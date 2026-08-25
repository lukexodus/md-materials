## Firewalls and Packet Filtering


Firewalls implement security policies by controlling network traffic flow between different network segments or security zones.

### Firewall Types

#### Packet Filtering Firewalls

**Operation:** Examine individual packets against predefined rule sets **Inspection Level:** Network layer (Layer 3) and transport layer (Layer 4) headers **Decision Factors:**

- Source and destination IP addresses
- Source and destination port numbers
- Protocol type (TCP, UDP, ICMP)
- TCP flag states
- Packet direction (inbound/outbound)

**Advantages:**

- High performance with minimal processing overhead
- Transparent to applications and users
- Cost-effective for basic protection needs
- Simple configuration for straightforward policies

**Limitations:**

- No application-level inspection capabilities
- Vulnerable to application layer attacks
- Cannot inspect encrypted payload content
- Limited logging and monitoring capabilities

#### Stateful Inspection Firewalls

**Connection Tracking:** Maintain state information for active network connections **Dynamic Rule Creation:** Automatically permit return traffic for established connections **Session Awareness:** Understand connection establishment and termination procedures

**State Table Information:**

- Connection five-tuple (source IP, destination IP, source port, destination port, protocol)
- Connection state (new, established, related, invalid)
- Sequence numbers and acknowledgment tracking
- Connection timers and aging mechanisms

**Security Enhancements:**

- Prevents unsolicited inbound connections
- Detects connection hijacking attempts
- Enforces proper protocol state transitions
- Provides better logging and forensic capabilities

#### Application Layer Firewalls (Proxy Firewalls)

**Deep Packet Inspection:** Examine complete packet contents including application data **Protocol Understanding:** Implement specific application protocol logic **Content Filtering:** Block malicious content based on payload analysis

**Proxy Operation:**

- Terminate client connections at firewall
- Establish separate connections to destination servers
- Inspect and filter application layer communications
- Apply granular security policies based on content

**Advanced Capabilities:**

- URL filtering and content categorization
- Malware detection and prevention
- Data loss prevention (DLP) functionality
- User identity integration and logging

### Firewall Architectures

#### Screened Host Architecture

**Design:** Single firewall protecting internal network from external threats **Implementation:** Firewall positioned between internal network and internet connection **Advantages:** Simple design, cost-effective, centralized policy enforcement **Limitations:** Single point of failure, all traffic must traverse one device

#### Screened Subnet (DMZ) Architecture

**Demilitarized Zone:** Separate network segment for public services **Dual Firewall Design:** External firewall protects DMZ, internal firewall protects LAN **Service Placement:** Web servers, email servers, and DNS servers in DMZ **Security Benefit:** Compromised DMZ services cannot directly access internal networks

#### Multi-Homed Firewall

**Multiple Interfaces:** Firewall connects to several network segments simultaneously **Network Segmentation:** Different security zones with varying trust levels **Policy Complexity:** Granular rules controlling inter-zone communications **Scalability:** Supports complex organizational network requirements

### Firewall Rule Configuration

**Default Deny Policy:** Block all traffic unless explicitly permitted by rules **Rule Ordering:** More specific rules processed before general rules **Rule Optimization:** Frequently matched rules positioned higher in rule base **Rule Documentation:** Clear descriptions explaining purpose and business justification

### Network Address Translation (NAT)

**IP Address Conservation:** Multiple internal devices share single public IP address **Security Benefit:** Hide internal network topology from external observers **Connection Tracking:** Maintain translation tables for active connections **Types:**

- **Static NAT:** One-to-one permanent address mapping
- **Dynamic NAT:** Pool of public addresses assigned dynamically
- **Port Address Translation (PAT):** Many-to-one mapping using port numbers

