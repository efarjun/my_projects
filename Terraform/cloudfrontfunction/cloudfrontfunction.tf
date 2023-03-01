resource "aws_cloudfront_function" "function" {
  name    = var.function_name
  runtime = var.function_runtime
  publish = var.function_publish
  code    = file("${path.module}/${var.function_file}")
}
