locals {
  invoke_urls = aws_apigatewayv2_stage.this[*]
}

output "data" {
  value = aws_apigatewayv2_stage.this[*]
}

output "invoke_urls" {
  value = local.invoke_urls
}
