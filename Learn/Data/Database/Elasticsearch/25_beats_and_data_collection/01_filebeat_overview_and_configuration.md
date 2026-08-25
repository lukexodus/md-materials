## Filebeat Overview and Configuration

### Overview

Filebeat is the Beats family member purpose-built for shipping log files. It tails files on disk, tracks read position so it can resume after a restart without re-sending or losing lines, and forwards log data — optionally structured through its own light processing or a downstream ingest pipeline — to Elasticsearch or Logstash.

### Core Architecture

**Key Points**
- Filebeat runs as a lightweight agent, typically one per host, and uses **inputs** to define what to read (file paths, containers, syslog, etc.) and **modules** to provide pre-built parsing configuration for common log formats.
- Internally, Filebeat tracks file state (inode, offset read so far) in a local registry, which is what allows it to resume tailing exactly where it left off after a restart rather than re-reading entire files.
- Like Metricbeat, Filebeat ships as a single Go binary with no runtime dependencies, and can output to Elasticsearch directly, to Logstash for further processing, or to Kafka as an intermediate buffer.

### Basic Configuration Structure

```yaml
filebeat.inputs:
  - type: filestream
    id: app-logs
    enabled: true
    paths:
      - /var/log/myapp/*.log

output.elasticsearch:
  hosts: ["https://es-node:9200"]
  username: "elastic"
  password: "changeme"
```

**Key Points**
- `filestream` is the modern input type for tailing plain log files, having succeeded the older `log` input type.
- `id` uniquely identifies an input within Filebeat's registry, and is required for `filestream` inputs so file state tracking can be correctly associated with that specific input's configuration.
- `paths` accepts glob patterns, and Filebeat continuously watches the matching directory for new files matching the pattern as well as tailing existing ones.

### Diagram: Filebeat Read and Ship Flow

<svg width="100%" viewBox="0 0 680 280" role="img"><title>Filebeat log file reading and shipping flow (svg_diagram)</title><desc>Filebeat tails log files on disk, tracks read position in a local registry, and ships new lines to an output such as Elasticsearch or Logstash.</desc>
<defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></marker></defs>

<g class="node c-gray">
<rect x="40" y="30" width="160" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="120" y="50" text-anchor="middle" dominant-baseline="central">Log files on disk</text>
<text class="ts" x="120" y="70" text-anchor="middle" dominant-baseline="central">/var/log/myapp/*.log</text>
</g>

<line x1="200" y1="58" x2="240" y2="58" class="arr" marker-end="url(#arrow)" />

<g class="node c-blue">
<rect x="240" y="30" width="160" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="320" y="50" text-anchor="middle" dominant-baseline="central">Filestream input</text>
<text class="ts" x="320" y="70" text-anchor="middle" dominant-baseline="central">Tails new lines</text>
</g>

<line x1="320" y1="86" x2="320" y2="120" class="arr" marker-end="url(#arrow)" />

<g class="node c-teal">
<rect x="220" y="120" width="200" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="320" y="140" text-anchor="middle" dominant-baseline="central">Local registry</text>
<text class="ts" x="320" y="160" text-anchor="middle" dominant-baseline="central">Tracks inode, offset</text>
</g>

<line x1="400" y1="58" x2="460" y2="58" class="arr" marker-end="url(#arrow)" />

<g class="node c-coral">
<rect x="460" y="30" width="180" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="550" y="50" text-anchor="middle" dominant-baseline="central">Output</text>
<text class="ts" x="550" y="70" text-anchor="middle" dominant-baseline="central">Elasticsearch or Logstash</text>
</g>

<text class="ts" x="320" y="220" text-anchor="middle">Registry state lets Filebeat resume exactly</text>
<text class="ts" x="320" y="236" text-anchor="middle">where it left off after a restart</text>
</svg>

### Modules

**Key Points**
- Filebeat modules provide pre-built configuration for common log sources — `nginx`, `apache`, `system`, `mysql`, `postgresql`, and many others — bundling the correct file paths, ingest pipeline for parsing, and index template in one enabled module.
- Enabling a module via `filebeat modules enable nginx` avoids manually writing grok patterns and field mappings for well-known, standard log formats.
- Modules typically ship an accompanying ingest pipeline that gets automatically loaded into Elasticsearch, handling the structuring work (parsing timestamps, splitting fields) so raw log lines arrive as structured documents.

```
filebeat modules enable nginx
filebeat setup --pipelines --modules nginx
```

### Multiline Handling

**Key Points**
- Log entries that span multiple physical lines (most commonly stack traces) need explicit multiline configuration, or each line of the stack trace becomes its own separate, incorrectly split document.
- Multiline grouping is configured with a pattern that identifies the start of a new logical entry (e.g., a line beginning with a timestamp), and all subsequent lines not matching that pattern are appended to the current entry until the next match.

```yaml
filebeat.inputs:
  - type: filestream
    id: app-logs
    paths:
      - /var/log/myapp/*.log
    parsers:
      - multiline:
          type: pattern
          pattern: '^\d{4}-\d{2}-\d{2}'
          negate: true
          match: after
```

- `negate: true` combined with `match: after` means "lines that do NOT match the timestamp pattern belong to (are appended after) the previous line that did match" — the standard configuration for appending stack trace lines to their originating log entry.

### Processors

**Key Points**
- Filebeat supports lightweight processors (distinct from, but conceptually similar to, Elasticsearch ingest pipeline processors) that run client-side before shipping, such as `add_host_metadata`, `add_cloud_metadata`, `drop_fields`, and `dissect`.
- Doing lightweight filtering or field-dropping at the Filebeat level, before data leaves the host, reduces network transfer and downstream processing load compared to shipping unneeded data and filtering it out later in an ingest pipeline.

```yaml
processors:
  - add_host_metadata: ~
  - drop_fields:
      fields: ["agent.ephemeral_id"]
```

### Autodiscover for Containerized Environments

As with Metricbeat, Filebeat supports autodiscover for Docker and Kubernetes, automatically starting to tail a container's logs as soon as it starts, using hints or templates to determine which parsing configuration applies to which container, without manual per-container configuration.

```yaml
filebeat.autodiscover:
  providers:
    - type: kubernetes
      hints.enabled: true
```

### Backpressure and At-Least-Once Delivery

**Key Points**
- Filebeat only advances its registry offset for a given file after the output has acknowledged successful delivery, giving it an at-least-once delivery guarantee similar in spirit to Logstash's persistent queue acknowledgment model (covered previously).
- If the configured output is unavailable, Filebeat applies backpressure, pausing reads rather than dropping log lines, and resumes from the last acknowledged offset once the output becomes available again.

### Related Topics

- **Filebeat modules in depth** — full list of supported services and their bundled ingest pipelines
- **Multiline pattern configuration** for other common formats (Java stack traces, JSON-per-line multi-field logs)
- **Filebeat autodiscover** hints-based vs. template-based configuration in depth
- **Metricbeat** (earlier topic) as the metrics-focused counterpart often deployed alongside Filebeat
- **Elastic Agent and Fleet** as the unified alternative to standalone Filebeat deployment
- **Ingest pipelines** (earlier topics) as the typical downstream structuring step for Filebeat-shipped log data