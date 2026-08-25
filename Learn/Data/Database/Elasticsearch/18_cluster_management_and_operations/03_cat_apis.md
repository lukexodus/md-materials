## Cat APIs

### Purpose and Design Philosophy

The cat APIs (compact and aligned text) are a family of Elasticsearch REST endpoints designed for humans reading output directly in a terminal, rather than for programmatic consumption. Where the standard JSON APIs (like `_cluster/health` or `_nodes/stats`) return deeply nested, machine-oriented structures, cat APIs return plain-text tables: columnar, aligned, and grep-friendly.

Every cat endpoint is prefixed with `_cat` and is read-only — none of them mutate cluster state. They exist purely as an operational convenience layer over data that is (mostly) available through other APIs.

### Basic Usage and Discovery

Calling `_cat` with no further path returns a list of all available cat endpoints:

```
GET _cat
```

This returns plain text, one endpoint per line, e.g. `/_cat/indices`, `/_cat/nodes`, `/_cat/shards`, and so on. This self-documenting behavior is a quick way to discover what's available directly from a running cluster without consulting external documentation.

### Common Endpoints

**Key Points**
- `_cat/health` — one-line cluster health summary (status, node/shard counts, pending tasks)
- `_cat/indices` — per-index stats: health, status, docs count, store size, primary/replica counts
- `_cat/nodes` — per-node stats: roles, load, heap/RAM usage, master eligibility
- `_cat/shards` — per-shard placement: which node holds each shard, primary vs replica, state
- `_cat/allocation` — disk usage and shard count per node, useful for diagnosing uneven allocation
- `_cat/master` — identifies the current elected master node
- `_cat/pending_tasks` — cluster-level tasks queued for the master to process
- `_cat/recovery` — shard recovery progress (useful after restarts or rebalancing)
- `_cat/thread_pool` — thread pool queue/rejection stats per node
- `_cat/segments` — Lucene segment-level detail per shard
- `_cat/count` — document count for an index or the whole cluster
- `_cat/aliases` — index alias mappings
- `_cat/templates` — index and component templates
- `_cat/plugins` — installed plugins per node
- `_cat/repositories` and `_cat/snapshots` — snapshot repository and snapshot listings

### Query Parameters Common to All Cat APIs

**Verbose headers (`v`)**

By default, most cat responses omit column headers to stay terse. Adding `v=true` (or just `v`) prints a header row:

```
GET _cat/indices?v
```

**Column selection (`h`)**

The `h` parameter restricts output to specific columns, using the short column names shown in each endpoint's `?help` output:

```
GET _cat/indices?h=index,docs.count,store.size
```

**Discovering column names (`help`)**

```
GET _cat/indices?help
```

This lists every available column for that endpoint along with its short name and a description — essential since column names aren't always intuitive (e.g., `pri` for primary shard count, `sc` for segment count).

**Sorting (`s`)**

```
GET _cat/indices?v&s=store.size:desc
```

Sorts by one or more columns; append `:asc` or `:desc` (ascending is the default).

**Human-readable values (`human`)**

Converts raw byte counts and timestamps into human-friendly units (e.g., `10gb` instead of `10737418240`):

```
GET _cat/indices?v&human
```

**Response format (`format`)**

While the default is plain text, cat APIs can return JSON, YAML, or CBOR via `format=json`, though at that point using the standard JSON APIs is usually more appropriate, since cat output is not intended as a stable machine-readable contract:

```
GET _cat/indices?format=json
```

[Unverified] Column ordering and exact short-name spellings can shift slightly between major versions, so scripts parsing cat output by position rather than by explicit `h=` selection are fragile across upgrades.

**Time formatting (`time`)**

Some endpoints (like `_cat/recovery`) show elapsed times; the `time` parameter controls the unit (e.g., `time=s` for seconds).

### Practical Examples

**Example: Checking cluster health at a glance**

```
GET _cat/health?v
```

```
epoch      timestamp cluster status node.total node.data shards pri relo init unassign pending_tasks
1706000000 12:00:00  prod    green            5         3    120  60    0    0        0             0
```

**Example: Finding the largest indices**

```
GET _cat/indices?v&h=index,store.size,docs.count&s=store.size:desc
```

This is one of the most common day-to-day operational queries — quickly surfacing which indices are consuming the most disk.

**Example: Checking shard distribution across nodes**

```
GET _cat/allocation?v&h=node,shards,disk.used,disk.percent
```

Useful for spotting hot-spotting, where one node holds disproportionately more shards or disk usage than its peers, often preceding a `disk watermark` warning.

**Example: Diagnosing unassigned shards**

```
GET _cat/shards?v&h=index,shard,prirep,state,unassigned.reason
```

Filtering mentally (or with `grep`) for `state=UNASSIGNED` rows is a standard first step in troubleshooting a yellow or red cluster.

### Cat APIs vs. Standard JSON APIs

**Key Points**
- Cat APIs are for ad hoc human inspection: quick, readable, terminal-friendly.
- Standard JSON APIs (`_cluster/health`, `_nodes/stats`, `_stats`) are for programmatic consumption: monitoring tools, dashboards, alerting pipelines.
- Cat API output format is not considered a stable contract for automation; column sets and exact text formatting can change between versions without the same deprecation guarantees as the JSON APIs.
- For building dashboards or scripted health checks, prefer the JSON equivalents even if a cat endpoint looks like it would work.

### Illustration: Where Cat APIs Sit in Cluster Operations

<svg viewBox="0 0 760 360" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif">
  <text x="380" y="28" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Cat APIs in the Operational Workflow (svg_diagram)</text>

  <rect x="30" y="60" width="220" height="80" rx="8" fill="#e8f0fe" stroke="#4285f4" stroke-width="1.5"/>
  <text x="140" y="95" text-anchor="middle" font-size="13" fill="#1a1a1a">Operator / Engineer</text>
  <text x="140" y="115" text-anchor="middle" font-size="11" fill="#555">runs terminal commands</text>

  <rect x="290" y="60" width="220" height="80" rx="8" fill="#fef7e0" stroke="#f9ab00" stroke-width="1.5"/>
  <text x="400" y="90" text-anchor="middle" font-size="13" fill="#1a1a1a">_cat/* endpoints</text>
  <text x="400" y="108" text-anchor="middle" font-size="11" fill="#555">plain-text, aligned tables</text>
  <text x="400" y="124" text-anchor="middle" font-size="11" fill="#555">read-only</text>

  <rect x="550" y="60" width="180" height="80" rx="8" fill="#e6f4ea" stroke="#34a853" stroke-width="1.5"/>
  <text x="640" y="95" text-anchor="middle" font-size="13" fill="#1a1a1a">Cluster State</text>
  <text x="640" y="113" text-anchor="middle" font-size="11" fill="#555">nodes, shards, indices</text>

  <line x1="250" y1="100" x2="285" y2="100" stroke="#555" stroke-width="1.5" marker-end="url(#arrow)"/>
  <line x1="510" y1="100" x2="545" y2="100" stroke="#555" stroke-width="1.5" marker-end="url(#arrow)"/>
  <line x1="545" y1="115" x2="510" y2="115" stroke="#999" stroke-width="1.5" stroke-dasharray="4,3" marker-end="url(#arrow2)"/>

  <rect x="290" y="200" width="220" height="80" rx="8" fill="#fce8e6" stroke="#ea4335" stroke-width="1.5"/>
  <text x="400" y="230" text-anchor="middle" font-size="13" fill="#1a1a1a">Standard JSON APIs</text>
  <text x="400" y="248" text-anchor="middle" font-size="11" fill="#555">_cluster/health, _nodes/stats</text>
  <text x="400" y="264" text-anchor="middle" font-size="11" fill="#555">stable, machine-oriented</text>

  <rect x="550" y="200" width="180" height="80" rx="8" fill="#e8eaed" stroke="#5f6368" stroke-width="1.5"/>
  <text x="640" y="230" text-anchor="middle" font-size="13" fill="#1a1a1a">Monitoring / Dashboards</text>
  <text x="640" y="250" text-anchor="middle" font-size="11" fill="#555">Kibana, alerting, scripts</text>

  <line x1="510" y1="240" x2="545" y2="240" stroke="#555" stroke-width="1.5" marker-end="url(#arrow)"/>
  <line x1="640" y1="140" x2="640" y2="195" stroke="#999" stroke-width="1.5" stroke-dasharray="4,3" marker-end="url(#arrow2)"/>

  <text x="400" y="325" text-anchor="middle" font-size="11" fill="#777" font-style="italic">Cat APIs: human-facing, ad hoc. JSON APIs: automation-facing, stable contract.</text>

  <defs>
    <marker id="arrow" markerWidth="8" markerHeight="8" refX="7" refY="4" orient="auto">
      <path d="M0,0 L8,4 L0,8 Z" fill="#555"/>
    </marker>
    <marker id="arrow2" markerWidth="8" markerHeight="8" refX="7" refY="4" orient="auto">
      <path d="M0,0 L8,4 L0,8 Z" fill="#999"/>
    </marker>
  </defs>
</svg>

### Request Flow for a Cat API Call

```plaintext
===MERMAID_DIAGRAM===
flowchart LR
    A[Operator sends GET _cat/indices?v&h=index,docs.count] --> B[Coordinating node parses query params]
    B --> C[Fetches cluster state / index stats internally]
    C --> D[Formats as aligned plain-text table]
    D --> E[Returns text response to terminal]
```

### Practical Guidance for Day-to-Day Use

**Key Points**
- Always add `?v` when running cat queries interactively — unlabeled columns are hard to interpret later, especially in saved logs or screenshots.
- Use `?h=` to trim output to just the columns relevant to the task at hand, especially when combining with shell tools like `grep`, `awk`, or `sort`.
- Don't build production monitoring or alerting on top of cat API text output; treat it as an interactive/debugging tool only.
- `_cat/shards` and `_cat/allocation` are typically the first two endpoints reached for when a cluster health status turns yellow or red.
- Combine with standard Unix tools — cat API output is intentionally aligned to work well with `grep`, `sort`, `column`, and `awk` in shell pipelines.

### Security and Permissions Note

Access to cat endpoints is governed by the same security model as other Elasticsearch APIs, when the security features are enabled. A user querying `_cat/indices`, for instance, will only see indices they have `monitor` or higher privileges on. [Unverified] Exact default privilege requirements per cat endpoint can vary by version and by which security realm/role-mapping configuration is in use, so verifying against the specific cluster's role definitions is advisable before assuming visibility.

**Related Topics**
- Cluster Health API and status semantics (green/yellow/red)
- Index-level monitoring via `_stats` and `_segments` JSON APIs
- Shard allocation filtering and rebalancing settings
- Disk-based shard allocation watermarks
- Node roles and how they affect `_cat/nodes` output
- Using cat APIs in shell scripts vs. structured monitoring via Metricbeat/Kibana