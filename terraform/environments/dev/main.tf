module "cloud_run" {
  source                            = "../../modules/cloud_run"
  env                               = "dev"
  project_id                        = var.project_id
  container_api_image               = "${module.artifact_registry.registry_uri}/api:${var.app_image_tag}"
  container_enricher_image          = "${module.artifact_registry.registry_uri}/enricher:${var.app_image_tag}"
  container_collector_image         = "${module.artifact_registry.registry_uri}/collector:${var.app_image_tag}"
  api_account_email                 = module.iam.api_account_email
  enricher_account_email            = module.iam.enricher_account_email
  collector_account_email           = module.iam.collector_account_email
  pubsub_raw_topic_name             = "heat-risk-dev-events-raw"
  pubsub_enricher_subscription_name = "heat-risk-dev-events-enricher"
  hosting_default_url               = module.firebase.hosting_default_url
}

module "artifact_registry" {
  source = "../../modules/artifact_registry"
  env    = "dev"
}

module "pubsub" {
  source                            = "../../modules/pubsub"
  project_id                        = var.project_id
  env                               = "dev"
  pubsub_raw_topic_name             = "heat-risk-dev-events-raw"
  pubsub_enricher_subscription_name = "heat-risk-dev-events-enricher"
  pubsub_dlq_topic_name             = "heat-risk-dev-events-dlq"
  pubsub_dlq_subscription_name      = "heat-risk-dev-events-dlq-sub"
  enricher_service_uri              = module.cloud_run.enricher_service_uri
  pubsub_push_account_email         = module.iam.pubsub_push_account_email
}

module "firestore" {
  source     = "../../modules/firestore"
  project_id = var.project_id
}

module "cloud_scheduler" {
  source                  = "../../modules/cloud_scheduler"
  env                     = "dev"
  collector_job_id        = module.cloud_run.collector_job_id
  scheduler_account_email = module.iam.scheduler_account_email
}

module "iam" {
  source                 = "../../modules/iam"
  project_id             = var.project_id
  api_account_id         = "heat-risk-dev-api-sa"
  enricher_account_id    = "heat-risk-dev-enricher-sa"
  collector_account_id   = "heat-risk-dev-collector-sa"
  scheduler_account_id   = "heat-risk-dev-scheduler-sa"
  pubsub_push_account_id = "heat-risk-dev-pubsub-push-sa"
}

module "bigquery" {
  source = "../../modules/bigquery"
  env    = "dev"
}

module "project_services" {
  source     = "../../modules/project_services"
  project_id = var.project_id
}

module "firebase" {
  source     = "../../modules/firebase"
  env        = "dev"
  project_id = var.project_id

  providers = {
    google-beta = google-beta
  }
}

module "github_actions" {
  source              = "../../modules/github_actions"
  project_id          = var.project_id
  deployer_account_id = "heat-risk-dev-deployer-sa"
  pool_id             = "heat-risk-dev-github"
  repository_name     = var.repository_name
  
  runtime_service_account_emails = [
    module.iam.api_account_email,
    module.iam.enricher_account_email,
    module.iam.collector_account_email,
  ]
}