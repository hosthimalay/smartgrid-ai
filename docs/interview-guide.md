# Interview guide

## Explain the system in 30 seconds

SmartGrid AI receives certificate-authenticated MQTT telemetry through AWS IoT Core. An IoT rule fans each reading into a hot path and a historical path. Lambda validates the event and updates a bounded DynamoDB latest-state table for the dashboard. Firehose buffers and compresses the complete stream into an hourly partitioned S3 data lake queried through Athena. Terraform provisions the platform using modules and least-privilege service roles.

## Questions and answers

**Why not store all readings in DynamoDB?**

The API needs current state, while historical analytics scans large time ranges. Separating them prevents operational storage from growing indefinitely and makes analytical storage cheaper.

**How does Terraform know creation order?**

Outputs such as the S3 bucket ARN are passed into dependent modules. Resource references form a dependency graph, so explicit `depends_on` is used only when a dependency cannot be inferred.

**Why is the dashboard not inside Terraform?**

Terraform creates the hosting infrastructure. npm compiles application source, and the deployment script uploads the immutable build. Infrastructure state and application build concerns have different lifecycles.

**What happens when Lambda fails?**

The IoT rule has an error action writing diagnostic events to CloudWatch Logs, and Lambda error alarms expose failures. A production extension could route failed events to SQS for controlled replay.

**Where is the star schema?**

The MVP creates raw telemetry and analytical SQL first. A curated Parquet layer can derive a `fact_energy_usage` table with site, device and time dimensions. This is deliberately a next increment rather than an unused warehouse model.

**What breaks at much higher scale?**

Review device connection quotas, message rate, Lambda concurrency, DynamoDB partition distribution, Firehose buffering and API scan access. Replace the demo-wide `/devices` scan with indexed site queries. Introduce a stream only when independent consumers or replay justify it.

**What is drift?**

Drift is a difference between Terraform configuration/state and remote resources, often caused by console changes. `terraform plan` reveals it; the team either updates configuration or lets Terraform restore the declared state.

