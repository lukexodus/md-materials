## Open Shortest Path First (OSPF)


OSPF implements link state routing within hierarchical area structures that limit flooding scope and improve scalability. Area 0 serves as the backbone connecting all other areas through Area Border Routers (ABRs). This design contains link state updates within areas while providing inter-area connectivity.

Hello protocol establishes neighbor relationships and monitors link status through periodic hello packets. Neighbor states progress through down, init, two-way, exstart, exchange, loading, and full states. Database Description (DBD) packets exchange LSA summaries during database synchronization.

Five LSA types describe different network elements: Router LSAs describe router links, Network LSAs represent multi-access networks, Summary LSAs advertise inter-area routes, ASBR Summary LSAs locate external route sources, and AS External LSAs describe external destinations.

Designated Router (DR) and Backup Designated Router (BDR) election reduces LSA flooding overhead on multi-access networks. All routers form adjacencies with DR/BDR while maintaining neighbor relationships with other routers. This approach minimizes flooding traffic and synchronization complexity.

**Key Points:**

- Hierarchical areas limit flooding scope and improve scalability
- Hello protocol manages neighbor discovery and failure detection
- Multiple LSA types describe different network topology elements
- DR/BDR election optimizes multi-access network operations

