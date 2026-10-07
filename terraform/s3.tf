# =========================================================
# S3 Bucket
# =========================================================

resource "aws_s3_bucket" "platform" {
  bucket_prefix = "serverless-file-platform-"
}

resource "aws_s3_object" "input_prefix" {
  bucket  = aws_s3_bucket.platform.id
  key     = "input/"
  content = ""
}

resource "aws_s3_object" "processing_prefix" {
  bucket  = aws_s3_bucket.platform.id
  key     = "processing/"
  content = ""
}

resource "aws_s3_object" "output_prefix" {
  bucket  = aws_s3_bucket.platform.id
  key     = "output/"
  content = ""
}

# =========================================================
# S3 → Ingest Lambda Notification
# =========================================================

resource "aws_s3_bucket_notification" "platform_notification" {
  bucket = aws_s3_bucket.platform.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.ingest.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "input/"
  }

  depends_on = [
    aws_lambda_permission.allow_s3
  ]
}