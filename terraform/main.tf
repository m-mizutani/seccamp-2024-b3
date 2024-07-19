terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.51.0"
    }
  }

  backend "gcs" {
    bucket = "mztn-seccamp-2024-state"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = local.project_id
}

locals {
  project_id = "mztn-seccamp-2024"
}
