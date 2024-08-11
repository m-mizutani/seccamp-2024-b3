package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"net/http"
	"os"
	"time"

	"cloud.google.com/go/bigquery"
	"github.com/m-mizutani/goerr"
)

const (
	apiEndpointURL = "https://seccamp2024-nxgezih6la-an.a.run.app/api/logs"
	projectID      = "mztn-seccamp-2024"
	dataSet        = "secmon_vermilion"
	tableName      = "logs"
	duration       = 3 * time.Minute
)

/*
API response schema

- `logs`: ログの配列
    - `id` : ログごとにユニークなID
    - `timestamp`: RFC3339形式の時刻
    - `user`: 操作をした認証済みユーザ名。 `login` の場合は認証試行したユーザ名
    - `action`: `read`, `write` はドキュメントの操作、 `login` はログイン試行
    - `target`: 対象となるドキュメント。 `login` の場合は空
    - `sccuess`: `read`, `write` は認可の成否、 `login` は認証の成否
    - `remote` : 操作元のIPアドレス（v4のみ）
- `metadata`: ログ取得に関するメタデータ
    - `total`: 指定された時間範囲に存在するログ数
    - `offset`: オフセット（指定されてない場合はデフォルト値）
    - `limit`: ログ数制限（指定されてない場合はデフォルト値）
    - `begin`: 時間範囲の開始時刻（指定されてない場合はデフォルト値）
    - `end`: 時間範囲の終了時刻（指定されてない場合はデフォルト値）
*/

type apiResponse struct {
	Logs     []Log    `json:"logs"`
	Metadata Metadata `json:"metadata"`
}

type Log struct {
	ID        string `json:"id"`
	Timestamp string `json:"timestamp"`
	User      string `json:"user"`
	Action    string `json:"action"`
	Target    string `json:"target"`
	Success   bool   `json:"success"`
	Remote    string `json:"remote"`
}

type Metadata struct {
	Total  int    `json:"total"`
	Offset int    `json:"offset"`
	Limit  int    `json:"limit"`
	Begin  string `json:"begin"`
	End    string `json:"end"`
}

var logger *slog.Logger

func init() {
	handler := slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
		AddSource: true,
		Level:     slog.LevelInfo,
	})
	logger = slog.New(handler)
}

func main() {
	ctx := context.Background()
	now := time.Now()

	logger.Info("start to crawl logs", "now", now)

	bqClient, err := bigquery.NewClient(ctx, projectID)
	if err != nil {
		logger.Error("failed to create bigquery client", "error", err)
		os.Exit(1)
	}
	defer bqClient.Close()

	adaptors := &Adaptors{
		httpClient: &http.Client{},
		inserter:   bqClient.Dataset(dataSet).Table(tableName).Inserter(),
	}

	if err := CrawlLogs(ctx, adaptors, now); err != nil {
		logger.Error("failed to crawl logs", "error", err)
		os.Exit(1)
	}
}

func CrawlLogs(ctx context.Context, adaptors *Adaptors, now time.Time) error {
	offset := 0

	for {
		resp, err := fetchLogs(ctx, adaptors, now, offset)
		if err != nil {
			return goerr.Wrap(err)
		}
		logger.Info("fetched logs", "count", len(resp.Logs))

		if len(resp.Logs) == 0 {
			break
		}

		if err := adaptors.inserter.Put(ctx, resp.Logs); err != nil {
			return goerr.Wrap(err, "failed to put logs")
		}

		if resp.Metadata.Offset+len(resp.Logs) >= resp.Metadata.Total {
			break
		}

		offset = resp.Metadata.Offset + len(resp.Logs)
	}

	return nil
}

func fetchLogs(ctx context.Context, ad *Adaptors, now time.Time, offset int) (*apiResponse, error) {
	req, err := http.NewRequestWithContext(ctx, "GET", apiEndpointURL, nil)
	if err != nil {
		return nil, err
	}

	q := req.URL.Query()
	q.Add("offset", fmt.Sprintf("%d", offset))

	timeFmt := "2006-01-02T15:04:05"
	q.Add("begin", now.UTC().Add(-duration).Format(timeFmt))
	q.Add("end", now.UTC().Format(timeFmt))
	req.URL.RawQuery = q.Encode()

	resp, err := ad.httpClient.Do(req)
	if err != nil {
		return nil, goerr.Wrap(err, "failed to request to API")
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, goerr.New("unexpected status code").With("status", resp.StatusCode)
	}

	var apiResp apiResponse
	if err := json.NewDecoder(resp.Body).Decode(&apiResp); err != nil {
		return nil, goerr.Wrap(err, "failed to decode response")
	}

	return &apiResp, nil
}
