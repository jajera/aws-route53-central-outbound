# Troubleshooting

| Symptom | Likely cause |
| --- | --- |
| `TargetNotConnected` on SSM | Agent not Online yet; confirm SSM endpoints + instance profile; wait 2–5 minutes |
| `SERVFAIL` / timeout on dig | Outbound SG cannot reach `10.0.0.10`, or BIND not ready |
| Empty dig answer | BIND user-data still installing; SSM to the DNS instance → `systemctl status named` |
| RAM `OperationNotPermittedException` (share only within Organization) | RAM org sharing not enabled — from management account run `aws ram enable-sharing-with-aws-organization`, then re-apply network / recreate the RAM share |
| RAM association / invitation fails | Share not visible, wrong rule ID, or accepter under org auto-accept |
| Stale rule ID after recreate | Re-copy `resolver_rule_id` from network into spoke tfvars |
| Dig works in network only | Spoke missing `shared_resolver_rule_id` or rule association |
| A works, PTR (`dig -x`) fails | Spoke missing `shared_reverse_resolver_rule_id` / reverse association, or reverse zone not on BIND |
| `Invalid for_each argument` on rule association | Fixed in module (`count` over VPC IDs); pull latest `resolver-forward-rule` |

Related: [Verify with dig](verify.md) · [Design → RAM](../design.md#ram-sharing).
