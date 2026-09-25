---
inclusion: fileMatch
fileMatchPattern: ["terraform/**", "docs/demo/**", "docs/cost.md"]
---

# Lab safety

This demo creates billable AWS resources (Resolver outbound ENIs, EC2, VPC endpoints).

## Never run AWS mutations unprompted

The agent does not `terraform apply` / `destroy` or create AWS resources on its own. Author the
command; the operator runs it. The `guard-aws-mutations` hook blocks accidental execution unless:

```bash
export R53_OUTBOUND_ALLOW_AWS=1
```

## Conventions

| Convention | Value |
| --- | --- |
| Profiles | `network`, `dev`, `sandbox` |
| Region | `ap-southeast-2` |
| Pattern switch | `outbound_pattern = "central" \| "per-account"` |
| Mutation guard | `R53_OUTBOUND_ALLOW_AWS=1` |
| State | Local; never commit `terraform.tfvars` or `*.tfstate*` |
| Teardown order | spokes (`dev`, `sandbox`) then `network` |

## Cost callouts

Every page that creates or implies running endpoints states that ENI-hours are billable and links
[Route 53 pricing](https://aws.amazon.com/route53/pricing/). Destroy when finished.

## ARN and account placeholders

In fenced samples, mask **account IDs** (use `123456789012` / `234567890123` /
`345678901234`). Resource IDs from a real lab run (instance, VPC, Resolver rule,
command) may be shown as-is.
