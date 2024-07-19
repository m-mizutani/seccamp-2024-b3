resource "google_cloud_run_v2_job" "crawler" {
  name     = "crawler-${var.id}"
  location = "asia-northeast1"

  template {
    template {
      containers {
        image = local.crawler_image
      }
      service_account = google_service_account.crawler.email
    }
  }
}

resource "google_cloud_run_v2_job" "detector" {
  name     = "detector-${var.id}"
  location = "asia-northeast1"

  template {
    template {
      containers {
        image = local.detector_image
      }
      service_account = google_service_account.detector.email
    }
  }
}

resource "google_cloud_run_v2_job_iam_member" "invoker_can_invoke_run" {
  for_each = {
    log_crawler = google_cloud_run_v2_job.crawler
    detector    = google_cloud_run_v2_job.detector
  }

  name     = each.value.name
  location = each.value.location
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.invoker.email}"
}

resource "google_cloud_run_v2_job_iam_member" "owner_can_invoke_run" {
  for_each = {
    log_crawler = google_cloud_run_v2_job.crawler
    detector    = google_cloud_run_v2_job.detector
  }

  name     = each.value.name
  location = each.value.location
  role     = "roles/run.admin"
  member   = "user:${var.owner}"
}
