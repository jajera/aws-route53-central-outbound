output "resource_share_arn" {
  description = "RAM resource share ARN"
  value       = aws_ram_resource_share.this.arn
}

output "resource_share_id" {
  description = "RAM resource share ID"
  value       = aws_ram_resource_share.this.id
}
