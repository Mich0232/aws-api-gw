variable "project_name" {
  type = string
}

variable "api_name" {
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

variable "stages" {
  type = map(object({
    domain_id      = string
    domain_mapping = string
    auto_deploy    = bool
  }))
}

variable "authorizers" {
  type = map(object({
    invoke_arn                        = string
    authorizer_payload_format_version = string
    authorizer_identity_sources       = list(string)
  }))
  default = {}
}

variable "integrations" {
  type = map(object({
    invoke_arn             = string
    function_name          = string
    authorizer_id          = string
    payload_format_version = string
  }))
}

locals {
  api_name_with_prefix = "${var.project_name}-${var.api_name}"
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
