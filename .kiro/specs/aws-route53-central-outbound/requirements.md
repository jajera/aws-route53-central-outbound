# Requirements — aws-route53-central-outbound

## Goal

Explain and demonstrate **per-account vs central** Route 53 Resolver outbound for multi-account
corporate DNS forwarding, with cost as a first-class outcome.

## Must

1. Zensical site: Overview → Patterns → Design → Cost → Demo → References.
2. Patterns tells the one-VPC → two-VPC story (central earns RAM at two+).
3. Terraform roots for `network`, `dev`, `sandbox` with `outbound_pattern`.
4. Working BIND zone `corp.demo.internal` in network; SSM + dig verification path documented.
5. Central shares rules via AWS RAM; per-account uses peering to reach BIND.
6. Cost page separates pattern ENI delta from demo overhead; cites Route 53 pricing with date.
7. Agents do not apply/destroy without `R53_OUTBOUND_ALLOW_AWS=1`.

## Must not (v1)

- Route 53 Profiles, inbound endpoints, DNS Firewall as demo features.
- Multi-region hubs.
- CI-driven terraform apply.
- Hardcoded live account IDs in committed files.
