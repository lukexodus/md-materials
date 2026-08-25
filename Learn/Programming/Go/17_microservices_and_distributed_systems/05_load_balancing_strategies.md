## Load Balancing Strategies


**Algorithmic Approaches** Round-robin load balancing distributes requests sequentially across available service instances, providing simple and fair distribution. Weighted round-robin allows assigning different capacities to instances based on their hardware specifications or performance characteristics.

Least connections routing directs requests to instances with the fewest active connections, optimizing resource utilization. Least response time combines connection count with average response times to identify the best-performing instances. Random selection provides good distribution with minimal computational overhead.

**Advanced Load Balancing** Consistent hashing maintains request affinity by mapping requests to instances based on request attributes, useful for stateful services or caching scenarios. Geographic routing directs requests to the closest service instances based on client location, reducing latency.

Health-based routing removes unhealthy instances from the load balancing pool automatically. Circuit breaker integration prevents routing requests to failing instances. Session affinity ensures subsequent requests from the same client reach the same service instance when required.

**Layer 4 vs Layer 7 Load Balancing** Layer 4 load balancing operates at the transport layer, making routing decisions based on IP addresses and ports without inspecting application content. This approach provides high performance and low latency but limited routing flexibility.

Layer 7 load balancing examines application-layer data, enabling content-based routing decisions. HTTP header inspection, URL path routing, and request method-based routing provide sophisticated traffic management capabilities. SSL termination and compression can be handled at this layer.

