locals {
  s3_origin_id = "s3_origin"
  cf_function_arn = one(aws_cloudfront_function.cf_function[*].arn)
}
