## Administrative Distance


Administrative Distance (AD) is a value representing the trustworthiness or reliability of a routing information source. When a router learns routes to the same destination from multiple sources, AD determines which route is installed in the routing table. Lower AD values indicate more trusted sources.

**Default Administrative Distance Values:**

|Route Source|AD Value|
|---|---|
|Directly Connected|0|
|Static Route|1|
|EIGRP Summary Route|5|
|External BGP (eBGP)|20|
|Internal EIGRP|90|
|OSPF|110|
|IS-IS|115|
|RIP|120|
|External EIGRP|170|
|Internal BGP (iBGP)|200|
|Unknown/Unreliable|255 (not installed)|

**Route Selection Process:**

When multiple routes to the same destination exist:

1. Router compares prefix lengths first (longest match wins)
2. If prefix lengths are equal, compares administrative distances
3. Route with lowest AD is installed in routing table
4. If ADs are equal, metric determines selection (protocol-specific)
5. If metrics are equal, load balancing may occur (if supported)

**Viewing Administrative Distance:**

```
Router# show ip route
D    192.168.20.0/24 [90/2170112] via 10.1.1.2, 00:05:32, GigabitEthernet0/0
```

The first number in brackets [90/2170112] is the AD (90 = EIGRP internal).

**Modifying Administrative Distance:**

You can adjust AD values to prefer certain routing sources over others, though this should be done carefully:

**Static Route AD Modification:**

```
Router(config)# ip route 192.168.20.0 255.255.255.0 10.1.1.2 150
```

This creates a floating static route (covered in detail in a later section) with AD 150, making it less preferred than OSPF (110) or RIP (120) but available as backup.

**Routing Protocol AD Modification:**

```
! Modify OSPF distance for all OSPF routes
Router(config)# router ospf 1
Router(config-router)# distance 115

! Modify EIGRP distance for all EIGRP routes
Router(config)# router eigrp 100
Router(config-router)# distance eigrp 95 175
```

The EIGRP command sets internal EIGRP routes to AD 95 and external to AD 175.

**Selective AD Modification with Access Lists:**

```
Router(config)# access-list 1 permit 192.168.10.0 0.0.0.255
Router(config)# router ospf 1
Router(config-router)# distance 95 10.1.1.2 0.0.0.0 1
```

This sets AD to 95 only for OSPF routes from neighbor 10.1.1.2 matching access-list 1.

**AD vs Metric:**

AD and metric serve different purposes:

- **AD**: Compares trustworthiness between different routing protocols or sources
- **Metric**: Compares path quality within the same routing protocol

AD is evaluated first. Only if AD values are equal does the router compare metrics.

**Example scenario:**

```
O    192.168.50.0/24 [110/65] via 10.1.1.2, 00:10:23, GigabitEthernet0/0
D    192.168.50.0/24 [90/2170112] via 10.2.1.2, 00:08:15, GigabitEthernet0/1
```

Even though OSPF has a better metric (65 vs 2170112), EIGRP route is installed because EIGRP AD (90) is lower than OSPF AD (110). Metrics from different protocols cannot be directly compared.

**AD Best Practices:**

- Avoid modifying default AD values unless absolutely necessary
- Document any AD changes thoroughly
- Understand that changing AD can affect routing behavior network-wide
- Use AD modification sparingly for traffic engineering or creating backup paths

