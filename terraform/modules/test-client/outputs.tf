output "instance_id" {
  description = "Test client EC2 instance ID for SSM"
  value       = aws_instance.this.id
}

output "private_ip" {
  description = "Test client private IP"
  value       = aws_instance.this.private_ip
}
