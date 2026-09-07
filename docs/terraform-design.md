# Terraform design

## Composition

`infrastructure/environments/dev` is the root module. It owns provider configuration and composes six child modules. Module outputs become inputs elsewhere; these references form Terraform's dependency graph.

| Module | Responsibility | Important outputs |
|---|---|---|
| `data_lake` | S3, Glue catalog and Athena | bucket ARN, workgroup |
| `ingestion` | Lambda, DynamoDB, SNS and Firehose | function, table and stream ARNs |
| `iot` | Topic rule, simulator policy and routing permissions | endpoint and policy name |
| `api` | HTTP API and read Lambda | API URL |
| `dashboard` | Private S3 origin and CloudFront | URL, bucket and distribution ID |
| `monitoring` | Alarms, dashboard and optional budget | operational controls |

The boundaries match architectural responsibilities rather than placing every AWS resource in its own module. One resource per module would create abstraction without reuse.

## State

Local state is acceptable for the first reviewed plan. CI/CD should use the separately bootstrapped, encrypted, versioned S3 backend with locking. State is excluded from Git because it can include infrastructure identifiers and sensitive values.

The backend cannot safely create itself using the state it is supposed to store, so `bootstrap` is a separate root configuration.

## Application artifacts

The `archive` provider packages small Python Lambda source directories and hashes the output. A hash change causes a function update. The dashboard is built by npm and uploaded after Terraform provisions its S3 and CloudFront targets. Terraform manages infrastructure lifecycle; the deployment script manages application compilation.

## Environments

Only `dev` is instantiated to control cost. Child modules accept environment-aware names, so staging or production can be added with a separate root configuration and isolated state. Claiming multi-environment capability does not require paying for three live copies.

## Useful commands

```text
terraform fmt -recursive
terraform init -backend=false
terraform validate
terraform plan
terraform show smartgrid.tfplan
terraform state list
terraform output
```

