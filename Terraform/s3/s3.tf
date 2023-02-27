

resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name
  acl    = var.acl
}

resource "aws_s3_bucket_versioning" "versioning_enabled" {
  bucket = aws_s3_bucket.s3_bucket.id
  versioning_configuration {
    status = var.versioning_status
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption_test" {
  bucket = aws_s3_bucket.s3_bucket.id
  rule {
      bucket_key_enabled = var.bucket_key
  }
}
