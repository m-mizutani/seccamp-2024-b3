resource "google_cloud_scheduler_job" "invoke-crawler" {
  provider         = google-beta
  name             = "invoke-crawler-${var.id}"
  description      = "test http job"
  schedule         = "*/2 * * * *"
  attempt_deadline = "120s"
  region           = "asia-northeast1"
  project          = var.project_id
  paused           = var.paused

  retry_config {
    retry_count = 3
  }

  http_target {
    http_method = "POST"
    uri         = "https://${google_cloud_run_v2_job.crawler.location}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${data.google_project.main.number}/jobs/${google_cloud_run_v2_job.crawler.name}:run"

    oauth_token {
      service_account_email = google_service_account.invoker.email
    }
  }

  depends_on = [google_cloud_run_v2_job_iam_member.invoker_can_invoke_run]
}

resource "google_cloud_scheduler_job" "invoke-detector" {
  provider         = google-beta
  name             = "invoke-detector-${var.id}"
  description      = "test http job"
  schedule         = "*/2 * * * *"
  attempt_deadline = "120s"
  region           = "asia-northeast1"
  project          = var.project_id
  paused           = var.paused

  retry_config {
    retry_count = 3
  }

  http_target {
    http_method = "POST"
    uri         = "https://${google_cloud_run_v2_job.detector.location}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${data.google_project.main.number}/jobs/${google_cloud_run_v2_job.detector.name}:run"

    oauth_token {
      service_account_email = google_service_account.invoker.email
    }
  }

  depends_on = [google_cloud_run_v2_job_iam_member.invoker_can_invoke_run]
}
