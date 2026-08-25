## Downsampling Time Series Data

### Overview

Downsampling is the process of reducing the storage footprint of time series data by aggregating raw, high-resolution documents into coarser-grained summary documents over fixed time intervals. Rather than retaining every individual metric sample indefinitely, downsampling replaces older data with statistical rollups (min, max, sum, average, value count) at a reduced time resolution, trading query granularity for significantly lower storage cost.

This is primarily applicable to **Time Series Data Streams (TSDS)**, since downsampling relies on the dimension/metric field type distinctions that TSDS enforces.

### Why Downsample

Raw metrics data — CPU usage sampled every 10 seconds, for instance — is valuable at full resolution for recent troubleshooting, but that resolution is rarely needed once the data is weeks or months old. Downsampling addresses this by:

- Reducing document count by orders of magnitude for older data.
- Preserving statistical shape (min/max/avg/sum) needed for long-range trend analysis and dashboards.
- Lowering storage and, indirectly, query cost for historical ranges.
- Fitting naturally into a hot-warm-cold tiering strategy, where downsampling typically occurs on the transition into warm or cold phases.

### Prerequisites: Dimensions and Metrics

Downsampling depends on fields being explicitly typed as either:

- **Dimensions** (`time_series_dimension: true`) — fields that identify the source of a metric, such as `host.name`, `pod.id`, or `region`. Dimensions form the identity used to group raw samples before aggregation.
- **Metrics** (`time_series_metric` set to `gauge`, `counter`, or `summary`) — the numeric values being tracked, such as `cpu.usage.percent` or `network.bytes.sent`.

During downsampling, documents sharing the same dimension values within a given time bucket are collapsed into a single summary document, with each metric field replaced by aggregated statistics appropriate to its metric type.

### Metric Type Aggregation Behavior

| Metric Type | Aggregation Applied on Downsample |
|---|---|
| `gauge` | min, max, sum, value_count are retained as an aggregate object |
| `counter` | Last (or equivalent monotonic-preserving) value retained, since counters are cumulative |
| `summary` | Pre-aggregated statistics are merged as applicable |

Querying a downsampled field returns the aggregate structure rather than a single raw value, and aggregations run against it must be aggregation-type-aware (e.g., using the appropriate sub-aggregation to extract min/max/avg from a downsampled gauge).

### The Downsampling Process

Downsampling operates on a backing index as a whole, producing a new, separate read-only index at the reduced resolution — it does not mutate the original index in place. The general flow:

1. A backing index becomes eligible for downsampling, typically once it is no longer the write index and has rolled over.
2. A downsampling interval is specified (e.g., `1h`, `1d`) representing the new bucket resolution.
3. Elasticsearch creates a new index containing one summary document per unique dimension combination per interval bucket.
4. The new downsampled index replaces the original within the data stream's backing indices, and the original raw-resolution index is typically deleted once the transition completes.

### Triggering Downsampling

Downsampling is generally configured as part of an **ILM policy phase action**, most commonly attached to the warm or cold phase:

```
PUT _ilm/policy/metrics-policy
{
  "policy": {
    "phases": {
      "hot": {
        "actions": {
          "rollover": { "max_age": "1d" }
        }
      },
      "warm": {
        "min_age": "7d",
        "actions": {
          "downsample": {
            "fixed_interval": "1h"
          }
        }
      }
    }
  }
}
```

This example rolls data over daily in the hot phase, then downsamples to hourly resolution once an index reaches seven days of age and transitions to warm. [Inference: exact ILM action syntax and default behaviors may differ slightly by version — verify against current documentation before deploying.]

Downsampling can also be invoked manually via the `_downsample` API against a specific backing index, useful for one-off historical data reduction or testing a policy before automating it.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 300">
  <text x="400" y="28" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Downsampling Flow (svg_diagram)</text>

  <rect x="40" y="70" width="220" height="90" rx="6" fill="#e8f0fe" stroke="#4285f4" stroke-width="2" />
  <text x="150" y="95" text-anchor="middle" font-size="12" fill="#1a1a1a">Raw backing index</text>
  <text x="150" y="112" text-anchor="middle" font-size="11" fill="#555">10s resolution</text>
  <text x="150" y="129" text-anchor="middle" font-size="11" fill="#555">host, pod dimensions</text>
  <text x="150" y="146" text-anchor="middle" font-size="11" fill="#555">cpu.usage gauge metric</text>

  <line x1="270" y1="115" x2="340" y2="115" stroke="#999" stroke-width="1.5" marker-end="url(#arr3)" />
  <text x="305" y="105" text-anchor="middle" font-size="10" fill="#4285f4">downsample</text>
  <text x="305" y="135" text-anchor="middle" font-size="10" fill="#4285f4">1h interval</text>

  <rect x="345" y="70" width="220" height="90" rx="6" fill="#e6f4ea" stroke="#34a853" stroke-width="2" />
  <text x="455" y="95" text-anchor="middle" font-size="12" fill="#1a1a1a">Downsampled index</text>
  <text x="455" y="112" text-anchor="middle" font-size="11" fill="#555">1h resolution</text>
  <text x="455" y="129" text-anchor="middle" font-size="11" fill="#555">same dimensions</text>
  <text x="455" y="146" text-anchor="middle" font-size="11" fill="#555">cpu.usage {min,max,sum,count}</text>

  <line x1="565" y1="115" x2="630" y2="115" stroke="#999" stroke-width="1.5" marker-end="url(#arr3)" />
  <text x="597" y="105" text-anchor="middle" font-size="10" fill="#777">replaces</text>

  <rect x="635" y="80" width="130" height="70" rx="6" fill="#f1f3f4" stroke="#999" stroke-width="1.5" />
  <text x="700" y="105" text-anchor="middle" font-size="11" fill="#333">Data stream</text>
  <text x="700" y="122" text-anchor="middle" font-size="11" fill="#333">backing index</text>
  <text x="700" y="139" text-anchor="middle" font-size="10" fill="#777">(warm/cold tier)</text>

  <text x="400" y="220" text-anchor="middle" font-size="12" fill="#555">The original raw-resolution index is not modified in place —</text>
  <text x="400" y="238" text-anchor="middle" font-size="12" fill="#555">a new downsampled index is created and swapped into the data stream,</text>
  <text x="400" y="256" text-anchor="middle" font-size="12" fill="#555">and the raw index is deleted once the swap completes.</text>
</svg>

### Multi-Stage Downsampling

ILM supports chaining multiple downsampling actions across successive phases, progressively coarsening resolution as data ages further — for example, hourly resolution in the warm phase, then daily resolution in the cold phase. Each stage downsamples from the previous stage's already-downsampled index rather than from the original raw data, since the raw index no longer exists at that point.

### Querying Across Mixed Resolutions

A data stream can contain backing indices at different resolutions simultaneously — recent raw-resolution indices alongside older downsampled ones. Elasticsearch's query layer is designed to handle this transparently for standard aggregations, though:

- Applications performing precise point-in-time lookups on historical data should be aware that only aggregate statistics, not individual raw samples, are available once data has been downsampled.
- Dashboards and visualizations built on aggregations (e.g., average CPU over time) generally continue to function correctly across the resolution boundary, since the aggregation framework understands how to combine raw and pre-aggregated metric values. [Inference: seamless cross-resolution aggregation behavior can have edge cases depending on aggregation type and version — worth validating for specific dashboard queries.]

### Limitations and Considerations

- Downsampling is irreversible — once raw-resolution data is replaced, the original per-sample values cannot be recovered from the downsampled index.
- Only applicable to indices structured as time series (TSDS with dimension/metric field typing); standard data streams without this structure are not eligible for downsampling.
- Downsampled indices are read-only; they cannot receive further writes.
- Choosing interval size involves a tradeoff — coarser intervals save more storage but discard more granularity, and this choice should be driven by actual query patterns (e.g., no dashboard ever needs sub-hourly resolution beyond 30 days).

### Key Points

- Downsampling aggregates raw time series samples into coarser statistical summaries to reduce storage.
- Requires TSDS with fields typed as dimensions and metrics.
- Produces a new read-only index; does not modify the original in place.
- Typically automated via ILM phase actions (commonly warm or cold phase).
- Irreversible — raw per-sample data is lost once downsampling completes and the original index is deleted.

### Related Topics

- Time Series Data Streams (TSDS) and dimension/metric field types
- ILM phases and the downsample action
- Hot-warm-cold-frozen tiering architecture
- Aggregations over gauge, counter, and summary metric types
- Data retention strategy for observability workloads
- The `_downsample` API for manual invocation