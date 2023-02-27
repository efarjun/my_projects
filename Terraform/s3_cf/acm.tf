resource "aws_acm_certificate" "cert" {
  domain_name       = var.domain_name
  validation_method = var.validation_method
  subject_alternative_names = var.alternative_names
  key_algorithm = var.key_algorithm
  options = var.options
  validation_option = var.validation_option
}
