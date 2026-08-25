## Virtual Networks (VNet)


Virtual Networks serve as the fundamental building block of Azure networking, providing isolated network environments where Azure resources can securely communicate with each other, the internet, and on-premises networks. VNets function as software-defined networks that replicate traditional network functionality while offering cloud-scale flexibility and management capabilities.

Each VNet exists within a single Azure region and subscription, containing one or more subnets that segment the network address space. Subnets enable logical separation of resources and application of different security policies, routing rules, and network services. VNet address spaces use private IP ranges defined in RFC 1918, though custom address ranges are supported for specific scenarios.

**Key Points:**

- Network isolation through private IP address spaces and subnet segmentation
- Support for IPv4 and IPv6 addressing with dual-stack configurations
- Integration with Azure services through service endpoints and private endpoints
- Cross-region connectivity through VNet peering and virtual network gateways
- Network policies for controlling traffic flow and service access

Resource deployment within VNets follows specific networking rules where resources receive private IP addresses from the subnet range and can optionally be assigned public IP addresses for internet connectivity. Network interfaces attached to virtual machines enable communication within the VNet and external networks based on routing and security configurations.

VNet peering enables connectivity between VNets within the same region or across different regions, creating hub-and-spoke topologies or mesh network architectures. Peered VNets appear as a single network to connected resources while maintaining separate administrative boundaries and billing scopes.

