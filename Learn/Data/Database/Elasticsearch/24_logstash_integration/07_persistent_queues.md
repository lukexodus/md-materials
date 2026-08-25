## Persistent Queues

### Overview

Persistent queues (PQ) are a Logstash feature that buffers in-flight events to disk between the input and filter/output stages, protecting against event loss if Logstash crashes, is restarted, or its downstream output becomes temporarily unavailable. This is distinct from the dead letter queue covered previously — the persistent queue buffers all events during normal operation, while the DLQ specifically holds events that Elasticsearch rejected.

### Why Persistent Queues Exist: The In-Memory Queue Problem

**Key Points**
- By default, Logstash uses an in-memory queue between its input and filter/output stages, which is fast but volatile — if Logstash crashes or is forcibly killed, any events sitting in that in-memory queue (received by an input but not yet fully processed and output) are lost permanently.
- Persistent queues address this by writing acknowledged events to disk before they're removed from the input's own buffer, so a crash mid-processing doesn't lose events that were already accepted.

### Enabling Persistent Queues

```yaml
queue.type: persisted
path.queue: /var/lib/logstash/queue
queue.max_bytes: 4gb
queue.checkpoint.writes: 1024
```

**Key Points**
- `queue.type: persisted` switches from the default in-memory queue to the disk-backed persistent queue; this is set in `logstash.yml` or per-pipeline in `pipelines.yml`.
- `queue.max_bytes` caps total disk usage for the queue; once full, Logstash applies backpressure to inputs, slowing or pausing ingestion until queue space frees up, rather than dropping events.
- `queue.checkpoint.writes` controls how many writes accumulate before a checkpoint (durability marker) is forced, trading off some durability granularity for write throughput — more frequent checkpoints are more durable but add I/O overhead.

### Diagram: Persistent Queue Position in the Pipeline

<svg width="100%" viewBox="0 0 680 260" role="img"><title>Persistent queue position between input and filter stages (svg_diagram)</title><desc>The persistent queue sits between the input stage and the filter and output stages, durably storing events on disk so that a crash after input but before output does not lose data.</desc>
<defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></marker></defs>

<g class="node c-blue">
<rect x="40" y="80" width="140" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="110" y="100" text-anchor="middle" dominant-baseline="central">Input</text>
<text class="ts" x="110" y="120" text-anchor="middle" dominant-baseline="central">Receives events</text>
</g>

<line x1="180" y1="108" x2="220" y2="108" class="arr" marker-end="url(#arrow)" />

<g class="node c-coral">
<rect x="220" y="60" width="200" height="96" rx="8" stroke-width="0.5" />
<text class="th" x="320" y="85" text-anchor="middle" dominant-baseline="central">Persistent queue</text>
<text class="ts" x="320" y="105" text-anchor="middle" dominant-baseline="central">Written to disk</text>
<text class="ts" x="320" y="122" text-anchor="middle" dominant-baseline="central">Acknowledges input</text>
<text class="ts" x="320" y="139" text-anchor="middle" dominant-baseline="central">only after durable write</text>
</g>

<line x1="420" y1="108" x2="460" y2="108" class="arr" marker-end="url(#arrow)" />

<g class="node c-blue">
<rect x="460" y="80" width="90" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="505" y="108" text-anchor="middle" dominant-baseline="central">Filters</text>
</g>

<line x1="550" y1="108" x2="590" y2="108" class="arr" marker-end="url(#arrow)" />
<text class="ts" x="605" y="104" text-anchor="middle">Output</text>

<text class="ts" x="320" y="200" text-anchor="middle">Events removed from the queue only after the output stage</text>
<text class="ts" x="320" y="216" text-anchor="middle">confirms successful delivery</text>
</svg>

### Acknowledgment Flow and Durability Guarantee

**Key Points**
- An event is only removed (dequeued) from the persistent queue after it has been fully processed by the filter stage and successfully acknowledged by the output stage — not merely after it was received by the input.
- If Logstash crashes after an event is durably written to the persistent queue but before it's been successfully delivered by the output, the event remains in the queue on disk and is reprocessed automatically on restart.
- This gives Logstash an at-least-once delivery guarantee for events that made it into the persistent queue, at the cost of the disk I/O overhead of the durable write, and potential duplicate delivery if an event was actually delivered but the acknowledgment was lost before the queue could record it as complete.

### Performance Trade-offs

**Key Points**
- Persistent queues add disk I/O to every event's path through Logstash, which reduces raw throughput compared to the in-memory queue, particularly on slower disks.
- SSD-backed storage for `path.queue` is recommended for the same reasons SSDs are generally preferred for Elasticsearch data nodes — the queue's write pattern benefits significantly from low-latency random I/O.
- [Inference] The throughput cost of enabling persistent queues is generally considered an acceptable trade-off against the risk of silent data loss for use cases where losing events (audit logs, billing-relevant events, compliance data) would be materially harmful, whereas use cases more tolerant of occasional data loss (best-effort metrics, high-volume debug logs) may reasonably prioritize the higher throughput of the default in-memory queue.

### Backpressure Behavior

**Key Points**
- When the persistent queue reaches `queue.max_bytes`, Logstash stops accepting new events at the input stage until queue space is freed by successful output delivery, rather than dropping events or growing the queue unboundedly.
- This means a sustained output outage (for example, Elasticsearch becoming unreachable) causes ingestion to eventually stall entirely once the queue fills, rather than silently losing events past that point — a deliberate trade-off favoring data safety over continued ingestion during an outage.
- Monitoring queue size relative to `queue.max_bytes` is important operationally, since an ingestion stall due to a full queue can look like a completely different problem (e.g., "Logstash isn't receiving data") if the underlying cause — a downstream output outage — isn't immediately visible.

### Persistent Queues vs. Dead Letter Queue — Comparison

| Aspect | Persistent Queue | Dead Letter Queue |
|---|---|---|
| Purpose | Buffer all in-flight events for crash recovery | Hold specifically rejected/failed events |
| Position | Between input and filter/output stages | After output rejection |
| Default state | Disabled (in-memory queue used) | Disabled |
| Contains | Every event, transiently, during normal operation | Only events Elasticsearch rejected |
| Growth pattern | Grows under output slowness/outage, shrinks as delivery catches up | Grows only when rejections occur, requires root-cause fix to stop growing |

### Related Topics

- **Logstash pipeline-to-pipeline communication** and how persistent queues interact with multi-pipeline architectures
- **Dead letter queues** (previous topic) as the complementary mechanism for rejected-event handling
- **`queue.checkpoint.acks` and `queue.checkpoint.interval`** for finer control over checkpoint frequency
- **Logstash monitoring APIs** for tracking queue size, event throughput, and backpressure state
- **Beats and Kafka input acknowledgment semantics**, since the input's own ack behavior interacts with persistent queue durability guarantees
- **Sizing `queue.max_bytes`** relative to expected outage duration and sustained ingest rate