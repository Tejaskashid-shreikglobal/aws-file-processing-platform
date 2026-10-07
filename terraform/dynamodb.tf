# =========================================================
# DynamoDB File Processing Status
# =========================================================

resource "aws_dynamodb_table" "file_processing_status" {
  name         = "file-processing-status"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "file_id"

  attribute {
    name = "file_id"
    type = "S"
  }
}