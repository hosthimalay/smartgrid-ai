# Architecture

## Runtime flow

```text
Simulator --MQTT/TLS--> AWS IoT Core
                           |
                           +-- IoT rule --> telemetry Lambda --> DynamoDB latest-state table
                           |                    |
                           |                    +--> SNS when power exceeds threshold
                           |
                           +-- IoT rule --> Firehose --> S3 raw/year/month/day/hour

React dashboard --> CloudFront --> private S3
        |
        +--> API Gateway --> API Lambda --> DynamoDB

Athena --> Glue Data Catalog --> S3 raw telemetry
```

## Why two paths?

The hot path overwrites the latest reading for each site/device pair. Its storage stays bounded and API queries are fast. The historical path retains every event in inexpensive object storage for analytical scans. Using the operational table for history would mix incompatible access patterns and allow unbounded growth.

## Scale

The demo starts with 15 devices. At 2,000 devices publishing every 30 seconds, the platform receives about 66.7 events per second and 5.76 million events per day. Managed ingestion and on-demand DynamoDB remove server management, while Firehose buffers small records into larger S3 objects.

Kinesis Data Streams becomes appropriate when multiple independent consumers, ordered shards, replay or sub-minute stream processing are explicit requirements. It is intentionally not in the MVP.

