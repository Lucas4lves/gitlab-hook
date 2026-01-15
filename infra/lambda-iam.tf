data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "push_messages_to_sqs" {
  statement {
    effect = "Allow"
    actions = ["sqs:sendMessage"]
    resources = [ aws_sqs_queue.regular_qeue.arn]
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda_exec"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy" "push_messages_to_sqs_policy" {
  name = "lambda_push_sqs"
  role = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.push_messages_to_sqs.json
}