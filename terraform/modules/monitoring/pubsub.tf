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
