output "bucket_name" {
  value = aws_s3_bucket.lake.id
}
output "bucket_arn" {
  value = aws_s3_bucket.lake.arn
}
output "athena_workgroup" {
  value = aws_athena_workgroup.energy.name
}
output "glue_database" {
  value = aws_glue_catalog_database.energy.name
}

