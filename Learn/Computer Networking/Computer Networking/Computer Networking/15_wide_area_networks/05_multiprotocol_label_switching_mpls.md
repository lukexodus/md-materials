## Multiprotocol Label Switching (MPLS)


MPLS is a packet-forwarding technology that uses labels to make forwarding decisions, enabling traffic engineering, Quality of Service implementation, and Virtual Private Network (VPN) services.

**Label Switching Architecture:** MPLS operates between Layer 2 and Layer 3, using 32-bit labels inserted between the data link header and network layer header. Label Switch Routers (LSRs) make forwarding decisions based on labels rather than examining IP headers, reducing processing overhead and enabling traffic engineering.

**Label Distribution and Management:** The Label Distribution Protocol (LDP) and Resource Reservation Protocol with Traffic Engineering extensions (RSVP-TE) distribute labels throughout the MPLS network. Label Switch Paths (LSPs) are established to create explicit routes through the network.

**Traffic Engineering Capabilities:** MPLS enables explicit path selection and constraint-based routing that considers bandwidth requirements, administrative policies, and link characteristics. This capability allows network operators to optimize resource utilization and implement service differentiation.

**VPN Services:**

- **Layer 3 VPNs**: Provide IP connectivity between customer sites using VPN Routing and Forwarding (VRF) tables to maintain separation
- **Layer 2 VPNs**: Transport Layer 2 frames across the MPLS backbone, enabling extension of customer LANs across WAN connections
- **Virtual Private LAN Service (VPLS)**: Creates multipoint Layer 2 VPN services that simulate LAN connectivity

**Quality of Service Integration:** MPLS integrates with Differentiated Services (DiffServ) to provide scalable QoS implementation. Traffic classes are mapped to different LSPs or treatment within shared LSPs based on service requirements.

**Advantages:**

- Simplified packet forwarding improves router performance
- Traffic engineering enables optimal resource utilization
- Integrated VPN services reduce complexity
- Scalable QoS implementation supports service differentiation

