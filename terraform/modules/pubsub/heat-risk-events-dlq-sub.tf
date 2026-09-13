resource "google_pubsub_subscription" "pubsub_events_dlq_subscription" {
  name  = var.pubsub_dlq_subscription_name
  topic = var.pubsub_dlq_topic_name
}