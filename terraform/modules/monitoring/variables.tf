variable "id" {
  type        = string
  description = "ID of the resources"
}

variable "project_id" {
  description = "The project ID"
  type        = string
}

variable "common_repository" {
  description = "The common image repository"
  type        = string
}

variable "common_storage" {
  description = "The common storage"
  type        = string
}

variable "viewer_role" {
  description = "The viewer role"
  type        = string
}

variable "use_dummy" {
  description = "Whether to use dummy image"
  type        = bool
  default     = false
}

variable "owner" {
  description = "The owner of the resources"
  type        = string
}

variable "notify_endpoint" {
  description = "The endpoint to notify"
  type        = string
}

variable "paused" {
  description = "Whether to pause the monitoring"
  type        = bool
  default     = false
}

locals {
  dummy_image = "asia-northeast1-docker.pkg.dev/mztn-seccamp-2024/containers-common/dummy:latest"

  crawler_image  = var.use_dummy ? local.dummy_image : "asia-northeast1-docker.pkg.dev/${var.project_id}/containers-${var.id}/crawler:latest"
  detector_image = var.use_dummy ? local.dummy_image : "asia-northeast1-docker.pkg.dev/${var.project_id}/containers-${var.id}/detector:latest"
}
