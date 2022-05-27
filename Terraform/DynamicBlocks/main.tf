data "aws_vpc" "vpc1" {
  id = "<vpc_id>" # Replace with your VPC ID.
}

data "aws_subnet" "subnet1" {
  id = "<subnet id>" # Replace with your subnet ID.
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
  name = "asg1"
  vpc_id = data.aws_vpc.vpc1.id
  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port = ingress.value.port
      to_port = ingress.value.port
      protocol = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
  dynamic "egress" {
    for_each = var.egress_rules
    content {
      from_port = egress.value.port
      to_port = egress.value.port
      protocol = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
}

resource "aws_instance" "ec2_instance" {
  count = 3
  ami = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  subnet_id = data.aws_subnet.subnet1.id
  vpc_security_group_ids = [aws_security_group.asg.id]
  tags = {
    Name = join("", ["webserver", count.index + 1])
  }
}
