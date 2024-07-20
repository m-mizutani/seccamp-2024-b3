resource "google_project_iam_member" "viewer" {
  project = var.project_id
  role    = "roles/viewer"
  member  = "user:${var.owner}"
}

resource "google_project_iam_member" "workflow_runner" {
  project = var.project_id
  role    = "roles/workflows.invoker"
  member  = "serviceAccount:${google_service_account.scheduler.email}"
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
