resource "google_bigquery_table" "bigquery_table_risk_assessments" {
  dataset_id = google_bigquery_dataset.bigquery_dataset_heat_risk.dataset_id
  table_id   = "risk_assessments"
  deletion_protection = true
  
  time_partitioning {
    type = "DAY"
    field = "forecast_at"
    expiration_ms = 3600000 * 24 * 90
  }

  schema = <<EOF
[
  {
    "name": "event_id",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "イベントID" 
  },
  {
    "name": "city_id",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "都市ID"
  },
  {
    "name": "wbgt_estimate",
    "type": "FLOAT64",
    "mode": "NULLABLE",
    "description": "WBGT推定値"
  },
  {
    "name": "forecast_at",
    "type": "TIMESTAMP",
    "mode": "NULLABLE",
    "description": "予報時刻"
  },
  {
    "name": "risk_level",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "リスクレベル（0: ほぼ安全, 1: 注意, 2: 警戒, 3: 厳重警戒, 4: 危険）"
  },
  {
    "name": "calculated_at",
    "type": "TIMESTAMP",
    "mode": "NULLABLE",
    "description": "計算日時"
  }
]
EOF

}