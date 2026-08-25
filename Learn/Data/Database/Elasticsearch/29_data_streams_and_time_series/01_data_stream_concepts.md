## Data Stream Concepts

### Overview

A data stream in Elasticsearch is a convenience abstraction over a series of hidden, auto-generated backing indices, designed for append-only, time-series or time-ordered data such as logs, metrics, and events. Rather than managing individual indices manually, applications write to and query a single named resource — the data stream — while Elasticsearch handles the underlying index lifecycle, rollover, and routing.

### Core Architecture

A data stream consists of:

- **A stream name** — the logical identifier applications use for indexing and search requests.
- **A matching index template** — defines the mappings, settings, and index lifecycle policy applied to backing indices. The template must have `data_stream` enabled for the stream to be created.
- **Backing indices** — hidden, system-managed indices named using the pattern `.ds-<data-stream-name>-<generation>`, each holding a slice of the stream's documents.

At any time, exactly one backing index is designated the **write index** — the only one accepting new documents. All other backing indices are read-only from the stream's perspective (though they remain directly searchable).

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 320">
  <text x="400" y="30" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Data Stream Structure (svg_diagram)</text>

  <rect x="300" y="55" width="200" height="45" rx="6" fill="#e8f0fe" stroke="#4285f4" stroke-width="2" />
  <text x="400" y="83" text-anchor="middle" font-size="14" fill="#1a1a1a">logs-app-prod</text>

  <line x1="400" y1="100" x2="400" y2="130" stroke="#666" stroke-width="1.5" />

  <rect x="80" y="140" width="150" height="60" rx="6" fill="#f1f3f4" stroke="#999" stroke-width="1.5" />
  <text x="155" y="165" text-anchor="middle" font-size="12" fill="#333">.ds-logs-app-prod</text>
  <text x="155" y="180" text-anchor="middle" font-size="12" fill="#333">-000001</text>
  <text x="155" y="195" text-anchor="middle" font-size="11" fill="#777">(read-only)</text>

  <rect x="260" y="140" width="150" height="60" rx="6" fill="#f1f3f4" stroke="#999" stroke-width="1.5" />
  <text x="335" y="165" text-anchor="middle" font-size="12" fill="#333">.ds-logs-app-prod</text>
  <text x="335" y="180" text-anchor="middle" font-size="12" fill="#333">-000002</text>
  <text x="335" y="195" text-anchor="middle" font-size="11" fill="#777">(read-only)</text>

  <rect x="440" y="140" width="150" height="60" rx="6" fill="#e6f4ea" stroke="#34a853" stroke-width="2" />
  <text x="515" y="165" text-anchor="middle" font-size="12" fill="#1a1a1a">.ds-logs-app-prod</text>
  <text x="515" y="180" text-anchor="middle" font-size="12" fill="#1a1a1a">-000003</text>
  <text x="515" y="195" text-anchor="middle" font-size="11" fill="#0a7a2f" font-weight="bold">(write index)</text>

  <line x1="155" y1="120" x2="155" y2="140" stroke="#999" stroke-width="1.5" />
  <line x1="335" y1="120" x2="335" y2="140" stroke="#999" stroke-width="1.5" />
  <line x1="515" y1="120" x2="515" y2="140" stroke="#999" stroke-width="1.5" />
  <path d="M 155 130 L 515 130" stroke="#999" stroke-width="1.5" fill="none" />

  <line x1="620" y1="170" x2="680" y2="170" stroke="#4285f4" stroke-width="2" marker-end="url(#arrow)" />
  <text x="650" y="160" text-anchor="middle" font-size="11" fill="#4285f4">rollover</text>

  <text x="400" y="240" text-anchor="middle" font-size="12" fill="#555">Application indexes and searches against "logs-app-prod" only.</text>
  <text x="400" y="258" text-anchor="middle" font-size="12" fill="#555">Elasticsearch resolves reads across all backing indices,</text>
  <text x="400" y="276" text-anchor="middle" font-size="12" fill="#555">and routes writes to the current write index.</text>
</svg>

### Required Document Fields

Every document indexed into a data stream must contain a timestamp field, by default named `@timestamp`. This field:

- Must be mapped as `date` or `date_nanos`.
- Is used by Elasticsearch to determine document age for lifecycle actions (rollover, retention).
- Can be renamed via the `data_stream.timestamp_field.name` setting in the index template, though `@timestamp` is the conventional default and aligns with Elastic Common Schema (ECS).

### Append-Only Semantics

Data streams are designed around an append-only pattern:

- Direct document `PUT` requests with explicit IDs targeting arbitrary documents, and update/delete-by-query operations against the stream name, are restricted or behave differently than on regular indices.
- Standard indexing (`POST <data-stream>/_doc`) auto-generates document IDs and routes to the write index.
- To update or delete specific documents, operations must target the specific backing index containing that document, not the data stream alias itself. [Inference: exact restrictions have evolved across versions — verify against the version in use.]

This design assumes time-series data is written once and rarely mutated afterward, which simplifies internal routing and enables aggressive optimizations for ingest-heavy workloads.

### Rollover

Rollover is the mechanism by which a new backing index becomes the write index. It can be triggered by:

- **ILM (Index Lifecycle Management) policies** — automatic rollover based on conditions like max age, max size, max document count, or max primary shard size.
- **Manual rollover** — via the `_rollover` API, explicitly invoked against the data stream name.

When rollover occurs, a new backing index is created (incrementing the generation number), and it becomes the sole write target. Prior backing indices remain fully searchable but stop receiving new writes.

### Naming Conventions

Data stream names conventionally follow the pattern:

```
<type>-<dataset>-<namespace>
```

For example: `logs-nginx.access-production`. This convention is used heavily by Elastic's own integrations (Fleet, Elastic Agent) and by ECS-aligned index templates, though it is not strictly enforced by Elasticsearch for custom data streams.

### Data Stream Lifecycle vs. ILM

Elasticsearch offers two mechanisms for managing backing index lifecycle:

- **Data stream lifecycle** — a simplified, built-in lifecycle management feature configured directly on the data stream, covering retention and rollover with less configuration surface.
- **Index Lifecycle Management (ILM)** — a more feature-rich system supporting multi-phase policies (hot, warm, cold, frozen, delete) with shard allocation, force-merge, searchable snapshots, and more.

A data stream can be managed by one or the other, not typically both simultaneously. ILM is generally preferred when phase-based tiering across hardware (hot-warm-cold architectures) is required. [Inference: the specific interplay and precedence rules depend on the Elasticsearch version — this area has changed across recent major releases.]

### Read and Write Behavior Summary

| Operation | Target | Behavior |
|---|---|---|
| Index new document | Data stream name | Routed to current write index |
| Search | Data stream name | Queries across all backing indices |
| Update/delete specific doc | Backing index name | Must target the specific `.ds-*` index |
| Rollover | Data stream name (via API or ILM) | Creates new write index |
| Delete entire stream | Data stream name | Removes stream and all backing indices |

### Key Points

- A data stream is an abstraction, not a physical index — actual data lives in hidden backing indices.
- Requires an index template with `data_stream` enabled and a timestamp field mapping.
- Only one backing index accepts writes at a time (the write index).
- Optimized for append-only, time-ordered data; document mutation requires targeting the backing index directly.
- Lifecycle is managed via either data stream lifecycle (simpler) or ILM (more granular, tiered).

### Related Topics

- Index templates and composable templates
- Index Lifecycle Management (ILM) phases and actions
- Data stream lifecycle configuration and retention
- Rollover conditions and the `_rollover` API
- Elastic Common Schema (ECS) and naming conventions
- Time series data streams (TSDS) and dimension/metric field types
- Searchable snapshots and cold/frozen tiers