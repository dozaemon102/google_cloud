variable "env" {
  type        = string
  description = "環境"
}

variable "collector_job_id" {
  type        = string
  description = "collectorのJob ID"
}

variable "scheduler_account_email" {
  type        = string
  description = "collectorのサービスアカウントメールアドレス"
}