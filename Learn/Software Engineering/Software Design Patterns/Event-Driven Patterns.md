## Event Sourcing (Event-Driven

Event sourcing persists application state as an immutable sequence of domain events rather than storing current state directly. State reconstruction occurs by replaying events from the beginning or from snapshots. The event log serves as the system of record, enabling temporal queries, audit trails, and derived view materialization.

### Event Log Design

**Append-only event store** guarantees immutability through write-once semantics. Physical deletion prohibited; soft deletion via compensating events or tombstone markers. Storage backend must support high-throughput sequential writes with strong ordering guarantees.

**Event ordering strategies** determine consistency semantics. Global ordering across all event types requires coordination (distributed log like Kafka, single-writer per partition). Per-aggregate ordering suffices when aggregates modify independently, enabling horizontal scaling.

Partition key selection: hash aggregate ID for uniform distribution, or use composite keys (tenant_id, aggregate_id) for multi-tenancy isolation. Poor partitioning creates hot partitions degrading write throughput.

**Event schema evolution** handles breaking changes to event structure. Versioning strategies include embedded version fields, separate event type names per version (OrderPlacedV1, OrderPlacedV2), or schema registry with backward/forward compatibility rules.

[Inference] Upcasting transforms old event versions to current schema during replay. Downcasting enables new code to produce events consumable by old code. Multiple simultaneous schema versions complicate projections requiring conditional logic per version.

**Event enrichment** embeds denormalized data at write time versus runtime lookup during replay. Embedded data increases event size but eliminates dependencies during projection rebuilding. Trade-off: storage cost and schema coupling versus projection latency and external service dependencies.

Anti-pattern: embedding volatile data that changes frequently. Example: embedding full user profile in every UserAction event creates inconsistency when profile updates. Embed only stable identifiers; lookup volatile data during projection.

### Event Store Implementation Patterns

**Database-backed stores** use relational databases with append-only event table. Composite primary key (aggregate_id, version) ensures ordering. Index on aggregate_id for efficient replay. Concurrent append detection via optimistic locking on version column.

```
CREATE TABLE events (
  aggregate_id UUID NOT NULL,
  version BIGINT NOT NULL,
  event_type VARCHAR(255) NOT NULL,
  event_data JSONB NOT NULL,
  metadata JSONB,
  timestamp TIMESTAMP NOT NULL,
  PRIMARY KEY (aggregate_id, version)
);
CREATE INDEX idx_aggregate_id ON events(aggregate_id);
CREATE INDEX idx_timestamp ON events(timestamp);
```

Optimistic concurrency: insert with expected version, catch unique constraint violation indicating concurrent write. Retry with updated expected version or abort transaction.

**Distributed log platforms** (Kafka, EventStoreDB, Pulsar) provide built-in ordering, retention, and replication. Topic per aggregate type or single topic with partition key routing. Configurable retention (time-based or size-based) versus indefinite retention for complete history.

Kafka considerations: partition count affects parallelism but complicates rebalancing. Compaction unsuitable for event sourcing due to loss of intermediate events. Retention policies must account for longest required replay window.

**Hybrid approaches** combine database for queryable metadata with blob storage for event payloads. Metadata table stores aggregate_id, version, event_type, timestamp with payload reference. Reduces database size while maintaining query capability.

Cloud blob storage (S3, GCS, Azure Blob) provides cost-effective storage for high-volume event streams. Structured paths like `{year}/{month}/{day}/{aggregate_id}/{version}` enable efficient range queries and lifecycle policies.

### State Reconstruction and Projections

**Full replay** iterates entire event log applying each event to initial state. Required for projection rebuilds or temporal queries at arbitrary points. Performance degrades linearly with event count; mitigation via snapshots or incremental projections.

Replay optimization: batch event loading, parallel aggregate reconstruction (different aggregate IDs process concurrently), and in-memory event caching for repeated replays.

**Snapshot-based replay** stores periodic state snapshots, replaying only events after snapshot. Snapshot frequency trades storage cost versus replay latency. Snapshot every N events (100-1000 typical) or time-based (hourly, daily).

Snapshot invalidation: snapshots become stale when event schema changes or projection logic updates. Version snapshots alongside events; discard incompatible snapshots forcing full replay.

**Incremental projections** (read models) subscribe to event stream, updating materialized views as events arrive. Decouples read performance from write volume. Multiple specialized projections optimize different query patterns.

Projection consistency: eventual consistency typical; projections lag event writes by milliseconds to seconds. Clients requiring read-your-writes must query event store directly or use versioned reads with wait-for-version semantics.

**Temporal projections** reconstruct state at specific historical points. Query "what was account balance on 2024-12-01?" replays events until timestamp. Enables regulatory compliance, debugging, and what-if analysis.

Implementation: filter events by timestamp, apply to initial state. Optimize with time-indexed snapshots; find snapshot preceding target time, replay subsequent events.

### Aggregate Design Patterns

**Aggregate boundaries** define transactional consistency scope. Events within single aggregate apply atomically; cross-aggregate consistency eventual. Aggregate size impacts conflict rate and replay performance.

Anti-pattern: large aggregates with many child entities increase conflict probability and replay cost. Prefer fine-grained aggregates with clear transactional boundaries.

**Event granularity** balances expressiveness versus event count. Coarse events (OrderCompleted) lose intermediate state changes. Fine events (OrderItemAdded, OrderShippingMethodSelected) enable detailed audit but increase replay cost.

Decision criteria: business value of intermediate states, audit requirements, and projection complexity. E-commerce orders benefit from fine-grained events; simple state machines tolerate coarse events.

**Command handling** validates business rules before emitting events. Commands express intent (PlaceOrder), events express facts (OrderPlaced). Command handler loads current aggregate state via replay, validates command, emits events.

Validation strategy: optimistic by default, load aggregate from event store, validate command against current state, append events if valid. Retry on concurrent modification (version conflict).

**Idempotency handling** prevents duplicate event application from retries. Assign unique command IDs; track processed IDs in aggregate state. Reject commands with already-processed IDs. Alternatively, deterministic event IDs enable at-least-once processing with idempotent application.

### Consistency Patterns

**Strong consistency within aggregate** enforces business invariants through synchronous event appending. Command succeeds only after events durably stored. Subsequent commands observe all prior events.

Conflict resolution: concurrent commands to same aggregate produce version conflicts. Last-writer-wins inappropriate; reject conflicting command, return error to client for retry with updated state.

**Eventual consistency across aggregates** coordinates via asynchronous event handlers (sagas, process managers). AggregateA emits event triggering command to AggregateB. Compensating events handle failures.

Saga pattern: long-running process coordinates multiple aggregates. Saga state persists as events; failure triggers compensating actions. Example: order fulfillment saga coordinates inventory, payment, shipping aggregates.

**Causal consistency** preserves happened-before relationships across aggregates. Vector clocks or causal event IDs track dependencies. Projection applies events respecting causal order even if physical arrival order differs.

### Event Versioning and Schema Migration

**Weak schema enforcement** uses dynamic JSON/map structures tolerating missing fields. New fields ignored by old code; old fields provide defaults. Simplifies evolution but loses type safety and compile-time validation.

**Strong schema enforcement** with explicit versioning requires migration strategies. In-place transformation rewrites old events to new schema; lazy transformation converts during read; multi-version handlers support both schemas.

In-place transformation risks: data loss if transformation buggy, long migration windows for large event stores, and rollback complexity. Prefer lazy transformation or multi-version handlers.

**Upcast functions** transform EventV1 to EventV2 during replay. Projection code operates on current schema only. Centralize upcasting in event store layer; projections remain version-agnostic.

Chain upcasts for multiple versions: EventV1 → EventV2 → EventV3. Test upcast chains thoroughly; bugs corrupt all projections depending on that event type.

**Deprecation strategy** for obsolete event types. Mark deprecated in schema registry, monitor usage, remove upcast support after grace period. Retain historical events for audit even if no longer processed.

### Performance Optimization

**Event batching** appends multiple events atomically. Reduces round-trips to event store; improves throughput. Batch size trades latency versus throughput; typical range 10-100 events per batch.

Transaction boundaries: batch events from single aggregate modification, not cross-aggregate to preserve consistency guarantees.

**Parallelization of replay** processes independent aggregates concurrently. Partition aggregate IDs across worker threads/processes. Effective for projection rebuilds scanning entire event log.

Coordination overhead: workers must merge results if projection spans aggregates (global statistics). Lock-free data structures or partitioned projections reduce contention.

**Event compaction** for CRUD-dominated domains. OrderCreated followed by OrderDeleted within retention window collapses to nothing. Applicability limited; most domains have non-canceling events.

[Unverified] Compaction complexity and risk of data loss limit adoption. Prefer snapshots with event truncation over compaction.

**Caching replay results** stores reconstructed aggregates in memory cache (Redis, Memcached). Cache key: aggregate_id + version. Invalidate on new events for that aggregate. Effective for read-heavy workloads.

Cache coherency: ensure cache invalidation happens-before event commit visible. Otherwise reads observe stale cached state.

### Multi-Tenancy Strategies

**Tenant-per-partition** isolates tenants within separate partitions/topics. Simplifies access control and blast radius containment. Partition proliferation impacts metadata overhead and rebalancing cost.

**Shared partition with tenant filtering** multiplexes tenants within partitions. Event metadata includes tenant_id; consumers filter events. Higher density but requires careful access control enforcement.

Row-level security: database-backed stores use tenant_id in WHERE clauses with application-enforced tenant context. Misconfiguration exposes cross-tenant data.

**Tenant-specific projections** materialize separate read models per tenant. Scales read throughput but multiplies storage and compute cost. Suitable for low tenant count with high isolation requirements.

### Observability and Debugging

**Event versioning metrics** track event type distribution across schema versions. High legacy version counts indicate migration lag. Per-projection upcast performance identifies bottlenecks.

**Replay performance profiling** measures time-per-event-type during projection rebuilds. Identify expensive event handlers for optimization. Histogram of events-per-aggregate reveals outlier aggregates.

**Event stream lag** monitors projection currency. Measure time delta between event timestamp and projection application timestamp. Growing lag indicates projection throughput insufficient for event rate.

Alerting thresholds: seconds for real-time projections, minutes for analytics projections. Sustained lag indicates scaling required.

**Distributed tracing** propagates trace context through events. Correlation IDs link commands to events to projections. Visualize causality chains across aggregate boundaries.

OpenTelemetry integration: embed trace_id, span_id in event metadata. Reconstruct request flow through event-driven system for debugging.

### Testing Strategies

**Event-based assertions** verify command handlers emit expected events. Given initial events, when command executed, then assert emitted events match expectations. Tests decouple from state representation.

Assertion libraries: compare event types, payloads, and metadata. Ignore non-deterministic fields (timestamps, random IDs) via matchers.

**Property-based testing** generates random command sequences, verifies invariants hold after replay. Catches edge cases manual testing misses. Example: account balance never negative regardless of concurrent deposits/withdrawals.

**Projection testing** verifies read model correctness. Given sequence of events, assert projection state matches expected. Test incremental updates and full rebuilds produce identical results.

**Temporal query testing** validates historical state reconstruction. Insert events spanning time range, query various timestamps, verify returned state consistent with events up to that point.

### Migration from State-Based Systems

**Dual-write pattern** writes to both legacy database and event store during transition. Read from legacy database initially; switch reads to projections after validation. Risky: consistency between systems difficult to maintain.

[Inference] Prefer stop-the-world migration or strangler pattern over dual-write when feasible.

**Event extraction from database** generates synthetic events from current state snapshots. Emit StateCreated events with full state. Lose historical transitions but establish event-sourced baseline.

**Change data capture (CDC)** streams database changes as events. Tools like Debezium convert database logs (binlog, WAL) to event streams. Enables gradual migration; legacy writes flow through CDC to event store.

CDC limitations: schema mapping complexity, transaction boundary reconstruction, and operational overhead of CDC infrastructure.

### Edge Cases and Anti-Patterns

**Event explosion** from overly granular events. Example: emitting PixelChanged events in graphics editor. Aggregate reconstruction becomes prohibitively expensive. Mitigation: batch related changes into coarser events.

**Missing compensating events** when domain actions reversed. Deleting entities without DeletedEvent leaves orphaned state in projections. Always emit explicit reverse events rather than physical deletion.

**Brittle projections coupled to event schema** break when event structure changes. Defensive projection code checks field existence before access, provides defaults for missing fields.

**Snapshot bugs corrupting state** when snapshot logic diverges from replay logic. Validate snapshots by comparing against full replay results periodically. Discard corrupt snapshots forcing full replay.

**Unbounded aggregate growth** when aggregates accumulate unlimited events. Shopping cart holding thousands of items or infinitely growing audit logs. Mitigation: archive old events to cold storage, maintain rolling window, or split aggregates when exceeding thresholds.

**Event causality violations** when projection applies events out-of-order. Distributed systems may deliver events from different partitions in non-causal order. Implement causal delivery guarantees or dependency tracking.

**Ignoring idempotency** allows duplicate event application from retries. Projections must handle at-least-once delivery semantics. Track processed event IDs or make handlers naturally idempotent.

**Privacy violations** retaining personally identifiable information indefinitely. GDPR right-to-erasure conflicts with immutable event log. Mitigation: crypto-shredding (encrypt PII, destroy keys), event anonymization, or exemption assertions.

Related topics: CQRS (Command Query Responsibility Segregation), domain-driven design aggregates, saga pattern, process manager pattern, change data capture, stream processing (Kafka Streams, Flink), eventual consistency, conflict-free replicated data types, distributed tracing, event stream processing, log-structured merge trees, write-ahead logging.

---

## Event Store

Append-only database optimized for persisting and querying domain events in event-driven and event-sourced architectures. Treats events as immutable first-class entities, storing complete history of state changes rather than current state snapshots. Enables temporal queries, audit trails, and event replay for reconstructing application state.

### Core Characteristics

**Append-Only Semantics**: Events never updated or deleted after insertion. Each event represents immutable fact about past occurrence. Updates modeled as compensating events rather than in-place modifications. Append-only property enables aggressive caching, simplified concurrency control, and temporal consistency guarantees.

**Ordered Event Streams**: Events organized into ordered sequences (streams) per aggregate or entity. Stream provides total ordering of events for single aggregate. Position within stream typically monotonically increasing integer or timestamp-based sequence number.

**Event Immutability**: Once persisted, event content cannot change. References to events remain valid indefinitely. Enables sharing event references across system boundaries without staleness concerns. Schema evolution handled through versioning and upcasting rather than mutation.

**Temporal Queries**: Query event history at any point in time. Reconstruct aggregate state as of specific timestamp or version. Support "as-of" queries like "what was customer balance on 2024-12-31" without maintaining separate snapshots.

### Storage Model

**Event Schema**: Minimum fields: event_id (unique identifier), stream_id (aggregate identifier), sequence_number (position in stream), event_type (discriminator), event_data (serialized payload), metadata (causation_id, correlation_id, timestamp, user_id), created_at (wall clock time).

**Stream Partitioning**: Streams typically partitioned by aggregate type and ID. Example: `account-{aggregate_id}` creates separate stream per account aggregate. Partition key enables co-location of related events and efficient range scans.

**Global Ordering**: Some implementations provide global event ordering across all streams via global sequence number or commit timestamp. Enables downstream consumers to process events in total order. Requires coordination overhead—single writer or distributed consensus for sequence allocation.

**Storage Backend**: Specialized event stores (EventStoreDB, Axon Server) use custom storage engines optimized for append workloads. General-purpose databases (PostgreSQL, MongoDB) viable with appropriate schema design. Log-structured storage systems (Kafka, Pulsar) provide natural fit for event semantics.

### Optimistic Concurrency Control

Event stores typically use optimistic locking to prevent conflicting concurrent writes to same stream.

**Expected Version**: Write operation specifies expected current version of stream. Write succeeds only if stream version matches expectation. Mismatch indicates concurrent modification—write rejected with concurrency exception.

**Version Semantics**: Initial stream creation: expected_version = -1 or "stream does not exist". Unconditional write (any version): expected_version = -2 or "any". Specific version: expected_version = N where N is last known sequence number.

**Retry Logic**: Application catches concurrency exception, reloads current aggregate state, re-executes business logic with updated state, retries write with new expected version. Automatic retry dangerous—may repeatedly execute non-idempotent side effects.

**Anti-Pattern - Blind Retries**: Automatically retrying failed writes without re-executing business logic. Original command may no longer be valid given updated state. Example: transfer approved based on sufficient balance, retry after concurrent withdrawal leaves insufficient funds. Must reload state and re-validate before retry.

### Event Projection

Materialized views derived from event streams. Projections maintain queryable read models updated as events arrive.

**Inline Projections**: Updated synchronously during event write transaction. Ensures read model consistency with event store at cost of write latency. Suitable for critical projections where stale reads unacceptable.

**Asynchronous Projections**: Background processes consume events and update read models independently. Eventual consistency between event store and projections. Decouples write performance from projection complexity. Typical delay: milliseconds to seconds depending on throughput.

**Checkpoint Management**: Projections track last processed event position (checkpoint). On restart, resume from checkpoint rather than replaying all history. Checkpoints stored durably, often in same database as projection. Checkpoint + projection updates must be atomic to prevent inconsistency.

**Idempotent Processing**: Projection handlers must be idempotent—applying same event multiple times produces same result as single application. Required because at-least-once delivery guarantees may result in duplicate event processing. Strategies: deduplication via event_id tracking, natural idempotence (set operations), commutative operations.

**Projection Rebuilding**: Ability to delete projection and rebuild from event history. Enables fixing bugs in projection logic, adding new projections, or changing projection schema. Rebuild typically performed offline or using blue-green deployment to avoid serving stale data during rebuild.

### Snapshotting

Periodic materialization of aggregate state to avoid replaying thousands of events for reconstruction.

**Snapshot Strategy**: Capture aggregate state after N events (e.g., every 100 events) or at specific intervals. Store snapshot with associated stream version. Loading aggregate: fetch latest snapshot, replay events since snapshot version.

**Snapshot Storage**: Can be stored in event store alongside events or separate database. Snapshots are performance optimization—not source of truth. Missing or corrupted snapshots recoverable by replaying all events, albeit with degraded performance.

**Snapshot Invalidation**: Snapshots become stale as events added. Never need explicit invalidation—snapshot version determines applicability. Loading always uses latest snapshot ≤ requested version, replays events between snapshot and target version.

**Trade-offs**: Snapshots reduce replay cost but add write overhead and storage. Appropriate threshold depends on event frequency and aggregate complexity. Aggregates with 1000+ events over lifetime typically benefit. Short-lived aggregates with <50 events rarely justify snapshotting overhead.

**Anti-Pattern - Snapshot Dependency**: Treating snapshots as source of truth rather than optimization. Losing snapshots should not cause data loss—only performance degradation. System must remain functional with snapshot feature disabled.

### Event Versioning

Events schemas evolve as system requirements change. Handling multiple event versions simultaneously required for long-lived systems.

**Weak Schema**: Store events as JSON/XML with minimal structure validation. Maximum flexibility for schema evolution but loses type safety. Downstream consumers must handle unexpected fields, missing fields, and type variations.

**Strong Schema**: Use schema registry (Avro, Protobuf) to enforce structure. Schema evolution follows compatibility rules (forward, backward, full). Provides type safety and validated evolution but constrains flexibility.

**Upcasting**: Transform old event versions to new version on read. Event persisted in original version, converted to current version when loaded. Enables gradual migration without rewriting history. Upcast functions chain together: V1→V2→V3 to reach current version from any historical version.

**Downcasting**: Convert new events to old version for legacy consumers. Enables gradual consumer migration—new producer versions work with old consumer versions. Requires maintaining backward compatibility, which constrains new event design.

**Versioning Strategies**: Include version field in event (event_type: "OrderCreated", version: 2). Use separate event types per version (OrderCreatedV1, OrderCreatedV2). Store schema version in metadata. Choice depends on tooling and organizational preferences.

### Event Sourcing Patterns

**Command-Event Separation**: Commands express intent (CreateOrder), events express fact (OrderCreated). Commands can be rejected, events are immutable facts. Command handler validates invariants, generates events. Events applied to aggregate to update state.

**Aggregate Reconstruction**: Load all events for aggregate stream in sequence order. Apply each event to aggregate in order. Final state after applying all events represents current aggregate state. Zero-state aggregate + event stream = current state.

**Event Enrichment**: Add contextual information to events beyond minimum required for state reconstruction. User ID, timestamp, causation ID, correlation ID, request metadata. Enrichment supports debugging, analytics, and audit without requiring additional data stores.

**Event Correlation**: Link related events across aggregates using correlation_id (tracks business transaction) and causation_id (immediate cause). Enables distributed tracing and understanding of event causality chains across service boundaries.

### Subscription Models

Mechanisms for consuming events from store in real-time or near-real-time.

**Polling**: Consumer periodically queries for new events since last checkpoint. Simple but inefficient—generates unnecessary load and introduces polling interval latency. Acceptable for low-frequency updates or batch processing.

**Push Subscriptions**: Event store notifies subscribers when new events arrive. Requires persistent connection and subscriber registration. Reduces latency to milliseconds. Implementations use WebSockets, long polling, or server-sent events.

**Catch-up Subscriptions**: Start from historical position, consume historical events at maximum throughput, transition to live subscription when caught up. Enables new projections to build from history then maintain real-time updates seamlessly.

**Competing Consumers**: Multiple consumer instances share subscription, each processing disjoint subset of events. Requires coordinator to assign partitions/streams to consumers. Enables horizontal scaling of projection processing. Rebalancing needed when consumers added/removed.

**Subscription Filtering**: Subscribe to subset of events matching criteria (event_type, stream prefix, metadata values). Reduces network bandwidth and processing overhead for consumers interested in specific event types. Filtering at source more efficient than consumer-side filtering.

### Partitioning and Sharding

Horizontal scaling strategies for high-throughput event stores.

**Stream-Based Partitioning**: Distribute streams across multiple physical nodes using hash or range partitioning on stream_id. All events for single stream on same partition—preserves stream ordering. Scatter-gather queries across partitions for global operations.

**Hot Partition Problem**: High-traffic streams become bottlenecks if partition cannot handle write throughput. Mitigation: sub-partition high-traffic streams (split single logical stream across multiple physical streams), provision additional capacity for hot partitions, implement backpressure to throttle writes.

**Partition Rebalancing**: As nodes added or removed, redistribute streams across partitions. Requires coordinated migration of event data and subscription state. Live rebalancing complex—typically requires brief write pause or versioned dual-writing to old and new partitions.

**Cross-Partition Transactions**: Events spanning multiple streams on different partitions require distributed transaction coordination. Two-phase commit adds latency and reduces availability. Alternative: eventually consistent propagation with compensation events for failures.

### Querying Patterns

**Stream Reads**: Fetch events for specific stream, optionally filtered by version range or event type. Primary query pattern. Highly optimized with indexed lookups. O(1) to locate stream, O(N) to scan events within version range.

**Category Streams**: Logical grouping of related streams. Example: `$ce-account` contains all events from streams matching `account-*` prefix. Enables querying all events for aggregate type. Implemented via indexes or stream references.

**Global Event Ordering**: Query all events across all streams in commit order. Expensive operation requiring full scan or global secondary index. Limited use cases: debugging, building projections requiring cross-aggregate ordering, event export.

**Temporal Queries**: "Show all events between timestamps T1 and T2." Requires secondary index on event timestamp. Timestamp-based queries imprecise due to clock skew and out-of-order writes. Prefer sequence-based queries where possible.

**Anti-Pattern - Complex Queries on Event Store**: Using event store for complex analytical queries (aggregations, joins, full-text search). Event store optimized for append and sequential read. Build dedicated read models for complex queries via projections.

### Consistency Guarantees

**Per-Stream Consistency**: All reads and writes for single stream are strictly serializable. Optimistic concurrency control ensures no lost updates. Readers always observe consistent event sequence for stream.

**Cross-Stream Consistency**: No atomicity guarantees across streams without additional coordination. Events for separate aggregates written independently. Eventual consistency via event propagation and saga patterns.

**Read-Your-Writes**: After writing events, subsequent reads from same connection/session observe those events. May not hold across different sessions or connections depending on replication lag in distributed deployments.

**Monotonic Reads**: Once event observed, subsequent reads never return earlier state. Guaranteed within single stream. May be violated globally if reading from replicas with replication lag.

### Archival and Retention

**Event Immutability vs. Compliance**: Legal requirements (GDPR, CCPA) mandate data deletion, conflicting with immutability. Strategies: delete/tombstone specific events (degrades audit capability), encrypt events with per-user keys (delete key = inaccessible data), separate PII into side tables with foreign keys.

**Historical Archival**: Move old events to cold storage after retention period. Recent events in hot storage (fast disk, memory). Archived events in cold storage (S3, tape). Transparent access tier—queries seamlessly span hot and cold storage.

**Stream Truncation**: Remove events before specific version from stream. Useful for bounded aggregates where old history irrelevant. Truncated events no longer available—projections must already be past truncation point or use snapshots.

**Compaction**: Remove superseded events when only final state matters. Example: repeatedly updating same field generates many events, compaction retains only latest value. Violates event sourcing principles—loses audit trail. Only appropriate for specific use cases like configuration management.

### Performance Optimization

**Batching Writes**: Group multiple events into single write transaction. Amortizes commit overhead across events. Typical batch: 10-100 events. Higher batches increase throughput but worsen latency. Adaptive batching based on load.

**Write-Ahead Logging**: Persist to durable log immediately, asynchronously update indexes and projections. Acknowledges write after log persistence but before secondary structures updated. Reduces write latency from ~10ms to ~1ms.

**Index Optimization**: Covering indexes for common query patterns avoid accessing event data. Example: index on (stream_id, sequence_number) covering stream reads. Trade-off: indexes increase write cost and storage.

**Connection Pooling**: Reuse database connections across requests. Connection establishment expensive (100+ms for SSL handshake). Pool size tuned based on concurrency requirements and database connection limits.

**Caching**: Cache recent events, snapshots, projection results. Event immutability enables aggressive caching without invalidation concerns. Cache keyed by (stream_id, version_range). Typical hit rate >80% for read-heavy workloads.

### Monitoring and Operations

**Write Throughput**: Track events/second written to store. Monitor percentile latencies (p50, p95, p99). Alert on degraded write performance indicating disk saturation, lock contention, or index maintenance overhead.

**Subscription Lag**: Measure delay between event written and processed by subscribers. Large lag indicates projection cannot keep pace with write rate. Remediation: optimize projection logic, horizontal scaling, increase polling frequency.

**Storage Growth**: Monitor event count and storage size. Unbounded growth requires archival or retention policies. Typical growth rates: 1-10GB per million events depending on serialization format and event size.

**Error Rates**: Track concurrency exceptions, serialization errors, constraint violations. Elevated concurrency exceptions indicate high contention on specific streams or incorrect retry logic. Serialization errors suggest schema compatibility issues.

**Snapshot Efficiency**: Measure snapshot hit rate (aggregate loads using snapshot vs. full replay). Low hit rate indicates inappropriate snapshot intervals or snapshot storage failures.

### Anti-Patterns

**Event Sourcing Everything**: Applying event sourcing to all aggregates regardless of requirements. Event sourcing adds complexity—justified for aggregates requiring audit trail, temporal queries, or complex business workflows. Simple CRUD entities better served by traditional state storage.

**Large Events**: Storing complete aggregate state in single event. Creates coupling between events—later events depend on structure of earlier events. Events should contain deltas (changes) not full state. Large events increase storage costs, network overhead, and serialization time.

**Business Logic in Projections**: Embedding domain logic in projection handlers. Projections are read model construction—mechanical translation from events to queryable format. Business logic belongs in command handlers that generate events. Logic in projections cannot be tested by replaying events.

**Ignoring Idempotence**: Assuming exactly-once event processing. Distributed systems provide at-least-once guarantees. Non-idempotent projections produce incorrect results on replay or duplicate delivery. Every projection handler must be idempotent.

**Synchronous Projections**: Updating all projections synchronously during event write. Write latency proportional to slowest projection. Single slow projection degrades entire system. Use asynchronous projections with eventual consistency.

**Missing Correlation Metadata**: Omitting causation_id and correlation_id from events. Debugging distributed workflows requires tracking event chains across services. Without correlation metadata, understanding system behavior during incidents extremely difficult.

**Unbounded Streams**: Allowing streams to grow indefinitely without snapshots or archival. Aggregate reconstruction becomes increasingly expensive. Typical problematic threshold: >10,000 events per stream. Implement snapshotting and consider aggregate lifecycle design.

### Security Considerations

**Event Encryption**: Encrypt sensitive event data at rest and in transit. Field-level encryption for PII within events. Key management via KMS or HSM. Performance impact: 10-30% throughput reduction depending on algorithm and payload size.

**Access Control**: Restrict stream access based on user roles and aggregate ownership. Fine-grained ACLs per stream or stream category. Coarse-grained controls at database/table level insufficient for multi-tenant systems.

**Audit Trail Integrity**: Events form audit trail—tampering detection critical. Digital signatures or cryptographic hashes chain events together. Merkle trees enable efficient verification of event sequence integrity. Trade-off: verification overhead vs. tamper evidence strength.

**Event Anonymization**: Remove or pseudonymize PII from events while preserving analytical utility. Irreversible anonymization prevents compliance with deletion requests. Prefer encryption with destroyable keys over anonymization.

### Related Topics

Event-driven architecture, CQRS (Command Query Responsibility Segregation), domain-driven design aggregates, saga pattern for distributed transactions, process managers, event choreography vs orchestration, change data capture (CDC), transaction log mining, temporal modeling, bi-temporal data, audit logging, immutable infrastructure, log-structured merge trees, write-ahead logging, materialized views, stream processing, Apache Kafka for event streaming, eventual consistency patterns, compensating transactions.

---

## Event Replay

### Core Mechanics

Event replay reconstructs system state by sequentially reprocessing stored events from an event log or event store. The technique exploits event immutability and deterministic event handlers to rebuild aggregate state, projections, or derived views without maintaining separate persistent state.

**Replay scenarios**:

- State reconstruction after data loss or corruption
- Temporal queries (state at specific point in time)
- New projection creation from existing event history
- Bug fixes requiring reprocessing with corrected logic
- System migration or schema evolution
- Audit and compliance verification
- Development and testing with production-like data

### Event Store Requirements

**Append-only log structure**: Events stored in immutable, ordered sequence. Each event assigned monotonically increasing sequence number or offset within stream:

```python
# Anti-pattern: Mutable event records
def update_event(event_id, new_data):
    events_table.update({"id": event_id}, {"data": new_data})

# Correct: Append-only with versioning
def append_correction_event(original_event_id, corrected_data):
    events_table.insert({
        "type": "EventCorrected",
        "original_event_id": original_event_id,
        "corrected_data": corrected_data,
        "sequence": get_next_sequence()
    })
```

**Total ordering guarantee**: Within single stream/aggregate, events must have unambiguous ordering. Timestamp-based ordering insufficient due to clock skew:

```python
# Anti-pattern: Timestamp-only ordering
events = event_store.query(
    aggregate_id="user-123",
    order_by="timestamp"  # Ambiguous for simultaneous events
)

# Correct: Sequence number with timestamp
events = event_store.query(
    aggregate_id="user-123",
    order_by="sequence_number"  # Unambiguous total order
)
```

**Efficient range queries**: Support sequential reads from arbitrary position. Index on `(stream_id, sequence_number)` enables efficient replay from checkpoint.

**Snapshotting infrastructure**: Store periodic state snapshots to avoid full replay overhead. Snapshot + subsequent events reconstruct current state:

```python
class SnapshotStrategy:
    def should_snapshot(self, event_count, last_snapshot_time):
        # Anti-pattern: Fixed event interval only
        # return event_count % 1000 == 0
        
        # Correct: Hybrid time and count threshold
        time_threshold = time.time() - last_snapshot_time > 3600
        count_threshold = event_count % 1000 == 0
        return time_threshold or count_threshold
```

### Deterministic Event Handlers

**Idempotency requirement**: Replaying same event multiple times produces identical state transitions. Critical for fault tolerance and exactly-once processing semantics:

```python
# Anti-pattern: Non-idempotent handler with side effects
def handle_order_placed(event):
    order = create_order(event.order_id)
    send_confirmation_email(event.customer_email)  # Side effect
    decrement_inventory(event.product_id)
    return order

# Correct: Deterministic state update, separate side effect tracking
def handle_order_placed(event, state):
    state.orders[event.order_id] = Order(
        id=event.order_id,
        customer=event.customer_id,
        items=event.items,
        status="placed"
    )
    state.pending_notifications.append({
        "type": "email",
        "recipient": event.customer_email,
        "template": "order_confirmation"
    })
    for item in event.items:
        state.inventory[item.product_id] -= item.quantity
    return state
```

**Elimination of external dependencies**: Event handlers must derive output solely from event data and prior state. No external API calls, database queries, or random number generation:

```python
# Anti-pattern: External dependency during replay
def handle_payment_processed(event):
    exchange_rate = currency_api.get_rate(event.currency)  # External call
    amount_usd = event.amount * exchange_rate
    return {"amount_usd": amount_usd}

# Correct: Capture exchange rate in event
def handle_payment_processed(event):
    # Event contains exchange_rate_at_time captured during command processing
    amount_usd = event.amount * event.exchange_rate
    return {"amount_usd": amount_usd}
```

**Timestamp handling**: Use event timestamp, not current time:

```python
# Anti-pattern: Current time during replay
def handle_session_started(event, state):
    state.last_activity = datetime.now()  # Different on each replay

# Correct: Event timestamp
def handle_session_started(event, state):
    state.last_activity = event.timestamp
```

### Replay Strategies

**Full replay**: Process entire event stream from beginning. Necessary for:

- Initial projection creation
- Complete state verification
- Event handler logic changes affecting all events

```python
def full_replay(event_store, projection):
    projection.reset()  # Clear existing state
    for event in event_store.read_all_events():
        projection.apply(event)
    projection.mark_complete()
```

**Incremental replay**: Process events from last checkpoint. Enables continuous projection updates:

```python
def incremental_replay(event_store, projection):
    last_position = projection.get_checkpoint()
    for event in event_store.read_from(last_position):
        projection.apply(event)
        if should_checkpoint(event):
            projection.save_checkpoint(event.sequence)
```

**Parallel replay**: Partition event streams for concurrent processing. Requires independence between partitions:

```python
def parallel_replay(event_store, projection, num_workers):
    partitions = partition_streams_by_aggregate(event_store)
    
    with ThreadPoolExecutor(max_workers=num_workers) as executor:
        futures = []
        for partition in partitions:
            future = executor.submit(replay_partition, partition, projection)
            futures.append(future)
        
        # Wait for completion, handle failures
        for future in as_completed(futures):
            try:
                future.result()
            except Exception as e:
                log.error(f"Replay partition failed: {e}")
                raise
```

**Temporal replay**: Reconstruct state at specific point in time. Process events until target timestamp:

```python
def temporal_replay(event_store, aggregate_id, target_timestamp):
    state = initialize_state()
    events = event_store.read_stream(aggregate_id)
    
    for event in events:
        if event.timestamp > target_timestamp:
            break
        state = apply_event(state, event)
    
    return state
```

### Versioning and Schema Evolution

**Event versioning**: Events require forward/backward compatibility as system evolves. Multiple event versions coexist in event store:

```python
class EventUpcast:
    def upcast(self, event):
        # Anti-pattern: Mutating original event
        # event.data['new_field'] = 'default'
        
        # Correct: Transform to new version
        if event.version == 1:
            return {
                "version": 2,
                "type": event.type,
                "data": {
                    **event.data,
                    "new_field": self.derive_from_v1(event.data)
                },
                "timestamp": event.timestamp
            }
        return event
```

**Weak schema approach**: Store events with flexible schema (JSON), handle multiple versions in handlers:

```python
def handle_user_registered(event):
    # Handle multiple versions
    if event.version == 1:
        return User(
            id=event.data['user_id'],
            email=event.data['email'],
            # Missing in v1, use default
            preferences={'notifications': True}
        )
    elif event.version == 2:
        return User(
            id=event.data['user_id'],
            email=event.data['email'],
            preferences=event.data['preferences']
        )
```

**Copy-and-transform migration**: Maintain legacy event handlers during transition period. New projections ignore deprecated events:

```python
class ProjectionV2:
    def apply(self, event):
        if event.type == "LegacyEventType":
            # Ignore deprecated events
            return
        elif event.type == "NewEventType":
            self.handle_new_event(event)
```

**Upcasting pipeline**: Transform events to latest schema version during replay. Original events remain immutable:

```python
def replay_with_upcasting(event_store, projection, upcaster):
    for raw_event in event_store.read_all_events():
        current_event = upcaster.upcast_to_latest(raw_event)
        projection.apply(current_event)
```

### Performance Optimization

**Snapshot frequency tuning**: Balance snapshot overhead vs. replay cost. More frequent snapshots reduce replay time but increase storage:

```python
class AdaptiveSnapshotPolicy:
    def __init__(self):
        self.replay_times = []
        
    def should_snapshot(self, events_since_snapshot):
        avg_replay_time = np.mean(self.replay_times[-10:])
        snapshot_cost = estimate_snapshot_cost()
        replay_cost = events_since_snapshot * avg_event_process_time()
        
        # Snapshot when replay cost exceeds snapshot cost
        return replay_cost > snapshot_cost * 1.5
```

**Batch event processing**: Reduce per-event overhead by processing in batches:

```python
# Anti-pattern: Individual event processing
for event in events:
    state = apply_event(state, event)
    save_state(state)

# Correct: Batch processing with periodic checkpoints
batch_size = 1000
for batch in chunk(events, batch_size):
    for event in batch:
        state = apply_event(state, event)
    save_state(state)  # Checkpoint once per batch
```

**Projection-specific optimization**: Different projections have different replay characteristics. Optimize independently:

```python
class FastProjection:
    """Optimized for rapid replay, minimal state"""
    def apply(self, event):
        # In-memory only, no I/O
        self.counters[event.type] += 1

class ComplexProjection:
    """Rich state, slower replay, requires snapshots"""
    def apply(self, event):
        # Complex business logic, database writes
        self.rebuild_complex_aggregate(event)
        if should_checkpoint():
            self.save_snapshot()
```

**Read optimization**: Use read-replicas or cache for projection queries during replay:

```python
def replay_with_read_isolation(event_store, projection):
    # Mark projection as rebuilding
    projection.set_status("REBUILDING")
    
    # Replay to temporary projection
    temp_projection = projection.create_temporary()
    for event in event_store.read_all_events():
        temp_projection.apply(event)
    
    # Atomic swap to new projection
    projection.swap(temp_projection)
    projection.set_status("ACTIVE")
```

### Failure Handling

**Poison event handling**: Events causing handler exceptions block replay progress:

```python
class ResilientReplay:
    def __init__(self, max_retries=3):
        self.max_retries = max_retries
        self.failed_events = []
        
    def replay_with_retry(self, event_store, projection):
        for event in event_store.read_all_events():
            retries = 0
            while retries < self.max_retries:
                try:
                    projection.apply(event)
                    break
                except TransientError as e:
                    retries += 1
                    backoff = 2 ** retries
                    time.sleep(backoff)
                except PermanentError as e:
                    # Log and skip poison event
                    self.failed_events.append({
                        "event": event,
                        "error": str(e)
                    })
                    log.error(f"Skipping poison event: {event.id}")
                    break
```

**Checkpoint corruption recovery**: Detect checkpoint inconsistency and fall back to earlier checkpoint or full replay:

```python
def verify_checkpoint(projection, event_store):
    checkpoint_seq = projection.get_checkpoint()
    checkpoint_hash = projection.get_state_hash()
    
    # Recompute hash from events
    state = initialize_state()
    for event in event_store.read_to(checkpoint_seq):
        state = apply_event(state, event)
    
    computed_hash = hash_state(state)
    
    if computed_hash != checkpoint_hash:
        log.error("Checkpoint corruption detected")
        # Fall back to previous checkpoint
        return projection.get_previous_checkpoint()
    
    return checkpoint_seq
```

**Partial replay failure**: Support resumption from arbitrary position without restarting:

```python
class RecoverableReplay:
    def replay(self, event_store, projection):
        try:
            last_position = projection.get_checkpoint()
            for event in event_store.read_from(last_position):
                projection.apply(event)
                # Frequent checkpointing for recovery
                if event.sequence % 100 == 0:
                    projection.save_checkpoint(event.sequence)
        except Exception as e:
            log.error(f"Replay failed at position {event.sequence}: {e}")
            # Next run resumes from last checkpoint
            raise
```

### Consistency Considerations

**Projection lag**: Time between event occurrence and projection update. Monitor and alert on excessive lag:

```python
def calculate_lag(event_store, projection):
    latest_event_time = event_store.get_latest_event_timestamp()
    projection_time = projection.get_last_processed_timestamp()
    lag_seconds = (latest_event_time - projection_time).total_seconds()
    
    if lag_seconds > ACCEPTABLE_LAG_THRESHOLD:
        alert(f"Projection lag: {lag_seconds}s")
    
    return lag_seconds
```

**Eventually consistent reads**: Queries against projections may return stale data. Expose staleness to clients:

```python
@app.route('/api/user/<user_id>')
def get_user(user_id):
    user = projection.get_user(user_id)
    last_update = projection.get_last_processed_timestamp()
    
    return {
        "user": user,
        "metadata": {
            "as_of": last_update.isoformat(),
            "lag_seconds": (datetime.utcnow() - last_update).total_seconds()
        }
    }
```

**Causal consistency**: Ensure events from same aggregate maintain ordering during replay:

```python
# Anti-pattern: Parallel processing violating causality
def parallel_replay_unsafe(events):
    with ThreadPoolExecutor() as executor:
        # Events from same aggregate processed concurrently
        executor.map(process_event, events)

# Correct: Partition by aggregate for causal consistency
def parallel_replay_safe(events):
    by_aggregate = group_by_aggregate(events)
    
    with ThreadPoolExecutor() as executor:
        # Each aggregate's events processed sequentially
        for aggregate_events in by_aggregate.values():
            executor.submit(process_events_sequentially, aggregate_events)
```

### Anti-Patterns

**Non-deterministic event handlers**: Any source of non-determinism produces different state on replay:

```python
# Anti-pattern: UUID generation during replay
def handle_user_created(event, state):
    state.users[event.user_id] = User(
        id=event.user_id,
        session_id=uuid.uuid4()  # Different on each replay
    )

# Correct: Capture UUID in event
def handle_user_created(event, state):
    state.users[event.user_id] = User(
        id=event.user_id,
        session_id=event.session_id  # Deterministic from event
    )
```

**Missing event data**: Insufficient information in events prevents accurate replay:

```python
# Anti-pattern: Minimal event data
{
    "type": "PriceChanged",
    "product_id": "prod-123",
    "new_price": 29.99
}

# Correct: Complete context for replay
{
    "type": "PriceChanged",
    "product_id": "prod-123",
    "old_price": 19.99,
    "new_price": 29.99,
    "changed_by": "user-456",
    "reason": "seasonal_promotion",
    "timestamp": "2024-01-15T10:30:00Z"
}
```

**Unbounded replay time**: Large event stores without snapshots cause prohibitive replay duration. Always implement snapshotting for long-lived aggregates.

**Ignoring event order within transaction**: Events from single transaction must replay atomically and in order:

```python
# Anti-pattern: Independent event processing
for event in transaction.events:
    process_independently(event)

# Correct: Transaction boundary preservation
def replay_transaction(transaction_events):
    with atomic_scope():
        for event in transaction_events:
            process_event(event)
        commit()
```

**State mutation during replay**: Modifying event store during replay causes inconsistency:

```python
# Anti-pattern: Writing during replay
def replay_with_corrections(event_store):
    for event in event_store.read_all():
        if needs_correction(event):
            # Modifying store during read
            event_store.append_correction(event.id)

# Correct: Collect corrections, apply after replay
def replay_with_corrections(event_store):
    corrections = []
    for event in event_store.read_all():
        if needs_correction(event):
            corrections.append(create_correction(event))
    
    # Write corrections after replay complete
    for correction in corrections:
        event_store.append(correction)
```

### Testing Strategies

**Replay verification tests**: Ensure handlers produce consistent state across multiple replays:

```python
def test_replay_determinism():
    events = [event1, event2, event3]
    
    state1 = replay(events)
    state2 = replay(events)
    state3 = replay(events)
    
    assert state1 == state2 == state3
    assert hash(state1) == hash(state2) == hash(state3)
```

**Temporal consistency tests**: Verify state correctness at arbitrary points:

```python
def test_temporal_queries():
    events = generate_event_stream()
    
    # Query state at different timestamps
    state_t1 = replay_until(events, timestamp=t1)
    state_t2 = replay_until(events, timestamp=t2)
    
    # Verify invariants
    assert state_t2.total_orders >= state_t1.total_orders
    assert state_t2.revenue >= state_t1.revenue
```

**Performance regression tests**: Monitor replay duration as event volume grows:

```python
def test_replay_performance():
    event_counts = [1000, 10000, 100000]
    
    for count in event_counts:
        events = generate_events(count)
        start = time.time()
        replay(events)
        duration = time.time() - start
        
        # Verify sub-linear growth with snapshots
        assert duration < count * MAX_PER_EVENT_TIME
```

### Related Topics

- Event sourcing architectural patterns
- CQRS (Command Query Responsibility Segregation)
- Snapshot strategies and optimization
- Event store implementation and sharding
- Conflict resolution in distributed event logs
- Event-carried state transfer
- Stream processing frameworks (Kafka Streams, Flink)
- Saga pattern with compensating events
- Event versioning and schema evolution strategies
- Temporal queries and time-travel debugging
- Audit logging and compliance requirements
- Blue-green deployment with projection rebuilding

---

## Snapshot Pattern

The snapshot pattern in event-driven architectures creates point-in-time state representations by periodically capturing and persisting the complete current state of an aggregate, entity, or system. Snapshots serve as optimization checkpoints that eliminate the need to replay entire event histories from origin, reducing recovery time and query latency while maintaining event sourcing's audit trail and temporal query capabilities.

### Core Mechanics

**Snapshot Structure** A snapshot encapsulates:

- **Aggregate ID**: Uniquely identifies the entity
- **State**: Complete serialized representation of entity state at snapshot time
- **Version/Sequence Number**: Event stream position corresponding to snapshot state
- **Timestamp**: When snapshot was created
- **Metadata**: Schema version, compression type, checksum for integrity validation

```python
@dataclass
class Snapshot:
    aggregate_id: str
    state: bytes  # Serialized entity state
    version: int  # Last applied event sequence number
    timestamp: datetime
    schema_version: str
    checksum: str
```

**Snapshot Creation Timing** Deterministic triggers for snapshot generation:

- **Event count threshold**: Create snapshot every N events (e.g., every 100 events)
- **Time interval**: Periodic snapshots (hourly, daily) regardless of event volume
- **State size threshold**: Snapshot when serialized state exceeds size limit
- **On-demand**: Explicit snapshot requests during maintenance windows
- **Adaptive**: Adjust frequency based on replay cost vs storage cost metrics

### Reconstruction Algorithm

**With Snapshots**

```python
def reconstruct_aggregate(aggregate_id: str, target_version: Optional[int] = None):
    # Find most recent snapshot at or before target version
    snapshot = get_latest_snapshot(aggregate_id, before_version=target_version)
    
    if snapshot is None:
        # No snapshot exists, full replay required
        aggregate = create_empty_aggregate()
        start_version = 0
    else:
        # Deserialize snapshot state
        aggregate = deserialize(snapshot.state)
        start_version = snapshot.version + 1
    
    # Replay events from snapshot version to target
    events = get_events(aggregate_id, from_version=start_version, to_version=target_version)
    
    for event in events:
        aggregate.apply(event)
    
    return aggregate
```

**Performance Impact** Without snapshots: O(N) where N = total event count With snapshots: O(M) where M = events since last snapshot (typically M << N)

For aggregates with 10,000 events and snapshots every 100 events: 99% reduction in replay operations.

### Snapshot Storage Strategies

**Inline Storage** Store snapshots in same event store database, separate table/collection. Advantages: transactional consistency, single storage system. Disadvantages: event store bloat, mixed access patterns (sequential events vs random snapshot access).

**Dedicated Snapshot Store** Separate database optimized for large binary objects. Advantages: storage optimization, independent scaling, different backup policies. Disadvantages: consistency challenges, additional infrastructure.

**Tiered Storage** Recent snapshots in fast storage (SSD, in-memory cache); older snapshots in cold storage (S3, archival systems). Access patterns favor recent state—older snapshots rarely accessed except for temporal queries or compliance.

**Compression** Apply compression algorithms to serialized state:

- **Dictionary-based** (LZ4, Zstandard): Fast, moderate compression ratios (2-3x)
- **Columnar** (Parquet, ORC): Excellent for structured data with repeated patterns
- **Domain-specific**: Exploit application semantics (delta encoding for counters, sparse representations)

Benchmark compression ratio vs CPU cost. LZ4 typically optimal—10-20μs compression time vs 50-70% size reduction.

### Versioning and Schema Evolution

**Schema Version Tracking** Snapshots must include schema version identifiers. Deserialization requires compatible schema version:

```python
class SnapshotSerializer:
    def __init__(self):
        self.deserializers = {
            "v1": self._deserialize_v1,
            "v2": self._deserialize_v2,
            "v3": self._deserialize_v3,
        }
    
    def deserialize(self, snapshot: Snapshot):
        deserializer = self.deserializers.get(snapshot.schema_version)
        if deserializer is None:
            raise UnsupportedSchemaVersion(snapshot.schema_version)
        return deserializer(snapshot.state)
```

**Forward and Backward Compatibility**

- **Additive changes** (new optional fields): Backward compatible—old snapshots deserialize with defaults
- **Field removal**: Requires migration—cannot deserialize old snapshots without transformation
- **Field type changes**: Breaking change—requires migration or dual-version support

**Migration Strategies** Lazy migration: Deserialize old schema, apply to current domain model, next snapshot uses new schema. Eventually all snapshots migrate through natural lifecycle.

Eager migration: Background job re-snapshots all aggregates with new schema. High resource cost but immediate consistency.

Dual-version support: Maintain deserializers for N previous schema versions. Bound N based on snapshot retention policy (if snapshots retained 90 days, support schemas from past 90 days).

### Consistency and Concurrency

**Race Conditions During Snapshot Creation** New events may arrive while snapshot is being serialized. Two approaches:

**Optimistic Snapshotting**

1. Lock aggregate briefly to capture version number V
2. Serialize state asynchronously
3. Before persisting, verify no events > V have been applied
4. If verification fails, discard snapshot and retry

Minimizes lock contention but can waste CPU on discarded snapshots under high write rates.

**Pessimistic Snapshotting**

1. Acquire exclusive lock on aggregate
2. Serialize and persist snapshot
3. Release lock

Guarantees consistency but blocks writes. Only viable for low-throughput aggregates or during maintenance windows.

**Snapshot Isolation Levels** Snapshots represent **eventual consistency snapshots**—concurrent reads may see different versions depending on snapshot availability. Not serializable unless combined with version-based optimistic locking.

For read-your-writes consistency: After write, ensure snapshot version >= write version before querying.

### Snapshot Validation and Integrity

**Checksum Verification** Calculate checksum (SHA-256, xxHash) during serialization:

```python
serialized_state = serialize(aggregate)
checksum = hashlib.sha256(serialized_state).hexdigest()
snapshot = Snapshot(
    state=serialized_state,
    checksum=checksum,
    ...
)
```

On deserialization, recalculate and compare. Detect silent data corruption from storage failures.

**Event Replay Validation** Periodically validate snapshots by:

1. Reconstruct aggregate from snapshot
2. Reconstruct same aggregate from full event replay (no snapshot)
3. Assert state equivalence

Detects serialization bugs, schema migration errors, or event application logic changes.

**Snapshot Audit Trail** Log snapshot creation events: who/what triggered snapshot, duration, size, version range. Enables troubleshooting snapshot-related issues and capacity planning.

### Anti-Patterns

**Snapshot-First Design**: Using snapshots as primary state storage, treating events as audit log. Violates event sourcing principles—loses temporal queries, cannot replay with different logic. Snapshots are **optimizations only**, never authoritative.

**Ignoring Snapshot Failures**: If snapshot creation fails, system must continue operating via event replay. Common mistake: hard dependency on snapshots causing outages when snapshot store unavailable. Snapshots are performance enhancements, not correctness requirements.

**Over-Snapshotting**: Creating snapshots too frequently wastes storage and I/O. If aggregate receives 1 event/day but snapshots hourly, 95% of snapshots are duplicates. Balance snapshot frequency against replay cost.

**Under-Snapshotting**: For high-velocity aggregates (1000s events/second), rare snapshots cause unacceptable replay latency. Monitor P95/P99 reconstruction time, adjust snapshot frequency to maintain SLA.

**Monolithic Snapshots**: Capturing entire system state as single snapshot. Defeats granularity benefits of event sourcing. Snapshot per aggregate maintains bounded replay cost regardless of system size.

**Ignoring Clock Skew**: Using wall-clock timestamps for snapshot ordering across distributed nodes. Clock skew causes non-monotonic snapshot sequences. Use logical clocks (Lamport, vector clocks) or event version numbers for ordering.

**Snapshot Starvation Under Write Load**: High write rate prevents snapshot creation (always failing optimistic validation). Implement backpressure—throttle writes during snapshot or allocate snapshot windows with reduced write capacity.

### Advanced Patterns

**Incremental Snapshots (Deltas)** Instead of full state, store delta from previous snapshot:

```python
@dataclass
class IncrementalSnapshot:
    aggregate_id: str
    base_snapshot_version: int  # Reference to full snapshot
    delta: bytes  # State changes since base
    version: int
```

Reduces snapshot size for large aggregates with localized changes. Requires chain traversal for reconstruction—bound chain depth (full snapshot every N incrementals).

**Materialized Views as Snapshots** For read-heavy projections, treat materialized views as queryable snapshots. Update views synchronously or asynchronously from event stream. Provides O(1) query time vs O(M) reconstruction.

Views must track version—queries specify minimum version for consistency guarantees.

**Snapshot Streaming** For very large aggregates (GB-scale state), stream snapshot in chunks rather than monolithic write:

```python
def stream_snapshot(aggregate_id: str):
    aggregate = reconstruct(aggregate_id)
    snapshot_id = generate_id()
    
    for chunk in serialize_chunked(aggregate, chunk_size=10MB):
        write_snapshot_chunk(snapshot_id, chunk)
    
    commit_snapshot(snapshot_id, aggregate.version)
```

Enables snapshotting aggregates exceeding memory limits. Complicates deserialization—must stream chunks, reconstruct progressively.

**Snapshot Forecasting** Predict which aggregates will be accessed soon, proactively create snapshots. Based on access patterns (recently accessed likely to be re-accessed), time patterns (business hours vs off-hours), or explicit hints from application layer.

Reduces latency for predictable workloads but wastes resources on inaccurate predictions.

### Multi-Tenancy Considerations

**Tenant Isolation** Snapshots for different tenants must be isolated:

- Storage partitioning (separate tables/collections per tenant)
- Encryption per tenant (tenant-specific keys)
- Access control enforcement during snapshot retrieval

**Fairness in Shared Snapshot Infrastructure** One tenant's high-frequency snapshots should not starve others. Implement per-tenant quotas:

- Maximum snapshot creation rate (snapshots/hour)
- Maximum storage consumption
- I/O bandwidth limits for snapshot operations

**Tenant-Specific Snapshot Policies** Different tenants may have different snapshot requirements:

- Enterprise tier: Snapshots every 50 events
- Standard tier: Snapshots every 500 events
- Free tier: No snapshots (always full replay)

Configuration as tenant metadata.

### Snapshot Retention and Cleanup

**Retention Policies** Define how many snapshots to retain:

- **Count-based**: Keep last N snapshots per aggregate
- **Time-based**: Keep snapshots from last T days
- **Compliance-driven**: Retain all snapshots for audit requirements

**Garbage Collection** Identify safe-to-delete snapshots:

```python
def cleanup_snapshots(aggregate_id: str, retention_count: int):
    snapshots = list_snapshots(aggregate_id, order_by="version DESC")
    
    # Always keep minimum number of recent snapshots
    to_retain = snapshots[:retention_count]
    to_delete = snapshots[retention_count:]
    
    # Additional safety: never delete if events since snapshot are gone
    for snapshot in to_delete:
        if events_exist(aggregate_id, from_version=snapshot.version):
            delete_snapshot(snapshot)
        else:
            # Events pruned, keep snapshot as state recovery anchor
            log_warning(f"Cannot delete snapshot {snapshot.version}, events missing")
```

**Snapshot Tombstones** After deletion, write tombstone record indicating snapshot existed but was purged. Prevents confusion when reconstructing aggregate—absence of snapshot doesn't imply empty history.

### Performance Optimization

**Snapshot Caching** Cache deserialized snapshots in memory:

```python
class SnapshotCache:
    def __init__(self, max_size: int):
        self.cache = LRUCache(max_size)
    
    def get_or_reconstruct(self, aggregate_id: str, version: int):
        cache_key = (aggregate_id, version)
        
        if cached := self.cache.get(cache_key):
            return cached
        
        aggregate = reconstruct_aggregate(aggregate_id, version)
        self.cache.put(cache_key, aggregate)
        return aggregate
```

Critical for read-heavy workloads. Cache hit eliminates deserialization CPU cost. Size cache based on working set (frequently accessed aggregates).

**Lazy Deserialization** Defer field deserialization until accessed:

```python
class LazySnapshot:
    def __init__(self, serialized_data: bytes):
        self._data = serialized_data
        self._fields = {}
    
    def get_field(self, field_name: str):
        if field_name not in self._fields:
            # Deserialize only requested field
            self._fields[field_name] = extract_field(self._data, field_name)
        return self._fields[field_name]
```

Useful when queries access subset of large aggregate state. Reduces deserialization overhead by 50-90% for selective queries.

**Async Snapshot Creation** Decouple snapshot creation from event processing:

```python
class AsyncSnapshotter:
    def __init__(self):
        self.queue = Queue()
        self.worker = Thread(target=self._process_queue)
    
    def schedule_snapshot(self, aggregate_id: str, version: int):
        self.queue.put((aggregate_id, version))
    
    def _process_queue(self):
        while True:
            aggregate_id, version = self.queue.get()
            try:
                create_snapshot(aggregate_id, version)
            except Exception as e:
                log_error(f"Snapshot failed: {e}")
```

Event processing continues without blocking on snapshot I/O. Risks: snapshots lag behind current state, increasing replay window. Mitigate with bounded queue size and monitoring.

### Testing Strategies

**Snapshot Correctness Testing**

```python
def test_snapshot_equivalence(aggregate_id: str):
    # Reconstruct with snapshot
    with_snapshot = reconstruct_aggregate(aggregate_id)
    
    # Reconstruct without snapshot (full replay)
    disable_snapshots()
    without_snapshot = reconstruct_aggregate(aggregate_id)
    enable_snapshots()
    
    assert with_snapshot == without_snapshot
```

Run periodically in production (off critical path) or continuously in staging.

**Chaos Engineering**

- Corrupt snapshot data (bit flips), verify checksum detection
- Delete random snapshots, verify graceful degradation to full replay
- Inject latency/failures in snapshot store, verify event replay fallback
- Simulate schema version mismatches

**Performance Benchmarking** Measure reconstruction time across varying:

- Event count (0, 100, 1000, 10000 events)
- Snapshot intervals (every 10, 50, 100, 500 events)
- State size (KB, MB, GB-scale aggregates)

Identify optimal snapshot frequency for workload characteristics.

**Load Testing** Concurrent snapshots for many aggregates under high write load. Verify:

- Snapshot creation does not degrade event processing throughput
- Resource exhaustion (memory, I/O bandwidth) under snapshot storms
- Optimistic snapshot retry rates remain acceptable (<10%)

### Monitoring and Observability

**Critical Metrics**

- **Snapshot age distribution**: Time since last snapshot per aggregate (detect under-snapshotting)
- **Reconstruction latency**: P50/P95/P99 for aggregate reconstruction (detect performance degradation)
- **Snapshot creation rate**: Snapshots/second (detect over-snapshotting, capacity issues)
- **Snapshot size distribution**: Identify anomalous growth patterns
- **Replay event count**: Average events replayed per reconstruction (validates snapshot effectiveness)
- **Snapshot failures**: Creation failures, deserialization errors (detect data corruption, bugs)

**Alerting Thresholds**

- Reconstruction P95 latency exceeds SLA (e.g., >500ms)
- Snapshot creation failure rate >1%
- Snapshot age exceeds configured threshold (stale snapshots)
- Storage capacity approaching limits
- Deserialization error rate >0.1% (schema evolution issues)

**Distributed Tracing** Instrument snapshot lifecycle:

1. Trigger event (threshold reached, scheduled)
2. State serialization span
3. Storage write span
4. Verification/checksum calculation
5. Cache update

Correlate snapshot traces with reconstruction traces to identify bottlenecks.

### Integration with Event Sourcing Patterns

**Snapshots + CQRS** Read models (queries) benefit most from snapshots. Write models (commands) reconstruct aggregate, apply command, append event. Snapshot after command processing reduces next read latency.

Query handlers specify minimum version for consistency:

```python
def handle_query(aggregate_id: str, min_version: int):
    aggregate = reconstruct_aggregate(aggregate_id, target_version=min_version)
    return project_to_view(aggregate)
```

**Snapshots + Event Upcasting** When event schema evolves, upcasters transform old events to new format during replay. Snapshots created post-upcasting embed transformed state. Older snapshots may require event replay with upcasting, negating snapshot benefit.

Strategy: Invalidate snapshots older than upcaster deployment. Force re-snapshot with new schema.

**Snapshots + Projections** Projections (materialized views) are specialized snapshots for specific queries. Maintain separate snapshot streams for different projections. Each projection tracks its own version and snapshot policy.

### Comparison with Alternatives

**Event Folding/Compaction** Instead of snapshots, replace event sequences with compacted events representing net effect. Example: 100 increment events → single `SetValue(final_count)` event. Loses audit trail granularity. Snapshots preserve full event history while optimizing reconstruction.

**State-Based Replication** Replicate current state directly instead of events. No reconstruction needed but loses temporal queries, event replay for new projections, and audit capabilities. Snapshots provide performance benefits of state replication while maintaining event sourcing advantages.

**Caching Without Snapshots** Cache reconstructed aggregates in memory. Effective for hot data but cold aggregates still require full replay. Snapshots provide persistent optimization benefiting all accesses, not just cached items.

### Related Topics

Event sourcing architecture, CQRS pattern, event store design, materialized views, stream processing checkpoints, write-ahead logging, database checkpoint mechanisms, temporal query optimization, schema evolution strategies, eventual consistency patterns

---

## CQRS Implementation (Event-Driven)

Command Query Responsibility Segregation (CQRS) separates write operations (commands) from read operations (queries) using distinct models optimized for their respective responsibilities. Event-driven implementations leverage event sourcing and asynchronous propagation to decouple command and query sides, enabling independent scaling, polyglot persistence, and temporal query capabilities.

### Architectural Components

**Command Side**: Processes write operations through command handlers that validate business rules, execute domain logic, and emit domain events. Maintains write-optimized storage (normalized relational schema, document store) focusing on transactional integrity and consistency.

**Event Store**: Immutable append-only log storing domain events representing state transitions. Acts as authoritative system of record from which all state derives. Provides temporal queries, audit trails, and replay capabilities unavailable in traditional CRUD architectures.

**Event Bus**: Message infrastructure propagating events from command side to query side projections. Implements publish-subscribe pattern with delivery guarantees (at-least-once or exactly-once) and ordering semantics (per-aggregate, per-partition, global).

**Query Side**: Denormalized read models (projections) built from event stream. Optimized for specific query patterns through materialized views, caching layers, and specialized data stores (search indexes, graph databases, time-series databases).

**Projection Engine**: Consumes events and updates read models. Handles event replay for projection rebuilds, manages projection versioning, and ensures eventual consistency between command and query sides.

### Event Sourcing Integration

**Event as Source of Truth**: Current state reconstructed by replaying events from empty initial state. Aggregate root loads event history, applies each event to internal state until reaching current version.

**Event Schema Design**: Each event represents single state transition with immutable attributes: event_id (UUID), aggregate_id, aggregate_type, event_type, event_version, timestamp, causation_id (triggering command), correlation_id (business transaction), and payload (state changes).

**Aggregate Versioning**: Attach version number to each aggregate. Commands include expected version for optimistic concurrency control. Append event only if current version matches expected, otherwise reject with concurrency exception.

**Snapshotting**: Periodically persist aggregate snapshots to avoid replaying thousands of events. Load most recent snapshot, replay subsequent events. Snapshot every N events (100-1000) balancing reconstruction time against snapshot storage.

**Event Upcasting**: Transform old event versions to current schema during replay. Implement version-specific handlers or transformation chains. Enables schema evolution without rewriting historical events—critical for long-lived systems.

**Temporal Queries**: Reconstruct aggregate state at any historical point by replaying events until timestamp. Enables regulatory compliance, debugging, and business intelligence unavailable in state-based systems.

### Command Processing Pipeline

**Command Validation**: Validate command structure, required fields, and basic constraints before routing. Reject malformed commands immediately without domain logic execution. Separate syntactic validation (required fields) from semantic validation (business rules).

**Command Handler**: Single handler per command type implementing business logic. Load aggregate from event store, execute domain operation, collect emitted domain events, append events atomically.

**Idempotency**: Commands assigned unique command_id by client or gateway. Store processed command IDs with TTL (hours to days). Deduplicate retries by checking processed set before execution. Return original result for duplicate commands.

**Transaction Boundaries**: Each command processing forms single transaction. Either all events from command appended or none. Distributed transactions across aggregates avoided—use sagas or process managers for cross-aggregate coordination.

**Event Publishing**: Events published to bus only after successful persistence to event store. Transactional outbox pattern stores events in relational database transaction, separate process polls outbox and publishes to bus. Prevents lost events from commit-then-publish failures.

**Command Result**: Return acknowledgment with command_id and result status (accepted, rejected, validation_failed). Avoid returning full aggregate state—query side handles reads. Optionally return generated IDs for created entities.

### Event Bus Patterns

**Topic-Based Routing**: Publish events to topics named by aggregate type or event type. Projections subscribe to relevant topics. Enables fine-grained subscription control and projection isolation.

**Partitioning**: Partition events by aggregate_id ensuring ordered delivery per aggregate. Different aggregates processed concurrently. Kafka, Pulsar, and EventStoreDB provide partitioning primitives. Partition count balances parallelism with coordination overhead.

**Delivery Guarantees**: At-least-once delivery requires idempotent projection handlers. Exactly-once achieved through distributed transactions (expensive) or idempotency keys. At-most-once unsuitable—lost events cause permanent inconsistency.

**Message Ordering**: Strong ordering (global order across all events) limits scalability. Per-partition ordering sufficient for most CQRS systems. Out-of-order delivery handled through version checking or reordering buffers.

**Dead Letter Queues**: Poison messages failing projection handlers repeatedly moved to DLQ after retry threshold (3-10 attempts with exponential backoff). Monitoring alerts on DLQ depth. Manual intervention investigates schema mismatches or projection bugs.

**Backpressure Handling**: Slow projections must not block event production. Implement bounded queues with overflow strategies: drop oldest (lossy), block publisher (backpressure), or spill to disk. Monitor queue depth and consumer lag.

### Projection Strategies

**Dedicated Projection per Use Case**: Create specialized read models for each query pattern. User profile projection for authentication, search projection for full-text queries, analytics projection for reporting. Optimizes each projection's data structure and storage technology.

**Materialized Views**: Store precomputed query results rather than computing on-the-fly. Shopping cart projection maintains item count, total price updated on ItemAdded/ItemRemoved events. Trades storage for query performance.

**Polyglot Persistence**: Different projections use different databases. Elasticsearch for search, Redis for session data, PostgreSQL for relational queries, Cassandra for time-series. Technology choice driven by query characteristics, not organizational standardization.

**Projection Versioning**: Tag projections with schema version. Breaking changes require new projection version. Run old and new versions concurrently during migration. Switch query traffic after new projection catches up to event stream head.

**Catch-Up Subscriptions**: New projections start from event stream beginning, processing historical events. Monitor catch-up progress (events processed, current timestamp lag). Switch to real-time mode after processing all historical events. Initial catch-up may take hours to days for large event stores.

**Projection Rebuilds**: Recreate projections from scratch by replaying event stream. Required after projection bugs corrupting state or major schema changes. Delete projection data, reset checkpoint to stream start, replay events. Zero-downtime rebuilds require running old projection while building new.

**Checkpointing**: Projections persist last processed event position (sequence number, timestamp). Resume from checkpoint after restart. Checkpoint frequency trades crash recovery time (seconds to minutes) against checkpoint overhead. Transactional checkpointing ensures exactly-once semantics.

### Consistency Patterns

**Eventual Consistency Window**: Time between command completion and query side visibility. Influenced by event bus latency, projection processing speed, and network delays. Production systems target 10-500ms depending on throughput requirements.

**Read-Your-Writes**: Client observes own writes immediately. Implementation: synchronous projection updates within command transaction (breaks CQRS benefits), client-provided version tokens in queries, or command returning projection wait token.

**Monotonic Reads**: Client never observes state regression. Route client requests to same query instance or include client-observed version in requests with server-side version filtering.

**Stale Read Tolerance**: Design UI acknowledging eventual consistency. Display "processing" states, optimistic UI updates, or explicit staleness indicators. Avoid immediate read-after-write patterns expecting strong consistency.

**Compensating Queries**: If projection inconsistent with command side, issue compensating command. Example: inventory projection shows item available, purchase command fails due to actual depletion—issue refund command. Requires business process compensation, not technical fix.

### Critical Anti-Patterns

**Synchronous Projections**: Updating query models within command transaction couples command and query sides, negating CQRS scalability benefits. Emergency fallback only—acceptable for single critical projection but not general pattern.

**Querying Event Store**: Event store optimized for append and sequential read, not random access queries. Building ad-hoc queries against event store creates performance bottleneck and couples query logic to event schema.

**Shared Database**: Command and query sides accessing same database tables violates CQRS separation. Creates implicit coupling, contention, and schema evolution constraints.

**Over-Normalization of Projections**: Normalizing projections like traditional databases requires joins degrading query performance. Denormalize aggressively—duplicate data across projections optimizing for read patterns.

**Missing Idempotency**: Non-idempotent projection handlers cause incorrect state on replay or redelivery. Every projection operation must be idempotent through natural idempotency (set operations), deduplication (processed event IDs), or deterministic conflict resolution.

**Event Schema Coupling**: Multiple bounded contexts depending on same event schema creates tight coupling. Events represent facts in publishing context—consuming contexts transform to local models. Use anti-corruption layer pattern.

**Unbounded Event Replay**: Replaying million-event streams without snapshotting causes unacceptable latency. Snapshots or incremental projections essential for performance. Snapshot frequency balances storage cost against replay time.

**Ignoring Event Versioning**: Changing event structure breaks old projections and replay. Implement versioned events with upcasters, or use additive-only changes maintaining backward compatibility. Never delete or rename event fields.

### Advanced Patterns

**Process Manager (Saga)**: Coordinates multi-aggregate workflows through event-driven state machine. Listens for events, maintains workflow state, issues commands to aggregates. Handles long-running processes (order fulfillment, payment processing) requiring coordination.

**Policy/Reactor Pattern**: Stateless event handlers issuing commands in response to events. Unlike process managers, policies don't maintain state. Example: OrderPlaced event triggers SendConfirmationEmail command, InventoryReserved event triggers ShipOrder command.

**Event-Carried State Transfer**: Include relevant state in events beyond minimal state changes. Reduces projection dependencies on external services. Balance message size against decoupling benefits. Example: OrderPlaced includes customer_name, shipping_address rather than just customer_id.

**CQRS with Separate Databases**: Command side uses PostgreSQL for transactional integrity, query side uses Elasticsearch for full-text search plus Redis for caching. Event bus (Kafka) propagates events between systems. Each system optimized for its access patterns.

**Inline Projections**: Critical projections updated synchronously within command transaction for immediate consistency. Used sparingly for use cases requiring strong consistency (authorization decisions, inventory allocation). Remainder use eventual consistency.

**Event Enrichment**: Append contextual information to events during propagation. Original event remains immutable; enriched version flows to consumers. Decouples producers from consumer information needs. Example: enrich UserId with full user profile for analytics consumers.

**Competing Consumers**: Multiple projection instances consume from same partition for parallel processing. Requires idempotent handlers and coordination (leader election, partition assignment). Increases throughput but adds operational complexity.

### Failure Handling

**Projection Failures**: Projection handler throwing exception triggers retry with exponential backoff. Transient failures (network timeouts) resolve through retry. Permanent failures (schema mismatch) require DLQ and manual intervention.

**Partial Failure Recovery**: Single projection failure shouldn't block others. Isolate projections through separate subscriptions and error handling. Failed projection falls behind event stream; recovery catches up independently.

**Event Store Unavailability**: Command processing blocks if event store unreachable. Implement timeouts (1-5 seconds) and circuit breakers. Return 503 Service Unavailable to clients. Queue commands only if idempotency guaranteed.

**Event Bus Outage**: Commands succeed writing to event store but events not propagated. Projections stale but command side consistent. After recovery, projections catch up processing buffered events. Monitor consumer lag.

**Projection Corruption**: Bugs causing incorrect projection state require rebuild. Detect through reconciliation jobs comparing projection to event store state. Automated rebuilds for development, manual approval for production due to resource intensity.

**Split-Brain Scenarios**: Multiple active command processors accepting writes to same aggregate causes divergent event streams. Use distributed locks, leader election, or consensus protocols preventing concurrent command processing.

### Performance Optimization

**Event Batching**: Append multiple events atomically and publish as batch. Reduces transaction overhead and network round trips. Typical batch size 10-100 events depending on event size and latency requirements.

**Projection Sharding**: Distribute projection instances across aggregate partitions. Each instance processes subset of event stream. Scales linearly with partitions. Requires repartitioning strategy for cluster changes.

**Caching Layers**: Cache hot projection queries in Redis or application memory. Invalidate on relevant events. Reduces database load but adds cache consistency complexity. Monitor cache hit rate (target >90%).

**Event Compression**: Compress event payloads (gzip, snappy, LZ4) in event store and bus. Reduces storage and network costs. Balance CPU overhead against I/O savings. Typically 50-80% size reduction for JSON events.

**Parallel Projection Processing**: Process independent projections concurrently. Different aggregate types processed in parallel. Single aggregate events processed sequentially maintaining causality. Thread pool size balances throughput against resource consumption.

**Connection Pooling**: Event store and query database connections pooled and reused. Configure pool size (10-50 connections) based on workload. Monitor connection exhaustion and query queueing.

**Read Replicas**: Scale query side by adding read replicas of projection databases. Route queries to replicas, writes to primary. Eventual consistency between primary and replicas acceptable given CQRS's eventual consistency model.

### Observability and Monitoring

**Command Metrics**: Track command processing latency (p50, p95, p99), success rate, rejection rate per command type. Alerts on elevated latency (>100ms) or error rate (>1%).

**Event Lag**: Measure time between event creation and projection processing. Per-projection lag monitoring identifies slow projections. Alert when lag exceeds threshold (1-10 seconds depending on SLA).

**Projection Throughput**: Events processed per second per projection. Declining throughput indicates performance degradation or increased event volume requiring scaling.

**Consumer Offset Lag**: For Kafka-based systems, monitor consumer group offset lag (events behind head). Growing lag indicates projection can't keep pace with event production rate.

**Event Store Growth**: Track event store size and append rate. Plan storage capacity and implement archival strategies (cold storage for old events) preventing disk exhaustion.

**Dead Letter Queue Depth**: Non-zero DLQ depth indicates projection failures requiring investigation. Alert immediately as DLQ growth signifies lost projection updates.

**Idempotency Cache Hit Rate**: High cache hit rate (>5%) indicates excessive retries or duplicate commands. Investigate client retry logic or network issues causing duplicates.

**Snapshotting Metrics**: Snapshot creation time, size, and frequency. Long snapshot creation times (>1 second) indicate excessive aggregate size requiring refactoring.

### Edge Cases

**Event Ordering Violations**: Network partitions or clock skew causing events arriving out of causal order. Detect through version gaps, buffer events, reorder before projection application. Alternatively use logical clocks (vector clocks) enabling correct ordering.

**Projection Timestamp Paradox**: Projections querying other projections may observe inconsistent temporal state if processing speeds differ. Avoid cross-projection dependencies or use version tokens ensuring causal consistency.

**Aggregate Deletion**: Soft delete by marking aggregate deleted in event. Maintain tombstone preventing resurrection. Projections filter deleted aggregates. Hard delete complicates replay—deleted events remain in stream but aggregate state inaccessible.

**Schema Evolution Conflicts**: Multiple teams independently evolving event schema create conflicts. Centralized schema registry (Confluent Schema Registry, AWS Glue) enforces compatibility rules (backward, forward, full). Block incompatible changes at publish time.

**Large Aggregates**: Aggregates with thousands of events cause slow load times. Refactor into smaller aggregates or implement snapshotting. Alternative: archive old events to cold storage, load only recent events plus snapshot.

**Cross-Aggregate Transactions**: Business operations spanning multiple aggregates (bank transfer debiting one account, crediting another) require saga patterns. Immediate consistency impossible in CQRS—design UX accommodating eventual consistency or use synchronous projection for critical invariants.

**Replay Performance**: Full event store replay taking hours blocks projection deployment. Incremental rebuilds process only changed aggregates. Parallel replay across partitions. Pre-warm new projections in shadow mode before cutover.

**Duplicate Event Detection**: Despite idempotency keys, duplicate events may enter stream through bugs or operational errors. Projections must handle naturally (set operations) or deduplicate explicitly (bloom filters, processed event IDs with TTL).

### Testing Strategies

**Event Sourcing Tests**: Given sequence of historical events, verify aggregate state correct. Load events, reconstruct aggregate, assert invariants hold. Tests business logic without infrastructure dependencies.

**Command Handler Tests**: Issue command to aggregate with known state, verify correct events emitted. Verify business rule enforcement through invalid commands rejected with expected errors.

**Projection Tests**: Feed events to projection handler, verify query model state. Test idempotency by applying same events twice, asserting identical final state. Test event ordering with permuted sequences.

**End-to-End Tests**: Issue command through API, poll query endpoint until expected state visible. Measures real eventual consistency window. Flaky due to timing—use generous timeouts or eventually-consistent assertion libraries.

**Chaos Engineering**: Inject projection failures, event bus delays, partial event loss. Verify system degrades gracefully and recovers automatically. Test projection rebuild under load.

**Performance Tests**: Load test command throughput, measure event lag growth under sustained load. Identify bottlenecks (event store, projection processing, bus capacity). Verify linear scalability by adding partitions.

**Replay Tests**: Replay production event stream against development projections. Verifies schema compatibility and catches upcasting bugs. Measures replay performance for capacity planning.

Related topics: Event Sourcing Patterns, Domain-Driven Design Aggregates, Saga Pattern for Distributed Transactions, Transactional Outbox Pattern, Event Schema Evolution, Idempotency Patterns, Polyglot Persistence Strategies, Process Manager Pattern

---

## Event Bus (Event-Driven)

### Architecture Pattern

Event buses implement publish-subscribe messaging patterns where components communicate through asynchronous event propagation rather than direct coupling. Publishers emit events without knowledge of subscribers; subscribers register interest in event types without knowledge of publishers. The bus acts as a central mediator managing subscriptions, event routing, and delivery guarantees.

### Core Implementation Patterns

**In-Process Event Bus**

Thread-safe implementation requires careful synchronization of subscriber collections. Use `ConcurrentHashMap<Class<?>, CopyOnWriteArraySet<Subscriber>>` for registration management to avoid `ConcurrentModificationException` during iteration. Handler invocation must account for subscriber addition/removal during event processing.

```java
public class EventBus {
    private final ConcurrentMap<Class<?>, Set<Consumer<?>>> subscribers = new ConcurrentHashMap<>();
    private final Executor executor;
    
    public <T> void subscribe(Class<T> eventType, Consumer<T> handler) {
        subscribers.computeIfAbsent(eventType, k -> ConcurrentHashMap.newKeySet()).add(handler);
    }
    
    public <T> void publish(T event) {
        Class<?> eventClass = event.getClass();
        Set<Consumer<?>> handlers = subscribers.get(eventClass);
        if (handlers != null) {
            handlers.forEach(h -> executor.execute(() -> ((Consumer<T>) h).accept(event)));
        }
    }
}
```

**Distributed Event Bus**

Distributed implementations leverage message brokers (Kafka, RabbitMQ, Redis Streams) for cross-process communication. Partition key selection critically impacts ordering guarantees and load distribution. Use entity IDs as partition keys when per-entity ordering matters; use random keys for maximum parallelism when order is irrelevant.

### Event Ordering and Delivery Guarantees

**Ordering Constraints**

Total ordering across all events introduces scalability bottlenecks. Partition-level ordering provides acceptable guarantees for most use cases—events for the same partition key arrive in published order. Implement causality tracking with vector clocks or happened-before relationships when cross-partition ordering matters.

**Delivery Semantics**

- **At-most-once:** Fire-and-forget with no acknowledgment. Acceptable for metrics, logging, non-critical notifications
- **At-least-once:** Retry until acknowledged. Requires idempotent handlers—use deduplication via event IDs stored in persistent cache (Redis, database) with TTL matching maximum retry window
- **Exactly-once:** Requires distributed transaction support or idempotent operations combined with at-least-once delivery. Kafka transactions provide exactly-once semantics within single-cluster boundaries

### Anti-Patterns

**Event Chain Explosion**

Handler triggering events that trigger more handlers creates cascade complexity and debugging nightmares. Limit chain depth to 2-3 levels maximum. Use saga patterns or workflow orchestration for complex multi-step processes requiring more than three event hops.

**God Events**

Events carrying entire aggregate state rather than deltas create tight coupling and payload bloat. Events should communicate state transitions, not entire object graphs. Include only changed fields plus minimal context (entity ID, version, timestamp).

**Synchronous Error Propagation**

Throwing exceptions from handlers to publishers breaks async boundaries and creates unpredictable failure modes. Handlers must catch all exceptions internally, log failures, and optionally publish error events. Publishers should never block on handler execution outcomes.

**Event Replay Without Idempotency**

Replaying event streams for recovery or new projections without idempotent handlers causes data corruption. Design handlers to produce identical outcomes regardless of execution count—use upsert operations, conditional updates with version checks, or deduplicate by event ID.

### Error Handling Strategies

**Dead Letter Queues**

Route repeatedly failing events to DLQ after exhausting retries (typical threshold: 3-5 attempts with exponential backoff). Monitor DLQ depth—accumulation indicates systematic handler bugs or downstream service degradation. Implement DLQ replay tooling for manual intervention after fixes.

**Circuit Breaking**

Wrap external service calls within handlers using circuit breakers (Hystrix, Resilience4j). Prevent cascading failures when downstream dependencies fail. Configure appropriate failure thresholds (50% error rate over 10-second window typical) and recovery timeouts (30-60 seconds).

**Poison Message Handling**

Malformed events causing deserialization failures require separate handling from business logic failures. Validate event schema before handler invocation. Route schema violations to separate error queue with raw message content preserved for forensic analysis.

### Event Schema Evolution

**Versioning Strategies**

- **Schema versioning:** Include version field in event payload. Route different versions to appropriate handler implementations. Maintain multiple handler versions during transition periods
- **Backward compatibility:** New fields must be optional. Removing fields requires coordinated deployment—deprecate first, remove after all consumers upgraded
- **Schema registry:** Centralize schema definitions (Avro, Protobuf) with compatibility checking. Enforce backward/forward compatibility rules at publication time

### Performance Considerations

**Batching**

Aggregate multiple events into single batch for improved throughput. Balance batch size against latency requirements—100ms windows with 100-event max typical. Use time-based and size-based triggers (whichever occurs first).

**Backpressure Management**

Implement bounded queues between publisher and bus with overflow policies (drop oldest, drop newest, block publisher). Monitor queue depth metrics—sustained high utilization indicates consumer scaling needed. Apply reactive streams backpressure protocols (Reactive Streams, Project Reactor) for flow control.

**Event Filtering**

Push filtering to bus layer rather than broadcasting to all subscribers. Use content-based routing with predicates evaluated against event metadata. Reduces network overhead and subscriber processing load.

### Testing Strategies

**Test Doubles**

Use in-memory synchronous event bus for unit tests to eliminate timing dependencies. Capture published events in collection for assertion—verify event types, payload content, publication order.

**Async Testing**

Integration tests require handling asynchronous completion. Use countdown latches, `CompletableFuture`, or test framework async support (`@Timeout`, `eventually`). Account for event processing delays—typical timeout: 5-10 seconds.

**Chaos Testing**

Simulate broker failures, network partitions, handler crashes. Verify retry logic, DLQ routing, circuit breaker behavior. Use frameworks like Chaos Monkey, Toxiproxy for fault injection.

### Observability

**Distributed Tracing**

Propagate trace context (trace ID, span ID) through event headers. Create child spans for handler execution. Enables end-to-end request flow visualization across async boundaries.

**Metrics**

Track publication rate, handler execution duration (p50, p95, p99), error rates per event type, queue depth, consumer lag. Alert on consumer lag exceeding SLA thresholds or sustained error rate spikes.

**Event Auditing**

Persist event history for compliance, debugging, replay scenarios. Use append-only event log (Event Store, Kafka with infinite retention). Include causation ID linking events to originating commands.

### Related Topics

Event sourcing, CQRS, saga pattern, message brokers, eventual consistency, distributed transactions, change data capture

---

## Message Broker Patterns (Event-Driven)

### Architectural Foundation

Event-driven architectures using message brokers decouple producers from consumers through asynchronous message passing. The broker acts as an intermediary that receives, stores, and routes messages based on configured patterns. Critical design decisions include message ordering guarantees, delivery semantics (at-most-once, at-least-once, exactly-once), and partition strategies.

### Core Patterns

**Publish-Subscribe**

Producers publish messages to topics without knowledge of subscribers. The broker maintains subscription lists and delivers copies to all active subscribers. Implementation requires careful consideration of subscription filtering (topic-based, content-based, or type-based) and fan-out scalability. Anti-pattern: creating dedicated topics for each consumer rather than using subscription filters, leading to topic proliferation and operational overhead.

**Point-to-Point (Queue)**

Messages are consumed by exactly one consumer from a queue. The broker must handle message acknowledgment, redelivery on failure, and load distribution across competing consumers. [Inference] Implementing proper consumer group coordination prevents duplicate processing while maintaining throughput. Critical edge case: handling poison messages that repeatedly fail processing requires dead-letter queue configuration with retry limits and exponential backoff.

**Request-Reply**

Asynchronous RPC implemented through correlation identifiers and temporary reply queues. The requestor publishes a message with a unique correlation ID and reply-to address, then waits for the response. Anti-pattern: creating persistent reply queues per request instead of using temporary queues or correlation-based routing, causing resource leaks.

**Competing Consumers**

Multiple consumer instances process messages from a single queue to scale throughput. The broker must ensure mutual exclusion—only one consumer processes each message. Implementation complexity includes handling consumer failures mid-processing (visibility timeout), rebalancing load when consumers join/leave, and maintaining message ordering where required.

**Message Router**

The broker evaluates message content or metadata to route to appropriate queues/topics. Content-based routing inspects message payload, while header-based routing uses metadata. [Inference] Complex routing logic should be externalized to prevent broker performance degradation. Edge case: routing logic creating circular message flows requires cycle detection or TTL-based termination.

**Saga Pattern**

Coordinates distributed transactions through message choreography or orchestration. Choreography uses domain events where each service listens for events and publishes new ones. Orchestration centralizes control in a saga coordinator that sends commands and listens for responses. Anti-pattern: mixing choreography and orchestration within a single saga creates ambiguous ownership and difficult debugging.

### Delivery Semantics

**At-Most-Once**

Fire-and-forget delivery with no acknowledgment. Message loss possible but no duplicates. Suitable only for telemetry or metrics where occasional data loss is acceptable. Implementation: disable publisher confirmations and consumer acknowledgments.

**At-Least-Once**

Messages delivered one or more times through acknowledgment and retry mechanisms. Requires idempotent consumers to handle duplicates safely. [Inference] Implementing idempotency keys (message IDs stored in consumer's datastore) prevents duplicate side effects. Edge case: network partitions causing indefinite redelivery requires circuit breaker patterns.

**Exactly-Once**

[Unverified: True exactly-once semantics across distributed systems is theoretically impossible without coordination protocols] Practical implementations use transactional outbox pattern (atomic write to database and message table, separate process publishes) or two-phase commit (2PC) with performance trade-offs. Kafka's exactly-once semantics uses transactional producers and idempotent writes within a single cluster but doesn't extend across external systems.

### Ordering Guarantees

**Global Ordering**

Single partition/queue maintains total message order but limits throughput to single consumer. Anti-pattern: using global ordering when only per-entity ordering is required sacrifices scalability unnecessarily.

**Partition Ordering**

Messages routed by partition key maintain order within partitions. Critical implementation detail: consistent hashing of keys across partition count prevents reordering during rebalances. Edge case: partition count changes require message draining or accepting temporary reordering.

**Causal Ordering**

Messages maintain happened-before relationships through vector clocks or sequence numbers. [Inference] Implementation complexity increases significantly; only use when true causal dependencies exist, not for simple sequencing.

### Message Patterns

**Command Message**

Imperative directive to perform an action. Contains all necessary data for processing. Anti-pattern: using commands as event notifications blurs semantic boundaries and creates tight coupling.

**Event Message**

Notification that something occurred in the past tense. Immutable fact that cannot be retracted, only compensated. Should contain complete state to prevent consumers from querying the producer (event-carried state transfer).

**Document Message**

Transfers entire data structure between systems. [Inference] Large documents increase network overhead and broker storage; consider claim-check pattern (store document externally, pass reference).

**Request-Reply Message**

Pairs request and response with correlation identifier. Anti-pattern: using request-reply for long-running operations instead of asynchronous status polling creates resource exhaustion.

### Poison Message Handling

Messages that repeatedly fail processing must be isolated to prevent blocking the queue. Implementation strategies:

- Retry limits with exponential backoff before moving to dead-letter queue
- Separate error queues per failure type for categorized handling
- Automated alerts on dead-letter queue depth thresholds
- Manual intervention workflows for poison message analysis

[Inference] Insufficient error logging during failed processing makes root cause analysis impossible; structured logging with correlation IDs is essential.

### Idempotency Implementation

**Natural Idempotency**

Operations inherently safe to repeat (e.g., absolute value assignments, idempotent REST operations). Preferred approach when possible.

**Idempotency Keys**

Consumer tracks processed message IDs in durable storage. Implementation requires atomic check-and-process within a transaction. Edge case: distributed race conditions require database-level uniqueness constraints on idempotency keys.

**Version Vectors**

Conditional updates based on expected version numbers. Optimistic locking prevents processing stale messages. Anti-pattern: ignoring version conflicts silently instead of raising errors or triggering reconciliation.

### Message Expiration and TTL

Messages with time-bound validity use TTL (time-to-live) to prevent processing stale data. Broker implementations vary: some expire messages in-queue, others only at consumption. [Inference] Long TTLs combined with slow consumers can cause unbounded queue growth; monitoring queue age metrics is critical.

### Backpressure and Flow Control

**Consumer-Side Throttling**

Prefetch limits control message batch size delivered to consumers. Too low reduces throughput, too high risks memory exhaustion. [Inference] Optimal prefetch count correlates with message processing latency and memory per message.

**Producer Rate Limiting**

Circuit breakers pause publishing when broker or consumers are overwhelmed. Implementation requires feedback mechanisms (broker capacity metrics, consumer lag monitoring). Anti-pattern: naive retry loops without backoff amplify overload conditions.

**Priority Queues**

Separate queues for priority levels or weighted round-robin within single queue. [Inference] Priority inversion risks exist when high-priority messages depend on low-priority message processing; careful dependency analysis required.

### Schema Evolution

Message schemas evolve over time requiring compatibility strategies:

- **Forward Compatibility**: Old producers, new consumers
- **Backward Compatibility**: New producers, old consumers
- **Full Compatibility**: Both directions supported

Avro and Protocol Buffers provide schema registries with compatibility checking. Anti-pattern: deploying breaking schema changes without consumer upgrade coordination causes deserialization failures.

### Monitoring and Observability

Critical metrics:

- Message throughput (published/consumed per second)
- Consumer lag (messages pending consumption)
- Processing latency (end-to-end message delay)
- Error rates and dead-letter queue depth
- Partition/queue saturation

[Inference] Distributed tracing with correlation IDs propagated through message headers enables request flow visualization across service boundaries. Without tracing context, debugging multi-service failures becomes prohibitively difficult.

### Anti-Patterns

**Message as Database**

Using message broker for durable storage instead of persistent databases. Brokers optimize for throughput, not long-term retention or querying. Results in operational complexity and data loss risks.

**Chatty Messages**

Fine-grained messages causing excessive network overhead. Coarser-grained events reduce message volume. Edge case: balancing granularity with consumer coupling—overly coarse events force consumers to process irrelevant data.

**Synchronous Blocking**

Request-reply implemented with blocking waits defeats asynchronous benefits. Use callback handlers or reactive programming models instead.

**Missing Compensation Logic**

Distributed transactions without compensating actions for rollback. Saga pattern requires explicit compensation messages for each forward action.

**Unbounded Retries**

Infinite retry loops without circuit breakers exhaust resources and mask underlying failures. Always implement retry limits and exponential backoff.

### Related Topics

Event Sourcing, CQRS (Command Query Responsibility Segregation), Transactional Outbox Pattern, Change Data Capture (CDC), Stream Processing Architecture, Service Mesh Message Routing, Reactive Programming Patterns

---

## Publish-Subscribe Topology (Event-Driven)

### Architectural Characteristics

Publish-subscribe topology decouples message producers from consumers through an intermediary event broker or message bus. Publishers emit events without knowledge of subscribers; subscribers register interest in event types without knowledge of publishers. This indirection enables dynamic system topologies where components can be added, removed, or scaled independently without modifying existing code.

**Core Components:**

- **Event Broker/Message Bus:** Central infrastructure managing event routing, persistence, and delivery guarantees (e.g., Apache Kafka, RabbitMQ, AWS SNS/SQS, Azure Event Grid, Google Pub/Sub)
- **Publishers:** Services emitting domain events representing state changes or significant occurrences
- **Subscribers:** Services consuming events to trigger downstream processing, maintain projections, or coordinate workflows
- **Event Schema Registry:** Centralized versioning and validation of event contracts (e.g., Confluent Schema Registry, AWS Glue Schema Registry)

### Event Design Principles

**Event Granularity:**

Events must represent atomic business facts, not technical implementation details. Prefer `OrderPlaced`, `PaymentProcessed`, `InventoryReserved` over generic `OrderUpdated`. Fine-grained events enable precise subscription filtering and reduce unnecessary processing.

**Event Immutability:**

Published events are append-only facts about past occurrences. Never modify or delete events post-publication. State corrections require compensating events (e.g., `OrderCancelled` rather than deleting `OrderPlaced`). Immutability guarantees audit trails and enables event sourcing patterns.

**Event Enrichment Strategy:**

Balance between fat events (include all relevant data) and thin events (include only identifiers). Fat events reduce downstream API calls but increase payload size and coupling. Thin events require subsequent queries but maintain loose coupling. Consider hybrid approaches: include critical data inline, reference IDs for ancillary information.

**Event Versioning:**

Implement explicit schema versioning from inception. Use semantic versioning for event contracts. Support backward compatibility through optional fields, default values, and deprecated field markers. Deploy version-aware consumers capable of handling multiple schema versions simultaneously during migration windows.

### Delivery Guarantees

**At-Most-Once:**

Publisher sends without acknowledgment. Messages may be lost due to network failures or broker unavailability. Acceptable only for non-critical telemetry or metrics where occasional data loss is tolerable. Lowest latency and resource overhead.

**At-Least-Once:**

Publisher retries until receiving acknowledgment. Messages may be duplicated if acknowledgment is lost after successful delivery. Requires idempotent consumers using deduplication keys (message IDs, correlation IDs, or business keys) to prevent duplicate processing side effects. Standard for most production systems.

**Exactly-Once:**

Guarantees single processing per message through distributed transactions or idempotent delivery protocols. Achievable via two-phase commit, transactional outbox pattern, or broker-native exactly-once semantics (Kafka transactions). Significant performance and complexity overhead; reserve for financial transactions, inventory operations, or other critical state mutations.

### Ordering Guarantees

**Global Ordering:**

Single partition/queue guarantees total ordering but limits horizontal scaling. Creates bottleneck as all events serialize through single consumer. Use only when business logic requires strict global sequencing (e.g., bank account transaction ledger).

**Partition/Shard Key Ordering:**

Events with identical partition keys maintain ordering within that partition while enabling parallel processing across partitions. Choose partition keys matching business invariants (e.g., user ID, order ID, aggregate root ID). Prevents race conditions within related event sequences while maximizing throughput.

**Unordered Processing:**

No ordering guarantees; maximum parallelism and throughput. Consumers must implement convergent conflict resolution strategies (CRDTs, last-write-wins with vector clocks, operational transformation). Suitable for commutative operations or eventually consistent projections.

### Subscription Patterns

**Topic-Based Subscription:**

Consumers subscribe to named topics representing event categories. Publishers route events to specific topics. Simple routing logic but requires predetermined topic taxonomy. Changes to event categorization necessitate infrastructure updates.

**Content-Based Subscription:**

Consumers define filter predicates evaluated against event payloads. Broker routes events matching filter criteria. Enables precise subscription targeting but increases broker processing overhead. Supports dynamic subscription changes without publisher awareness.

**Wildcard/Pattern Subscription:**

Consumers subscribe using pattern matchers (e.g., `order.*`, `inventory.warehouse-*.reserved`). Combines topic hierarchy with flexible filtering. Useful for cross-cutting concerns (logging, monitoring, analytics).

### Anti-Patterns

**Event Chains as Distributed Transactions:**

Creating long chains of synchronous event-driven calls (A publishes → B consumes and publishes → C consumes and publishes) recreates distributed transaction coupling. Each hop introduces failure points and latency. Instead, use sagas with compensating events or centralized orchestration for multi-step workflows.

**Chatty Event Streams:**

Publishing fine-grained events for every field mutation creates excessive broker load and consumer processing overhead. Aggregate related changes into meaningful business events. Emit `ProductUpdated` containing all changed attributes rather than separate `ProductNameChanged`, `ProductPriceChanged`, `ProductDescriptionChanged`.

**Event Notification as State Transfer:**

Including complete entity state in every event couples consumers to publisher's data model. Changes to entity structure break all consumers. Use event-carried state transfer selectively; prefer event notifications with query endpoints for full state retrieval.

**Unbounded Event Retention:**

Retaining events indefinitely without compaction or archival strategies exhausts broker storage. Implement time-based or size-based retention policies. Use log compaction for maintaining latest entity states. Archive historical events to cold storage (S3, Glacier) for compliance or analytics.

**Missing Poison Pill Handling:**

Malformed events or unhandled exceptions cause infinite retry loops, blocking queue processing. Implement dead-letter queues (DLQs) with retry budgets (exponential backoff, max attempts). Monitor DLQs for recurring failures indicating schema incompatibility or consumer bugs.

**Synchronous Event Publishing in Critical Path:**

Blocking request threads on event publication introduces broker availability as single point of failure and adds latency to user-facing operations. Use asynchronous publishing with outbox pattern: persist events locally in database transaction, separate process polls and publishes to broker.

### Idempotency Implementation

Consumers must handle duplicate message delivery without side effects. Strategies:

**Natural Idempotency:**

Operations inherently idempotent (SET operations, upserts with deterministic values). Requires no additional logic.

**Deduplication Cache:**

Track processed message IDs in fast-access store (Redis, Memcached). Check cache before processing; discard if present. Requires cache expiration matching broker retention to prevent false negatives. Cache failures must fail-safe to processing rather than silently dropping events.

**Database Constraints:**

Unique constraints on business keys prevent duplicate records. Catch constraint violations and treat as successful idempotent replay. Relies on database-level consistency guarantees.

**Versioned State:**

Include version numbers or timestamps in events. Consumers reject events older than current state. Prevents out-of-order event processing from corrupting state. Requires strongly consistent version storage.

### Monitoring and Observability

**Event Lag:**

Track delta between last published event offset and last consumed offset per subscriber. Growing lag indicates consumer throughput insufficiency, processing errors, or infrastructure issues. Alert on sustained lag growth.

**Processing Duration:**

Measure end-to-end latency from event publication to processing completion. Percentile metrics (p50, p95, p99) identify long-tail latency issues. Correlate spikes with specific event types or payload sizes.

**Error Rates:**

Monitor processing failures, retries, and DLQ accumulation per subscriber and event type. Spike detection identifies schema incompatibilities, consumer bugs, or infrastructure degradation.

**Event Schema Violations:**

Track schema validation failures at publisher and consumer boundaries. Indicates contract drift or deployment coordination issues between services.

**Throughput Metrics:**

Events published/consumed per second per topic. Identify capacity planning needs and load patterns. Compare against broker quotas and rate limits.

### Scalability Considerations

**Broker Partitioning:**

Partition topics to enable parallel consumption. Partition count should exceed maximum expected consumer instances to prevent idle consumers. Over-partitioning increases coordination overhead and resource consumption.

**Consumer Group Coordination:**

Multiple consumer instances form consumer groups sharing partition assignment. Broker manages partition rebalancing when instances join/leave. Rebalancing pauses processing; optimize by minimizing deployment frequency and using incremental cooperative rebalancing protocols.

**Backpressure Management:**

Consumers must implement flow control to prevent overwhelm. Strategies include bounded queues with rejection policies, dynamic batch sizing based on processing latency, and circuit breakers halting consumption during downstream service degradation.

**Hot Partitions:**

Uneven partition key distribution creates load imbalance across partitions. Monitor partition-level metrics to detect hot partitions. Implement consistent hashing or compound partition keys to improve distribution.

### Security Considerations

**Event Content Encryption:**

Encrypt sensitive event payloads at application level before publishing. Broker-level encryption (TLS, encryption at rest) protects transport and storage but allows broker operators access to plaintext. Application-level encryption limits exposure to consumers with decryption keys.

**Subscriber Authorization:**

Enforce topic-level access controls preventing unauthorized subscription. Implement fine-grained permissions using OAuth2 scopes, JWT claims, or broker-native ACLs. Regularly audit subscriber access logs.

**Event Provenance:**

Include publisher identity, correlation IDs, and causation IDs in event metadata. Enables tracing event chains for security audits and debugging. Cryptographically sign events for non-repudiation requirements.

**Tenant Isolation:**

Multi-tenant systems require logical or physical topic isolation to prevent cross-tenant data leakage. Physical isolation (separate topics per tenant) simplifies security but increases operational overhead. Logical isolation (partition keys, filtering) reduces infrastructure costs but requires careful access control implementation.

### Related Topics

Event Sourcing, CQRS (Command Query Responsibility Segregation), Saga Pattern, Transactional Outbox Pattern, Change Data Capture, Stream Processing, Event-Driven Microservices, Reactive Systems

---

## Point-to-Point Topology

### Architecture Overview

Point-to-point topology in event-driven systems establishes direct, one-to-one communication channels between event producers and consumers. Each message is consumed by exactly one receiver, ensuring exclusive processing and eliminating race conditions inherent in competing consumer patterns. This topology guarantees message ordering within a single channel and provides deterministic routing paths.

### Implementation Characteristics

**Message Queue Semantics**

Messages persist in queues until acknowledged by consumers. The queue acts as a buffer, decoupling producer availability from consumer readiness. Dead-letter queues handle poison messages that exceed retry thresholds. Message expiration policies prevent queue bloat from abandoned messages.

**Delivery Guarantees**

At-most-once delivery sacrifices reliability for throughput—messages may be lost but never duplicated. At-least-once delivery ensures no message loss through acknowledgment protocols but permits duplicates during network partitions or consumer failures. Exactly-once delivery requires distributed transactions or idempotency tokens to prevent duplicate processing while guaranteeing delivery.

**Acknowledgment Patterns**

Auto-acknowledgment commits messages before processing, risking data loss on consumer crashes. Manual acknowledgment defers commitment until processing completes, ensuring durability at the cost of potential redelivery. Negative acknowledgment returns messages to the queue for reprocessing, often with backoff strategies to prevent tight retry loops.

### Anti-Patterns

**Tight Coupling Through Direct Dependencies**

Hardcoding queue names, connection strings, or message formats creates brittle integration points. Producer changes cascade through all consumers. Use service registries, configuration management, and schema registries to externalize dependencies.

**Synchronous Blocking on Async Operations**

Blocking threads while waiting for message acknowledgments or queue operations negates the scalability benefits of asynchronous messaging. Implement non-blocking I/O with reactive streams or async/await patterns to maximize thread pool efficiency.

**Missing Idempotency Guarantees**

Assuming exactly-once delivery without implementing idempotent consumers creates duplicate processing bugs. Natural idempotency (SET operations) or explicit deduplication (unique message IDs tracked in storage) must be enforced at the application layer.

**Queue Depth Explosion**

Unbounded queue growth from consumer saturation leads to memory exhaustion and increased message latency. Implement backpressure mechanisms, rate limiting on producers, and circuit breakers to prevent queue overload. Monitor queue depth metrics and configure alerts.

### Scalability Considerations

**Horizontal Consumer Scaling**

Point-to-point topology limits parallelism—only one consumer processes each queue. Partition messages across multiple queues using consistent hashing or range-based routing to enable horizontal scaling. Each partition maintains ordering guarantees while distributing load.

**Prefetch and Batching**

Configure consumer prefetch counts to balance throughput and memory usage. High prefetch reduces network round trips but increases memory pressure and redelivery costs on consumer failure. Batch message retrieval and acknowledgment to amortize protocol overhead across multiple messages.

**Connection Pooling**

Queue client connections are expensive resources. Pool connections across threads and reuse for multiple operations. Implement connection validation, automatic reconnection with exponential backoff, and graceful degradation when brokers are unavailable.

### Reliability Patterns

**Transactional Outbox**

Coordinate message publishing with database transactions by writing messages to an outbox table within the same transaction. Background workers poll the outbox and forward messages to the queue, ensuring atomic commit of business state and message publishing without distributed transactions.

**Saga Orchestration**

Implement long-running transactions across services using command messages for forward progress and compensating messages for rollback. The orchestrator tracks saga state and issues point-to-point commands to participant services, handling failures through compensation logic.

**Message Deduplication Windows**

Maintain a sliding window of recently processed message IDs in fast storage (cache or database). Check incoming messages against this window before processing. Configure window size based on maximum expected redelivery delay to balance memory usage and deduplication effectiveness.

### Monitoring and Observability

**Key Metrics**

Track message production rate, consumption rate, queue depth, processing latency (time from production to acknowledgment), and error rates. Sustained queue depth growth indicates consumer saturation. High error rates suggest message format mismatches or processing bugs.

**Distributed Tracing**

Propagate correlation IDs and trace contexts through message headers. Link producer spans to consumer spans for end-to-end request tracing across service boundaries. Instrument queue client libraries to capture enqueue and dequeue operations as trace events.

**Dead-Letter Queue Analysis**

Regularly inspect dead-letter queues for systematic failures. Classify failures by error type—transient failures (network timeouts) warrant retry, permanent failures (validation errors) require schema evolution or producer fixes. Implement alerting on dead-letter queue depth thresholds.

### Edge Cases

**Poison Message Handling**

Messages that consistently fail processing poison the queue, blocking subsequent messages. Implement retry limits with exponential backoff, then route to dead-letter queues. For critical queues, implement message filtering or routing to isolate poison messages without blocking the queue.

**Ordering Guarantees Under Failure**

Consumer crashes during message processing violate ordering if subsequent messages are processed first during redelivery. Use single-threaded consumers or sequential processing within partitions to maintain strict ordering. Accept eventual consistency for non-ordered scenarios.

**Clock Skew in TTL**

Message TTL enforcement varies across distributed brokers with unsynchronized clocks. Producers may timestamp messages that expire before reaching consumers due to clock drift. Use logical clocks or server-side TTL calculation to ensure consistent expiration behavior.

### Security Considerations

**Message Encryption**

Encrypt sensitive message payloads at rest and in transit. Use envelope encryption with data encryption keys per message and key encryption keys managed by external key management services. Implement key rotation policies and audit logging for key access.

**Access Control**

Enforce queue-level permissions restricting which services can produce or consume from specific queues. Implement mutual TLS for client authentication and authorization. Regularly audit queue permissions and revoke unused credentials.

**Message Validation**

Validate all consumed messages against schemas to prevent injection attacks or malformed data processing. Reject invalid messages to dead-letter queues rather than crashing consumers. Log validation failures for security monitoring.

**Related Topics:** Publish-subscribe topology, competing consumers pattern, message broker selection (RabbitMQ vs. Apache Kafka vs. AWS SQS), event sourcing, CQRS with messaging

---

## Request-Reply Pattern (Event-Driven)

### Architecture Overview

The request-reply pattern in event-driven systems decouples synchronous request-response semantics from direct coupling between components. A requestor publishes an event containing a request payload and correlation identifier to a message broker or event bus, then awaits a corresponding reply event. The responder consumes the request event, processes it, and publishes a reply event with the same correlation identifier to enable response routing.

This pattern differs from traditional RPC by introducing temporal decoupling, location transparency, and persistent message storage. The requestor and responder never communicate directly—all interaction occurs through the messaging infrastructure.

### Correlation Mechanism

**Correlation ID Strategy:** Every request must include a unique correlation identifier (typically UUID v4 or ULID) in message metadata. The responder echoes this identifier in the reply. The requestor maintains an in-memory correlation map (request ID → pending promise/future/callback) with configurable TTL to match replies to pending requests.

**Reply-To Address:** Request messages must specify a reply destination—either a temporary exclusive queue (JMS temporary queues, AMQP reply-to), a well-known queue with message selectors, or a topic with filtering. Temporary queues provide isolation but require connection persistence. Shared reply queues with correlation-based filtering enable connection pooling but require sophisticated client-side demultiplexing.

**Multi-Tenant Correlation:** In multi-tenant systems, correlation identifiers must incorporate tenant context to prevent cross-tenant reply leakage. Use compound keys: `{tenantId}:{correlationId}` or cryptographically sign correlation tokens.

### Timeout and Failure Handling

**Client-Side Timeouts:** Every pending request must have a deadline. Implement timeout using timer-based cleanup rather than blocking waits. When timeout expires, remove the correlation entry and propagate timeout error to caller. Never allow indefinite blocking.

**Responder Failure Detection:** If responder fails before publishing reply, requestor has no direct knowledge. Implement these layers:

- **Heartbeat mechanism:** Responders periodically publish liveness events
- **Dead letter queues:** Broker redirects unprocessable requests after retry exhaustion
- **Circuit breaker pattern:** Track failure rates per responder; halt requests when threshold exceeded

**Idempotency Requirements:** Network partitions and broker failures may cause duplicate request delivery. Responders must implement idempotent processing using:

- **Deduplication window:** Track processed request IDs in recent time window (e.g., last 5 minutes)
- **State-based idempotency:** Design operations as idempotent state transitions rather than delta updates
- **Idempotency keys:** Separate from correlation IDs; request-scoped unique identifiers preserved across retries

### Message Ordering and Causality

**Ordering Guarantees:** Event-driven request-reply inherently lacks ordering guarantees across multiple request-reply interactions. If operation B depends on completion of operation A, implement one of:

- **Saga pattern:** Chain requests using callback events; each reply triggers next request
- **Sequence numbers:** Include monotonic sequence in correlation metadata; responder validates sequence before processing
- **Partition keys:** Route causally-related requests to same partition/queue to leverage broker ordering guarantees

**Causal Dependencies:** When reply requires data from previous replies, avoid implicit dependencies. Explicitly include required context in request payload or implement distributed session state using correlation ID as session key.

### Scalability Considerations

**Reply Queue Scaling:** Shared reply queues become bottlenecks. Strategies:

- **Queue sharding:** Hash correlation ID to one of N reply queues
- **Per-instance reply queues:** Each requestor instance uses dedicated reply queue; responder extracts reply address from request metadata
- **Subscription filtering:** Use broker-side filtering (RabbitMQ topic routing, Kafka partition assignment) to distribute replies

**Connection Pooling:** Temporary queue strategy requires maintaining long-lived connections, conflicting with connection pooling. Resolve by:

- Using durable reply queues with selector-based filtering
- Implementing application-level connection affinity (sticky connections for duration of request-reply)
- Leveraging broker features like AMQP link detach/reattach

**Horizontal Scaling:** Multiple responder instances compete for requests. Ensure:

- **Competing consumers:** Configure queue/topic for load distribution across consumers
- **Stateless processing:** Responders must not rely on local state; externalize to cache or database
- **Work stealing:** If processing time varies significantly, use dynamic queue rebalancing or partition reassignment

### Anti-Patterns

**Synchronous Blocking:** Blocking thread while awaiting reply negates event-driven benefits. Always use async/await, futures, reactive streams, or callback patterns.

**Reply Message Bloat:** Including entire request payload in reply wastes bandwidth. Return only correlation ID and result data. Requestor should cache request context locally.

**Cascading Request-Reply:** Implementing complex workflows as nested request-reply sequences creates temporal coupling and timeout propagation issues. Use choreography (event chains) or orchestration (saga coordinator) instead.

**Missing Poison Message Handling:** Malformed requests that repeatedly fail processing can block queue consumers. Implement:

- Maximum retry count with exponential backoff
- Dead letter queue for manual inspection
- Automated alerting on DLQ depth thresholds

**Correlation Map Memory Leaks:** Failing to remove completed/timed-out correlation entries causes memory exhaustion. Implement sliding window cleanup with periodic garbage collection of expired entries.

### Security Implications

**Authorization Context Propagation:** Include authentication/authorization tokens in request metadata. Responders must validate on every request—never trust message source.

**Reply Spoofing:** Malicious actors can publish fake reply events with valid correlation IDs. Mitigate via:

- **Cryptographic signing:** Sign replies using responder private key; requestor validates using public key
- **Broker ACLs:** Restrict reply queue/topic publishing to authorized responder identities
- **Ephemeral credentials:** Include time-limited token in request; responder must include valid token in reply

**Information Disclosure:** Reply queues visible to multiple consumers can leak sensitive data. Use per-tenant reply topics with subscription filters or encrypt reply payloads.

### Observability

**Distributed Tracing:** Inject trace context (W3C Trace Context, OpenTelemetry) into request metadata. Responders propagate trace context to replies and downstream operations. Enables end-to-end latency analysis across event-driven boundaries.

**Metrics:** Track per-operation:

- Request-reply round-trip latency (p50, p95, p99)
- Timeout rate
- Correlation map size (memory pressure indicator)
- Reply queue depth
- Unmatched reply rate (correlation failures)

**Structured Logging:** Log correlation ID, request/reply timestamps, processing duration, error details. Enables reconstructing request-reply flows from logs.

### Related Topics

Saga Pattern, Event Sourcing, CQRS, Message Broker Selection, Eventual Consistency, Distributed Transactions, Choreography vs Orchestration

---

## Event Notification (Event-Driven)

### Architecture Pattern

Event notification represents a decoupled communication pattern where components broadcast state changes without knowledge of downstream consumers. The producer emits events asynchronously, and interested parties subscribe to event streams independently. This contrasts with request-response patterns where callers await synchronous acknowledgment.

### Implementation Principles

**Event Granularity**: Events must represent meaningful business state transitions, not technical implementation details. An `OrderPlaced` event captures domain semantics; `DatabaseRowInserted` does not. Over-granular events create excessive coupling and processing overhead. Under-granular events force consumers to poll for state changes, defeating the pattern's purpose.

**Event Immutability**: Events represent historical facts that cannot be altered. Once published, event payloads must remain immutable. Mutable events introduce race conditions where consumers process different versions of the same logical event, causing data inconsistency.

**Payload Design**: Include sufficient contextual data to enable autonomous consumer decision-making without requiring synchronous callbacks to the producer. Insufficient payload data forces consumers into request-response patterns, negating decoupling benefits. Conversely, excessive payload bloat increases network overhead and serialization costs.

**Idempotency Guarantees**: Consumers must handle duplicate event delivery without side effects. At-least-once delivery semantics in distributed systems guarantee eventual delivery but permit duplicates. Implement idempotency through unique event identifiers, consumer-side deduplication windows, or idempotent operation design.

### Anti-Patterns

**Event Chain Explosion**: Avoid cascading event chains where each consumer generates new events triggering additional consumers. This creates opaque execution flows impossible to debug or reason about. Limit chain depth and implement circuit breakers to prevent infinite loops.

**Synchronous Event Processing**: Blocking event handlers while awaiting I/O operations defeats the pattern's asynchronous nature. Event handlers must complete quickly, delegating long-running work to background processors or message queues.

**Event Sourcing Confusion**: Event notification differs from event sourcing. Event notification communicates state changes for decoupled integration. Event sourcing persists events as the primary data store and reconstructs state through event replay. Conflating these patterns leads to architectural inconsistency.

**Dual Writes**: Publishing events while updating local state in separate transactions creates consistency risks. If the database commit succeeds but event publication fails, consumers never receive notification. Use transactional outbox pattern, polling publisher, or change data capture to ensure atomicity.

### Delivery Guarantees

**At-Most-Once**: Events may be lost but never duplicated. Acceptable for non-critical notifications like cache invalidation. Unacceptable for financial transactions or audit trails.

**At-Least-Once**: Events guaranteed delivery but may duplicate. Requires idempotent consumers. Standard choice for business-critical events where data loss is unacceptable.

**Exactly-Once**: Events delivered once without duplication. Extremely difficult to achieve in distributed systems. Typically implemented through distributed transactions or sophisticated deduplication mechanisms with significant performance costs. [Inference] Most systems claiming exactly-once delivery actually provide effectively-once semantics through idempotent processing rather than true exactly-once guarantees.

### Event Schema Evolution

**Backward Compatibility**: New event versions must remain consumable by existing consumers. Add optional fields; never remove or rename existing fields. Use schema registries to enforce compatibility rules and prevent breaking changes.

**Versioning Strategies**: Embed version indicators in event payloads or topics. Maintain multiple event versions simultaneously during transition periods. Deprecate old versions only after confirming zero active consumers.

**Schema Registry Integration**: Centralized schema repositories (e.g., Confluent Schema Registry, AWS Glue Schema Registry) enforce schema validation at production time, preventing incompatible events from entering the system.

### Observability Requirements

**Correlation Identifiers**: Propagate trace identifiers across event chains to enable distributed tracing. Without correlation, debugging failures in multi-hop event flows becomes impossible.

**Event Replay Capability**: Retain published events for configurable retention periods enabling consumer recovery, debugging, and temporal analysis. Ephemeral events prevent post-mortem analysis of production incidents.

**Dead Letter Queues**: Route repeatedly failing events to quarantine queues for manual inspection rather than indefinite retry loops. Include failure metadata (retry count, exception traces, timestamps) to accelerate debugging.

**Monitoring Metrics**: Track event publication rates, consumer lag, processing latency, and error rates. Alert on anomalies indicating producer failures, consumer bottlenecks, or infrastructure degradation.

### Error Handling Strategies

**Poison Message Handling**: Events causing repeated consumer failures must be isolated to prevent blocking healthy message processing. Implement retry limits with exponential backoff before routing to dead letter queues.

**Partial Failure Recovery**: In fan-out scenarios where one consumer fails among many, failed messages must retry independently without reprocessing successful deliveries. Avoid global retry mechanisms that duplicate work.

**Compensating Actions**: For events triggering distributed workflows, design compensating events to reverse partially completed operations when downstream failures occur. Pure event notification provides no rollback mechanism; compensation is application responsibility.

### Performance Considerations

**Event Batching**: Aggregate multiple events into batches to reduce network round-trips and improve throughput. Balance batch size against latency requirements; larger batches increase throughput but delay individual event delivery.

**Partitioning Strategy**: Distribute events across partitions using consistent keys (e.g., customer ID, order ID) to ensure ordering within partitions while enabling parallel processing. Poor partitioning creates hot partitions causing consumer lag.

**Consumer Group Scaling**: Partition count constrains maximum consumer parallelism. A topic with 10 partitions supports at most 10 concurrent consumers per consumer group. Plan partition counts based on anticipated peak throughput requirements.

### Security Constraints

**Event Authorization**: Implement fine-grained access control determining which consumers may subscribe to specific event types. Overly permissive subscriptions expose sensitive business data to unauthorized services.

**Payload Encryption**: Encrypt sensitive event payloads end-to-end when traversing untrusted networks or multi-tenant infrastructure. Consider field-level encryption for granular protection.

**Audit Logging**: Maintain immutable audit trails of event publication and consumption for compliance and forensic analysis. Include publisher identity, timestamp, consumer identity, and processing status.

### Testing Strategies

**Contract Testing**: Validate that producers emit events matching consumer expectations without requiring full integration tests. Use tools like Pact or Spring Cloud Contract to define and verify event contracts.

**Chaos Testing**: Inject failures (message loss, duplication, reordering, consumer crashes) to validate system resilience under adverse conditions. Event-driven systems exhibit complex failure modes requiring deliberate chaos experimentation.

**Load Testing**: Simulate peak event volumes to identify throughput bottlenecks, consumer lag accumulation, and infrastructure scaling limits before production deployment.

**Related Topics**: Event Sourcing, Command Query Responsibility Segregation (CQRS), Saga Pattern, Transactional Outbox Pattern, Change Data Capture (CDC), Message Broker Selection, Event Stream Processing

---

## Event-Carried State Transfer

Event-carried state transfer is an event-driven architecture pattern where events contain complete state snapshots rather than just notification of state changes. Consuming services maintain local replicas of data from other services, eliminating synchronous query dependencies and achieving autonomous operation at the cost of eventual consistency and increased payload size.

### Core Mechanics

Events encapsulate full entity state or substantial state deltas. When `OrderService` publishes `OrderPlaced`, the event carries order line items, customer details, pricing, and fulfillment data—not merely an order ID. Consumers persist this state locally, avoiding real-time queries to `OrderService` for order information.

This contrasts with event notification patterns where events signal "something happened" with minimal data, forcing consumers to query the source system for details. Event-carried state transfer inverts this: consumers become readers of a replicated state cache, while the source system becomes the sole writer.

### Implementation Patterns

**Full State Events**

Each event contains the complete current state of an entity. `CustomerUpdated` includes all customer attributes regardless of what changed. Consumers replace their local copy entirely.

```java
// Anti-pattern: Minimal event
public class OrderPlaced {
    private UUID orderId;
    private Instant timestamp;
}

// Correct: State-carrying event
public class OrderPlaced {
    private UUID orderId;
    private UUID customerId;
    private String customerEmail;
    private String shippingAddress;
    private List<OrderLineItem> items;
    private Money totalAmount;
    private OrderStatus status;
    private Instant placedAt;
}
```

**Delta State Events**

Events carry only changed attributes plus immutable identifiers. Requires consumers to merge deltas with existing state. More network-efficient but increases consumer complexity and risks inconsistency if events arrive out-of-order.

```java
public class CustomerAddressChanged {
    private UUID customerId;
    private Address newAddress;
    private long version; // Optimistic locking
}
```

**Snapshot + Delta Hybrid**

Periodic full snapshots interspersed with delta events. Consumers can rebuild state from latest snapshot plus subsequent deltas, enabling late joiners to catch up without replaying entire event history.

### Autonomy and Decoupling

Primary benefit: consuming services operate independently of source system availability. `ShippingService` maintains local order data; if `OrderService` crashes, shipping proceeds uninterrupted. This eliminates cascading failures from synchronous service-to-service calls.

Temporal decoupling: producers and consumers need not be online simultaneously. Events persist in message broker; consumers process at their own pace.

Organizational decoupling: teams evolve services independently. `ShippingService` team doesn't coordinate deployments with `OrderService` team, provided event schema compatibility is maintained.

### Trade-offs and Challenges

**Eventual Consistency**

Consumers lag behind source system state by propagation delay (milliseconds to seconds). Applications must tolerate stale reads. If `OrderService` cancels an order, `ShippingService` may briefly process shipment for already-canceled order. Requires compensating transactions or idempotency patterns.

```java
// Handling out-of-order events
public void handle(OrderCancelled event) {
    Order localOrder = repository.findById(event.getOrderId());
    if (localOrder.getVersion() > event.getVersion()) {
        log.warn("Ignoring stale cancellation for order {}", event.getOrderId());
        return; // Newer state already applied
    }
    localOrder.cancel();
    repository.save(localOrder);
}
```

**Data Duplication and Storage Overhead**

Each consumer stores redundant copies of source data. An order entity exists in `OrderService`, `ShippingService`, `BillingService`, and `AnalyticsService`. Increases total storage requirements and complicates data governance (GDPR deletion requests must cascade to all consumers).

**Schema Evolution Complexity**

Event schema changes impact all consumers. Adding optional fields is safe; removing or renaming fields breaks compatibility. Requires versioning strategies:

- **Multiple event versions**: Publish `OrderPlacedV1` and `OrderPlacedV2` simultaneously during migration periods
- **Schema registry**: Use Avro/Protobuf with centralized schema management (Confluent Schema Registry)
- **Tolerant readers**: Consumers ignore unknown fields, provide defaults for missing fields

```java
// Tolerant reader pattern
@JsonIgnoreProperties(ignoreUnknown = true)
public class OrderPlaced {
    private UUID orderId;
    @JsonProperty(defaultValue = "STANDARD")
    private ShippingMethod shippingMethod; // New field with default
}
```

**Event Size and Network Overhead**

Carrying full state increases message size. A product catalog event might contain megabytes of image URLs, descriptions, and metadata. Mitigations:

- **Selective projection**: Include only fields consumers need
- **Compression**: Enable broker-level compression (Kafka supports gzip, snappy, lz4)
- **Reference data patterns**: Carry immutable entity IDs for large nested objects; consumers maintain separate lookup tables

**Consistency Boundaries**

Event-carried state transfer works within a single bounded context. Cross-aggregate consistency still requires distributed transaction patterns (Saga, eventual consistency). Events cannot carry state for entities outside their aggregate root's authority.

### Anti-Patterns

**Querying Source Systems Despite Having Local State**

Negates autonomy benefits. If consumer queries source system "just to be sure," you've built a caching layer with extra steps. Commit to trusting local state or abandon the pattern.

**Incomplete State in Events**

Publishing events with partial state forces consumers to query missing data, reintroducing synchronous coupling. Either include all necessary state or use event notification pattern explicitly.

**No Versioning Strategy**

Assuming event schemas never change causes production failures. From day one, include version field in events and implement backward/forward compatibility testing.

```java
public class OrderPlaced {
    private int schemaVersion = 2; // Explicit version
    // ... fields
}
```

**Ignoring Idempotency**

Message brokers guarantee at-least-once delivery. Consumers must handle duplicate events. Without idempotency keys, duplicate `OrderPlaced` events create phantom orders.

```java
@Transactional
public void handle(OrderPlaced event) {
    if (processedEvents.contains(event.getEventId())) {
        return; // Already processed
    }
    Order order = new Order(event);
    repository.save(order);
    processedEvents.add(event.getEventId());
}
```

### Testing Strategies

**Contract Testing**

Producers and consumers agree on event schema contracts. Use Pact or Spring Cloud Contract to verify producers emit events matching consumer expectations without integration tests against live services.

**Chaos Engineering**

Inject artificial delays in event processing. Verify consumers tolerate stale data. Simulate source system failures; ensure consumers continue operating with last-known state.

**Event Replay Testing**

Persist production events; replay against test environments to validate consumer logic handles real-world event sequences, including duplicates and out-of-order delivery.

### Operational Considerations

**Monitoring**

Track replication lag per consumer: time delta between event production timestamp and consumption timestamp. Alert when lag exceeds thresholds. Monitor event processing rates and dead letter queue depths.

**Data Retention Policies**

Configure broker retention based on longest acceptable consumer downtime. If consumers can be offline 7 days maximum, retain events for 7+ days. Compacted topics (Kafka) retain only latest state per key indefinitely.

**Consumer Recovery**

New consumer instances or consumers recovering from extended outages must rebuild state. Strategies:

- **Full event replay**: Process entire topic from beginning (slow for large histories)
- **Snapshot restoration**: Load latest snapshot, then process recent deltas
- **Bulk state transfer**: Query source system for initial state load, then switch to event processing

### Comparison with Alternative Patterns

**vs. Event Notification**: Event notification minimizes payload size and keeps source system as single source of truth, but introduces synchronous query dependencies. Use event notification when consumers need only triggering signals and can tolerate request-response latency.

**vs. CQRS with Projections**: Event-carried state transfer is essentially CQRS where events are the write model and consumer-local stores are read models. Difference is primarily semantic; CQRS emphasizes query optimization while event-carried state transfer emphasizes service autonomy.

**vs. Database Replication**: Database-level replication (CDC, logical replication) provides similar eventual consistency but couples services to database schemas. Event-carried state transfer offers bounded context isolation and schema independence.

**Related Topics**: Event Sourcing, Saga Pattern, Change Data Capture (CDC), Command Query Responsibility Segregation (CQRS), Bounded Context Design, Idempotency Patterns, Schema Evolution Strategies

---

## Domain Events (Event-Driven)

Domain events represent significant state changes or occurrences within a bounded context that domain experts care about. They capture business-meaningful facts that have already happened, named in past tense (e.g., `OrderPlaced`, `PaymentProcessed`, `InventoryReserved`). Unlike technical messaging patterns, domain events embody business semantics and serve as the primary mechanism for maintaining consistency across aggregates and bounded contexts while preserving transactional boundaries.

### Event Design Principles

**Immutability and Structure**

Domain events must be immutable value objects containing all information necessary to understand what happened without requiring external queries. Each event should include: event identifier (UUID), timestamp (ISO 8601 with timezone), aggregate identifier, aggregate version (for optimistic concurrency), event type discriminator, causation identifier (triggering command/event), correlation identifier (business transaction), and the payload representing the state change.

```typescript
interface DomainEvent {
  readonly eventId: string;
  readonly occurredAt: string;
  readonly aggregateId: string;
  readonly aggregateType: string;
  readonly aggregateVersion: number;
  readonly eventType: string;
  readonly causationId: string;
  readonly correlationId: string;
  readonly payload: Record<string, unknown>;
  readonly metadata?: Record<string, unknown>;
}
```

**Granularity and Boundary Decisions**

Event granularity directly impacts system evolution and performance. Fine-grained events (e.g., `OrderLineItemAdded`, `OrderLineItemQuantityChanged`) enable precise replay and projection rebuilding but increase message volume and complexity. Coarse-grained events (e.g., `OrderModified` with full state) simplify consumption but lose semantic richness and complicate partial updates. [Inference] The optimal approach typically involves business-aligned granularity where each event represents a single business decision or policy enforcement point.

Avoid technical events masquerading as domain events (e.g., `DatabaseRecordUpdated`, `CacheInvalidated`). These violate domain model purity and couple business logic to infrastructure concerns.

### Event Sourcing Implementation

**Aggregate Reconstruction and Snapshotting**

Event-sourced aggregates reconstruct current state by replaying all historical events. For long-lived aggregates with thousands of events, reconstruction becomes prohibitively expensive. Implement snapshotting at configurable intervals (e.g., every 50-100 events) where snapshots represent serialized aggregate state at specific versions.

```typescript
class EventSourcedAggregate {
  private version: number = 0;
  private uncommittedEvents: DomainEvent[] = [];
  
  static async load(id: string, eventStore: EventStore): Promise<this> {
    const snapshot = await eventStore.getLatestSnapshot(id);
    const aggregate = snapshot 
      ? this.fromSnapshot(snapshot)
      : new this(id);
    
    const events = await eventStore.getEvents(
      id, 
      snapshot?.version ?? 0
    );
    
    events.forEach(event => aggregate.applyEvent(event, false));
    return aggregate;
  }
  
  private applyEvent(event: DomainEvent, isNew: boolean): void {
    this.mutateState(event); // Pure state transition
    this.version = event.aggregateVersion;
    if (isNew) this.uncommittedEvents.push(event);
  }
}
```

**Versioning and Schema Evolution**

Event schemas evolve as business requirements change. Implement upcasting (transforming old event versions to current schema) at the read boundary, never mutating stored events. Maintain explicit event version numbers and upcast chains.

```typescript
interface EventUpcast {
  fromVersion: number;
  toVersion: number;
  upcast(oldEvent: DomainEvent): DomainEvent;
}

const orderPlacedUpcast: EventUpcast = {
  fromVersion: 1,
  toVersion: 2,
  upcast(event) {
    return {
      ...event,
      eventType: 'OrderPlacedV2',
      payload: {
        ...event.payload,
        // V2 adds customer tier for pricing
        customerTier: 'STANDARD' // Default for legacy events
      }
    };
  }
};
```

Handle breaking changes through event versioning strategies: weak schema (additive changes only), copy-and-transform (parallel event versions), or event migration (one-time rewrite of event store with version bump).

### Eventual Consistency Patterns

**Saga Orchestration vs Choreography**

Sagas coordinate multi-aggregate or cross-bounded-context transactions through compensating actions. Orchestration uses a central coordinator (saga manager) that explicitly commands participants and handles failures. Choreography relies on domain events where each service reacts independently.

Orchestration provides centralized visibility and explicit compensation logic but creates a single point of failure and coupling to the orchestrator. Choreography offers better decoupling and fault isolation but makes the overall business process implicit and harder to trace.

```typescript
// Orchestration example
class OrderFulfillmentSaga {
  async execute(command: FulfillOrder): Promise<void> {
    const compensations: (() => Promise<void>)[] = [];
    
    try {
      await this.reserveInventory(command.orderId);
      compensations.push(() => this.releaseInventory(command.orderId));
      
      await this.processPayment(command.paymentDetails);
      compensations.push(() => this.refundPayment(command.paymentDetails));
      
      await this.scheduleShipment(command.shippingAddress);
      
    } catch (error) {
      for (const compensate of compensations.reverse()) {
        await compensate().catch(err => 
          this.logCompensationFailure(err)
        );
      }
      throw error;
    }
  }
}
```

**Idempotency and Duplicate Detection**

Event handlers must be idempotent since at-least-once delivery guarantees result in duplicate event processing. Implement idempotency through event deduplication (storing processed event IDs with TTL), natural idempotency (operations that produce same result regardless of repetition), or idempotent receivers (checking current state before mutation).

```typescript
class IdempotentEventHandler {
  async handle(event: DomainEvent): Promise<void> {
    const processed = await this.cache.get(`event:${event.eventId}`);
    if (processed) return; // Already processed
    
    await this.processEvent(event);
    
    // Mark as processed with TTL exceeding max replay window
    await this.cache.set(
      `event:${event.eventId}`, 
      true, 
      { ttl: 86400 * 7 } // 7 days
    );
  }
}
```

### Projection Management

**Read Model Consistency**

Projections (read models) derive queryable state from event streams. Handle projection rebuilds without downtime through blue-green deployment: build new projection version in parallel, switch traffic atomically once caught up, deprecate old version. Track projection positions (last processed event offset) persistently to enable resumption after failures.

```typescript
interface ProjectionCheckpoint {
  projectionName: string;
  lastProcessedPosition: number;
  lastProcessedAt: Date;
  version: number;
}

class ProjectionEngine {
  async rebuild(projectionName: string): Promise<void> {
    const newVersion = await this.startNewProjectionVersion(projectionName);
    
    // Process all events from beginning
    await this.processEventsFrom(0, newVersion);
    
    // Atomic switchover when caught up
    await this.activateProjectionVersion(projectionName, newVersion);
    await this.deactivateOldVersions(projectionName, newVersion);
  }
}
```

**Projection Failure Handling**

Projection failures fall into two categories: transient (network timeouts, temporary unavailability) and poison messages (events that consistently fail processing). Implement exponential backoff for transient failures and dead-letter queues for poison messages requiring manual intervention.

### Event Store Implementation Concerns

**Concurrency Control**

Prevent lost updates through optimistic concurrency control: expect aggregate version when appending events, reject if version mismatch indicates concurrent modification. Use event store's atomic append operations (conditional writes in databases like PostgreSQL, DynamoDB, or EventStoreDB).

```sql
-- PostgreSQL optimistic locking
INSERT INTO events (
  aggregate_id, 
  aggregate_version, 
  event_type, 
  event_data
)
SELECT $1, $2, $3, $4
WHERE NOT EXISTS (
  SELECT 1 FROM events 
  WHERE aggregate_id = $1 
  AND aggregate_version >= $2
);
```

**Partitioning and Scaling**

Partition event streams by aggregate identifier for horizontal scalability. Within partitions, maintain strict ordering; across partitions, ordering is not guaranteed (nor required for different aggregates). Use consistent hashing for partition assignment and be prepared for partition rebalancing when scaling.

### Anti-Patterns

**Event Coupling**

Publishing events that expose internal aggregate structure (e.g., including full entity graphs, database IDs, or implementation details) creates tight coupling. Events should contain only business-relevant data consumers need to react appropriately.

**Command-Event Confusion**

Commands express intent and can be rejected; events state facts and cannot be rejected. Never name events as imperatives (e.g., `PlaceOrder` is a command, `OrderPlaced` is an event). Never conditionally process events based on current state validation—events represent immutable history.

**Synchronous Event Processing**

Processing events synchronously within the originating transaction defeats the purpose of eventual consistency and reintroduces distributed transaction problems. Events should be published after transaction commit and processed asynchronously.

**Event Store as Query Database**

Querying event stores for business reporting creates performance bottlenecks. Event stores optimize for append-only writes and sequential reads, not ad-hoc queries. Build dedicated projections for each query pattern.

**Missing Causation Tracking**

Failing to track causation (which command/event triggered this event) and correlation (which business transaction does this belong to) makes debugging distributed flows nearly impossible. Always propagate these identifiers through the entire event chain.

Related topics: CQRS (Command Query Responsibility Segregation), Aggregate Design, Message-Driven Architecture, Distributed Transactions, Event Streaming Platforms

---

## Integration Events (Event-Driven)

Integration events represent state changes or significant occurrences within a bounded context that other bounded contexts or external systems need to know about. Unlike domain events (which are internal to a bounded context), integration events cross boundaries and facilitate loose coupling in distributed architectures.

### Event Structure and Design

Integration events must be immutable, serializable, and contain sufficient context for consumers to process them without additional lookups. Essential attributes include:

- **Event ID**: Globally unique identifier (GUID/UUID) for idempotency and deduplication
- **Timestamp**: UTC timestamp of event occurrence (not publication time)
- **Event Type/Name**: Semantic identifier following consistent naming conventions
- **Aggregate ID**: Identifier of the entity that triggered the event
- **Correlation ID**: For tracing related events across service boundaries
- **Causation ID**: Links to the command or event that caused this event
- **Payload**: Minimal data required by consumers (avoid over-fetching)
- **Schema Version**: For schema evolution and backward compatibility

**Anti-pattern**: Including navigation properties, lazy-loaded entities, or domain objects directly in events. Events should carry DTOs with primitive types and value objects only.

### Event Naming Conventions

Use past-tense verbs indicating completed actions: `OrderPlaced`, `PaymentProcessed`, `InventoryReserved`. Avoid present tense (`OrderPlacing`) or vague names (`OrderEvent`, `OrderUpdated`).

Namespace events by bounded context: `Ordering.OrderPlaced`, `Billing.InvoiceGenerated`. This prevents naming conflicts and clarifies ownership.

### Publishing Patterns

**Transactional Outbox Pattern**: Store events in the same database transaction as the business operation. A separate process polls the outbox table and publishes events to the message broker. This guarantees at-least-once delivery without distributed transactions.

```sql
-- Outbox table structure
CREATE TABLE IntegrationEventLog (
    EventId UNIQUEIDENTIFIER PRIMARY KEY,
    EventType NVARCHAR(200) NOT NULL,
    Payload NVARCHAR(MAX) NOT NULL,
    State INT NOT NULL, -- NotPublished, InProgress, Published, Failed
    TimesSent INT DEFAULT 0,
    CreatedAt DATETIME2 NOT NULL,
    PublishedAt DATETIME2 NULL
);
```

**[Inference]** The outbox processor should implement exponential backoff for failed publications and mark events as poison messages after a threshold (e.g., 5 attempts).

**Change Data Capture (CDC)**: Leverage database transaction logs (e.g., Debezium, SQL Server CDC) to automatically publish events based on data changes. Suitable for scenarios where event schema directly mirrors database state.

**[Unverified]** CDC reduces application-level code but couples event schema to database structure, making schema evolution more challenging.

### Consumption Patterns

**Idempotent Consumers**: Consumers must handle duplicate events. Strategies include:

- Storing processed event IDs in a deduplication table
- Using event ID as idempotency key in downstream operations
- Designing operations to be naturally idempotent (e.g., setting state rather than incrementing)

**Ordering Guarantees**: Message brokers typically guarantee ordering within a partition/queue. Design aggregate IDs as partition keys to maintain event order for the same entity.

**[Inference]** Processing events out of order can lead to inconsistent state. For critical sequences, implement version-based conflict detection or event sequencing metadata.

**Competing Consumers**: Scale event processing horizontally by distributing partitions across consumer instances. Ensure each partition is consumed by exactly one instance at a time to prevent race conditions.

### Error Handling and Retry Strategies

**Transient Failures**: Network timeouts, temporary service unavailability. Apply exponential backoff with jitter. Maximum retry attempts should be configurable (typically 3-5).

**Poison Messages**: Events that consistently fail processing due to schema incompatibility, business rule violations, or bugs. Move to a dead-letter queue (DLQ) after retry exhaustion. Implement monitoring and alerting on DLQ depth.

**Compensating Actions**: For failures after partial processing, publish compensating events (e.g., `OrderCancelled` to reverse `OrderPlaced` effects). Avoid attempting rollbacks across distributed transactions.

### Schema Evolution

**Versioning Strategies**:

- **Weak Schema**: Add new optional fields, never remove or rename existing fields. Consumers ignore unknown fields.
- **Multiple Versions**: Publish events with version identifier. Maintain parallel producers/consumers during transition periods.
- **Schema Registry**: Centralized schema management (e.g., Confluent Schema Registry, AWS Glue) with compatibility rules enforced at publish/subscribe time.

**[Inference]** Breaking changes require coordinated deployment: deploy updated consumers first (backward compatible), then deploy new producers.

### Event Filtering and Routing

Consumers should subscribe only to relevant event types. Use message broker filtering capabilities (e.g., RabbitMQ routing keys, Kafka topic partitions, Azure Service Bus filters) rather than receiving all events and discarding irrelevant ones.

**Content-Based Routing**: Route events to different handlers based on payload attributes. Example: `OrderPlaced` events routed differently based on `OrderValue` thresholds.

### Monitoring and Observability

Critical metrics:

- **Event lag**: Time between event creation and processing completion
- **Processing rate**: Events processed per second per consumer
- **Failure rate**: Percentage of events moved to DLQ
- **Retry attempts**: Distribution of retry counts before success

Implement distributed tracing using correlation IDs to visualize event flow across services. Each event processing span should link to the producing span.

### Anti-Patterns to Avoid

**Event Chain Explosion**: Cascading events triggering additional events recursively. Define clear boundaries; use sagas or process managers for complex workflows instead of event chains.

**Event Sourcing Confusion**: Integration events are NOT the same as event-sourced domain events. Integration events communicate between services; event sourcing stores all state changes as events within a single service.

**Synchronous Event Publishing**: Blocking the business transaction while publishing events defeats loose coupling benefits. Always publish asynchronously (via outbox or background workers).

**Fat Events**: Including excessive data "just in case" consumers need it. This couples consumers to producer's data model. Consumers requiring additional data should query the producer's API or maintain their own read models.

**Database Sharing**: Multiple services subscribing to the same database table changes. This creates tight coupling and violates bounded context autonomy. Use explicit integration events instead.

### Technology Considerations

**Message Brokers**:

- **RabbitMQ**: Strong message routing, lower throughput, complex clustering
- **Apache Kafka**: High throughput, log-based storage, complex operational overhead
- **Azure Service Bus**: Managed service, enterprise integration patterns, vendor lock-in
- **Amazon SQS/SNS**: Managed, high availability, eventual consistency guarantees

**[Inference]** Kafka suits high-volume event streaming with replay requirements. RabbitMQ fits traditional messaging with complex routing. Managed services (Service Bus, SQS/SNS) reduce operational burden at higher cost.

### Testing Strategies

**Contract Testing**: Verify event schema compatibility between producers and consumers using tools like Pact or Spring Cloud Contract.

**Integration Testing**: Use in-memory or containerized message brokers (Testcontainers) to validate end-to-end event flow without mocking.

**Chaos Testing**: Simulate broker failures, network partitions, and message duplication to validate retry logic and idempotency.

Related topics: Event Sourcing, Saga Pattern, CQRS, Distributed Transactions, Message Brokers, Eventual Consistency, Outbox Pattern, Idempotency

---

## Event Versioning

Event versioning manages schema evolution in event-driven architectures where events serve as immutable facts representing state changes. The challenge lies in maintaining backward and forward compatibility across distributed systems consuming events at different versions while preserving the immutability principle that defines event sourcing.

### Versioning Strategies

**Schema Evolution Approaches**

Weak schema systems permit additive changes without version increments. New optional fields extend existing events while consumers ignore unknown properties. This approach minimizes coordination overhead but risks semantic drift where field meanings diverge across service boundaries. Strong schema systems enforce explicit versioning through schema registries, requiring version negotiation between producers and consumers.

**Upcasting and Downcasting**

Upcasting transforms old event versions to current schema during deserialization. Domain logic operates exclusively on the latest version, consolidating business rules in single code paths. Transformation functions map deprecated fields to new structures, applying default values or deriving missing data from context. This pattern concentrates migration complexity at system boundaries rather than distributing it across business logic.

Downcasting converts recent events to legacy formats for backward compatibility. Required when consumers cannot upgrade immediately or when supporting multiple application versions simultaneously. Introduces data loss risk when new schema includes fields absent in older versions, necessitating careful semantic analysis of what information can be safely discarded.

**Version Indicators**

Embedding version metadata directly in event payloads through dedicated version fields enables explicit schema identification. Event type names incorporating version suffixes (e.g., `OrderPlaced.v2`) provide self-documenting schemas but proliferate event type definitions. Content negotiation headers in message metadata separate versioning concerns from payload structure, allowing version selection without payload inspection.

### Anti-Patterns

**In-Place Event Mutation**

Modifying historical events violates event sourcing's fundamental immutability guarantee. Retroactive corrections should generate compensating events that explicitly document the correction, preserving complete audit trails. Systems that mutate events lose the ability to reconstruct historical state accurately and compromise debugging capabilities.

**Version Skipping Without Migration Paths**

Deprecating intermediate versions without providing migration functions from v1 to v3 forces consumers to implement multi-hop transformations. Each service independently develops v1→v2→v3 chains, duplicating logic and risking inconsistent interpretations. Maintain direct migration paths between all supported versions or establish canonical transformations through central repositories.

**Implicit Schema Changes**

Altering field semantics without version changes creates silent breaking changes. Changing an `amount` field from cents to dollars, or `timestamp` from Unix epoch to ISO 8601 string, breaks consumers expecting original formats. Semantic shifts require new versions even when data types remain compatible.

### Implementation Patterns

**Version Transformation Registry**

Centralized registries map source and target versions to transformation functions. Dependency injection provides version-appropriate transformers at event hydration time. Registry pattern enables runtime version discovery, allowing services to query supported versions before event production and select mutually compatible schemas.

```
registry.register(OrderPlaced.v1, OrderPlaced.v3, (v1) => {
  return {
    ...v1,
    customerId: v1.userId,  // Field rename
    items: v1.items.map(item => ({
      ...item,
      taxAmount: calculateTax(item)  // Derived field
    })),
    currency: 'USD'  // Default addition
  };
});
```

**Multi-Version Event Stores**

Storing events in multiple formats at write time eliminates read-time transformation overhead. Producers serialize events to all currently supported versions, trading increased storage costs for reduced computational complexity and latency. Particularly effective when read-to-write ratios heavily favor reads or when transformation logic carries significant computational expense.

**Versioned Event Handlers**

Handler registration maps event versions to dedicated processing functions rather than routing all versions through transformation layers. Different versions trigger distinct code paths optimized for their specific schemas. Approach works well for divergent schemas where transformation logic becomes complex, but increases maintenance burden through code duplication.

**Snapshot Versioning**

Event sourcing systems using snapshots must version both events and snapshots independently. Snapshot versions lag event versions since snapshots represent aggregated state. Rebuilding snapshots from events requires replaying historical events through version transformers, making snapshot regeneration a critical operational procedure during schema migrations.

### Edge Cases

**Bi-Temporal Versioning**

Systems tracking both business time (when events actually occurred) and system time (when events entered the system) face complex versioning scenarios. Late-arriving events may use schemas deprecated at arrival time but current at business time. Version selection must consider temporal context—events recorded today about transactions last year might need historical schema versions for semantic accuracy.

**Partial Event Hydration**

Projections consuming event subsets face versioning complexity when only specific fields undergo schema changes. Hydrating full events for single-field projections wastes resources, but partial deserialization requires field-level version tracking. Schema evolution tools must support field-level compatibility matrices indicating which fields changed across versions.

**Event Sourcing with GDPR Compliance**

Immutability conflicts with right-to-erasure requirements. Pseudo-deletion through encryption key destruction or event tombstoning preserves event log structure while rendering content inaccessible. Versioning strategies must account for events transitioning to redacted states, potentially introducing `RedactedEvent.vX` types maintaining structural compatibility without exposing original data.

### Testing Strategies

**Cross-Version Compatibility Suites**

Automated tests verify bidirectional transformations produce semantically equivalent results. Round-trip tests ensure v1→v2→v1 transformations preserve information where possible and document acceptable data loss. Property-based testing generates random valid events for each schema version, applying transformations and asserting invariants hold across versions.

**Temporal Replay Tests**

Replaying production event streams from specific time periods through current event handlers validates transformation logic against real-world data distributions. Historical replay identifies edge cases absent from synthetic test data and ensures gradual schema drift hasn't broken assumptions embedded in transformation functions.

**Contract Testing**

Consumer-driven contracts define minimum viable event schemas from consumer perspective. Producers validate schema changes against registered contracts, preventing breaking changes. Contract evolution tracking shows which consumers depend on specific schema features, informing deprecation timelines.

### Operational Considerations

**Version Sunset Policies**

Establishing clear deprecation timelines communicates version lifecycle to service owners. Multi-phase sunset begins with marking versions deprecated, proceeds to logging warnings when deprecated versions are produced/consumed, and culminates in version removal after grace periods. Telemetry tracking version usage identifies services requiring upgrade before deprecation deadlines.

**Schema Registry Integration**

Centralized schema registries (Confluent Schema Registry, AWS Glue Schema Registry) enforce compatibility rules at production time. Producers cannot publish events with incompatible schemas, preventing version conflicts from entering event streams. Registry APIs enable programmatic schema discovery, allowing consumers to query available versions and select compatible schemas dynamically.

**Version Metrics**

Monitoring version distribution across event streams reveals adoption rates for new schemas and identifies services stuck on deprecated versions. High cardinality in version distribution indicates fragmentation requiring consolidation. Tracking transformation function execution times identifies performance bottlenecks in version translation logic.

**Related Topics:** Event-carried state transfer, Schema evolution patterns, Polyglot persistence versioning, Command versioning strategies, Saga compensation with versioned events, Event store migration patterns

---

## Event Upcasting

Event upcasting transforms older event versions into newer schema versions during deserialization, enabling schema evolution without modifying historical event streams. This pattern maintains immutability of persisted events while ensuring application code operates against current domain models.

### Core Mechanism

Upcasting interceptors execute during event replay, detecting version metadata and applying sequential transformations. The process chains multiple version transitions: V1→V2→V3, never skipping intermediate versions to preserve transformation logic integrity.

```typescript
interface EventUpcaster<TOld, TNew> {
  canUpcast(event: StoredEvent): boolean;
  upcast(event: TOld): TNew;
  targetVersion: number;
}

class UserRegisteredUpcaster implements EventUpcaster<UserRegisteredV1, UserRegisteredV2> {
  canUpcast(event: StoredEvent): boolean {
    return event.type === 'UserRegistered' && event.version === 1;
  }

  upcast(event: UserRegisteredV1): UserRegisteredV2 {
    return {
      ...event,
      version: 2,
      email: event.emailAddress, // Field renamed
      metadata: {
        source: 'legacy_migration',
        timestamp: event.occurredAt
      }
    };
  }

  targetVersion = 2;
}
```

### Implementation Strategies

**Lazy Upcasting**: Transform events on-read during aggregate rehydration. Minimizes upfront migration cost but incurs runtime overhead on every projection rebuild and aggregate load. Appropriate when event stores contain billions of events or migration windows are constrained.

**Eager Upcasting**: Background process scans event store, transforming and rewriting events to current schema. Eliminates runtime transformation cost but requires careful coordination to avoid race conditions with concurrent writes. Implement with distributed locking or CDC patterns.

**Hybrid Approach**: Upcast during read, flag transformed events, asynchronous background process persists upcasted versions. Reduces read-path latency over time while avoiding blocking migrations.

### Version Metadata Management

Events must carry explicit version identifiers. Implicit versioning via schema inference creates fragility during rapid iteration phases.

```json
{
  "eventId": "evt_7x9k2m",
  "eventType": "OrderPlaced",
  "eventVersion": 3,
  "aggregateId": "ord_4j8n1q",
  "occurredAt": "2024-11-15T14:32:11Z",
  "data": { /* version 3 schema */ }
}
```

Store version in event envelope, not within payload. Upcasters inspect envelope metadata before deserializing payload, preventing deserialization failures on incompatible schemas.

### Upcast Chain Orchestration

```typescript
class UpcasterChain {
  private upcasters: Map<number, EventUpcaster<any, any>[]> = new Map();

  register(sourceVersion: number, upcaster: EventUpcaster<any, any>): void {
    const chain = this.upcasters.get(sourceVersion) || [];
    chain.push(upcaster);
    this.upcasters.set(sourceVersion, chain);
  }

  upcast(event: StoredEvent, targetVersion: number): DomainEvent {
    let current = event;
    let currentVersion = event.version;

    while (currentVersion < targetVersion) {
      const applicable = this.upcasters.get(currentVersion);
      if (!applicable || applicable.length === 0) {
        throw new MissingUpcasterError(currentVersion, targetVersion);
      }

      const upcaster = applicable[0]; // Single path enforcement
      current = upcaster.upcast(current);
      currentVersion = upcaster.targetVersion;
    }

    return current;
  }
}
```

Enforce single upcast path per version transition. Multiple competing upcasters for the same version transition indicate architectural ambiguity requiring resolution at design time.

### Anti-Patterns

**Lossy Transformations**: Dropping fields during upcasting without preserving data in alternative structure. Historical analysis becomes impossible. Store deprecated fields in metadata section or create parallel enrichment events.

**Conditional Upcasting Logic**: Branching transformation logic based on payload contents creates non-deterministic history. Each V1 event must produce identical V2 output regardless of when upcasting occurs.

```typescript
// INCORRECT: Conditional transformation
upcast(event: OrderPlacedV1): OrderPlacedV2 {
  return {
    ...event,
    // Transformation varies by content - non-deterministic
    priority: event.amount > 1000 ? 'high' : 'normal'
  };
}

// CORRECT: Deterministic field mapping only
upcast(event: OrderPlacedV1): OrderPlacedV2 {
  return {
    ...event,
    amount: event.totalAmount, // Simple rename
    currency: 'USD' // Default for missing field
  };
}
```

**Schema Downcast**: Never transform newer events to older schemas during projection rebuilds. Projections must handle all schema versions or upcast to current version. Downcast creates data loss scenarios.

**Circular Dependencies**: Upcaster logic must not depend on external domain services, repositories, or stateful components. Transformations must be pure functions operating solely on event data. External dependencies create replay failures when services are unavailable.

### Testing Strategies

Generate comprehensive test suites covering every version transition path. Property-based testing ensures upcast chains maintain semantic equivalence.

```typescript
describe('UserRegistered Upcast Chain', () => {
  it('maintains semantic equivalence V1→V3', () => {
    const v1Event = generateUserRegisteredV1();
    const v3Direct = upcastChain.upcast(v1Event, 3);
    
    // Verify through V2 intermediate
    const v2Event = upcastChain.upcast(v1Event, 2);
    const v3FromV2 = upcastChain.upcast(v2Event, 3);
    
    expect(v3Direct).toEqual(v3FromV2);
  });

  it('preserves all original data', () => {
    const v1Event = createV1WithAllFields();
    const v2Event = upcast(v1Event);
    
    // Verify no data loss
    expect(extractAllValues(v2Event)).toContainAll(extractAllValues(v1Event));
  });
});
```

### Performance Optimization

Cache upcasted events at aggregate or projection level to avoid repeated transformation overhead. Invalidate cache when new upcasters deploy.

```typescript
class CachingEventStore implements EventStore {
  private upcastCache = new LRU<string, DomainEvent[]>({ max: 10000 });

  async loadEvents(aggregateId: string): Promise<DomainEvent[]> {
    const cacheKey = `${aggregateId}:v${this.currentVersion}`;
    
    if (this.upcastCache.has(cacheKey)) {
      return this.upcastCache.get(cacheKey)!;
    }

    const stored = await this.store.load(aggregateId);
    const upcasted = stored.map(e => this.upcasterChain.upcast(e, this.currentVersion));
    
    this.upcastCache.set(cacheKey, upcasted);
    return upcasted;
  }
}
```

Monitor upcasting performance metrics: transformation latency per version transition, cache hit rates, and aggregate rehydration time. Alerts trigger when P99 latency exceeds thresholds indicating upcaster complexity issues.

### Versioning Strategy Evolution

**Additive Changes**: New optional fields require no upcasting. Set defaults during deserialization.

**Field Renames**: Require upcaster mapping old field name to new field name.

**Structural Changes**: Splitting/merging fields requires transformation logic. Example: `fullName` → `{firstName, lastName}` requires parsing logic with fallback handling.

**Semantic Changes**: Field meaning changes require new event type, not upcasting. Example: `price` currency change from implied USD to explicit multi-currency. Emit `OrderPlacedV2` event type instead of upcasting `OrderPlaced`.

### Event Store Integration Patterns

**Axon Framework**: Implement `EventUpcaster` interface, register in `EventUpcasterChain`, automatic application during deserialization.

**EventStoreDB**: Use projection API to create upcasted event stream, application reads from transformed stream or inline upcasting in subscription handlers.

**Custom Solutions**: Middleware layer intercepts event deserialization, applies upcast chain before domain handler receives event.

Upcasting enables zero-downtime schema evolution in event-sourced systems. Proper implementation maintains historical data integrity while supporting continuous domain model refinement.

**Related Topics**: Event Versioning Strategies, Schema Registry Integration, Weak Schema Patterns, Event Migration vs Upcasting, Projection Rebuild Strategies

---
