data "aws_vpc" "vpc1" {
  id = "vpc-06e54bfd9bca2d16e"
}

data "aws_subnet" "subnet1" {
  id = "subnet-0435fa15a40d53940"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "ec2-1" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id = data.aws_subnet.subnet1.id
  tags = {
    Name = "web1"
  }
}
resource "aws_security_group" "asg" {
  vpc_id = data.aws_vpc.vpc.id
  dynamic "ingress" {
    for_each = var.ingress_rules
    iterator = "ingress_rule"
    content {
      from_port = ingress_rule.value
      to_port = ingress_rule.value
      protocol = ingress_rule.value
      cidr_blocks = ingress_rule.value
    }
  }
  dynamic "egress" {
    for_each = var.egress_rules
    iterator = "egress_rule"
    content {
      from_port = egress_rule.value
      to_port = egress_rule.value
      protocol = egress_rule.value
      cidr_block = egress_rule.value
    }
  }
}
