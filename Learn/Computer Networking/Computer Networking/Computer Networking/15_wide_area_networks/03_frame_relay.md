## Frame Relay


Frame Relay is a packet-switched WAN technology that provides cost-effective connectivity by sharing network resources among multiple customers while maintaining logical separation of data streams.

**Technical Architecture:** Frame Relay operates at the data link layer using variable-length frames and virtual circuits. The technology employs Permanent Virtual Circuits (PVCs) that are configured administratively and Data Link Connection Identifiers (DLCIs) to distinguish between different virtual connections on the same physical interface.

**Traffic Management Mechanisms:**

- **Committed Information Rate (CIR)**: Guaranteed minimum bandwidth that the network commits to deliver
- **Burst Size**: Additional bandwidth above CIR that may be available when network conditions permit
- **Discard Eligibility (DE) Bit**: Marks frames that exceed committed parameters and may be dropped during congestion
- **Forward Explicit Congestion Notification (FECN)**: Indicates congestion in the forward direction
- **Backward Explicit Congestion Notification (BECN)**: Signals congestion in the reverse direction

**Network Topologies:** Frame Relay supports various network topologies including hub-and-spoke, partial mesh, and full mesh configurations. Hub-and-spoke topologies concentrate traffic through central sites, while mesh topologies provide direct connectivity between multiple sites.

**Quality of Service Features:** Frame Relay networks implement congestion control mechanisms and traffic shaping to manage network resources. The technology provides different service classes based on CIR commitments and burst capabilities.

**Limitations:** Frame Relay lacks built-in error correction and relies on higher-layer protocols for reliability. The technology also provides limited Quality of Service granularity compared to more modern alternatives.

