##################################################
# Lambda function that Automates S3 Access Logging
##################################################

resource "aws_lambda_function" "s3_access_logging" {
  function_name = "s3-access-logging-${terraform.workspace}"
  description   = "Automates access logging when an S3 bucket is created."
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "lambda_function.handler"
  runtime       = "python3.14"
  timeout       = 30

  filename         = "${path.module}/lambda_function.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda_function.zip")

  environment {
    variables = {
      LOG_TARGET_BUCKET = local.current.log_target_bucket
    }
  }
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.s3_access_logging.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.s3_bucket_created.arn
}
