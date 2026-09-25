resource "aws_security_group" "this" {
  name        = "${var.name_prefix}-outbound-sg"
  description = "Route 53 Resolver outbound endpoint egress to DNS targets"
  vpc_id      = var.vpc_id

  egress {
    description = "DNS UDP to forward targets"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = var.target_cidr_blocks
  }

  egress {
    description = "DNS TCP to forward targets"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = var.target_cidr_blocks
  }

  tags = {
    Name = "${var.name_prefix}-outbound-sg"
  }
}

resource "aws_route53_resolver_endpoint" "this" {
  name               = "${var.name_prefix}-outbound"
  direction          = "OUTBOUND"
  security_group_ids = [aws_security_group.this.id]

  dynamic "ip_address" {
    for_each = var.subnet_ids
    content {
      subnet_id = ip_address.value
    }
  }

  tags = {
    Name = "${var.name_prefix}-outbound"
  }
}
