package main

import (
	"context"
	"testing"
	"time"

	"cloud.google.com/go/bigquery"
	"cloud.google.com/go/pubsub"
	"github.com/m-mizutani/goerr"
	"github.com/m-mizutani/gt"
	"google.golang.org/api/iterator"
)

func TestDetect(t *testing.T) {
	iterCount := 0
	iMock := &InquirerMock{
		QueryFunc: func(ctx context.Context, query string) (RowIterator, error) {
			return &RowIteratorMock{
				NextFunc: func(dst interface{}) error {
					rows := dst.(*[]bigquery.Value)
					iterCount++
					switch iterCount {
					case 1:
						*rows = []bigquery.Value{"foo", "1.2.3.4", time.Now()}
						return nil
					case 2:
						return iterator.Done
					default:
						return goerr.New("unexpected iteration")
					}
				},
			}, nil
		},
	}
	pMock := &PublisherMock{
		PublishFunc: func(ctx context.Context, msg *pubsub.Message) PublishResult {
			return &PublishResultMock{
				GetFunc: func(ctx context.Context) (string, error) {
					return "", nil
				},
			}
		},
	}

	ifs := &Interfaces{
		Inquirer:  iMock,
		Publisher: pMock,
	}

	ctx := context.Background()
	gt.NoError(t, detect(ctx, ifs))
	gt.Equal(t, iterCount, 2)
	gt.A(t, pMock.PublishCalls()).Length(1)
}
