# =========================================================
# CloudWatch Log Groups
# =========================================================

resource "aws_cloudwatch_log_group" "ingest" {
  name              = "/aws/lambda/file-processing-ingest"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "worker" {
  name              = "/aws/lambda/file-processing-worker"
  retention_in_days = 7
}