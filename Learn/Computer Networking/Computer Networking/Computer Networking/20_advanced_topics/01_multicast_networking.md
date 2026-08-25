## Multicast Networking


Multicast networking enables efficient one-to-many and many-to-many communication by delivering data from a single source to multiple receivers simultaneously, reducing network bandwidth consumption compared to multiple unicast transmissions.

**Multicast Addressing** IPv4 multicast addresses utilize the Class D address space (224.0.0.0 to 239.255.255.255). The range is subdivided into specific allocation blocks: 224.0.0.0/24 for local network control, 224.0.1.0/24 for internetwork control, 232.0.0.0/8 for Source-Specific Multicast (SSM), and 233.0.0.0/8 for GLOP addressing.

IPv6 multicast addresses begin with the prefix FF00::/8, with the second octet indicating flags and scope. Well-known multicast addresses include FF02::1 (all nodes) and FF02::2 (all routers).

**Internet Group Management Protocol (IGMP)** IGMP enables hosts to inform local routers about multicast group memberships. IGMPv1 provides basic join/leave functionality, IGMPv2 adds leave group messages and querier election mechanisms, while IGMPv3 introduces source filtering capabilities allowing receivers to specify desired source addresses.

**Multicast Routing Protocols** _Distance Vector Multicast Routing Protocol (DVMRP)_ uses flood-and-prune behavior with reverse path forwarding (RPF) checks. DVMRP builds source-based distribution trees but suffers from scalability limitations in large networks.

_Protocol Independent Multicast (PIM)_ operates in two modes: PIM Dense Mode (PIM-DM) for high-density multicast environments using flood-and-prune mechanisms, and PIM Sparse Mode (PIM-SM) for sparse multicast deployments using explicit join messages and rendezvous points (RP).

_Multicast Source Discovery Protocol (MSDP)_ connects multiple PIM-SM domains by allowing RPs to share active source information across domain boundaries.

**Source-Specific Multicast (SSM)** SSM requires receivers to specify both the multicast group address and the source address they wish to receive traffic from. This approach eliminates the need for shared trees and rendezvous points, simplifying multicast deployment and improving security by preventing unauthorized sources from injecting traffic.

**Multicast Distribution Trees** _Source Trees_ create optimal paths from each source to all receivers but require more state information in routers. Each (S,G) entry represents a unique source-group combination.

_Shared Trees_ use a common distribution point (rendezvous point) to minimize state information but may result in suboptimal paths. Routers maintain (*,G) entries representing all sources for a specific group.

**Multicast Applications** IPTV services leverage multicast to efficiently distribute video content to multiple subscribers simultaneously. Financial data feeds use multicast for real-time market data distribution. Software distribution systems employ multicast for efficient deployment across large networks.

