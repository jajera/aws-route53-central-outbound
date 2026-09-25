variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "ap-southeast-2"
}

variable "aws_profile" {
  type        = string
  description = "AWS CLI profile for the network account"
  default     = "network"
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
  description = "Network VPC CIDR"
  default     = "10.0.0.0/16"
}

variable "dns_server_private_ip" {
  type        = string
  description = "Fixed private IP for the BIND server inside the network VPC"
  default     = "10.0.0.10"
}

variable "zone_name" {
  type        = string
  description = "Authoritative zone served by BIND"
  default     = "corp.demo.internal"
}

variable "zone_records" {
  type        = map(string)
  description = "Relative A records in the BIND zone"
  default = {
    app = "10.0.100.10"
    db  = "10.0.100.20"
  }
}

variable "workload_account_ids" {
  type        = list(string)
  description = "Dev and sandbox account IDs for RAM shares (central pattern)"
  default     = []

  validation {
    condition = (
      var.outbound_pattern != "central" ||
      length(var.workload_account_ids) > 0
    )
    error_message = "central requires workload_account_ids (dev and sandbox account IDs)."
  }
}

variable "spoke_peers" {
  type = map(object({
    cidr                  = string
    peering_connection_id = string
  }))
  description = "Per-account only: spoke name to CIDR and peering connection ID to accept"
  default     = {}
}
