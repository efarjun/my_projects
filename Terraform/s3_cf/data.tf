data "aws_cloudfront_function" "cf_function" {
  name = "appendindexhtml"
  stage = "LIVE"
}

data "aws_acm_certificate" "cf_distribution_cert" {
  domain = "ef-20230226-test1.com"
}
