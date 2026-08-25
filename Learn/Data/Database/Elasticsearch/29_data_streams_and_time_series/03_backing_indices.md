## Backing Indices

### Overview

Backing indices are the actual physical Elasticsearch indices that store the documents belonging to a data stream. The data stream itself holds no data directly — it is a named reference to an ordered sequence of these indices. Understanding how backing indices are created, named, promoted, and retired is central to understanding data stream behavior in practice.

### Naming Format

Backing indices follow a system-generated naming pattern:

```
.ds-<data-stream-name>-<namespace-date>-<generation>
```

In current versions, the pattern typically includes a date component reflecting when the backing index was created, followed by a zero-padded generation number, for example:

```
.ds-logs-app-prod-2026.08.20-000003
```

The leading dot marks it as a **hidden index** — it does not appear in default `GET _cat/indices` or wildcard listings unless hidden indices are explicitly requested. This is intentional: users are expected to interact with the data stream name, not the backing indices, under normal operation.

### Generation Numbers

Each backing index is assigned a **generation** — a monotonically increasing integer starting at 1 (formatted as `000001`). Every rollover increments the generation by one and creates a new backing index carrying that number. Generation numbers are never reused within a data stream's lifetime, even if intermediate backing indices are deleted.

### The Write Index

At any given moment, exactly one backing index is the **write index** — the most recently created one, holding the highest generation number under normal operation. Key properties:

- All standard indexing requests directed at the data stream name are routed to this index.
- It is the only backing index that accepts new documents through the data stream alias.
- It becomes read-only (from the stream's perspective) the moment rollover produces a successor.

### Backing Index Creation Triggers

New backing indices are created under these circumstances:

- **Data stream creation** — the first backing index (generation `000001`) is created automatically when the stream is first used or explicitly created.
- **Rollover** — triggered by ILM policy, data stream lifecycle, or a manual `_rollover` API call.
- **Explicit index rollover conditions being met** — such as max age, max primary shard size, max document count, or max size, depending on the configured policy.

### Direct Access to Backing Indices

While normal application traffic should target the data stream name, backing indices can be addressed directly for specific operations:

- **Update or delete a specific document** — since data streams restrict document-level update/delete via the stream alias, these operations must target the backing index (`.ds-...`) that physically contains the document.
- **Diagnostics** — inspecting index-level settings, shard allocation, or segment info for a particular slice of time-ordered data.
- **Direct search** — searching a specific backing index by name restricts results to that time slice only, which can be a deliberate performance optimization when the relevant window is known.

Direct write operations that bypass the data stream's routing logic (e.g., indexing directly into an older, non-write backing index) are disallowed for standard document creation, preserving the append-only guarantee at the stream level.

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 280">
  <text x="400" y="28" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Backing Index Lifecycle (svg_diagram)</text>

  <circle cx="90" cy="110" r="8" fill="#4285f4" />
  <text x="90" y="140" text-anchor="middle" font-size="11" fill="#333">Stream created</text>

  <line x1="98" y1="110" x2="180" y2="110" stroke="#999" stroke-width="1.5" marker-end="url(#arr2)" />

  <rect x="185" y="85" width="150" height="50" rx="6" fill="#f1f3f4" stroke="#999" stroke-width="1.5" />
  <text x="260" y="106" text-anchor="middle" font-size="11" fill="#333">gen 000001</text>
  <text x="260" y="122" text-anchor="middle" font-size="10" fill="#0a7a2f">write index</text>

  <line x1="335" y1="110" x2="400" y2="110" stroke="#999" stroke-width="1.5" marker-end="url(#arr2)" />
  <text x="367" y="100" text-anchor="middle" font-size="10" fill="#4285f4">rollover</text>

  <rect x="185" y="150" width="150" height="50" rx="6" fill="#f1f3f4" stroke="#999" stroke-width="1.5" opacity="0.6" />
  <text x="260" y="171" text-anchor="middle" font-size="11" fill="#333">gen 000001</text>
  <text x="260" y="187" text-anchor="middle" font-size="10" fill="#777">read-only</text>

  <rect x="405" y="85" width="150" height="50" rx="6" fill="#f1f3f4" stroke="#999" stroke-width="1.5" />
  <text x="480" y="106" text-anchor="middle" font-size="11" fill="#333">gen 000002</text>
  <text x="480" y="122" text-anchor="middle" font-size="10" fill="#0a7a2f">write index</text>

  <line x1="555" y1="110" x2="620" y2="110" stroke="#999" stroke-width="1.5" marker-end="url(#arr2)" />
  <text x="587" y="100" text-anchor="middle" font-size="10" fill="#4285f4">rollover</text>

  <rect x="405" y="150" width="150" height="50" rx="6" fill="#f1f3f4" stroke="#999" stroke-width="1.5" opacity="0.6" />
  <text x="480" y="171" text-anchor="middle" font-size="11" fill="#333">gen 000002</text>
  <text x="480" y="187" text-anchor="middle" font-size="10" fill="#777">read-only</text>

  <rect x="625" y="85" width="150" height="50" rx="6" fill="#e6f4ea" stroke="#34a853" stroke-width="2" />
  <text x="700" y="106" text-anchor="middle" font-size="11" fill="#1a1a1a">gen 000003</text>
  <text x="700" y="122" text-anchor="middle" font-size="10" fill="#0a7a2f" font-weight="bold">current write</text>

  <text x="400" y="240" text-anchor="middle" font-size="12" fill="#555">Each rollover retires the current write index and promotes a new one.</text>
  <text x="400" y="258" text-anchor="middle" font-size="12" fill="#555">Retired indices remain searchable until deleted by retention policy.</text>
</svg>

### Deletion and Retention

Backing indices are removed according to the retention rules of whichever lifecycle mechanism governs the stream:

- **Data stream lifecycle** — retention is configured with a simple `data_retention` period; indices whose data has aged past that period are deleted automatically.
- **ILM** — the delete phase, combined with a `min_age` threshold, removes indices once they meet the configured age and pass through earlier phases (hot/warm/cold) as applicable.

Deleting a backing index directly (via the standard index delete API) is possible but generally discouraged outside of lifecycle automation, since it bypasses lifecycle bookkeeping. [Inference: some versions impose additional guardrails preventing direct deletion of the current write index — confirm behavior against the version in use.]

### Shards and Settings Inheritance

Backing indices inherit their mappings and settings from the index template matching the data stream at the time of creation:

- Each new generation is created fresh from the **current** state of the matching index template, not the template state at stream creation time.
- This means updating an index template affects only backing indices created *after* the update — existing backing indices retain the settings they were created with, unless explicitly updated via the index settings API.
- This has a practical implication: changing the number of primary shards, or adding new field mappings, only takes effect for future generations following the next rollover.

### Key Points

- Backing indices are hidden, system-named indices (`.ds-*`) holding the actual data.
- Exactly one backing index is the write index at any time; all others are read-only under the stream.
- Generation numbers increment monotonically and are never reused.
- Index template changes apply only to backing indices created after the change — not retroactively.
- Document update/delete must target the specific backing index, not the data stream name.

### Related Topics

- Rollover conditions and the `_rollover` API
- Index templates and composable templates
- ILM phases: hot, warm, cold, frozen, delete
- Data stream lifecycle and `data_retention`
- Reindexing and migrating data streams after mapping changes
- Shard allocation and hot-warm-cold architecture