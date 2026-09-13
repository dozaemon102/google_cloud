output "api_account_email" {
  value = google_service_account.api_service_account.email
}

output "enricher_account_email" {
  value = google_service_account.enricher_service_account.email
}

output "collector_account_email" {
  value = google_service_account.collector_service_account.email
}

output "scheduler_account_email" {
  value = google_service_account.scheduler_service_account.email
}

output "pubsub_push_account_email" {
  value = google_service_account.pubsub_push_service_account.email
}