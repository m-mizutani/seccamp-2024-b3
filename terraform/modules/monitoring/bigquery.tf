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

resource "google_bigquery_table" "ioc" {
  dataset_id = google_bigquery_dataset.default.dataset_id
  table_id   = "ioc"

  deletion_protection = false
  schema              = <<EOF
[
  {
    "name": "id",
    "type": "STRING",
    "description": "ID of IoC"
  },
  {
    "name": "ioc_type",
    "type": "STRING",
    "description": "Type of IoC (ipaddr, domain, url, etc)"
  },
  {
    "name": "created_at",
    "type": "TIMESTAMP",
    "description": "Created at"
  },
  {
    "name": "value",
    "type": "STRING",
    "description": "Value of IoC"
  }
]
EOF

  external_data_configuration {
    source_uris = ["gs://mztn-seccamp-2024-public/ioc.csv"]
    source_format = "CSV"
    autodetect = true
    csv_options {
      quote = "\""
      skip_leading_rows = 1
    }
  }
}

resource "google_bigquery_dataset_iam_member" "owner_is_data_owner" {
  dataset_id = google_bigquery_dataset.default.dataset_id
  role       = "roles/bigquery.dataOwner"
  member     = "user:${var.owner}"
}

resource "google_bigquery_dataset_iam_member" "detector_is_common_data_owner" {
  dataset_id = google_bigquery_dataset.default.dataset_id
  role       = "roles/bigquery.dataViewer"
  member     = "serviceAccount:${google_service_account.detector.email}"
}

resource "google_bigquery_dataset_iam_member" "crawler_is_data_editor" {
  dataset_id = google_bigquery_dataset.default.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = "serviceAccount:${google_service_account.crawler.email}"
}
