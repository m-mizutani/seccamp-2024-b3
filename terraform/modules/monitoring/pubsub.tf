resource "google_pubsub_topic" "notify" {
  project = var.project_id
  name    = "notify-${var.id}"
}

resource "google_pubsub_subscription" "notify" {
  project              = var.project_id
  name                 = "notify-${var.id}"
  topic                = google_pubsub_topic.notify.name
  ack_deadline_seconds = 10

  push_config {
    oidc_token {
      service_account_email = google_service_account.notifier.email
    }
    push_endpoint = var.notify_endpoint
  }
}

resource "google_pubsub_topic_iam_member" "detector_is_publisher" {
  topic  = google_pubsub_topic.notify.name
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${google_service_account.detector.email}"
}

resource "google_pubsub_topic_iam_member" "owner_is_admin" {
  topic  = google_pubsub_topic.notify.name
  role   = "roles/pubsub.admin"
  member = "user:${var.owner}"
}

resource "google_pubsub_topic" "test" {
  project = var.project_id
  name    = "test-${var.id}"
}

resource "google_pubsub_subscription" "test" {
  project              = var.project_id
  name                 = "test-${var.id}"
  topic                = google_pubsub_topic.test.name
}

resource "google_pubsub_topic_iam_member" "detector_is_test_publisher" {
  topic  = google_pubsub_topic.test.name
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${google_service_account.detector.email}"
}

resource "google_pubsub_topic_iam_member" "owner_is_test_admin" {
  topic  = google_pubsub_topic.test.name
  role   = "roles/pubsub.admin"
  member = "user:${var.owner}"
}
