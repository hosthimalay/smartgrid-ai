output "api_url" {
  value = aws_apigatewayv2_api.api.api_endpoint
}
output "lambda_name" {
  value = aws_lambda_function.api.function_name
}

