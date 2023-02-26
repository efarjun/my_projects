variable "bucket_name" {}
variable "bucket_key" {
  type = bool
  default = true
}
variable "versioning_status" {
  default = "Enabled"
}
variable "allowed_methods" {
  type = list
  default = ["GET", "HEAD"]
}
variable "cached_methods" {
  type = list
  default = ["GET", "HEAD"]
}
variable "oac_name" {}
variable "cf_function" {
  type = bool
  default = false
}
