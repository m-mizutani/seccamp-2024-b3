resource "google_bigquery_dataset" "default" {
  dataset_id    = "secmon_${var.id}"
  friendly_name = "Monitoring dataset for ${var.id}"
  location      = "US"
}

resource "google_bigquery_table" "logs" {
  dataset_id = google_bigquery_dataset.default.dataset_id
  table_id   = "logs"

  deletion_protection = false
  schema              = <<EOF
[
  {
    "name": "id",
    "type": "STRING"
  },
  {
    "name": "timestamp",
    "type": "TIMESTAMP"
  },
  {
    "name": "user",
    "type": "STRING"
  },
  {
    "name": "action",
    "type": "STRING"
  },
  {
    "name": "target",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "success",
    "type": "BOOLEAN"
  },
  {
    "name": "remote",
    "type": "STRING"
  }
]
EOF

}

resource "google_bigquery_table_iam_member" "owner_is_data_owner" {
  dataset_id = google_bigquery_dataset.default.dataset_id
  table_id   = google_bigquery_table.logs.table_id
  role       = "roles/bigquery.dataOwner"
  member     = "user:${var.owner}"
}

resource "google_bigquery_table_iam_member" "crawler_is_data_editor" {
  dataset_id = google_bigquery_dataset.default.dataset_id
  table_id   = google_bigquery_table.logs.table_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.crawler.email}"
}
