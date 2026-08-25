## Connection Pooling and Sniffing

### Overview

Official Elasticsearch clients manage connections to a multi-node cluster through connection pooling and, in some clients, node discovery ("sniffing"). These mechanisms determine how a client distributes requests across nodes, detects and routes around unhealthy nodes, and stays aware of cluster topology changes without requiring an application to manually track which nodes are currently available.

### Why Connection Pooling Matters

**Key Points**
- A production Elasticsearch cluster typically has multiple nodes, and a client configured with only a single node's address creates a single point of failure — if that specific node goes down, the client cannot reach the cluster at all even though other nodes remain healthy.
- Connection pooling lets a client be configured with multiple known node addresses and distribute requests across them, providing both load distribution and failover if one node becomes unreachable.
- Pooling behavior — how nodes are selected per request, how failures are detected, and how a failed node is retried — differs across client implementations and configuration.

### Common Pool Selection Strategies

**Key Points**
- **Round-robin**: requests are distributed evenly across all known healthy nodes in rotation.
- **Random selection**: a node is chosen at random per request from the healthy pool.
- **Sticky/single-node**: some configurations pin all requests to one node until a failure is detected, then fail over to another, useful in scenarios where session affinity or connection reuse matters more than even distribution.
- [Unverified] Which strategy is the client's default, and which alternatives are configurable, varies by client and version, so the specific client's documentation should be checked when the selection behavior matters for a given deployment's requirements.

### Diagram: Connection Pool with Failover

<svg width="100%" viewBox="0 0 680 300" role="img"><title>Client connection pool distributing requests with failover (svg_diagram)</title><desc>A client's connection pool distributes requests across multiple known healthy nodes and routes around a node that has been marked dead after a failed request, retrying it periodically to check for recovery.</desc>
<defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></marker></defs>

<g class="node c-blue">
<rect x="250" y="20" width="180" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="340" y="40" text-anchor="middle" dominant-baseline="central">Client connection pool</text>
<text class="ts" x="340" y="60" text-anchor="middle" dominant-baseline="central">Tracks node health</text>
</g>

<line x1="300" y1="76" x2="150" y2="130" class="arr" marker-end="url(#arrow)" />
<line x1="340" y1="76" x2="340" y2="130" class="arr" marker-end="url(#arrow)" />
<line x1="380" y1="76" x2="530" y2="130" class="arr" marker-end="url(#arrow)" />

<g class="node c-teal">
<rect x="70" y="130" width="160" height="50" rx="8" stroke-width="0.5" />
<text class="th" x="150" y="155" text-anchor="middle" dominant-baseline="central">Node A — healthy</text>
</g>
<g class="node c-red">
<rect x="260" y="130" width="160" height="50" rx="8" stroke-width="0.5" />
<text class="th" x="340" y="155" text-anchor="middle" dominant-baseline="central">Node B — marked dead</text>
</g>
<g class="node c-teal">
<rect x="450" y="130" width="160" height="50" rx="8" stroke-width="0.5" />
<text class="th" x="530" y="155" text-anchor="middle" dominant-baseline="central">Node C — healthy</text>
</g>

<text class="ts" x="340" y="220" text-anchor="middle">Requests route only to healthy nodes;</text>
<text class="ts" x="340" y="236" text-anchor="middle">node B is periodically retried to check for recovery</text>
</svg>

### Marking Nodes Dead and Resurrection

**Key Points**
- When a request to a node fails (connection refused, timeout), most clients mark that node as "dead" internally and stop routing new requests to it.
- Dead nodes are periodically retried ("resurrected") after a backoff interval to check whether they've recovered, rather than being permanently excluded from the pool for the client's lifetime.
- The backoff strategy for resurrection attempts (fixed interval vs. exponential backoff) affects how quickly a client resumes using a node that recovers versus how much load repeated failed connection attempts place on a still-unhealthy node.

### Sniffing (Node Discovery)

**Key Points**
- Sniffing is a feature in some clients where the client periodically queries the cluster (via the nodes info API) to discover its current node topology, automatically updating its connection pool to include newly added nodes and remove decommissioned ones.
- This avoids needing to manually reconfigure every application's client node list whenever cluster topology changes (node added, node removed, node replaced).
- [Unverified] Sniffing is not universally enabled by default or even supported identically across all official clients, and its interaction with load balancers or proxies sitting in front of a cluster can be problematic (since sniffing discovers actual node addresses, which may not be externally routable through a load balancer), so its use should be evaluated against the specific deployment's network topology.

### Sniffing Pitfalls with Load Balancers or Proxies

[Inference] When a client sits behind a load balancer or reverse proxy rather than connecting to cluster nodes directly, enabling sniffing can be actively harmful: the client may discover internal node addresses that aren't reachable from its network position, causing it to attempt (and fail) connections to unreachable hosts instead of continuing to use the working proxy address — for this reason, sniffing is often deliberately disabled in architectures where a load balancer or managed-service endpoint is the intended single point of contact.

### Cloud and Managed Service Considerations

**Key Points**
- Elastic Cloud and other managed Elasticsearch offerings typically present a single endpoint (often behind their own internal load balancing), meaning client-side connection pooling across "multiple nodes" as described above is less directly relevant — the managed service itself handles node-level distribution and failover behind that single endpoint.
- Client configuration for managed/cloud endpoints commonly uses a dedicated "cloud ID" or similar simplified connection mechanism instead of manually listing individual node addresses, abstracting away the underlying topology entirely from the client's perspective.

### Timeout and Retry Interaction with Pooling

**Key Points**
- Per-request timeout settings (covered in the earlier clients overview topic) interact directly with pooling — a request that times out against one node may be retried against a different node in the pool, depending on the client's configured retry behavior, rather than simply failing outright.
- Care should be taken that retry-across-nodes behavior doesn't silently mask a systemic cluster-wide problem (e.g., all nodes overloaded) as if it were a routine single-node failure, since observability into retry counts and failure patterns matters for diagnosing whether pooling is compensating for isolated node issues or papering over a broader capacity problem.

### Related Topics

- **Official clients overview** (earlier topic) for the broader context of client configuration options
- **Retry and timeout configuration** in depth, and its interaction with non-idempotent write operations
- **Elastic Cloud connection configuration** (Cloud ID) as the managed-service alternative to manual node lists
- **Nodes info API** (`_nodes`), the underlying endpoint sniffing relies on for topology discovery
- **Load balancer and reverse proxy architectures** in front of Elasticsearch clusters, and their implications for client configuration
- **Circuit breaker patterns at the application layer**, as a complementary resilience mechanism alongside client-level pooling and retry