output "bucket_id" {
  value = aws_s3_bucket.s3_bucket.id
}
output "bucket_arn" {
  value = aws_s3_bucket.s3_bucket.arn
}
output "bucket_domain_name" {
  value  = aws_s3_bucket.s3_bucket.bucket_domain_name
}
output "bucket_region" {
  value = aws_s3_bucket.s3_bucket.region
}
