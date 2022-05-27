variable "ingress_rules" {
  type = list(object({
    port = number
    protocol = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      port = 22
      protocol = "tcp"
      cidr_blocks["0.0.0.0/0"]
    },
    {
      port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
     },
    {
      port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}
variable "egress_rules" {
  default = [
    {
      port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}
