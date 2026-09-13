resource "google_bigquery_table" "bigquery_table_weather_observations" {
  dataset_id = google_bigquery_dataset.bigquery_dataset_heat_risk.dataset_id
  table_id   = "weather_observations"
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
    "name": "forecast_at",
    "type": "TIMESTAMP",
    "mode": "NULLABLE",
    "description": "予報時刻"
  },
  {
    "name": "temperature_c",
    "type": "FLOAT64",
    "mode": "NULLABLE",
    "description": "気温（℃）"
  },
  {
    "name": "relative_humidity_pct",
    "type": "FLOAT64",
    "mode": "NULLABLE",
    "description": "相対湿度（%）"
  },
  {
    "name": "precipitation_mm",
    "type": "FLOAT64",
    "mode": "NULLABLE",
    "description": "降水量（mm）"
  },
  {
    "name": "wind_speed_kmh",
    "type": "FLOAT64",
    "mode": "NULLABLE",
    "description": "風速（km/h）"
  },
  {
    "name": "source",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "ソース"
  },
  {
    "name": "collected_at",
    "type": "TIMESTAMP",
    "mode": "NULLABLE",
    "description": "収集日時"
  }
]
EOF

}