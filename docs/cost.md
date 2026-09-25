# Cost

Endpoint ENI-hours are the lever between per-account and central outbound.
Query volume does **not** change the pattern delta when both shapes forward the
same queries — it changes **who** pays (the endpoint owner).

**Prices retrieved:** 26 September 2026 from
[Amazon Route 53 pricing](https://aws.amazon.com/route53/pricing/) — Resolver
endpoints **$0.125** per ENI-hour; recursive queries through an endpoint
**$0.40** / million (first 1B/month), then **$0.20** / million. Those rates are
not region-differentiated on the public table. Worked example region:
`ap-southeast-2`.

## Assumptions

| Assumption | Value |
| --- | --- |
| Region | `ap-southeast-2` |
| VPCs needing the same zone | 3 (worked example) |
| ENIs per outbound endpoint | 2 (AWS minimum, different AZs) |
| Hours per month | 730 |
| ENI-hour rate | **$0.125** |
| Queries through endpoints | $0.40 / million (first 1B/month), then $0.20 / million |
| Query volume bands | 1M, 100M, 1B / month (same total for both patterns) |
| AWS RAM | $0 (rule share only) |

## Formula

```text
endpoint_cost = endpoints × ENIs_per_endpoint × hours × eni_hour_rate
query_cost    = queries_millions × query_rate   # first 1B at $0.40
total         = endpoint_cost + query_cost
```

For three VPCs (endpoint ENI-hours only):

| Pattern | Calculation | Monthly |
| --- | --- | ---: |
| Per-account | `3 × 2 × 730 × 0.125` | **$547.50** |
| Central | `1 × 2 × 730 × 0.125` | **$182.50** |

## Where the gap opens

| VPCs | Per-account | Central | You save |
| ---: | ---: | ---: | ---: |
| 1 | $182.50 | $182.50 | $0 |
| 2 | $365.00 | $182.50 | **$182.50** |
| 3 | $547.50 | $182.50 | **$365.00** |

One VPC: same two ENIs either way — central only adds unused RAM. The second VPC
is where per-account doubles ENIs and central stays flat. Story form:
[Patterns](patterns.md).

## Side by side (3 VPCs)

| Line item | Per-account | Central | Delta |
| --- | ---: | ---: | ---: |
| Endpoints | 3 | 1 | −2 |
| ENIs | 6 | 2 | −4 |
| Endpoint ENI-hours / month | $547.50 | $182.50 | **−$365.00** |
| Queries @ 1M | $0.40 | $0.40 | $0 |
| Queries @ 100M | $40.00 | $40.00 | $0 |
| Queries @ 1B | $400.00 | $400.00 | $0 |
| **Total @ 100M queries** | **$587.50** | **$222.50** | **−$365.00** |

Central still wins on ENI-hours. Query charges for traffic through the shared
endpoint land on the **network** account (chargeback), not on each spoke.

## Scaling (endpoint ENI-hours only)

| VPCs | Per-account ENIs | Per-account / month | Central ENIs | Central / month | Savings |
| ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | 2 | $182.50 | 2 | $182.50 | $0.00 |
| 2 | 4 | $365.00 | 2 | $182.50 | $182.50 |
| 3 | 6 | $547.50 | 2 | $182.50 | $365.00 |
| 5 | 10 | $912.50 | 2 | $182.50 | $730.00 |
| 10 | 20 | $1,825.00 | 2 | $182.50 | $1,642.50 |
| 25 | 50 | $4,562.50 | 2 | $182.50 | $4,380.00 |
| 50 | 100 | $9,125.00 | 2 | $182.50 | $8,942.50 |

Central stays at two ENIs until you add regions or more interfaces on the hub.
Multi-region is out of scope for v1 but would multiply hub cost by region count
(Resolver endpoints are regional).

## Not only money

ENI savings are not free. Central concentrates the failure domain, chargeback, and ops
ownership on the network account; per-account keeps those local but every VPC still needs
a path to the DNS IP. Full write-up: [Patterns §4](patterns.md#4-cost-is-not-the-only-tradeoff).

| Factor | Per-account | Central |
| --- | --- | --- |
| Blast radius | One account | All associated spokes |
| Chargeback | Each account pays its ENIs/queries | Network pays hub ENIs/queries |
| Ops ownership | Each account | Network account |
| Path to DNS IP | Every VPC (TGW / VPN / peering) | Hub once |

Path bandwidth (TGW/VPN/peering) is **excluded** from the tables — it is
environment-specific and often dominates when you already have a hub network.

## Demo lab overhead (not part of the pattern comparison)

Lab-only resources under `terraform/accounts/` — BIND, dig clients, SSM endpoints.
Same in both patterns (or only in per-account for peering). **Do not** fold these
into the ENI delta above.

Rates below: AWS Price List API for `ap-southeast-2`, 26 September 2026 —
`t4g.nano` Linux On-Demand **$0.0053**/hour; interface VPC endpoint
**$0.013**/hour.

| Resource | Unit (apse2) | Qty (central) | Notes |
| --- | --- | ---: | --- |
| BIND EC2 `t4g.nano` | $0.0053 / hour | 1 | Corporate DNS stand-in |
| Test client `t4g.nano` | $0.0053 / hour | 3 | One per account for dig |
| SSM interface endpoints | $0.013 / hour each | 9 (3 services × 3 VPCs, 1 AZ) | No NAT |
| S3 gateway endpoints | $0 | 3 | Package install path |
| VPC peering | data transfer only | 0 in central | Used in per-account |

Rough central lab run rate: about **$3.30/day** while applied (~$0.138/hour —
dominated by nine SSM interface endpoints). Destroy when finished.

!!! warning "Always destroy after the demo"
    Outbound endpoints alone are $182.50/month in central and $547.50/month in
    per-account at these rates. Leave them running only while you need dig
    verification.
