## Datafeed Configuration

### Overview

A datafeed is the mechanism by which Elasticsearch's machine learning (ML) anomaly detection jobs retrieve data to analyze. A datafeed periodically queries a specified index or data stream, pulls matching documents within a time window, and feeds them into the associated anomaly detection job for processing. Every real-time (as opposed to purely batch/file-based) anomaly detection job requires an associated datafeed to supply it with data.

### Relationship to Anomaly Detection Jobs

A datafeed and an anomaly detection job have a one-to-one relationship at creation, though the underlying wiring is:

- The **job** defines what to analyze — detectors, bucket span, influencers, and the analysis configuration.
- The **datafeed** defines where the data comes from — source indices, the query used to filter documents, and the timing/interval of retrieval.

The datafeed does not perform analysis itself; it is purely responsible for sourcing and shaping the data stream that the job consumes.

### Core Configuration Fields

A datafeed configuration includes:

- **`datafeed_id`** — a unique identifier for the datafeed.
- **`job_id`** — the anomaly detection job this datafeed feeds.
- **`indices`** — one or more index names, index patterns, or data stream names to query.
- **`query`** — a standard Elasticsearch DSL query used to filter which documents are retrieved (defaults to `match_all` if unspecified).
- **`frequency`** — how often the datafeed checks for and processes new data.
- **`scroll_size`** — the batch size used when pulling documents from the source (analogous to `size` in scroll/search-after operations).
- **`query_delay`** — a buffer added before querying for the latest interval, to account for indexing latency (ensuring recently indexed documents have settled before being queried).

### Example Configuration

```
PUT _ml/datafeeds/datafeed-high-cpu
{
  "job_id": "high-cpu-job",
  "indices": ["metrics-system.cpu-*"],
  "query": {
    "bool": {
      "filter": [
        { "term": { "host.name": "web-01" } }
      ]
    }
  },
  "frequency": "1m",
  "query_delay": "60s"
}
```

This configuration feeds the `high-cpu-job` anomaly detection job with documents from indices matching `metrics-system.cpu-*`, filtered to a specific host, checking for new data every minute with a 60-second delay buffer.

### Aggregations Within Datafeeds

Datafeeds can use aggregations rather than raw document retrieval, which is often preferable for high-volume metrics data:

- Instead of streaming every raw document into the job, the datafeed can retrieve pre-aggregated buckets (e.g., average CPU per minute per host).
- This significantly reduces the volume of data the ML job must process, improving both performance and, in many cases, the statistical stability of the anomaly detection model.
- The aggregation's date histogram interval typically should align with the job's configured `bucket_span`.

```
PUT _ml/datafeeds/datafeed-agg-example
{
  "job_id": "avg-cpu-job",
  "indices": ["metrics-system.cpu-*"],
  "aggregations": {
    "buckets": {
      "date_histogram": {
        "field": "@timestamp",
        "fixed_interval": "5m"
      },
      "aggregations": {
        "avg_cpu": {
          "avg": { "field": "cpu.usage.percent" }
        }
      }
    }
  }
}
```

### Query Delay and Real-Time Considerations

Because data streams and indices may have documents arrive slightly out of order or with ingest latency, `query_delay` exists to avoid the datafeed querying for a time bucket before all relevant documents have actually landed. Setting this too low risks the job analyzing incomplete buckets; setting it too high delays anomaly detection results unnecessarily. [Inference: appropriate values are workload-dependent and typically tuned based on observed ingest latency in a given deployment.]

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 260">
  <text x="400" y="26" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Datafeed to Job Flow (svg_diagram)</text>

  <rect x="40" y="60" width="180" height="60" rx="6" fill="#e8f0fe" stroke="#4285f4" stroke-width="2" />
  <text x="130" y="85" text-anchor="middle" font-size="12" fill="#1a1a1a">Source index /</text>
  <text x="130" y="102" text-anchor="middle" font-size="12" fill="#1a1a1a">data stream</text>

  <line x1="220" y1="90" x2="290" y2="90" stroke="#999" stroke-width="1.5" marker-end="url(#arr5)" />
  <text x="255" y="80" text-anchor="middle" font-size="10" fill="#555">query</text>

  <rect x="295" y="55" width="200" height="70" rx="6" fill="#f1f3f4" stroke="#999" stroke-width="1.5" />
  <text x="395" y="78" text-anchor="middle" font-size="12" fill="#333">Datafeed</text>
  <text x="395" y="95" text-anchor="middle" font-size="10" fill="#777">query, frequency,</text>
  <text x="395" y="110" text-anchor="middle" font-size="10" fill="#777">query_delay, aggs</text>

  <line x1="495" y1="90" x2="565" y2="90" stroke="#999" stroke-width="1.5" marker-end="url(#arr5)" />
  <text x="530" y="80" text-anchor="middle" font-size="10" fill="#555">feeds</text>

  <rect x="570" y="55" width="190" height="70" rx="6" fill="#e6f4ea" stroke="#34a853" stroke-width="2" />
  <text x="665" y="78" text-anchor="middle" font-size="12" fill="#1a1a1a">Anomaly detection</text>
  <text x="665" y="95" text-anchor="middle" font-size="12" fill="#1a1a1a">job</text>
  <text x="665" y="112" text-anchor="middle" font-size="10" fill="#555">detectors, bucket_span</text>

  <text x="400" y="175" text-anchor="middle" font-size="12" fill="#555">The datafeed periodically queries source data,</text>
  <text x="400" y="193" text-anchor="middle" font-size="12" fill="#555">optionally pre-aggregating it, and streams results</text>
  <text x="400" y="211" text-anchor="middle" font-size="12" fill="#555">into the job for real-time anomaly analysis.</text>
</svg>

### Starting, Stopping, and State

Datafeeds have their own lifecycle independent of the job's existence:

- **`_start`** — begins the datafeed, which in turn starts the associated job if it is not already open.
- **`_stop`** — halts data retrieval; the job itself can remain open, retaining its trained model state.
- Datafeeds can be started with a specific `start` and `end` time for reprocessing historical data, or left open-ended for continuous real-time operation.
- A datafeed processing historical data up to the current time transitions into continuous real-time lookback once it catches up, if no `end` time was specified.

### Datafeed Preview

Before starting a datafeed against a live job, its output can be previewed via the `_preview` endpoint, which returns the shaped data (post-query, post-aggregation) exactly as the job would receive it — useful for validating query filters and aggregation structure without committing to a running job.

### Common Configuration Pitfalls

- **Mismatched aggregation interval and bucket_span** — using a `date_histogram` interval that doesn't align with the job's `bucket_span` can produce misleading results or unnecessary data volume.
- **Overly broad `indices` patterns** — pulling in unrelated documents that don't match the intended metric/log source, inflating processing cost and potentially skewing analysis.
- **Query filters excluding needed fields** — since only fields returned by the datafeed's query/aggregation are available to the job's detectors, an overly restrictive `_source` filter or aggregation can silently starve a detector of data it expects.
- **`query_delay` too short for actual ingest latency** — leads to incomplete buckets being analyzed as if final, which can produce inconsistent results on reprocessing.

### Key Points

- A datafeed sources and shapes data for an ML anomaly detection job; it does not perform analysis itself.
- Configuration includes source indices, a filtering query, timing (`frequency`, `query_delay`), and optionally aggregations.
- Aggregation-based datafeeds are preferred for high-volume metrics data, and their interval should align with the job's `bucket_span`.
- Datafeeds can run in historical (bounded `start`/`end`) or continuous real-time mode.
- The `_preview` endpoint validates the exact shape of data before committing to a running job.

### Related Topics

- Anomaly detection job configuration (detectors, bucket_span, influencers)
- ML job lifecycle: open, close, and model snapshots
- Aggregation alignment and `bucket_span` tuning
- Data stream and index pattern querying for ML
- Forecasting with anomaly detection jobs
- ML job results and anomaly score interpretation