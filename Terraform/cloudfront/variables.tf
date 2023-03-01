variable "oac_name" {
  description = "name of origin access control."
}
variable "oac_type" {
  description = "Type of origin access control."
  default = "s3"
}
variable "signing_behavior" {
  description = "Signing behavior"
  default = "always"
}
variable "signing_protocol" {
  description = "Signing protocol."
  default = "sigv4"
}
variable "s3_origin_name" {
  description = "The name of the S3 bucket that will be the Cloudfront origin."
}
variable "origin_id" {
  description = "Origin ID."
}
variable "enabled" {
  description = "If the distribution is enabled."
  type = bool
  default = true
}
variable "ipv6" {
  description = "If IPv6 is enabled."
  type = bool
  default = true
}
variable "comment" {
  description = "Add a comment."
  default = null
}
variable "root_object" {
  description = "The default root object in S3 folder."
  default = "index.html"
}
variable "allowed_methods" {
  description = "Allowed HTTP methods."
  type = list
  default = ["GET", "HEAD"]
}
variable "cached_methods" {
  description = "Cached HTTP methods."
  type = list
  default = ["GET", "HEAD"]
}
variable "cf_function" {
  description = "If CloudFront Function is being used."
  type = bool
  default = false
}
variable "event_type" {
  description = "If function being used, use viewer-request."
  default = null
}
variable "cloudfront_function" {
  description "If function being used, use ARN of function."
  default = null
}
variable "query_string" {
  type = bool
  default = false
}
variable "forward" {
  default = "none"
}
variable "viewer_protocol_policy" {
  default = "allow-all"
}
variable "min_ttl" {
  default = 0
}
variable "default_ttl" {
  default = 3600
}
variable "max_ttl" {
  default = 86400
}
variable "price_class" {
  default = "PriceClass_All"
}
variable "restriction_type" {
  default = "none"
}
variable "viewer_certificate" {
  type = bool
  default = true
}
variable "certificate_arn" {
  description = "The arn of the ACM certificate used for the distribution."
}
variable "ssl_support_method" {
  default = "sni-only"
}
variable "principal_type" {
  default = "AWS"
}
  
