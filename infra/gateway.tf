resource "aws_api_gateway_rest_api" "rest_api" {
  name = var.rest_api_name
}

resource "aws_api_gateway_resource" "rest_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  parent_id   = aws_api_gateway_rest_api.rest_api.root_resource_id
  path_part   = var.rest_api_path
}

resource "aws_api_gateway_method" "summarize_changes" {
  rest_api_id   = aws_api_gateway_rest_api.rest_api.id
  resource_id   = aws_api_gateway_resource.rest_api_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.rest_api.id
  resource_id             = aws_api_gateway_resource.rest_api_resource.id
  http_method             = aws_api_gateway_method.summarize_changes.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.this.invoke_arn
}

resource "aws_api_gateway_deployment" "gateway_deployment" {
  rest_api_id = aws_api_gateway_rest_api.rest_api.id
  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.rest_api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "gateway_stage" {
  deployment_id = aws_api_gateway_deployment.gateway_deployment.id
  rest_api_id = aws_api_gateway_rest_api.rest_api.id

  stage_name = "v1"
}