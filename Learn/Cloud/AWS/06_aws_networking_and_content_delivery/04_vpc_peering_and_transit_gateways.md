## VPC Peering and Transit Gateways


**VPC Peering** creates a direct network connection between two VPCs, enabling instances in either VPC to communicate as if they were within the same network. VPC peering connections can be established between VPCs in the same account, different accounts, or different regions.

Peered VPCs must have non-overlapping CIDR blocks to avoid routing conflicts. Traffic between peered VPCs stays on the AWS global network and never traverses the public internet. Route tables in both VPCs must be updated to include routes to the peer VPC's CIDR block.

VPC peering has several limitations: it does not support transitive peering (VPC A cannot reach VPC C through VPC B), does not support edge-to-edge routing through gateways, and has a maximum limit of 125 peering connections per VPC.

**AWS Transit Gateway** acts as a cloud router that connects VPCs and on-premises networks through a central hub. This simplifies network architecture by eliminating the need for multiple VPC peering connections in complex network topologies.

Transit Gateway supports up to 5,000 VPCs and VPN connections per gateway, with the ability to segment networks using route tables. It enables transitive routing between connected networks and supports both IPv4 and IPv6 traffic.

Route propagation can be configured to automatically add routes from connected networks, simplifying route management. Transit Gateway supports inter-region peering to connect networks across different AWS regions, and cross-account sharing through AWS Resource Access Manager.

