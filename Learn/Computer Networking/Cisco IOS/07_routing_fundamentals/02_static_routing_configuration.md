## Static Routing Configuration


Static routes are manually configured path entries that specify how to reach specific destination networks. They remain in the routing table until removed or until the associated interface goes down.

**Standard Static Route Syntax:**

```
Router(config)# ip route [destination-network] [subnet-mask] [next-hop-ip | exit-interface]
```

**Next-Hop Static Route:**

```
Router(config)# ip route 192.168.20.0 255.255.255.0 10.1.1.2
```

The router performs recursive lookup to determine which interface connects to 10.1.1.2 before forwarding packets. This adds slight processing overhead but is necessary on multi-access networks.

**Exit Interface Static Route:**

```
Router(config)# ip route 192.168.20.0 255.255.255.0 GigabitEthernet0/1
```

Packets are forwarded directly out the specified interface. This works well for point-to-point links but creates issues on multi-access networks where the router doesn't know the Layer 2 address for encapsulation.

**Fully Specified Static Route:**

```
Router(config)# ip route 192.168.20.0 255.255.255.0 GigabitEthernet0/1 10.1.1.2
```

Specifies both exit interface and next-hop address, combining benefits of both methods. The router knows exactly where to forward without recursive lookup and has the next-hop IP for ARP resolution. This is the preferred configuration method for most scenarios.

**IPv6 Static Route Configuration:**

```
Router(config)# ipv6 unicast-routing
Router(config)# ipv6 route 2001:DB8:ACAD:2::/64 2001:DB8:ACAD:1::2
Router(config)# ipv6 route 2001:DB8:ACAD:2::/64 GigabitEthernet0/0
Router(config)# ipv6 route 2001:DB8:ACAD:2::/64 GigabitEthernet0/0 2001:DB8:ACAD:1::2
```

IPv6 static routes follow the same logic as IPv4, but the `ipv6 unicast-routing` command must be enabled first to activate IPv6 routing.

**Link-Local Next-Hop (IPv6):**

When using IPv6 link-local addresses as next-hop, the exit interface must be specified:

```
Router(config)# ipv6 route 2001:DB8:ACAD:2::/64 GigabitEthernet0/0 FE80::2
```

Link-local addresses are not unique globally, so the router needs to know which interface connects to that link-local address.

**Static Route Verification:**

```
Router# show ip route static
Router# show ipv6 route static
Router# show running-config | section ip route
Router# show ip route [destination-network]
```

**When to Use Static Routes:**

- Small networks with few routers and predictable topology
- Stub networks with single exit point
- Default routes to ISPs
- Backup routes for dynamic routing protocol failures
- Security-sensitive paths requiring explicit control
- Reducing routing protocol overhead and bandwidth

**Static Route Limitations:**

- No automatic adaptation to topology changes
- Administrative burden increases with network size
- Human configuration errors can create routing loops or black holes
- Lack of load balancing capabilities compared to dynamic protocols (though multiple static routes to same destination enable basic load sharing)

