data "archive_file" "telemetry" {
  type        = "zip"
  source_dir  = var.telemetry_source_dir
  output_path = "${var.build_directory}/telemetry.zip"
}

resource "aws_dynamodb_table" "latest" {
  name         = "${var.name_prefix}-latest-telemetry"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "site_id"
  range_key    = "device_id"
  attribute {
    name = "site_id"
    type = "S"
  }
  attribute {
    name = "device_id"
    type = "S"
  }
  point_in_time_recovery {
    enabled = true
  }
  server_side_encryption {
    enabled = true
  }
}
resource "aws_sns_topic" "alerts" {
  name = "${var.name_prefix}-energy-alerts"
}

resource "aws_iam_role" "telemetry" {
  name = "${var.name_prefix}-telemetry-lambda"
  assume_role_policy = jsonencode({
    Version = "2012-10-17", Statement = [{
      Effect = "Allow", Principal = {
        Service = "lambda.amazonaws.com"
      }, Action = "sts:AssumeRole"
    }]
  })
}
resource "aws_iam_role_policy" "telemetry" {
  role = aws_iam_role.telemetry.id
  policy = jsonencode({
    Version = "2012-10-17", Statement = [
      {
        Effect = "Allow", Action = ["logs:CreateLogStream", "logs:PutLogEvents"], Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow", Action = ["dynamodb:PutItem"], Resource = aws_dynamodb_table.latest.arn
      },
      {
        Effect = "Allow", Action = ["sns:Publish"], Resource = aws_sns_topic.alerts.arn
      }
    ]
  })
}
resource "aws_cloudwatch_log_group" "telemetry" {
  name              = "/aws/lambda/${var.name_prefix}-telemetry"
  retention_in_days = 7
}
resource "aws_lambda_function" "telemetry" {
  function_name    = "${var.name_prefix}-telemetry"
  role             = aws_iam_role.telemetry.arn
  runtime          = "python3.12"
  handler          = "handler.handler"
  filename         = data.archive_file.telemetry.output_path
  source_code_hash = data.archive_file.telemetry.output_base64sha256
  timeout          = 10
  memory_size      = 256
  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.latest.name, ALERT_TOPIC_ARN = aws_sns_topic.alerts.arn, ANOMALY_THRESHOLD_KW = tostring(var.anomaly_threshold_kw)
    }
  }
  depends_on = [aws_cloudwatch_log_group.telemetry]
}

resource "aws_iam_role" "firehose" {
  name = "${var.name_prefix}-firehose"
  assume_role_policy = jsonencode({
    Version = "2012-10-17", Statement = [{
      Effect = "Allow", Principal = {
        Service = "firehose.amazonaws.com"
      }, Action = "sts:AssumeRole"
    }]
  })
}
resource "aws_iam_role_policy" "firehose" {
  role = aws_iam_role.firehose.id
  policy = jsonencode({
    Version = "2012-10-17", Statement = [{
      Effect = "Allow", Action = ["s3:AbortMultipartUpload", "s3:GetBucketLocation", "s3:ListBucket", "s3:ListBucketMultipartUploads", "s3:PutObject"], Resource = [var.data_lake_bucket_arn, "${var.data_lake_bucket_arn}/*"]
    }]
  })
}
resource "aws_kinesis_firehose_delivery_stream" "telemetry" {
  name        = "${var.name_prefix}-telemetry"
  destination = "extended_s3"
  extended_s3_configuration {
    role_arn            = aws_iam_role.firehose.arn
    bucket_arn          = var.data_lake_bucket_arn
    prefix              = "raw/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/hour=!{timestamp:HH}/"
    error_output_prefix = "errors/!{firehose:error-output-type}/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
    buffering_interval  = 60
    buffering_size      = 5
    compression_format  = "GZIP"
  }
}

