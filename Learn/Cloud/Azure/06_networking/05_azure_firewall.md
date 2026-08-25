## Azure Firewall


Azure Firewall provides centralized network security for virtual networks through a fully stateful firewall service with built-in high availability and cloud scalability. The service operates at both network (Layer 3-4) and application (Layer 7) levels, offering comprehensive traffic filtering and threat protection capabilities.

Firewall rules are organized into rule collections that contain network rules, application rules, and NAT rules. Network rules filter traffic based on IP addresses, ports, and protocols, while application rules provide filtering based on fully qualified domain names (FQDNs) and HTTP/HTTPS traffic characteristics.

**Key Points:**

- Centralized network security with built-in high availability
- Application and network rule processing with threat intelligence integration
- DNAT (Destination Network Address Translation) for inbound connectivity
- FQDN filtering for outbound traffic control
- Integration with Azure Monitor and third-party SIEM solutions

Threat intelligence integration provides automatic protection against known malicious IP addresses and domains, with regular updates from Microsoft's threat intelligence feeds. The service supports forced tunneling for compliance scenarios requiring all internet traffic to flow through on-premises security appliances.

**Example:** Azure Firewall deployed in a hub VNet controls all outbound internet traffic from spoke VNets, allowing specific FQDN-based access to business applications while blocking access to social media and file sharing sites based on application rules.

Azure Firewall Premium offers advanced capabilities including TLS inspection, intrusion detection and prevention system (IDPS), URL filtering, and web categories for enhanced security control. Premium features require additional compute resources and licensing but provide enterprise-grade security capabilities.

