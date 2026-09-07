output "api_url" {
  value = module.api.api_url
}
output "dashboard_url" {
  value = module.dashboard.dashboard_url
}
output "dashboard_bucket_name" {
  value = module.dashboard.bucket_name
}
output "cloudfront_distribution_id" {
  value = module.dashboard.distribution_id
}
output "iot_endpoint" {
  value = module.iot.iot_endpoint
}
output "iot_policy_name" {
  value = module.iot.iot_policy_name
}
output "data_lake_bucket" {
  value = module.data_lake.bucket_name
}
output "athena_workgroup" {
  value = module.data_lake.athena_workgroup
}
output "alert_topic_arn" {
  value = module.ingestion.alert_topic_arn
}

