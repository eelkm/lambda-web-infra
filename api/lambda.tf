data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${var.api_path}"
  output_path = "lambda_function.zip"
}

resource "aws_lambda_function" "api_lambda" {
  function_name    = "${var.prefix}_lambda-function"
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  role = aws_iam_role.lambda_exec.arn

  tags = {
    Project = "${var.prefix}"
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "lambda_exec_role"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Principal = { Service = "lambda.amazonaws.com" }
      Effect    = "Allow"
      Sid       = ""
    }]
  })
}