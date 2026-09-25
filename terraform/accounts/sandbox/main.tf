data "aws_caller_identity" "current" {}

locals {
  name_prefix    = "${var.project_name}-sandbox"
  is_central     = var.outbound_pattern == "central"
  is_per_account = var.outbound_pattern == "per-account"
}

module "vpc" {
  source = "../../modules/vpc"

  name_prefix = local.name_prefix
  cidr_block  = var.vpc_cidr
  aws_region  = var.aws_region
}

module "test_client" {
  source = "../../modules/test-client"

  name_prefix = local.name_prefix
  vpc_id      = module.vpc.vpc_id
  subnet_id   = module.vpc.private_subnet_ids[0]
}

# --- central: associate the RAM-shared rule from network ---

resource "aws_ram_resource_share_accepter" "resolver_rule" {
  count = local.is_central && var.ram_share_accept_required ? 1 : 0

  share_arn = var.ram_share_arn
}

resource "aws_route53_resolver_rule_association" "shared" {
  count = local.is_central ? 1 : 0

  resolver_rule_id = var.shared_resolver_rule_id
  vpc_id           = module.vpc.vpc_id
  name             = "${local.name_prefix}-shared-corp"

  depends_on = [aws_ram_resource_share_accepter.resolver_rule]
}

resource "aws_route53_resolver_rule_association" "shared_reverse" {
  count = local.is_central ? 1 : 0

  resolver_rule_id = var.shared_reverse_resolver_rule_id
  vpc_id           = module.vpc.vpc_id
  name             = "${local.name_prefix}-shared-corp-rev"

  depends_on = [aws_ram_resource_share_accepter.resolver_rule]
}

# --- per-account: own outbound endpoint + rule + peering to network ---

module "resolver_outbound" {
  count  = local.is_per_account ? 1 : 0
  source = "../../modules/resolver-outbound"

  name_prefix        = local.name_prefix
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.private_subnet_ids
  target_cidr_blocks = [var.network_vpc_cidr]
}

module "forward_rule" {
  count  = local.is_per_account ? 1 : 0
  source = "../../modules/resolver-forward-rule"

  name                 = "${local.name_prefix}-corp"
  domain_name          = var.zone_name
  resolver_endpoint_id = module.resolver_outbound[0].resolver_endpoint_id
  target_ips           = [var.dns_server_ip]
  vpc_ids              = [module.vpc.vpc_id]
}

module "reverse_forward_rule" {
  count  = local.is_per_account ? 1 : 0
  source = "../../modules/resolver-forward-rule"

  name                 = "${local.name_prefix}-corp-rev"
  domain_name          = var.reverse_zone_name
  resolver_endpoint_id = module.resolver_outbound[0].resolver_endpoint_id
  target_ips           = [var.dns_server_ip]
  vpc_ids              = [module.vpc.vpc_id]
}

module "peering" {
  count  = local.is_per_account ? 1 : 0
  source = "../../modules/vpc-peering-requester"

  name            = "${local.name_prefix}-to-network"
  vpc_id          = module.vpc.vpc_id
  peer_vpc_id     = var.network_vpc_id
  peer_owner_id   = var.network_account_id
  peer_region     = var.aws_region
  peer_cidr_block = var.network_vpc_cidr
  route_table_id  = module.vpc.private_route_table_id
}
