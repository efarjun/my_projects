acl_rules = {
  ingress = [
    {
      rule_no         = 100
      action          = "allow"
      protocol        = "-1"
      from_port       = 0
      to_port         = 0
      cidr_block      = "0.0.0.0/0"
      ipv6_cidr_block = ""
      icmp_type       = 0
      icmp_code       = 0
    },
    {
      rule_no         = 94
      action          = "allow"
      protocol        = "6"
      from_port       = 22
      to_port         = 22
      cidr_block      = "10.23.0.0/16"
      ipv6_cidr_block = ""
      icmp_type       = 0
      icmp_code       = 0
    },
    {
      rule_no         = 95
      action          = "allow"
      protocol        = "6"
      from_port       = 3389
      to_port         = 3389
      cidr_block      = "10.23.0.0/16"
      ipv6_cidr_block = ""
      icmp_type       = 0
      icmp_code       = 0
    },
    {
      rule_no         = 96
      action          = "allow"
      protocol        = "6"
      from_port       = 22
      to_port         = 22
      cidr_block      = "23.0.0.0/16"
      ipv6_cidr_block = ""
      icmp_type       = 0
      icmp_code       = 0
    },
    {
      rule_no         = 97
      action          = "allow"
      protocol        = "6"
      from_port       = 3389
      to_port         = 3389
      cidr_block      = "23.0.0.0/16"
      ipv6_cidr_block = ""
      icmp_type       = 0
      icmp_code       = 0
    },
    {
      rule_no         = 98
      action          = "deny"
      protocol        = "6"
      from_port       = 22
      to_port         = 22
      cidr_block      = "0.0.0.0/0"
      ipv6_cidr_block = ""
      icmp_type       = 0
      icmp_code       = 0
    },
    {
      rule_no         = 99
      action          = "deny"
      protocol        = "6"
      from_port       = 3389
      to_port         = 3389
      cidr_block      = "0.0.0.0/0"
      ipv6_cidr_block = ""
      icmp_type       = 0
      icmp_code       = 0
    }
  ]
  egress = [
    {
      rule_no         = 100
      action          = "allow"
      protocol        = "-1"
      from_port       = 0
      to_port         = 0
      cidr_block      = "0.0.0.0/0"
      ipv6_cidr_block = ""
      icmp_type       = 0
      icmp_code       = 0
    }
  ]
}
