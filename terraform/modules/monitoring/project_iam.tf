locals {
  view_roles = [
    "roles/logging.viewer",
  ]
}

resource "google_project_iam_member" "logging_viewer" {
  for_each = toset(local.view_roles)

  project = var.project_id
  role    = each.value
  member  = "user:${var.owner}"
}

resource "google_project_iam_member" "detector_is_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.detector.email}"
}

resource "google_project_iam_member" "owner_is_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = "user:${var.owner}"
}

resource "google_project_iam_member" "viewer" {
  project = var.project_id
  role    = var.viewer_role
  member  = "user:${var.owner}"
}
