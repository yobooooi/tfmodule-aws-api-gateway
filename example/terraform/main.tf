module "api-gateway-module-demo" {
  source = "../"

  service = "api-gateway-module-demo"
  team = "devops"
  environment = "dev"

  stage_variables = [
    {
      "stage"       : "dev"
      "lambdaAlias" : "dev"
    },
    {
      "stage"       : "prod"
      "lambdaAlias" : "prod"
    }
  ]
  api_definition = [
    {
      "path"                           : "health"
      "function_name"                  : "devops-api-poc-healthcheck"
      "api_key_requireds"              : false
      "authorizations"                 : "NONE"
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
      "api_key_requireds"              : true
      "authorizations"                 : "CUSTOM"
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
    },
    {
      "path"                           : "post"
      "function_name"                  : "devops-api-poc-post"
      "api_key_requireds"              : true
      "authorizations"                 : "CUSTOM"
      "method"                         : "POST"
      "integration_type"               : "AWS_PROXY"
      "integration_http_method"        : "POST"
      "uri"                            : "arn:aws:apigateway:eu-west-1:lambda:path/2015-03-31/functions/arn:aws:lambda:eu-west-1:834366213304:function:devops-api-poc-post:$${stageVariables.lambdaAlias}/invocations"
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