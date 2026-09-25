variable "name" {
  type        = string
  description = "Name tag for the peering connection"
}

variable "vpc_id" {
  type        = string
  description = "Requester VPC ID"
}

variable "peer_vpc_id" {
  type        = string
  description = "Accepter VPC ID (network account)"
}

variable "peer_owner_id" {
  type        = string
  description = "AWS account ID that owns the peer VPC"
}

variable "peer_region" {
  type        = string
  description = "Region of the peer VPC"
}

variable "peer_cidr_block" {
  type        = string
  description = "CIDR of the peer VPC for the route"
}

variable "route_table_id" {
  type        = string
  description = "Requester private route table to add the peer route"
}
