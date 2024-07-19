package main

import (
	"context"
	"fmt"
	"log"
	"os"

	"cloud.google.com/go/bigquery"
	"cloud.google.com/go/pubsub"
	"google.golang.org/api/iterator"
)

func main() {
	ctx := context.Background()

	// 環境変数から設定を取得
	projectID := os.Getenv("GOOGLE_CLOUD_PROJECT_ID")
	if projectID == "" {
		log.Fatalf("GOOGLE_CLOUD_PROJECT_ID environment variable is not set")
	}

	bigQueryTable := os.Getenv("BIGQUERY_TABLE")
	if bigQueryTable == "" {
		log.Fatalf("BIGQUERY_TABLE environment variable is not set")
	}

	pubSubTopicID := os.Getenv("PUBSUB_TOPIC_ID")
	if pubSubTopicID == "" {
		log.Fatalf("PUBSUB_TOPIC_ID environment variable is not set")
	}

	// BigQueryクライアントの設定
	bqClient, err := bigquery.NewClient(ctx, projectID)
	if err != nil {
		log.Fatalf("Failed to create BigQuery client: %v", err)
	}
	defer bqClient.Close()

	// PubSubクライアントの設定
	psClient, err := pubsub.NewClient(ctx, projectID)
	if err != nil {
		log.Fatalf("Failed to create PubSub client: %v", err)
	}
	defer psClient.Close()

	// BigQueryクエリを実行

	sql := fmt.Sprintf(`SELECT value, ioc_type FROM %s WHERE id = "6c9a43a5-752e-4673-b5f6-147d23e233b1"`, bigQueryTable)
	log.Printf("Executing query: %s\n", sql)

	query := bqClient.Query(sql)
	it, err := query.Read(ctx)
	if err != nil {
		log.Fatalf("Failed to execute query: %v", err)
	}

	// クエリ結果を処理し、レコードが取得できた場合にサマリを作成
	for {
		var row struct {
			Value   string `bigquery:"value"`
			IOCType string `bigquery:"ioc_type"`
		}
		err := it.Next(&row)
		if err == iterator.Done {
			break
		}
		if err != nil {
			log.Fatalf("Failed to iterate over query results: %v", err)
		}

		// フィールドの内容を人間が読める英文にサマリ
		summary := fmt.Sprintf("Record with: Value=%s (%s)", row.Value, row.IOCType)

		// PubSubトピックにメッセージを送信
		topic := psClient.Topic(pubSubTopicID)
		result := topic.Publish(ctx, &pubsub.Message{
			Data: []byte(summary),
		})

		// メッセージの送信結果を確認
		id, err := result.Get(ctx)
		if err != nil {
			log.Fatalf("Failed to publish message: %v", err)
		}
		log.Printf("Published message with ID: %s\n", id)
	}
}
