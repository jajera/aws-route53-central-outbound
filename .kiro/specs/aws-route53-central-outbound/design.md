# Design notes

See also `.kiro/steering/product.md` and `docs/{patterns,design,cost,demo}.md`.

## Patterns

- **Central:** one outbound endpoint in network; FORWARD rule shared via RAM; spokes associate.
- **Per-account:** each account has outbound + local rule; peering to network for path to BIND.

## Demo data plane

- BIND on EC2 at fixed `10.0.0.10`, zone `corp.demo.internal`.
- Test clients via SSM; no NAT (SSM interface + S3 gateway endpoints).
