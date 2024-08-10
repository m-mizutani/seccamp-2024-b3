package main

import (
	"bytes"
	"context"
	_ "embed"
	"io"
	"net/http"
	"testing"
	"time"

	"github.com/m-mizutani/gt"
)

//go:embed testdata/resp1.json
var resp1 []byte

//go:embed testdata/resp2.json
var resp2 []byte

func TestGetLogs(t *testing.T) {
	ctx := context.Background()
	now := time.Now()

	respData := [][]byte{resp1, resp2}
	respIndex := 0

	adaptors := &Adaptors{
		httpClient: &HTTPClientMock{
			DoFunc: func(req *http.Request) (*http.Response, error) {
				resp := &http.Response{
					StatusCode: 200,
					Body:       io.NopCloser(bytes.NewReader(respData[respIndex])),
				}
				respIndex++
				return resp, nil
			},
		},
		inserter: &InserterMock{
			PutFunc: func(ctx context.Context, rows any) error {
				return nil
			},
		},
	}

	gt.NoError(t, CrawlLogs(ctx, adaptors, now))
	gt.Equal(t, len(adaptors.httpClient.(*HTTPClientMock).calls.Do), 2)
	gt.Equal(t, len(adaptors.inserter.(*InserterMock).calls.Put), 2)

	// Check the requests for inserter
	putArgs := adaptors.inserter.(*InserterMock).calls.Put
	rows1 := gt.Cast[[]Log](t, putArgs[0].Rows)
	gt.Equal(t, rows1[0].User, "dora56")
	gt.Equal(t, rows1[1].User, "harry86")
	rows2 := gt.Cast[[]Log](t, putArgs[1].Rows)
	gt.Equal(t, rows2[0].User, "alice1")
}
