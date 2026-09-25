variable "name" {
  type        = string
  description = "Name for the Resolver rule"
}

variable "domain_name" {
  type        = string
  description = "Domain to forward (for example corp.demo.internal)"
}

variable "resolver_endpoint_id" {
  type        = string
  description = "Outbound endpoint that forwards the queries"
}

variable "target_ips" {
  type        = list(string)
  description = "DNS server IPs to forward to"
}

variable "vpc_ids" {
  type        = list(string)
  description = "VPCs in this account to associate with the rule"
  default     = []
}
