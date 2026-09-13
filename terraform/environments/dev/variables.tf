variable "project_id" {
  type        = string
  description = "デプロイ先の Google Cloud プロジェクト ID"
  default     = "test-pro-507713"
}

variable "app_image_tag" {
  type        = string
  description = "デプロイするイメージのタグ"
  default     = "latest"
}

variable "repository_name" {
  type        = string
  description = "GitHub リポジトリ名"
}