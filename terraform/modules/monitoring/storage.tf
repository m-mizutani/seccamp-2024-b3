resource "google_storage_bucket_iam_member" "owner_is_common_storage_viewer" {
  bucket = var.common_storage
  role   = "roles/storage.objectViewer"
  member = "user:${var.owner}"
}