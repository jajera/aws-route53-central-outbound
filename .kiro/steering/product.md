---
inclusion: always
---

# Product

`aws-route53-central-outbound` publishes a Zensical explainer plus a multi-account Terraform demo
for **central versus per-account Route 53 Resolver outbound** — cost and design when many VPCs
need to resolve a corporate DNS zone.

## The story

Start with one VPC: an outbound endpoint is almost a standalone resolver. Central adds RAM and
hub ownership you do not need yet. The moment a second VPC needs the same zone, central halves
the ENIs and the monthly endpoint bill starts to drop. Scale that to many accounts.

```text
Per-account                         Central

VPC1 ── ENIs ──┐                    VPC1 ──┐
               ├──► corporate DNS          ├── rule (RAM) ──► Hub ENIs ──► DNS
VPC2 ── ENIs ──┘                    VPC2 ──┘
```

## Audience

Engineers who already know Route 53 basics and want a clear cost/design comparison before they
centralise outbound DNS in a network account.

## Shape of the project

- **Zensical + Patina** docs site under `docs/`.
- **Terraform** under `terraform/accounts/{network,dev,sandbox}` with
  `outbound_pattern = "central" | "per-account"`.
- Profiles **`network`**, **`dev`**, **`sandbox`**; Region **`ap-southeast-2`**.
- Mutation guard: `R53_OUTBOUND_ALLOW_AWS=1`.
- Live site: `https://aws-route53-central-outbound.johna.kiwi/`.

## In scope

- Patterns story (one VPC → two → many), design (request path, RAM), cost tables, phased demo
  with BIND in network and SSM + `dig`.
- Supporting modules: VPC, DNS server, test client, Resolver outbound/rules, RAM share, peering.

## Out of scope (v1)

- Route 53 Profiles (corporate-friendly, own hourly cost).
- Multi-region hubs, inbound endpoints, DNS Firewall.
- Transit Gateway as the primary path (peering stands in for per-account reachability).
- Remote state, CI-driven `terraform apply`.

## Visual bias

Prefer diagrams (ASCII or Mermaid), tables, and short numbered steps over long prose.
Story pages (especially Patterns) keep a continuous narrative; diagrams illustrate beats.
