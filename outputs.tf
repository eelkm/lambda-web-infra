
output "api_gateway_invoke_url" {
  value = module.api.api_gateway_invoke_url
  description = "The URL used to invoke the API gateway."
}

output "cloudfront_url" {
  description = "The URL of the CloudFront distribution"
  value       = module.frontend.cloudfront_url
}
