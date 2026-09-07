variable "name_prefix" {
  type = string
}
variable "data_lake_bucket_arn" {
  type = string
}
variable "data_lake_bucket_name" {
  type = string
}
variable "telemetry_source_dir" {
  type = string
}
variable "build_directory" {
  type = string
}
variable "anomaly_threshold_kw" {
  type = number
}

