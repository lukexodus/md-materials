## Network Security (NACLs and Security Groups)


**Network Access Control Lists (NACLs)** operate at the subnet level and act as stateless firewalls that control traffic entering and leaving subnets. NACLs evaluate rules in order based on rule numbers, with lower numbers taking precedence. Traffic matching a rule is immediately allowed or denied without evaluating subsequent rules.

NACL rules specify protocol, rule number, rule action (allow or deny), source or destination CIDR block, and port range. Separate rules are required for inbound and outbound traffic since NACLs are stateless - they do not track connection state.

Default NACLs allow all inbound and outbound traffic, while custom NACLs deny all traffic by default until specific allow rules are added. Each subnet must be associated with a NACL, and subnets can share the same NACL.

**Security Groups** operate at the instance level and act as stateful firewalls that control traffic to and from EC2 instances. Security groups are stateful, meaning that if inbound traffic is allowed, corresponding outbound response traffic is automatically allowed regardless of outbound rules.

Security group rules specify protocol, port range, and source (for inbound rules) or destination (for outbound rules). Sources and destinations can be IP addresses, CIDR blocks, or other security groups. Rules can only allow traffic - there are no explicit deny rules.

Default security groups allow all outbound traffic and inbound traffic from instances associated with the same security group. Custom security groups deny all inbound traffic and allow all outbound traffic by default.

**Defense in Depth** architecture combines both NACLs and security groups to provide layered security. NACLs provide coarse-grained control at the subnet level, while security groups provide fine-grained control at the instance level.

**Key Points** for network security include implementing the principle of least privilege by opening only necessary ports and protocols. Regular security group audits help identify overly permissive rules. Network segmentation through subnets and security groups helps contain potential security breaches.

**Example** of layered security configuration might include a NACL that allows HTTP (port 80) and HTTPS (port 443) traffic to web tier subnets, while security groups on web servers allow the same traffic but only from specific load balancer security groups.

**Output** of proper network security implementation includes reduced attack surface, improved compliance posture, detailed network traffic control, and the ability to implement zero-trust network principles within AWS infrastructure.

**Conclusion** AWS networking and content delivery services provide comprehensive tools for building secure, scalable, and performant network architectures. The combination of VPCs, subnets, routing, and security controls enables fine-grained network management, while services like CloudFront and Route 53 optimize content delivery and DNS resolution globally.

**Next Steps** for implementing robust AWS networking include designing VPC architecture with appropriate subnet segmentation, implementing redundant connectivity through multiple Availability Zones, configuring CloudFront distributions for global content delivery, and establishing comprehensive network monitoring through VPC Flow Logs and CloudTrail. Organizations should also consider implementing AWS Config rules to monitor network compliance and using AWS Network Manager for centralized network management across multiple accounts and regions.

---

