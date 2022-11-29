resource "aws_apigatewayv2_domain_name" "api_domain" {
  for_each    = var.domains
  domain_name = each.key

  domain_name_configuration {
    certificate_arn = each.value.certificate_arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }

  tags = local.default_tags
}

resource "aws_apigatewayv2_api_mapping" "api_mapping" {
  for_each        = var.domains
  api_id          = aws_apigatewayv2_api.main.id
  domain_name     = each.key
  stage           = aws_apigatewayv2_stage.this[each.value.stage].id
  api_mapping_key = each.value.domain_mapping
}
