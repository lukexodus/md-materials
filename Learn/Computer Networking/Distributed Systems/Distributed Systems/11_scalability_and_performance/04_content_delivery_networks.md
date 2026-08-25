## Content Delivery Networks


### Core Architecture

CDNs implement geographically distributed caching and content distribution infrastructure to minimize latency, reduce origin load, and improve availability for static and dynamic content delivery. Architecture spans origin infrastructure, edge nodes (PoPs), intermediate caching tiers, control plane for configuration propagation, and data plane for request routing and content delivery.

**Hierarchical Topology:**

- **Origin tier:** Authoritative content source, handles cache misses, serves as system of record
- **Mid-tier caches (regional shields):** Aggregation points reducing origin fan-in, collapse concurrent cache misses, provide additional caching layer
- **Edge tier:** Terminal serving nodes closest to end users, highest cache hit ratio target, lowest latency delivery

**Flat/Mesh Topology:** Edge nodes peer directly, no strict hierarchy. Enables edge-to-edge content sharing, reduces origin load through cooperative caching, increases complexity in cache coherence and routing.

### Request Routing Mechanisms

**DNS-based routing:** Authoritative nameserver returns geographically or load-optimized IP addresses based on resolver location (EDNS Client Subnet for precision). TTL controls routing agility vs DNS caching overhead. Challenges: resolver location != client location, DNS caching disrupts routing changes, coarse-grained control.

**Anycast routing:** Multiple edge nodes advertise identical IP prefix via BGP. Network-layer routing determines nearest PoP based on AS-path length and BGP metrics. Provides automatic failover, DDoS mitigation through traffic distribution. Limitations: stateful connections broken on route changes, uneven load distribution, limited application-layer visibility for routing decisions.

**HTTP redirect:** Origin or DNS returns 302/307 redirect to optimal edge node. Adds RTT overhead, full application-layer visibility for routing decisions, enables A/B testing and gradual rollouts.

**Application-layer routing:** Client-side logic (SDK, JavaScript) selects edge node based on performance metrics, custom logic. Maximum flexibility, requires client instrumentation, vulnerable to client-side manipulation.

### Cache Coherence and Invalidation

**TTL-based expiration:** Content validity period specified via `Cache-Control` or `Expires` headers. Simple, scalable, weak consistency. Stale content served until TTL expiration. Suitable for immutable content with versioned URLs.

**Event-driven invalidation (purge/ban):** Origin pushes invalidation events to edge nodes via control plane. Types:

- **Purge by URL:** Exact cache key invalidation, fast, precise
- **Purge by tag/surrogate key:** Logical grouping for bulk invalidation, requires tagging infrastructure
- **Ban expressions:** Pattern-based invalidation (regex, header matching), flexible but expensive to evaluate

Consistency challenges: propagation delay to all edge nodes (eventual consistency), thundering herd on origin post-invalidation, ordering guarantees for concurrent updates.

**Revalidation (conditional requests):** Edge issues `If-None-Match` (ETag) or `If-Modified-Since` to origin. Origin responds 304 Not Modified or 200 with fresh content. Reduces bandwidth, maintains fresher cache, increases origin request volume.

**Hierarchical invalidation:** Invalidation propagates through cache tiers. Mid-tier shields revalidate with origin, edges revalidate with shields. Reduces origin load, increases invalidation latency.

### Consistency Models

**Eventual consistency (default):** Edge caches serve potentially stale content until TTL expiration or invalidation propagates. Acceptable for most static assets, content where staleness is tolerable.

**Read-after-write consistency:** Bypass cache for requests from clients that recently modified content (session pinning, cookie-based cache bypass). Complex to implement at scale, breaks caching efficiency.

**Strong consistency:** Edge always revalidates with origin (no caching) or uses distributed consensus for cache coherence. Defeats CDN purpose, used only for highly dynamic or personalized content unsuitable for edge caching.

### Partitioning and Sharding

**Geographic partitioning:** Content distribution based on regulatory constraints (data residency), licensing boundaries, or latency optimization. Requires geo-aware routing, complicates global content updates.

**Content-type partitioning:** Separate cache infrastructure for video (large objects, range requests), small objects (high request rate), dynamic content (bypass or short TTL). Optimizes cache algorithms, storage types, network paths per workload.

**Customer/tenant partitioning:** Multi-tenant CDNs isolate customer traffic, cache pools, or configuration to prevent noisy neighbor effects, meet SLAs, or provide dedicated infrastructure.

### Origin Shielding and Load Shedding

**Shield PoPs:** Designated mid-tier nodes aggregate requests to origin from edge tier. Collapses concurrent cache misses (request coalescing), reduces origin connection count, provides choke point for rate limiting. Adds latency hop, creates single point of failure (mitigated by multi-shield redundancy).

**Request coalescing:** Multiple concurrent requests for same cache miss deduplicated, single origin request satisfies all waiters. Reduces origin load, increases edge memory for tracking in-flight requests.

**Stale-while-revalidate:** Serve stale cached content while asynchronously fetching fresh version from origin. Maintains low latency, reduces origin impact during traffic spikes, eventual consistency trade-off.

**Stale-if-error:** Serve stale content when origin is unreachable or returns errors. Degrades gracefully during origin outages, bounded staleness via TTL limits.

**Origin rate limiting and backpressure:** CDN enforces request rate limits to origin based on capacity, error rates, or explicit signals from origin. Protects origin from overload, requires graceful degradation strategy (serve stale, return 429/503).

### Dynamic Content Acceleration

**Connection optimization:** CDN maintains persistent connections to origin, connection pooling, protocol optimization (HTTP/2, HTTP/3). Reduces TLS handshake overhead, connection establishment latency for short-lived origin connections.

**Route optimization:** CDN leverages private backbone network between edge and origin, bypassing congested public internet paths. Reduces latency variance, packet loss, improves throughput.

**Protocol transformation:** Edge terminates HTTP/3 or HTTP/2 from clients, communicates with origin over optimized protocol. Enables modern protocol adoption without origin changes.

**Edge compute for personalization:** Execute code at edge to assemble personalized responses from cached fragments, API calls, or origin requests. Reduces origin load, enables low-latency personalization. Limited by edge compute constraints (CPU, memory, execution time).

### Range Request Handling

**Full object caching:** Cache entire object on first request, serve ranges from cached copy. Simple, optimal for frequently accessed content, inefficient for large objects with sparse access patterns (large videos with skip behavior).

**Slice/chunked caching:** Divide large objects into fixed-size chunks, cache chunks independently. Fetches only requested byte ranges from origin, efficient for sparse access. Complexity in chunk boundary alignment, cache key management, stitching responses.

**On-demand slice fetching:** Request exact byte range from origin as needed, cache returned slice. Minimizes cache storage, increases origin requests for non-sequential access.

### Streaming and Live Content

**HTTP-based adaptive streaming (HLS, DASH):** Manifest files list content segments, clients request segments based on bandwidth conditions. CDN caches manifest and segments independently. Manifest caching challenges: short TTL for live content, version consistency across edges.

**Segment caching strategies:** Live segments cached with short TTL, older segments cached longer (sliding window). Reduces origin load as live edge moves forward, balances freshness and cache efficiency.

**Origin segment generation:** Origin generates segments on-demand or just-in-time. CDN shields origin by caching segments immediately after generation, distributing load across edge tier.

**Low-latency streaming (LL-HLS, LL-DASH, WebRTC):** Sub-second latency requires chunked transfer encoding, HTTP/2 server push, or WebRTC data channels. CDN edge nodes act as media servers, forwarding streams with minimal buffering. Statefulness challenges, connection persistence requirements.

### Security and DDoS Mitigation

**Edge-based attack absorption:** Anycast distribution spreads volumetric attacks across global infrastructure. Rate limiting, connection limits, and traffic scrubbing at edge prevents origin saturation.

**Web application firewall (WAF) at edge:** Inspect HTTP requests for malicious patterns, SQL injection, XSS, bot traffic. Execute at edge to block attacks before reaching origin, requires low-latency rule evaluation.

**TLS termination at edge:** Offload TLS handshake and encryption from origin, reduce computational load. Edge-to-origin communication over private network may use unencrypted or re-encrypted channels.

**Token authentication and signed URLs:** Origin generates time-limited, cryptographically signed URLs to prevent unauthorized access and hotlinking. CDN validates signatures at edge, blocks invalid requests without origin involvement.

**Bot detection and mitigation:** Challenge-response mechanisms (CAPTCHA, JavaScript challenges), behavioral analysis, reputation scoring at edge. Trade-offs: false positives blocking legitimate traffic, latency impact of challenges, adversarial evolution.

### Observability and Telemetry

**Request-level logging:** Detailed logs at edge nodes (client IP, URL, response code, cache status, latency). High volume, requires aggregation, sampling, or streaming to centralized system. Privacy concerns with PII in logs.

**Real-time metrics aggregation:** Cache hit ratio, request rate, error rate, latency percentiles per PoP, per customer, per content type. Dashboard for operational visibility, alerting on anomalies.

**Distributed tracing:** Propagate trace context (W3C Trace Context, OpenTelemetry) through CDN tiers to origin. Correlate edge behavior with origin performance, debug cache misses, measure end-to-end latency.

**Cache analytics:** Top uncacheable URLs, cache miss reasons, byte hit ratio, object size distribution. Identifies optimization opportunities, content misconfiguration.

**Client-side performance metrics (RUM):** JavaScript beacons report page load times, resource fetch latency, errors from end-user perspective. Complements server-side metrics, captures last-mile network conditions.

### Failure Modes and Degradation

**PoP failure:** DNS or anycast reroutes traffic to healthy PoPs. Increased latency for affected users, potential cache cold start at new PoP. Graceful degradation if capacity insufficient, prioritize critical traffic.

**Origin failure:** Serve stale content (`stale-if-error`), return cached error pages, or fail open to alternate origin. Time-bounded staleness prevents indefinite stale serving.

**Control plane failure:** Configuration updates, invalidations delayed but existing data plane continues serving cached content. Eventually inconsistent state until control plane recovery.

**Cascading cache misses (thundering herd):** Popular content expiration or invalidation causes simultaneous cache misses across edges, overwhelming origin. Mitigations: request coalescing, probabilistic early expiration (jitter TTLs), shields with additional coalescing.

**Cache stampede on invalidation:** Explicit purge across all edges simultaneously triggers origin request flood. Staggered invalidation, rate limiting on origin requests, shield-based request aggregation.

### Cost and Performance Trade-offs

**Cache storage costs:** Edge storage limited, must balance cache size vs hit ratio. Eviction policies (LRU, LFU, size-aware) optimize for hit ratio or byte hit ratio. Large objects consume disproportionate cache space.

**Egress/bandwidth costs:** Origin-to-edge egress expensive, especially for cache misses or high-churn content. Mid-tier shields reduce origin egress, increase intra-CDN transfer costs. Content optimization (compression, image resizing) reduces total bandwidth.

**PoP count vs coverage:** More PoPs improve latency, increase infrastructure costs. Diminishing returns beyond certain density, especially in sparse regions. Cost optimization: concentrate PoPs in high-traffic regions, accept higher latency for low-traffic areas.

**Origin request rate:** Lower TTL increases freshness, increases origin load and costs. Higher TTL reduces origin requests but increases staleness window. Per-content tuning based on update frequency and consistency requirements.

### Edge Compute Integration

**Serverless functions at edge:** Execute custom code on request path for authentication, A/B testing, header manipulation, content transformation, API aggregation. Cold start latency, execution time limits, resource constraints (CPU, memory, external network access).

**Compute-near-cache architecture:** Co-locate compute and cache in same infrastructure, minimize latency for cache lookups, enable complex cache key generation, conditional logic for cache bypass.

**State management at edge:** Distributed KV stores at edge for session state, rate limiting counters, feature flags. Consistency challenges across edge nodes, replication latency, limited storage capacity.

### Multi-CDN and Hybrid Strategies

**Multi-CDN architectures:** Utilize multiple CDN providers simultaneously for redundancy, cost optimization, performance tuning. Complexity: traffic splitting logic, consistent invalidation across providers, unified observability.

**DNS-based traffic steering:** Route subsets of traffic to different CDNs based on geography, content type, or performance. Requires intelligent DNS with real-time performance monitoring.

**Private CDN (self-operated edge):** Enterprises build proprietary edge infrastructure for regulatory, cost, or performance reasons. Full control, high capital and operational costs, expertise requirements.

**Hybrid origin/edge:** Critical or high-margin content served via CDN, long-tail content served directly from origin. Reduces CDN costs, origin must handle subset of traffic directly.

### Advanced Caching Strategies

**ESI (Edge Side Includes):** Compose pages from cacheable fragments with varying TTLs. Edge assembles fragments into final response, allows personalization within otherwise cacheable page structure. Complexity: fragment dependency management, error handling for missing fragments.

**Cache warming (pre-fetching):** Proactively populate edge caches before anticipated traffic spikes (content releases, events). Reduces origin load during spike, requires prediction of popular content, consumes cache space for potentially unused content.

**Negative caching:** Cache 404, 410, or other error responses to prevent repeated origin requests for non-existent resources. Requires careful TTL tuning to avoid masking newly created content.

**Vary header handling:** Cache multiple variants of same URL based on request headers (`Accept-Encoding`, `Accept-Language`, `User-Agent`). Multiplies cache storage requirements, fragments cache hit ratio, complexity in key management.

### Regulatory and Compliance

**Data residency:** Geographic restrictions on where content can be cached or transit. Requires region-locked PoPs, complex routing rules, potential performance degradation in restricted regions.

**GDPR and privacy:** Minimize PII in logs, support data deletion requests, transparent data handling. Edge processing of requests must comply with data protection regulations.

**Content filtering and censorship:** Region-specific content blocking based on legal requirements. Implemented at edge via geo-blocking, URL filtering, or DPI. Complicates global content strategy.

### Related Topics

- Anycast routing and BGP-based traffic engineering
- HTTP/2 and HTTP/3 protocol optimization
- Edge computing and serverless at the edge
- Reverse proxy and load balancing architectures
- Distributed caching systems (Redis, Memcached)
- Object storage systems (S3-compatible APIs)
- Video streaming protocols (HLS, DASH, WebRTC)
- DNS architecture and EDNS Client Subnet
- DDoS mitigation and traffic scrubbing
- Web application firewalls (WAF)
- Service mesh and ingress controllers
- Multi-region active-active architectures
- Cache coherence protocols
- Consistent hashing for distributed systems

---

