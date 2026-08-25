## Elastic Load Balancer (ELB)


Elastic Load Balancers distribute incoming application traffic across multiple targets, improving application fault tolerance and availability.

**Application Load Balancer (ALB)** ALBs operate at Layer 7 (application layer) and route HTTP/HTTPS traffic based on content. They support advanced routing features including host-based routing, path-based routing, and HTTP header routing. ALBs integrate with AWS services like ECS, EKS, and Lambda, supporting containerized applications and serverless architectures. They provide WebSocket support and HTTP/2 protocol handling.

**Network Load Balancer (NLB)** NLBs operate at Layer 4 (transport layer) and handle TCP, UDP, and TLS traffic with ultra-low latency. They support static IP addresses and preserve source IP addresses. NLBs can handle millions of requests per second while maintaining microsecond latencies, making them suitable for latency-sensitive applications.

**Gateway Load Balancer (GWLB)** GWLBs enable deployment of third-party virtual appliances like firewalls, intrusion detection systems, and deep packet inspection systems. They operate at Layer 3 (network layer) and use the GENEVE protocol for traffic encapsulation.

**Classic Load Balancer (CLB)** CLBs provide basic load balancing across EC2 instances and operate at both Layer 4 and Layer 7. They support HTTP, HTTPS, TCP, and SSL protocols but lack advanced routing capabilities of ALBs and NLBs. [Unverified: AWS may be phasing out Classic Load Balancers in favor of newer load balancer types.]

