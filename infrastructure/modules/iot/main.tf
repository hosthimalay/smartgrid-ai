data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_iot_endpoint" "data" {
  endpoint_type = "iot:Data-ATS"
}

resource "aws_iot_policy" "simulator" {
  name = "${var.name_prefix}-simulator"
  policy = jsonencode({
    Version = "2012-10-17", Statement = [
      {
        Effect = "Allow", Action = ["iot:Connect"], Resource = "arn:aws:iot:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:client/smartgrid-simulator-*"
      },
      {
        Effect = "Allow", Action = ["iot:Publish"], Resource = "arn:aws:iot:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:topic/smartgrid/*/*/telemetry"
      }
    ]
  })
}

resource "aws_iam_role" "iot_firehose" {
  name = "${var.name_prefix}-iot-firehose"
  assume_role_policy = jsonencode({
    Version = "2012-10-17", Statement = [{
      Effect = "Allow", Principal = {
        Service = "iot.amazonaws.com"
      }, Action = "sts:AssumeRole"
    }]
  })
}
resource "aws_iam_role_policy" "iot_firehose" {
  role = aws_iam_role.iot_firehose.id
  policy = jsonencode({
    Version = "2012-10-17", Statement = [{
      Effect = "Allow", Action = ["firehose:PutRecord"], Resource = var.firehose_arn
    }]
  })
}
resource "aws_lambda_permission" "iot" {
  statement_id  = "AllowIoTInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.telemetry_lambda_name
  principal     = "iot.amazonaws.com"
  source_arn    = "arn:aws:iot:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:rule/${replace(var.name_prefix, "-", "_")}_telemetry"
}
resource "aws_iot_topic_rule" "telemetry" {
  name        = "${replace(var.name_prefix, "-", "_")}_telemetry"
  enabled     = true
  sql         = "SELECT * FROM 'smartgrid/+/+/telemetry'"
  sql_version = "2016-03-23"
  lambda {
    function_arn = var.telemetry_lambda_arn
  }
  firehose {
    delivery_stream_name = split("/", var.firehose_arn)[1]
    role_arn             = aws_iam_role.iot_firehose.arn
    separator            = "\n"
  }
  error_action {
    cloudwatch_logs {
      log_group_name = aws_cloudwatch_log_group.iot_errors.name
      role_arn       = aws_iam_role.iot_logs.arn
    }
  }
  depends_on = [aws_lambda_permission.iot, aws_iam_role_policy.iot_firehose, aws_iam_role_policy.iot_logs]
}
resource "aws_cloudwatch_log_group" "iot_errors" {
  name              = "/aws/iot/${var.name_prefix}/errors"
  retention_in_days = 7
}
resource "aws_iam_role" "iot_logs" {
  name = "${var.name_prefix}-iot-logs"
  assume_role_policy = jsonencode({
    Version = "2012-10-17", Statement = [{
      Effect = "Allow", Principal = {
        Service = "iot.amazonaws.com"
      }, Action = "sts:AssumeRole"
    }]
  })
}
resource "aws_iam_role_policy" "iot_logs" {
  role = aws_iam_role.iot_logs.id
  policy = jsonencode({
    Version = "2012-10-17", Statement = [{
      Effect = "Allow", Action = ["logs:CreateLogStream", "logs:PutLogEvents"], Resource = "${aws_cloudwatch_log_group.iot_errors.arn}:*"
    }]
  })
}

