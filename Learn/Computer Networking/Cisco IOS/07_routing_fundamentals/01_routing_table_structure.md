## Routing Table Structure


The routing table is a data structure stored in router memory containing information about network destinations and the paths to reach them. Routers consult this table to make forwarding decisions for every packet.

**Routing Table Components:**

Each route entry contains specific fields that guide forwarding decisions:

- **Route Source**: Indicates how the route was learned (directly connected, static, dynamic routing protocol). Denoted by codes such as C (connected), S (static), R (RIP), D (EIGRP), O (OSPF), B (BGP).
- **Destination Network**: The target network address and subnet mask in CIDR notation (e.g., 192.168.10.0/24).
- **Administrative Distance**: Trustworthiness metric of the route source (lower is more preferred). Shown in brackets [AD/Metric].
- **Metric**: Cost to reach the destination network, calculated differently by each routing protocol. Shown in brackets [AD/Metric].
- **Next-Hop Address**: IP address of the next router in the path to the destination, or the exit interface.
- **Exit Interface**: The local interface through which packets should be forwarded to reach the next hop.
- **Route Timestamp**: How long the route has been in the routing table.

**Viewing the Routing Table:**

```
Router# show ip route
Router# show ip route [network]
Router# show ip route [protocol]
Router# show ipv6 route
```

**Example Routing Table Entry:**

```
D    192.168.20.0/24 [90/2170112] via 10.1.1.2, 00:05:32, GigabitEthernet0/0
```

This breaks down as:

- D = EIGRP learned route
- 192.168.20.0/24 = destination network
- [90/2170112] = administrative distance 90, metric 2170112
- via 10.1.1.2 = next-hop IP address
- 00:05:32 = route age in routing table
- GigabitEthernet0/0 = exit interface

**Route Types:**

- **Directly Connected (C)**: Networks attached to router interfaces that are in up/up state. Automatically added when interface is configured with an IP address and activated.
- **Local (L)**: The specific IP address configured on the router interface, always with /32 mask for IPv4 or /128 for IPv6. Used for local packet processing.
- **Static (S)**: Manually configured routes that remain until administratively removed or interface goes down.
- **Dynamic**: Routes learned through routing protocols like RIP, EIGRP, OSPF, or BGP.

**Longest Prefix Match:**

When multiple routes match a destination, the router selects the route with the longest prefix length (most specific match). A packet destined for 192.168.10.50 would prefer route 192.168.10.0/24 over 192.168.0.0/16, even if the latter has a better metric.

**Route Lookup Process:**

1. Router receives packet and extracts destination IP address
2. Searches routing table for longest prefix match
3. If match found, forwards packet to next-hop or exit interface
4. If no match found, uses default route if configured
5. If no default route exists, drops packet and sends ICMP Destination Unreachable

**Classful vs Classless Routing Table:**

Modern routers use classless routing tables, displaying routes with their specific subnet masks regardless of class boundaries. The `ip classless` command (enabled by default) allows routers to forward packets using supernet routes when no exact match exists.

**Route Recursion:**

When a route lists only a next-hop IP address without an exit interface, the router must perform recursive lookup to determine the actual exit interface by finding another route that resolves the next-hop address.

