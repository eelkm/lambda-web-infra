resource "aws_api_gateway_rest_api" "myapi" {
  name        = "${var.prefix}_api"
  description = "API Gateway for Lambda Function"

  tags = {
    Project = "${var.prefix}"
  }
}

resource "aws_api_gateway_resource" "api_proxy_resource" {
  rest_api_id = aws_api_gateway_rest_api.myapi.id
  parent_id   = aws_api_gateway_rest_api.myapi.root_resource_id
  path_part   = "{proxy+}"  # Proxy resource to handle any path
}

resource "aws_api_gateway_method" "api_proxy_method" {
  rest_api_id   = aws_api_gateway_rest_api.myapi.id
  resource_id   = aws_api_gateway_resource.api_proxy_resource.id
  http_method   = "ANY"  # Any HTTP method
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "api_lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.myapi.id
  resource_id = aws_api_gateway_resource.api_proxy_resource.id
  http_method = aws_api_gateway_method.api_proxy_method.http_method

  integration_http_method = "POST"  # Lambda receives POST from API Gateway
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api_lambda.invoke_arn
}

resource "null_resource" "always_deploy" {
  triggers = {
    always_trigger = "${timestamp()}"
  }
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.myapi.id
  stage_name  = "${var.stage}"

  depends_on = [
    aws_api_gateway_integration.api_lambda_integration,
    aws_api_gateway_method.api_proxy_method,
    null_resource.always_deploy
  ]

  # Triggers a new deployment using a unique identifier each time
  triggers = {
    redeployment = "${null_resource.always_deploy.triggers.always_trigger}"
  }

  lifecycle {
    create_before_destroy = true
  }
}