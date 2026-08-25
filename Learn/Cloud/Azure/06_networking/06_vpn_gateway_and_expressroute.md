## VPN Gateway and ExpressRoute


VPN Gateway enables secure cross-premises connectivity between Azure virtual networks and on-premises networks through encrypted tunnels over the public internet. The service supports site-to-site, point-to-site, and VNet-to-VNet connections with multiple VPN protocols and authentication methods.

Site-to-site VPNs create persistent connections between on-premises VPN devices and Azure VPN gateways, enabling hybrid network architectures. Point-to-site VPNs allow individual client devices to connect securely to Azure VNets, supporting remote work scenarios and administrative access.

**Key Points:**

- Multiple VPN types supporting different connectivity scenarios
- Active-active and active-passive gateway configurations for high availability
- BGP routing support for dynamic route advertisement
- Multiple authentication methods including certificates and Azure AD
- Integration with on-premises routing infrastructure

ExpressRoute provides private, dedicated connections between on-premises networks and Azure datacenters, bypassing the public internet entirely. ExpressRoute connections offer predictable bandwidth, lower latencies, and enhanced security compared to internet-based connections.

ExpressRoute peering configurations include private peering for Azure VNet connectivity, Microsoft peering for Office 365 and Azure public services, and Azure public peering (deprecated) for legacy scenarios. Global Reach enables on-premises networks connected to different ExpressRoute locations to communicate through the Microsoft backbone.

**Example:** A multinational corporation uses ExpressRoute Premium with Global Reach to connect regional offices in different continents, enabling direct communication between locations through Microsoft's global network while maintaining private connectivity to Azure services.

ExpressRoute Direct provides dedicated physical connections with bandwidth options up to 100 Gbps, enabling massive scale requirements and complete control over the physical connection. FastPath optimizes data path performance by bypassing the ExpressRoute gateway for specific traffic flows.

