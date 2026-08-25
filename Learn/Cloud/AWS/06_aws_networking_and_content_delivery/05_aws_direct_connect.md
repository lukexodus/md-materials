## AWS Direct Connect


AWS Direct Connect establishes dedicated network connections between on-premises data centers and AWS. This service bypasses the public internet to provide more consistent network performance, reduced bandwidth costs, and enhanced security for hybrid cloud architectures.

**Dedicated Connections** are physical Ethernet connections with bandwidth options of 1 Gbps, 10 Gbps, or 100 Gbps. These connections are provisioned at AWS Direct Connect locations and require coordination with AWS partners or telecommunications providers.

**Hosted Connections** are provided by AWS Direct Connect Partners and offer bandwidth options from 50 Mbps to 10 Gbps. Partners manage the physical infrastructure while customers configure the logical connection to their AWS account.

**Virtual Interfaces (VIFs)** are logical connections that run over Direct Connect physical connections. Public VIFs provide access to AWS public services like S3 and DynamoDB, while Private VIFs connect to VPC resources. Transit VIFs enable connections to multiple VPCs through Transit Gateway.

Link Aggregation Groups (LAGs) can combine multiple connections for higher bandwidth and redundancy. BGP routing protocol is used to advertise and learn routes between on-premises networks and AWS.

[Inference] Direct Connect typically provides lower latency and more predictable bandwidth compared to internet-based VPN connections, making it suitable for applications requiring consistent network performance.

