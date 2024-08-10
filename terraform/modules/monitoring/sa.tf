resource "google_service_account" "crawler" {
  account_id   = "runner-${var.id}"
  display_name = "Cralwer for ${var.id}"
}

resource "google_service_account" "detector" {
  account_id   = "detector-${var.id}"
  display_name = "Detector for ${var.id}"
}

resource "google_service_account" "invoker" {
  account_id   = "invoker-${var.id}"
  display_name = "Cloud Run Invoker for ${var.id}"
}

resource "google_service_account" "notifier" {
  account_id   = "notifier-${var.id}"
  display_name = "Cloud Run notifier for ${var.id}"
}

resource "google_service_account_iam_member" "invoker_is_crawler" {
  service_account_id = google_service_account.crawler.id
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.invoker.email}"
}

resource "google_service_account_iam_member" "invoker_is_detector" {
  service_account_id = google_service_account.detector.id
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.invoker.email}"
}

resource "google_service_account_iam_member" "owner_is_crawler" {
  service_account_id = google_service_account.crawler.id
  role               = "roles/iam.serviceAccountUser"
  member             = "user:${var.owner}"
}

resource "google_service_account_iam_member" "owner_is_detector" {
  service_account_id = google_service_account.detector.id
  role               = "roles/iam.serviceAccountUser"
  member             = "user:${var.owner}"
}
