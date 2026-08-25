## Azure Load Balancer


Azure Load Balancer distributes inbound traffic across multiple backend instances to ensure high availability and optimal resource utilization. The service operates at Layer 4 (transport layer) of the OSI model, providing load balancing based on TCP and UDP protocols with support for both public and internal load balancing scenarios.

Load balancer configurations include frontend IP configurations, backend address pools, health probes, and load balancing rules. Frontend configurations define the IP addresses that receive traffic, while backend pools contain the target resources that serve the traffic. Health probes monitor backend instance availability, and load balancing rules define how traffic is distributed.

The service supports multiple load balancing algorithms including hash-based distribution (5-tuple hash), source IP affinity (session persistence), and port-based distribution. Health probes ensure traffic is only directed to healthy instances, with configurable probe intervals, timeout values, and failure thresholds.

**Example:** A Standard Load Balancer distributing HTTPS traffic across three web servers monitors each server's health through HTTP probes on port 80 and automatically removes failed instances from the backend pool until they recover.

**Key Points:**

- Basic and Standard SKUs with different feature sets and SLA guarantees
- Zone redundancy for high availability across availability zones
- Outbound connectivity management through outbound rules and SNAT
- Support for IPv6 and dual-stack configurations
- Integration with virtual machine scale sets for automatic scaling

Standard Load Balancer provides enhanced capabilities including availability zone support, expanded backend pool sizes, health probe monitoring for all ports, and detailed metrics through Azure Monitor. Outbound rules enable precise control over outbound connectivity and SNAT port allocation for backend instances.

