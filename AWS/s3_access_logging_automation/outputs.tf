##################################################
# Lambda Outputs
##################################################

output "s3_access_logging_lambda_name" {
  description = "Name of the S3 Access Logging Lambda function"
  value       = aws_lambda_function.s3_access_logging.function_name
}

output "s3_access_logging_lambda_arn" {
  description = "ARN of the S3 Access Logging Lambda function"
  value       = aws_lambda_function.s3_access_logging.arn
}

output "s3_access_logging_lambda_invoke_arn" {
  description = "Invoke ARN of the Lambda function"
  value       = aws_lambda_function.s3_access_logging.invoke_arn
}

##################################################
# IAM Role Outputs
##################################################

output "lambda_execution_role_name" {
  description = "Lambda execution role name"
  value       = aws_iam_role.lambda_exec_role.name
}

output "lambda_execution_role_arn" {
  description = "Lambda execution role ARN"
  value       = aws_iam_role.lambda_exec_role.arn
}

##################################################
# IAM Policy Outputs
##################################################

output "lambda_execution_policy_name" {
  description = "Lambda execution policy name"
  value       = aws_iam_policy.lambda_basic_execution.name
}

output "lambda_execution_policy_arn" {
  description = "Lambda execution policy ARN"
  value       = aws_iam_policy.lambda_basic_execution.arn
}

##################################################
# Lambda Permission Outputs
##################################################

output "lambda_permission_statement_id" {
  description = "Lambda permission statement ID for EventBridge"
  value       = aws_lambda_permission.allow_eventbridge.statement_id
}

##################################################
# Operational Outputs
##################################################

output "log_target_bucket" {
  description = "S3 bucket receiving access logs"
  value       = local.current.log_target_bucket
}