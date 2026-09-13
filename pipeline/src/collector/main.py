import requests
from models import City
import json
from datetime import datetime, timezone
from google.cloud import pubsub_v1
import os
import uuid

URL = "https://api.open-meteo.com/v1/jma"

PROJECT_ID = os.environ["PROJECT_ID"]
TOPIC_ID = os.environ["PUBSUB_RAW_TOPIC_NAME"]


def publish_message(publisher: pubsub_v1.PublisherClient, topic_path: str, data: dict):

    data = json.dumps(data).encode("utf-8")

    publisher.publish(topic_path, data).result()


def collect_weather_data(publisher: pubsub_v1.PublisherClient, topic_path: str) -> None:

    sapporo = City(city_id="sapporo", city_name="札幌", latitude=43.0618, longitude=141.3545, timezone="Asia/Tokyo")
    sendai = City(city_id="sendai", city_name="仙台", latitude=38.2682, longitude=140.8694, timezone="Asia/Tokyo")
    tokyo = City(city_id="tokyo", city_name="東京", latitude=35.6762, longitude=139.6503, timezone="Asia/Tokyo")
    nagoya = City(city_id="nagoya", city_name="名古屋", latitude=35.1815, longitude=136.9066, timezone="Asia/Tokyo")
    osaka = City(city_id="osaka", city_name="大阪", latitude=34.6937, longitude=135.5023, timezone="Asia/Tokyo")
    kyoto = City(city_id="kyoto", city_name="京都", latitude=35.0116, longitude=135.7681, timezone="Asia/Tokyo")
    hiroshima = City(city_id="hiroshima", city_name="広島", latitude=34.3853, longitude=132.4553, timezone="Asia/Tokyo")
    fukuoka = City(city_id="fukuoka", city_name="福岡", latitude=33.5904, longitude=130.4017, timezone="Asia/Tokyo")
    nagasaki = City(city_id="nagasaki", city_name="長崎", latitude=32.7503, longitude=129.8777, timezone="Asia/Tokyo")
    naha = City(city_id="naha", city_name="那覇", latitude=26.2124, longitude=127.68097, timezone="Asia/Tokyo")

    for city in [sapporo, sendai, tokyo, nagoya, osaka, kyoto, hiroshima, fukuoka, nagasaki, naha]:
        params = {
            "latitude": city.latitude,
            "longitude": city.longitude,
            "hourly": ",".join([
                "temperature_2m",
                "relative_humidity_2m",
                "precipitation",
                "wind_speed_10m",
                "apparent_temperature",
                "dew_point_2m",
                "weather_code",
                "cloud_cover",
                "surface_pressure",
                "shortwave_radiation",
            ]),
            "timezone": city.timezone,
            "forecast_days": 3,
        }

        response = requests.get(URL, params=params, timeout=10)
        response.raise_for_status()

        hourly = response.json()["hourly"]
        forecasts = []
        for index, forecast_at in enumerate(hourly["time"]):
            forecasts.append(
                {
                    "event_id": str(uuid.uuid4()),
                    "forecast_at": forecast_at,
                    "temperature_c": hourly["temperature_2m"][index],
                    "relative_humidity_pct": hourly["relative_humidity_2m"][index],
                    "precipitation_mm": hourly["precipitation"][index],
                    "wind_speed_kmh": hourly["wind_speed_10m"][index],
                }
            )
        
        data = {
            "schema_version": 1,
            "event_type": "weather.forecast.collected",
            "collected_at": datetime.now(timezone.utc).isoformat(),
            "source": "open-meteo-jma",
            "city": {
                "city_id": city.city_id,
                "city_name": city.city_name,
                "latitude": city.latitude,
                "longitude": city.longitude,
                "timezone": city.timezone,
            },
            "forecasts": forecasts,
        }

        publish_message(publisher, topic_path, data)


def main():
    publisher = pubsub_v1.PublisherClient()
    topic_path = publisher.topic_path(PROJECT_ID, TOPIC_ID)
    collect_weather_data(publisher, topic_path)


if __name__ == "__main__":
    main()