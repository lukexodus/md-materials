## Floating Static Routes


A floating static route is a backup static route configured with a higher administrative distance than the primary route. It remains inactive in the routing table until the primary route fails, then automatically takes over.

**Floating Static Route Concept:**

By default, static routes have AD of 1, making them more preferred than any dynamic routing protocol. By increasing the AD of a backup static route above the primary route's AD, the backup "floats" above the routing table, installing only when needed.

**Configuration Syntax:**

```
Router(config)# ip route [destination] [mask] [next-hop] [AD-value]
```

**Basic Floating Static Route Example:**

Primary route learned via OSPF (AD 110):

```
Router(config)# router ospf 1
Router(config-router)# network 10.0.0.0 0.255.255.255 area 0
```

Backup floating static route with AD 115:

```
Router(config)# ip route 0.0.0.0 0.0.0.0 Serial0/1/0 115
```

Under normal conditions, OSPF route is installed (AD 110). If OSPF route fails, the static route (AD 115) is installed.

**Floating Static Default Route:**

Common implementation for backup Internet connectivity:

```
! Primary default route via OSPF
Router(config)# router ospf 1
Router(config-router)# default-information originate

! Backup floating static default route via secondary ISP
Router(config)# ip route 0.0.0.0 0.0.0.0 203.0.113.5 120
```

If OSPF-learned default route fails, router automatically switches to static default route.

**Multiple Floating Static Routes:**

You can configure multiple backup routes with progressively higher AD values:

```
! Primary EIGRP route (AD 90)
Router(config)# router eigrp 100
Router(config-router)# network 10.0.0.0

! First backup - static route with AD 95
Router(config)# ip route 192.168.100.0 255.255.255.0 10.1.1.2 95

! Second backup - static route with AD 100
Router(config)# ip route 192.168.100.0 255.255.255.0 10.2.2.2 100
```

Routes install in order: EIGRP (90) → 10.1.1.2 (95) → 10.2.2.2 (100) as each previous route fails.

**IPv6 Floating Static Routes:**

```
! Primary OSPFv3 route (AD 110)
Router(config)# ipv6 router ospf 1
Router(config-rtr)# router-id 1.1.1.1

! Backup floating static route with AD 120
Router(config)# ipv6 route ::/0 Serial0/1/0 2001:DB8:FEED::1 120
```

**Tracking Objects for More Reliable Failover:**

[Inference] Basic floating static routes depend on interface status or routing protocol convergence to trigger failover. IP SLA (Service Level Agreement) tracking provides more sophisticated failure detection:

```
! Configure IP SLA to ping critical destination
Router(config)# ip sla 1
Router(config-ip-sla)# icmp-echo 203.0.113.1
Router(config-ip-sla-echo)# frequency 10
Router(config-ip-sla-echo)# exit
Router(config)# ip sla schedule 1 start-time now life forever

! Create tracking object
Router(config)# track 1 ip sla 1 reachability

! Primary static route with tracking
Router(config)# ip route 0.0.0.0 0.0.0.0 203.0.113.1 track 1

! Floating static route as backup
Router(config)# ip route 0.0.0.0 0.0.0.0 198.51.100.1 10
```

If ICMP echo to 203.0.113.1 fails, tracking object becomes down, primary route is removed, and floating static route (AD 10) is installed.

**Use Cases:**

- Redundant WAN links where primary uses MPLS and backup uses Internet
- Dual ISP connections for Internet redundancy
- Branch offices with primary dynamic routing and backup static paths
- Cost-sensitive scenarios where backup link should only activate when primary fails

**Verification:**

```
Router# show ip route
Router# show ip route static
Router# show track
Router# show ip sla statistics
```

When primary route is active, floating static won't appear in routing table. It only appears after primary fails.

**Considerations:**

- Failover speed depends on interface failure detection or routing protocol convergence time
- Floating static routes don't provide load balancing (only one route active at a time)
- Ensure backup path AD is higher than all primary routing sources
- Test failover scenarios to verify proper operation

