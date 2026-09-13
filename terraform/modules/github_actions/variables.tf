variable "project_id" {
  type        = string
  description = "プロジェクトID"
}

variable "deployer_account_id" {
  type        = string
  description = "Deployer サービスアカウントID"
}

variable "pool_id" {
  type        = string
  description = "GitHub Actions プールID"
}

variable "repository_name" {
  type        = string
  description = "GitHub リポジトリ名"
}

variable "runtime_service_account_emails" {
  type        = list(string)
  description = "Cloud Run が実行時に使う SA（deployer に actAs を付与）"
}
