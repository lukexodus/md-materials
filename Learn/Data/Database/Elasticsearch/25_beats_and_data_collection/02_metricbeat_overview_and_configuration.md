## Metricbeat Overview and Configuration

### Overview

This topic covers Metricbeat's core configuration mechanics in depth as a standalone reference, complementing the earlier discussion of Metricbeat in the context of Stack Monitoring. Metricbeat's fundamental job is periodic polling: on a defined schedule, it queries configured modules for their metrics and ships the results to an output.

### Basic Configuration Structure

```yaml
metricbeat.modules:
  - module: system
    metricsets: ["cpu", "memory", "network", "process", "filesystem"]
    period: 10s
    processes: ["logstash", "elasticsearch"]

output.elasticsearch:
  hosts: ["https://es-node:9200"]
  username: "elastic"
  password: "changeme"
```

**Key Points**
- `module` selects which service or system component's metrics to collect; `metricsets` selects which specific metric groups within that module to enable.
- `period` sets the polling interval independently per module block, so different modules can be collected at different frequencies within the same Metricbeat instance.
- `processes` (specific to the `system` module's `process` metricset) filters which running processes get per-process metrics collected, rather than collecting metrics for every process on the host.

### `modules.d` Directory Structure

**Key Points**
- Rather than one large `metricbeat.yml` with every module inline, Metricbeat supports splitting module configuration into individual files under `modules.d/`, each named after its module (e.g., `system.yml`, `elasticsearch.yml`).
- Modules are enabled or disabled by renaming their file between a `.yml` and `.yml.disabled` extension, or via the `metricbeat modules enable`/`disable` CLI commands.
- This structure keeps configuration manageable when many modules are in use and mirrors the same `modules.d` pattern used by Filebeat.

```
metricbeat modules enable elasticsearch kibana logstash
metricbeat modules disable mysql
```

### Diagram: Metricbeat Polling Cycle

<svg width="100%" viewBox="0 0 680 280" role="img"><title>Metricbeat periodic polling cycle (svg_diagram)</title><desc>On each configured period, Metricbeat queries every enabled module for its metricsets, packages the results into events, and ships them to the configured output.</desc>
<defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></marker></defs>

<g class="node c-gray">
<rect x="270" y="20" width="140" height="44" rx="8" stroke-width="0.5" />
<text class="th" x="340" y="42" text-anchor="middle" dominant-baseline="central">Timer tick</text>
</g>

<line x1="340" y1="64" x2="340" y2="100" class="arr" marker-end="url(#arrow)" />

<g class="node c-blue">
<rect x="240" y="100" width="200" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="340" y="118" text-anchor="middle" dominant-baseline="central">Poll enabled modules</text>
<text class="ts" x="340" y="138" text-anchor="middle" dominant-baseline="central">Per configured period</text>
</g>

<line x1="340" y1="156" x2="340" y2="190" class="arr" marker-end="url(#arrow)" />

<g class="node c-teal">
<rect x="240" y="190" width="200" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="340" y="208" text-anchor="middle" dominant-baseline="central">Package events</text>
<text class="ts" x="340" y="228" text-anchor="middle" dominant-baseline="central">One per metricset result</text>
</g>

<line x1="340" y1="246" x2="340" y2="256" class="arr" />
<text class="ts" x="500" y="150" text-anchor="middle">Repeats on</text>
<text class="ts" x="500" y="166" text-anchor="middle">next tick</text>
<line class="leader" x1="440" y1="128" x2="470" y2="150" />
</svg>

### Fields and Tags

**Key Points**
- Custom `fields` can be added to every event Metricbeat ships, useful for tagging events with environment, team, or deployment identifiers not otherwise present in the collected metric data.
- `tags` provide a simpler list-based labeling mechanism for the same general purpose, commonly used for filtering in Kibana.
- `fields_under_root: true` places custom fields at the top level of the event document rather than nested under a `fields` object, which affects how they're queried afterward.

```yaml
fields:
  environment: production
  team: platform
fields_under_root: true
tags: ["critical", "customer-facing"]
```

### Index Lifecycle Management Integration

**Key Points**
- Metricbeat can automatically set up an ILM policy and matching index template for its own indices on first run, applying sensible defaults for rollover and retention without manual index template authoring.
- This default setup can be customized or disabled via `setup.ilm.*` settings when an organization wants to apply its own retention policy instead of Metricbeat's built-in default.

```yaml
setup.ilm.enabled: true
setup.ilm.rollover_alias: "metricbeat"
setup.ilm.policy_name: "metricbeat-policy"
```

### Lightweight vs. Deep Modules

**Key Points**
- Some modules (like `system`) collect metrics directly from OS-level interfaces with minimal overhead.
- Other modules (like `elasticsearch`, `kibana`, or database modules) query the target service's own API or protocol, meaning their overhead and the load they place on the monitored service depend on how expensive those underlying API calls are, not just on Metricbeat's own resource usage.
- [Inference] For modules querying a monitored service's API at short periods, particularly on already-loaded production services, the polling frequency should be weighed against the added load those API calls themselves introduce on the monitored service, not just against Metricbeat's own footprint.

### Dashboards

Metricbeat modules typically ship with pre-built Kibana dashboards that can be loaded via `metricbeat setup --dashboards`, providing an immediately usable visualization for that module's collected metrics without needing to build custom Kibana visualizations from scratch as a first step.

```
metricbeat setup --dashboards
```

### Testing Configuration

**Key Points**
- `metricbeat test config` validates configuration file syntax without starting the full agent.
- `metricbeat test output` verifies connectivity to the configured output (e.g., that the Elasticsearch host is reachable and credentials are valid) before running in production.
- `metricbeat test modules` checks whether enabled modules can successfully connect to and query their target services, catching misconfiguration (wrong host, bad credentials) before deployment.

```
metricbeat test config
metricbeat test output
metricbeat test modules
```

### Related Topics

- **Metricbeat for monitoring** (earlier topic) — its specific role in Stack Monitoring data collection
- **Filebeat overview and configuration** (previous topic) — the parallel configuration model for log shipping
- **Kubernetes and Docker autodiscover** in depth for dynamic environments
- **Processors shared across Beats** (`add_host_metadata`, `add_cloud_metadata`, `drop_fields`, `dissect`)
- **Elastic Agent and Fleet** as the centrally managed alternative to standalone Metricbeat configuration
- **ILM policy customization** for Metricbeat-collected data retention beyond the built-in default