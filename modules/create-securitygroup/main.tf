data "aws_vpc" "cluster_vpc" {
  filter {
    name = "tag:Name"
    values = [ var.vpc.name ]
  }
}

resource "aws_security_group" "solace_secgrp" {
  name        = var.solace_secgrp.name
  vpc_id = data.aws_vpc.cluster_vpc.id

  tags = merge({
    Name = var.solace_secgrp.name
    }, var.common_tags)

  # dynamic
  dynamic "ingress" {
    for_each = var.solace_secgrp.ingress
    content {
      from_port = ingress.value.from_port
      to_port = ingress.value.to_port
      protocol = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  # Self 
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self = true
  }

  # outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}