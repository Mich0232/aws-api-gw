variable "project_name" {
  type = string
}

variable "api_name" {
  type = string
}

variable "domains" {
  type = map(object({
    certificate_arn = string
    domain_id       = string
    domain_mapping  = string
    stage           = string
  }))
  default = {}
}

variable "cors_allowed_domains" {
  type    = list(string)
  default = []
}

variable "stages" {
  type = map(object({
    auto_deploy = bool
  }))
}

variable "authorizers" {
  type = map(object({
    invoke_arn                        = string
    function_name                     = string
    authorizer_payload_format_version = string
    authorizer_identity_sources       = list(string)
    stage                             = string
  }))
  default = {}
}

variable "integrations" {
  type = map(object({
    invoke_arn             = string
    function_name          = string
    authorizer_id          = string
    payload_format_version = string
    stage                  = string
  }))
}

variable "tags" {
  type    = map(string)
  default = {}

  validation {
    condition     = length(keys(var.tags)) <= 8
    error_message = "You can assign up to 8 tags to the S3 Object."
  }
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

  default_tags = merge({
    Project = var.project_name,
    Name    = var.api_name
  }, var.tags)
}
