data "aws_cloudfront_function" "cf_function" {
  name = "appendindexhtml"
  stage = "LIVE"
}
