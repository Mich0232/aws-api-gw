resource "aws_cloudwatch_log_group" "this" {
  for_each = var.stages
  name     = "/aws/api-gw/${aws_apigatewayv2_api.main.name}/${each.key}"

  tags = local.default_tags
}

resource "aws_apigatewayv2_stage" "this" {
  for_each    = var.stages
  api_id      = aws_apigatewayv2_api.main.id
  name        = each.key
  auto_deploy = each.value.auto_deploy

  default_route_settings {
    detailed_metrics_enabled = true
    throttling_burst_limit   = 5000
    throttling_rate_limit    = 10000
  }

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.this[each.key].arn
    format          = local.default_log_format
  }

  tags = local.default_tags
}

resource "aws_apigatewayv2_api_mapping" "api_mapping" {
  for_each    = var.stages
  api_id      = aws_apigatewayv2_api.main.id
  domain_name = each.value.domain_id
  stage       = aws_apigatewayv2_stage.this[each.key].id

  api_mapping_key = each.value.domain_mapping

  tags = local.default_tags
}

