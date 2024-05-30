output "lambda_function_arn" {
  description = "ARN of the Lambda function"
  value       = aws_lambda_function.api_lambda.arn
}

output "api_gateway_invoke_url" {
  value = "https://${aws_api_gateway_rest_api.myapi.id}.execute-api.${var.aws_region}.amazonaws.com/prod"
  description = "The URL used to invoke the API gateway."
}
