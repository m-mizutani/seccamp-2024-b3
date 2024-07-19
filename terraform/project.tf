locals {
  google_cloud_services = [
    "iam.googleapis.com",
    "logging.googleapis.com",
    "artifactregistry.googleapis.com",
    "monitoring.googleapis.com",
    "run.googleapis.com",
    "workflows.googleapis.com",
    "bigquery.googleapis.com",
    "cloudscheduler.googleapis.com",
  ]
}

resource "google_project_service" "project" {
  for_each = toset(local.google_cloud_services)
  project  = local.project_id
  service  = each.key

  disable_on_destroy = false
}
