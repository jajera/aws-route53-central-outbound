# Build the hub

Apply `terraform/accounts/network` in **central** mode: BIND, hub outbound,
two FORWARD rules (forward + reverse), and a RAM share to the spoke accounts.

Before apply: [Prerequisites](prerequisites.md) — especially **RAM org sharing**
from the management account.

## What this creates

All in the **network** VPC:

| Resource | Detail |
| --- | --- |
| Private subnets (2 AZs) | SSM interface endpoints (1 AZ) + S3 gateway endpoint |
| BIND `@ 10.0.0.10` | Authoritative for `corp.demo.internal` **and** `100.0.10.in-addr.arpa` |
| Outbound endpoint | 2 ENIs (**billable**) |
| FORWARD rules (×2) | Forward zone + reverse zone → `10.0.0.10` (same endpoint) |
| RAM share | Both rules; principals = `dev` + `sandbox` |
| dig test client | SSM + `bind-utils` |

## Configure

<div class="run" markdown>

```bash
cd terraform/accounts/network
cp terraform.tfvars.example terraform.tfvars
```

```text {.no-copy}
(no output)
```

</div>

Edit `terraform.tfvars` (account IDs from [Check profiles](profiles.md)):

```hcl
outbound_pattern     = "central"
workload_account_ids = ["234567890123", "345678901234"]
```

## Apply

!!! tip "Mutation guard"
    Local agent shells need `export R53_OUTBOUND_ALLOW_AWS=1` before apply/destroy.

<div class="run" markdown>

```bash
terraform init
```

```text {.no-copy}
Initializing the backend...
Initializing provider plugins...
...
Terraform has been successfully initialized!
```

</div>

<div class="run" markdown>

```bash
terraform apply
```

```text {.no-copy}
Apply complete! Resources: 36 added, 0 changed, 0 destroyed.

Outputs:

account_id               = "123456789012"
dns_server_ip            = "10.0.0.10"
resolver_rule_id         = "rslvr-rr-c6f17286c56046a89"
reverse_resolver_rule_id = "rslvr-rr-1cac69d7e92e481eb"
reverse_zone_name        = "100.0.10.in-addr.arpa"
test_client_instance_id  = "i-09e2fb6ff74bd0f8b"
```

</div>

## Capture outputs for spokes

<div class="run" markdown>

```bash
terraform output -raw resolver_rule_id
```

```text {.no-copy}
rslvr-rr-c6f17286c56046a89
```

</div>

<div class="run" markdown>

```bash
terraform output -raw reverse_resolver_rule_id
```

```text {.no-copy}
rslvr-rr-1cac69d7e92e481eb
```

</div>

<div class="run" markdown>

```bash
terraform output -raw ram_share_arn
```

```text {.no-copy}
arn:aws:ram:ap-southeast-2:123456789012:resource-share/b50d638e-1d5a-467a-a0d7-6458bda162c6
```

</div>

<div class="run" markdown>

```bash
terraform output -raw dns_server_ip
```

```text {.no-copy}
10.0.0.10
```

</div>

<div class="run" markdown>

```bash
terraform output -raw vpc_id
```

```text {.no-copy}
vpc-012a14c39b799bad7
```

</div>

<div class="run" markdown>

```bash
terraform output -raw vpc_cidr
```

```text {.no-copy}
10.0.0.0/16
```

</div>

<div class="run" markdown>

```bash
terraform output -raw account_id
```

```text {.no-copy}
123456789012
```

</div>

<div class="run" markdown>

```bash
terraform output -raw test_client_instance_id
```

```text {.no-copy}
i-09e2fb6ff74bd0f8b
```

</div>

Keep `resolver_rule_id` and `reverse_resolver_rule_id` for the next step.

Next: [Attach spokes](spokes.md).
