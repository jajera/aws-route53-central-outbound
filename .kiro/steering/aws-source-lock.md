---
inclusion: always
---

# AWS source lock

Model training data about Route 53 Resolver can be incomplete or stale, so **every AWS
behavioural claim in this repository must trace to a source below**. If a claim is not in a
source and not verified in an account, it does not ship as fact.

## Canonical sources

| Topic | Source |
| --- | --- |
| Route 53 Resolver | https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver.html |
| Forwarding rules | https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-rules-managing.html |
| Rule domain-name matching (most specific wins) | https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-overview-forward-vpc-to-network-domain-name-matches.html |
| Outbound endpoints | https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-forwarding-outbound-queries.html |
| Configure outbound (endpoint + one or more rules) | https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-forwarding-outbound-queries-configuring.html |
| Sharing rules with RAM | https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-rules-managing.html#resolver-rules-sharing |
| AWS RAM | https://docs.aws.amazon.com/ram/latest/userguide/what-is.html |
| Route 53 pricing | https://aws.amazon.com/route53/pricing/ |
| VPC peering | https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html |
| Session Manager | https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html |
| Interface VPC endpoints | https://docs.aws.amazon.com/vpc/latest/privatelink/vpce-interface.html |

Use the `aws-docs` MCP server (or the deploy-on-aws knowledge tools) to re-read these rather than
recalling them.

## Verified facts (safe to state from public docs)

1. An outbound Resolver endpoint requires **at least two IP addresses** (ENIs) in different AZs.
2. Outbound endpoints are billed **per ENI-hour** (public pricing table: **$0.125** per ENI per
   hour as of the retrieval date recorded in `docs/cost.md`).
3. Queries that pass through a Resolver endpoint are billed per million (public table: **$0.40**
   / million for the first 1B/month, then **$0.20**).
4. Resolver endpoints and rules are **regional**.
5. Forwarding rules can be shared across accounts with **AWS RAM** and associated to VPCs in
   consumer accounts.
6. With AWS Organizations and RAM org sharing enabled, shares typically **auto-accept**; an
   explicit accepter can fail in that mode.
7. Query charges for traffic through an endpoint land on the **endpoint-owning account**.
8. When a query matches more than one forwarding rule, VPC Resolver uses the rule with the
   **most specific domain name** (exact or subdomain match).
9. One outbound endpoint can serve **multiple FORWARD rules** (multiple domain names / target
   sets). A second domain does not require a second endpoint. This lab shares both
   `corp.demo.internal` and `100.0.10.in-addr.arpa` on one hub endpoint.

## Lab evidence — status

Central pattern evidence pass (26 September 2026): `terraform apply` on `network` /
`dev` / `sandbox`, then SSM `dig +short` on each dig client returned
`10.0.100.10` / `10.0.100.20` for `app` / `db.corp.demo.internal`, and
`dig +short -x` returned the matching PTRs. See `docs/demo/verify.md`. The public
demo walkthrough is central-only (no pattern switch step).

## Open TBDs

- Re-pull Resolver ENI/query rates from the Price List API when credentials allow (public
  Route 53 table used for those in v1). Demo overhead (`t4g.nano`, interface VPCE) for
  `ap-southeast-2` was pulled from the public offer index on 26 September 2026 — see
  `docs/cost.md`.
