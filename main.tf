provider "aws" {
  region = var.aws_region
}

module "api" {
  source = "./api"
  prefix = var.prefix
  aws_region = var.aws_region
  stage = var.stage
  api_path = var.api_path
}

module "frontend" {
  source = "./frontend"
  prefix = var.prefix
  domain_name = var.domain_name
  aws_region = var.aws_region
  ui_path = var.ui_path
  certificate_arn = var.certificate_arn
  zone_id = var.zone_id
}
