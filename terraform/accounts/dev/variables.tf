variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "ap-southeast-2"
}

variable "aws_profile" {
  type        = string
  description = "AWS CLI profile for the dev account"
  default     = "dev"
}

variable "project_name" {
  type        = string
  description = "Project tag value"
  default     = "r53-central-outbound"
}

variable "outbound_pattern" {
  type        = string
  description = "Outbound pattern: central or per-account"

  validation {
    condition     = contains(["central", "per-account"], var.outbound_pattern)
    error_message = "outbound_pattern must be central or per-account."
  }
}

variable "vpc_cidr" {
  type        = string
  description = "Dev VPC CIDR"
  default     = "10.1.0.0/16"
}

variable "zone_name" {
  type        = string
  description = "Domain forwarded to BIND"
  default     = "corp.demo.internal"
}

variable "reverse_zone_name" {
  type        = string
  description = "Reverse zone forwarded to BIND (per-account); match network reverse_zone_name"
  default     = "100.0.10.in-addr.arpa"
}

variable "network_account_id" {
  type        = string
  description = "Network account ID (peering peer owner)"
  default     = ""

  validation {
    condition = (
      var.outbound_pattern != "per-account" ||
      length(var.network_account_id) > 0
    )
    error_message = "per-account requires network_account_id."
  }
}

variable "network_vpc_id" {
  type        = string
  description = "Network VPC ID for peering (per-account)"
  default     = ""

  validation {
    condition = (
      var.outbound_pattern != "per-account" ||
      length(var.network_vpc_id) > 0
    )
    error_message = "per-account requires network_vpc_id."
  }
}

variable "network_vpc_cidr" {
  type        = string
  description = "Network VPC CIDR for peering route (per-account)"
  default     = "10.0.0.0/16"
}

variable "dns_server_ip" {
  type        = string
  description = "BIND private IP in the network account (per-account target)"
  default     = ""

  validation {
    condition = (
      var.outbound_pattern != "per-account" ||
      length(var.dns_server_ip) > 0
    )
    error_message = "per-account requires dns_server_ip."
  }
}

variable "shared_resolver_rule_id" {
  type        = string
  description = "Forward-zone Resolver rule ID shared from network via RAM (central)"
  default     = ""

  validation {
    condition = (
      var.outbound_pattern != "central" ||
      length(var.shared_resolver_rule_id) > 0
    )
    error_message = "central requires shared_resolver_rule_id from network outputs."
  }
}

variable "shared_reverse_resolver_rule_id" {
  type        = string
  description = "Reverse-zone Resolver rule ID shared from network via RAM (central)"
  default     = ""

  validation {
    condition = (
      var.outbound_pattern != "central" ||
      length(var.shared_reverse_resolver_rule_id) > 0
    )
    error_message = "central requires shared_reverse_resolver_rule_id from network outputs."
  }
}

variable "ram_share_accept_required" {
  type        = bool
  description = "Set true when accounts are not in an org with RAM auto-accept"
  default     = false
}

variable "ram_share_arn" {
  type        = string
  description = "RAM resource share ARN to accept when ram_share_accept_required is true"
  default     = ""

  validation {
    condition = (
      !var.ram_share_accept_required ||
      length(var.ram_share_arn) > 0
    )
    error_message = "ram_share_accept_required=true needs ram_share_arn."
  }
}
