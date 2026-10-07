output "s3_bucket_name" {
  description = "S3 bucket used for file processing"
  value       = aws_s3_bucket.platform.bucket
}

output "processing_queue_url" {
  description = "SQS processing queue URL"
  value       = aws_sqs_queue.processing_queue.url
}

output "processing_dlq_url" {
  description = "SQS dead letter queue URL"
  value       = aws_sqs_queue.processing_dlq.url
}

output "dynamodb_table_name" {
  description = "DynamoDB status table"
  value       = aws_dynamodb_table.file_processing_status.name
}

output "ingest_lambda_name" {
  description = "Ingest Lambda function name"
  value       = aws_lambda_function.ingest.function_name
}

output "worker_lambda_name" {
  description = "Worker Lambda function name"
  value       = aws_lambda_function.worker.function_name
}

output "cloudwatch_dashboard_name" {
  description = "CloudWatch monitoring dashboard"
  value       = aws_cloudwatch_dashboard.serverless_monitoring.dashboard_name
}