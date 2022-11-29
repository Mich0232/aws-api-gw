resource "aws_apigatewayv2_domain_name" "api_domain" {
  for_each    = var.domains
  domain_name = each.key

  domain_name_configuration {
    certificate_arn = each.value
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }
}

