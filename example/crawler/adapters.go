package main

import (
	"context"
	"net/http"
)

type HTTPClient interface {
	Do(req *http.Request) (*http.Response, error)
}

// PutLogs is a function type for putting logs into BigQuery.
type Inserter interface {
	Put(ctx context.Context, rows any) error
}

type Adaptors struct {
	httpClient HTTPClient
	inserter   Inserter
}
