package main

import (
	"context"

	"cloud.google.com/go/pubsub"
)

type RowIterator interface {
	Next(dst interface{}) error
}

type Inquirer interface {
	Query(ctx context.Context, query string) (RowIterator, error)
}

type Publisher interface {
	Publish(ctx context.Context, msg *pubsub.Message) PublishResult
}

type PublishResult interface {
	Get(ctx context.Context) (string, error)
}

type Interfaces struct {
	Inquirer  Inquirer
	Publisher Publisher
}
