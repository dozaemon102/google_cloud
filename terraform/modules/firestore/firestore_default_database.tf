resource "google_firestore_database" "firestore_database" {
  project     = var.project_id
  name        = "(default)"
  location_id = "asia-northeast1"
  type        = "FIRESTORE_NATIVE"
}