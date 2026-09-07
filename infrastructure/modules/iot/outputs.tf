output "iot_endpoint" {
  value = data.aws_iot_endpoint.data.endpoint_address
}
output "iot_policy_name" {
  value = aws_iot_policy.simulator.name
}

