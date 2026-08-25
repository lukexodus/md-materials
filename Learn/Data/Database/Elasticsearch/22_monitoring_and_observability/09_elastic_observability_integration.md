## Elastic Observability Integration

### Overview

Elastic Observability is Elastic's unified approach to combining logs, metrics, and traces (APM) into a single stack and Kibana experience, built on Elasticsearch as the common backing store. Rather than running separate tools for each observability signal, the Elastic Stack lets logs, metrics, and application traces flow into the same cluster and be correlated in shared views.

### The Three Pillars and Their Collection Paths

**Key Points**
- **Logs**: collected primarily via Filebeat or Elastic Agent, parsed and structured through ingest pipelines, and viewed in Kibana's Logs UI/Discover.
- **Metrics**: collected via Metricbeat or Elastic Agent (as covered previously), viewed through Kibana's Infrastructure UI and custom dashboards.
- **Traces (APM)**: collected via APM agents embedded in application code (or auto-instrumentation), sent to the APM integration in Elastic Agent or the legacy standalone APM Server, and viewed in Kibana's APM UI.
- All three ultimately land as documents in Elasticsearch indices/data streams, which is what enables cross-signal correlation — a trace, its associated logs, and the host metrics at that time can all be queried from the same underlying store.

### Diagram: Observability Data Flow

<svg width="100%" viewBox="0 0 680 340" role="img"><title>Elastic Observability data flow from sources to Kibana (svg_diagram)</title><desc>Logs, metrics, and traces are each collected by a dedicated agent, sent to Elasticsearch through ingest pipelines, and then correlated together in Kibana Observability views.</desc>
<defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></marker></defs>

<g class="node c-blue">
<rect x="40" y="30" width="150" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="115" y="50" text-anchor="middle" dominant-baseline="central">Application logs</text>
<text class="ts" x="115" y="70" text-anchor="middle" dominant-baseline="central">via Filebeat</text>
</g>

<g class="node c-teal">
<rect x="265" y="30" width="150" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="340" y="50" text-anchor="middle" dominant-baseline="central">Host metrics</text>
<text class="ts" x="340" y="70" text-anchor="middle" dominant-baseline="central">via Metricbeat</text>
</g>

<g class="node c-coral">
<rect x="490" y="30" width="150" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="565" y="50" text-anchor="middle" dominant-baseline="central">App traces</text>
<text class="ts" x="565" y="70" text-anchor="middle" dominant-baseline="central">via APM agent</text>
</g>

<line x1="115" y1="86" x2="280" y2="150" class="arr" marker-end="url(#arrow)" />
<line x1="340" y1="86" x2="340" y2="150" class="arr" marker-end="url(#arrow)" />
<line x1="565" y1="86" x2="400" y2="150" class="arr" marker-end="url(#arrow)" />

<g class="node c-gray">
<rect x="240" y="150" width="200" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="340" y="170" text-anchor="middle" dominant-baseline="central">Elasticsearch</text>
<text class="ts" x="340" y="190" text-anchor="middle" dominant-baseline="central">Ingest pipelines, data streams</text>
</g>

<line x1="340" y1="206" x2="340" y2="250" class="arr" marker-end="url(#arrow)" />

<g class="node c-purple">
<rect x="190" y="250" width="300" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="340" y="270" text-anchor="middle" dominant-baseline="central">Kibana Observability</text>
<text class="ts" x="340" y="290" text-anchor="middle" dominant-baseline="central">Correlated logs, metrics, traces</text>
</g>
</svg>

### Ingest Pipelines for Log Structuring

**Key Points**
- Raw log lines are typically unstructured text, and ingest pipelines (or Logstash) parse them into structured fields — timestamps, log levels, service names, trace/span IDs — using processors like `grok`, `dissect`, or `json`.
- Elastic Common Schema (ECS) is the standardized field-naming convention used across logs, metrics, and traces so that a field like `host.name` or `service.name` means the same thing and is queryable consistently regardless of which signal or Beat produced it.
- Consistent adherence to ECS is what makes cross-signal correlation practical — without shared field names, joining a trace's `service.name` to related log entries would require manual field mapping per data source.

### Correlating Traces and Logs

**Key Points**
- APM agents can automatically inject trace and span IDs into application log output when logs are correlated with tracing configuration in the agent.
- When log entries carry `trace.id` and `span.id` fields matching ECS conventions, Kibana's APM UI can display the exact log lines emitted during a specific trace, directly within the trace waterfall view.
- This correlation eliminates the manual step of cross-referencing timestamps between a separate logging tool and a separate APM tool.

### Service Maps

The APM UI's service map visualizes dependencies between instrumented services (and their connections to databases, external APIs, and message queues) automatically, built from the trace data collected across all instrumented services, showing real traffic flow and latency/error-rate coloring per connection rather than requiring the topology to be manually diagrammed and maintained.

### Synthetic Monitoring and Uptime

**Key Points**
- Elastic Observability includes synthetic monitoring (via Heartbeat or the Elastic Synthetics runner), which proactively checks endpoint availability and, for browser-based synthetic monitors, full user-journey scripts on a schedule from configured locations.
- This complements passive APM/log monitoring by detecting availability problems even when there's no real user traffic generating traces at that moment.

### SLOs (Service Level Objectives)

**Key Points**
- Kibana Observability includes an SLO feature for defining service level objectives against metrics like availability or latency, backed by underlying APM or custom data.
- SLOs track error budget consumption over a rolling window and can trigger alerts when burn rate exceeds a configured threshold, which is a more nuanced signal than a simple static threshold alert, since burn rate accounts for how quickly the error budget is being consumed relative to the SLO window.

### Alerting Across Signals

Kibana's alerting framework spans Observability, allowing a single alert rule to be built from log thresholds, metric thresholds, APM anomaly detection, or custom Elasticsearch queries, with unified routing to notification connectors (email, Slack, PagerDuty, webhook) regardless of which signal type triggered the rule.

### Resource and Cluster Sizing Implications

[Inference] Because Observability workloads combine high-volume logs, high-cardinality metrics, and trace data — often at significant total ingest volume for larger deployments — clusters serving Observability use cases typically need the hot-warm-cold ILM tiering, shard sizing, and hardware guidance covered in earlier topics applied deliberately, since observability data volume tends to grow faster and more unpredictably than typical business application data.

### Related Topics

- **Elastic Common Schema (ECS)** field reference and mapping conventions in depth
- **APM agents** per language (Java, Node.js, Python, Go, .NET, Ruby) and their auto-instrumentation capabilities
- **Ingest pipeline processors** (`grok`, `dissect`, `date`, `geoip`) for log parsing in depth
- **Elastic Agent and Fleet-managed integrations** as the unified collection path across all three signal types
- **Anomaly detection (machine learning jobs)** applied to Observability data for automatic baseline deviation alerts
- **Data stream lifecycle management** specifically for high-volume logs and traces indices