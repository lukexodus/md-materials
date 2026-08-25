## Network Tools


### Connectivity Testing

Network connectivity testing forms the foundation of network troubleshooting, helping administrators verify reachability, measure latency, and trace network paths between hosts.

**ping command usage:** The `ping` utility sends ICMP echo request packets to test basic connectivity and measure round-trip time.

- `ping hostname` - Basic connectivity test with continuous pinging
- `ping -c 5 hostname` - Send exactly 5 packets then stop
- `ping -i 0.2 hostname` - Set interval between packets (0.2 seconds)
- `ping -s 1024 hostname` - Specify packet size (1024 bytes)
- `ping -t 64 hostname` - Set TTL (Time To Live) value
- `ping -W 2 hostname` - Set timeout for response (2 seconds)
- `ping -f hostname` - Flood ping (requires root privileges)
- `ping -q hostname` - Quiet mode, shows summary only

**Advanced ping options:**

- `ping -D hostname` - Print timestamps for each packet
- `ping -R hostname` - Record route option (shows path taken)
- `ping -M do hostname` - Set "Don't Fragment" bit for MTU discovery
- `ping -v hostname` - Verbose output with additional information
- `ping -a hostname` - Audible ping (beep on response)
- `ping -n hostname` - Numeric output only, no DNS resolution

**ping6 for IPv6:**

- `ping6 hostname` - IPv6 connectivity testing
- `ping6 -I interface hostname` - Specify outgoing interface
- `ping6 ::1` - Test IPv6 loopback

**traceroute command usage:** Traceroute traces the path packets take through the network to reach a destination, showing each hop along the route.

- `traceroute hostname` - Basic path tracing
- `traceroute -n hostname` - Numeric output, no reverse DNS lookups
- `traceroute -w 5 hostname` - Set timeout for each hop (5 seconds)
- `traceroute -q 1 hostname` - Send only 1 probe per hop (default is 3)
- `traceroute -m 15 hostname` - Set maximum hops (default is 30)
- `traceroute -p 80 hostname` - Use specific destination port
- `traceroute -I hostname` - Use ICMP instead of UDP probes
- `traceroute -T hostname` - Use TCP SYN probes

**Alternative tracing tools:**

- `mtr hostname` - Combines ping and traceroute functionality
- `mtr -r -c 10 hostname` - Report mode with 10 cycles
- `tracepath hostname` - Similar to traceroute but doesn't require root
- `traceroute6 hostname` - IPv6 path tracing

**Interpreting traceroute output:** Each line represents a hop in the network path, showing:

- Hop number
- Hostname or IP address of the router
- Three round-trip times (or * for timeouts)
- Any ICMP error messages

### DNS Tools

DNS troubleshooting tools help diagnose name resolution issues, verify DNS configurations, and analyze DNS record information.

**nslookup usage:** The `nslookup` tool provides interactive and non-interactive DNS lookup capabilities.

**Basic nslookup commands:**

- `nslookup hostname` - Basic forward DNS lookup
- `nslookup ip-address` - Reverse DNS lookup
- `nslookup hostname dns-server` - Query specific DNS server
- `nslookup -type=MX domain` - Query specific record type
- `nslookup -debug hostname` - Enable debug output

**Interactive nslookup mode:**

```bash
nslookup
> set type=A
> example.com
> set type=MX
> example.com
> server 8.8.8.8
> example.com
> exit
```

**dig command usage:** The `dig` (Domain Information Groper) tool provides more detailed and flexible DNS querying capabilities.

**Basic dig commands:**

- `dig hostname` - Basic A record lookup
- `dig @dns-server hostname` - Query specific DNS server
- `dig hostname MX` - Query specific record type
- `dig -x ip-address` - Reverse DNS lookup
- `dig +short hostname` - Concise output format
- `dig +trace hostname` - Trace complete DNS resolution path

**Advanced dig options:**

- `dig +norecurse hostname` - Disable recursive queries
- `dig +tcp hostname` - Force TCP instead of UDP
- `dig +time=5 hostname` - Set query timeout
- `dig +retry=2 hostname` - Set number of retries
- `dig hostname ANY` - Query all available record types
- `dig -f filename` - Batch mode from file

**DNS record types:**

- `A` - IPv4 address records
- `AAAA` - IPv6 address records
- `MX` - Mail exchange records
- `NS` - Name server records
- `CNAME` - Canonical name records
- `PTR` - Pointer records (reverse DNS)
- `TXT` - Text records
- `SOA` - Start of Authority records
- `SRV` - Service records

**host command usage:** The `host` utility provides simple DNS lookup functionality with clean output.

- `host hostname` - Basic forward lookup
- `host ip-address` - Reverse lookup
- `host -t MX domain` - Query specific record type
- `host -a hostname` - Query all record types
- `host -v hostname` - Verbose output
- `host -W 10 hostname` - Set timeout (10 seconds)

**DNS troubleshooting techniques:**

- Compare results from multiple DNS servers
- Check for DNS propagation delays
- Verify DNS server configurations
- Test both forward and reverse lookups
- Monitor DNS response times and consistency

### Network Statistics

Network statistics tools provide insights into network connections, listening services, routing tables, and network interface statistics.

**netstat command usage:** [Inference] The `netstat` command is considered legacy on many modern systems, but still widely available and used.

**Basic netstat commands:**

- `netstat -tuln` - Show all listening TCP and UDP ports
- `netstat -tulpn` - Include process information
- `netstat -r` - Display routing table
- `netstat -i` - Show network interface statistics
- `netstat -s` - Display network protocol statistics

**Connection monitoring:**

- `netstat -an` - Show all connections (numeric)
- `netstat -at` - Show TCP connections only
- `netstat -au` - Show UDP connections only
- `netstat -c` - Continuous monitoring mode
- `netstat -o` - Show timer information

**ss command usage:** The `ss` (socket statistics) command is the modern replacement for netstat, providing faster performance and more detailed information.

**Basic ss commands:**

- `ss -tuln` - Show listening TCP and UDP sockets
- `ss -tulpn` - Include process information
- `ss -s` - Show socket statistics summary
- `ss -r` - Resolve hostnames
- `ss -o` - Show timer information

**Advanced ss filtering:**

- `ss -t state established` - Show established TCP connections
- `ss -t state listening` - Show listening TCP sockets
- `ss dst :80` - Filter by destination port
- `ss src 192.168.1.0/24` - Filter by source network
- `ss -t '( dport = :80 or sport = :80 )'` - Complex filtering

**Socket states:**

- `ESTABLISHED` - Active connection
- `LISTEN` - Waiting for incoming connections
- `TIME-WAIT` - Connection closed, waiting for timeout
- `CLOSE-WAIT` - Remote end closed connection
- `FIN-WAIT-1/2` - Local end closed connection
- `SYN-SENT` - Attempting to establish connection
- `SYN-RECV` - Received connection request

**Interface statistics:**

- `ss -i` - Show detailed interface information
- `ip -s link` - Interface statistics with ip command
- `cat /proc/net/dev` - Raw interface statistics
- `sar -n DEV 1` - Real-time interface monitoring

**Additional network statistics tools:**

- `lsof -i` - List open network files and connections
- `fuser -n tcp 80` - Show processes using specific port
- `netstat -M` - Show masquerading connections (NAT)
- `watch -n 1 'ss -tuln'` - Continuous monitoring

### Traffic Analysis

Network traffic analysis tools capture and analyze network packets for troubleshooting, security monitoring, and performance analysis.

**tcpdump basic usage:** The `tcpdump` command captures and displays network packets in real-time or saves them for later analysis.

**Basic tcpdump commands:**

- `tcpdump -i interface` - Capture on specific interface
- `tcpdump -i any` - Capture on all interfaces
- `tcpdump host hostname` - Capture traffic to/from specific host
- `tcpdump port 80` - Capture traffic on specific port
- `tcpdump -n` - Don't resolve hostnames
- `tcpdump -v` - Verbose output
- `tcpdump -vv` - More verbose output
- `tcpdump -vvv` - Maximum verbosity

**Filtering expressions:**

- `tcpdump src host 192.168.1.1` - Source host filter
- `tcpdump dst host 192.168.1.1` - Destination host filter
- `tcpdump net 192.168.1.0/24` - Network range filter
- `tcpdump tcp and port 80` - Protocol and port combination
- `tcpdump icmp` - ICMP packets only
- `tcpdump arp` - ARP packets only

**Advanced filtering:**

- `tcpdump 'tcp[tcpflags] & tcp-syn != 0'` - TCP SYN packets
- `tcpdump 'tcp[tcpflags] & tcp-rst != 0'` - TCP RST packets
- `tcpdump greater 1500` - Packets larger than 1500 bytes
- `tcpdump less 60` - Packets smaller than 60 bytes
- `tcpdump -s 0` - Capture full packet (no truncation)

**Output and file operations:**

- `tcpdump -w capture.pcap` - Write packets to file
- `tcpdump -r capture.pcap` - Read packets from file
- `tcpdump -C 100 -w capture` - Rotate files at 100MB
- `tcpdump -G 3600 -w capture_%Y%m%d_%H%M%S.pcap` - Time-based rotation
- `tcpdump -c 1000 -w capture.pcap` - Capture specific number of packets

**Display formatting:**

- `tcpdump -A` - Print packet payload in ASCII
- `tcpdump -X` - Print packet payload in hex and ASCII
- `tcpdump -e` - Print link-level headers
- `tcpdump -t` - Don't print timestamps
- `tcpdump -tt` - Print unformatted timestamps
- `tcpdump -ttt` - Print time differences between packets

**Protocol-specific analysis:**

- `tcpdump -i any tcp port 22 -A` - SSH traffic analysis
- `tcpdump -i any udp port 53` - DNS query monitoring
- `tcpdump -i any icmp` - ICMP traffic analysis
- `tcpdump -i any arp` - ARP traffic monitoring

**Alternative traffic analysis tools:**

- `tshark` - Command-line version of Wireshark
- `ngrep` - Network grep for packet payloads
- `iftop` - Real-time interface bandwidth monitoring
- `nethogs` - Per-process network usage monitoring
- `bmon` - Bandwidth monitoring with visual interface

**Wireshark integration:**

- Capture with tcpdump, analyze with Wireshark GUI
- `tcpdump -w - | wireshark -k -i -` - Pipe to Wireshark real-time
- Use Wireshark's command-line tools for automated analysis

**Performance considerations:**

- Use appropriate buffer sizes for high-traffic captures
- Apply filters early to reduce capture overhead
- Consider capture file rotation for long-term monitoring
- Monitor system resources during intensive captures

**Security and permissions:**

- Root privileges typically required for packet capture
- Be aware of legal and policy implications of traffic monitoring
- Implement appropriate access controls for capture files
- Consider privacy implications when capturing packet contents

**Key points** for effective network troubleshooting include combining multiple tools for comprehensive analysis, understanding the appropriate use cases for each tool, implementing proper filtering to focus on relevant traffic, and maintaining awareness of performance and security implications when conducting network analysis.

---

