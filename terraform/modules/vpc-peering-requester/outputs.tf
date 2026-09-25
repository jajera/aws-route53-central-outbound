output "peering_connection_id" {
  description = "VPC peering connection ID for the network account to accept"
  value       = aws_vpc_peering_connection.this.id
}
