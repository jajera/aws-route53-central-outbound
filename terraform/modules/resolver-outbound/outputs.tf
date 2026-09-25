output "resolver_endpoint_id" {
  description = "Route 53 Resolver outbound endpoint ID"
  value       = aws_route53_resolver_endpoint.this.id
}

output "security_group_id" {
  description = "Outbound endpoint security group ID"
  value       = aws_security_group.this.id
}

output "eni_count" {
  description = "Number of ENIs attached to the outbound endpoint"
  value       = 2
}
