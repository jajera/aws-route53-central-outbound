---
icon: lucide/network
---

<div class="patina-hero" markdown>

<p class="patina-kicker">Route 53 · September 2026</p>

# Central Route 53 outbound DNS

<p class="patina-lede">
  When VPCs need to resolve a corporate or on-premises DNS zone, each account
  can run its own Resolver <strong>outbound endpoint</strong>, or a
  <strong>network</strong> account can own one shared endpoint and share the
  forwarding rule with AWS RAM. With a single VPC the bill is the same; from
  the <strong>second VPC</strong> onward, central usually costs less because
  endpoints are priced per ENI-hour.
</p>

<div class="patina-actions">
<a class="patina-btn patina-btn--primary" href="patterns/">Compare the patterns</a>
<a class="patina-btn patina-btn--ghost" href="cost/">See the cost model</a>
</div>

</div>

## At a glance

| Pattern | Outbound endpoints (3 VPCs) | ENIs | Rule sharing | Monthly endpoint cost\* |
| --- | --- | --- | --- | --- |
| Per-account | 3 | 6 | None | **$547.50** |
| Central | 1 | 2 | AWS RAM | **$182.50** |

\*ENI-hours only, at $0.125/ENI/hour × 730 hours. At **one** VPC both patterns are ~$182.50 — the gap opens at two. Query charges: [Cost](cost.md).

![Per-account vs central Route 53 Resolver outbound for three VPCs](assets/diagrams/per-account-vs-central.svg)

<p class="diagram-caption">Same zone, same queries — the bill difference is mostly ENI-hours. How that gap appears as you grow: <a href="patterns/">Patterns</a>.</p>

## Why this matters

<div class="path-grid">
  <a class="path-card" href="patterns/">
    <span class="path-card__label">Patterns</span>
    <strong>One VPC ≈ standalone; two starts the win</strong>
    <p>Central adds RAM you do not need for a single VPC. The second VPC is where half the ENIs — and the savings — show up.</p>
    <span class="path-card__meta">the comparison</span>
  </a>
  <a class="path-card" href="design/">
    <span class="path-card__label">Design</span>
    <strong>How the query path works</strong>
    <p>RAM-shared FORWARD rules, hub ENIs, and why spokes need no network path to the DNS IP under central.</p>
    <span class="path-card__meta">RAM + Resolver</span>
  </a>
  <a class="path-card" href="cost/">
    <span class="path-card__label">Cost</span>
    <strong>ENI-hours are the lever</strong>
    <p>Each outbound endpoint needs two ENIs at $0.125/hour. Three accounts pay for six; a hub pays for two — same query volume either way.</p>
    <span class="path-card__meta">$547 vs $182</span>
  </a>
  <a class="path-card" href="demo/">
    <span class="path-card__label">Demo</span>
    <strong>Apply, dig, tear down</strong>
    <p>Three accounts (<code>network</code>, <code>dev</code>, <code>sandbox</code>) in <code>ap-southeast-2</code>. BIND serves <code>corp.demo.internal</code> (and reverse); apply central, dig A + PTR, tear down.</p>
    <span class="path-card__meta">Terraform demo</span>
  </a>
</div>

## What this does not do

- **Cover Route 53 Profiles.** Profiles suit complex corporate DNS sharing, but they add their own hourly cost — out of scope here; this demo uses classic Resolver rules + RAM.
- **Build multi-region.** Comparison is one region; production central still needs a hub per region (noted in [Cost](cost.md)).
- **Include Resolver DNS Firewall.** Filtering and managed domain lists are a separate cost and control plane — out of scope.

## Contents

1. [Patterns](patterns.md) — one VPC vs two+, when central pays off
2. [Design](design.md) — request path, RAM behaviour, regional scope, chargeback
3. [Cost](cost.md) — assumptions, formula, scaling table, demo overhead
4. [Demo](demo/index.md) — phased apply, dig checks, teardown
5. [References](references.md) — AWS docs and posts this site builds on

!!! note "Relation to AWS documentation"
    Builds on the [Route 53 Resolver](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver.html)
    guide and [pricing](https://aws.amazon.com/route53/pricing/) with a
    multi-account cost comparison and a runnable demo under `terraform/accounts/`.
    Full source list: [References](references.md).
