## Domain Name System (DNS)


The Domain Name System provides hierarchical naming services that translate human-readable domain names into IP addresses and other resource records. DNS operates as a distributed database system that enables scalable name resolution across the global Internet.

### DNS Hierarchy and Architecture

**Root Domain:**

- Thirteen root name servers worldwide (A through M)
- Managed by different organizations under ICANN oversight
- Contains authoritative information about top-level domains
- Root servers return referrals to TLD name servers

**Top-Level Domains (TLDs):**

- Generic TLDs: .com, .org, .net, .edu, .gov
- Country-code TLDs: .us, .uk, .de, .jp
- Sponsored TLDs: .aero, .museum, .coop
- New gTLDs: .app, .cloud, .security

**Second-Level and Subdomain Structure:**

- Organizations register second-level domains (example.com)
- Subdomains create hierarchical organization (www.example.com)
- Delegation allows distributed administration
- Zone files define authoritative data for domain portions

### DNS Record Types

**A Records (IPv4 Address):**

- Map domain names to IPv4 addresses
- Most common record type for web services
- Multiple A records enable load distribution
- Time-to-live (TTL) values control caching duration

**AAAA Records (IPv6 Address):**

- Map domain names to IPv6 addresses
- Essential for IPv6 connectivity
- Dual-stack configurations include both A and AAAA records
- Prefer IPv6 addresses when available

**CNAME Records (Canonical Name):**

- Create aliases pointing to other domain names
- Cannot coexist with other record types for same name
- Useful for service abstraction and redirection
- Multiple CNAME chains should be avoided

**MX Records (Mail Exchange):**

- Specify mail servers for domain
- Priority values enable backup mail servers
- Essential for email delivery routing
- Multiple MX records provide redundancy

**NS Records (Name Server):**

- Identify authoritative name servers for domain
- Required for domain delegation
- Multiple NS records provide redundancy
- Glue records prevent circular dependencies

**PTR Records (Pointer):**

- Enable reverse DNS lookups (IP to name)
- Required for many email servers
- Stored in special reverse domains (in-addr.arpa)
- Critical for security and logging applications

**TXT Records (Text):**

- Store arbitrary text data
- Used for domain verification and security policies
- SPF records specify authorized mail servers
- DKIM records contain public keys for email authentication

### DNS Resolution Process

**Recursive Resolution:**

- DNS resolver queries on behalf of client
- Resolver follows referrals to find authoritative answer
- Caches responses to improve performance
- Returns final answer to client

**Iterative Resolution:**

- Client follows referrals directly
- Each query returns either answer or referral
- Client responsible for following referral chain
- Less common for end-user applications

**Resolution Steps:**

1. Client queries local resolver for domain name
2. Resolver checks cache for existing answer
3. If not cached, resolver queries root server
4. Root server returns TLD server referral
5. Resolver queries TLD server for domain
6. TLD server returns authoritative server referral
7. Resolver queries authoritative server
8. Authoritative server returns final answer
9. Resolver caches answer and returns to client

### DNS Security Considerations

**DNS Security Extensions (DNSSEC):**

- Digital signatures authenticate DNS responses
- Chain of trust from root to individual records
- Prevents cache poisoning and response forgery
- Requires coordinated deployment across infrastructure

**DNS over HTTPS (DoH) and DNS over TLS (DoT):**

- Encrypts DNS queries to prevent eavesdropping
- DoH uses HTTPS protocol for transport
- DoT uses dedicated TLS connections
- Improves privacy but complicates network management

**Common Security Threats:**

- Cache poisoning attacks inject false records
- DNS hijacking redirects legitimate queries
- DDoS attacks against DNS infrastructure
- Subdomain enumeration reveals internal structure

### DNS Performance Optimization

**Caching Strategies:**

- TTL values balance freshness with performance
- Negative caching reduces repeated failed queries
- Prefetching anticipates future queries
- Geographic distribution improves response times

**Load Balancing Techniques:**

- Multiple A records enable simple load distribution
- Geographic DNS returns location-specific addresses
- Health checking removes failed servers
- Weighted round-robin distributes load proportionally

