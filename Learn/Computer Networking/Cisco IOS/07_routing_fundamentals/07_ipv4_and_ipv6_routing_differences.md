## IPv4 and IPv6 Routing Differences


While routing fundamentals remain similar between IPv4 and IPv6, several operational and configuration differences exist due to protocol design changes.

**Enabling Routing:**

**IPv4**: Routing is enabled by default on Cisco routers. No global command required.

**IPv6**: Must be explicitly enabled:

```
Router(config)# ipv6 unicast-routing
```

Without this command, the router will not forward IPv6 packets or participate in IPv6 routing protocols.

**Address Configuration:**

**IPv4**: Requires manual IP address and subnet mask:

```
Router(config-if)# ip address 192.168.1.1 255.255.255.0
```

**IPv6**: Supports multiple configuration methods:

```
! Manual configuration
Router(config-if)# ipv6 address 2001:DB8:ACAD:1::1/64

! EUI-64 autoconfiguration
Router(config-if)# ipv6 address 2001:DB8:ACAD:1::/64 eui-64

! Link-local only
Router(config-if)# ipv6 enable
```

IPv6 interfaces automatically generate link-local addresses (FE80::/10) when IPv6 is enabled. Each interface can have multiple IPv6 addresses of different types simultaneously.

**Static Route Configuration:**

**IPv4**:

```
Router(config)# ip route 192.168.20.0 255.255.255.0 10.1.1.2
Router(config)# ip route 192.168.20.0 255.255.255.0 GigabitEthernet0/0
```

**IPv6**:

```
Router(config)# ipv6 route 2001:DB8:ACAD:2::/64 2001:DB8:ACAD:1::2
Router(config)# ipv6 route 2001:DB8:ACAD:2::/64 GigabitEthernet0/0
Router(config)# ipv6 route 2001:DB8:ACAD:2::/64 GigabitEthernet0/0 FE80::2
```

When using IPv6 link-local addresses as next-hop, exit interface must be specified because link-local addresses are not globally unique.

**Default Route Notation:**

**IPv4**: 0.0.0.0/0

```
Router(config)# ip route 0.0.0.0 0.0.0.0 203.0.113.1
```

**IPv6**: ::/0

```
Router(config)# ipv6 route ::/0 2001:DB8:FEED::1
```

**Routing Table Differences:**

**IPv4 Routing Table**:

```
Router# show ip route
```

Shows:

- Connected networks (C)
- Local interface addresses /32 (L)
- Static routes (S)
- Dynamic routes with protocol codes

**IPv6 Routing Table**:

```
Router# show ipv6 route
```

Shows:

- Connected networks (C)
- Local interface addresses /128 (L)
- Link-local routes (L) for FE80::/10
- Static routes (S)
- Dynamic routes with protocol codes

IPv6 routing table includes explicit entries for link-local addresses used for neighbor discovery and routing protocol adjacencies.

**NAT Requirements:**

**IPv4**: NAT (Network Address Translation) commonly used due to address exhaustion. Private addresses (RFC 1918) require translation for Internet access.

**IPv6**: NAT typically not required due to vast address space (128-bit addresses). Networks use global unicast addresses for end-to-end connectivity. NPTv6 (Network Prefix Translation) exists but is less common.

**Broadcast vs Multicast:**

**IPv4**: Uses broadcasts (255.255.255.255 or subnet broadcasts) for certain operations like ARP and DHCP discovery.

**IPv6**: No broadcast concept. Uses multicast addresses instead:

- All-nodes multicast: FF02::1
- All-routers multicast: FF02::2
- Solicited-node multicast: FF02::1:FF00:0/104

**Neighbor Discovery:**

**IPv4**: Uses ARP (Address Resolution Protocol) to map IP addresses to MAC addresses. ARP operates at Layer 2 and is separate from IP.

**IPv6**: Uses ICMPv6 Neighbor Discovery Protocol (NDP) with:

- Neighbor Solicitation (NS) - equivalent to ARP request
- Neighbor Advertisement (NA) - equivalent to ARP reply
- Router Solicitation (RS)
- Router Advertisement (RA)
- Redirect messages

NDP is integrated into ICMPv6, providing enhanced security and functionality.

**Routing Protocol Versions:**

**IPv4 Routing Protocols**: RIPv2, EIGRP for IPv4, OSPFv2, BGP-4

**IPv6 Routing Protocols**: RIPng (RIP next generation), EIGRP for IPv6, OSPFv3, BGP-4 (with IPv6 extensions)

Configuration differs significantly:

**OSPFv2 (IPv4)**:

```
Router(config)# router ospf 1
Router(config-router)# network 10.1.1.0 0.0.0.255 area 0
```

**OSPFv3 (IPv6)**:

```
Router(config)# ipv6 router ospf 1
Router(config-rtr)# router-id 1.1.1.1
Router(config)# interface GigabitEthernet0/0
Router(config-if)# ipv6 ospf 1 area 0
```

OSPFv3 is enabled per-interface rather than using network statements. It still requires an IPv4-format router ID even though routing IPv6.

**EIGRP Configuration:**

**EIGRP for IPv4**:

```
Router(config)# router eigrp 100
Router(config-router)# network 10.0.0.0
```

**EIGRP for IPv6**:

```
Router(config)# ipv6 router eigrp 100
Router(config-rtr)# eigrp router-id 1.1.1.1
Router(config-rtr)# no shutdown
Router(config)# interface GigabitEthernet0/0
Router(config-if)# ipv6 eigrp 100
```

IPv6 EIGRP requires explicit no shutdown command and is enabled per-interface.

**Administrative Distance:**

Administrative distance values remain the same for equivalent protocols between IPv4 and IPv6:

- Directly Connected: 0
- Static: 1
- EIGRP: 90 (internal), 170 (external)
- OSPF: 110
- RIP/RIPng: 120

**Fragmentation:**

**IPv4**: Routers can fragment packets if they exceed the MTU of outgoing interface. The fragment bit in IP header controls this behavior.

**IPv6**: Routers do not fragment packets. Source host must perform Path MTU Discovery to determine appropriate packet size. If packet exceeds MTU, router drops it and sends ICMPv6 "Packet Too Big" message back to source.

**Header Simplification:**

IPv6 header is simpler despite longer addresses:

- Fixed 40-byte header (IPv4 variable 20-60 bytes)
- No header checksum (reduces processing)
- No fragmentation fields in main header
- Options handled via extension headers

This simplification improves routing performance.

**Address Types in Routing:**

**IPv4**: Unicast, multicast (224.0.0.0/4), broadcast, limited broadcast

**IPv6**: Unicast (global, unique local, link-local), multicast (FF00::/8), anycast (assigned from unicast space). No broadcast addresses exist.

**Verification Commands:**

**IPv4**:

```
Router# show ip interface brief
Router# show ip route
Router# show ip protocols
Router# show ip arp
```

**IPv6**:

```
Router# show ipv6 interface brief
Router# show ipv6 route
Router# show ipv6 protocols
Router# show ipv6 neighbors
```

The `show ipv6 neighbors` command displays IPv6 neighbor discovery cache (equivalent to IPv4 ARP table).

**Key points:**

- Routing tables contain destination networks, administrative distance/metric in brackets, next-hop addresses, exit interfaces, and route sources indicated by protocol codes.
- Static routes are manually configured using destination network, subnet mask, and next-hop or exit interface, with fully specified routes combining both for optimal performance.
- Default routes (0.0.0.0/0 for IPv4, ::/0 for IPv6) match all destinations not matching more specific routes and function as gateway of last resort.
- Administrative distance (0-255) determines route preference between different sources, with lower values more trusted (connected=0, static=1, EIGRP=90, OSPF=110, RIP=120).
- Route summarization combines contiguous networks into single advertisement by identifying common leftmost bits, reducing table size and update overhead.
- Floating static routes use higher administrative distance values than primary routes to create automatic failover when primary paths fail, typically configured 5-10 AD values above the primary route source.
- IPv6 routing requires explicit enablement with `ipv6 unicast-routing`, uses link-local addresses for next-hop on local links, lacks broadcast support, and integrates neighbor discovery into ICMPv6 rather than using separate ARP protocol.

