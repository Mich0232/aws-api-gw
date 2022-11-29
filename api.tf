locals {
  cors_settings                = length(var.cors_allowed_domains) > 0 ? [1] : []
  disable_execute_api_endpoint = length(var.domains) > 0
}

resource "aws_apigatewayv2_api" "main" {
  name                         = local.api_name_with_prefix
  protocol_type                = "HTTP"
  disable_execute_api_endpoint = local.disable_execute_api_endpoint

  dynamic "cors_configuration" {
    for_each = local.cors_settings
    content {
      allow_origins     = var.cors_allowed_domains
      allow_credentials = true
    }
  }

  tags = local.default_tags
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

resource "aws_lambda_permission" "api_gw_authorizers" {
  for_each = var.authorizers

  function_name = each.value.function_name
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.main.execution_arn}/*/*"
}
