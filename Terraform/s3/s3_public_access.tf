resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.example.id

  block_public_acls       = var.public_acls
  block_public_policy     = var.public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restricted_public_buckets
}
