import argparse
import json
import random
import ssl
import time
from datetime import datetime, timezone

import paho.mqtt.client as mqtt


def reading(site_number, device_number):
    baseline = 25 + (site_number * 2)
    return {"site_id": f"DUBLIN-{site_number:03d}", "device_id": f"METER-{device_number:04d}", "timestamp": datetime.now(timezone.utc).isoformat().replace("+00:00", "Z"), "power_kw": round(max(0, random.gauss(baseline, 8)), 2), "voltage": round(random.gauss(230, 2), 2), "temperature": round(random.gauss(21, 3), 2), "battery_soc": round(random.uniform(25, 95), 1), "solar_generation_kw": round(max(0, random.gauss(8, 4)), 2)}


def main():
    parser = argparse.ArgumentParser(description="Publish simulated energy telemetry to AWS IoT Core")
    parser.add_argument("--endpoint", required=True); parser.add_argument("--certificate", required=True)
    parser.add_argument("--private-key", required=True); parser.add_argument("--root-ca", required=True)
    parser.add_argument("--sites", type=int, default=3); parser.add_argument("--devices-per-site", type=int, default=5)
    parser.add_argument("--interval", type=float, default=5)
    args = parser.parse_args()
    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2, client_id=f"smartgrid-simulator-{random.randint(1, 999999)}")
    client.tls_set(args.root_ca, certfile=args.certificate, keyfile=args.private_key, tls_version=ssl.PROTOCOL_TLS_CLIENT)
    client.connect(args.endpoint, 8883, 60); client.loop_start()
    try:
        while True:
            for site in range(1, args.sites + 1):
                for device in range(1, args.devices_per_site + 1):
                    payload = reading(site, device); topic = f"smartgrid/{payload['site_id']}/{payload['device_id']}/telemetry"
                    result = client.publish(topic, json.dumps(payload), qos=1); result.wait_for_publish()
                    print(f"published {topic}: {payload['power_kw']} kW")
            time.sleep(args.interval)
    except KeyboardInterrupt:
        print("Stopping simulator")
    finally:
        client.loop_stop(); client.disconnect()


if __name__ == "__main__":
    main()
