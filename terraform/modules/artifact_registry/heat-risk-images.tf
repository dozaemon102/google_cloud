resource "google_artifact_registry_repository" "artifact_registry_images" {
  location      = "asia-northeast1"
  repository_id = "heat-risk-${var.env}-images"
  format        = "DOCKER"
}