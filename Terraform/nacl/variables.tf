variable "acl_rules" {
  description = "Map of ingress and egress rules for the network ACL"
  type = object({
    ingress = list(object({
      rule_no         = number
      action          = string
      protocol        = string
      from_port       = number
      to_port         = number
      cidr_block      = string
      ipv6_cidr_block = string
      icmp_type       = number
      icmp_code       = number
    }))
    egress = list(object({
      rule_no         = number
      action          = string
      protocol        = string
      from_port       = number
      to_port         = number
      cidr_block      = string
      ipv6_cidr_block = string
      icmp_type       = number
      icmp_code       = number
    }))
  })
}
