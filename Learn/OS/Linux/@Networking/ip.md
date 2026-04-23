# ip

The modern replacement for `ifconfig`, `route`, `arp`, and `netstat`. Part of the `iproute2` package. Manages network interfaces, addresses, routes, tunnels, and more.

---

## Basic Structure

```bash
ip [options] <object> <command> [arguments]
```

Objects: `link`, `address`, `route`, `neighbour`, `rule`, `tunnel`, `maddress`, `monitor`, and more.

Most objects can be abbreviated: `address` → `a`, `link` → `l`, `route` → `r`, `neighbour` → `n`.

---

## Global Options

|Option|Action|
|---|---|
|`-4`|IPv4 only|
|`-6`|IPv6 only|
|`-b <file>`|Read commands from a batch file|
|`-c`|Colorize output|
|`-j`|JSON output|
|`-p`|Pretty-print JSON (use with `-j`)|
|`-s`|Show statistics (use twice for more detail)|
|`-h`|Human-readable sizes with `-s`|
|`-n <netns>`|Operate in a named network namespace|
|`-br`|Brief output (compact table)|
|`-o`|One line per record|

```bash
ip -c a                     # colorized address list
ip -j -p route              # pretty JSON route table
ip -4 a                     # IPv4 addresses only
ip -s link                  # interface stats
ip -br a                    # brief address table
```

---

## ip link — Network Interfaces

Manages network interfaces at the link layer (Layer 2).

### Viewing

```bash
ip link show                        # all interfaces
ip link show eth0                   # specific interface
ip link show type bridge            # filter by type
ip link show type vlan
ip link show up                     # only interfaces that are up
ip -br link show                    # compact table
ip -s link show eth0                # with traffic statistics
ip -s -s link show eth0             # even more statistics
```

**Example output:**

```
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP
    link/ether 52:54:00:ab:cd:ef brd ff:ff:ff:ff:ff:ff
```

Flags in `<...>`: `UP` — interface enabled. `LOWER_UP` — physical link detected. `BROADCAST` — supports broadcast. `MULTICAST` — supports multicast. `NO-CARRIER` — cable unplugged.

### Bringing Interfaces Up/Down

```bash
ip link set eth0 up
ip link set eth0 down
```

### Changing Interface Properties

```bash
ip link set eth0 mtu 9000               # set MTU (jumbo frames)
ip link set eth0 address 52:54:00:11:22:33   # change MAC address
ip link set eth0 txqueuelen 10000       # set transmit queue length
ip link set eth0 promisc on             # enable promiscuous mode
ip link set eth0 promisc off
ip link set eth0 multicast on
ip link set eth0 name eth1              # rename interface (must be down first)
ip link set eth0 master br0             # add to bridge
ip link set eth0 nomaster               # remove from bridge
```

### Virtual Interfaces

```bash
# VLAN
ip link add link eth0 name eth0.10 type vlan id 10

# Bridge
ip link add name br0 type bridge

# Bonding
ip link add name bond0 type bond
ip link set eth0 master bond0
ip link set eth1 master bond0

# Dummy (loopback-like)
ip link add dummy0 type dummy

# VETH pair (used in containers)
ip link add veth0 type veth peer name veth1

# Delete
ip link delete eth0.10
ip link delete br0
```

---

## ip address — IP Addresses

Manages IP addresses on interfaces (Layer 3).

### Viewing

```bash
ip address show                     # all interfaces and addresses
ip address show eth0                # specific interface
ip address show up                  # only up interfaces
ip -4 address show                  # IPv4 only
ip -6 address show                  # IPv6 only
ip -br address show                 # compact table
```

Short form: `ip a`, `ip a show eth0`

**Example output:**

```
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 state UP
    link/ether 52:54:00:ab:cd:ef brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.100/24 brd 192.168.1.255 scope global dynamic eth0
       valid_lft 86394sec preferred_lft 86394sec
    inet6 fe80::5054:ff:feab:cdef/64 scope link
       valid_lft forever preferred_lft forever
```

### Adding & Removing Addresses

```bash
ip address add 192.168.1.100/24 dev eth0
ip address add 192.168.1.100/24 brd + dev eth0     # auto-calculate broadcast
ip address add 10.0.0.1/8 dev eth0 label eth0:1    # with label
ip address del 192.168.1.100/24 dev eth0
ip address flush dev eth0                           # remove all addresses from interface
ip address flush dev eth0 scope global              # remove only global addresses
```

Multiple addresses can be added to one interface — this is normal and fully supported.

---

## ip route — Routing Table

Manages the kernel routing table.

### Viewing

```bash
ip route show                       # main routing table
ip route show table all             # all routing tables
ip route show table local           # local table
ip -4 route show                    # IPv4 routes
ip -6 route show                    # IPv6 routes
ip route get 8.8.8.8                # which route would be used to reach an IP
ip route get 8.8.8.8 from 192.168.1.100   # with source address
```

**Example output:**

```
default via 192.168.1.1 dev eth0 proto dhcp src 192.168.1.100 metric 100
192.168.1.0/24 dev eth0 proto kernel scope link src 192.168.1.100
```

### Adding & Removing Routes

```bash
# Default gateway
ip route add default via 192.168.1.1
ip route add default via 192.168.1.1 dev eth0

# Specific network
ip route add 10.0.0.0/8 via 192.168.1.1
ip route add 10.0.0.0/8 dev eth0

# With metric (lower = preferred)
ip route add 10.0.0.0/8 via 192.168.1.1 metric 100

# Blackhole (silently drop)
ip route add blackhole 10.10.10.0/24

# Unreachable (return ICMP error)
ip route add unreachable 10.10.10.0/24

# Remove
ip route del default
ip route del 10.0.0.0/8 via 192.168.1.1

# Replace (add or update atomically)
ip route replace 10.0.0.0/8 via 192.168.1.254
```

### Policy Routing

Linux supports multiple routing tables (1–253, plus `local`, `main`, `default`):

```bash
ip route add 10.0.0.0/8 via 192.168.1.1 table 100     # add to table 100
ip rule add from 192.168.2.0/24 table 100              # use table 100 for this source
ip rule show                                            # show routing policy rules
ip rule del from 192.168.2.0/24 table 100
```

---

## ip neighbour — ARP / NDP Table

Manages the ARP cache (IPv4) and NDP cache (IPv6) — the mapping of IP addresses to MAC addresses.

```bash
ip neighbour show                       # full ARP/NDP table
ip neighbour show dev eth0              # for a specific interface
ip -4 neighbour show                    # IPv4 ARP only
ip -6 neighbour show                    # IPv6 NDP only
```

**Example output:**

```
192.168.1.1 dev eth0 lladdr 00:11:22:33:44:55 REACHABLE
192.168.1.50 dev eth0 lladdr aa:bb:cc:dd:ee:ff STALE
```

States: `REACHABLE` — recently confirmed reachable. `STALE` — not confirmed recently. `DELAY` — waiting to confirm. `FAILED` — unreachable.

```bash
ip neighbour add 192.168.1.200 lladdr aa:bb:cc:dd:ee:ff dev eth0    # static ARP entry
ip neighbour del 192.168.1.200 dev eth0                             # remove entry
ip neighbour flush dev eth0                                         # clear ARP cache for interface
ip neighbour flush all                                              # clear entire ARP cache
```

---

## ip monitor — Live Events

Watch network changes in real time:

```bash
ip monitor                      # all events
ip monitor link                 # interface up/down events
ip monitor address              # address changes
ip monitor route                # routing table changes
ip monitor neigh                # ARP/NDP changes
ip monitor all                  # everything
```

Useful for debugging DHCP, link flapping, or dynamic routing changes as they happen.

---

## ip netns — Network Namespaces

Network namespaces provide isolated network stacks. Used heavily by containers and VPNs.

```bash
ip netns list                               # list namespaces
ip netns add myns                           # create namespace
ip netns del myns                           # delete namespace
ip netns exec myns ip a                     # run command inside namespace
ip netns exec myns bash                     # shell inside namespace
ip link set eth0 netns myns                 # move interface into namespace
ip -n myns link show                        # shorthand for exec ... ip link
```

**Basic container-style setup:**

```bash
ip netns add container1
ip link add veth0 type veth peer name veth1
ip link set veth1 netns container1
ip address add 10.0.0.1/24 dev veth0
ip netns exec container1 ip address add 10.0.0.2/24 dev veth1
ip link set veth0 up
ip netns exec container1 ip link set veth1 up
```

---

## ip tunnel — Tunnels

```bash
ip tunnel show                                          # list tunnels
ip tunnel add tun0 mode gre remote 1.2.3.4 local 5.6.7.8   # GRE tunnel
ip tunnel add tun0 mode ipip remote 1.2.3.4 local 5.6.7.8  # IP-in-IP
ip tunnel del tun0
```

---

## Practical Examples

**Show your IP addresses quickly:**

```bash
ip -br -c a
```

**Find your default gateway:**

```bash
ip route show default
ip route show default | awk '{print $3}'    # just the IP
```

**Check which interface and route reaches a host:**

```bash
ip route get 8.8.8.8
```

**Flush and renew DHCP (manual method):**

```bash
ip address flush dev eth0
dhclient eth0
```

**Add a temporary second IP to an interface:**

```bash
ip address add 192.168.1.200/24 dev eth0
# removed on reboot — for persistence use /etc/network/interfaces or NetworkManager
```

**Watch for interface state changes:**

```bash
ip monitor link
```

**Clear stale ARP entries:**

```bash
ip neighbour flush dev eth0
```

**Get JSON output for scripting:**

```bash
ip -j route show | jq '.[0].gateway'        # default gateway as plain string
ip -j -p a                                  # pretty-printed addresses
```

---

## Persistence

Changes made with `ip` are not persistent across reboots. To make them permanent:

|System|Method|
|---|---|
|Debian/Ubuntu|`/etc/network/interfaces` or Netplan (`/etc/netplan/`)|
|RHEL/Fedora|NetworkManager (`nmcli`) or `/etc/sysconfig/network-scripts/`|
|Arch|systemd-networkd (`/etc/systemd/network/`) or NetworkManager|
|systemd-networkd|`/etc/systemd/network/*.network` files|

For one-off testing `ip` is ideal. For persistent config, use the appropriate network manager for your distro.

---

## Comparison with Deprecated Tools

|Old tool|`ip` equivalent|
|---|---|
|`ifconfig eth0`|`ip a show eth0`|
|`ifconfig eth0 up`|`ip link set eth0 up`|
|`ifconfig eth0 192.168.1.1`|`ip a add 192.168.1.1/24 dev eth0`|
|`route -n`|`ip route show`|
|`route add default gw x.x.x.x`|`ip route add default via x.x.x.x`|
|`arp -n`|`ip neigh show`|
|`netstat -r`|`ip route show`|

`ifconfig` and `route` are from the `net-tools` package, which is unmaintained. `ip` is the current standard.

---

## Tips

**`ip route get` is invaluable for debugging** — it tells you exactly which route the kernel would use, including the source address and outgoing interface, without sending any traffic.

**`-br -c` is the fastest way to read addresses** — brief colorized output gives you a clean table of interfaces and IPs at a glance.

**Changes are lost on reboot** — `ip` modifies the live kernel state only. Always use your distro's network configuration system for anything that needs to survive a restart.

**Multiple addresses per interface is normal** — Linux has always supported this. Aliases (`eth0:1`) are an old convention; just add multiple addresses directly to the interface with `ip address add`.

**Use `-j` for scripting instead of parsing text** — `ip -j route show | jq ...` is far more robust than `awk`/`grep` on text output, which varies between kernel versions.

**`ip monitor` beats polling** — if you're writing a script that needs to react to network changes, `ip monitor` gives you events as they happen rather than requiring a polling loop.