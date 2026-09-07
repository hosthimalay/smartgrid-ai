import json
import os
from decimal import Decimal

import boto3
from boto3.dynamodb.conditions import Key

table = boto3.resource("dynamodb").Table(os.environ["TABLE_NAME"])


class DecimalEncoder(json.JSONEncoder):
    def default(self, value):
        if isinstance(value, Decimal):
            return float(value)
        return super().default(value)


def response(status_code, body):
    return {"statusCode": status_code, "headers": {"content-type": "application/json"}, "body": json.dumps(body, cls=DecimalEncoder)}


def handler(event, _context):
    route_key = event.get("routeKey", "")
    if route_key == "GET /health":
        return response(200, {"status": "healthy"})
    if route_key == "GET /sites/{site_id}/devices":
        site_id = event.get("pathParameters", {}).get("site_id")
        if not site_id:
            return response(400, {"message": "site_id is required"})
        result = table.query(KeyConditionExpression=Key("site_id").eq(site_id))
        return response(200, {"site_id": site_id, "devices": result.get("Items", [])})
    if route_key == "GET /devices":
        result = table.scan(Limit=200)
        return response(200, {"devices": result.get("Items", [])})
    return response(404, {"message": "Route not found"})

