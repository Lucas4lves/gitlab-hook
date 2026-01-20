resource "aws_api_gateway_rest_api" "rest_api" {
  name = var.rest_api_name
}

resource "aws_api_gateway_resource" "rest_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = var.rest_api_path
}

resource "aws_api_gateway_method" "webhook-producer" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.rest_api_resource.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.rest_api_resource.id
  http_method             = aws_api_gateway_method.webhook-producer.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.producer.invoke_arn
}

resource "aws_api_gateway_deployment" "gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.rest_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [ aws_api_gateway_method.webhook-producer, aws_api_gateway_integration.lambda_integration ]
}

resource "aws_api_gateway_stage" "gateway_stage" {
  deployment_id = aws_api_gateway_deployment.gateway_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id

  stage_name = "v1"

  depends_on = [ aws_api_gateway_deployment.gateway_deployment ]
}

resource "aws_api_gateway_api_key" "gateway_key" {
  name = var.rest_api_key
}

resource "aws_api_gateway_usage_plan" "gateway_usage_plan" {
  name = var.rest_api_key_usage_plan
  api_stages {
    api_id = aws_api_gateway_rest_api.rest_api.id
    stage = aws_api_gateway_stage.gateway_stage.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "gateway_usage_plan" {
  key_id = aws_api_gateway_api_key.gateway_key.id
  key_type = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.gateway_usage_plan.id
}

output "api_gateway_invoke_url" {
  value = "${aws_api_gateway_stage.gateway_stage.invoke_url}/summarize"
}
