from dataclasses import dataclass

@dataclass(frozen=True)
class City:
    city_id: str
    city_name: str
    latitude: float
    longitude: float
    timezone: str
