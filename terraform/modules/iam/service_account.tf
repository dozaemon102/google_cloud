data "google_project" "current" {
  project_id = var.project_id
}

# API service account
resource "google_service_account" "api_service_account" {
  account_id   = var.api_account_id
  display_name = var.api_account_id
}

resource "google_project_iam_member" "api_service_account_role" {
  project = var.project_id
  role    = "roles/datastore.viewer"
  member  = "serviceAccount:${google_service_account.api_service_account.email}"
}

# Enricher service account
resource "google_service_account" "enricher_service_account" {
  account_id   = var.enricher_account_id
  display_name = var.enricher_account_id
}

resource "google_project_iam_member" "enricher_service_account_role" {
  for_each = toset([
    "roles/datastore.user",
    "roles/bigquery.dataEditor",
  ])

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.enricher_service_account.email}"
}

# Collector service account
resource "google_service_account" "collector_service_account" {
  account_id   = var.collector_account_id
  display_name = var.collector_account_id
}

resource "google_project_iam_member" "collector_service_account_role" {
  project = var.project_id
  role    = "roles/pubsub.publisher"
  member  = "serviceAccount:${google_service_account.collector_service_account.email}"
}

# Scheduler service account
resource "google_service_account" "scheduler_service_account" {
  account_id   = var.scheduler_account_id
  display_name = var.scheduler_account_id
}

resource "google_project_iam_member" "schedure_service_account_role" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.scheduler_service_account.email}"
}

# Pubsub push service account
resource "google_service_account" "pubsub_push_service_account" {
  account_id   = var.pubsub_push_account_id
  display_name = var.pubsub_push_account_id
}

resource "google_project_iam_member" "pubsub_push_service_account_role" {
  project = var.project_id
  role    = "roles/run.invoker"
  member  = "serviceAccount:${google_service_account.pubsub_push_service_account.email}"
}

# Pubsub service agent token creator
resource "google_service_account_iam_member" "pubsub_service_agent_token_creator" {
  service_account_id = google_service_account.pubsub_push_service_account.name
  role               = "roles/iam.serviceAccountTokenCreator"
  member             = "serviceAccount:service-${data.google_project.current.number}@gcp-sa-pubsub.iam.gserviceaccount.com"
}
