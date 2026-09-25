# Tear down

Spokes first, then network — so shared-rule associations go away before the hub
endpoint and BIND.

!!! tip "Mutation guard"
    Local agent shells need `export R53_OUTBOUND_ALLOW_AWS=1` before apply/destroy.

## Destroy (dev)

<div class="run" markdown>

```bash
cd terraform/accounts/dev
terraform destroy
```

```text {.no-copy}
Destroy complete! Resources: 18 destroyed.
```

</div>

## Destroy (sandbox)

<div class="run" markdown>

```bash
cd terraform/accounts/sandbox
terraform destroy
```

```text {.no-copy}
Destroy complete! Resources: 18 destroyed.
```

</div>

## Destroy (network)

<div class="run" markdown>

```bash
cd terraform/accounts/network
terraform destroy
```

```text {.no-copy}
Destroy complete! Resources: 32 destroyed.
```

</div>

Resource counts above are from this lab’s evidence pass (central + reverse rules).
Your apply history may differ slightly.

Outbound ENIs stop billing once destroyed (~$6/day while they ran). If dig
still failed before destroy, see [Troubleshooting](troubleshooting.md).
