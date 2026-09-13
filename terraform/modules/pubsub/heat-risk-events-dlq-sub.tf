resource "google_pubsub_subscription" "pubsub_events_dlq_subscription" {
  name  = var.pubsub_dlq_subscription_name
  topic = google_pubsub_topic.pubsub_events_dlq.id
}