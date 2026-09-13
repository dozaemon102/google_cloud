resource "google_pubsub_subscription" "pubsub_enricher_subscription" {
  name  = var.pubsub_enricher_subscription_name
  topic = google_pubsub_topic.pubsub_events_raw.id

  push_config {
    push_endpoint = var.enricher_service_uri
    oidc_token {
      service_account_email = var.pubsub_push_account_email
    }
  }

  dead_letter_policy {
    dead_letter_topic     = google_pubsub_topic.pubsub_events_dlq.id
    max_delivery_attempts = 5
  }
}

resource "google_pubsub_subscription_iam_member" "pubsub_enricher_subscription_subscriber" {
  subscription = google_pubsub_subscription.pubsub_enricher_subscription.name
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}