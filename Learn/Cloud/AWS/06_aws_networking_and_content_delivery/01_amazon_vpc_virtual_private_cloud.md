## Amazon VPC (Virtual Private Cloud)


Amazon Virtual Private Cloud (VPC) is a logically isolated section of the AWS Cloud where you can launch AWS resources in a virtual network that you define. VPC provides complete control over the virtual networking environment, including selection of IP address ranges, creation of subnets, and configuration of route tables and network gateways.

Each VPC exists within a single AWS Region and can span multiple Availability Zones. When creating a VPC, you specify an IPv4 CIDR block (and optionally an IPv6 CIDR block) that defines the IP address range for the network. The CIDR block size can range from /16 (65,536 IP addresses) to /28 (16 IP addresses).

**Default VPC** is automatically created in each AWS Region and includes a default subnet in each Availability Zone. The default VPC is configured with an internet gateway, default route table, default network access control list (NACL), and default security group. Resources launched in the default VPC automatically receive public IP addresses and can communicate with the internet.

**Custom VPCs** provide greater control over network configuration and security. Unlike default VPCs, custom VPCs do not automatically provide internet access - this must be explicitly configured through internet gateways and route tables.

VPC components include DNS resolution and DNS hostnames settings that control whether instances receive DNS names and whether DNS resolution is enabled within the VPC. Tenancy can be set to default (shared hardware) or dedicated (single-tenant hardware) for compliance requirements.

