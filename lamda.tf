resource "aws_lambda_permission" "dev_alias_permissions" {
  for_each      = zipmap([for config in var.api_definition: config.path], [for config in var.api_definition: config.function_name])
  statement_id  = "AllowExecutionFromAPIGateway-dev-GET-${each.value}"
  action        = "lambda:InvokeFunction"
  function_name = each.value
  principal     = "apigateway.amazonaws.com"
  qualifier     = "dev"
  source_arn    = "arn:aws:execute-api:eu-west-1:834366213304:${module.api-gateway.id}/*/GET/${each.key}"
}

resource "aws_lambda_permission" "prod_alias_permissions" {
  for_each      = zipmap([for config in var.api_definition: config.path], [for config in var.api_definition: config.function_name])
  statement_id  = "AllowExecutionFromAPIGateway-prod-GET-${each.value}"
  action        = "lambda:InvokeFunction"
  function_name = each.value
  principal     = "apigateway.amazonaws.com"
  qualifier     = "prod"
  source_arn    = "arn:aws:execute-api:eu-west-1:834366213304:${module.api-gateway.id}/*/GET/${each.key}"
}

#TODO: determine the HTTP Method on the resource and create the respective GET, PUT, POST etc.
resource "aws_lambda_permission" "post_dev_alias_get_permissions" {
  for_each      = zipmap([for config in var.api_definition: config.path], [for config in var.api_definition: config.function_name])
  statement_id  = "AllowExecutionFromAPIGateway-dev-POST-${each.value}"
  action        = "lambda:InvokeFunction"
  function_name = each.value
  principal     = "apigateway.amazonaws.com"
  qualifier     = "dev"
  source_arn    = "arn:aws:execute-api:eu-west-1:834366213304:${module.api-gateway.id}/*/POST/${each.key}"
}

resource "aws_lambda_permission" "post_prod_alias_permissions" {
  for_each      = zipmap([for config in var.api_definition: config.path], [for config in var.api_definition: config.function_name])
  statement_id  = "AllowExecutionFromAPIGateway-prod-POST-${each.value}"
  action        = "lambda:InvokeFunction"
  function_name = each.value
  principal     = "apigateway.amazonaws.com"
  qualifier     = "prod"
  source_arn    = "arn:aws:execute-api:eu-west-1:834366213304:${module.api-gateway.id}/*/POST/${each.key}"
}