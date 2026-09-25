# Demo

Stand up three accounts and resolve `corp.demo.internal` with `dig` over SSM.
You run every AWS and Terraform command; these pages only author them.

**Billable while applied** — about **~$6/day** for central outbound ENIs, plus
~$3.30/day lab overhead. Destroy when finished →
[Prerequisites](prerequisites.md) · [Cost](../cost.md).

## What you will build

A small multi-account DNS lab that proves the **central** side of the Patterns
story in a real account.

![Central lab topology: the network account runs a dig client, VPC Resolver, FORWARD rule, hub outbound endpoint (two ENIs) and BIND at 10.0.0.10; the rule is shared via RAM to the dev and sandbox accounts, which each run a dig client and associate the shared rule with no local outbound](../assets/diagrams/lab-topology.svg)

<p class="diagram-caption">Lab shape is <strong>central</strong>: one hub outbound endpoint, rule shared with RAM, spokes only associate the rule.</p>

### Accounts

| Profile | VPC CIDR | What it owns |
| --- | --- | --- |
| `network` | `10.0.0.0/16` | BIND, hub outbound (2 ENIs), FORWARD rule, RAM share, dig client |
| `dev` | `10.1.0.0/16` | VPC, dig client, association to the shared rule |
| `sandbox` | `10.2.0.0/16` | Same as dev |

### Zone (BIND stand-in for corporate DNS)

| Name | Type | Answer |
| --- | --- | --- |
| `app.corp.demo.internal` | A | `10.0.100.10` |
| `db.corp.demo.internal` | A | `10.0.100.20` |
| `10.0.100.10` | PTR | `app.corp.demo.internal.` |
| `10.0.100.20` | PTR | `db.corp.demo.internal.` |

Synthetic addresses — prove resolution only, not real hosts. Reverse lives in
`100.0.10.in-addr.arpa` on the same BIND instance and the same hub endpoint
(second FORWARD rule + RAM share).

### What you will prove

1. All three dig clients answer the same A **and** PTR records through Resolver.
2. Central uses **two** outbound ENIs total (hub only) for both domains.

The per-account contrast (more ENIs, path to BIND) stays on
[Patterns](../patterns.md), [Design](../design.md), and [Cost](../cost.md) —
this lab does not flip patterns under apply.

## Steps

| Step | Page |
| --- | --- |
| Before you start | [Prerequisites](prerequisites.md) |
| 0 · Profiles | [Check profiles](profiles.md) |
| 1 · Hub | [Build the hub](hub.md) |
| 2 · Spokes | [Attach spokes](spokes.md) |
| 3 · Dig | [Verify with dig](verify.md) |
| 4 · Clean up | [Tear down](teardown.md) |
| Stuck? | [Troubleshooting](troubleshooting.md) |

Terraform layout and variables:
[terraform/README.md](https://github.com/jajera/aws-route53-central-outbound/blob/main/terraform/README.md).
