data "aws_caller_identity" "current" {}

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Project = var.project_name, Environment = var.environment, ManagedBy = "Terraform"
  }
}

module "data_lake" {
  source        = "../../modules/data_lake"
  name_prefix   = local.name_prefix
  account_id    = data.aws_caller_identity.current.account_id
  aws_region    = var.aws_region
  force_destroy = var.environment == "dev"
}

module "ingestion" {
  source                = "../../modules/ingestion"
  name_prefix           = local.name_prefix
  data_lake_bucket_arn  = module.data_lake.bucket_arn
  data_lake_bucket_name = module.data_lake.bucket_name
  telemetry_source_dir  = "${path.root}/../../../lambdas/telemetry"
  build_directory       = "${path.root}/build"
  anomaly_threshold_kw  = var.anomaly_threshold_kw
}

module "iot" {
  source                = "../../modules/iot"
  name_prefix           = local.name_prefix
  telemetry_lambda_arn  = module.ingestion.telemetry_lambda_arn
  telemetry_lambda_name = module.ingestion.telemetry_lambda_name
  firehose_arn          = module.ingestion.firehose_arn
}

module "api" {
  source          = "../../modules/api"
  name_prefix     = local.name_prefix
  table_name      = module.ingestion.table_name
  table_arn       = module.ingestion.table_arn
  api_source_dir  = "${path.root}/../../../lambdas/api"
  build_directory = "${path.root}/build"
}

module "dashboard" {
  source        = "../../modules/dashboard"
  name_prefix   = local.name_prefix
  account_id    = data.aws_caller_identity.current.account_id
  aws_region    = var.aws_region
  force_destroy = var.environment == "dev"
}

module "monitoring" {
  source                = "../../modules/monitoring"
  name_prefix           = local.name_prefix
  telemetry_lambda_name = module.ingestion.telemetry_lambda_name
  api_lambda_name       = module.api.lambda_name
  firehose_name         = module.ingestion.firehose_name
  notification_email    = var.budget_notification_email
  monthly_budget_usd    = var.monthly_budget_usd
}

