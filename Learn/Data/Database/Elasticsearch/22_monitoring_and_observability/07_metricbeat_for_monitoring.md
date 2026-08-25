## Metricbeat for Monitoring

### Overview

Metricbeat is a lightweight, purpose-built shipper for collecting system and service metrics and sending them to Elasticsearch, either directly or via Logstash. In the context of the Elastic Stack, it serves two related but distinct roles: general infrastructure/service metrics collection (CPU, memory, disk, per-service metrics for databases, web servers, etc.) and, as covered previously, the recommended mechanism for Stack Monitoring data collection.

### Core Architecture

**Key Points**
- Metricbeat runs as a lightweight agent, typically one per host, periodically polling configured modules and shipping the collected metrics to an output.
- Each module corresponds to a service or system component (`system`, `elasticsearch`, `kibana`, `docker`, `mysql`, `nginx`, and many others) and defines the specific metricsets it can collect.
- A metricset is a specific set of related metrics within a module — for example, the `system` module has metricsets like `cpu`, `memory`, `network`, `filesystem`, and `process`.
- Metricbeat ships as a single Go binary with no runtime dependencies, making deployment simple across hosts, containers, and orchestrated environments.

### Configuration Structure

```yaml
metricbeat.modules:
  - module: system
    metricsets: ["cpu", "memory", "network", "filesystem"]
    period: 10s

  - module: elasticsearch
    xpack.enabled: true
    period: 10s
    hosts: ["https://localhost:9200"]

output.elasticsearch:
  hosts: ["https://monitoring-es:9200"]
  username: "elastic"
  password: "changeme"
```

**Key Points**
- `period` controls how frequently a module's metricsets are collected; shorter periods give finer time resolution at the cost of higher data volume and collection overhead.
- `hosts` for a service module (like `elasticsearch`) points at the API endpoint of the service being monitored, which is distinct from `output.elasticsearch.hosts`, the destination the collected data is shipped to.
- Multiple modules can be configured in a single Metricbeat instance, and Metricbeat can also read module configuration from separate files under a `modules.d/` directory rather than one monolithic config.

### Diagram: Metricbeat Module and Metricset Structure

<svg width="100%" viewBox="0 0 680 320" role="img"><title>Metricbeat module and metricset structure (svg_diagram)</title><desc>A single Metricbeat instance runs multiple modules, each of which collects one or more metricsets, all shipped to a configured output.</desc>
<defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></marker></defs>

<g class="c-gray">
<rect x="40" y="30" width="600" height="220" rx="16" stroke-width="0.5" />
<text class="th" x="60" y="20" dominant-baseline="central">Metricbeat instance</text>
</g>

<g class="c-blue">
<rect x="70" y="60" width="170" height="170" rx="10" stroke-width="0.5" />
<text class="th" x="155" y="82" text-anchor="middle">system module</text>
<rect x="86" y="100" width="138" height="30" rx="6" fill="none" stroke="var(--b)" stroke-width="0.5" />
<text class="ts" x="155" y="115" text-anchor="middle">cpu</text>
<rect x="86" y="138" width="138" height="30" rx="6" fill="none" stroke="var(--b)" stroke-width="0.5" />
<text class="ts" x="155" y="153" text-anchor="middle">memory</text>
<rect x="86" y="176" width="138" height="30" rx="6" fill="none" stroke="var(--b)" stroke-width="0.5" />
<text class="ts" x="155" y="191" text-anchor="middle">filesystem</text>
</g>

<g class="c-teal">
<rect x="255" y="60" width="170" height="170" rx="10" stroke-width="0.5" />
<text class="th" x="340" y="82" text-anchor="middle">elasticsearch module</text>
<rect x="271" y="100" width="138" height="30" rx="6" fill="none" stroke="var(--b)" stroke-width="0.5" />
<text class="ts" x="340" y="115" text-anchor="middle">node_stats</text>
<rect x="271" y="138" width="138" height="30" rx="6" fill="none" stroke="var(--b)" stroke-width="0.5" />
<text class="ts" x="340" y="153" text-anchor="middle">index</text>
<rect x="271" y="176" width="138" height="30" rx="6" fill="none" stroke="var(--b)" stroke-width="0.5" />
<text class="ts" x="340" y="191" text-anchor="middle">cluster_stats</text>
</g>

<g class="c-coral">
<rect x="440" y="60" width="170" height="170" rx="10" stroke-width="0.5" />
<text class="th" x="525" y="82" text-anchor="middle">docker module</text>
<rect x="456" y="100" width="138" height="30" rx="6" fill="none" stroke="var(--b)" stroke-width="0.5" />
<text class="ts" x="525" y="115" text-anchor="middle">container</text>
<rect x="456" y="138" width="138" height="30" rx="6" fill="none" stroke="var(--b)" stroke-width="0.5" />
<text class="ts" x="525" y="153" text-anchor="middle">cpu</text>
<rect x="456" y="176" width="138" height="30" rx="6" fill="none" stroke="var(--b)" stroke-width="0.5" />
<text class="ts" x="525" y="191" text-anchor="middle">memory</text>
</g>

<line x1="340" y1="250" x2="340" y2="285" class="arr" marker-end="url(#arrow)" />
<g class="c-purple">
<rect x="240" y="285" width="200" height="30" rx="8" stroke-width="0.5" />
<text class="ts" x="340" y="300" text-anchor="middle" dominant-baseline="central">output.elasticsearch</text>
</g>
</svg>

### Autodiscover

**Key Points**
- Autodiscover allows Metricbeat to automatically detect and start monitoring containers or pods as they appear, particularly useful in Docker and Kubernetes environments where workloads are dynamic.
- Configured via hints (annotations/labels on containers or pods) or templates (conditions matching container metadata to a specific module configuration).
- This avoids the need to manually reconfigure Metricbeat every time a new service instance is deployed or removed in an orchestrated environment.

```yaml
metricbeat.autodiscover:
  providers:
    - type: kubernetes
      hints.enabled: true
```

### Metricbeat vs. Beats Family Context

[Inference] Within the broader Beats family, Metricbeat's role is specifically periodic metric polling, distinct from Filebeat (log file shipping), Packetbeat (network traffic analysis), Heartbeat (uptime/availability probing), and Winlogbeat (Windows event log shipping) — a full observability setup for a stack often runs several Beats together, each responsible for its own data type, rather than one Beat covering everything.

### Elastic Agent as an Alternative

**Key Points**
- Elastic Agent is a newer, unified agent that can perform the functions of multiple individual Beats (including Metricbeat's metric collection) under a single managed process, configured centrally through Fleet in Kibana rather than per-host YAML files.
- [Unverified] Whether to use standalone Metricbeat or Elastic Agent for new deployments depends on organizational preference for centralized fleet management versus direct per-host configuration control, and Elastic's own guidance on this has evolved over time, so current product documentation should be checked for the currently recommended path for new deployments.
- Existing Metricbeat deployments continue to be supported as a valid collection method regardless of Elastic Agent's availability.

### Sizing and Resource Impact

**Key Points**
- Metricbeat itself is lightweight, but the cumulative effect of many hosts each shipping metrics at short intervals can produce substantial index volume on the receiving cluster, particularly with many modules and metricsets enabled at short periods.
- Longer collection periods reduce both Metricbeat's own resource footprint and the volume of data indexed, trading off time-resolution granularity for reduced overhead.
- Dedicated monitoring/observability clusters receiving Metricbeat data benefit from the same ILM-based retention management as any other high-volume time-series data, to prevent unbounded growth.

### Related Topics

- **Filebeat** for log file shipping, often deployed alongside Metricbeat on the same hosts
- **Elastic Agent and Fleet** as the centrally managed alternative to standalone Beats
- **Processors in Beats** (`add_host_metadata`, `add_cloud_metadata`, `drop_fields`) for enriching or filtering data before shipping
- **Kubernetes and Docker autodiscover** configuration in depth, including hints-based vs template-based approaches
- **Ingest pipelines** as a place to further process Beats data after it arrives at the receiving cluster
- **Beats output configuration options** beyond direct Elasticsearch output, including Logstash and Kafka as intermediate buffers