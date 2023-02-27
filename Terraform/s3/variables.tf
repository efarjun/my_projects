variable "bucket_name" {}
variable "versioning_status" {
  default = "Enabled"
}
variable "bucket_key" {
  type = bool
  default = true
}
