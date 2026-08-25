## Dead Letter Queues

### Overview

A dead letter queue (DLQ) is a durable holding location for events or documents that fail to be processed or delivered, preserving them for later inspection and reprocessing rather than allowing them to be silently dropped. Within the Elastic Stack, the most prominent implementation is Logstash's DLQ, though the concept also applies more broadly to failure-redirect patterns elsewhere in the stack, such as the ingest pipeline failure-redirect pattern covered previously.

### Logstash's Dead Letter Queue

**Key Points**
- Logstash's DLQ captures events that fail to be indexed at the output stage, specifically for the Elasticsearch output plugin, when Elasticsearch rejects a document (for example, a mapping conflict, a malformed field value, or a version conflict).
- Disabled by default; enabling it requires setting `dead_letter_queue.enable: true` in `logstash.yml`, either globally or per-pipeline.
- Events written to the DLQ retain the original event data along with metadata about the failure — including the reason for rejection and a timestamp — enabling later diagnosis of exactly why the event failed.

```yaml
dead_letter_queue.enable: true
dead_letter_queue.max_bytes: 1024mb
path.dead_letter_queue: /var/lib/logstash/dead_letter_queue
```

**Key Points**
- `dead_letter_queue.max_bytes` caps the total size of the DLQ on disk; once the limit is reached, new entries are dropped (not queued) until space is freed, so monitoring DLQ size is important in sustained-failure scenarios.
- The DLQ is stored on local disk at the configured `path.dead_letter_queue`, structured as per-pipeline segment files.

### Diagram: Logstash DLQ Flow

<svg width="100%" viewBox="0 0 680 320" role="img"><title>Logstash dead letter queue flow (svg_diagram)</title><desc>Events flow from Logstash input through filters to the Elasticsearch output. Events Elasticsearch rejects are written to the dead letter queue instead of being dropped, and can later be reprocessed through a dead_letter_queue input.</desc>
<defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></marker></defs>

<g class="node c-blue">
<rect x="40" y="30" width="140" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="110" y="50" text-anchor="middle" dominant-baseline="central">Input</text>
<text class="ts" x="110" y="70" text-anchor="middle" dominant-baseline="central">Beats, Kafka, etc.</text>
</g>

<line x1="180" y1="58" x2="220" y2="58" class="arr" marker-end="url(#arrow)" />

<g class="node c-blue">
<rect x="220" y="30" width="140" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="290" y="50" text-anchor="middle" dominant-baseline="central">Filters</text>
<text class="ts" x="290" y="70" text-anchor="middle" dominant-baseline="central">grok, mutate, etc.</text>
</g>

<line x1="360" y1="58" x2="400" y2="58" class="arr" marker-end="url(#arrow)" />

<g class="node c-blue">
<rect x="400" y="30" width="160" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="480" y="50" text-anchor="middle" dominant-baseline="central">Elasticsearch output</text>
<text class="ts" x="480" y="70" text-anchor="middle" dominant-baseline="central">Attempts to index</text>
</g>

<line x1="480" y1="86" x2="480" y2="130" class="arr" marker-end="url(#arrow)" />
<text class="ts" x="560" y="112" text-anchor="middle">Rejected</text>

<g class="node c-coral">
<rect x="380" y="130" width="200" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="480" y="150" text-anchor="middle" dominant-baseline="central">Dead letter queue</text>
<text class="ts" x="480" y="170" text-anchor="middle" dominant-baseline="central">On local disk</text>
</g>

<line x1="480" y1="186" x2="480" y2="220" class="arr" marker-end="url(#arrow)" />

<g class="node c-teal">
<rect x="380" y="220" width="200" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="480" y="240" text-anchor="middle" dominant-baseline="central">dead_letter_queue input</text>
<text class="ts" x="480" y="260" text-anchor="middle" dominant-baseline="central">Reprocess in new pipeline</text>
</g>
</svg>

### Reprocessing Events from the DLQ

**Key Points**
- Logstash provides a `dead_letter_queue` input plugin, which reads events back out of the DLQ, allowing them to be routed through a corrective pipeline (for example, after fixing a mapping issue or a malformed filter) and resubmitted to Elasticsearch.
- Reprocessing is typically done as a separate, deliberately run pipeline rather than continuously, since continuously reading and re-attempting delivery of events that will fail again for the same unresolved reason would just refill the DLQ.

```
input {
  dead_letter_queue {
    path => "/var/lib/logstash/dead_letter_queue"
    commit_offsets => true
  }
}
```

- `commit_offsets => true` marks DLQ entries as read after processing, so re-running the same reprocessing pipeline doesn't reprocess already-handled entries.

### What Causes Events to Land in the DLQ

**Key Points**
- Mapping conflicts — a field that was previously indexed as one type (e.g., `keyword`) receiving a document where that field is a different type (e.g., an object).
- Malformed data that fails a mapping's strict type coercion, such as text where a `date` or `numeric` type is expected.
- Document version conflicts, in setups using explicit versioning.
- [Unverified] The exact set of Elasticsearch rejection reasons that route to the DLQ versus other failure handling depends on the specific error type and Logstash version, so current documentation should be checked when diagnosing an unfamiliar rejection reason.

### DLQ vs. Pipeline-Level `on_failure` Redirect

**Key Points**
- Logstash's DLQ captures failures at the output/delivery stage — after all filter processing has already happened successfully — specifically for rejections coming back from Elasticsearch.
- The ingest pipeline `on_failure`-based redirect pattern (covered previously) captures failures during document processing within Elasticsearch itself, before or during indexing.
- [Inference] These are complementary rather than redundant: a robust pipeline can use Logstash filters plus DLQ for delivery-stage failures, and ingest pipeline `on_failure` redirection for processing-stage failures that occur inside Elasticsearch, covering different points in the overall data flow where something can go wrong.

### Monitoring DLQ Health

**Key Points**
- Logstash exposes DLQ-related metrics (queue size, age of oldest entry) via its monitoring APIs, which can be tracked to detect a DLQ that is silently accumulating unaddressed failures.
- A steadily growing DLQ, or one approaching `dead_letter_queue.max_bytes`, is a signal that an upstream data quality or mapping issue needs attention rather than being left to reprocess automatically, since the failures generally repeat until their root cause is fixed.

### Related Topics

- **Logstash pipeline-to-pipeline communication** as a way to route DLQ reprocessing without a separate manual run
- **Elasticsearch mapping conflicts** and strategies to prevent them (explicit mappings, `ignore_malformed`)
- **`ignore_malformed`** as an alternative that lets a document index successfully despite one bad field, rather than being rejected outright
- **Logstash persistent queues** (a distinct feature from the DLQ, buffering all in-flight events for crash recovery) and how they differ in purpose from the DLQ
- **Failure handling in ingest pipelines** (previous topic) as the Elasticsearch-side complement to Logstash's DLQ
- **Reindex-from-remote** as a pattern for bulk reprocessing large volumes of previously failed data after a root-cause fix