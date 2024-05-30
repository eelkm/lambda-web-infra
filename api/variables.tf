variable "prefix" {
  description = "Prefix to add to resource names"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
}

variable "stage" {
  description = "Stage of the deployment"
  type        = string
}

variable "api_path" {
  description = "Path to the Express app"
  type        = string
}