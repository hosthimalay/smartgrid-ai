# SmartGrid AI

SmartGrid AI is a production-style AWS IoT energy telemetry platform. It demonstrates cloud, IoT and data-engineering decisions through a small system that can actually be deployed and explained.

```text
Python simulator -> AWS IoT Core -> IoT Rule
                                      |-> Lambda -> DynamoDB -> HTTP API -> React dashboard
                                      |-> Firehose -> S3 raw zone -> Athena
```

The first release intentionally avoids Docker, SageMaker, Redshift, NAT Gateway and always-on compute. Those services are scaling options, not MVP requirements.
<img width="2823" height="1482" alt="{B5581B00-AFED-49D8-9DF0-AECE91970C9A}" src="https://github.com/user-attachments/assets/c67693e3-cc1f-49c5-a72a-0a16708aa0f4" />

## What it demonstrates

- Secure MQTT telemetry ingestion with AWS IoT Core
- Separate hot and historical data paths
- Latest device state in DynamoDB
- Durable raw telemetry in a partitioned S3 data lake
- Athena metadata and query workgroup
- Serverless HTTP API and CloudFront-hosted React dashboard
- Threshold anomaly alerts with SNS
- CloudWatch monitoring and a cost-conscious design
- Reproducible AWS infrastructure with Terraform modules

## Repository

```text
dashboard/                  React/Vite dashboard
infrastructure/
  bootstrap/                Optional remote-state bootstrap
  environments/dev/         Root Terraform module
  modules/                  Reusable infrastructure modules
lambdas/                    Python telemetry and API functions
simulator/                  Python MQTT device simulator
scripts/                    Deployment and certificate helpers
tests/                      Python unit tests
docs/                       Architecture and interview notes
```

## Prerequisites

- Terraform 1.14+
- AWS CLI v2 authenticated to the intended account
- Python 3.11+
- Node.js 20+

Default settings are `eu-west-1`, AWS profile `default`, and a USD 10 monthly budget alert. AWS Budgets uses USD here; the value is an alert threshold, not a hard spending cap.

## Validate locally

```powershell
py -m pytest tests
npm --prefix dashboard install
npm --prefix dashboard run build
terraform -chdir=infrastructure/environments/dev init -backend=false
terraform -chdir=infrastructure/environments/dev validate
```

## Plan before deploying

```powershell
Copy-Item infrastructure/environments/dev/terraform.tfvars.example infrastructure/environments/dev/terraform.tfvars
terraform -chdir=infrastructure/environments/dev init -backend=false
terraform -chdir=infrastructure/environments/dev plan -out=smartgrid.tfplan
terraform -chdir=infrastructure/environments/dev show smartgrid.tfplan
```

No command in this repository applies infrastructure automatically. Review the plan before running `terraform apply`.

## Documentation

- [Deployment](docs/deployment.md)
- [Architecture](docs/architecture.md)
- [Terraform design](docs/terraform-design.md)
- [Architecture decisions](docs/decisions.md)
- [Security and cost](docs/security-and-cost.md)
- [Interview guide](docs/interview-guide.md)
