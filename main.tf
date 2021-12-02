  module "api-gateway" {
    source        = "clouddrove/api-gateway/aws"
    version       = "0.14.0"

    name        = var.service
    environment = var.environment
    label_order = ["name", "environment"]
    enabled     = true

  # Api Gateway Resource
    path_parts     = flatten([for config in var.api_definition: config.path])

  # Api Gateway Method
    method_enabled = true
    http_methods   = flatten([for config in var.api_definition: config.method])

  # Api Gateway Integration
    integration_types              = flatten([for config in var.api_definition: config.integration_type])
    integration_http_methods       = flatten([for config in var.api_definition: config.integration_http_method])
    uri                            = flatten([for config in var.api_definition: config.uri])
    integration_request_parameters = flatten([for config in var.api_definition: config.integration_request_parameter])
    request_templates              = flatten([for config in var.api_definition: config.request_template])

  # Api Gateway Method Response
    status_codes                   = flatten([for config in var.api_definition: config.status_code])
    response_models                = flatten([for config in var.api_definition: config.response_model])
    response_parameters            = flatten([for config in var.api_definition: config.response_parameter])
    api_key_requireds              = flatten([for config in var.api_definition: config.api_key_requireds])

  # Api Gateway Integration Response
    integration_response_parameters = flatten([for config in var.api_definition: config.integration_response_parameter])
    response_templates = flatten([for config in var.api_definition: config.response_template])

  # Api Gateway Deployment
    deployment_enabled = true

  # Api Gateway Stage
    stage_enabled = true
    stage_names   = flatten([for stage in var.stage_variables: stage.stage])
    stage_variables = var.stage_variables

  # Endpoint Type
    types = ["REGIONAL"]

  # Default API Keys
    key_count = 1
    key_names = ["default_api_key"]
  }
