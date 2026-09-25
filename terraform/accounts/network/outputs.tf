output "account_id" {
  description = "Network AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "vpc_id" {
  description = "Network VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "Network VPC CIDR"
  value       = module.vpc.vpc_cidr
}

output "dns_server_ip" {
  description = "BIND private IP (Resolver target)"
  value       = module.dns_server.private_ip
}

output "dns_server_instance_id" {
  description = "BIND EC2 instance ID"
  value       = module.dns_server.instance_id
}

output "zone_name" {
  description = "Authoritative forward zone name"
  value       = module.dns_server.zone_name
}

output "reverse_zone_name" {
  description = "Authoritative reverse zone (in-addr.arpa)"
  value       = module.dns_server.reverse_zone_name
}

output "resolver_endpoint_id" {
  description = "Network outbound endpoint ID"
  value       = module.resolver_outbound.resolver_endpoint_id
}

output "resolver_rule_id" {
  description = "Forward zone FORWARD rule ID (share or hand off to spokes)"
  value       = module.forward_rule.resolver_rule_id
}

output "resolver_rule_arn" {
  description = "Forward zone FORWARD rule ARN"
  value       = module.forward_rule.resolver_rule_arn
}

output "reverse_resolver_rule_id" {
  description = "Reverse zone FORWARD rule ID (share or hand off to spokes)"
  value       = module.reverse_forward_rule.resolver_rule_id
}

output "reverse_resolver_rule_arn" {
  description = "Reverse zone FORWARD rule ARN"
  value       = module.reverse_forward_rule.resolver_rule_arn
}

output "ram_share_arn" {
  description = "RAM share ARN when outbound_pattern is central; empty otherwise"
  value       = try(module.ram_share[0].resource_share_arn, "")
}

output "test_client_instance_id" {
  description = "Network test client instance ID for SSM dig"
  value       = module.test_client.instance_id
}

output "outbound_pattern" {
  description = "Active outbound pattern"
  value       = var.outbound_pattern
}

output "eni_count" {
  description = "Outbound endpoint ENI count in this account"
  value       = module.resolver_outbound.eni_count
}
