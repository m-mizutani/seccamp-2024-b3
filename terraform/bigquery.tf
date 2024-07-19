resource "google_bigquery_dataset" "default" {
  dataset_id    = "common"
  friendly_name = "Monitoring dataset for common"
  location      = "US"
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
}
