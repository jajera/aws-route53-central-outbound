# References

AWS documentation and posts this site builds on. Behavioural claims in Patterns,
Design, and Cost trace here (and to lab evidence in the demo).

## Route 53 Resolver

| Topic | Link |
| --- | --- |
| Resolver overview | [Developer Guide](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver.html) |
| Outbound endpoints | [Forwarding outbound queries](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-forwarding-outbound-queries.html) |
| Configure outbound (endpoint + rules) | [Configuring outbound forwarding](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-forwarding-outbound-queries-configuring.html) |
| Forwarding rules | [Managing forwarding rules](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-rules-managing.html) |
| Rule domain matching (most specific wins) | [How VPC Resolver matches domain names](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-overview-forward-vpc-to-network-domain-name-matches.html) |
| Sharing rules with RAM | [Sharing Resolver rules](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-rules-managing.html#resolver-rules-sharing) |
| Endpoint considerations | [Creating inbound and outbound endpoints](https://docs.aws.amazon.com/Route53/latest/DeveloperGuide/resolver-choose-vpc.html) |
| Pricing | [Amazon Route 53 pricing](https://aws.amazon.com/route53/pricing/) |

## High availability and blast radius

| Topic | Link |
| --- | --- |
| Multi-AZ ENIs, multiple target IPs | [How to achieve DNS high availability with Route 53 Resolver endpoints](https://aws.amazon.com/blogs/networking-and-content-delivery/how-to-achieve-dns-high-availability-with-route-53-resolver-endpoints/) |
| Shared rules still use the owner VPC’s outbound path | [Hybrid cloud DNS options for Amazon VPC — key concepts](https://docs.aws.amazon.com/whitepapers/latest/hybrid-cloud-dns-options-for-vpc/key-concepts.html) |

## Related AWS services

| Topic | Link |
| --- | --- |
| AWS RAM | [What is AWS RAM?](https://docs.aws.amazon.com/ram/latest/userguide/what-is.html) |
| VPC peering | [What is VPC peering?](https://docs.aws.amazon.com/vpc/latest/peering/what-is-vpc-peering.html) |
| Session Manager | [AWS Systems Manager Session Manager](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager.html) |
| Interface VPC endpoints | [Interface VPC endpoints](https://docs.aws.amazon.com/vpc/latest/privatelink/vpce-interface.html) |
