## Cloud Service Models


### Infrastructure as a Service (IaaS)

**Architectural Boundary**

IaaS exposes virtualized compute, storage, and network primitives as programmatically controllable resources. The provider manages physical infrastructure, hypervisor layer, and hardware abstraction; the tenant controls OS, runtime, middleware, application stack, and data. Control plane operations (provisioning, scaling, monitoring) are separated from data plane (actual workload execution).

**Compute Abstraction Layer**

Virtualization substrate exposes compute as ephemeral or persistent instances with defined CPU, memory, and I/O characteristics. Hypervisor isolation (KVM, Xen, Hyper-V, Firecracker) provides fault and security boundaries between tenants. Instance lifecycle management—boot, snapshot, clone, migration—occurs through APIs or orchestration layers. Bare-metal offerings bypass hypervisor overhead for latency-sensitive or compliance-driven workloads.

**Storage Primitives**

Block storage presents virtual disks (EBS, Azure Disks, Persistent Disks) with configurable IOPS, throughput, and durability guarantees. Backend typically uses distributed block stores with replication factor N (commonly 3) across failure domains. Object storage (S3, Blob Storage, Cloud Storage) exposes key-value semantics with eventual consistency by default, strong consistency optional. Metadata services provide indexing and querying. Shared filesystem services (EFS, Azure Files) offer POSIX or SMB semantics over distributed storage with consistency trade-offs depending on locking and caching strategies.

**Network Virtualization**

Software-defined networking isolates tenant traffic through VPC/VNet constructs using overlay networks (VXLAN, Geneve). Subnetting, routing tables, security groups, and network ACLs define L3/L4 policy enforcement. Cross-region and cross-VPC connectivity requires peering, transit gateways, or VPN/dedicated interconnects. Load balancing operates at L4 (TCP/UDP) or L7 (HTTP/HTTPS) with health checks and connection draining. Direct hardware access via SR-IOV reduces latency for packet-intensive workloads.

**Control Plane Characteristics**

Resource provisioning involves API calls translated into distributed task queues, quota enforcement, placement decisions (bin-packing, affinity/anti-affinity rules), and eventual state reconciliation. Control plane availability is decoupled from data plane; regional control plane failures do not terminate running instances but prevent new operations. Tagging, IAM policies, and resource hierarchies enable multi-tenant governance and cost allocation.

**Failure Domains and Availability**

Availability zones represent isolated failure domains within a region (separate power, cooling, networking). Multi-AZ deployments tolerate single AZ failures. Regions are geographically distributed; cross-region replication requires explicit data replication strategies with RPO/RTO considerations. Instance failure handled via health checks and auto-scaling groups or equivalent orchestration.

**Scalability and Performance Envelope**

Vertical scaling limited by largest instance type; horizontal scaling constrained by quota limits and API rate limits. Network throughput scales with instance size; jumbo frames and placement groups reduce latency. Storage IOPS and throughput scale independently or coupled to volume size depending on service tier. Cold start latency for instance provisioning (minutes) affects elasticity responsiveness.

**Consistency and State Management**

IaaS primitives do not provide consistency guarantees across services. Application-level distributed coordination (etcd, ZooKeeper, Consul) required for state consensus. Metadata services (instance metadata, tagging) eventually consistent with potential staleness during updates or failures.

**Operational Constraints**

Billing granularity at instance-hour or per-second levels with reserved, spot, and on-demand pricing models. Monitoring and logging integrated via agents or platform services. Compliance certifications (SOC 2, HIPAA, PCI-DSS) scoped to provider infrastructure; tenant responsible for application-level compliance. Maintenance windows for hypervisor patches may require instance migration or downtime.

---

### Platform as a Service (PaaS)

**Architectural Boundary**

PaaS abstracts runtime, middleware, OS, and infrastructure management. Provider controls everything below application code and data; tenant deploys application artifacts (containers, source code, binaries). Control plane handles deployment pipelines, scaling policies, routing, and service binding.

**Runtime and Execution Model**

Application execution occurs in managed containers, language-specific runtimes (Node.js, Python, Java, Go), or function execution environments. Multi-tenancy achieved via namespace isolation, resource quotas (CPU/memory limits), and process isolation. Build pipelines (buildpacks, Dockerfiles) translate source to runnable artifacts. Horizontal scaling through replica count adjustments; vertical scaling via resource limit modifications.

**State and Data Services**

Managed data services (relational, NoSQL, caching, messaging) exposed as bound services with connection credentials injected via environment variables or secret management. Data durability, replication, backups, and high availability handled by provider. Consistency models vary: managed PostgreSQL/MySQL provide strong consistency; managed Cassandra provides tunable consistency; managed Redis offers eventual consistency with optional persistence.

**Networking and Service Mesh**

Ingress routing maps external requests to application instances via load balancers with TLS termination, path-based routing, and virtual host support. Service discovery typically DNS-based or via service registry. East-west traffic may traverse service mesh (Istio, Linkerd) for observability, traffic shaping, and mTLS. Network policies enforce L7-aware access controls.

**Deployment and Lifecycle**

Blue-green or rolling deployment strategies minimize downtime. Canary releases shift traffic incrementally based on health checks. Rollback mechanisms revert to previous versions. Application logs aggregated to centralized logging services; metrics scraped via agents or sidecars. Health check endpoints determine instance readiness and liveness.

**Consistency and Coordination**

PaaS platforms do not guarantee distributed consistency across service instances. Session affinity (sticky sessions) or external session stores (Redis, Memcached) required for stateful applications. Distributed locking or coordination requires external services (etcd, ZooKeeper) or managed coordination primitives if provided.

**Failure Handling**

Instance failures detected via health checks; failed instances replaced automatically. Transient failures handled via retry policies and circuit breakers in application or service mesh layer. Cascading failures mitigated via bulkheads, rate limiting, and backpressure mechanisms. Database failover handled by managed service replication and promotion logic.

**Scalability Constraints**

Autoscaling based on CPU, memory, request rate, or custom metrics. Scaling latency depends on cold start time for new instances (seconds to minutes). Platform quotas limit maximum instances, memory, and service bindings per namespace or organization. Shared infrastructure introduces noisy neighbor effects impacting latency and throughput.

**Operational Characteristics**

Billing based on instance-hours, resource consumption, or request count depending on service tier. Built-in monitoring dashboards, alerts, and tracing integration. Compliance responsibility shared: provider secures platform; tenant secures application logic and data handling. Limited control over underlying OS patches, runtime versions, and infrastructure topology.

---

### Software as a Service (SaaS)

**Architectural Boundary**

SaaS delivers fully managed applications accessible via APIs or web interfaces. Provider controls entire stack: infrastructure, platform, application logic, and data schema. Tenant controls application configuration, user access policies, and data within application boundaries. Multi-tenancy typically implemented at application or database schema level.

**Multi-Tenancy Models**

Shared-schema multi-tenancy uses tenant ID columns for data isolation; risk of data leakage via SQL injection or logic bugs. Schema-per-tenant provides stronger isolation within shared database; schema count scaling limited by DBMS metadata overhead. Database-per-tenant offers maximum isolation; scaling constrained by database instance limits. Hybrid models use sharding strategies to distribute tenants across database clusters.

**Data Isolation and Security**

Row-level security, application-layer filtering, or encrypted tenant keys enforce data segregation. Access control via RBAC, ABAC, or custom policy engines. Encryption at rest and in transit standard; key management per-tenant or shared with provider-managed keys. Audit logs track tenant actions for compliance.

**Consistency and Replication**

Backend database consistency model dictates SaaS consistency guarantees. Strong consistency (serializable isolation) ensures read-your-writes; eventual consistency tolerates replication lag. Cross-region replication for disaster recovery introduces RPO/RTO trade-offs. Conflict resolution strategies (last-write-wins, CRDTs, application-defined) required for multi-master setups.

**API and Integration Patterns**

RESTful or GraphQL APIs expose application functionality with rate limiting per tenant. Webhooks, event streams, or message queues enable asynchronous integration. API versioning strategies (URI versioning, header-based, content negotiation) manage backward compatibility. OAuth 2.0, SAML, or OpenID Connect for federated authentication.

**Scalability and Performance**

Horizontal scaling via load balancers distributing requests across application server pools. Database scaling through read replicas, sharding, or managed scaling features. Caching layers (CDN, application cache, database query cache) reduce latency. Queueing systems decouple synchronous request processing from background jobs. Performance degradation under noisy neighbor scenarios mitigated via tenant-level resource quotas or throttling.

**Failure Modes and Degradation**

Application-level failures result in error responses or degraded functionality; circuit breakers prevent cascading failures to dependencies. Database failover involves read replica promotion with potential data loss depending on replication lag. Regional outages require cross-region failover with DNS updates or global load balancing. Data corruption incidents require point-in-time recovery from backups.

**Operational and Compliance Boundaries**

Provider responsible for uptime, security patches, data backups, and disaster recovery. SLAs define availability targets (99.9%, 99.99%) with downtime credits. Compliance certifications (SOC 2, GDPR, HIPAA) cover provider operations; tenant responsible for data classification and usage policies. Data residency requirements addressed via region selection or dedicated infrastructure tiers.

**Observability Constraints**

Limited visibility into infrastructure metrics; tenant observability restricted to application-level logs, API usage metrics, and custom event tracking. Distributed tracing ends at API boundary; internal service dependencies opaque. Alerting based on API response times, error rates, or business metrics.

---

**Related Distributed Systems Topics**

- Container Orchestration (Kubernetes, Mesos)
- Service Mesh Architectures
- Serverless and Function-as-a-Service
- Multi-Tenancy Isolation Strategies
- Global Load Balancing and Traffic Management
- Distributed Database Architectures
- API Gateway Patterns
- Edge Computing and CDN Architectures

---

