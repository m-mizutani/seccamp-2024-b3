resource "google_storage_bucket" "common" {
  name          = "mztn-seccamp-2024-common"
  location      = "ASIA"
  storage_class = "STANDARD"

  public_access_prevention = "enforced"
}
