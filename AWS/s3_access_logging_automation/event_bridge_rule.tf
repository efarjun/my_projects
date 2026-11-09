resource "aws_cloudwatch_event_rule" "s3_bucket_created" {
  name        = "s3-bucket-created"
  description = "Triggers Lambda when an S3 bucket is created"

  event_pattern = jsonencode({
    source = [
      "aws.s3"
    ]
    "detail-type" = [
      "AWS API Call via CloudTrail"
    ]
    detail = {
      eventSource = [
        "s3.amazonaws.com"
      ]
      eventName = [
        "CreateBucket"
      ]
    }
  })
}

resource "aws_cloudwatch_event_target" "s3_bucket_created" {
  rule      = aws_cloudwatch_event_rule.s3_bucket_created.name
  target_id = "s3-access-logging"
  arn       = aws_lambda_function.s3_access_logging.arn
}