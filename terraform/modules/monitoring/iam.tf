resource "google_pubsub_topic_iam_member" "notify" {
  topic  = google_pubsub_topic.notify.name
  role   = "roles/pubsub.publisher"
  member = "serviceAccount:${google_service_account.detector.email}"
}
