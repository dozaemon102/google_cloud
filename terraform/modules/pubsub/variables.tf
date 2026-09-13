variable "project_id" {
  type        = string
  description = "プロジェクト ID"
}

variable "env" {
  type        = string
  description = "環境"
}

variable "pubsub_raw_topic_name" {
  type        = string
  description = "Pub/Sub の raw トピック名"
}

variable "pubsub_enricher_subscription_name" {
  type        = string
  description = "Pub/Sub の enricher サブスクリプション名"
}

variable "pubsub_dlq_topic_name" {
  type        = string
  description = "Pub/Sub の dlq トピック名"
}

variable "pubsub_dlq_subscription_name" {
  type        = string
  description = "Pub/Sub の dlq サブスクリプション名"
}

variable "enricher_service_uri" {
  type        = string
  description = "Enricher の Service URI"
}

variable "pubsub_push_account_email" {
  type        = string
  description = "Pub/Sub Push の Service Account Email"
}