variable "bucket_name" {}
variable "versioning_status" {
  default = "Enabled"
}
variable "bucket_key" {
  type = bool
  default = true
}
variable "public_acls" {
  default = true
}
variable "ignore_public_acls" {
  default = true
}
variable "ignore_public_acls" {
  default = true
}
variable "restrict_public_buckets" {
  default = true
}
