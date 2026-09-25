variable "name_prefix" {
  type        = string
  description = "Naming prefix for all resources"
}

variable "cidr_block" {
  type        = string
  description = "VPC CIDR (for example 10.0.0.0/16)"
}

variable "aws_region" {
  type        = string
  description = "AWS region for AZ and endpoint service names"
}

variable "enable_ssm_vpc_endpoints" {
  type        = bool
  default     = true
  description = "Create SSM interface VPC endpoints (one AZ) so Session Manager works without NAT"
}

variable "enable_s3_gateway_endpoint" {
  type        = bool
  default     = true
  description = "Create an S3 gateway endpoint so AL2023 packages install without NAT"
}
