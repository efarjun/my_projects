output "s3_bucket_name" {
  value = aws_s3_bucket.s3_bucket.id
}
output "cloudfront_distribution_id_with_function" {
  value = one(aws_cloudfront_distribution.cloudfront_function_yes[*].id)
}
output "cloudfront_distribution_id_no_function" {
  value = one(aws_cloudfront_distribution.cloudfront_function_no[*].id)
}
