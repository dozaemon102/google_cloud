output "collector_job_id" {
  value = google_cloud_run_v2_job.cloud_run_collector.id
}

output "enricher_service_uri" {
  value = google_cloud_run_v2_service.cloud_run_enricher.uri
}