resource "aws_network_acl" "main" {
  vpc_id = module.vpc.vpc_id

  egress = [
    for rule in var.acl_rules.egress : {
      rule_no         = rule.rule_no
      action          = rule.action
      protocol        = rule.protocol
      from_port       = rule.from_port
      to_port         = rule.to_port
      cidr_block      = rule.cidr_block
      ipv6_cidr_block = rule.ipv6_cidr_block
      icmp_type       = rule.icmp_type
      icmp_code       = rule.icmp_code
    }
  ]

  ingress = [
    for rule in var.acl_rules.ingress : {
      rule_no         = rule.rule_no
      action          = rule.action
      protocol        = rule.protocol
      from_port       = rule.from_port
      to_port         = rule.to_port
      cidr_block      = rule.cidr_block
      ipv6_cidr_block = rule.ipv6_cidr_block
      icmp_type       = rule.icmp_type
      icmp_code       = rule.icmp_code
    }
  ]
}
