## Naming Systems and Name Resolution


### Naming Fundamentals

**Name binding**: Association between name and entity (resource, object, service). Binding may be static (compile-time) or dynamic (runtime). Immutable bindings enable caching; mutable bindings require invalidation strategies.

**Name resolution**: Process of translating name to address, binding, or resource. Resolution may traverse multiple naming layers or authorities. Resolution latency directly impacts application performance in distributed systems.

**Flat naming**: Names without hierarchical structure. UUIDs, content hashes, MAC addresses. Resolution requires broadcast, DHT lookup, or centralized directory. No delegation possible; single namespace authority.

**Hierarchical naming**: Names organized in tree structure with delegation boundaries. DNS, file systems, LDAP. Enables distributed administration. Resolution proceeds level-by-level from root. Caching at each level reduces load on authoritative sources.

**Attribute-based naming**: Names specify properties rather than identifiers. Directory services, service discovery with metadata queries. Resolution requires search rather than lookup. LDAP filters, Consul service tags, Kubernetes label selectors.

### DNS Architecture

**Zone delegation**: DNS namespace partitioned into zones with designated authoritative name servers. Zone boundary marks administrative delegation point. Parent zone contains NS records pointing to child zone name servers. Enables distributed management at internet scale.

**Authoritative name servers**: Hold master zone data. Primary (master) serves zone file; secondaries (slaves) replicate via zone transfer (AXFR full, IXFR incremental). Authoritative responses have AA flag set. DNSSEC signatures prove authenticity.

**Recursive resolvers**: Accept queries from clients, perform full resolution by iterative queries to authoritative servers. Cache intermediate results. Implement negative caching (NXDOMAIN) per RFC 2308. Google Public DNS (8.8.8.8), Cloudflare (1.1.1.1), organizational resolvers.

**Iterative vs recursive resolution**: Iterative resolution returns referral to next name server; client continues query. Recursive resolution returns final answer or error; resolver handles iteration. DNS protocol supports both; clients typically request recursion.

**Resource record types**: A (IPv4 address), AAAA (IPv6), CNAME (canonical name alias), MX (mail exchanger with priority), NS (name server delegation), TXT (arbitrary text, used for SPF, DKIM), SRV (service location with port and priority), CAA (certificate authority authorization).

**Time-to-live (TTL)**: Specifies caching duration in seconds. Short TTL enables rapid updates but increases query load. Long TTL reduces load but delays propagation. Typical values: 300s (5min) for dynamic records, 86400s (24h) for stable infrastructure.

**Negative caching**: Cache NXDOMAIN and NODATA responses to reduce load from queries for nonexistent names. Controlled by SOA minimum TTL field. Aggressive negative caching (RFC 8198) uses NSEC/NSEC3 for broader coverage.

**Zone transfer mechanisms**: AXFR transfers entire zone via TCP. IXFR transfers only changes since previous serial number. NOTIFY (RFC 1996) signals secondaries of zone updates. Zone size and change frequency determine optimal mechanism.

### DNS Security Extensions (DNSSEC)

**Chain of trust**: Root zone signed by root KSK (key-signing key). Each zone signed by ZSK (zone-signing key). DS records in parent zone hash child zone's KSK, creating delegation chain. Resolver validates signatures up to trusted anchor (root KSK).

**RRSIG records**: Digital signatures over resource record sets. Include signature expiration time, signer name, key tag. Resolver verifies signature using DNSKEY records. Signature expiration requires periodic re-signing (typical: weekly).

**DNSKEY records**: Public keys used for signature verification. KSK signs DNSKEY set; ZSK signs zone data. Key rollover protocols (RFC 5011) enable trust anchor updates without manual reconfiguration.

**NSEC/NSEC3 records**: Prove nonexistence of names or record types. NSEC provides next name in canonical order; NSEC3 uses hashed names to prevent zone enumeration. NSEC3 includes opt-out for unsigned delegations in large zones.

**Validation failure modes**: SERVFAIL returned when signature validation fails. BOGUS status indicates cryptographic verification failure. INDETERMINATE when missing trust anchor or DNSKEY. Requires fallback strategy or strict enforcement depending on security requirements.

**Operational challenges**: Increased response sizes may require TCP fallback or EDNS0 buffer size negotiation. Key rollover requires coordination. Signing latency for dynamic zones addressed via inline signing or NSEC3 aggressive caching.

### Service Discovery

**DNS-based service discovery (DNS-SD)**: Uses DNS records (SRV, TXT, PTR) to advertise services. Service instance names constructed as `<instance>.<service>.<domain>`. SRV provides hostname and port; TXT provides metadata. RFC 6763. Used by Bonjour, Avahi.

**Multicast DNS (mDNS)**: Zero-configuration DNS for local networks. Queries sent to multicast address (224.0.0.251). Each host responds authoritatively for its names. Used by Bonjour for `.local` pseudo-TLD. No central server; scales to small networks only.

**Service registration**: Service instances register with discovery system, providing endpoint and metadata. Registration includes health check configuration. Ephemeral registration with TTL requires periodic renewal. Consul, etcd, Eureka, ZooKeeper.

**Service query and filtering**: Clients query for service by name or attributes. Returns list of healthy instances. May include load balancing weights, version tags, datacenter locality. Consul DNS interface, Kubernetes DNS for service discovery.

**Health checking**: Discovery system monitors instance health via HTTP, TCP, or script-based checks. Unhealthy instances removed from query results. Check interval vs failure threshold trade-off. Consul, Kubernetes liveness/readiness probes.

**Client-side load balancing**: Client receives multiple endpoints, selects using local algorithm (round-robin, random, least-connections, locality-aware). Eliminates load balancer single point of failure. gRPC name resolver, Netflix Ribbon, Envoy clusters.

**Service mesh integration**: Sidecar proxies (Envoy, Linkerd) intercept outbound connections, perform discovery and load balancing. Control plane (Istio, Consul Connect) distributes service topology. Observability, traffic shaping, mutual TLS built-in.

### Distributed Hash Tables (DHT)

**Consistent hashing**: Keys and nodes mapped to ring using hash function. Key stored at successor node (first node clockwise). Node addition/removal affects only neighbors. Chord protocol uses m-bit identifier space, O(log N) routing.

**Virtual nodes**: Each physical node assigned multiple positions on ring. Improves load distribution, reduces variance. Node departure spreads load across multiple successors. Cassandra uses 256 virtual nodes per physical node by default.

**Finger tables**: Routing table with O(log N) entries pointing to nodes at exponentially increasing distances. Chord finger[i] points to successor of (n + 2^i) mod 2^m. Enables O(log N) lookup hops. Requires stabilization protocol to maintain accuracy.

**Stabilization and repair**: Periodic protocol to correct finger tables after node joins/departures. Successor lists provide redundancy for fault tolerance. Chord stabilization runs every few seconds. Trade-off between convergence speed and messaging overhead.

**Replication strategies**: Store key at N successor nodes for fault tolerance. Quorum reads/writes for consistency. Sloppy quorums with hinted handoff during failures. Dynamo-style eventually consistent replication.

**DHT protocols**: Chord (structured ring), Kademlia (XOR metric, parallel lookups), Pastry (prefix-based routing), CAN (d-dimensional torus). Trade-offs in routing efficiency, maintenance overhead, and fault tolerance.

**Practical deployments**: BitTorrent distributed tracker (Mainline DHT, Kademlia-based), IPFS content addressing, Ethereum node discovery, Riak Core for data partitioning.

### Content-Addressable Storage

**Cryptographic hashing**: Content identified by hash of data. Git uses SHA-1 (migrating to SHA-256), IPFS uses multihash supporting multiple algorithms. Hash serves as both name and integrity verification.

**Merkle DAGs**: Directed acyclic graph where nodes reference children by content hash. Immutable structure; any change propagates to root hash. Git commits, IPFS files, blockchain transactions. Efficient verification of subset without full download.

**Block-level deduplication**: Chunk data into fixed or variable-size blocks, hash each block. Store only unique blocks. File represented as list of block hashes. Reduces storage for similar files. LBFS, Venti, Perkeep.

**Content distribution**: Requesting hash enables retrieval from any source (CDN, peer, cache). No trusted source required; hash verifies authenticity. BitTorrent, IPFS, Dat protocol. Separates naming from location.

**Naming layer on top**: Content-addressable storage provides immutable objects. Mutable naming via IPNS (InterPlanetary Name System), Git branches, or DNS records containing current hash. Indirection enables updates while preserving immutability benefits.

### Uniform Resource Locators (URLs) and Identifiers (URIs)

**URL components**: Scheme (protocol), authority (host:port), path, query parameters, fragment. Hierarchical structure maps to resource location. Authority determines name resolution strategy (DNS for hostnames, local for localhost).

**URI opacity and stability**: Cool URIs don't change (W3C principle). Persistent identifiers (DOI, ARK, PURL) redirect to current location. Content negotiation via Accept headers enables same URI for multiple representations.

**URL shortening and redirection**: Maps short identifier to long URL via HTTP redirect. Single point of failure and control. Privacy implications from click tracking. bit.ly, TinyURL architecture uses hash table with collision handling.

**Vanity names and aliasing**: Human-readable names mapped to underlying identifiers. DNS CNAME for aliasing. Reverse proxy routing by hostname. API gateway routing by path prefix. Slack workspace subdomains.

### Naming in Distributed File Systems

**Mount points and namespaces**: File systems mounted into unified namespace. NFS, AFS use mount table to map paths to remote servers. Transparent to applications but visible via different device IDs or fsync semantics.

**Symbolic links and hard links**: Symlinks store path string, resolved at access time. Hard links create multiple directory entries for same inode. Distributed systems challenges: symlink targets may be unreachable, hard links across volumes require global inode space.

**Pathname resolution**: Traverse directory hierarchy, check permissions at each level. Distributed systems perform resolution locally until reaching remote mount point, then RPC to server. Caching directory metadata reduces remote operations.

**HDFS naming**: NameNode maintains filesystem metadata (directory tree, block locations). Files identified by path. Blocks identified by 64-bit block ID. DataNodes report block inventory to NameNode via heartbeat. Single NameNode bottleneck addressed by HDFS Federation (multiple namespaces) or NameNode HA.

**Object storage naming**: Flat namespace of object keys. S3 uses bucket and key. Keys may contain delimiter (/) for hierarchical listing but storage is flat. No directory operations; rename requires copy and delete. Scales to billions of objects.

### Service Naming and Routing

**Virtual IP addresses**: Single IP shared across multiple servers via anycast routing or load balancer. Clients use stable address independent of backend topology. AWS ELB, Google Cloud Load Balancing, Kubernetes ClusterIP.

**Server Name Indication (SNI)**: TLS extension specifying hostname in ClientHello. Enables virtual hosting on shared IP address. Server selects certificate based on SNI. Required for HTTPS load balancing without terminating TLS at load balancer.

**API gateway routing**: HTTP reverse proxy routes by path, headers, or query parameters. `/api/users` to user service, `/api/orders` to order service. Kong, Ambassador, AWS API Gateway. Centralizes cross-cutting concerns (authentication, rate limiting).

**Service mesh sidecar routing**: Envoy proxy intercepts all traffic, routes based on control plane configuration. Service names resolved to endpoints by xDS API. Enables traffic splitting, canary deployments, circuit breaking without application changes.

**gRPC name resolution**: Client uses resolver plugin to translate service name to endpoints. Builtin resolvers: dns (SRV records), xds (Envoy control plane), unix (local socket). Custom resolvers for Consul, etcd, ZooKeeper.

### Name Resolution Caching

**Cache coherence protocols**: Invalidation-based (explicit invalidation messages) or TTL-based (entries expire). Invalidation requires knowing all caches holding entry. TTL-based simpler but bounded staleness.

**Negative caching**: Cache unsuccessful lookups (NXDOMAIN, 404 responses) to reduce load from repeated queries for nonexistent resources. Expiration controlled separately from positive cache. DNS negative caching per SOA minimum TTL.

**Cache poisoning**: Attacker injects false mappings into cache. DNS cache poisoning via forged responses with matching query ID. Defenses: randomized source ports, query ID randomization, DNSSEC validation, 0x20 encoding.

**Hierarchical caching**: Multiple cache layers (browser, OS resolver, recursive resolver). Amplifies TTL effectiveness but complicates invalidation. Each layer independently enforces TTL. CDN edge caches, intermediate DNS resolvers.

**Cache stampede**: Simultaneous cache misses trigger multiple backend queries. Thundering herd on cache expiration. Mitigations: lock-based coalescing (first requester fetches, others wait), probabilistic early expiration, stale-while-revalidate.

### Consistency Models in Naming

**Strong consistency**: All queries return most recent binding. Requires coordination on every update. Linearizable operations on single-leader database or consensus system (etcd, ZooKeeper). High latency, availability sacrifice during partitions.

**Eventual consistency**: Updates propagate asynchronously; queries may return stale bindings. Bounded staleness proportional to propagation delay and cache TTL. DNS standard model. Dynamo-style systems with anti-entropy.

**Session consistency**: Client observes own updates immediately. Read-your-writes guarantee. Implemented via session affinity or version tracking. Cassandra LOCAL_QUORUM with session token.

**Causal consistency**: Queries observe causally-ordered updates. Concurrent updates may be observed in different orders. COPS protocol, Bayou system. Requires vector clocks or dependency tracking.

**Timeline consistency**: Ordering within same key guaranteed; cross-key operations unordered. Eventual consistency per key. Many NoSQL systems default behavior.

### Namespace Partitioning and Sharding

**Range-based partitioning**: Name space divided into contiguous ranges assigned to servers. `/a-m` to server1, `/n-z` to server2. Simple but vulnerable to hot spots. Requires rebalancing as load distribution changes.

**Hash-based partitioning**: Apply hash function to name, modulo server count determines placement. Uniform load distribution. Consistent hashing reduces data movement on topology changes. Cassandra, Riak, DynamoDB.

**Hierarchical partitioning**: Partition at specific namespace levels. DNS zones, HDFS Federation. Delegation boundaries enable independent scaling. Clients must know partitioning scheme or use indirection layer.

**Directory-based mapping**: Separate mapping service stores name-to-location table. Clients query directory before accessing data. Chubby, BigTable tablets. Directory itself must be highly available and scalable.

### Cross-Datacenter Naming

**Geo-distributed authoritative servers**: DNS name servers distributed across regions. Anycast routing directs queries to nearest server. Reduces latency, improves availability. Requires zone synchronization or master-slave replication.

**Region-specific resolution**: Return different bindings based on client location. GeoDNS maps client IP to region, returns nearest endpoint. AWS Route 53 geolocation routing, Cloudflare load balancing.

**Active-active resolution**: Multiple datacenters serve queries concurrently. Updates require cross-datacenter synchronization. Conflict resolution for concurrent updates. CRDTs or last-write-wins with timestamps.

**Failover mechanisms**: Detect datacenter failure, update bindings to redirect traffic. DNS-based failover updates NS records. Service mesh control plane reconfigures data plane. Requires health checking and automatic promotion.

### Naming in Microservices

**Service registry pattern**: Centralized or distributed database of service instances. Services register on startup, deregister on shutdown. Clients query registry for current instances. Consul, Eureka, ZooKeeper, etcd.

**Client-side discovery**: Clients query service registry, select instance, connect directly. No intermediate load balancer. Netflix OSS approach with Eureka and Ribbon.

**Server-side discovery**: Clients connect to load balancer or API gateway. Load balancer queries service registry, proxies to instance. Additional hop but centralized traffic management. Kubernetes services with kube-proxy, AWS ELB with target groups.

**Kubernetes DNS**: CoreDNS serves cluster-internal DNS. Services addressable via `<service>.<namespace>.svc.cluster.local`. Headless services return pod IPs for client-side load balancing. ExternalName services CNAME to external resources.

**Istio service naming**: Services addressed by Kubernetes service names or arbitrary hostnames. Envoy sidecar resolves via xDS protocol. ServiceEntry resources define external services. DestinationRule configures subset routing based on labels.

### Operational Considerations

**TTL tuning**: Short TTL (60-300s) for dynamic infrastructure enables rapid updates. Long TTL (3600-86400s) for stable resources reduces query load. Zero TTL disables caching for testing. Monitor cache hit rates.

**Resolver selection**: Public resolvers (Google, Cloudflare) provide speed, reliability. Private resolvers enable internal name resolution, filtering, custom policies. Hybrid split-horizon DNS routes internal vs external queries differently.

**Monitoring and alerting**: Track query rates, error rates, latency percentiles. DNS SERVFAIL indicates resolution failures. Service registry staleness detected by TTL violations or health check failures. Query distribution across instances for load balance verification.

**Capacity planning**: Resolution system must handle peak query rates. DNS query rate 10-100x normal application request rate due to TTL expirations. Service registry handles registration/deregistration bursts during deployments.

**Security hardening**: DNSSEC validation prevents spoofing. Rate limiting prevents DoS. Access controls on service registry prevent unauthorized registration. Audit logging for name updates.

### Naming Anti-Patterns

**Hardcoded addresses**: Embedding IP addresses or hostnames in application code. Requires redeployment for infrastructure changes. Use service names with discovery instead.

**Overly long DNS chains**: CNAME pointing to CNAME pointing to CNAME. Increases resolution latency, amplifies failures. Limit to single CNAME indirection.

**Centralized resolution bottleneck**: All queries routed through single resolver or load balancer. Scale horizontally, use anycast, or implement client-side caching.

**Unbounded namespace growth**: Registering ephemeral instances without cleanup. Memory exhaustion in registry. Implement TTL-based expiration or active garbage collection.

**Cross-region synchronous resolution**: Querying remote datacenter synchronously for every resolution. Adds RTT to every request. Cache locally with TTL or replicate registry.

### Related Topics

- Consistent hashing and virtual nodes
- Distributed consensus for strongly consistent registries
- Service mesh architecture and control plane design
- CDN request routing and edge DNS
- Anycast routing for distributed name servers
- Certificate authority systems and PKI
- Identity and access management (IAM) systems
- API gateway and ingress controller design
- Load balancing algorithms
- Bloom filters for set membership
- Gossip protocols for membership and failure detection
- Locality-aware routing and affinity
- Multi-tenancy isolation in shared namespaces
- Version-based routing and canary deployments
- Zero-trust networking and identity-based access control

---

