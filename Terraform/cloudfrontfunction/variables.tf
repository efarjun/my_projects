variable "function_name" {
  description = "Name of Cloudfront Function."
}
variable "function_runtime" {
  description = "Function runtime"
  default = "cloudfront-js-1.0"
}
variable "function_publish" {
  description = "Publish to distribution"
  type = "bool"
  default = false
}
variable "function_file" {
  description = "Name of file with function."
}
