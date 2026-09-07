import importlib.util
import os
import sys
from decimal import Decimal
from pathlib import Path
from unittest.mock import MagicMock

os.environ.setdefault("TABLE_NAME", "test-table")
sys.modules.setdefault("boto3", MagicMock())
module_path = Path(__file__).parents[1] / "lambdas" / "telemetry" / "handler.py"
spec = importlib.util.spec_from_file_location("telemetry_handler", module_path)
telemetry = importlib.util.module_from_spec(spec)
spec.loader.exec_module(telemetry)


def test_normalise_reading_marks_high_demand():
    reading = telemetry.normalise_reading({"site_id": "DUBLIN-001", "device_id": "METER-001", "timestamp": "2026-09-05T12:00:00Z", "power_kw": 91.2})
    assert reading["power_kw"] == Decimal("91.2")
    assert reading["status"] == "HIGH"


def test_normalise_reading_rejects_missing_fields():
    try:
        telemetry.normalise_reading({"site_id": "DUBLIN-001"})
        assert False, "Expected ValueError"
    except ValueError as error:
        assert "device_id" in str(error)

