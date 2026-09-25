# Terraform — multi-account Resolver outbound lab

Three account roots compare **central** vs **per-account** Route 53 Resolver
outbound for the same corporate zone. BIND in **network** stands in for
on-prem / corporate DNS.

Operator walkthrough (dig, SSM, teardown): [docs/demo/](../docs/demo/).  
Cost model: [docs/cost.md](../docs/cost.md).  
Query path: [docs/design.md](../docs/design.md).

**You run apply/destroy.** Agents author commands only unless
`R53_OUTBOUND_ALLOW_AWS=1`.

## Layout

```text
terraform/
├── README.md                 ← this file
├── modules/
│   ├── vpc/                  # private VPC, 2 AZ subnets, SSM (1 AZ) + S3 GW
│   ├── dns-server/           # BIND on t4g.nano at fixed private IP
│   ├── test-client/          # dig client via SSM
│   ├── resolver-outbound/    # outbound endpoint (2 ENIs) + DNS egress SG
│   ├── resolver-forward-rule/# FORWARD rule + optional VPC associations
│   ├── ram-resolver-share/   # share rule ARN to spoke accounts
│   └── vpc-peering-requester/# cross-account peering request + requester route
└── accounts/
    ├── network/              # hub: BIND + outbound + rule (+ RAM or accept peers)
    ├── dev/                  # spoke 10.1.0.0/16
    └── sandbox/              # spoke 10.2.0.0/16
```

Each `accounts/*` root has its own state (local). Do not commit
`terraform.tfvars` or `*.tfstate*`.

## Prerequisites

| Item | Value |
| --- | --- |
| Terraform | `>= 1.5.0` |
| AWS provider | `hashicorp/aws` `~> 6.66` (lockfile selects current 6.66.x; Dependabot bumps) |
| CLI profiles | `network`, `dev`, `sandbox` |
| Region | `ap-southeast-2` |
| Org RAM sharing | Enabled for central (`aws ram enable-sharing-with-aws-organization` from management) |

## Lab constants

| Constant | Value |
| --- | --- |
| Network CIDR | `10.0.0.0/16` |
| Dev CIDR | `10.1.0.0/16` |
| Sandbox CIDR | `10.2.0.0/16` |
| BIND IP | `10.0.0.10` |
| Zone | `corp.demo.internal` (+ reverse `100.0.10.in-addr.arpa`) |
| Records | `app` → `10.0.100.10`, `db` → `10.0.100.20` (synthetic A records) |

No NAT / IGW. Session Manager uses interface VPC endpoints in **one** AZ
(`ssm`, `ssmmessages`, `ec2messages`). S3 gateway endpoint covers package
install.

## `outbound_pattern` behaviour

| | `central` | `per-account` |
| --- | --- | --- |
| **network** | Outbound + FORWARD + **RAM share** to `workload_account_ids` | Outbound + FORWARD + **accept** `spoke_peers` + return routes + BIND ingress for spoke CIDRs |
| **dev / sandbox** | Associate shared rules (`shared_resolver_rule_id` + `shared_reverse_resolver_rule_id`); no spoke endpoint | Own outbound + FORWARD (+ reverse) + peering **request** to network |

### Hub outbound is always on

`accounts/network` always creates the outbound endpoint and **two** FORWARD rules
(forward + reverse) in both patterns, then shares both via one RAM share when
central. Switching to per-account does **not** remove the hub’s two ENIs —
spokes add their own. That is why the 3-VPC per-account bill is six ENIs
(`2 × 3`), matching [docs/cost.md](../docs/cost.md).

## Apply order (start central)

1. **network** — set `outbound_pattern = "central"` and
   `workload_account_ids = ["<dev>", "<sandbox>"]`, then apply.
2. **dev** and **sandbox** — set `shared_resolver_rule_id` and
   `shared_reverse_resolver_rule_id` from network outputs, then apply.
3. Verify with dig (see [docs/demo/verify.md](../docs/demo/verify.md)).

```bash
cd terraform/accounts/network
cp terraform.tfvars.example terraform.tfvars
# edit tfvars, then:
terraform init
terraform apply
```

Repeat under `dev` and `sandbox`.

### Outputs to copy (network → spokes)

| Network output | Spoke variable (central) | Spoke variable (per-account) |
| --- | --- | --- |
| `resolver_rule_id` | `shared_resolver_rule_id` | — |
| `reverse_resolver_rule_id` | `shared_reverse_resolver_rule_id` | — |
| `ram_share_arn` | `ram_share_arn` (only if accept required) | — |
| `account_id` | — | `network_account_id` |
| `vpc_id` | — | `network_vpc_id` |
| `vpc_cidr` | — | `network_vpc_cidr` |
| `dns_server_ip` | — | `dns_server_ip` |

Spoke → network (per-account): `peering_connection_id` + `vpc_cidr` into
network `spoke_peers`.

## Switch patterns

### To per-account — spokes first, then network

1. Spokes: `outbound_pattern = "per-account"`, fill network_* / `dns_server_ip`,
   clear `shared_resolver_rule_id` and `shared_reverse_resolver_rule_id`, apply.
   Capture `peering_connection_id`.
2. Network: `outbound_pattern = "per-account"`, clear `workload_account_ids`,
   set `spoke_peers`, apply.

### Back to central — network first, then spokes

1. Network: `central`, set `workload_account_ids`, clear `spoke_peers`, apply
   (RAM share must exist before spokes associate).
2. Spokes: `central`, set `shared_resolver_rule_id` and
   `shared_reverse_resolver_rule_id`, clear peering fields, apply.

## Destroy order

```bash
(cd terraform/accounts/dev && terraform destroy)
(cd terraform/accounts/sandbox && terraform destroy)
(cd terraform/accounts/network && terraform destroy)
```

Outbound ENIs are billed while present — destroy when finished.

## Variable reference

### `accounts/network`

| Variable | Notes |
| --- | --- |
| `outbound_pattern` | **Required.** `central` \| `per-account` |
| `workload_account_ids` | **Required when central** (validated) |
| `spoke_peers` | Per-account: map of `{ cidr, peering_connection_id }` |
| `dns_server_private_ip` | Default `10.0.0.10` |
| `zone_name` / `zone_records` | Defaults match lab constants |
| `aws_profile` | Default `network` |

### `accounts/dev` and `accounts/sandbox`

| Variable | Notes |
| --- | --- |
| `outbound_pattern` | **Required** |
| `shared_resolver_rule_id` | **Required when central** (validated) |
| `shared_reverse_resolver_rule_id` | **Required when central** (validated) |
| `ram_share_accept_required` | Default `false` (org auto-accept) |
| `ram_share_arn` | Required if `ram_share_accept_required = true` |
| `network_account_id` / `network_vpc_id` / `dns_server_ip` | **Required when per-account** (validated) |
| `network_vpc_cidr` | Default `10.0.0.0/16` |
| `vpc_cidr` | Dev `10.1.0.0/16`, sandbox `10.2.0.0/16` |

## Modules

| Module | Creates |
| --- | --- |
| `vpc` | VPC, 2 private subnets (different AZs), private RT, optional SSM×3 (1 AZ) + S3 gateway |
| `dns-server` | IAM + SG + AL2023 arm64 EC2; BIND via `user_data.sh.tftpl` (dnf retries, `named-checkconf` / `named-checkzone`, fixed private IP) |
| `test-client` | IAM + SG + dig client (`bind-utils`) |
| `resolver-outbound` | Outbound endpoint on exactly two subnets; SG egress UDP/TCP 53 |
| `resolver-forward-rule` | FORWARD rule; optional associations in the owning account |
| `ram-resolver-share` | Resource share + rule association + principal associations (`allow_external_principals = false`) |
| `vpc-peering-requester` | Peering connection (`auto_accept = false`) + route on requester |

## Networking notes

- **Central:** spokes need no path to `10.0.0.10`. Resolver hands the query to
  the hub endpoint.
- **Per-account:** each spoke outbound ENI must reach BIND — demo uses VPC
  peering (stand-in for TGW/VPN).
- **BIND SG:** hub CIDR always; spoke CIDRs added from `spoke_peers` in
  per-account; also allows the hub outbound endpoint SG.
- **RAM:** with Organizations + RAM org sharing, shares often auto-accept. An
  explicit `aws_ram_resource_share_accepter` can fail in that mode — leave
  `ram_share_accept_required = false` unless invitations stay pending.

## Cost while applied

| Pattern (3 VPCs) | Outbound ENIs | Endpoint ENI-hours / month\* |
| --- | ---: | ---: |
| Central | 2 (hub only) | ~$182.50 |
| Per-account | 6 (hub + 2 spokes) | ~$547.50 |

\*At $0.125/ENI-hour × 730 hours. Lab EC2 + SSM endpoints are extra — see
[docs/cost.md](../docs/cost.md) demo overhead.

## Validate locally

```bash
(cd terraform/accounts/network && terraform fmt -check && terraform validate)
(cd terraform/accounts/dev && terraform fmt -check && terraform validate)
(cd terraform/accounts/sandbox && terraform fmt -check && terraform validate)
```

`validate` needs `terraform init` first. Pattern-gated variables need a
`terraform.tfvars` (or `-var`) that satisfies the active `outbound_pattern`.
