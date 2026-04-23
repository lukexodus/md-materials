# ss

---

## What It Is

**`ss`** (socket statistics) is the modern replacement for `netstat`. It queries the kernel directly via netlink, making it faster and more accurate. It displays information about network sockets — TCP, UDP, Unix domain sockets, and more.

Part of the `iproute2` package, available on all modern Linux systems by default.

---

## Basic Usage

```bash
ss                      # all non-listening sockets (established connections)
ss -a                   # all sockets (listening + non-listening)
ss -l                   # listening sockets only
ss -t                   # TCP sockets
ss -u                   # UDP sockets
ss -x                   # Unix domain sockets
ss -n                   # numeric (no hostname/service resolution)
ss -p                   # show process using each socket
ss -s                   # summary statistics
```

---

## Flags

### Socket Type

```bash
-t / --tcp              # TCP
-u / --udp              # UDP
-d / --dccp             # DCCP
-w / --raw              # raw sockets
-x / --unix             # Unix domain sockets
-S / --sctp             # SCTP
--vsock                 # vsock sockets
-4                      # IPv4 only
-6                      # IPv6 only
```

### State

```bash
-a / --all              # all sockets (listening + established + etc.)
-l / --listening        # listening sockets only
```

### Output

```bash
-n / --numeric          # show IPs and port numbers, no DNS/service lookup
-r / --resolve          # resolve hostnames (opposite of -n)
-p / --processes        # show PID and process name
-e / --extended         # show extended socket info (uid, inode, etc.)
-m / --memory           # show socket memory usage
-i / --info             # show internal TCP info (congestion window, RTT, etc.)
-o / --options          # show timer info
-K / --kill             # kill matching sockets (requires root)
-Z / --context          # show SELinux context
-H / --no-header        # suppress header line
-O / --oneline          # one line per socket
```

### Combining common flags

```bash
ss -tlnp                # listening TCP, numeric, with process
ss -tulnp               # listening TCP + UDP, numeric, with process
ss -anp                 # all sockets, numeric, with process
ss -tnp                 # established TCP with process
```

---

## Most Common Invocations

```bash
# What is listening on what port?
ss -tlnp

# All established TCP connections
ss -tn state established

# What process is using port 8080?
ss -tlnp sport = :8080

# All connections to a remote host
ss -tn dst 192.168.1.1

# UDP listeners
ss -ulnp

# Unix domain sockets (listening)
ss -xlp

# Full summary
ss -s
```

---

## Filtering

ss has a powerful filter expression syntax applied after the flags.

### By state

```bash
ss -t state established
ss -t state listening
ss -t state time-wait
ss -t state close-wait
ss -t state syn-sent
ss -t state syn-recv
ss -t state fin-wait-1
ss -t state fin-wait-2
ss -t state last-ack
ss -t state closed
ss -t state all
ss -t state connected       # all except listening and closed
ss -t state synchronized    # all except syn-sent
```

### By address and port

```bash
# Source port
ss sport = :22
ss sport = :ssh
ss sport gt :1024           # source port greater than 1024
ss sport lt :1024           # privileged ports

# Destination port
ss dport = :443
ss dport != :22

# Source address
ss src 192.168.1.100
ss src 192.168.1.100:22

# Destination address
ss dst 10.0.0.1
ss dst 10.0.0.0/24          # CIDR range

# Combining with and/or
ss -t src 192.168.1.0/24 and dport = :443
```

### Operators for port comparisons

|Operator|Meaning|
|---|---|
|`=` or `==`|equal|
|`!=`|not equal|
|`gt` or `>`|greater than|
|`ge` or `>=`|greater or equal|
|`lt` or `<`|less than|
|`le` or `<=`|less or equal|

---

## Output Fields Explained

### Standard TCP output (`ss -tn`)

```
Netid  State    Recv-Q  Send-Q  Local Address:Port   Peer Address:Port
tcp    ESTAB    0       0       192.168.1.5:52412    93.184.216.34:443
```

|Field|Meaning|
|---|---|
|`Netid`|Socket type (tcp, udp, unix, etc.)|
|`State`|Connection state|
|`Recv-Q`|Bytes received but not yet read by app|
|`Send-Q`|Bytes sent but not yet acknowledged|
|`Local Address:Port`|Local endpoint|
|`Peer Address:Port`|Remote endpoint|

**Recv-Q on listening socket** = backlog count (connections waiting to be accepted) **Send-Q on listening socket** = maximum backlog size

High `Recv-Q` on established sockets = application not reading fast enough. High `Send-Q` = network or remote side is slow.

### With `-p` (process info)

```
... users:(("nginx",pid=1234,fd=6))
```

### With `-i` (TCP internals)

```
cubic wscale:7,7 rto:204 rtt:3.14/1.57 ato:40 mss:1448 pmtu:1500
rcvmss:1448 advmss:1448 cwnd:10 ssthresh:10 bytes_sent:123 ...
```

Key fields:

|Field|Meaning|
|---|---|
|`rtt`|Round trip time (ms) / variance|
|`cwnd`|Congestion window (segments)|
|`ssthresh`|Slow start threshold|
|`mss`|Maximum segment size|
|`retrans`|Retransmit count|
|`rcv_space`|Receive buffer space|

### With `-m` (memory)

```
skmem:(r0,rb131072,t0,tb87040,f0,w0,o0,bl0,d0)
```

|Key|Meaning|
|---|---|
|`r`|Receive queue bytes|
|`rb`|Receive buffer size|
|`t`|Transmit queue bytes|
|`tb`|Transmit buffer size|
|`f`|Forward alloc|
|`w`|wmem queued|
|`o`|Optional mem|

---

## Timer Information (`-o`)

```bash
ss -tno
# timer:(keepalive,1min52sec,0)
# timer:(on,200ms,2)   ← retransmit timer, 2 retries so far
```

Timer types: `on` (retransmit), `keepalive`, `timewait`, `persist`, `unknown`

---

## Unix Domain Sockets

```bash
ss -x                   # all unix sockets
ss -xlp                 # listening, with process
ss -xap                 # all, with process

# Filter by path
ss -x src /run/systemd/private/journal.socket
```

Output includes socket path, type (stream/dgram/seqpacket), and state.

---

## Killing Sockets

```bash
# Kill all TIME-WAIT sockets (requires root)
sudo ss -K state time-wait

# Kill connections to a specific host
sudo ss -K dst 10.0.0.5

# Kill connections on a specific port
sudo ss -K sport = :8080
```

`-K` sends `TCP_REPAIR` or closes the socket forcibly. Use carefully.

---

## Practical Examples

```bash
# Find what's using port 443
ss -tlnp sport = :443

# Count established connections per remote IP (combine with other tools)
ss -tn state established | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -rn

# Watch connections in real time
watch -n1 'ss -tn state established'

# Show all TIME_WAIT sockets (common after high-traffic server)
ss -tan state time-wait

# Check if a port is open locally
ss -tln | grep ':8080'

# All sockets for a specific process by PID
ss -p | grep pid=1234

# Show connections with retransmits
ss -ti | grep retrans

# Check backlog on listening sockets
ss -tln   # Recv-Q = current backlog, Send-Q = max backlog
```

---

## ss vs netstat

|Feature|ss|netstat|
|---|---|---|
|Speed|Fast (netlink)|Slow (reads /proc)|
|Availability|iproute2, modern default|net-tools, may need install|
|Filter syntax|Built-in powerful filters|Minimal, rely on grep|
|TCP internals|Yes (`-i`)|No|
|Socket memory|Yes (`-m`)|No|
|Kill sockets|Yes (`-K`)|No|
|Output format|Similar|Similar|

`netstat` is effectively deprecated on Linux. `ss` is the replacement.

---

## Tips & Gotchas

- **`-p` requires root for other users' processes** — without root, processes not owned by you show no process info
- **`-n` speeds up output significantly** — DNS and service name resolution is slow; always use `-n` when scanning many sockets
- **`Recv-Q` on a listener is not bytes** — it is the count of connections in the accept backlog, not data
- **TIME-WAIT sockets are normal** — high counts indicate a busy server closing many short-lived connections; not inherently a problem
- **`ss -s` is the fastest overview** — no per-socket enumeration, just totals
- **Port numbers in filters need the colon prefix** — `sport = :80` not `sport = 80`
- **`-i` output is dense but valuable** — RTT, cwnd, and retransmit counts are key metrics for diagnosing TCP performance issues

---

## Quick Reference

```bash
ss -tlnp                        Listening TCP with process
ss -tulnp                       Listening TCP + UDP with process
ss -anp                         All sockets with process
ss -s                           Summary statistics
ss -tn state established        Established TCP connections
ss -tan state time-wait         TIME-WAIT sockets
ss sport = :80                  Filter by source port
ss dst 10.0.0.1                 Filter by destination
ss -ti                          TCP internals (RTT, cwnd)
ss -tm                          Socket memory usage
sudo ss -K state time-wait      Kill TIME-WAIT sockets
watch -n1 'ss -tn'              Live view
```