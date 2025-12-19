# Syllabus

## Module 1: DNS Fundamentals

- What is DNS
- DNS history and evolution
- Purpose and role in internet infrastructure
- DNS as a distributed database
- Hierarchical namespace structure
- DNS terminology and concepts
- Internet namespace architecture

## Module 2: DNS Architecture

- DNS hierarchy overview
- Root DNS servers
- Top-Level Domains (TLDs)
- Second-level domains
- Subdomains
- Authoritative name servers
- Recursive resolvers
- Forwarding name servers

## Module 3: DNS Records Types

- A (Address) records
- AAAA (IPv6 Address) records
- CNAME (Canonical Name) records
- MX (Mail Exchange) records
- NS (Name Server) records
- PTR (Pointer) records
- SOA (Start of Authority) records
- TXT (Text) records
- SRV (Service) records
- CAA (Certification Authority Authorization) records
- DNSKEY records
- DS (Delegation Signer) records
- NSEC and NSEC3 records
- RRSIG records
- TLSA records
- SVCB and HTTPS records

## Module 4: DNS Resolution Process

- Iterative queries
- Recursive queries
- Query flow from client to root
- Step-by-step resolution process
- Referrals and delegation
- Glue records
- DNS response codes
- Authoritative vs non-authoritative answers

## Module 5: DNS Caching

- Cache operation principles
- Time To Live (TTL) values
- TTL configuration strategies
- Cache poisoning concepts
- Cache hierarchy
- Negative caching
- Cache invalidation
- Browser DNS cache

## Module 6: DNS Protocol Details

- DNS message format
- Header structure
- Question section
- Answer section
- Authority section
- Additional section
- DNS flags and opcodes
- EDNS0 (Extension Mechanisms for DNS)
- UDP vs TCP for DNS
- DNS over port 53

## Module 7: BIND DNS Server

- BIND installation and setup
- named.conf configuration
- Zone file syntax
- Zone file best practices
- BIND logging
- BIND security features
- BIND views
- Dynamic updates with BIND
- BIND debugging and troubleshooting

## Module 8: Alternative DNS Servers

- Microsoft DNS Server
- PowerDNS
- Unbound
- dnsmasq
- Knot DNS
- NSD (Name Server Daemon)
- CoreDNS
- Comparison of DNS server software

## Module 9: Zone Management

- Zone file structure
- Zone file records format
- Zone transfers (AXFR)
- Incremental zone transfers (IXFR)
- Zone delegation
- Primary (master) zones
- Secondary (slave) zones
- Stub zones
- Forward zones
- Reverse zones

## Module 10: DNS Security (DNSSEC)

- DNSSEC purpose and goals
- Chain of trust
- Key signing keys (KSK)
- Zone signing keys (ZSK)
- DNSSEC validation process
- DS records and delegation
- RRSIG signatures
- NSEC and NSEC3 for authenticated denial
- Key rollover procedures
- DNSSEC deployment considerations

## Module 11: DNS Security Threats

- DNS spoofing and cache poisoning
- DNS amplification attacks
- DDoS attacks targeting DNS
- DNS tunneling
- Domain hijacking
- DNS hijacking
- Subdomain takeover
- NXDOMAIN attacks
- Random subdomain attacks

## Module 12: DNS Security Hardening

- Rate limiting
- Response Rate Limiting (RRL)
- Access control lists (ACLs)
- Transaction signatures (TSIG)
- Source IP validation
- Query filtering
- Firewall configuration for DNS
- Minimizing information disclosure
- DNS security best practices

## Module 13: Modern DNS Protocols

- DNS over HTTPS (DoH)
- DNS over TLS (DoT)
- DNS over QUIC (DoQ)
- DNSCrypt
- Protocol comparison
- Privacy implications
- Performance considerations
- Client and server support

## Module 14: DNS Load Balancing

- Round-robin DNS
- Geographic DNS (GeoDNS)
- Weighted DNS responses
- DNS-based traffic management
- Health checking integration
- Anycast DNS
- Active-active configurations
- Failover strategies

## Module 15: DNS Performance Optimization

- Query response time optimization
- Anycast deployment
- DNS prefetching
- DNS preconnect
- Reducing DNS lookup times
- Optimal TTL values
- Minimizing delegation depth
- DNS server placement strategies

## Module 16: Reverse DNS

- Reverse DNS purpose
- PTR record configuration
- in-addr.arpa domain
- ip6.arpa domain
- Reverse DNS delegation
- Reverse DNS verification
- Email server requirements
- Troubleshooting reverse DNS

## Module 17: Dynamic DNS (DDNS)

- DDNS concepts and use cases
- DDNS update mechanisms
- TSIG authentication for updates
- DDNS client configuration
- DDNS provider services
- Security considerations
- Automated DDNS updates
- DDNS for home networks

## Module 18: DNS Monitoring and Analytics

- DNS query logging
- Performance metrics
- Query patterns analysis
- Anomaly detection
- DNS monitoring tools
- Health checks and alerts
- Traffic analysis
- Response time monitoring

## Module 19: DNS Troubleshooting Tools

- nslookup
- dig (Domain Information Groper)
- host command
- whois
- dnstracer
- dnsrecon
- Wireshark for DNS analysis
- Online DNS diagnostic tools

## Module 20: DNS Troubleshooting Techniques

- Common DNS issues
- Propagation delays
- Misconfigured records
- DNSSEC validation failures
- Resolution failures
- Debugging methodology
- Log analysis
- Packet capture analysis

## Module 21: DNS Registrars and Registries

- Domain registration process
- Registrar vs registry distinction
- EPP (Extensible Provisioning Protocol)
- WHOIS database
- RDAP (Registration Data Access Protocol)
- Domain transfer procedures
- Registrar lock mechanisms
- Grace and redemption periods

## Module 22: Top-Level Domains (TLDs)

- Generic TLDs (gTLDs)
- Country code TLDs (ccTLDs)
- New gTLD program
- Sponsored TLDs
- Infrastructure TLD (.arpa)
- Special-use domains
- TLD policies and management
- ICANN role in TLD governance

## Module 23: DNS in Cloud Environments

- AWS Route 53
- Google Cloud DNS
- Azure DNS
- Cloudflare DNS
- Cloud DNS architectures
- Hybrid cloud DNS
- Multi-cloud DNS strategies
- DNS failover in cloud

## Module 24: DNS for Email

- MX record configuration
- SPF (Sender Policy Framework)
- DKIM (DomainKeys Identified Mail)
- DMARC (Domain-based Message Authentication)
- Email authentication flow
- MTA-STS records
- BIMI (Brand Indicators for Message Identification)
- Email deliverability optimization

## Module 25: Split-Horizon DNS

- Split-horizon concepts
- Internal vs external views
- View-based configurations
- Use cases for split DNS
- Security benefits
- Implementation strategies
- Split-brain DNS issues
- Troubleshooting split-horizon

## Module 26: DNS in IPv6

- AAAA records
- IPv6 reverse DNS (ip6.arpa)
- Dual-stack DNS considerations
- IPv6-only DNS resolution
- DNS64 and NAT64
- IPv6 glue records
- Transition mechanisms
- IPv6 DNS best practices

## Module 27: DNS API and Automation

- DNS provider APIs
- Programmatic zone management
- Automated record updates
- Infrastructure as Code for DNS
- Terraform DNS providers
- Ansible DNS modules
- DNS change management
- CI/CD integration with DNS

## Module 28: DNS High Availability

- Redundant name server design
- Primary-secondary configurations
- Multi-master replication
- Geographic distribution
- Disaster recovery planning
- Failover mechanisms
- Hidden primary configurations
- Service continuity strategies

## Module 29: Private DNS

- Internal DNS zones
- RFC 1918 address space
- Split DNS for internal resources
- Active Directory integrated DNS
- Private DNS in VPCs
- mDNS (Multicast DNS)
- Link-local resolution
- Zero-configuration networking

## Module 30: DNS Compliance and Standards

- RFC standards for DNS
- IETF DNS working groups
- ICANN policies
- Industry best practices
- Compliance requirements
- Audit considerations
- Documentation standards
- Change management procedures

## Module 31: Advanced DNS Topics

- DNS cookies
- Aggressive Use of DNSSEC-Validated Cache
- QNAME minimization
- DNS prefetching and preloading
- Negative Trust Anchors
- DNS flag day events
- Response Policy Zones (RPZ)
- Catalog Zones

## Module 32: DNS Performance Testing

- Query load testing
- Stress testing DNS infrastructure
- Benchmarking tools
- Performance baselines
- Capacity planning
- Response time analysis
- Throughput testing
- Scalability assessment

## Module 33: DNS in Content Delivery

- CDN DNS integration
- Edge DNS services
- DNS-based content routing
- Geographic traffic steering
- Performance-based routing
- Multi-CDN strategies
- DNS for video streaming
- Real-time DNS updates

## Module 34: DNS Filtering and Control

- DNS-based content filtering
- Parental controls via DNS
- DNS sinkholing
- Blocklists and allowlists
- Pi-hole and similar solutions
- Enterprise DNS filtering
- Threat intelligence feeds
- Policy enforcement via DNS

## Module 35: DNS Data Analysis

- Query pattern analysis
- Statistical analysis of DNS traffic
- Machine learning applications
- Threat detection via DNS
- User behavior analytics
- Business intelligence from DNS data
- Trend identification
- Predictive analytics

## Module 36: Mobile and IoT DNS

- DNS in mobile networks
- iOS DNS configuration
- Android DNS settings
- DNS for IoT devices
- Lightweight DNS implementations
- Mesh network DNS
- Edge computing DNS
- Constrained environment considerations

## Module 37: DNS Certification and Career

- DNS certification programs
- Professional development paths
- Industry certifications
- Hands-on lab environments
- Real-world project experience
- Community resources
- Staying current with DNS developments
- Contributing to DNS standards