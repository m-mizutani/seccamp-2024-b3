package main

import (
	"context"
	_ "embed"
	"fmt"
	"log/slog"
	"os"
	"time"

	"cloud.google.com/go/bigquery"
	"cloud.google.com/go/pubsub"
	"github.com/m-mizutani/goerr"
	"google.golang.org/api/iterator"
)

const (
	projectID = "mztn-seccamp-2024"
	dataSet   = "secmon_vermilion"
	tableName = "logs"
)

var logger *slog.Logger

func init() {
	handler := slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
		AddSource: true,
		Level:     slog.LevelInfo,
	})
	logger = slog.New(handler)
}

type BQClient struct {
	client *bigquery.Client
}

func (bq *BQClient) Query(ctx context.Context, query string) (*bigquery.RowIterator, error) {
	return bq.client.Query(query).Read(ctx)
}

func main() {
	ctx := context.Background()

	// Setup BigQuery client
	bq, err := bigquery.NewClient(ctx, projectID)
	if err != nil {
		logger.Error("failed to create bigquery client", "error", err)
		os.Exit(1)
	}
	defer bq.Close()

	// Setup PubSub client
	ps, err := pubsub.NewClient(ctx, projectID)
	if err != nil {
		logger.Error("failed to create pubsub client", "error", err)
		os.Exit(1)
	}
	defer ps.Close()

	ps.Topic("alert").Publish(ctx, &pubsub.Message{Data: []byte("Hello, World!")})
	ifs := &Interfaces{
		Inquirer:  &BQClient{client: bq},
		Publisher: ps.Topic("notify-vermilion"),
	}

	if err := detect(ctx, ifs); err != nil {
		logger.Error("failed to detect", "error", err)
		os.Exit(1)
	}
}

func detect(ctx context.Context, ifs *Interfaces) error {
	alerts, err := detectAlert(ctx, ifs)
	if err != nil {
		logger.Error("failed to detect alert", "error", err)
		os.Exit(1)
	}

	if len(alerts) == 0 {
		logger.Info("no alert")
		return nil
	}

	for _, alert := range alerts {
		msg := &pubsub.Message{
			Data: []byte(fmt.Sprintf("Suspicious activity by '%s' is detected as %s", alert.UserName, alert.Reason)),
		}

		result := ifs.Publisher.Publish(ctx, msg)
		serverID, err := result.Get(ctx)
		if err != nil {
			return goerr.Wrap(err)
		}

		logger.Info("published", "serverID", serverID, "alert", alert)
	}

	return nil
}

type Alert struct {
	UserName  string
	IPAddress string
	Reason    string
	Timestamp time.Time
}

//go:embed query/check_ioc.sql
var checkIocSQL string

func detectAlert(ctx context.Context, ifs *Interfaces) ([]*Alert, error) {
	it, err := ifs.Inquirer.Query(ctx, checkIocSQL)
	if err != nil {
		logger.Error("failed to query logs", "error", err)
		os.Exit(1)
	}

	var alerts []*Alert
	for {
		var row []bigquery.Value
		err := it.Next(&row)
		if err == iterator.Done {
			break
		}
		if err != nil {
			return nil, goerr.Wrap(err)
		}

		alerts = append(alerts, &Alert{
			UserName:  row[0].(string),
			IPAddress: row[1].(string),
			Timestamp: row[2].(time.Time),
			Reason:    "accessing from IOC",
		})
	}

	return alerts, nil
}
