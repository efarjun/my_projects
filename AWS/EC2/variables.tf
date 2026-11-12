variable "owner" {
  description = "Owner name for tagging"
  type        = string
  default     = "Josh Owoseni"
}

variable "management_cidr_blocks" {
  description = "CIDR blocks allowed to RDP into the instances (e.g. Client VPN CIDR or office IP)"
  type        = list(string)
}
