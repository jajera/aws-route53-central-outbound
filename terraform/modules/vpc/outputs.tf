output "vpc_id" {
  description = "VPC identifier"
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = aws_vpc.this.cidr_block
}

output "private_subnet_ids" {
  description = "IDs of the two private subnets"
  value       = aws_subnet.private[*].id
}

output "private_route_table_id" {
  description = "Private route table ID (for peering routes)"
  value       = aws_route_table.private.id
}

output "ssm_vpc_endpoints_enabled" {
  description = "Whether SSM interface VPC endpoints were created"
  value       = var.enable_ssm_vpc_endpoints
}
