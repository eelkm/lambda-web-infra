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
  aws_region = var.aws_region
  ui_path = var.ui_path
}
