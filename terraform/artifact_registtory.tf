resource "google_artifact_registry_repository" "common" {
  repository_id = "containers-common"
  location      = "asia-northeast1"
  format        = "DOCKER"
}
