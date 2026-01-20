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

data "aws_iam_policy_document" "use_sqs" {
  statement {
    effect = "Allow"
    actions = ["sqs:sendMessage", "sqs:receiveMessage", "sqs:deleteMessage"]
    resources = [ aws_sqs_queue.regular_qeue.arn]
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "lambda_exec"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json 
}


resource "aws_iam_role_policy" "lambda_sqs" {
  name = "lambda_sqs_policy"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = "${aws_sqs_queue.regular_qeue.arn}"
      }
    ]
  })

  depends_on = [ aws_sqs_queue.regular_qeue ]
}

resource "aws_iam_role_policy" "use_sqs_policy" {
  name = "lambda_push_sqs"
  role = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.use_sqs.json
}