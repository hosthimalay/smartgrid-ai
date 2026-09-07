output "table_name" {
  value = aws_dynamodb_table.latest.name
}
output "table_arn" {
  value = aws_dynamodb_table.latest.arn
}
output "telemetry_lambda_arn" {
  value = aws_lambda_function.telemetry.arn
}
output "telemetry_lambda_name" {
  value = aws_lambda_function.telemetry.function_name
}
output "firehose_arn" {
  value = aws_kinesis_firehose_delivery_stream.telemetry.arn
}
output "firehose_name" {
  value = aws_kinesis_firehose_delivery_stream.telemetry.name
}
output "alert_topic_arn" {
  value = aws_sns_topic.alerts.arn
}
