## Network Configuration


### Network Interface Concepts

#### Physical and Virtual Interfaces

Network interfaces represent the connection points between a Linux system and networks. Physical interfaces correspond to actual hardware network adapters (Ethernet cards, wireless adapters), while virtual interfaces are software-created abstractions that provide network functionality without dedicated hardware.

#### Interface Naming Conventions

Modern Linux distributions use predictable network interface names based on hardware characteristics rather than the traditional `eth0`, `eth1` naming scheme. This systemd-based naming provides consistent interface identification across reboots and hardware changes.

**Ethernet interfaces:**

- `enp0s3` - PCI bus 0, slot 3 Ethernet interface
- `eno1` - Onboard Ethernet interface 1
- `enx001122334455` - Ethernet interface with MAC address 00:11:22:33:44:55

**Wireless interfaces:**

- `wlp2s0` - PCI bus 2, slot 0 wireless interface
- `wlan0` - Traditional wireless naming (still used on some systems)

**Virtual interfaces:**

- `lo` - Loopback interface (127.0.0.1)
- `virbr0` - Virtual bridge interface
- `tun0`, `tap0` - VPN tunnel interfaces
- `docker0` - Docker bridge interface

#### Interface States and Properties

Network interfaces exist in various operational states that determine their functionality:

**UP/DOWN** - Administrative state controlled by system administrators. An interface marked DOWN cannot transmit or receive traffic regardless of physical connectivity.

**RUNNING** - Indicates active network connection with carrier signal detected on physical interfaces.

**MULTICAST** - Interface supports multicast packet transmission, essential for many network protocols.

**BROADCAST** - Interface supports broadcast packet transmission within its network segment.

**LOOPBACK** - Special interface type for internal system communication.

#### MAC Addresses and Hardware Properties

Each network interface has a unique Media Access Control (MAC) address, a 48-bit identifier typically displayed in hexadecimal format (e.g., `00:11:22:33:44:55`). MAC addresses operate at the data link layer and are used for local network communication within the same broadcast domain.

### IP Address Configuration

#### IPv4 Address Structure

IPv4 addresses consist of 32-bit values typically expressed in dotted decimal notation (e.g., `192.168.1.100`). Each address includes a network portion and host portion determined by the subnet mask or CIDR notation.

**Address Classes and Private Ranges:**

- Class A: `10.0.0.0/8` (10.0.0.0 - 10.255.255.255)
- Class B: `172.16.0.0/12` (172.16.0.0 - 172.31.255.255)
- Class C: `192.168.0.0/16` (192.168.0.0 - 192.168.255.255)

#### Subnet Masks and CIDR Notation

Subnet masks define which portion of an IP address represents the network and which represents the host. CIDR (Classless Inter-Domain Routing) notation provides a more flexible way to express network prefixes.

**Examples:**

- `192.168.1.100/24` - 24-bit network prefix, 8-bit host portion
- `10.0.0.0/8` - 8-bit network prefix, 24-bit host portion
- `172.16.50.0/28` - 28-bit network prefix, 4-bit host portion (16 total addresses)

#### IPv6 Address Configuration

IPv6 uses 128-bit addresses expressed in hexadecimal notation with colon separators (e.g., `2001:db8::1`). IPv6 supports multiple address types including global unicast, link-local, and unique local addresses.

**IPv6 Address Types:**

- Global Unicast: Routable on the internet (e.g., `2001:db8::/32`)
- Link-Local: Automatic configuration for local segment (e.g., `fe80::/10`)
- Unique Local: Private addressing similar to IPv4 RFC 1918 (e.g., `fd00::/8`)

#### Multiple IP Addresses

Linux interfaces can host multiple IP addresses simultaneously, enabling complex networking scenarios:

**Primary and Secondary Addresses** - One primary address per interface with additional secondary addresses for multi-homing or service binding.

**Address Aliases** - Traditional method using interface aliases like `eth0:1`, `eth0:2` for additional addresses.

**Modern Multiple Address Assignment** - Current approach assigns multiple addresses directly to the interface without alias notation.

### Static vs DHCP Configuration

#### Static IP Configuration

Static configuration involves manually assigning fixed IP addresses, subnet masks, gateways, and DNS servers. This approach provides predictable addressing but requires manual management.

**Advantages of Static Configuration:**

- Predictable IP addresses for servers and infrastructure
- No dependency on DHCP server availability
- Simplified troubleshooting with known addresses
- Better security control over address assignments
- Consistent configuration across reboots

**Disadvantages of Static Configuration:**

- Manual configuration overhead
- Potential for IP address conflicts
- Difficulty managing large numbers of devices
- No automatic adaptation to network changes

#### DHCP Configuration

Dynamic Host Configuration Protocol (DHCP) automatically assigns IP addresses and network configuration parameters to devices. DHCP servers maintain pools of available addresses and lease them to clients for specified time periods.

**DHCP Process (DORA):**

1. **Discover** - Client broadcasts request for IP configuration
2. **Offer** - DHCP server responds with available IP address
3. **Request** - Client requests the offered configuration
4. **Acknowledge** - Server confirms the lease assignment

**DHCP Configuration Parameters:**

- IP address and subnet mask
- Default gateway address
- DNS server addresses
- Domain name and search domains
- Lease duration and renewal times
- NTP server addresses
- Boot server information

**Advantages of DHCP:**

- Automatic address assignment and management
- Reduced configuration errors
- Easy network parameter updates
- Efficient address space utilization
- Simplified device deployment

**Disadvantages of DHCP:**

- Dependency on DHCP server availability
- Potential for address changes
- Additional network infrastructure required
- Security considerations with rogue DHCP servers

#### DHCP Reservations

DHCP reservations combine DHCP automation with static address predictability by associating specific MAC addresses with fixed IP addresses. This approach provides automatic configuration while ensuring consistent addressing for critical systems.

### Interface Tools (`ip`, `ifconfig`)

#### The `ip` Command Suite

The `ip` command is the modern, comprehensive tool for network configuration and monitoring in Linux. It replaces several older utilities with a unified interface and supports advanced networking features.

#### Viewing Interface Information

**Display all interfaces:**

```bash
ip link show
ip addr show
```

**Display specific interface:**

```bash
ip link show eth0
ip addr show eth0
```

**Show interface statistics:**

```bash
ip -s link show eth0
```

#### Configuring IP Addresses

**Add IP address:**

```bash
ip addr add 192.168.1.100/24 dev eth0
```

**Add multiple addresses:**

```bash
ip addr add 192.168.1.100/24 dev eth0
ip addr add 192.168.1.101/24 dev eth0
```

**Remove IP address:**

```bash
ip addr del 192.168.1.100/24 dev eth0
```

#### Interface State Management

**Bring interface up:**

```bash
ip link set eth0 up
```

**Bring interface down:**

```bash
ip link set eth0 down
```

**Change MAC address:**

```bash
ip link set eth0 address 00:11:22:33:44:55
```

#### Routing Configuration

**View routing table:**

```bash
ip route show
```

**Add default gateway:**

```bash
ip route add default via 192.168.1.1
```

**Add specific route:**

```bash
ip route add 10.0.0.0/8 via 192.168.1.254
```

**Delete route:**

```bash
ip route del 10.0.0.0/8
```

#### Advanced `ip` Features

**Neighbor (ARP) table management:**

```bash
ip neigh show
ip neigh add 192.168.1.50 lladdr 00:11:22:33:44:55 dev eth0
```

**Network namespace operations:**

```bash
ip netns add namespace1
ip netns exec namespace1 ip addr show
```

**VLAN configuration:**

```bash
ip link add link eth0 name eth0.100 type vlan id 100
```

#### The `ifconfig` Command (Legacy)

The `ifconfig` command is the traditional network configuration tool, still available on many systems but considered deprecated in favor of the `ip` command suite.

#### Basic `ifconfig` Usage

**Display all interfaces:**

```bash
ifconfig
ifconfig -a  # Include inactive interfaces
```

**Display specific interface:**

```bash
ifconfig eth0
```

**Configure IP address:**

```bash
ifconfig eth0 192.168.1.100 netmask 255.255.255.0
```

**Bring interface up/down:**

```bash
ifconfig eth0 up
ifconfig eth0 down
```

#### `ifconfig` vs `ip` Comparison

**Key points:**

- `ip` command provides more comprehensive functionality
- `ifconfig` syntax is often more intuitive for basic operations
- `ip` supports modern networking features like namespaces and VLAN tagging
- Many distributions no longer install `ifconfig` by default
- `ip` provides better scripting and automation capabilities

#### Network Configuration Files

#### Debian/Ubuntu Configuration

**`/etc/network/interfaces`** - Primary network configuration file for Debian-based systems:

```bash
# Static configuration
auto eth0
iface eth0 inet static
    address 192.168.1.100
    netmask 255.255.255.0
    gateway 192.168.1.1
    dns-nameservers 8.8.8.8 8.8.4.4

# DHCP configuration
auto eth1
iface eth1 inet dhcp
```

#### Red Hat/CentOS Configuration

**`/etc/sysconfig/network-scripts/ifcfg-eth0`** - Interface-specific configuration files:

```bash
# Static configuration
DEVICE=eth0
BOOTPROTO=static
ONBOOT=yes
IPADDR=192.168.1.100
NETMASK=255.255.255.0
GATEWAY=192.168.1.1
DNS1=8.8.8.8
DNS2=8.8.4.4

# DHCP configuration
DEVICE=eth1
BOOTPROTO=dhcp
ONBOOT=yes
```

#### NetworkManager and systemd-networkd

Modern Linux distributions increasingly use NetworkManager or systemd-networkd for network management, providing dynamic configuration and integration with desktop environments.

**NetworkManager CLI commands:**

```bash
nmcli device show
nmcli connection show
nmcli connection add type ethernet ifname eth0 con-name "Static Connection" ip4 192.168.1.100/24 gw4 192.168.1.1
```

### Troubleshooting Network Configuration

#### Common Diagnostic Commands

**Test connectivity:**

```bash
ping 192.168.1.1
ping -c 4 google.com
```

**Trace network path:**

```bash
traceroute google.com
mtr google.com  # Continuous trace
```

**Check DNS resolution:**

```bash
nslookup google.com
dig google.com
host google.com
```

**Monitor network traffic:**

```bash
tcpdump -i eth0
netstat -tuln  # Show listening ports
ss -tuln       # Modern alternative to netstat
```

#### Configuration Verification

**Key points:**

- Verify IP address assignment matches requirements
- Confirm subnet mask allows communication with intended hosts
- Test default gateway connectivity
- Validate DNS server configuration and resolution
- Check interface state and carrier signal
- Monitor for IP address conflicts

#### Common Configuration Issues

**IP address conflicts** - Multiple devices using the same IP address cause intermittent connectivity issues. [Inference] This typically occurs with static configurations in environments without proper IP address management.

**Incorrect subnet masks** - Wrong subnet masks prevent communication with hosts that should be reachable. [Inference] This often manifests as inability to reach the default gateway or other local systems.

**DNS configuration problems** - Incorrect DNS servers prevent hostname resolution while IP connectivity remains functional.

**Interface state issues** - Interfaces may be administratively down or lack carrier signal due to cable or switch port problems.

**Key points:** Network configuration in Linux involves understanding interface concepts, properly configuring IP addresses, choosing appropriate static or DHCP configuration methods, and effectively using modern tools like `ip` command for management and troubleshooting. [Inference] Proper network configuration is fundamental to system connectivity and requires careful attention to addressing schemes, routing, and DNS configuration to ensure reliable network operations.

---

