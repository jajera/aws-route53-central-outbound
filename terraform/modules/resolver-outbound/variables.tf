variable "name_prefix" {
  type        = string
  description = "Naming prefix for all resources"
}

variable "vpc_id" {
  type        = string
  description = "VPC for the outbound endpoint security group"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Exactly two subnet IDs in different AZs for the outbound endpoint"

  validation {
    condition     = length(var.subnet_ids) == 2
    error_message = "Outbound endpoints require exactly two subnet IDs in different AZs."
  }
}

variable "target_cidr_blocks" {
  type        = list(string)
  description = "CIDRs allowed for DNS egress from the outbound endpoint"
  default     = ["10.0.0.0/8"]
}
