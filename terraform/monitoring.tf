# =========================================================
# CloudWatch Monitoring Dashboard
# =========================================================

resource "aws_cloudwatch_dashboard" "serverless_monitoring" {
  dashboard_name = "serverless-file-processing-monitoring"

  dashboard_body = jsonencode({
    widgets = [

      # ===================================================
      # Ingest Lambda Metrics
      # ===================================================

      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6

        properties = {
          title  = "Ingest Lambda Metrics"
          region = var.aws_region
          period = 300
          stat   = "Sum"
          view   = "timeSeries"

          metrics = [
            [
              "AWS/Lambda",
              "Invocations",
              "FunctionName",
              aws_lambda_function.ingest.function_name
            ],
            [
              "AWS/Lambda",
              "Errors",
              "FunctionName",
              aws_lambda_function.ingest.function_name
            ],
            [
              "AWS/Lambda",
              "Throttles",
              "FunctionName",
              aws_lambda_function.ingest.function_name
            ]
          ]
        }
      },

      # ===================================================
      # Worker Lambda Metrics
      # ===================================================

      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6

        properties = {
          title  = "Worker Lambda Metrics"
          region = var.aws_region
          period = 300
          view   = "timeSeries"

          metrics = [
            [
              "AWS/Lambda",
              "Invocations",
              "FunctionName",
              aws_lambda_function.worker.function_name
            ],
            [
              "AWS/Lambda",
              "Errors",
              "FunctionName",
              aws_lambda_function.worker.function_name
            ],
            [
              "AWS/Lambda",
              "Duration",
              "FunctionName",
              aws_lambda_function.worker.function_name
            ],
            [
              "AWS/Lambda",
              "Throttles",
              "FunctionName",
              aws_lambda_function.worker.function_name
            ]
          ]
        }
      },

      # ===================================================
      # SQS Metrics
      # ===================================================

      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 24
        height = 6

        properties = {
          title  = "Processing Queue Metrics"
          region = var.aws_region
          period = 300
          view   = "timeSeries"

          metrics = [
            [
              "AWS/SQS",
              "NumberOfMessagesSent",
              "QueueName",
              aws_sqs_queue.processing_queue.name
            ],
            [
              "AWS/SQS",
              "NumberOfMessagesReceived",
              "QueueName",
              aws_sqs_queue.processing_queue.name
            ],
            [
              "AWS/SQS",
              "NumberOfMessagesDeleted",
              "QueueName",
              aws_sqs_queue.processing_queue.name
            ],
            [
              "AWS/SQS",
              "ApproximateNumberOfMessagesVisible",
              "QueueName",
              aws_sqs_queue.processing_queue.name
            ]
          ]
        }
      }
    ]
  })
}


# =========================================================
# SQS Visible Messages Alarm
# =========================================================

resource "aws_cloudwatch_metric_alarm" "sqs_messages_visible" {
  alarm_name          = "processing-queue-messages-visible"
  alarm_description   = "Alerts when processing queue has too many visible messages"
  namespace           = "AWS/SQS"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  dimensions = {
    QueueName = aws_sqs_queue.processing_queue.name
  }

  statistic                 = "Maximum"
  period                    = 300
  evaluation_periods        = 1
  threshold                 = 5
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  treat_missing_data        = "notBreaching"
  insufficient_data_actions = []
}


# =========================================================
# Worker Lambda Error Alarm
# =========================================================

resource "aws_cloudwatch_metric_alarm" "worker_errors" {
  alarm_name          = "file-processing-worker-errors"
  alarm_description   = "Monitors errors in Worker Lambda"
  namespace           = "AWS/Lambda"
  metric_name         = "Errors"

  statistic           = "Sum"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1

  comparison_operator = "GreaterThanOrEqualToThreshold"

  dimensions = {
    FunctionName = aws_lambda_function.worker.function_name
  }
}