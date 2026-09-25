# Attach spokes

Apply each spoke root once: `terraform/accounts/dev`, then
`terraform/accounts/sandbox`. In **central** they only associate the shared
rule — no local outbound endpoint (`eni_count = 0`).

## What this creates (each spoke)

| Resource | Detail |
| --- | --- |
| Private subnets | SSM interface endpoints + S3 gateway |
| dig test client | SSM + `bind-utils` |
| Rule association | Shared FORWARD rules (corp + reverse) from network via RAM |
| Outbound endpoint | **None** in central |

Query path after this step:

![Central request path](../assets/diagrams/request-path-central.svg)

<p class="diagram-caption">Spoke dig → VPC Resolver → shared rule → hub ENIs → BIND. No peering required for resolution.</p>

## Configure (dev)

<div class="run" markdown>

```bash
cd terraform/accounts/dev
cp terraform.tfvars.example terraform.tfvars
```

```text {.no-copy}
(no output)
```

</div>

Edit `terraform.tfvars` — set `shared_resolver_rule_id` from
[Build the hub](hub.md):

```hcl
outbound_pattern                = "central"
vpc_cidr                        = "10.1.0.0/16"
shared_resolver_rule_id         = "rslvr-rr-c6f17286c56046a89"
shared_reverse_resolver_rule_id = "rslvr-rr-1cac69d7e92e481eb"
# ram_share_accept_required = false   # default when org auto-accept works
# ram_share_arn = "..."               # only if accept is required
```

## Apply (dev)

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
Apply complete! Resources: 17 added, 0 changed, 0 destroyed.

Outputs:

account_id              = "234567890123"
eni_count               = 0
outbound_pattern        = "central"
peering_connection_id   = ""
resolver_endpoint_id    = ""
test_client_instance_id = "i-09e4080d662e78cd7"
vpc_cidr                = "10.1.0.0/16"
vpc_id                  = "vpc-0040c8b17ae1c1dc0"
```

</div>

Confirm the dig client ID for [Verify with dig](verify.md):

<div class="run" markdown>

```bash
terraform output -raw test_client_instance_id
```

```text {.no-copy}
i-09e4080d662e78cd7
```

</div>

<div class="run" markdown>

```bash
terraform output -raw eni_count
```

```text {.no-copy}
0
```

</div>

## Configure (sandbox)

<div class="run" markdown>

```bash
cd terraform/accounts/sandbox
cp terraform.tfvars.example terraform.tfvars
```

```text {.no-copy}
(no output)
```

</div>

Same rule ID; sandbox uses a different VPC CIDR:

```hcl
outbound_pattern                = "central"
vpc_cidr                        = "10.2.0.0/16"
shared_resolver_rule_id         = "rslvr-rr-c6f17286c56046a89"
shared_reverse_resolver_rule_id = "rslvr-rr-1cac69d7e92e481eb"
```

## Apply (sandbox)

<div class="run" markdown>

```bash
terraform init
```

```text {.no-copy}
Terraform has been successfully initialized!
```

</div>

<div class="run" markdown>

```bash
terraform apply
```

```text {.no-copy}
Apply complete! Resources: 17 added, 0 changed, 0 destroyed.

Outputs:

account_id              = "345678901234"
eni_count               = 0
outbound_pattern        = "central"
peering_connection_id   = ""
resolver_endpoint_id    = ""
test_client_instance_id = "i-028971f8ce654c6e0"
vpc_cidr                = "10.2.0.0/16"
vpc_id                  = "vpc-05fa5dc9ddd60cd39"
```

</div>

<div class="run" markdown>

```bash
terraform output -raw test_client_instance_id
```

```text {.no-copy}
i-028971f8ce654c6e0
```

</div>

Next: [Verify with dig](verify.md).
