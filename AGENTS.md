# Agent Context

Zensical explainer + multi-account Terraform demo for **central versus per-account Route 53
Resolver outbound** — cost and design when many VPCs resolve a corporate DNS zone —
published at [aws-route53-central-outbound.johna.kiwi](https://aws-route53-central-outbound.johna.kiwi/).

## Read these first

Kiro loads `.kiro/steering/` automatically; other agents should read them directly.

| File                                | When it applies                         | What it covers                                |
| --- | --- | --- |
| `.kiro/steering/product.md`         | always                                  | Story, scope, non-goals, visual bias          |
| `.kiro/steering/tech.md`            | always                                  | Stack, commands, Terraform, CI                |
| `.kiro/steering/structure.md`       | always                                  | Layout, reading order, naming                 |
| `.kiro/steering/aws-source-lock.md` | always                                  | **Citation rules, verified facts, open TBDs** |
| `.kiro/steering/docs-pattern.md`    | `docs/**`                               | Page shapes, Patterns story arc               |
| `.kiro/steering/markdown-tables.md` | `docs/**`                               | GFM table hygiene                             |
| `.kiro/steering/lab-safety.md`      | `terraform/**`, `docs/demo/**`, cost    | Profiles, Region, mutation guard, teardown    |

Profiles: **`network`**, **`dev`**, **`sandbox`**. Region: **`ap-southeast-2`**. Start readers
at **Overview**, then **Patterns** (the comparison).

## Non-negotiables

1. **Cite AWS behaviour.** Do not answer from recall — use the `aws-docs` MCP server and the
   source list in `aws-source-lock.md`. Unsourced claims do not ship.
2. **Never run AWS mutations.** Author the command; the operator runs it. The
   `guard-aws-mutations` hook blocks mutating AWS CLI and IaC commands from shell tools unless
   `R53_OUTBOUND_ALLOW_AWS=1`.
3. **Mark unverified work.** Nothing is "verified" until the evidence pass runs it in an
   account. Demo `dig` expectations stay unmarked until then.
4. **Prefer visuals.** Diagrams, tables, and short numbered steps over paragraphs. Patterns
   keeps a continuous story; diagrams illustrate beats.
5. **Respect reading order.** Overview → Patterns → Design → Cost → Demo → References.
   Patterns is the comparison; Design is the path deep-dive — do not swap them.

## Facts that trip people up

- Outbound endpoints need **at least two ENIs** (different AZs). That is the cost lever.
- Multiple domains = multiple FORWARD rules on the **same** endpoint — not one endpoint per zone.
  This lab uses two: `corp.demo.internal` and `100.0.10.in-addr.arpa` (PTR).
- Resolver endpoints and rules are **regional** — one hub does not cover another region.
- Central shares the **rule** via RAM, not the endpoint. Query charges land on the
  **endpoint owner** (network).
- With Organizations + RAM org sharing, shares often **auto-accept**; an explicit accepter can
  fail in that mode (`ram_share_accept_required`).
- One VPC: central is **not cheaper** — same two ENIs, plus unused RAM. Benefit starts at
  **two** VPCs that need the same zone.
- Per-account needs a **path to the DNS IP** (peering / TGW / VPN). Central spokes do not —
  Resolver hands the query to the hub endpoint.
- Zone name: `corp.demo.internal` (`.internal`, not `.local`). BIND IP is fixed at `10.0.0.10`.

The complete list, with sources, is in `.kiro/steering/aws-source-lock.md`.

## Plan of record

`.kiro/specs/aws-route53-central-outbound/` holds `requirements.md`, `design.md`, and
`tasks.md`. Work the phases in order; the evidence pass is deliberately last.

## Validation

```bash
.venv/bin/zensical build
(cd terraform/accounts/network && terraform fmt -check && terraform validate)
(cd terraform/accounts/dev && terraform fmt -check && terraform validate)
(cd terraform/accounts/sandbox && terraform fmt -check && terraform validate)
```

## Diagrams and icons

- AWS service icons — <https://johna.kiwi/aws-icons/>
- Generic architecture icons — <https://johna.kiwi/arch-icons/>
- Mermaid scratchpad — <https://johna.kiwi/mermaid-diagram-editor/>
