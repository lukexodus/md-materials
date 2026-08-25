## Stack Monitoring

### Overview

Stack Monitoring is Kibana's built-in feature for observing the health and performance of an Elasticsearch cluster (and other stack components like Kibana, Logstash, and Beats) over time. It surfaces metrics such as cluster health, node resource usage, index statistics, and shard allocation, helping operators detect and diagnose problems before they cause outages.

### Architecture: Metricbeat-Based Monitoring vs. Legacy Internal Collection

**Key Points**
- Two collection methods exist: legacy internal collection (Elasticsearch itself indexes monitoring data into `.monitoring-*` indices) and Metricbeat-based collection (a separate Metricbeat instance scrapes monitoring APIs and ships data to a monitoring cluster).
- Metricbeat-based collection is the recommended approach, since it decouples monitoring data collection from the production cluster's own resources and reduces the risk of monitoring load affecting production performance.
- Internal collection runs monitoring data through the same cluster being monitored, which means a cluster in enough distress to need monitoring the most may also struggle to reliably collect and store that monitoring data.
- Sending monitoring data to a separate, dedicated monitoring cluster (rather than the production cluster monitoring itself) is the recommended production pattern, so that a production cluster outage doesn't simultaneously take down the ability to diagnose it.

### Diagram: Recommended Monitoring Architecture

<svg width="100%" viewBox="0 0 680 300" role="img"><title>Metricbeat-based stack monitoring architecture (svg_diagram)</title><desc>Metricbeat collects metrics from the production cluster and Kibana, then ships them to a separate dedicated monitoring cluster, which Kibana reads from to display Stack Monitoring dashboards.</desc>
<defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></marker></defs>

<g class="node c-blue">
<rect x="40" y="30" width="200" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="140" y="50" text-anchor="middle" dominant-baseline="central">Production cluster</text>
<text class="ts" x="140" y="70" text-anchor="middle" dominant-baseline="central">Nodes, indices, shards</text>
</g>

<g class="node c-teal">
<rect x="270" y="30" width="160" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="350" y="50" text-anchor="middle" dominant-baseline="central">Metricbeat</text>
<text class="ts" x="350" y="70" text-anchor="middle" dominant-baseline="central">Scrapes monitoring APIs</text>
</g>

<line x1="240" y1="58" x2="268" y2="58" class="arr" marker-end="url(#arrow)" />

<g class="node c-purple">
<rect x="470" y="30" width="170" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="555" y="50" text-anchor="middle" dominant-baseline="central">Monitoring cluster</text>
<text class="ts" x="555" y="70" text-anchor="middle" dominant-baseline="central">Dedicated, separate</text>
</g>

<line x1="350" y1="86" x2="500" y2="150" class="arr" marker-end="url(#arrow)" />

<g class="node c-blue">
<rect x="40" y="150" width="200" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="140" y="170" text-anchor="middle" dominant-baseline="central">Kibana instance</text>
<text class="ts" x="140" y="190" text-anchor="middle" dominant-baseline="central">Serving production UI</text>
</g>

<line x1="240" y1="178" x2="350" y2="86" class="arr" marker-end="url(#arrow)" />

<line x1="555" y1="86" x2="555" y2="220" class="arr" marker-end="url(#arrow)" />
<g class="node c-purple">
<rect x="460" y="220" width="180" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="550" y="240" text-anchor="middle" dominant-baseline="central">Stack Monitoring UI</text>
<text class="ts" x="550" y="260" text-anchor="middle" dominant-baseline="central">Reads from monitoring cluster</text>
</g>
</svg>

### Setting Up Metricbeat Monitoring

**Key Points**
- The `elasticsearch` Metricbeat module collects cluster stats, node stats, index stats, and shard allocation data from the monitored cluster.
- The `kibana` Metricbeat module collects Kibana's own status and usage metrics.
- Metricbeat is pointed at the monitored cluster to scrape from, and separately configured to output to the monitoring cluster.

```yaml
metricbeat.modules:
  - module: elasticsearch
    xpack.enabled: true
    period: 10s
    hosts: ["https://production-es:9200"]
    username: "remote_monitoring_user"
    password: "changeme"

output.elasticsearch:
  hosts: ["https://monitoring-es:9200"]
  username: "elastic"
  password: "changeme"
```

- `xpack.enabled: true` on the module tells Metricbeat to format the collected data in the schema Stack Monitoring's Kibana UI expects.
- A dedicated monitoring user with the appropriate built-in monitoring role (rather than a superuser) is the standard practice for the credentials Metricbeat uses to scrape the monitored cluster.

### What Stack Monitoring Shows

**Key Points**
- **Cluster overview**: overall cluster health (green/yellow/red), node count, index count, shard count, and aggregate resource usage.
- **Node listing**: per-node CPU usage, JVM heap usage, disk usage, and load average, letting operators spot an individual struggling node.
- **Index listing**: per-index document count, size, indexing rate, and search rate.
- **Shard allocation view**: which shards live on which nodes, and unassigned shard counts, useful for diagnosing allocation problems.
- **Advanced monitoring views**: for a selected node or index, deeper time-series charts of JVM heap over time, GC frequency and duration, indexing/search latency, and thread pool queue/rejection counts.

### Alerting Integration

Stack Monitoring integrates with Kibana's alerting framework to provide built-in rules for common cluster health problems — including cluster health status changes (yellow/red), nodes running low on disk space, CPU usage sustained above a threshold, and JVM memory usage sustained above a threshold — which can be configured to notify via email, Slack, PagerDuty, or other connectors without requiring custom rule authoring.

### Retention of Monitoring Data

**Key Points**
- Monitoring data accumulates over time like any other indexed data and should have its own ILM policy to control retention, since indefinite retention of high-frequency metrics data leads to unbounded storage growth.
- A common pattern applies a relatively short retention window (days to a few weeks) to monitoring data, since its primary value is in recent-history troubleshooting and short-to-medium-term trend analysis rather than long-term archival.
- [Unverified] The appropriate retention window depends on organizational requirements for historical trend analysis and audit needs, so this should be tuned rather than left at any product default without review.

### Stack Monitoring vs. General-Purpose Observability

[Inference] Stack Monitoring is purpose-built for observing the Elastic Stack's own components and is not a substitute for general application or infrastructure observability (APM, general infrastructure metrics, log analysis of application behavior) — it answers "is my Elasticsearch cluster healthy" specifically, and organizations typically run it alongside, not instead of, broader observability tooling covering their full infrastructure and applications.

### Related Topics

- **Built-in monitoring roles and users** (`remote_monitoring_collector`, `remote_monitoring_agent`) and least-privilege setup
- **Kibana alerting framework** and connector types beyond the built-in monitoring rules
- **Cross-cluster monitoring** setups for organizations running many production clusters into one shared monitoring cluster
- **JVM garbage collection metrics** and how to read GC frequency/duration charts for heap pressure diagnosis
- **Thread pool rejection metrics** and what queue/rejection counts indicate about node saturation
- **Migrating from legacy internal collection to Metricbeat-based collection** for existing clusters