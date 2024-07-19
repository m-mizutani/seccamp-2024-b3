resource "google_artifact_registry_repository" "containers" {
  repository_id = "containers-${var.id}"
  location      = "asia-northeast1"
  format        = "DOCKER"
}

resource "google_artifact_registry_repository_iam_member" "operator_is_repository_writer" {
  repository = google_artifact_registry_repository.containers.id
  role       = "roles/artifactregistry.writer"
  member     = "user:${var.owner}"
}

resource "google_artifact_registry_repository_iam_member" "crawler_is_repository_reader" {
  repository = google_artifact_registry_repository.containers.id
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.crawler.email}"
}

# for common repository
resource "google_artifact_registry_repository_iam_member" "crawler_is_common_repository_reader" {
  repository = var.common_repository
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.crawler.email}"
}
