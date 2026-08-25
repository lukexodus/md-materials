## Network Security Groups (NSG)


Network Security Groups function as distributed firewalls that control network traffic to and from Azure resources through security rules that allow or deny traffic based on source, destination, port, and protocol. NSGs can be associated with subnets or individual network interfaces, providing multiple layers of network security control.

Security rules within NSGs are processed by priority, with lower numbers taking precedence over higher numbers. Each rule specifies action (allow or deny), protocol (TCP, UDP, or any), source and destination (IP addresses, service tags, or application security groups), and port ranges. Default rules provide baseline connectivity while custom rules implement specific security requirements.

**Example:** An NSG protecting web servers might allow HTTP (port 80) and HTTPS (port 443) traffic from any source while restricting SSH (port 22) access to specific administrative IP addresses and blocking all other inbound traffic.

Application Security Groups (ASGs) enhance NSG functionality by enabling rule definition based on application roles rather than specific IP addresses. ASGs allow grouping of virtual machines by function, making security rules more maintainable and scalable as infrastructure grows and changes.

**Key Points:**

- Stateful firewall behavior with automatic return traffic allowance
- Service tags for simplified rule creation targeting Azure services
- Flow logging capabilities for network traffic analysis and security monitoring
- Integration with Azure Security Center for security recommendations
- Subnet and network interface association options for flexible deployment

NSG flow logs capture information about IP traffic flowing through NSGs, providing detailed network traffic analytics for security analysis, compliance auditing, and network troubleshooting. Flow logs integrate with Azure Network Watcher for advanced network monitoring and diagnostic capabilities.

