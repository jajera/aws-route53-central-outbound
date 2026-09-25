# Central Route 53 outbound DNS

Cost and design of **central versus per-account** Route 53 Resolver outbound endpoints, with a multi-account Terraform demo and a working BIND zone in the network account.

**Live site:** [aws-route53-central-outbound.johna.kiwi](https://aws-route53-central-outbound.johna.kiwi/)

## At a glance

| Pattern (3 VPCs) | Endpoints | ENIs | Monthly endpoint cost\* |
| --- | ---: | ---: | ---: |
| Per-account | 3 | 6 | $547.50 |
| Central | 1 | 2 | $182.50 |

\*At $0.125/ENI/hour × 730 hours ([Route 53 pricing](https://aws.amazon.com/route53/pricing/), retrieved 26 September 2026). Details: [docs/cost.md](docs/cost.md).

## Repository layout

| Path | Purpose |
| --- | --- |
| [docs/](docs/) | Zensical explainer site |
| [terraform/](terraform/) | Multi-account lab — see [terraform/README.md](terraform/README.md) |

AWS CLI profiles: **`network`**, **`dev`**, **`sandbox`**.

## Preview the site locally

```bash
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
.venv/bin/zensical serve
```

Open the URL printed by the server (usually `http://127.0.0.1:8000`). Push to `main` deploys GitHub Pages.

## Run the demo

1. [terraform/README.md](terraform/README.md) — layout, variables, optional pattern switch, modules
2. [docs/demo/](docs/demo/) — central walkthrough (hub → spokes → dig → teardown)

**Cost warning:** outbound endpoints are billed per ENI-hour. Destroy when finished (spokes first, then network).

## Agent / Kiro context

Read [AGENTS.md](AGENTS.md) and `.kiro/steering/` before changing docs or Terraform.
Mutation guard: `R53_OUTBOUND_ALLOW_AWS=1`.

## What this does not do

- Route 53 Profiles, inbound endpoints, or DNS Firewall
- Multi-region or Transit Gateway
- Remote state or CI-driven `terraform apply`
