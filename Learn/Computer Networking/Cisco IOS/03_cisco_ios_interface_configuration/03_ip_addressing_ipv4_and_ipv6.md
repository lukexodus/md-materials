## IP Addressing (IPv4 and IPv6)


**IPv4 Configuration:**

```
Router(config-if)# ip address 192.168.1.1 255.255.255.0
Router(config-if)# ip address 10.1.1.1 255.255.255.252 secondary
```

The primary IP address is configured first, followed by any secondary addresses using the `secondary` keyword.

**DHCP Client Configuration:**

```
Router(config-if)# ip address dhcp
Router(config-if)# ip address dhcp hostname router1
```

**IPv6 Configuration:**

```
Router(config-if)# ipv6 address 2001:db8:1::1/64
Router(config-if)# ipv6 address fe80::1 link-local
Router(config-if)# ipv6 enable
```

**IPv6 Autoconfiguration:**

```
Router(config-if)# ipv6 address autoconfig
Router(config-if)# ipv6 address dhcp
```

**Dual Stack Configuration:** Both IPv4 and IPv6 can be configured simultaneously on the same interface:

```
Router(config-if)# ip address 192.168.1.1 255.255.255.0
Router(config-if)# ipv6 address 2001:db8:1::1/64
Router(config-if)# ipv6 enable
```

**Unnumbered Interfaces:**

```
Router(config-if)# ip unnumbered loopback0
```

This borrows the IP address from another interface, commonly used on point-to-point links.

