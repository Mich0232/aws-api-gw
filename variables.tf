variable "project_name" {
  type = string
}

variable "api-name" {
  type = string
}

variable "domains" {
  type    = map(string)
  default = {}
}

variable "cors_allowed_domains" {
  type    = list(string)
  default = []
}

variable "authorizer_identity_source" {
  type    = list(string)
  default = ["$request.header.cookie"]
}

variable "authorizer_invoke_arn" {
  type        = string
  description = "Invoke ARN of authorizer lambda function"
}

variable "stages" {
  type = map(object({
    domain_id      = string
    domain_mapping = string
    auto_deploy    = bool
  }))
}

variable "integrations" {
  type = map(object({}))
}


locals {
  api_name_with_prefix = "${var.project_name}-${var.api-name}"
  default_log_format = jsonencode({
    requestId               = "$context.requestId"
    sourceIp                = "$context.identity.sourceIp"
    requestTime             = "$context.requestTime"
    protocol                = "$context.protocol"
    httpMethod              = "$context.httpMethod"
    resourcePath            = "$context.resourcePath"
    routeKey                = "$context.routeKey"
    status                  = "$context.status"
    responseLength          = "$context.responseLength"
    integrationErrorMessage = "$context.integrationErrorMessage"
    }
  )
}
