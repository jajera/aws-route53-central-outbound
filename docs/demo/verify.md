# Verify with dig

Prove all three dig clients reach BIND through Resolver for:

| Kind | Query | Shared FORWARD rule |
| ---- | ----- | ------------------- |
| **Forward** (A) | name → IP | `corp.demo.internal` |
| **Reverse** (PTR) | IP → name | `100.0.10.in-addr.arpa` |

## Wait for SSM

Allow **2–5 minutes** after apply for agents to show Online.

<div class="run" markdown>

```bash
aws ssm describe-instance-information \
  --profile network --region ap-southeast-2 \
  --filters "Key=InstanceIds,Values=$(cd terraform/accounts/network && terraform output -raw test_client_instance_id)" \
  --query 'InstanceInformationList[0].PingStatus' --output text
```

```text {.no-copy}
Online
```

</div>

<div class="run" markdown>

```bash
aws ssm describe-instance-information \
  --profile dev --region ap-southeast-2 \
  --filters "Key=InstanceIds,Values=$(cd terraform/accounts/dev && terraform output -raw test_client_instance_id)" \
  --query 'InstanceInformationList[0].PingStatus' --output text
```

```text {.no-copy}
Online
```

</div>

<div class="run" markdown>

```bash
aws ssm describe-instance-information \
  --profile sandbox --region ap-southeast-2 \
  --filters "Key=InstanceIds,Values=$(cd terraform/accounts/sandbox && terraform output -raw test_client_instance_id)" \
  --query 'InstanceInformationList[0].PingStatus' --output text
```

```text {.no-copy}
Online
```

</div>

## Forward lookup (A)

Name → address via the `corp.demo.internal` rule.

### Network

<div class="run" markdown>

```bash
INSTANCE_ID=$(cd terraform/accounts/network && terraform output -raw test_client_instance_id)
echo "$INSTANCE_ID"
```

```text {.no-copy}
i-09e2fb6ff74bd0f8b
```

</div>

<div class="run" markdown>

```bash
COMMAND_ID=$(aws ssm send-command \
  --profile network \
  --region ap-southeast-2 \
  --instance-ids "$INSTANCE_ID" \
  --document-name AWS-RunShellScript \
  --parameters 'commands=["dig +short app.corp.demo.internal","dig +short db.corp.demo.internal"]' \
  --query 'Command.CommandId' \
  --output text)
echo "$COMMAND_ID"
```

```text {.no-copy}
090f3e81-d7e5-411b-9ed5-ef7076a03e8c
```

</div>

<div class="run" markdown>

```bash
aws ssm get-command-invocation \
  --profile network \
  --region ap-southeast-2 \
  --command-id "$COMMAND_ID" \
  --instance-id "$INSTANCE_ID" \
  --query '{Status:Status,Out:StandardOutputContent,Err:StandardErrorContent}'
```

```text {.no-copy}
{
    "Status": "Success",
    "Out": "10.0.100.10\n10.0.100.20\n",
    "Err": ""
}
```

</div>

### Dev

<div class="run" markdown>

```bash
INSTANCE_ID=$(cd terraform/accounts/dev && terraform output -raw test_client_instance_id)
COMMAND_ID=$(aws ssm send-command \
  --profile dev \
  --region ap-southeast-2 \
  --instance-ids "$INSTANCE_ID" \
  --document-name AWS-RunShellScript \
  --parameters 'commands=["dig +short app.corp.demo.internal","dig +short db.corp.demo.internal"]' \
  --query 'Command.CommandId' \
  --output text)
aws ssm get-command-invocation \
  --profile dev \
  --region ap-southeast-2 \
  --command-id "$COMMAND_ID" \
  --instance-id "$INSTANCE_ID" \
  --query '{Status:Status,Out:StandardOutputContent,Err:StandardErrorContent}'
```

```text {.no-copy}
{
    "Status": "Success",
    "Out": "10.0.100.10\n10.0.100.20\n",
    "Err": ""
}
```

</div>

### Sandbox

<div class="run" markdown>

```bash
INSTANCE_ID=$(cd terraform/accounts/sandbox && terraform output -raw test_client_instance_id)
COMMAND_ID=$(aws ssm send-command \
  --profile sandbox \
  --region ap-southeast-2 \
  --instance-ids "$INSTANCE_ID" \
  --document-name AWS-RunShellScript \
  --parameters 'commands=["dig +short app.corp.demo.internal","dig +short db.corp.demo.internal"]' \
  --query 'Command.CommandId' \
  --output text)
aws ssm get-command-invocation \
  --profile sandbox \
  --region ap-southeast-2 \
  --command-id "$COMMAND_ID" \
  --instance-id "$INSTANCE_ID" \
  --query '{Status:Status,Out:StandardOutputContent,Err:StandardErrorContent}'
```

```text {.no-copy}
{
    "Status": "Success",
    "Out": "10.0.100.10\n10.0.100.20\n",
    "Err": ""
}
```

</div>

| Forward query | Expected answer |
| ------------- | --------------- |
| `app.corp.demo.internal` | `10.0.100.10` |
| `db.corp.demo.internal` | `10.0.100.20` |

## Reverse lookup (PTR)

Address → name via the `100.0.10.in-addr.arpa` rule (`dig -x`).

### Network

<div class="run" markdown>

```bash
INSTANCE_ID=$(cd terraform/accounts/network && terraform output -raw test_client_instance_id)
COMMAND_ID=$(aws ssm send-command \
  --profile network \
  --region ap-southeast-2 \
  --instance-ids "$INSTANCE_ID" \
  --document-name AWS-RunShellScript \
  --parameters 'commands=["dig +short -x 10.0.100.10","dig +short -x 10.0.100.20"]' \
  --query 'Command.CommandId' \
  --output text)
aws ssm get-command-invocation \
  --profile network \
  --region ap-southeast-2 \
  --command-id "$COMMAND_ID" \
  --instance-id "$INSTANCE_ID" \
  --query '{Status:Status,Out:StandardOutputContent,Err:StandardErrorContent}'
```

```text {.no-copy}
{
    "Status": "Success",
    "Out": "app.corp.demo.internal.\ndb.corp.demo.internal.\n",
    "Err": ""
}
```

</div>

### Dev

<div class="run" markdown>

```bash
INSTANCE_ID=$(cd terraform/accounts/dev && terraform output -raw test_client_instance_id)
COMMAND_ID=$(aws ssm send-command \
  --profile dev \
  --region ap-southeast-2 \
  --instance-ids "$INSTANCE_ID" \
  --document-name AWS-RunShellScript \
  --parameters 'commands=["dig +short -x 10.0.100.10","dig +short -x 10.0.100.20"]' \
  --query 'Command.CommandId' \
  --output text)
aws ssm get-command-invocation \
  --profile dev \
  --region ap-southeast-2 \
  --command-id "$COMMAND_ID" \
  --instance-id "$INSTANCE_ID" \
  --query '{Status:Status,Out:StandardOutputContent,Err:StandardErrorContent}'
```

```text {.no-copy}
{
    "Status": "Success",
    "Out": "app.corp.demo.internal.\ndb.corp.demo.internal.\n",
    "Err": ""
}
```

</div>

### Sandbox

<div class="run" markdown>

```bash
INSTANCE_ID=$(cd terraform/accounts/sandbox && terraform output -raw test_client_instance_id)
COMMAND_ID=$(aws ssm send-command \
  --profile sandbox \
  --region ap-southeast-2 \
  --instance-ids "$INSTANCE_ID" \
  --document-name AWS-RunShellScript \
  --parameters 'commands=["dig +short -x 10.0.100.10","dig +short -x 10.0.100.20"]' \
  --query 'Command.CommandId' \
  --output text)
aws ssm get-command-invocation \
  --profile sandbox \
  --region ap-southeast-2 \
  --command-id "$COMMAND_ID" \
  --instance-id "$INSTANCE_ID" \
  --query '{Status:Status,Out:StandardOutputContent,Err:StandardErrorContent}'
```

```text {.no-copy}
{
    "Status": "Success",
    "Out": "app.corp.demo.internal.\ndb.corp.demo.internal.\n",
    "Err": ""
}
```

</div>

| Reverse query | Expected answer |
| ------------- | --------------- |
| `-x 10.0.100.10` | `app.corp.demo.internal.` |
| `-x 10.0.100.20` | `db.corp.demo.internal.` |

All three accounts must match for **both** forward and reverse. If only network
works, the spoke is missing a shared rule association — see
[Troubleshooting](troubleshooting.md).

Next: [Tear down](teardown.md).
