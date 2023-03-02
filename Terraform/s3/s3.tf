resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_versioning" "versioning_enabled" {
  bucket = aws_s3_bucket.s3_bucket.id
  versioning_configuration {
    status = var.versioning_status
  }
  depends_on = [aws_s3_bucket.s3_bucket]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  bucket = aws_s3_bucket.s3_bucket.id
  rule {
      bucket_key_enabled = var.bucket_key
  }
  depends_on = [aws_s3_bucket.s3_bucket]
}
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = var.bucket_name

  block_public_acls       = var.public_acls
  block_public_policy     = var.public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
  depends_on = [aws_s3_bucket.s3_bucket]
}
