locals {
  cors_settings = length(var.cors_allowed_domains) > 0 ? [1] : []
}

resource "aws_apigatewayv2_api" "main" {
  name                         = local.api_name_with_prefix
  protocol_type                = "HTTP"
  disable_execute_api_endpoint = true

  dynamic "cors_configuration" {
    for_each = local.cors_settings
    content {
      allow_origins     = var.cors_allowed_domains
      allow_credentials = true
    }
  }
}

resource "aws_apigatewayv2_authorizer" "authorizer" {
  for_each                          = var.authorizers
  api_id                            = aws_apigatewayv2_api.main.id
  authorizer_type                   = "REQUEST"
  identity_sources                  = each.value.authorizer_identity_sources
  name                              = "${local.api_name_with_prefix}-authorizer"
  authorizer_payload_format_version = each.value.authorizer_payload_format_version
  authorizer_uri                    = each.value.invoke_arn
  enable_simple_responses           = true
}
