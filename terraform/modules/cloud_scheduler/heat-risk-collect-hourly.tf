resource "google_cloud_scheduler_job" "scheduler_job" {
  name             = "heat-risk-${var.env}-collect-hourly"
  description      = "Cloud Run job を起動する"
  schedule         = "0 * * * *"
  time_zone        = "Asia/Tokyo"
  attempt_deadline = "320s"

  retry_config {
    retry_count = 1
  }

  http_target {
    http_method = "POST"
    uri         = "https://run.googleapis.com/v2/${var.collector_job_id}:run"

    oauth_token {
      service_account_email = var.scheduler_account_email
      scope                 = "https://www.googleapis.com/auth/cloud-platform"
    }
  }
}