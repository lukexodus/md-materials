## Single and Multi-Metric Jobs

### Overview

Single-metric and multi-metric jobs are the two guided anomaly detection job types available through Kibana's job creation wizards, sitting alongside population jobs and fully manual advanced jobs. They differ in how many detectors they configure and whether analysis is split by an entity field, but both are built on the same underlying job/datafeed mechanics.

### Single Metric Jobs

A single-metric job analyzes exactly one metric using exactly one detector, with no split (`by_field_name`) applied. It produces one continuous anomaly score timeline for the entire dataset as a whole.

**Characteristics:**

- One detector, one function, one field
- No entity splitting — all matching documents are modeled as a single aggregate time series
- Simplest to configure and interpret, since there's only one resulting chart/timeline
- Well suited to an already-aggregate metric (e.g., total requests per minute across an entire service) where per-entity breakdown isn't needed

```json
PUT /_ml/anomaly_detectors/total-error-rate
{
  "analysis_config": {
    "bucket_span": "15m",
    "detectors": [
      {
        "function": "count"
      }
    ]
  },
  "data_description": {
    "time_field": "@timestamp"
  }
}
```

This detector has no `field_name` or `by_field_name` — with `function: count` alone, it models the overall event count per bucket, useful for detecting overall traffic/volume anomalies.

```json
PUT /_ml/datafeeds/datafeed-total-error-rate
{
  "job_id": "total-error-rate",
  "indices": ["logs-app-prod"],
  "query": {
    "term": { "log.level": "error" }
  }
}
```

### Multi-Metric Jobs

A multi-metric job analyzes multiple detectors within a single job, and typically (though not necessarily) applies a `by_field_name` split so that a separate model is maintained per distinct entity value.

**Characteristics:**

- Multiple detectors, each potentially analyzing a different field/function combination
- Commonly split by an entity field (e.g., `host.name`, `service.name`), producing one model per entity rather than one global model
- Better suited to infrastructure/service monitoring where "normal" varies meaningfully between entities (e.g., a database host's normal CPU baseline differs from a web server's)
- Surfaces results per entity, making it easier to identify *which* host/service is behaving anomalously, not just that *something* is anomalous overall

```json
PUT /_ml/anomaly_detectors/host-health
{
  "analysis_config": {
    "bucket_span": "15m",
    "detectors": [
      {
        "function": "mean",
        "field_name": "cpu.usage",
        "by_field_name": "host.name"
      },
      {
        "function": "mean",
        "field_name": "memory.usage",
        "by_field_name": "host.name"
      },
      {
        "function": "max",
        "field_name": "disk.io.wait",
        "by_field_name": "host.name"
      }
    ],
    "influencers": ["host.name"]
  },
  "data_description": {
    "time_field": "@timestamp"
  }
}
```

Each detector here maintains an independent model per `host.name` value, so a host with naturally higher baseline CPU usage isn't flagged just for differing from another host's baseline — each host is compared only against its own learned history.

### Single-Metric vs. Multi-Metric (Comparison)

| Aspect | Single-Metric Job | Multi-Metric Job |
| --- | --- | --- |
| Number of detectors | Exactly 1 | 1 or more |
| Entity splitting (`by_field_name`) | Not used | Commonly used |
| Result granularity | One overall timeline | Per-entity timelines (if split) |
| Configuration complexity | Low | Moderate to high |
| Typical use case | Already-aggregate metrics, simple overall trend monitoring | Per-host/per-service/per-entity monitoring |
| Kibana wizard | Single Metric Job wizard | Multi-Metric Job wizard |

### Choosing Between Them

The decision generally follows from the shape of the question being asked:

- *"Is overall traffic/error rate unusual right now?"* → single-metric job, no split needed
- *"Which specific host/service is behaving unusually?"* → multi-metric job, split by the relevant entity field
- *"Is any entity behaving unusually compared to its peers (not just its own history)?"* → population job (`over_field_name` instead of `by_field_name`), covered under general anomaly detection concepts rather than this job type

### Adding Influencers

Both job types support `influencers`, which are not detectors themselves but fields used to help attribute anomalies to the entity most likely responsible — particularly valuable in multi-metric jobs where multiple detectors and entities are in play simultaneously.

```json
{
  "analysis_config": {
    "detectors": [ "..." ],
    "influencers": ["host.name", "service.name"]
  }
}
```

When several detectors fire anomalies in the same bucket, shared influencer values across those anomalies help identify a common root cause (e.g., multiple metrics on the same host spiking together point to that host as the influencer, rather than a coincidence across unrelated hosts).

### Example: Converting Single-Metric Reasoning into Multi-Metric

A single-metric job monitoring overall CPU usage across a fleet:

```json
{
  "detectors": [
    { "function": "mean", "field_name": "cpu.usage" }
  ]
}
```

...only tells you the fleet-wide average is unusual. Extending it into a multi-metric job by adding `by_field_name` reveals *which* host is driving that anomaly:

```json
{
  "detectors": [
    { "function": "mean", "field_name": "cpu.usage", "by_field_name": "host.name" }
  ],
  "influencers": ["host.name"]
}
```

This is a common progression: start with a single-metric job to confirm an aggregate signal exists, then move to a multi-metric (or population) job once per-entity attribution is needed.

### Viewing Results by Entity

For multi-metric jobs, results queries commonly filter or group by the `by_field_name` value to inspect a specific entity's anomaly history.

```json
GET /_ml/anomaly_detectors/host-health/results/records
{
  "query": {
    "term": { "by_field_value": "web-3" }
  },
  "sort": "record_score",
  "desc": true
}
```

### Common Pitfalls

- Using a single-metric job when per-entity attribution is actually needed, leading to an aggregate anomaly signal that can't identify *which* entity caused it
- Splitting a multi-metric job by an overly high-cardinality field, causing excessive model memory usage per the same concerns noted for `by_field_name`/`over_field_name` generally
- Adding many detectors to one multi-metric job without corresponding influencers, making it harder to determine whether simultaneous anomalies share a root cause
- Assuming a multi-metric job with `by_field_name` is the same as a population job (`over_field_name`) — they answer different questions (per-entity-vs-own-history vs. per-entity-vs-peers)

### Diagram: Single-Metric vs. Multi-Metric Modeling

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 740 300">
\<style\>
.title { font: bold 14px sans-serif; fill: #1a1a1a; }
.label { font: 12px sans-serif; fill: #1a1a1a; }
.sub { font: 11px sans-serif; fill: #555; }
.box { fill: #eef3fb; stroke: #4a6fa5; stroke-width: 1.5; }
.boxHost { fill: #eefbee; stroke: #4a9a5a; stroke-width: 1.5; }
.arrow { stroke: #333; stroke-width: 1.5; marker-end: url(#arrow8); }
\</style\>
<text x="20" y="25" class="title">Single-Metric vs. Multi-Metric Job Modeling (svg_diagram)</text>

<text x="30" y="55" class="label" font-weight="bold">Single-Metric Job</text>

<rect x="30" y="65" width="620" height="45" rx="4" class="box" />

<text x="340" y="92" class="label" text-anchor="middle">One model: all documents combined into one time series</text>

<text x="30" y="145" class="label" font-weight="bold">Multi-Metric Job (split by host.name)</text>

<rect x="30" y="155" width="190" height="45" rx="4" class="boxHost" />

<text x="125" y="182" class="label" text-anchor="middle">Model: web-1</text>

<rect x="240" y="155" width="190" height="45" rx="4" class="boxHost" />
<text x="335" y="182" class="label" text-anchor="middle">Model: web-2</text>
<rect x="450" y="155" width="190" height="45" rx="4" class="boxHost" />
<text x="545" y="182" class="label" text-anchor="middle">Model: db-1</text>

<text x="30" y="225" class="sub">Each host modeled independently against its own history</text>

<text x="30" y="245" class="sub">influencers (e.g. host.name) help attribute anomalies to the responsible entity</text>

</svg>

**Related Topics**

- Anomaly detection jobs — job types and detector functions overview
- Datafeed configuration — query filtering and aggregation-backed datafeeds
- Population jobs and `over_field_name` peer-comparison analysis
- Model memory limits and split-field cardinality considerations
- Influencers and root-cause attribution in anomaly results
- Alerting rules based on anomaly detection job results