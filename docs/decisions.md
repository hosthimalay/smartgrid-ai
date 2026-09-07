# Architecture decisions

## ADR-001: Terraform for infrastructure

Terraform makes changes reviewable, repeatable and independent of console clicks. AWS CDK was considered, but Terraform better demonstrates declarative IaC skills across cloud-engineering roles.

## ADR-002: DynamoDB stores only latest state

The dashboard requires fast reads by site and device. Each new reading overwrites the same key, bounding operational storage. Full history belongs in S3. Timestream is a reasonable future alternative if time-series queries become an operational requirement.

## ADR-003: Direct Firehose delivery

IoT Core sends records directly to Firehose. Kinesis Data Streams is omitted because the MVP has no replay or multiple real-time consumer requirement. Firehose buffers and compresses records before S3 delivery.

## ADR-004: No Docker in the MVP

The simulator is a local Python process, Lambda uses ZIP packages, and React compiles to static assets. Containers would add packaging complexity without solving a present deployment problem.

## ADR-005: Simulator certificates outside Terraform

Generating a private device key through Terraform can persist it in state. A post-deployment provisioning script creates the key locally, attaches the Terraform-managed least-privilege policy and keeps the certificate directory out of Git.

## ADR-006: Raw JSON first, Parquet next

Firehose writes compressed newline-delimited JSON for the first release. This makes ingestion easy to inspect. A later curated transformation can produce partitioned Parquet; the trade-off is higher Athena scan cost until that enhancement exists.

