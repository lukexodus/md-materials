## Logstash Monitoring

### Overview

Logstash exposes a range of internal metrics — event throughput, pipeline latency, queue state, JVM health, plugin-level performance — through both a monitoring API and integration with Kibana's Stack Monitoring. Observing these metrics is essential for diagnosing bottlenecks, detecting backpressure, and confirming a pipeline is keeping pace with its input volume.

### The Node Stats API

```
GET _node/stats
```

Logstash's own monitoring API (distinct from Elasticsearch's) is queried directly against a Logstash instance's HTTP API, typically on port 9600, and returns a comprehensive snapshot of that node's current state.

**Key Points**
- `events` — counts of events received, filtered, and output, plus timing statistics, at both the node level and per-pipeline.
- `jvm` — heap usage, garbage collection counts and duration, thread counts.
- `pipelines` — per-pipeline breakdown of the same event and queue metrics, essential when a single Logstash instance runs multiple pipelines.
- `queue` — persistent queue size, event count, and capacity, when persistent queues are enabled.
- `process` — OS-level process metrics like CPU percentage and open file descriptors.

### Key Metrics to Watch

**Key Points**
- **Events in vs. events out**: a sustained gap where events are being received faster than they're being output indicates the pipeline (or its output destination) can't keep pace, and backpressure or queue growth will follow.
- **Pipeline latency / `duration_in_millis`**: per-event or per-batch processing time; a rising trend points to a specific filter or output becoming a bottleneck.
- **JVM heap usage and GC frequency**: frequent or long garbage collection pauses reduce effective throughput and, in severe cases, indicate the JVM heap is undersized for the workload.
- **Queue size relative to capacity** (when persistent queues are enabled, as covered previously): a queue trending toward `queue.max_bytes` signals the output can't keep up with the input rate.
- **Worker utilization**: whether configured pipeline workers (`pipeline.workers`) are consistently busy, which can indicate whether adding more workers or batch size tuning would help throughput.

### Diagram: Logstash Monitoring Data Sources

<svg width="100%" viewBox="0 0 680 300" role="img"><title>Logstash monitoring data collection paths (svg_diagram)</title><desc>A Logstash instance exposes metrics through its own node stats API, which can be queried directly or collected by Metricbeat and shipped to a monitoring cluster for visualization in Kibana Stack Monitoring.</desc>
<defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></marker></defs>

<g class="node c-blue">
<rect x="250" y="20" width="180" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="340" y="40" text-anchor="middle" dominant-baseline="central">Logstash instance</text>
<text class="ts" x="340" y="60" text-anchor="middle" dominant-baseline="central">Exposes port 9600</text>
</g>

<line x1="290" y1="76" x2="180" y2="130" class="arr" marker-end="url(#arrow)" />
<line x1="390" y1="76" x2="500" y2="130" class="arr" marker-end="url(#arrow)" />

<g class="node c-gray">
<rect x="60" y="130" width="220" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="170" y="150" text-anchor="middle" dominant-baseline="central">Direct API query</text>
<text class="ts" x="170" y="170" text-anchor="middle" dominant-baseline="central">GET _node/stats</text>
</g>

<g class="node c-teal">
<rect x="400" y="130" width="220" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="510" y="150" text-anchor="middle" dominant-baseline="central">Metricbeat logstash module</text>
<text class="ts" x="510" y="170" text-anchor="middle" dominant-baseline="central">Scrapes on a schedule</text>
</g>

<line x1="510" y1="186" x2="510" y2="220" class="arr" marker-end="url(#arrow)" />

<g class="node c-purple">
<rect x="400" y="220" width="220" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="510" y="240" text-anchor="middle" dominant-baseline="central">Monitoring cluster</text>
<text class="ts" x="510" y="260" text-anchor="middle" dominant-baseline="central">Kibana Stack Monitoring</text>
</g>
</svg>

### Metricbeat's `logstash` Module

**Key Points**
- As with Elasticsearch and Kibana monitoring (covered previously), the recommended production approach ships Logstash metrics via Metricbeat's `logstash` module to a dedicated monitoring cluster, rather than relying solely on ad hoc direct API queries.
- This surfaces Logstash health in the same Stack Monitoring UI used for the rest of the deployment, allowing correlated diagnosis — for example, seeing that Logstash's event throughput dropped at the same time an Elasticsearch node's indexing thread pool showed rejections.

```yaml
metricbeat.modules:
  - module: logstash
    xpack.enabled: true
    period: 10s
    hosts: ["http://localhost:9600"]
```

### Hot Threads

```
GET _node/hot_threads
```

**Key Points**
- Returns a snapshot of the busiest threads in the Logstash JVM at that moment, useful for diagnosing which specific plugin or internal operation is consuming CPU during a performance investigation.
- This mirrors Elasticsearch's own hot threads API in purpose — identifying what a JVM-based process is actually spending its CPU time on right now, rather than relying on aggregate metrics alone.

### Pipeline-Level Diagnostics

**Key Points**
- When multiple pipelines run in one Logstash instance (via `pipelines.yml`), per-pipeline metrics in the node stats output allow isolating which specific pipeline is slow or backpressured, rather than only having an aggregate node-wide view.
- The `pipeline.workers` and `pipeline.batch.size` settings for each pipeline directly affect its throughput characteristics, and monitoring worker utilization alongside queue/backpressure metrics helps determine whether adjusting either setting would relieve an observed bottleneck.

### Common Diagnostic Scenarios

**Key Points**
- **Rising persistent queue size** combined with steady `events.in` but falling `events.out` typically points to an output-side problem — Elasticsearch rejecting documents, network issues, or Elasticsearch itself under load.
- **High GC frequency/duration** alongside degraded throughput typically points to JVM heap sizing, excessive object allocation in a filter (e.g., a heavy `ruby` filter or complex `grok` patterns), or simply too much data volume for the allocated heap.
- **Low worker utilization** despite a backlog of events can indicate the bottleneck is upstream (input can't read fast enough) or downstream (output is slow, workers are blocked waiting on it) rather than in the filter stage itself.

### Related Topics

- **Persistent queues** (previous topic) and interpreting their size/capacity metrics
- **Dead letter queues** and their own size/growth metrics as a monitoring signal
- **Pipeline-to-pipeline communication** and how it affects per-pipeline metric interpretation
- **`pipeline.workers` and `pipeline.batch.size` tuning** based on observed throughput and latency metrics
- **Stack Monitoring in Kibana** (earlier topic) as the visualization layer for Metricbeat-collected Logstash metrics
- **Elasticsearch hot threads API** as the comparable diagnostic tool on the Elasticsearch side of a pipeline