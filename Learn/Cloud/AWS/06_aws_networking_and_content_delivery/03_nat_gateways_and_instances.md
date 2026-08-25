## NAT Gateways and Instances


**NAT Gateways** are managed AWS services that enable instances in private subnets to connect to the internet or other AWS services while preventing inbound connections from the internet. NAT gateways are highly available within a single Availability Zone and automatically scale to accommodate bandwidth requirements up to 45 Gbps.

NAT gateways require an Elastic IP address and must be deployed in a public subnet. They support IPv4 traffic only - for IPv6, an egress-only internet gateway is used instead. AWS manages the underlying infrastructure, including software updates and failure recovery.

Bandwidth allocation for NAT gateways starts at 5 Gbps and scales automatically. [Inference] Performance is generally superior to NAT instances for most use cases due to the managed nature and automatic scaling capabilities.

**NAT Instances** are EC2 instances configured to provide network address translation services. Unlike NAT gateways, NAT instances run on customer-managed EC2 infrastructure, requiring manual configuration, monitoring, and scaling.

NAT instances offer more flexibility in terms of configuration options, security groups, and custom software installation. They can be configured as bastion hosts and support port forwarding. However, they introduce single points of failure unless deployed with high availability configurations across multiple Availability Zones.

Performance of NAT instances depends on the instance type and can become a bottleneck if not properly sized. They require regular patching and maintenance, and bandwidth is limited by the instance type's network performance capabilities.

