variable "name_prefix" {
  type        = string
  description = "Naming prefix for all resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC for the security group"
}

variable "subnet_id" {
  type        = string
  description = "Private subnet for the test client"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t4g.nano"
}
