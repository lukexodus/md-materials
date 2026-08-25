## Routing Information Protocol (RIP)


RIP implements distance vector routing using hop count as the sole metric, limiting network diameter to 15 hops maximum. Version 1 broadcasts routing updates every 30 seconds without authentication, while Version 2 adds subnet mask support, multicast updates, and authentication mechanisms.

Route advertisements contain destination networks with associated hop counts. Routers increment hop counts when relaying updates, preventing direct metric comparison. Invalid routes receive hop counts of 16, indicating unreachable destinations.

Split horizon with poison reverse prevents immediate routing loops by advertising unreachable routes back to sources. Hold-down timers maintain failed routes in hold-down state, suppressing potentially incorrect updates. Triggered updates immediately advertise topology changes without waiting for periodic intervals.

RIP converges slowly compared to modern protocols due to periodic update intervals and counting-to-infinity behavior. Compatibility with legacy equipment and simple configuration maintain RIP usage in small networks despite performance limitations.

**Key Points:**

- Hop count metric limits network scalability to 15-hop maximum
- Version 2 improvements include VLSM support and authentication
- Loop prevention relies on split horizon and hold-down mechanisms
- Slow convergence limits applicability to small, stable networks

