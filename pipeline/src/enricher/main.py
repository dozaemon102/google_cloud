from fastapi import FastAPI, Request
import json
import base64
from google.cloud import bigquery
from google.cloud import firestore
from risk import estimate_wbgt, classify_risk
from datetime import datetime, timezone
from zoneinfo import ZoneInfo

app = FastAPI()


def format_data(event : dict, city_data: dict, forecasts_data: list[dict]) -> tuple[list[dict], list[dict]]:
    risk_rows = []
    weather_rows = []
    city_timezone = ZoneInfo(city_data["timezone"])

    for forecast in forecasts_data:

        wbgt_estimate = estimate_wbgt(forecast["temperature_c"], forecast["relative_humidity_pct"])
        risk_level = classify_risk(wbgt_estimate)

        risk_data = {
            "event_id": forecast["event_id"],
            "city_id": city_data["city_id"],
            "forecast_at": datetime.fromisoformat(forecast["forecast_at"]).replace(tzinfo=city_timezone).isoformat(),
            "wbgt_estimate": wbgt_estimate,
            "risk_level": risk_level,
            "calculated_at": datetime.now(timezone.utc).isoformat()
        }
        risk_rows.append(risk_data)

        weather_data = {
            "event_id": forecast["event_id"],
            "city_id": city_data["city_id"],
            "forecast_at": datetime.fromisoformat(forecast["forecast_at"]).replace(tzinfo=city_timezone).isoformat(),
            "temperature_c": forecast["temperature_c"],
            "relative_humidity_pct": forecast["relative_humidity_pct"],
            "precipitation_mm": forecast["precipitation_mm"],
            "wind_speed_kmh": forecast["wind_speed_kmh"],
            "source": event["source"],
            "collected_at": event["collected_at"]
        }
        weather_rows.append(weather_data)

    return risk_rows, weather_rows


def save_bigquery(client: bigquery.Client, risk_rows: list[dict], weather_rows: list[dict]) -> None:
    errors = client.insert_rows_json(
        "test-pro-507713.heat_risk_dev.risk_assessments",
        risk_rows
    )
    if errors:
        print(f"Error saving risk data: {errors}")
        raise Exception(f"Error saving risk data: {errors}")
    
    errors = client.insert_rows_json(
            "test-pro-507713.heat_risk_dev.weather_observations",
            weather_rows
        )
    if errors:
        print(f"Error saving data: {errors}")
        raise Exception(f"Error saving data: {errors}")


def save_firestore(client: firestore.Client, event: dict, city_data: dict, forecasts_data: list[dict]) -> None:    
    city_timezone = ZoneInfo(city_data["timezone"])
    collected_at = datetime.fromisoformat(event["collected_at"])

    future_forecasts = [
        forecast
        for forecast in forecasts_data
        if datetime.fromisoformat(forecast["forecast_at"]).replace(
            tzinfo=city_timezone
        ) >= collected_at
    ]

    if not future_forecasts:
        raise ValueError("現在以降の予報がありません")

    forecast = future_forecasts[0]
    
    wbgt_estimate = estimate_wbgt(forecast["temperature_c"], forecast["relative_humidity_pct"])
    risk_level = classify_risk(wbgt_estimate)

    client.collection("risk_statuses").document(city_data["city_id"]).set(
        {
            "city_id": city_data["city_id"],
            "forecast_at": datetime.fromisoformat(forecast["forecast_at"]).replace(tzinfo=city_timezone).isoformat(),
            "wbgt_estimate": wbgt_estimate,
            "risk_level": risk_level,
        }
    )


@app.post("/")
async def receive_pubsub_message(request: Request) -> dict:
    bq_client = bigquery.Client()
    fs_client = firestore.Client()
    envelope = await request.json()
    event = json.loads(base64.b64decode(envelope["message"]["data"]))
    city_data = event["city"]
    forecasts_data = event["forecasts"]

    risk_rows, weather_rows = format_data(event, city_data, forecasts_data)
    save_bigquery(bq_client, risk_rows, weather_rows)

    save_firestore(fs_client, event, city_data, forecasts_data)

    return {}
