resource "google_cloud_run_v2_service" "cloud_run_api" {
  name     = "heat-risk-${var.env}-api"
  location = "asia-northeast1"
  deletion_protection = false

  template {
    service_account = var.api_account_email
    containers {
      image = var.container_api_image
        env {
          name = "ALLOWED_ORIGINS"
          value = var.hosting_default_url
      }
    }
  }
}

resource "google_cloud_run_v2_service_iam_member" "api_public_invoker" {
  project  = var.project_id
  location = google_cloud_run_v2_service.cloud_run_api.location
  name     = google_cloud_run_v2_service.cloud_run_api.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}