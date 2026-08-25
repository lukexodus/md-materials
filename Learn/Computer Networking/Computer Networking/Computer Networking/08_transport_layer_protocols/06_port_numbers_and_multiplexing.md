## Port Numbers and Multiplexing


Transport layer multiplexing enables multiple applications to share network connections simultaneously through port number addressing and socket management.

### Port Number Allocation

**Well-Known Ports (0-1023):**

- Reserved for system services and standard applications
- Require administrative privileges for binding
- Standardized by Internet Assigned Numbers Authority (IANA)
- Examples: HTTP (80), HTTPS (443), SSH (22), FTP (21)

**Registered Ports (1024-49151):**

- Assigned to specific applications and services
- Less restrictive binding requirements
- Managed by IANA registration process
- Examples: MySQL (3306), PostgreSQL (5432), SIP (5060)

**Dynamic/Private Ports (49152-65535):**

- Available for temporary client connections
- Automatically assigned by operating system
- Used for outbound connections and ephemeral services
- Also called ephemeral or high ports

### Multiplexing and Demultiplexing

**Connection Identification:**

- TCP connections identified by four-tuple: source IP, source port, destination IP, destination port
- UDP multiplexing based on destination IP and port
- Multiple applications can share same well-known port on different interfaces
- Port reuse options allow multiple bindings under specific conditions

**Socket Management:**

- Operating system maintains socket tables
- Each socket associated with specific application process
- Incoming packets routed to appropriate application based on port numbers
- Socket state includes protocol type, addresses, and connection status

### Port Security Considerations

**Port Scanning Vulnerabilities:**

- Closed ports typically respond with RST or ICMP unreachable
- Port scanning reveals active services
- Firewall rules should restrict unnecessary port access
- Service fingerprinting can identify application versions

**Port-Based Access Control:**

- Firewalls filter traffic based on port numbers
- Network Address Translation (NAT) modifies port numbers
- Port forwarding enables external access to internal services
- Virtual private networks often use specific ports

