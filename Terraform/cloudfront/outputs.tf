output "distribution_id_with_function" {
  value = one(aws_cloudfront_distribution.s3_distribution_with_function[*].id)
}
output"distribution_id_without_function" {
  value = one(aws_cloudfront_distribution.s3_distribution_without_function[*].id)
}
output "distribution_arn_with_function" {
  value = one(aws_cloudfront_distribution.s3_distribution_with_function[*].arn)
}
output"distribution_arn_without_function" {
  value = one(aws_cloudfront_distribution.s3_distribution_without_function[*].arn)
}
