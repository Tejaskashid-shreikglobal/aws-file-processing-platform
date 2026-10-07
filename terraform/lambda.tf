# =========================================================
# Lambda Function Packages
# =========================================================

data "archive_file" "ingest_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/ingest/ingest.py"
  output_path = "${path.module}/ingest.zip"
}

data "archive_file" "worker_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/worker/worker.py"
  output_path = "${path.module}/worker.zip"
}

# =========================================================
# Ingest Lambda
# =========================================================

resource "aws_lambda_function" "ingest" {
  function_name = "file-processing-ingest"
  role          = aws_iam_role.ingest_lambda_role.arn

  runtime = "python3.12"
  handler = "ingest.lambda_handler"

  filename         = data.archive_file.ingest_zip.output_path
  source_code_hash = data.archive_file.ingest_zip.output_base64sha256

  timeout = 30

  environment {
    variables = {
      QUEUE_URL  = aws_sqs_queue.processing_queue.url
      TABLE_NAME = aws_dynamodb_table.file_processing_status.name
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.ingest
  ]
}

# =========================================================
# Worker Lambda
# =========================================================

resource "aws_lambda_function" "worker" {
  function_name = "file-processing-worker"
  role          = aws_iam_role.worker_lambda_role.arn

  runtime = "python3.12"
  handler = "worker.lambda_handler"

  filename         = data.archive_file.worker_zip.output_path
  source_code_hash = data.archive_file.worker_zip.output_base64sha256

  timeout = 60

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.file_processing_status.name
    }
  }

  depends_on = [
    aws_cloudwatch_log_group.worker
  ]
}

# =========================================================
# S3 → Ingest Lambda Permission
# =========================================================

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.ingest.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.platform.arn
}

# =========================================================
# SQS → Worker Lambda Event Source
# =========================================================

resource "aws_lambda_event_source_mapping" "worker_sqs" {
  event_source_arn = aws_sqs_queue.processing_queue.arn
  function_name    = aws_lambda_function.worker.arn

  batch_size = 1
  enabled    = true
}