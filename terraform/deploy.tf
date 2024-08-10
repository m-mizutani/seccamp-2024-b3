locals {
  config = jsondecode(file("${path.module}/config.json"))
}

module "deploy" {
  for_each = { for m in local.config.members : m.id => m }

  source    = "./modules/monitoring"
  id        = each.value.id
  use_dummy = each.value.use_dummy
  owner     = each.value.email
  paused    = each.value.paused

  project_id        = local.project_id
  common_repository = google_artifact_registry_repository.common.id
  common_storage    = google_storage_bucket.common.id
  viewer_role       = google_project_iam_custom_role.custom-viewer.id
  notify_endpoint   = local.config.notify_endpoint
}
