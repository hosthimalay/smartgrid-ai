resource "aws_cloudwatch_metric_alarm" "telemetry_errors" {
  alarm_name          = "${var.name_prefix}-telemetry-errors"
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  dimensions = {
    FunctionName = var.telemetry_lambda_name
  }
}
resource "aws_cloudwatch_metric_alarm" "api_errors" {
  alarm_name          = "${var.name_prefix}-api-errors"
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"
  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"
  dimensions = {
    FunctionName = var.api_lambda_name
  }
}
resource "aws_cloudwatch_metric_alarm" "firehose_freshness" {
  alarm_name          = "${var.name_prefix}-firehose-freshness"
  namespace           = "AWS/Firehose"
  metric_name         = "DeliveryToS3.DataFreshness"
  statistic           = "Maximum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 900
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"
  dimensions = {
    DeliveryStreamName = var.firehose_name
  }
}
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = var.name_prefix
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric", x = 0, y = 0, width = 12, height = 6, properties = {
          title = "Lambda invocations and errors", region = data.aws_region.current.region, metrics = [["AWS/Lambda", "Invocations", "FunctionName", var.telemetry_lambda_name], [".", "Errors", ".", "."], ["AWS/Lambda", "Invocations", "FunctionName", var.api_lambda_name], [".", "Errors", ".", "."]]
        }
      },
      {
        type = "metric", x = 12, y = 0, width = 12, height = 6, properties = {
          title = "Firehose delivery", region = data.aws_region.current.region, metrics = [["AWS/Firehose", "DeliveryToS3.Records", "DeliveryStreamName", var.firehose_name], [".", "DeliveryToS3.DataFreshness", ".", "."]]
        }
      }
    ]
  })
}
data "aws_region" "current" {}
resource "aws_budgets_budget" "monthly" {
  count        = var.notification_email == "" ? 0 : 1
  name         = "${var.name_prefix}-monthly"
  budget_type  = "COST"
  limit_amount = tostring(var.monthly_budget_usd)
  limit_unit   = "USD"
  time_unit    = "MONTHLY"
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.notification_email]
  }
  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.notification_email]
  }
}
