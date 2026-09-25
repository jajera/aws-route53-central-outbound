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
  description = "Private subnet for the DNS server"
}

variable "private_ip" {
  type        = string
  description = "Fixed private IP so Resolver target IPs survive instance replacement"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t4g.nano"
}

variable "zone_name" {
  type        = string
  description = "Authoritative zone name (for example corp.demo.internal)"
  default     = "corp.demo.internal"
}

variable "zone_records" {
  type        = map(string)
  description = "Relative record name to A record IP"
  default = {
    app = "10.0.100.10"
    db  = "10.0.100.20"
  }
}

variable "soa_serial" {
  type        = number
  description = "SOA serial (YYYYMMDDNN). Bump when baking new zone content into user_data."
  default     = 2026092602
}

variable "allowed_cidr_blocks" {
  type        = list(string)
  description = "CIDRs allowed to query DNS (hub plus peered spokes); also used in named allow-query"
  default     = ["10.0.0.0/8"]
}

variable "allowed_security_group_ids" {
  type        = list(string)
  description = "Security groups allowed to query DNS (outbound endpoint SG)"
  default     = []
}
