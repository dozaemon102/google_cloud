resource "google_pubsub_topic" "pubsub_events_raw" {
  name = var.pubsub_raw_topic_name
}