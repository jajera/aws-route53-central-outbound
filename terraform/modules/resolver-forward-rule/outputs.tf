output "resolver_rule_id" {
  description = "Forwarding rule ID"
  value       = aws_route53_resolver_rule.this.id
}

output "resolver_rule_arn" {
  description = "Forwarding rule ARN (for RAM shares)"
  value       = aws_route53_resolver_rule.this.arn
}
