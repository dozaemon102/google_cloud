resource "google_cloud_run_v2_job" "cloud_run_collector" {
  name                = "heat-risk-${var.env}-collector"
  location            = "asia-northeast1"
  deletion_protection = false

  template {
    template {
      service_account = var.collector_account_email
      containers {
        image = var.container_collector_image

        env {
          name = "PROJECT_ID"
          value = var.project_id
        }

        env {
          name = "PUBSUB_RAW_TOPIC_NAME"
          value = var.pubsub_raw_topic_name
        }
      }
    }
  }
}