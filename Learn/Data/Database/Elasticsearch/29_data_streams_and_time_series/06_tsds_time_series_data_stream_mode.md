## TSDS (Time Series Data Stream) Mode

### Overview

Time Series Data Stream (TSDS) mode is a specialized configuration of the data stream abstraction, purpose-built for metrics data. It introduces a distinct index mode (`time_series`) that changes how documents are organized, stored, sorted, and deduplicated internally, enabling better compression and unlocking capabilities like downsampling that are unavailable to standard data streams.

### How TSDS Differs from a Standard Data Stream

A standard data stream treats documents as an unordered append-only sequence within each backing index, sorted only by insertion order (with `@timestamp` as a queryable field but not a structural organizing principle at the storage layer). TSDS changes this model:

- Documents are internally sorted by a composite of **dimension fields** and `@timestamp`, rather than by ingestion order
- A synthetic, deterministic document identifier (`_tsid`) is derived from the combination of dimension field values, rather than relying on an auto-generated or externally supplied `_id`
- This sorting and identity structure is what enables efficient columnar compression and, later, downsampling

### Required Index Setting

TSDS is activated by setting `index.mode` to `time_series` in the index template.

```json
PUT /_index_template/metrics-cpu-template
{
  "index_patterns": ["metrics-cpu-*"],
  "data_stream": {},
  "template": {
    "settings": {
      "index.mode": "time_series"
    }
  }
}
```

### Dimension Fields

Dimension fields identify the entity or source a metric describes — they are the "grouping" or "label" fields, analogous to tags/labels in other metrics systems (e.g., Prometheus labels). They must be mapped with `time_series_dimension: true` and are restricted to specific field types.

```json
{
  "mappings": {
    "properties": {
      "host.name": { "type": "keyword", "time_series_dimension": true },
      "region": { "type": "keyword", "time_series_dimension": true },
      "cpu.usage": { "type": "double", "time_series_metric": "gauge" }
    }
  }
}
```

- Dimension fields are typically `keyword`, numeric, or `ip` types [Unverified — exact supported type list should be confirmed against the deployed version]
- The combination of all dimension field values on a document determines its `_tsid` — documents sharing the same dimension values across time form a logical "time series" for that entity
- Dimension field values are expected to be effectively immutable per entity over time (e.g., `host.name` for a given host doesn't change), since they define series identity

### Metric Fields

Metric fields hold the actual measured values and are mapped with a `time_series_metric` type indicating how the value should be interpreted for aggregation purposes.

| `time_series_metric` value | Meaning |
| --- | --- |
| `gauge` | A value that can arbitrarily go up or down (e.g., CPU usage, memory used) |
| `counter` | A monotonically increasing value (e.g., total requests served, bytes sent) |
| `summary` | A pre-aggregated summary value (e.g., already-computed percentiles) [Unverified — exact semantics/support may vary by version] |

```json
{
  "cpu.usage": { "type": "double", "time_series_metric": "gauge" },
  "http.requests.total": { "type": "long", "time_series_metric": "counter" }
}
```

This classification informs how downsampling and certain aggregations treat the field — for instance, a `counter` field's rate of change is often more meaningful than its raw value, while a `gauge`'s min/max/avg over an interval is directly meaningful.

### The `_tsid` Field

Every document in a TSDS is assigned a `_tsid`, computed deterministically from its dimension field values. Documents with identical dimension values across different timestamps share the same `_tsid`, effectively forming one logical time series.

- `_tsid` is not manually set — it is derived automatically at index time from the mapped dimension fields
- It underpins the internal sort order (by `_tsid`, then `@timestamp`) that TSDS relies on for compression efficiency and downsampling correctness

### Index-Time Sorting and Storage Benefits

Because documents are physically organized by dimension-then-time rather than arbitrary ingestion order, TSDS achieves higher compression ratios than a standard data stream storing equivalent metric data [Unverified — exact compression improvement is workload-dependent and not a fixed guaranteed figure]. This is one of the primary motivations for using TSDS mode over a standard data stream for metrics workloads, alongside enabling downsampling.

### Time-Bound Backing Indices

TSDS backing indices are created with an explicit time range (`index.time_series.start_time` / `index.time_series.end_time`), rather than being open-ended like standard data stream backing indices. Documents with a `@timestamp` outside a backing index's configured time range are rejected at index time, which is a departure from standard data streams where the write index simply accepts whatever is sent to it [Unverified — exact rejection/routing behavior for out-of-range timestamps should be confirmed against the deployed version, as this affects how out-of-order or late-arriving metrics are handled].

### TSDS vs. Standard Data Stream (Comparison)

| Aspect | Standard Data Stream | TSDS |
| --- | --- | --- |
| `index.mode` | `standard` (default) | `time_series` |
| Document sort order | Ingestion order | Dimension fields + `@timestamp` |
| Document identity | `_id` (auto or supplied) | `_tsid` (derived from dimensions) |
| Requires dimension/metric mapping | No | Yes |
| Downsampling support | No | Yes |
| Compression efficiency for metrics | Standard | Typically higher |
| Backing index time bounds | Open-ended | Explicit start/end time per index |
| Typical use case | Logs, traces, general events | Metrics |

### Example: Full TSDS Template

```json
PUT /_index_template/metrics-cpu-template
{
  "index_patterns": ["metrics-cpu-*"],
  "data_stream": {},
  "template": {
    "settings": {
      "index.mode": "time_series",
      "index.lifecycle.name": "metrics-ilm-policy"
    },
    "mappings": {
      "properties": {
        "@timestamp": { "type": "date" },
        "host.name": { "type": "keyword", "time_series_dimension": true },
        "cpu.usage": { "type": "double", "time_series_metric": "gauge" },
        "cpu.total_ticks": { "type": "long", "time_series_metric": "counter" }
      }
    }
  }
}
```

### Querying a TSDS

Search and aggregation syntax against a TSDS is the same as any other data stream or index — `time_series_dimension`/`time_series_metric` mappings do not change the query DSL, only the internal storage and what downstream capabilities (like downsampling) become available.

```json
GET /metrics-cpu-prod/_search
{
  "size": 0,
  "query": {
    "range": { "@timestamp": { "gte": "now-1h" } }
  },
  "aggs": {
    "by_host": {
      "terms": { "field": "host.name" },
      "aggs": {
        "avg_cpu": { "avg": { "field": "cpu.usage" } }
      }
    }
  }
}
```

### Common Pitfalls

- Marking a high-cardinality, frequently changing field as `time_series_dimension`, which fragments series identity and undermines both compression and downsampling effectiveness
- Omitting `time_series_metric` on numeric fields intended for aggregation, missing out on TSDS-aware handling of those fields
- Assuming TSDS backing indices behave like standard ones for out-of-time-range document ingestion — late or out-of-order data may be rejected rather than silently accepted [Unverified]
- Converting an existing standard data stream to TSDS in place — this is not a supported in-place operation; migration typically requires reindexing into a new TSDS-mode data stream [Unverified — confirm current migration tooling/support for the deployed version]

### Diagram: TSDS Document Organization

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 740 320">
\<style\>
.title { font: bold 14px sans-serif; fill: #1a1a1a; }
.label { font: 12px sans-serif; fill: #1a1a1a; }
.sub { font: 11px sans-serif; fill: #555; }
.box { fill: #eef3fb; stroke: #4a6fa5; stroke-width: 1.5; }
.boxA { fill: #eefbee; stroke: #4a9a5a; stroke-width: 1.5; }
.boxB { fill: #fbf6ee; stroke: #a5854a; stroke-width: 1.5; }
.arrow { stroke: #333; stroke-width: 1.5; marker-end: url(#arrow6); }
\</style\>
<text x="20" y="25" class="title">TSDS Grouping by _tsid (svg_diagram)</text>

<text x="30" y="55" class="sub">Incoming documents (unordered arrival):</text>

<rect x="30" y="65" width="220" height="30" rx="3" class="box" />

<text x="140" y="85" class="label" text-anchor="middle">host=web-1, t=00:01, cpu=42</text>

<rect x="30" y="100" width="220" height="30" rx="3" class="box" />

<text x="140" y="120" class="label" text-anchor="middle">host=web-2, t=00:01, cpu=38</text>

<rect x="30" y="135" width="220" height="30" rx="3" class="box" />

<text x="140" y="155" class="label" text-anchor="middle">host=web-1, t=00:02, cpu=44</text>

<rect x="30" y="170" width="220" height="30" rx="3" class="box" />

<text x="140" y="190" class="label" text-anchor="middle">host=web-2, t=00:02, cpu=39</text>

<line x1="250" y1="80" x2="420" y2="80" class="arrow" />
<line x1="250" y1="150" x2="420" y2="80" class="arrow" />
<line x1="250" y1="115" x2="420" y2="180" class="arrow" />
<line x1="250" y1="185" x2="420" y2="180" class="arrow" />

<text x="430" y="55" class="sub">Reorganized internally by _tsid:</text>

<rect x="430" y="65" width="280" height="55" rx="3" class="boxA" />

<text x="570" y="85" class="label" text-anchor="middle" font-weight="bold">_tsid: host=web-1</text>

<text x="570" y="103" class="sub" text-anchor="middle">t=00:01 (cpu=42), t=00:02 (cpu=44)</text>

<rect x="430" y="150" width="280" height="55" rx="3" class="boxB" />
<text x="570" y="170" class="label" text-anchor="middle" font-weight="bold">_tsid: host=web-2</text>
<text x="570" y="188" class="sub" text-anchor="middle">t=00:01 (cpu=38), t=00:02 (cpu=39)</text>

<text x="30" y="240" class="sub">Grouping by dimension + time enables higher compression and per-series downsampling</text>

</svg>

**Related Topics**

- Downsampling time series data (built directly on TSDS)
- Dimension field cardinality and its effect on compression
- Index Lifecycle Management (ILM) for metrics retention
- Metrics ingestion via Elastic Agent / OpenTelemetry integrations
- `_tsid` internals and series-based aggregation performance
- Migrating existing metrics indices into TSDS mode