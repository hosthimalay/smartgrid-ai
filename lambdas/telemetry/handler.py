import json
import os
from decimal import Decimal

import boto3

dynamodb = boto3.resource("dynamodb")
sns = boto3.client("sns")
table = dynamodb.Table(os.environ["TABLE_NAME"])
anomaly_threshold_kw = Decimal(os.environ.get("ANOMALY_THRESHOLD_KW", "80"))


def _decimal(value):
    return Decimal(str(value))


def normalise_reading(event):
    required = {"site_id", "device_id", "timestamp", "power_kw"}
    missing = required.difference(event)
    if missing:
        raise ValueError(f"Missing telemetry fields: {', '.join(sorted(missing))}")
    reading = {
        "site_id": str(event["site_id"]), "device_id": str(event["device_id"]), "timestamp": str(event["timestamp"]),
        "power_kw": _decimal(event["power_kw"]), "voltage": _decimal(event.get("voltage", 0)),
        "temperature": _decimal(event.get("temperature", 0)), "battery_soc": _decimal(event.get("battery_soc", 0)),
        "solar_generation_kw": _decimal(event.get("solar_generation_kw", 0)),
    }
    reading["status"] = "HIGH" if reading["power_kw"] >= anomaly_threshold_kw else "NORMAL"
    return reading


def handler(event, _context):
    reading = normalise_reading(event)
    table.put_item(Item=reading)
    if reading["status"] == "HIGH" and os.environ.get("ALERT_TOPIC_ARN"):
        sns.publish(TopicArn=os.environ["ALERT_TOPIC_ARN"], Subject="SmartGrid high energy demand", Message=json.dumps({"site_id": reading["site_id"], "device_id": reading["device_id"], "power_kw": float(reading["power_kw"]), "timestamp": reading["timestamp"]}))
    return {"stored": True, "status": reading["status"]}

