## Overlay Networks


Overlay networks create virtual network topologies that operate independently of underlying physical infrastructure. These logical networks enable tenant isolation, flexible addressing schemes, and location transparency for distributed applications.

**Overlay Network Architectures**

Overlay networks implement various architectural models to support different use cases and performance requirements. Flat overlay networks provide simple Layer 2 connectivity across distributed locations, enabling virtual machine mobility and simplified application deployment. Hierarchical overlays implement routing between multiple overlay segments, supporting complex multi-tier application architectures. Mesh overlays create direct connectivity between all overlay endpoints, minimizing latency and eliminating potential bottlenecks.

**Encapsulation Technologies**

Overlay network implementations rely on encapsulation protocols to transport virtual network traffic over physical infrastructure. VXLAN (Virtual Extensible LAN) extends Layer 2 domains across Layer 3 networks using UDP encapsulation with 24-bit VNID addressing. NVGRE (Network Virtualization using Generic Routing Encapsulation) employs GRE tunneling with additional header fields for tenant identification. STT (Stateless Transport Tunneling) optimizes performance for TCP-based overlay traffic through specialized encapsulation techniques.

**Control Plane Distribution**

Overlay network control planes manage endpoint discovery, reachability information, and policy distribution across the overlay infrastructure. Centralized control planes utilize dedicated controllers to maintain global overlay topology information and coordinate policy enforcement. Distributed control planes employ peer-to-peer protocols to exchange reachability information between overlay endpoints. [Speculation] Hybrid approaches may combine centralized policy management with distributed data plane learning to balance control efficiency with scalability requirements.

**Multi-Tenancy Implementation**

Multi-tenant overlay networks provide isolation between different customer or application environments sharing common physical infrastructure. Tenant identification mechanisms assign unique identifiers to each customer environment, enabling policy enforcement and traffic separation. Address space isolation prevents conflicts between tenant addressing schemes while maintaining connectivity within each tenant domain. Policy enforcement ensures tenant traffic isolation while supporting controlled inter-tenant communication when required.

