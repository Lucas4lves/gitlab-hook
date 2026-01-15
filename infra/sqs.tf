resource "aws_sqs_queue" "dead_letter" {
  name = "deadletterqueue.fifo"
  fifo_queue = true
}

resource "aws_sqs_queue" "regular_qeue" {
  name                        = var.regular_qeue_name
  fifo_queue                  = true
  content_based_deduplication = true

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead_letter.arn
    maxReceiveCount     = 2
  })
}

output "regular_queue_url" {
  value = aws_sqs_queue.regular_qeue.url
}