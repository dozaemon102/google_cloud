resource "google_cloud_run_v2_service" "cloud_run_enricher" {
  name     = "heat-risk-${var.env}-enricher"
  location = "asia-northeast1"
  deletion_protection = false

  template {
    service_account = var.enricher_account_email
    containers {
      image = var.container_enricher_image
      
      env {
        name = "PROJECT_ID"
        value = var.project_id
      }
      
      env {
        name = "PUBSUB_ENRICHER_SUBSCRIPTION_NAME"
        value = var.pubsub_enricher_subscription_name
      }
    }
  }
}