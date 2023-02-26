resource "aws_cloudfront_function" "cf_function" {
  count   = var.cf_function == true ? 1 : 0
  name    = "appendindexhtml"
  runtime = "cloudfront-js-1.0"
  publish = var.cf_function == true ? true : false
  code    = file("${path.module}/cf_function.js")

  lifecycle {
    create_before_destroy = true
  }
}
