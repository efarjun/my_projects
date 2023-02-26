variable "bucket_name" {}
variable "allowed_methods" {
  type = list(strings)
  default = ["GET", "HEAD"]
}
variable "cached_methods" {
  type = list(strings)
  default = ["GET", "HEAD"]
}
variable "oac_name" {}
variable "cf_function" {
  type = bool
  default = false
}
