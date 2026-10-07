# =========================================================
# SQS Dead Letter Queue
# =========================================================

resource "aws_sqs_queue" "processing_dlq" {
  name = "processing-dlq"
}

# =========================================================
# SQS Processing Queue
# =========================================================

resource "aws_sqs_queue" "processing_queue" {
  name                       = "processing-queue"
  visibility_timeout_seconds = 180

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.processing_dlq.arn
    maxReceiveCount     = 3
  })
}