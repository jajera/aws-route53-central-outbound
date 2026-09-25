output "instance_id" {
  description = "DNS server EC2 instance ID"
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "Fixed private IP of the DNS server"
  value       = aws_instance.this.private_ip
}

output "security_group_id" {
  description = "DNS server security group ID"
  value       = aws_security_group.this.id
}

output "zone_name" {
  description = "Authoritative forward zone name"
  value       = var.zone_name
}

output "reverse_zone_name" {
  description = "Authoritative reverse zone name (in-addr.arpa)"
  value       = local.reverse_zone_name
}
