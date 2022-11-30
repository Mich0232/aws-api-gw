locals {
  data = flatten([for url in aws_apigatewayv2_stage.this[*] : values(url)])
}

output "invoke_urls" {
  value = { for v in local.data : v.id => v.invoke_url }
}
