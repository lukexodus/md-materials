## Routing Fundamentals


Routing determines optimal paths for data packets across interconnected networks through systematic path selection algorithms. Routers maintain routing tables containing destination networks, next-hop addresses, interface information, and path metrics. These tables guide forwarding decisions for each packet based on destination IP addresses.

Routing metrics quantify path desirability using various factors including hop count, bandwidth, delay, reliability, and cost. Administrative distance values prioritize routing information sources when multiple protocols provide conflicting paths. Lower administrative distances indicate more trusted routing sources.

Convergence represents the time required for all routers to agree on network topology after changes. Fast convergence minimizes packet loss and routing loops during network transitions. Load balancing distributes traffic across multiple equal-cost paths, improving network utilization and redundancy.

Routing loops occur when packets circulate indefinitely between routers due to inconsistent routing information. Prevention mechanisms include split horizon, poison reverse, and hold-down timers that suppress potentially incorrect routing updates.

**Key Points:**

- Routing tables contain destination networks, next-hops, and metrics
- Administrative distance prioritizes information from different sources
- Convergence time affects network stability during topology changes
- Loop prevention mechanisms ensure reliable packet delivery

