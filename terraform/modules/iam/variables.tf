variable "project_id" {
  type        = string
  description = "プロジェクトID"
}

variable "api_account_id" {
  type        = string
  description = "API サービスアカウントID"
}

variable "enricher_account_id" {
  type        = string
  description = "Enricher サービスアカウントID"
}

variable "collector_account_id" {
  type        = string
  description = "Collector サービスアカウントID"
}

variable "scheduler_account_id" {
  type        = string
  description = "Scheduler サービスアカウントID"
}

variable "pubsub_push_account_id" {
  type        = string
  description = "Pub/Sub Push サービスアカウントID"
}