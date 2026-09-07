# Security and cost

## Security controls

- MQTT uses TLS client certificates.
- The simulator policy permits only connect and publish to the project topic hierarchy.
- Each Lambda and delivery service has a dedicated IAM role.
- Data-lake and dashboard buckets block public access and encrypt objects.
- CloudFront accesses the dashboard bucket through origin access control.
- DynamoDB point-in-time recovery is enabled.
- Log retention is seven days in the development environment.
- Private keys, state, variable files and build outputs are excluded from Git.

The public read API is acceptable for synthetic portfolio data, but production would add Cognito/JWT authorization and restrict CORS to the dashboard origin.

## Cost posture

The architecture has no NAT Gateway, EC2 instance, Redshift cluster, SageMaker endpoint or other deliberately always-on compute. Most charges scale with requests, records, stored bytes and CloudFront transfer.

The optional AWS Budget is account-wide because untagged resources can still create unexpected cost. Set `budget_notification_email` in the uncommitted `terraform.tfvars` to enable it. A budget alerts; it does not shut resources down.

Stop the simulator when it is not being demonstrated. Destroy the development stack when extended availability is unnecessary, after preserving any portfolio screenshots or desired data.

