## Default Routes


A default route is a special static route matching all packets that don't match any other specific route in the routing table. It functions as a "gateway of last resort," forwarding traffic to unknown destinations.

**IPv4 Default Route Configuration:**

```
Router(config)# ip route 0.0.0.0 0.0.0.0 [next-hop-ip | exit-interface]
```

**Example Configurations:**

```
! Next-hop default route
Router(config)# ip route 0.0.0.0 0.0.0.0 203.0.113.1

! Exit interface default route
Router(config)# ip route 0.0.0.0 0.0.0.0 Serial0/0/0

! Fully specified default route
Router(config)# ip route 0.0.0.0 0.0.0.0 Serial0/0/0 203.0.113.1
```

The 0.0.0.0/0 notation represents all possible IP addresses (match everything), with a prefix length of zero bits.

**IPv6 Default Route Configuration:**

```
Router(config)# ipv6 route ::/0 [next-hop-ipv6 | exit-interface]

! Examples
Router(config)# ipv6 route ::/0 2001:DB8:ACAD:1::1
Router(config)# ipv6 route ::/0 Serial0/0/0
Router(config)# ipv6 route ::/0 Serial0/0/0 FE80::1
```

The ::/0 notation is IPv6 equivalent, representing all IPv6 addresses with zero prefix length.

**Default Route Use Cases:**

- **Stub Networks**: Networks with only one exit point don't need specific routes to every external destination
- **ISP Connections**: Customer routers forward all Internet-bound traffic to ISP without maintaining full Internet routing table
- **Hub-and-Spoke Topologies**: Spoke routers use default routes pointing to hub
- **Simplifying Configuration**: Reduces routing table size and configuration complexity

**Propagating Default Routes:**

Dynamic routing protocols can advertise default routes to other routers:

```
! OSPF default route propagation
Router(config)# router ospf 1
Router(config-router)# default-information originate

! EIGRP default route propagation
Router(config)# router eigrp 100
Router(config-router)# redistribute static

! RIPv2 default route propagation
Router(config)# router rip
Router(config-router)# default-information originate
```

**Verification:**

```
Router# show ip route
Router# show ip route 0.0.0.0
Router# show ipv6 route
Router# show ipv6 route ::/0
```

A default route appears in the routing table as:

```
S*   0.0.0.0/0 [1/0] via 203.0.113.1
```

The asterisk (*) denotes this as the gateway of last resort.

**Default Route Priority:**

If multiple default routes exist (static and dynamically learned), the router selects based on administrative distance. A static default route (AD 1) is preferred over OSPF external default route (AD 110).

