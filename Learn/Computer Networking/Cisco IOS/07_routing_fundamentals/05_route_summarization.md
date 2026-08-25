## Route Summarization


Route summarization (also called route aggregation or supernetting) combines multiple contiguous network addresses into a single routing advertisement. This reduces routing table size, decreases routing update traffic, and improves network stability.

**Benefits of Route Summarization:**

- **Smaller Routing Tables**: Fewer entries consume less memory and reduce lookup time
- **Reduced Update Traffic**: Less bandwidth consumed by routing protocol updates
- **Stability**: Topology changes within summarized area don't trigger updates outside the summary boundary
- **Faster Convergence**: Fewer routes to recalculate during topology changes
- **Reduced CPU Utilization**: Less processing required for routing updates

**Summarization Requirements:**

Networks must be contiguous and properly subnetted for summarization. You cannot summarize non-contiguous address blocks into a single summary.

**Calculating Summary Routes:**

To create a summary route:

1. Convert network addresses to binary
2. Identify common leftmost bits across all networks
3. Count the number of common bits (this becomes subnet mask)
4. Set remaining bits to zero for summary network address

**Example Calculation:**

Summarize these networks:

- 192.168.16.0/24
- 192.168.17.0/24
- 192.168.18.0/24
- 192.168.19.0/24

Binary representation:

```
192.168.16.0 = 11000000.10101000.00010000.00000000
192.168.17.0 = 11000000.10101000.00010001.00000000
192.168.18.0 = 11000000.10101000.00010010.00000000
192.168.19.0 = 11000000.10101000.00010011.00000000
                                  ^^ These bits differ
```

Common bits: 22 bits match (11000000.10101000.000100)

Summary route: 192.168.16.0/22 (covers 192.168.16.0 through 192.168.19.255)

**CIDR Block Size Reference:**

- /22 = 4 Class C networks (1024 addresses)
- /23 = 2 Class C networks (512 addresses)
- /21 = 8 Class C networks (2048 addresses)
- /20 = 16 Class C networks (4096 addresses)

**OSPF Route Summarization:**

OSPF performs summarization at Area Border Routers (ABRs) when routes are injected from one area into the backbone, and at Autonomous System Boundary Routers (ASBRs) for external routes.

```
! Summarization at ABR for inter-area routes
Router(config)# router ospf 1
Router(config-router)# area 1 range 192.168.16.0 255.255.252.0

! Summarization for external routes at ASBR
Router(config-router)# summary-address 10.0.0.0 255.0.0.0
```

**EIGRP Route Summarization:**

EIGRP allows manual summarization on any interface, providing flexibility for network design:

```
Router(config)# interface GigabitEthernet0/0
Router(config-if)# ip summary-address eigrp 100 192.168.16.0 255.255.252.0

! IPv6 EIGRP summarization
Router(config-if)# ipv6 summary-address eigrp 100 2001:DB8:ACAD::/48
```

When EIGRP creates a summary route, it automatically installs a local summary route to the Null0 interface to prevent routing loops for addresses within the summary range that don't have specific matches.

**BGP Route Summarization:**

BGP uses the aggregate-address command:

```
Router(config)# router bgp 65001
Router(config-router)# aggregate-address 192.168.0.0 255.255.0.0 summary-only
```

The `summary-only` keyword suppresses advertisement of more specific routes, sending only the aggregate.

**Static Route Summarization:**

Static routes can be manually configured as summaries:

```
Router(config)# ip route 192.168.16.0 255.255.252.0 10.1.1.2
```

This single static route replaces multiple specific static routes for 192.168.16.0/24 through 192.168.19.0/24.

**Discontiguous Networks:**

[Inference] Networks separated by different major network addresses cannot be summarized together without including unwanted address space. For example, attempting to summarize 10.1.0.0/16 and 10.3.0.0/16 into 10.0.0.0/14 also includes 10.2.0.0/16, which may not be part of your network.

**Verification Commands:**

```
Router# show ip route
Router# show ip protocols
Router# show ip ospf border-routers
Router# show ip eigrp topology
```

