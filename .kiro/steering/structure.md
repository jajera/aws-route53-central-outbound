---
inclusion: always
---

# Structure

## Layout

```plaintext
.github/workflows/          # docs, terraform-validate, markdown-lint, commitmsg, auto-merge
.kiro/
  settings/mcp.json
  steering/
  hooks/
  specs/aws-route53-central-outbound/
docs/
  index.md                  # Overview
  patterns.md               # comparison story (after Overview)
  design.md
  cost.md
  demo/                     # walkthrough (index + phased pages)
  assets/ stylesheets/
overrides/main.html
terraform/
  modules/                  # vpc, dns-server, test-client, resolver-*, ram-*, vpc-peering-requester
  accounts/{network,dev,sandbox}/
zensical.toml
AGENTS.md
```

## Page rules

- Reading order: **Overview → Patterns → Design → Cost → Demo → References** (must match `zensical.toml` nav).
- One job per page. Prefer visuals; Patterns keeps a continuous story.
- AWS behavioural claims need a source (see `aws-source-lock.md`).
- Cost rates: cite [Route 53 pricing](https://aws.amazon.com/route53/pricing/) with retrieval date;
  do not invent region-specific Resolver ENI prices without a source.
- Internal links in Zensical: relative (`design.md`) or site paths (`design/`).

## Naming

| Item | Value |
| --- | --- |
| Project tag | `r53-central-outbound` / `Project=r53-central-outbound` |
| Zone | `corp.demo.internal` |
| BIND IP | `10.0.0.10` (fixed) |
| CIDRs | network `10.0.0.0/16`, dev `10.1.0.0/16`, sandbox `10.2.0.0/16` |
| Pattern tag | `Pattern=central\|per-account` |
