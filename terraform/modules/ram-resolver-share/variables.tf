variable "name" {
  type        = string
  description = "Name of the RAM resource share"
}

variable "resolver_rules" {
  type        = map(string)
  description = "Map of static keys to Resolver FORWARD rule ARNs (keys must be known at plan time)"
}

variable "principal_account_ids" {
  type        = list(string)
  description = "AWS account IDs to share the rules with"
}

variable "allow_external_principals" {
  type        = bool
  default     = false
  description = "Allow principals outside the organization"
}
