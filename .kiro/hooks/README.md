# Hooks

Kiro v1 hooks ([reference](https://kiro.dev/docs/hooks/)). Adapted from
[s3-express-hot-lookup-walkthrough](https://github.com/jajera/s3-express-hot-lookup-walkthrough).

| File | Trigger | Blocks | Purpose |
| --- | --- | --- | --- |
| `guard-aws-mutations.json` | `PreToolUse` | yes | Refuses mutating AWS CLI / Terraform apply-destroy unless `R53_OUTBOUND_ALLOW_AWS=1` |
| `cite-aws-claims.json` | `PostFileSave` | no | Reminds the agent to ground AWS claims after editing `docs/**` |
| `format-markdown-tables.json` | `PostFileSave` | no | Repairs broken GFM tables in dirty Markdown |

Opt in for a deliberate demo apply:

```bash
export R53_OUTBOUND_ALLOW_AWS=1
```

Test the guard without Kiro:

```bash
echo '{"command":"terraform apply"}' | python3 .kiro/hooks/guard-aws-mutations.py; echo "exit=$?"   # 2
echo '{"command":"aws sts get-caller-identity --profile network"}' | python3 .kiro/hooks/guard-aws-mutations.py; echo "exit=$?" # 0
```
