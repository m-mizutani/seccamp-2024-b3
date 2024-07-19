
# module "invoke-crawler" {
#   source  = "GoogleCloudPlatform/cloud-workflows/google"
#   version = "~> 0.1"

#   project_id            = var.project_id
#   workflow_name         = "invoke-crawler-${var.id}"
#   region                = "asia-northeast1"
#   service_account_email = google_service_account.invoker.email
#   workflow_trigger = {
#     cloud_scheduler = {
#       name                  = "invoke-crawler-${var.id}"
#       cron                  = "*/5 * * * *"
#       time_zone             = "Asia/Tokyo"
#       deadline              = "120s"
#       service_account_email = google_service_account.scheduler.email
#     }
#   }

#   workflow_labels = {
#     "run_id" = google_cloud_run_v2_job.crawler.uid
#   }

#   workflow_source = <<EOT
# main:
#   params: [event]
#   steps:
#     - run_job:
#         call: googleapis.run.v1.namespaces.jobs.run
#         args:
#           name: namespaces/${var.project_id}/jobs/crawler-${var.id}
#           location: asia-northeast1
#         result: job_execution
#     - finish:
#         return: $${job_execution}
# EOT
# }

# module "invoke-detector" {
#   source  = "GoogleCloudPlatform/cloud-workflows/google"
#   version = "~> 0.1"

#   project_id            = var.project_id
#   workflow_name         = "invoke-detector-${var.id}"
#   region                = "asia-northeast1"
#   service_account_email = google_service_account.invoker.email
#   workflow_trigger = {
#     cloud_scheduler = {
#       name                  = "invoke-detector-${var.id}"
#       cron                  = "*/5 * * * *"
#       time_zone             = "Asia/Tokyo"
#       deadline              = "120s"
#       service_account_email = google_service_account.scheduler.email
#     }
#   }

#   workflow_labels = {
#     "run_id" = google_cloud_run_v2_job.detector.uid
#   }

#   workflow_source = <<EOT
# main:
#   params: [event]
#   steps:
#     - run_job:
#         call: googleapis.run.v1.namespaces.jobs.run
#         args:
#           name: namespaces/${var.project_id}/jobs/detector-${var.id}
#           location: asia-northeast1
#         result: job_execution
#     - finish:
#         return: $${job_execution}
# EOT
# }
