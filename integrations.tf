resource "aws_apigatewayv2_integration" "main" {
  for_each = var.integrations
  api_id   = aws_apigatewayv2_api.main.id

  integration_uri        = each.value.invoke_arn
  integration_type       = "AWS_PROXY"
  integration_method     = each.value.method
  payload_format_version = each.value.payload_format_version

}

resource "aws_lambda_permission" "api_gw" {
  for_each = var.integrations

  function_name = each.value.function_name
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_apigatewayv2_api.main.execution_arn}/${each.value.stage}/*"
}

resource "aws_apigatewayv2_route" "routes" {
  for_each = var.routes

  api_id    = aws_apigatewayv2_api.main.id
  route_key = each.key
  target    = "integrations/${aws_apigatewayv2_integration.main[each.value.integration].id}"

  authorizer_id      = each.value.authorizer_id != null ? aws_apigatewayv2_authorizer.authorizer[each.value.authorizer_id].id : null
  authorization_type = each.value.authorizer_id != null ? "CUSTOM" : null
}
