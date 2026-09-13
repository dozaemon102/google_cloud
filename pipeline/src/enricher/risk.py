import math

def estimate_wbgt(temperature_c: float, relative_humidity_pct: float) -> float:
    vapor_pressure_hpa = (
        6.105
        * math.exp(17.27 * temperature_c / (237.7 + temperature_c))
        * relative_humidity_pct
        / 100
    )
    return 0.567 * temperature_c + 0.393 * vapor_pressure_hpa + 3.94


def classify_risk(wbgt_estimate: float) -> str:
    if wbgt_estimate < 25:
        return "ほぼ安全"
    elif wbgt_estimate < 27:
        return "注意"
    elif wbgt_estimate < 29:
        return "警戒"
    elif wbgt_estimate < 31:
        return "厳重警戒"
    else:
        return "危険"