variable "prefix" {
  description = "Prefix to add to resource names"
  type        = string
}

variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
}

variable "ui_path" {
  description = "Path to the React app"
  type        = string
}