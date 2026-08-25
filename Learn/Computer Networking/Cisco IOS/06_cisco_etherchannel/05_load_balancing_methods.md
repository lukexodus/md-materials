## Load Balancing Methods


EtherChannel uses various algorithms to distribute traffic across member links, ensuring efficient utilization of available bandwidth.

**Load Balancing Options:**

**Source MAC Address:**

```
Switch(config)# port-channel load-balance src-mac
```

Traffic distribution based on source MAC address. Ensures frames from the same source follow the same path.

**Destination MAC Address:**

```
Switch(config)# port-channel load-balance dst-mac
```

Traffic distribution based on destination MAC address. Ensures frames to the same destination follow the same path.

**Source and Destination MAC:**

```
Switch(config)# port-channel load-balance src-dst-mac
```

Uses both source and destination MAC addresses for load balancing, providing better distribution.

**Source IP Address:**

```
Switch(config)# port-channel load-balance src-ip
```

Distribution based on source IP address for Layer 3 traffic.

**Destination IP Address:**

```
Switch(config)# port-channel load-balance dst-ip
```

Distribution based on destination IP address for Layer 3 traffic.

**Source and Destination IP:**

```
Switch(config)# port-channel load-balance src-dst-ip
```

Uses both source and destination IP addresses, providing optimal distribution for most scenarios.

**Source and Destination Port:**

```
Switch(config)# port-channel load-balance src-dst-port
```

Includes Layer 4 port numbers in the load-balancing algorithm.

**Algorithm Operation:** The switch performs a hash calculation on selected packet fields to determine which physical link carries each frame. The same flow always uses the same physical link, maintaining packet ordering.

**Platform Variations:** Different Cisco platforms support different load-balancing methods. Newer platforms typically support more sophisticated algorithms including Layer 4 information.

