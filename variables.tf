variable "profile" {
  description = "AWS Profile used to create the resoources"
  default     = "globee"
}

variable "region" {
  description = "Region in which to create the resources"
  default     = "eu-west-1"
}

variable "team" {
  description = "Department or Owner of the resource"
  default     = "dev-inprogress" 
}

variable "environment" {
  description = "Respective environment the resource is targetting i.e. dev or prod"
  default     = "dev"
}

variable "service" {
  description = "Name of API"
  default     = "services-api-gateway-demo"
}

variable "api_definition" {
  description = "API definitions"
  default     = [
    {
      "path"                           : "health"
      "function_name"                  : "devops-api-poc-healthcheck"
      "method"                         : "GET"
      "integration_type"               : "AWS_PROXY"
      "integration_http_method"        : "POST"
      "uri"                            : "arn:aws:apigateway:eu-west-1:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-west-1:834366213304:function:devops-api-poc-healthcheck:$${stageVariables.lambdaAlias}/invocations"
      "integration_request_parameter"  : { "integration.request.header.X-Authorization" = "'static'" }
      "request_template"               : { "application/xml" = <<EOF
          {
            "body" : $input.json('$')
          }
          EOF
      }
      "status_code"                    : 200
      "response_model"                 : { "application/json" = "Empty" }
      "response_parameter"             : { "method.response.header.X-Some-Header" = true }
      "integration_response_parameter" : { "method.response.header.X-Some-Header" = "integration.response.header.X-Some-Other-Header" }
      "response_template"              : {
          "application/xml" = <<EOF
          #set($inputRoot = $input.path('$'))
          <?xml version="1.0" encoding="UTF-8"?>
          <message>
              $inputRoot.body
          </message>
          EOF
      }
    },
    {
      "path"                           : "env"
      "function_name"                  : "devops-api-poc-env"
      "method"                         : "GET"
      "integration_type"               : "AWS_PROXY"
      "integration_http_method"        : "POST"
      "uri"                            : "arn:aws:apigateway:eu-west-1:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-west-1:834366213304:function:devops-api-poc-env:$${stageVariables.lambdaAlias}/invocations"
      "integration_request_parameter"  : { "integration.request.header.X-Authorization" = "'static'" }
      "request_template"               : { "application/xml" = <<EOF
          {
            "body" : $input.json('$')
          }
        EOF
      }
      "status_code"                    : 200
      "response_model"                 : { "application/json" = "Empty" }
      "response_parameter"             : { "method.response.header.X-Some-Header" = true }
      "integration_response_parameter" : { "method.response.header.X-Some-Header" = "integration.response.header.X-Some-Other-Header" }
      "response_template"              : {
          "application/xml" = <<EOF
          #set($inputRoot = $input.path('$'))
          <?xml version="1.0" encoding="UTF-8"?>
          <message>
              $inputRoot.body
          </message>
          EOF
      }
    }
  ]
}

variable "stage_variables" {
  description = "API definitions"
  default     = [
    {
      "stage"       : "dev"
      "lambdaAlias" : "dev"
    },
    {
      "stage"       : "prod"
      "lambdaAlias" : "prod"
    }
  ]
}