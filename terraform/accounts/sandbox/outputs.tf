output "account_id" {
  description = "Sandbox AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "vpc_id" {
  description = "Sandbox VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "Sandbox VPC CIDR"
  value       = module.vpc.vpc_cidr
}

output "test_client_instance_id" {
  description = "Sandbox test client instance ID for SSM dig"
  value       = module.test_client.instance_id
}

output "peering_connection_id" {
  description = "Peering connection ID for network to accept (per-account); empty in central"
  value       = try(module.peering[0].peering_connection_id, "")
}

output "resolver_endpoint_id" {
  description = "Sandbox outbound endpoint ID (per-account); empty in central"
  value       = try(module.resolver_outbound[0].resolver_endpoint_id, "")
}

output "eni_count" {
  description = "Outbound endpoint ENI count in this account (0 in central)"
  value       = try(module.resolver_outbound[0].eni_count, 0)
}

output "outbound_pattern" {
  description = "Active outbound pattern"
  value       = var.outbound_pattern
}
