data "aws_caller_identity" "current" {}

locals {
  name_prefix    = "${var.project_name}-network"
  is_central     = var.outbound_pattern == "central"
  is_per_account = var.outbound_pattern == "per-account"

  bind_allowed_cidrs = concat(
    [var.vpc_cidr],
    [for peer in var.spoke_peers : peer.cidr]
  )
}

module "vpc" {
  source = "../../modules/vpc"

  name_prefix = local.name_prefix
  cidr_block  = var.vpc_cidr
  aws_region  = var.aws_region
}

module "resolver_outbound" {
  source = "../../modules/resolver-outbound"

  name_prefix        = local.name_prefix
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  target_cidr_blocks = [var.vpc_cidr]
}

module "dns_server" {
  source = "../../modules/dns-server"

  name_prefix                = local.name_prefix
  vpc_id                     = module.vpc.vpc_id
  subnet_id                  = module.vpc.private_subnet_ids[0]
  private_ip                 = var.dns_server_private_ip
  zone_name                  = var.zone_name
  zone_records               = var.zone_records
  allowed_cidr_blocks        = local.bind_allowed_cidrs
  allowed_security_group_ids = [module.resolver_outbound.security_group_id]
}

module "forward_rule" {
  source = "../../modules/resolver-forward-rule"

  name                 = "${local.name_prefix}-corp"
  domain_name          = var.zone_name
  resolver_endpoint_id = module.resolver_outbound.resolver_endpoint_id
  target_ips           = [module.dns_server.private_ip]
  vpc_ids              = [module.vpc.vpc_id]
}

module "reverse_forward_rule" {
  source = "../../modules/resolver-forward-rule"

  name                 = "${local.name_prefix}-corp-rev"
  domain_name          = module.dns_server.reverse_zone_name
  resolver_endpoint_id = module.resolver_outbound.resolver_endpoint_id
  target_ips           = [module.dns_server.private_ip]
  vpc_ids              = [module.vpc.vpc_id]
}

module "ram_share" {
  count  = local.is_central ? 1 : 0
  source = "../../modules/ram-resolver-share"

  name = "${local.name_prefix}-corp-rules"
  resolver_rules = {
    forward = module.forward_rule.resolver_rule_arn
    reverse = module.reverse_forward_rule.resolver_rule_arn
  }
  principal_account_ids = var.workload_account_ids
}

module "test_client" {
  source = "../../modules/test-client"

  name_prefix = local.name_prefix
  vpc_id      = module.vpc.vpc_id
  subnet_id   = module.vpc.private_subnet_ids[0]
}

resource "aws_vpc_peering_connection_accepter" "spoke" {
  for_each = local.is_per_account ? var.spoke_peers : {}

  vpc_peering_connection_id = each.value.peering_connection_id
  auto_accept               = true

  tags = {
    Name = "${local.name_prefix}-peer-${each.key}"
  }
}

resource "aws_route" "to_spoke" {
  for_each = local.is_per_account ? var.spoke_peers : {}

  route_table_id            = module.vpc.private_route_table_id
  destination_cidr_block    = each.value.cidr
  vpc_peering_connection_id = each.value.peering_connection_id

  depends_on = [aws_vpc_peering_connection_accepter.spoke]
}
