resource "aws_acm_certificate" "api_cert" {
  domain_name = "api.${var.domain_name}"
  validation_method = "DNS"

  tags = {
    Project = "${var.prefix}"
  }
}

resource "aws_route53_record" "api_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.api_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      type   = dvo.resource_record_type
      value  = dvo.resource_record_value
    }
  }

  zone_id = "${var.zone_id}"
  name    = each.value.name
  type    = each.value.type
  records = [each.value.value]
  ttl     = 60
}

# Custom domain name for the API Gateway

resource "aws_api_gateway_domain_name" "api_domain" {
  domain_name              = "api.${var.domain_name}"
  regional_certificate_arn = aws_acm_certificate.api_cert.arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Project = "${var.prefix}"
  }

  depends_on = [aws_route53_record.api_cert_validation]
}

resource "aws_api_gateway_base_path_mapping" "api_mapping" {
  domain_name = aws_api_gateway_domain_name.api_domain.domain_name
  api_id      = aws_api_gateway_rest_api.myapi.id
  stage_name  = var.stage
}

resource "aws_route53_record" "api_domain" {
  zone_id = var.zone_id
  name    = "api.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.api_domain.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.api_domain.regional_zone_id
    evaluate_target_health = false
  }
}