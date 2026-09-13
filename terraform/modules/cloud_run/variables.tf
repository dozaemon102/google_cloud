variable "env" {
  type        = string
  description = "環境"
}

variable "project_id" {
  type        = string
  description = "プロジェクトID"
}

variable "container_api_image" {
  type        = string
  description = "Cloud Run API で使用するコンテナイメージ URL"
}

variable "container_enricher_image" {
  type        = string
  description = "Cloud Run enricher で使用するコンテナイメージ URL"
}

variable "container_collector_image" {
  type        = string
  description = "Cloud Run collector で使用するコンテナイメージ URL"
}

variable "api_account_email" {
  type        = string
  description = "API サービスアカウントメールアドレス"
}

variable "enricher_account_email" {
  type        = string
  description = "Enricher サービスアカウントメールアドレス"
}

variable "collector_account_email" {
  type        = string
  description = "Collector サービスアカウントメールアドレス"
}

variable "pubsub_raw_topic_name" {
  type        = string
  description = "Raw トピックID"
}

variable "pubsub_enricher_subscription_name" {
  type        = string
  description = "Enricher サブスクリプション名"
}

variable "hosting_default_url" {
  type        = string
  description = "Firebase Hosting デフォルトURL"
}