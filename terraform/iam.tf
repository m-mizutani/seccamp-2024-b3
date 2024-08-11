resource "google_project_iam_custom_role" "custom-viewer" {
  role_id     = "CustomViewer"
  title       = "Custom viewer"
  description = "A description"
  permissions = [
    "serviceusage.services.list",
    "run.jobs.list",
    "run.executions.get",
    "run.executions.list",
    "run.jobs.get",
    "run.jobs.list",
    "run.jobs.listEffectiveTags",
    "run.jobs.listTagBindings",
    "run.locations.list",
    "run.operations.get",
    "run.operations.list",
    "run.revisions.get",
    "run.revisions.list",
    "run.routes.get",
    "run.routes.list",
    "run.services.get",
    "run.services.list",
    "run.services.listEffectiveTags",
    "run.services.listTagBindings",
    "monitoring.dashboards.get",
    "monitoring.dashboards.list",
    "cloudscheduler.jobs.list",
    "cloudscheduler.jobs.get",
    "cloudscheduler.locations.list",
    "artifactregistry.repositories.list",
    "artifactregistry.repositories.get",
    "artifactregistry.locations.list",
    "artifactregistry.dockerimages.list",
    "pubsub.topics.list",
  ]
}
