package main

import (
	"context"

	"cloud.google.com/go/bigquery"
	"cloud.google.com/go/pubsub"
)

type Inquirer interface {
	Query(ctx context.Context, query string) (*bigquery.RowIterator, error)
}

type Publisher interface {
	Publish(ctx context.Context, msg *pubsub.Message) *pubsub.PublishResult
}

type Interfaces struct {
	Inquirer  Inquirer
	Publisher Publisher
}
