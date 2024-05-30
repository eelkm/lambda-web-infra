resource "aws_lambda_permission" "allow_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.myapi.execution_arn}/*/*/*"
}

resource "aws_iam_role_policy" "lambda_access" {
  name   = "lambda_access_policy"
  role   = aws_iam_role.lambda_exec.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow",
        Action    = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:DeleteItem"
        ],
        Resource  = "${aws_dynamodb_table.basic_table.arn}"
      },
      {
        Effect    = "Allow",
        Action    = [
          "s3:GetObject",
          "s3:PutObject"
        ],
        Resource  = "${aws_s3_bucket.public_read_bucket.arn}/*"
      },
      {
        Effect    = "Allow",
        Action    = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource  = "arn:aws:logs:*:*:*"
      }
    ]
  })
}
