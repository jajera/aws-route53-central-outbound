# Prerequisites

Tools, access, and cost awareness before the first `terraform apply`.

## Tools and access

| Requirement | Detail |
| --- | --- |
| AWS CLI profiles | Named `network`, `dev`, `sandbox` |
| Region | `ap-southeast-2` |
| Terraform | `>= 1.5.0` |
| Same AWS Organization | `network`, `dev`, and `sandbox` must be in one org |
| RAM org sharing | **Required** for central — enable once from the management account |
| State | Local only — do not commit `terraform.tfvars` or `*.tfstate*` |

### Enable RAM sharing with the organization (once)

Resolver rules can only be shared inside an Organization, and only after RAM
org sharing is turned on from the **management** account:

<div class="run" markdown>

```bash
aws ram enable-sharing-with-aws-organization --profile <management-profile>
```

```text {.no-copy}
{
    "returnValue": true
}
```

</div>

Run this once per organization (not per lab apply). If hub apply fails with
`OperationNotPermittedException` … “only be shared within your AWS Organization”,
run that command, then re-apply network (recreate the RAM share if it was created
before sharing was enabled).

If invitations still do **not** auto-accept, spokes set
`ram_share_accept_required = true` and `ram_share_arn` from network (see Design →
[RAM sharing](../design.md#ram-sharing)).

## Cost while applied

| Mode | Outbound ENIs | Endpoint ≈ / day\* |
| --- | ---: | ---: |
| Central (this demo) | 2 | **~$6** |

\*At $0.125/ENI-hour × 24 hours. Lab EC2 + nine SSM interface endpoints add
about **~$3.30/day** on top — see
[Cost → Demo lab overhead](../cost.md#demo-lab-overhead-not-part-of-the-pattern-comparison).
Monthly pattern comparison (including per-account) lives on [Cost](../cost.md).

!!! warning "Destroy when finished"
    Roughly **~$9/day** central all-in (endpoints + lab overhead) while applied.
    Tear-down order: [Tear down](teardown.md).

Next: [Check profiles](profiles.md).
