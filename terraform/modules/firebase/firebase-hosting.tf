resource "google_firebase_project" "firebase_project" {
  provider = google-beta
  project  = var.project_id
}

resource "google_firebase_hosting_site" "hosting_site" {
  provider = google-beta
  project  = var.project_id
  site_id  = "heat-risk-${var.env}"

  depends_on = [google_firebase_project.firebase_project]
}
