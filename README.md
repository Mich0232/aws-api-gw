## AWS HTTP API Gateway module

This module creates an HTTP API using AWS API Gateway.  

Stages are throttled using default limits:

```terraform
default_route_settings {
    throttling_burst_limit   = 5000
    throttling_rate_limit    = 10000
}
```


### Routes 

You can specify API routes using configuration. Each integration is of type AWS Lambda Proxy.

```terraform
module "api" {
  source       = "git@github.com:Mich0232/aws-api-gw.git"
  project_name = local.project_name
  api_name     = "my-api"
  stages = {
    "v1" : {
      auto_deploy = true
    }
  }
  integrations = {
    "GET /Info" : {
      stage                  = "v1"
      authorizer_id          = ""
      payload_format_version = "2.0"
      invoke_arn             = module.lambda.invoke_arn
      function_name          = module.lambda.function_name
    }
  }
}
```

### Authorizers

Module support adding custom authorizers.  
Created authorizers can be later references in the integrations section.

```terraform
module "api" {
  ...
  authorizers = {
    "my_authorizer" : {
      invoke_arn                        = module.authorizer.invoke_arn
      function_name                     = module.authorizer.function_name
      authorizer_payload_format_version = "2.0"
      authorizer_identity_sources       = ["$request.header.cookie"]
      stage                             = "v1"
    }
  }
  integrations = {
    "GET /Info" : {
      stage                  = "v1"
      authorizer_id          = "my_authorizer"
      payload_format_version = "2.0"
      invoke_arn             = module.lambda.invoke_arn
      function_name          = module.lambda.function_name
    }
  }
  ...
}
```

### Domains

When adding custom domains you need to include the certificate ARN.  
Endpoint type will be set to `REGIONAL` and security policy to `TLS_1_2`

```terraform
module "api" {
  source       = "git@github.com:Mich0232/aws-api-gw.git"
  project_name = local.project_name
  api_name     = "my-api"
  ...
  domains = {
    "https://my-custom-website.com" : {
      certificate_arn = aws_acm_certificate_validation.api.certificate_arn
      domain_mapping  = "v1"
      stage           = "v1"
    }
  }
}
```


## Provisioned Resources

 - AWS HTTP API Gateway 
 - GW Stage
 - GW Integrations
 - GW Authorizers
 - GW Routes
 - GW Custom domains
 - GW Domain mappings
 - IAM Roles & Permissions


## Input variables

`project_name` - Project name. Used as a prefix in resources

`api_name` - AWS API GW name.

`domains` - custom domains configuration

```terraform
{
  type = map(object({
    certificate_arn = string
    domain_mapping  = string
    stage           = string
  }))
  default = {}
}
```

`cors_allowed_domains` - List of allowed domain for CORS interactions

`stages` - AWS GW Stages configuration
```terraform
{
  type = map(object({
    auto_deploy = bool
  }))
}
```

`authorizers` - AWS GW Lambda authorizers configuration
```terraform
{
  type = map(object({
    invoke_arn                        = string
    function_name                     = string
    authorizer_payload_format_version = string
    authorizer_identity_sources       = list(string)
    stage                             = string
  }))
  default = {}
}
```

`integrations` - AWS GW Routes & Integrations configuration
```terraform
{
  type = map(object({
    invoke_arn             = string
    function_name          = string
    authorizer_id          = string
    payload_format_version = string
    stage                  = string
  }))
}
```

## Output

`invoke_urls` - list of invoke urls per API Stage
