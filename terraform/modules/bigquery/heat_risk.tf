resource "google_bigquery_dataset" "bigquery_dataset_heat_risk" {
  dataset_id    = "heat_risk_${var.env}"
  friendly_name = "heat_risk_${var.env}"
  description   = "heat_riskのデータセット"
  location      = "asia-northeast1"
}