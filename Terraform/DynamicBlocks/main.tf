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

resource "aws_security_group" "asg" {
  vpc_id = data.aws_vpc.vpc1.id
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port = ingress_rule.value.port
      to_port = ingress_rule.value.port
      protocol = ingress_rule.value.protocol
      cidr_blocks = ingress_rule.value.cidr_blocks
    }
  }
  dynamic "egress" {
    for_each = var.egress_rules
    content {
      from_port = egress_rule.value.port
      to_port = egress_rule.value.port
      protocol = egress_rule.value.protocol
      cidr_block = egress_rule.value.cidr_blocks
    }
  }
}

resource "aws_instance" "ec2-1" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id = data.aws_subnet.subnet1.id
  vpc_security_groups = [aws_security_group.asg.id]
  tags = {
    Name = "web1"
  }
}

