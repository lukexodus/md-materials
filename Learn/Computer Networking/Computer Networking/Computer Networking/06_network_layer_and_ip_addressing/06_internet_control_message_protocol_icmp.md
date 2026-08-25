## Internet Control Message Protocol (ICMP)


ICMP provides error reporting, diagnostic, and informational services for IP networks. Operating at the Network Layer, ICMP helps troubleshoot connectivity issues and provides feedback about network conditions.

**ICMP functions:**

- **Error reporting**: Notifying sources about delivery problems
- **Diagnostic testing**: Providing tools for network troubleshooting
- **Flow control**: Informing sources about congestion conditions
- **Route optimization**: Suggesting better routing paths

**ICMP message types:**

- **Echo Request/Reply**: Used by ping utility for connectivity testing
- **Destination Unreachable**: Various reasons for delivery failure
    - Network unreachable
    - Host unreachable
    - Protocol unreachable
    - Port unreachable
    - Fragmentation needed but Don't Fragment bit set
- **Time Exceeded**: TTL expired or fragment reassembly timeout
- **Redirect**: Suggesting better routes to destinations
- **Source Quench**: Flow control mechanism (deprecated in modern networks)

**ICMP header structure:**

- **Type**: Message category (8 bits)
- **Code**: Specific message within type (8 bits)
- **Checksum**: Error detection (16 bits)
- **Message-specific data**: Additional information based on type

**Common ICMP utilities:**

- **Ping**: Tests connectivity using Echo Request/Reply
- **Traceroute**: Maps network path using Time Exceeded messages
- **Path MTU Discovery**: Determines maximum transmission unit along path

**ICMPv6 enhancements:**

- **Neighbor Discovery**: Replaces ARP functionality
- **Router Discovery**: Automatic router identification
- **Address Resolution**: IPv6 address to link-layer address mapping
- **Duplicate Address Detection**: Prevents address conflicts
- **Multicast Listener Discovery**: Manages multicast group membership

**ICMP security considerations:**

- **Information disclosure**: ICMP responses can reveal network topology
- **Denial of Service**: ICMP floods can overwhelm networks
- **Reconnaissance**: Attackers use ICMP for network scanning
- **Firewall policies**: Many organizations filter or limit ICMP traffic

