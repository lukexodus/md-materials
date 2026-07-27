# Mastering PromQL on OpenObserve — A Comprehensive Guide

## How this guide is organized

I'm splitting this into two threads that run in parallel throughout: **PromQL the language** (which is the actual, unmodified Prometheus query language — no OpenObserve-specific dialect exists) and **PromQL on OpenObserve specifically** (ingestion paths, query endpoints, UI mechanics, and the handful of documented quirks). If you already know PromQL from real Prometheus/Grafana work, skip to Part 4 and treat Parts 1–3 as reference.

**A note on sourcing, since accuracy matters more than completeness here:** OpenObserve does not publish an exhaustive "supported vs. unsupported PromQL functions" reference page — I looked. What I found instead is a direct engineering data point from the project's own GitHub, a real Grafana-plugin integration doc, and scattered how-to pages for dashboards/alerts/custom-charts. I'll flag clearly which claims come from which source, and where I'm reasoning from a strongly-supported pattern rather than an explicit doc, I'll say so rather than presenting it as fact.

---

## Part 1: What PromQL actually is (the mental model)

PromQL has exactly four data types, and almost every confusion beginners have traces back to not knowing which one they're looking at:

| Type | What it is | Example |
|---|---|---|
| **Instant vector** | A set of time series, each with a single value at one instant | `http_requests_total` |
| **Range vector** | A set of time series, each with a range of values over a time window | `http_requests_total[5m]` |
| **Scalar** | A single numeric value, no labels | `3.14` |
| **String** | A literal string (rarely used directly) | `"foo"` |

The single most important rule in the entire language: **a range vector cannot be graphed or displayed directly.** It's raw input for functions like `rate()`, `increase()`, `avg_over_time()` — those consume the range and emit an instant vector. If you write `http_requests_total[5m]` into a dashboard panel expecting a graph, you'll get an error or nothing, because you handed it the ingredients, not the dish.

### Metric types and why they change how you query

Every metric ingested via Prometheus remote-write (which is how metrics get into OpenObserve — more on that in Part 2) carries a type:

- **Counter** — monotonically increasing (request counts, error counts, bytes sent). *Never query a counter's raw value directly* — always wrap it in `rate()` or `increase()`. A raw counter tells you "47,281,003 requests since the process started," which is useless. `rate()` tells you "312 requests/sec right now," which is what you actually want.
- **Gauge** — a value that goes up and down (memory usage, queue depth, temperature). Query these directly, or with `avg_over_time()`, `max_over_time()`, etc.
- **Histogram** — a set of `_bucket`, `_sum`, and `_count` series representing an observation distribution (request latencies). Almost always paired with `histogram_quantile()`.
- **Summary** — client-side pre-calculated quantiles. Rarer, cannot be aggregated across instances meaningfully (this is a fundamental math limitation, not a tooling gap — you cannot average two p99s and get a meaningful p99).

OpenObserve's own engineering docs (via the DeepWiki technical reference, which is generated from the actual OpenObserve source code) confirm the visualization layer explicitly differentiates counter, gauge, histogram, and summary during rendering — so this isn't just Prometheus theory, it's live in the product you're using.

---

## Part 2: How PromQL connects to OpenObserve specifically

This is the part that's actually about OpenObserve rather than generic PromQL theory, so I'll be precise about what's confirmed vs. inferred.

### Ingestion (confirmed)

OpenObserve ingests metrics via the standard Prometheus remote-write protocol, at an endpoint that mirrors Prometheus's own path structure:

```yaml
# prometheus.yml
remote_write:
  - url: https://<your-openobserve-host>/api/<org_name>/prometheus/api/v1/write
    queue_config:
      max_samples_per_send: 10000
    basic_auth:
      username: <your-email>
      password: <your-password-or-token>
```

Other confirmed ingestion paths for metrics: OTLP/OpenTelemetry Collector, Telegraf, and structured JSON via direct HTTP API — but remote-write is the one that actually carries PromQL-relevant metadata (metric type, native counter/gauge semantics) most cleanly, since it's the format Prometheus itself uses.

### Querying — API endpoint (well-supported inference, flagged as such)

I could not find an OpenObserve doc page that explicitly enumerates `/api/v1/query` and `/api/v1/query_range` the way, say, Google's Managed Prometheus docs do. What I *can* confirm: OpenObserve's own **Grafana plugin documentation** instructs you to configure OpenObserve as a **Prometheus-compatible data source** in Grafana using the base URL:

```
https://<your-openobserve-host>/api/<org_name>/prometheus
```

Grafana's Prometheus datasource plugin is not OpenObserve-specific — it's the same plugin used against real Prometheus, Thanos, Cortex, Mimir, VictoriaMetrics, and anything else claiming Prometheus HTTP API compatibility. It works by appending the standard suffix paths (`/api/v1/query`, `/api/v1/query_range`, `/api/v1/labels`, `/api/v1/label/<name>/values`, `/api/v1/series`) to whatever base URL you give it. Since OpenObserve's documented write path is `/api/<org>/prometheus/api/v1/write` and its documented Grafana base is `/api/<org>/prometheus`, the read-side endpoints almost certainly resolve to:

```
GET  https://<host>/api/<org>/prometheus/api/v1/query
GET  https://<host>/api/<org>/prometheus/api/v1/query_range
```

I'm confident enough in this to give it to you, but not confident enough to call it "documented" — if you're scripting against it directly (rather than through Grafana or OpenObserve's own UI), curl one of these against your instance before you build automation around it, since a wrong assumption here wastes your time, not mine.

```bash
curl -G "https://<host>/api/<org>/prometheus/api/v1/query" \
  --data-urlencode 'query=up' \
  -u '<email>:<password>'
```

### Querying — inside the OpenObserve UI (confirmed, and this is where you'll actually spend your time)

PromQL shows up in **three distinct UI surfaces**, each with slightly different mechanics:

**1. Standard dashboard panels.** When you add a panel, set Stream Type to `metrics`, pick your metric stream, and there's a toggle between SQL and PromQL query modes right in the panel editor.

**2. Custom Chart panels.** This is OpenObserve-specific and worth knowing about even if you don't use it immediately: instead of a built-in chart type, you write a PromQL query *and* JavaScript that transforms the raw response into an ECharts config. The raw response shape (confirmed directly from OpenObserve's docs) is:

```json
{
  "resultType": "matrix",
  "result": [
    {
      "metric": { "k8s_pod_name": "...", "container_id": "...", "service_name": "..." },
      "values": [ [timestamp, "value"], [timestamp, "value"], ... ]
    }
  ]
}
```

This is exactly Prometheus's own `matrix` result format from a range query — no OpenObserve dialect on the wire format. If you run **multiple** PromQL queries in one Custom Chart panel, the outer structure becomes an array of these matrix objects, one per query (`data[0]`, `data[1]`, etc.) — again, confirmed directly from OpenObserve's own custom-chart documentation, not inferred.

**3. Alerts.** PromQL is a first-class condition mode for metrics-type alerts alongside the natural-language Builder and SQL modes. A specific mechanic worth knowing: switching between "count mode" and "measure mode" in the alert condition builder clears your aggregation config and reverts operators to controlling event count — so if you've built out a PromQL-based measure-mode alert and accidentally toggle back to count mode, you'll lose that configuration, not just hide it.

### The most useful practical debugging tip I found

From OpenObserve's own Grafana-migration guide: **when a PromQL query returns no data, case mismatch on the metric name or label values is the most common cause.** This lines up with how PromQL label matching works (it's exact-match by default, case-sensitive, no fuzzy matching) — but it's specifically flagged by OpenObserve's own docs as the top real-world failure mode, so it's worth checking first before assuming your query logic is wrong.

### Migrating existing PromQL (confirmed)

If you're coming from Grafana + Prometheus/Mimir/Cortex, OpenObserve's own migration docs state plainly: **PromQL-based panels and alerts work as-is** — the same PromQL query that ran against Mimir runs unchanged against OpenObserve. This is the strongest practical compatibility claim I found anywhere in their docs, and it's consistent with the compliance data below.

---

## Part 3: The compliance data point (this is the important one)

I dug into OpenObserve's GitHub directly rather than relying on marketing copy, because "Full compatibility with Prometheus Query Language" is the kind of claim every vendor in this space makes and it's usually not literally true. Here's what I found, from a real engineering pull request (`#3772`, a PromQL-engine performance refactor) that included compliance-test output as part of its validation:

```
================================================================================
General query tweaks:
*  Openobserve is sometimes off by 1ms when parsing floating point start/end timestamps.
*  Openobserve fractional tolerance amount for <agg>_over_time queries
================================================================================
Total: 538 / 548 (98.18%) passed, 0 unsupported
```

What this tells you, and its limits:

- **98.18% of the PromQL compliance test suite passed, with zero functions reported as entirely unsupported.** This is a strong, specific number — far more useful than "full compatibility."
- **Two named, narrow quirks exist:** sub-millisecond floating-point timestamp rounding on query start/end, and a fractional-tolerance difference in `*_over_time` aggregation functions (`avg_over_time`, `sum_over_time`, etc.). Neither of these is likely to affect real dashboards or alerts — they're the kind of thing a compliance-test harness catches at floating-point precision but a human looking at a graph would never notice.
- **This is a point-in-time snapshot from one PR**, not an officially published, continuously-updated compatibility page. OpenObserve is under active development (latest GitHub release at time of writing: v0.90.0-rc3), so treat this as strong directional evidence that the language surface is essentially complete, not as a permanent guarantee pinned to whatever version you're running. If a specific advanced function misbehaves for you, that's more likely a genuine edge case than something to expect broadly.

**Practical takeaway:** you can learn and write PromQL against OpenObserve treating it as real, standard PromQL. You are not learning a subset or a dialect. The gaps that exist are precision-level, not feature-level.

---

## Part 4: The language itself, structured for actually mastering it

### 4.1 — Selectors: the foundation

```promql
http_requests_total
http_requests_total{job="api-server"}
http_requests_total{job="api-server", status_code="500"}
http_requests_total{status_code=~"5.."}      # regex match
http_requests_total{status_code!~"2.."}      # negative regex match
http_requests_total{env!="staging"}          # negative exact match
```

Four matcher operators: `=`, `!=`, `=~`, `!~`. That's the entire vocabulary for label matching. No `LIKE`, no `IN`, no wildcards outside regex.

### 4.2 — Range vectors and the functions that consume them

```promql
rate(http_requests_total[5m])
```

`rate()` calculates per-second average rate of increase over the window, correctly handling counter resets (if the counter drops — process restart — `rate()` detects and compensates rather than reporting a nonsensical negative rate). This is the single most-used function in all of PromQL.

```promql
irate(http_requests_total[5m])
```

`irate()` uses only the last two data points in the window instead of averaging across all of them — more responsive to sudden spikes, noisier on slow-moving graphs. Rule of thumb: `rate()` for dashboards and alerts, `irate()` for high-resolution debugging graphs where you want to see a spike happen in near-real-time.

```promql
increase(http_requests_total[1h])
```

`increase()` is `rate()` × window duration — total increase over the period rather than per-second rate. "How many errors in the last hour" uses `increase()`; "current error rate" uses `rate()`.

```promql
avg_over_time(cpu_usage[10m])
max_over_time(memory_bytes[1h])
min_over_time(disk_free[24h])
```

The `_over_time` family works on gauges (and any range vector) — this is also the function family with OpenObserve's documented fractional-tolerance quirk from Part 3. Not a functional gap, just a floating-point precision note.

### 4.3 — Aggregation operators

```promql
sum(rate(http_requests_total[5m])) by (job)
avg(cpu_usage) by (instance)
max(memory_bytes) by (pod)
count(up == 1)
```

`by (label)` keeps only the named labels in the result, dropping everything else — this is how you go from "500 individual time series, one per pod" to "one line per job." The inverse:

```promql
sum(rate(http_requests_total[5m])) without (instance)
```

`without (label)` drops the named labels and keeps everything else. `by` and `without` are opposite tools for the same job — pick whichever requires less typing for your label set.

### 4.4 — Binary operators and vector matching

```promql
http_requests_total{code="500"} / http_requests_total * 100
```

This computes an error-rate percentage by dividing two instant vectors. The critical, non-obvious rule: **PromQL performs an inner join on labels by default** — it only produces output for series where the label sets match on both sides (minus the label being compared, in this case `code`). This trips people up constantly. If your numerator has a label your denominator doesn't, that series silently disappears from the result rather than erroring.

```promql
http_requests_total{code="500"} / ignoring(code) http_requests_total
```

`ignoring(label)` explicitly excludes a label from the matching, which is what makes the division above actually work across series that only differ by `code`.

```promql
rate(node_cpu_seconds_total{mode="idle"}[5m])
  * on(instance) group_left(nodename)
  node_meta
```

`on(labels)` restricts matching to only the specified labels (opposite of `ignoring`). `group_left`/`group_right` handle many-to-one and one-to-many matches — the classic use case is enriching a metric with a "meta" label from a separate metric, like attaching a human-readable node name to a raw instance ID.

### 4.5 — Comparison operators, and the `bool` modifier

```promql
up == 0
cpu_usage > 90
```

Comparison operators used bare act as a **filter** — they drop non-matching series from the result rather than returning true/false.

```promql
cpu_usage > bool 90
```

Adding `bool` changes the behavior entirely: instead of filtering, every series is kept and the value becomes `1` or `0`. This distinction matters enormously for alerting logic — `cpu_usage > 90` gives you *only the series currently breaching*, while `cpu_usage > bool 90` gives you *every series, flagged*.

### 4.6 — Histograms and `histogram_quantile`

```promql
histogram_quantile(0.95,
  sum(rate(http_request_duration_seconds_bucket[5m])) by (le, job)
)
```

This computes p95 latency. Three things must be true for this to work correctly, and all three are common failure points:

1. You must aggregate with `sum(rate(..._bucket[...]))` first — never call `histogram_quantile` directly on raw bucket counters.
2. `le` (the bucket upper-bound label) **must** be preserved in your `by()` clause — drop it and the function has nothing to interpolate across.
3. `histogram_quantile` performs **linear interpolation within the bucket the quantile falls into** — it's an estimate, not an exact value, and its accuracy is bounded by how many buckets you configured on the instrumentation side. Coarse buckets produce coarse quantile estimates no matter how clever the query is.

### 4.7 — The `offset` modifier and time shifting

```promql
http_requests_total offset 1d
increase(http_requests_total[1h] offset 1d)
```

Shifts the entire query backward in time, useful for week-over-week or day-over-day comparisons:

```promql
(sum(rate(http_requests_total[5m])) - sum(rate(http_requests_total[5m] offset 1w)))
  / sum(rate(http_requests_total[5m] offset 1w)) * 100
```

That computes percent change in request rate versus the same time last week — a genuinely common real-world pattern once you have it, and easy to build incorrectly the first time (people often forget the offset needs to be inside the range-vector selector when combined with a range function, as shown in the second example above, not just tacked onto the end).

### 4.8 — `label_replace` and label manipulation

```promql
label_replace(
  up,
  "shortname", "$1", "instance", "([^:]+):.*"
)
```

Regex-extracts part of one label's value into a new label — commonly used to strip a port number off an `instance` label, or to normalize inconsistent naming between two metrics you're about to join with `on()`.

---

## Part 5: Where beginners and even experienced engineers get PromQL wrong

I'm listing these because they're the errors that produce *plausible-looking but wrong* dashboards — the dangerous kind, since nothing throws an error.

1. **Querying a counter without `rate()`/`increase()`.** The graph will show an ever-climbing line that resets to zero on every process restart. It compiles, it renders, it's meaningless.

2. **Using `rate()` with a window shorter than 4× the scrape interval.** If your metric arrives every 15s but you query `rate(x[15s])`, you frequently get gaps or noisy garbage, because `rate()` needs at least two samples inside the window to compute a slope. General guidance floating around the Prometheus community is to keep the range at least 4× the scrape interval — a `1m` minimum is a safe default for most setups.

3. **Forgetting that label mismatches silently drop series in binary operations**, rather than erroring — covered in 4.4, but worth repeating because it's the single most common "why is my graph empty for some things but not others" bug.

4. **Dropping the `le` label before `histogram_quantile`.** Covered in 4.6, but this is extremely common because it's an easy thing to accidentally do while writing an aggregation.

5. **Treating Summary quantiles as aggregatable.** You cannot `avg()` two p99 values from two different instances and get a meaningful p99 of the combined population — this is a mathematical property of pre-computed quantiles, not a PromQL limitation. If you need cross-instance aggregation, use Histograms with `histogram_quantile()`, not Summaries.

6. **On OpenObserve specifically: metric-name or label-value case mismatch.** Flagged directly in OpenObserve's own docs as the most common cause of "PromQL returns nothing." Check exact casing in the Metrics explorer before assuming your query logic is broken.

---

## Part 6: A practical learning path

If you want to go from zero to genuinely fluent, here's the order I'd actually recommend, based on what compounds versus what's a dead end to learn early:

1. **Selectors and label matching** (4.1) — everything else builds on this.
2. **Counters + `rate()`** (4.2) — this single pairing covers a large fraction of real-world dashboards.
3. **`sum()...by()`** (4.3) — turns per-instance noise into per-service signal.
4. **Comparison filtering vs. `bool`** (4.5) — this is where alerting logic actually lives.
5. **Binary operators and `ignoring`/`on`** (4.4) — this is where most intermediate learners plateau, because it's genuinely the most conceptually dense part of the language. Budget real time here.
6. **Histograms and `histogram_quantile`** (4.6) — latency percentiles, the thing everyone eventually needs for SLOs.
7. **`offset` and time comparisons** (4.7) — week-over-week, day-over-day reporting.
8. Everything else (`label_replace`, `absent()`, `predict_linear()`, subqueries) — pick these up as specific needs arise; they're powerful but narrow, and memorizing them before you need them doesn't stick.

At each stage, the fastest way to build real fluency is the same regardless of platform: **write the query against your own real metrics, not tutorial data.** Tutorial data is clean and doesn't teach you what your actual label cardinality, missing data, or counter-reset behavior looks like. Given that OpenObserve's own migration docs confirm PromQL "works as-is" when moved from other Prometheus-compatible backends, anything you learn here transfers cleanly if you ever end up on plain Prometheus, Grafana Mimir, Thanos, or VictoriaMetrics — this isn't OpenObserve-flavored knowledge, it's the real thing.