resource "aws_acm_certificate" "certificate" {
  domain_name       = var.domain_name
  validation_method = var.validation_method
  subject_alternative_names = var.alternative_names
}
