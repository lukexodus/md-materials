## Aggregations — Pipeline Aggregations Overview

### What Pipeline Aggregations Are

Pipeline aggregations operate on the **outputs of other aggregations** rather than directly on document fields. Where metric aggregations reduce documents to values and bucket aggregations partition documents into groups, pipeline aggregations take the numeric results already produced by those aggregations and compute secondary statistics, transformations, or derivatives from them.

This means pipeline aggregations require at least one other aggregation to already exist in the request — they have no access to raw documents and cannot be the only aggregation in a request.

---

### Conceptual Position in the Aggregation Tree

```
Query
└── Bucket Aggregation (e.g., date_histogram)
    ├── Metric Aggregation (e.g., sum → produces per-bucket value)
    └── Pipeline Aggregation (reads the metric output across buckets)
```

Pipeline aggregations typically sit as **siblings** to the bucket aggregation whose output they consume (sibling pipeline aggregations), or as **children** inside the bucket aggregation (parent pipeline aggregations). This distinction is one of the two primary classifications of pipeline aggregations.

---

### Two Categories

#### Parent Pipeline Aggregations

Defined **inside** a bucket aggregation. They iterate over the ordered sequence of buckets produced by their parent and compute a new value for each bucket, adding it back into that bucket's result.

They operate bucket-by-bucket, in order, and can reference prior bucket values (e.g., for derivatives or moving averages).

Examples: `derivative`, `cumulative_sum`, `moving_avg` (deprecated), `moving_fn`, `serial_diff`

#### Sibling Pipeline Aggregations

Defined **alongside** a bucket aggregation at the same level. They take the complete set of bucket outputs and produce a single new value (or set of values) at that level — summarizing across all buckets rather than enriching each one.

Examples: `avg_bucket`, `sum_bucket`, `max_bucket`, `min_bucket`, `stats_bucket`, `extended_stats_bucket`, `percentiles_bucket`, `bucket_script`, `bucket_selector`, `bucket_sort`

---

### The buckets\_path Parameter

All pipeline aggregations reference their input via a `buckets_path` parameter. This is a dot-notation path that navigates the aggregation tree to locate the specific metric value to consume.

#### Syntax

```
buckets_path: "agg_name>metric_name"
```

- `>` separates levels in nested aggregation paths
- The final segment identifies the specific metric output (e.g., `_count`, `_key`, or a named metric aggregation)

#### Example

```json
GET /sales/_search
{
  "size": 0,
  "aggs": {
    "monthly_sales": {
      "date_histogram": {
        "field": "order_date",
        "calendar_interval": "month"
      },
      "aggs": {
        "total_revenue": {
          "sum": { "field": "revenue" }
        }
      }
    },
    "avg_monthly_revenue": {
      "avg_bucket": {
        "buckets_path": "monthly_sales>total_revenue"
      }
    }
  }
}
```

`avg_monthly_revenue` is a sibling pipeline aggregation. It reads `total_revenue` from each bucket of `monthly_sales` and produces the average across all months.

#### Special Path Tokens

| Token | Meaning |
|---|---|
| `_count` | The document count of a bucket |
| `_key` | The bucket key value |
| `metric_name` | Output of a named metric aggregation |
| `metric_name.value` | Explicit value output (some aggregations) |

#### Multi-value Metric Paths

When referencing a metric aggregation that produces multiple values (e.g., `percentiles`, `stats`), the specific output must be identified:

```
"buckets_path": "monthly_sales>latency_percentiles[99.0]"
```

Bracket notation selects a named key from the metric's output map.

---

### Gap Handling

Bucket aggregations do not always produce contiguous, populated buckets. A `date_histogram` over sparse data may have months with zero documents — or no bucket at all if `min_doc_count` is greater than zero.

Pipeline aggregations that depend on ordered sequences (parent type) must handle these gaps. The `gap_policy` parameter controls this behavior.

#### gap\_policy Options

```json
"derivative": {
  "buckets_path": "total_revenue",
  "gap_policy": "skip"
}
```

| Value | Behavior |
|---|---|
| `skip` | Ignores the empty bucket; the pipeline aggregation produces no output for it |
| `insert_zeros` | Treats the missing bucket as having a value of zero |
| `keep_values` | (available on some aggregations) Passes the existing value through unchanged |

Default is `skip`. The appropriate policy depends on whether a missing bucket represents truly zero activity or simply absent data — these have different semantic meanings in most time-series contexts.

---

### Ordering and Sequence Dependency

Parent pipeline aggregations that compute change over time — `derivative`, `serial_diff`, `cumulative_sum`, `moving_fn` — are **order-sensitive**. They rely on the parent bucket aggregation producing buckets in a meaningful sequence, typically chronological.

[Inference] Using these with bucket aggregations that do not produce a stable natural order (e.g., `terms`) may yield results that are computed but semantically meaningless — behavior and usefulness depend on the data and use case.

The `date_histogram` and `histogram` aggregations are the natural parent types for sequence-dependent pipeline aggregations.

---

### Normalization and Format

Pipeline aggregation outputs can be formatted using the `format` parameter where supported:

```json
"avg_monthly_revenue": {
  "avg_bucket": {
    "buckets_path": "monthly_sales>total_revenue",
    "format": "#,##0.00"
  }
}
```

This applies a Java `DecimalFormat` pattern to the numeric output. The underlying value in the response is unchanged; the formatted string appears alongside it as `value_as_string`.

---

### Pipeline Aggregations Cannot Be Nested Into Metrics

Pipeline aggregations can reference the output of other pipeline aggregations via `buckets_path`, subject to ordering constraints. However, they cannot be used as the input to a standard metric aggregation — the data flow is one-directional: documents → metrics/buckets → pipelines.

[Inference] Complex multi-stage pipeline chains are possible within a single request, but each stage must respect the parent/sibling classification and path resolution rules — there is no guarantee all combinations produce meaningful results without validating against the specific aggregation types involved.

---

### Summary of Available Pipeline Aggregations

#### Sibling Pipeline Aggregations

| Name | Description |
|---|---|
| `avg_bucket` | Average of a metric across all buckets |
| `sum_bucket` | Sum of a metric across all buckets |
| `max_bucket` | Maximum value across all buckets, with bucket key |
| `min_bucket` | Minimum value across all buckets, with bucket key |
| `stats_bucket` | count, min, max, avg, sum across all buckets |
| `extended_stats_bucket` | `stats_bucket` plus variance, std deviation |
| `percentiles_bucket` | Percentile distribution of a metric across buckets |
| `bucket_script` | Executes a script over multiple bucket metrics |
| `bucket_selector` | Filters buckets based on a script condition |
| `bucket_sort` | Sorts, truncates, or paginates buckets |
| `cumulative_cardinality` | Running count of distinct values seen so far |
| `normalize` | Rescales bucket values using a specified method |

#### Parent Pipeline Aggregations

| Name | Description |
|---|---|
| `derivative` | Rate of change between consecutive buckets |
| `cumulative_sum` | Running total across ordered buckets |
| `moving_fn` | Sliding window function over ordered buckets |
| `serial_diff` | Difference between a bucket and a lagged bucket |
| `moving_avg` | Deprecated; replaced by `moving_fn` |
| `inference` | Applies a trained ML model to bucket values |

---

### Illustrative Structure

The following diagram shows the positional relationship between aggregation types in a request:

<svg viewBox="0 0 700 420" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13">
  <rect width="700" height="420" fill="#0f1117"/>
  <!-- Query box -->
  <rect x="20" y="20" width="660" height="60" rx="6" fill="#1e2130" stroke="#3b4261" stroke-width="1.5"/>
  <text x="40" y="45" fill="#7aa2f7" font-weight="bold">Query</text>
  <text x="40" y="67" fill="#565f89" font-size="11">Filters the document set before aggregation</text>
  <!-- Bucket agg box -->
  <rect x="20" y="110" width="660" height="60" rx="6" fill="#1e2130" stroke="#3b4261" stroke-width="1.5"/>
  <text x="40" y="135" fill="#9ece6a" font-weight="bold">Bucket Aggregation</text>
  <text x="40" y="157" fill="#565f89" font-size="11">e.g. date_histogram — partitions documents into ordered buckets</text>
  <!-- Arrow query to bucket -->
  <line x1="350" y1="80" x2="350" y2="110" stroke="#3b4261" stroke-width="1.5" marker-end="url(#arr)"/>
  <!-- Metric agg box (child) -->
  <rect x="40" y="200" width="300" height="60" rx="6" fill="#1a1f2e" stroke="#3b4261" stroke-width="1.5"/>
  <text x="60" y="225" fill="#e0af68" font-weight="bold">Metric Aggregation (child)</text>
  <text x="60" y="247" fill="#565f89" font-size="11">e.g. sum — produces per-bucket value</text>
  <!-- Parent pipeline box (child) -->
  <rect x="360" y="200" width="300" height="60" rx="6" fill="#1a1f2e" stroke="#f7768e" stroke-width="1.5" stroke-dasharray="5,3"/>
  <text x="380" y="220" fill="#f7768e" font-weight="bold">Parent Pipeline Agg</text>
  <text x="380" y="238" fill="#f7768e" font-size="10">(defined inside bucket agg)</text>
  <text x="380" y="255" fill="#565f89" font-size="11">e.g. derivative, cumulative_sum</text>
  <!-- Arrow bucket to children -->
  <line x1="190" y1="170" x2="190" y2="200" stroke="#3b4261" stroke-width="1.5" marker-end="url(#arr)"/>
  <line x1="510" y1="170" x2="510" y2="200" stroke="#f7768e" stroke-width="1" stroke-dasharray="4,3" marker-end="url(#arrRed)"/>
  <!-- Sibling pipeline box -->
  <rect x="40" y="310" width="620" height="70" rx="6" fill="#1a1f2e" stroke="#7dcfff" stroke-width="1.5" stroke-dasharray="5,3"/>
  <text x="60" y="333" fill="#7dcfff" font-weight="bold">Sibling Pipeline Aggregation</text>
  <text x="60" y="351" fill="#7dcfff" font-size="10">(defined alongside bucket agg, at same level)</text>
  <text x="60" y="368" fill="#565f89" font-size="11">e.g. avg_bucket, max_bucket — reads across all bucket outputs via buckets_path</text>
  <!-- Arrow metric to sibling -->
  <line x1="190" y1="260" x2="190" y2="310" stroke="#7dcfff" stroke-width="1" stroke-dasharray="4,3" marker-end="url(#arrBlue)"/>
  <line x1="510" y1="260" x2="510" y2="310" stroke="#7dcfff" stroke-width="1" stroke-dasharray="4,3" marker-end="url(#arrBlue)"/>
  <!-- Legend -->
  <line x1="460" y1="120" x2="490" y2="120" stroke="#f7768e" stroke-width="1.5" stroke-dasharray="5,3"/>
  <text x="496" y="124" fill="#f7768e" font-size="11">Parent pipeline</text>
  <line x1="460" y1="140" x2="490" y2="140" stroke="#7dcfff" stroke-width="1.5" stroke-dasharray="5,3"/>
  <text x="496" y="144" fill="#7dcfff" font-size="11">Sibling pipeline</text>
  <!-- Arrow markers -->
  <defs>
    <marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#3b4261"/>
    </marker>
    <marker id="arrRed" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#f7768e"/>
    </marker>
    <marker id="arrBlue" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
      <path d="M0,0 L0,6 L8,3 z" fill="#7dcfff"/>
    </marker>
  </defs>
</svg>

---

**Conclusion:** Pipeline aggregations extend the aggregation framework into a second computational layer — one that operates on aggregation outputs rather than documents. The parent/sibling classification determines where they are defined and what scope of data they see. The `buckets_path` parameter is the universal mechanism for referencing inputs. Gap handling and sequence order are the primary operational concerns for parent pipeline aggregations. Each individual pipeline aggregation type builds on this shared foundation with its own specific behavior, covered in subsequent topics.