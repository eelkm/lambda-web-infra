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

resource "aws_api_gateway_method" "cors_options_method" {
  rest_api_id   = aws_api_gateway_rest_api.myapi.id
  resource_id   = aws_api_gateway_resource.api_proxy_resource.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cors_options_integration" {
  rest_api_id = aws_api_gateway_rest_api.myapi.id
  resource_id = aws_api_gateway_resource.api_proxy_resource.id
  http_method = aws_api_gateway_method.cors_options_method.http_method

  type             = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_integration_response" "cors_options_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.myapi.id
  resource_id = aws_api_gateway_resource.api_proxy_resource.id
  http_method = aws_api_gateway_method.cors_options_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token,X-Amz-User-Agent'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,DELETE,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [aws_api_gateway_integration.cors_options_integration]
}

resource "aws_api_gateway_method_response" "cors_options_method_response" {
  rest_api_id = aws_api_gateway_rest_api.myapi.id
  resource_id = aws_api_gateway_resource.api_proxy_resource.id
  http_method = aws_api_gateway_method.cors_options_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }

  depends_on = [aws_api_gateway_method.cors_options_method]
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
    aws_api_gateway_method.cors_options_method,       
    aws_api_gateway_integration.cors_options_integration, 
    aws_api_gateway_integration_response.cors_options_integration_response,
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