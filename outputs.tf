output "invoke_urls" {
  value = aws_apigatewayv2_stage.this[*].invoke_url
}
