## Subnets, Route Tables, and Internet Gateways


**Subnets** are subdivisions of a VPC's IP address range that exist within a single Availability Zone. Each subnet must be associated with a route table that controls traffic routing. Subnets can be classified as:

**Public subnets** have a route to an internet gateway, allowing resources with public IP addresses to communicate directly with the internet. Resources in public subnets can receive inbound traffic from the internet if security groups and NACLs permit it.

**Private subnets** do not have a direct route to an internet gateway. Resources in private subnets cannot receive inbound traffic from the internet but can access the internet through NAT gateways or NAT instances for outbound connections.

**Database subnets** are typically isolated subnets used exclusively for database instances, often spanning multiple Availability Zones for high availability.

**Route Tables** contain rules (routes) that determine where network traffic is directed. Each route specifies a destination CIDR block and a target (such as an internet gateway, NAT gateway, or VPC peering connection). Every subnet must be associated with a route table, and if not explicitly associated, it uses the main route table.

Routes are evaluated based on the most specific match (longest prefix match). Local routes for VPC communication are automatically created and cannot be deleted. Custom routes can direct traffic to various targets including internet gateways, NAT gateways, VPC endpoints, transit gateways, and VPN connections.

**Internet Gateways** are horizontally scaled, redundant, and highly available VPC components that provide a target for internet-routable traffic. An internet gateway serves two purposes: providing a target in route tables for internet-routable traffic and performing network address translation (NAT) for instances with public IPv4 addresses.

Only one internet gateway can be attached to a VPC at a time. For an instance to communicate with the internet, it must have a public IPv4 address or Elastic IP address, be in a subnet with a route to an internet gateway, and have security group and NACL rules that allow the relevant traffic.

