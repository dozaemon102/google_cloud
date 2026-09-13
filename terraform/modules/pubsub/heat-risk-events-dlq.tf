resource "google_pubsub_topic" "pubsub_events_dlq" {
  name = var.pubsub_dlq_topic_name
}

resource "google_pubsub_topic_iam_member" "pubsub_events_dlq_publisher" {
  topic   = google_pubsub_topic.pubsub_events_dlq.name
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}