provider "google" {
  project = var.project_id
  region  = "asia-northeast1"
}

provider "google-beta" {
  project = var.project_id
  region  = "asia-northeast1"
}