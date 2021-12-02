## Purpose
The purpose of this module is to standardise the way we build API Gateways in a scalable and reproducible manner.
- [x] Provisions API Gateway
- [x] Provisions Resources and their respective integration configuration i.e. HTTP Methods, Integration Types and API Keys etc.
- [x] Provisions `dev` and `prod` stages for the API Gateway Resources and their respective stage variables
- [x] Configures the neccessary permissions to invoke AWS Lambda Functions and their respective aliases from the API Gateway
- [x] Allows to optionally configure API keys for Authentication


The module creates an API Gateway. It creates the API Resources using the `api_definition` variable where the `path`, `lambda_function` and `HTTP Method` is defined for the specific endpoint. The module also creates the `dev` and `prod` stages defined in the `stage_variables` variable. The `lambdaAlias` stage variable is used to target the functions using its `dev` and `prod` aliases [2]. Lastly worth noting the module also allows the API Gateway the IAM permissions to invoke the AWS Lambda functions configured. Note that to use this module, the AWS Lambda functions will need to have been deployed. 

## Additional Reading
1. [Lambda Aliases](https://docs.aws.amazon.com/lambda/latest/dg/configuration-aliases.html)

## Future Work
- [ ] Dynamically scale IAM Permissions for all stages configured 
- [ ] Test Module
- [ ] Investigate the implementation of other AWS resources as integration endpoints that can be configured behind an API gateway

#### Variables

Variable | Description
------------ | -------------
`profile` | AWS Profile used to create the resoources 
`region` | Region in which to create the resources
`team` | Department or Owner of the resource
`environment` | Respective environment the resource is targetting i.e. dev or prod
`service` | The service name abbreviation of the service
`api_definition` | Map of the definitions of the API Resources. See more later
`stage_variables` | Map of stage variables per stage

### Deploy AWS Lambda Function Using Serverless

See the example directory on how to implement module and using serverless to deploy APIs. The Serverless Framework is a open source tool that enables development on serverless platforms like AWS Lamdba. Its powered by CloudFormation, however it does obfuscate the technicalities of Cloudformation, and using one `yaml` file we're able to define and deploy functions to mulitple stages. That being, run the following commands to initialise and deploy the function using serverless. 

``` bash
$ serverless init
$ serverless deploy

Serverless: Packaging service...
Serverless: Excluding development dependencies...
Serverless: Uploading CloudFormation file to S3...
Serverless: Uploading artifacts...
Serverless: Uploading service devops-serverless-api-poc.zip file to S3 (47.14 MB)...
Serverless: Validating template...
Serverless: Updating Stack...
Serverless: Checking Stack update progress...
.....................
Serverless: Stack update finished...
Service Information
service: devops-serverless-api-poc
stage: dev
region: eu-west-1
stack: devops-serverless-api-poc-dev
resources: 10
api keys:
  None
endpoints:
functions:
  health: devops-api-poc-healthcheck
  env: devops-api-poc-env
  post: devops-api-poc-post
layers:
  None

```

Run the follwoing command to list the functions deployed and their respective versions
``` bash
$ serverless deploy list functions
Serverless: Listing functions and their last 5 versions:
Serverless: -------------
Serverless: devops-api-poc-healthcheck: $LATEST, 14, 15, 16, 17
Serverless: devops-api-poc-env: $LATEST, 14, 15, 16, 17
Serverless: devops-api-poc-post: $LATEST, 2, 3, 4, 5
```

For earch function you want to create a `dev` and a `prod` alias. We'll set the `dev` alias to always point to the latest version of the code. For production, this largely depends on what code needs to go live and can be easily set and updated on the fly

``` bash
$ aws lambda update-alias --function-name devops-api-poc-healthcheck --function-version '$LATEST' --name dev --profile globee --region eu-west-1
{
    "AliasArn": "arn:aws:lambda:eu-west-1:834366213304:function:devops-api-poc-healthcheck:dev",
    "Name": "dev",
    "FunctionVersion": "$LATEST",
    "Description": "",
    "RevisionId": "cd6aa4df-7b53-406f-b76b-e50cfb06eb10"
}
$ aws lambda update-alias --function-name devops-api-poc-healthcheck --function-version 17 --name prod --profile globee --region eu-west-1
{
    "AliasArn": "arn:aws:lambda:eu-west-1:834366213304:function:devops-api-poc-healthcheck:prod",
    "Name": "prod",
    "FunctionVersion": "17",
    "Description": "",
    "RevisionId": "eb6e8afd-fe18-4ef6-b2f0-e9fb7320e54f"
}

```
Our AWS Lambda Functions are now deployed and we can provision the API Gateway using terraform. See below for module usage.

#### Module Usage 

``` bash
$ terraform init
$ terraform plan
$ terraform apply
```

``` ruby
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
```


#### Source Code Structure
```
├── main.tf                           - main implementation of clouddrove/api-gateway/aws module using the flatterned maps of the api_definition var
├── lambda.tf                         - IAM invoke permissions for the lambda functions and their respective stages
├── locals.tf                         - local vars used as default tags for all resources
├── provider.tf                       - terraform provider configuration
├── variables.tf                      - variable definitions, descriptions and defaults
├── example
│    ├── serverless.yml               - serverless definition
│    └── src                    
│         └── main.py                 - boilerplate example for AWS Lambda Functions 
│    └── terraform                    
│         └── main.tf                 - example of Module usage     
```
