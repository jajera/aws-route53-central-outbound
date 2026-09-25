resource "aws_route53_resolver_rule" "this" {
  domain_name          = var.domain_name
  name                 = var.name
  rule_type            = "FORWARD"
  resolver_endpoint_id = var.resolver_endpoint_id

  dynamic "target_ip" {
    for_each = var.target_ips
    content {
      ip   = target_ip.value
      port = 53
    }
  }

  tags = {
    Name = var.name
  }
}

resource "aws_route53_resolver_rule_association" "this" {
  # count (not for_each): vpc_ids often contain apply-time unknowns (new VPC IDs).
  count = length(var.vpc_ids)

  resolver_rule_id = aws_route53_resolver_rule.this.id
  vpc_id           = var.vpc_ids[count.index]
  name             = "${var.name}-${count.index}"
}
