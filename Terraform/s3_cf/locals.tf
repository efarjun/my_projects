locals {
  s3_origin_id = "s3_origin"
  cf_function_arn = one(data.aws_cloudfront_function.cf_function[*].arn)
}
