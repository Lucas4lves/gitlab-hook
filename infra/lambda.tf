data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}

data "archive_file" "producer_source" {
  type        = "zip"
  source_file = "${path.module}/../dist/producer/index.js"
  output_path = "${path.module}/../producer-lambda.zip"
}

data "archive_file" "consumer_source" {
  type        = "zip"
  source_file = "${path.module}/../dist/consumer/index.js"
  output_path = "${path.module}/../consumer-lambda.zip"
}

resource "aws_lambda_function" "producer" {
  filename      = data.archive_file.producer_source.output_path
  function_name = var.lambda_function_name
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"

  runtime = "nodejs20.x"

  environment {
    variables = {
      REGION = var.aws_region,
      QUEUE_URL = "${aws_sqs_queue.regular_qeue.url}",
    }
  }
  depends_on = [ aws_sqs_queue.regular_qeue ]
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.producer.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "arn:${data.aws_partition.current.partition}:execute-api:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.rest_api.id}/*/${aws_api_gateway_method.summarize_changes.http_method}${aws_api_gateway_resource.rest_api_resource.path}"

  depends_on = [ aws_lambda_function.producer ]
}

resource "aws_lambda_function" "consumer" {
  filename = data.archive_file.consumer_source.output_path
  function_name = "consumer-lambda"
  role = aws_iam_role.lambda_role.arn

  handler = "index.handler"
  runtime = "nodejs20.x"
}

resource "aws_lambda_event_source_mapping" "consumer_trigger" {
  event_source_arn = aws_sqs_queue.regular_qeue.arn
  function_name = aws_lambda_function.consumer.function_name
  enabled = true
  batch_size = 5
}