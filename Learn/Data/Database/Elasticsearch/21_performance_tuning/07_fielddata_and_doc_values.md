## Fielddata and Doc Values

### Overview

Doc values and fielddata are two mechanisms Elasticsearch uses to provide the field-value lookups required for sorting, aggregations, and scripting. They solve the same fundamental problem — reading values "column-wise" across many documents — but they differ radically in when they're built, where they live, and what that means for cluster stability.

### The Core Problem: Why Inverted Indices Aren't Enough

An inverted index maps terms to the documents containing them, which is ideal for search ("find documents containing this term") but poorly suited to the inverse operation: "for this document, what is the value of this field?" Sorting, aggregations, and scripting all need this document-to-value direction, sometimes called a "forward index" or column-oriented view of the data.

### Doc Values

**Key Points**
- Doc values are the default on-disk, column-oriented data structure built at index time for most field types.
- Enabled by default for all fields except `text` and `annotated_text`, which do not support doc values.
- Stored on disk alongside the inverted index, so they are not held entirely in JVM heap.
- Immutable, densely packed, and compressed, which makes them fast to load into the filesystem cache and memory-efficient relative to fielddata.
- Because they live on disk (leveraging the OS filesystem cache rather than the JVM heap), doc values largely sidestep the heap-pressure problems that plagued the old fielddata-for-everything approach.

### Fielddata

**Key Points**
- Fielddata is an in-memory, heap-resident structure built lazily the first time a field is used for sorting, aggregations, or scripting.
- Required for aggregations/sorting/scripting on `text` fields, since analyzed text fields don't have doc values.
- Disabled by default on `text` fields precisely because of the heap risk described below.
- Once built, fielddata is cached in the field data cache for the lifetime of the segment (until the segment is merged away or the cache evicts it).

### Why Fielddata on Text Fields Is Risky

Building fielddata for a `text` field means loading every unique analyzed term, across every document, into heap — uncompressed relative to doc values, and built on first use rather than incrementally at index time. On high-cardinality fields (free-text descriptions, logs, user comments) this can consume enormous amounts of heap very quickly.

[Inference] In practice this is one of the more common causes of node instability in clusters that enable fielddata carelessly on large text fields, because a single expensive aggregation can spike heap enough to trigger circuit breakers or garbage collection pauses that affect the whole node.

### The `fielddata_frequency_filter`

When fielddata must be enabled on a `text` field, a frequency filter can limit which terms get loaded into memory, excluding very rare or very common terms:

```json
PUT my-index/_mapping
{
  "properties": {
    "tag": {
      "type": "text",
      "fielddata": true,
      "fielddata_frequency_filter": {
        "min": 0.001,
        "max": 0.1,
        "min_segment_size": 500
      }
    }
  }
}
```

- `min` / `max` — a percentage (0–1) or absolute term-count threshold of document frequency; terms outside this range are excluded from fielddata.
- `min_segment_size` — segments smaller than this are ignored by the filter (always fully loaded if used).

This reduces memory pressure but does not eliminate the underlying risk; it's a mitigation, not a fix.

### The Preferred Pattern: `keyword` Multi-Fields

Rather than enabling fielddata on a `text` field, the standard practice is to map the field as `text` for full-text search and add a `keyword` sub-field (via multi-fields) for aggregations, sorting, and exact-match filtering. The `keyword` sub-field gets doc values automatically.

```json
PUT my-index
{
  "mappings": {
    "properties": {
      "tag": {
        "type": "text",
        "fields": {
          "raw": {
            "type": "keyword"
          }
        }
      }
    }
  }
}
```

Aggregating on `tag.raw` uses doc values, avoiding fielddata entirely:

```json
GET my-index/_search
{
  "size": 0,
  "aggs": {
    "tag_counts": {
      "terms": {
        "field": "tag.raw"
      }
    }
  }
}
```

### Disabling Doc Values

Doc values can be disabled per field to save disk space, typically for fields that will never be sorted, aggregated, or scripted on:

```json
PUT my-index
{
  "mappings": {
    "properties": {
      "session_id": {
        "type": "keyword",
        "doc_values": false
      }
    }
  }
}
```

This trades away sort/aggregation capability on that field for reduced index size. [Unverified] The exact size savings depend heavily on field cardinality and value length, so this is a case-by-case tuning decision rather than a blanket recommendation.

### Doc Values vs. Fielddata — Comparison

| Aspect | Doc Values | Fielddata |
|---|---|---|
| Storage location | Disk (filesystem cache) | JVM heap |
| Build time | Index time | Query time (lazy, first use) |
| Default state | Enabled for most types | Disabled for `text` |
| Applicable to `text`/`annotated_text` | No | Yes (if manually enabled) |
| Heap risk | Low | High on high-cardinality fields |
| Mutability | Immutable per segment | Cached, rebuilt if evicted/segment changes |

### How Doc Values Are Loaded and Cached

Even though doc values live on disk, the OS filesystem cache keeps frequently accessed doc value files in memory transparently, which is why doc values still perform well for repeated aggregations — the cost is paid by the operating system's page cache rather than the JVM heap that Elasticsearch itself manages and monitors.### Diagram: Doc Values vs. Fielddata Load Path

<svg width="100%" viewBox="0 0 680 400" role="img"><title>Doc values vs fielddata load path (svg_diagram)</title><desc>Comparison of where doc values and fielddata are built and stored: doc values at index time to disk, fielddata lazily at query time into JVM heap.</desc>
<defs><marker id="arrow" viewBox="0 0 10 10" refX="8" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M2 1L8 5L2 9" fill="none" stroke="context-stroke" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round" /></marker></defs>

<text class="th" x="40" y="30">Index time</text>
<g class="node c-teal">
<rect x="40" y="50" width="200" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="140" y="70" text-anchor="middle" dominant-baseline="central">Document indexed</text>
<text class="ts" x="140" y="90" text-anchor="middle" dominant-baseline="central">keyword, numeric, date fields</text>
</g>
<line x1="240" y1="78" x2="290" y2="78" class="arr" marker-end="url(#arrow)" />
<g class="node c-teal">
<rect x="290" y="50" width="180" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="380" y="70" text-anchor="middle" dominant-baseline="central">Doc values built</text>
<text class="ts" x="380" y="90" text-anchor="middle" dominant-baseline="central">columnar, on disk</text>
</g>
<line x1="470" y1="78" x2="520" y2="78" class="arr" marker-end="url(#arrow)" />
<g class="node c-teal">
<rect x="520" y="50" width="120" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="580" y="70" text-anchor="middle" dominant-baseline="central">OS page cache</text>
<text class="ts" x="580" y="90" text-anchor="middle" dominant-baseline="central">not JVM heap</text>
</g>

<text class="th" x="40" y="170">Query time</text>
<g class="node c-coral">
<rect x="40" y="190" width="200" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="140" y="210" text-anchor="middle" dominant-baseline="central">Aggregation on text field</text>
<text class="ts" x="140" y="230" text-anchor="middle" dominant-baseline="central">fielddata enabled</text>
</g>
<line x1="240" y1="218" x2="290" y2="218" class="arr" marker-end="url(#arrow)" />
<g class="node c-coral">
<rect x="290" y="190" width="180" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="380" y="210" text-anchor="middle" dominant-baseline="central">Fielddata built lazily</text>
<text class="ts" x="380" y="230" text-anchor="middle" dominant-baseline="central">first use, per segment</text>
</g>
<line x1="470" y1="218" x2="520" y2="218" class="arr" marker-end="url(#arrow)" />
<g class="node c-coral">
<rect x="520" y="190" width="120" height="56" rx="8" stroke-width="0.5" />
<text class="th" x="580" y="210" text-anchor="middle" dominant-baseline="central">JVM heap</text>
<text class="ts" x="580" y="230" text-anchor="middle" dominant-baseline="central">circuit breaker risk</text>
</g>

<text class="ts" x="340" y="290" text-anchor="middle">Doc values pay their cost once, at write time. Fielddata defers the cost to the first query, on heap.</text>
</svg>

### Related Topics

- **Field data circuit breakers** (`indices.breaker.fielddata.limit`) and how they prevent fielddata-triggered `OutOfMemoryError`
- **`indices.fielddata.cache.size`** and eviction behavior of the fielddata cache
- **`eager_global_ordinals`** for `keyword` fields — precomputing global ordinals to speed up aggregations on high-cardinality terms
- **Global ordinals** and their relationship to doc values in terms aggregations
- **Node-level heap sizing and the 50% RAM / 32 GB compressed-oops guidance**, since fielddata competes with other heap consumers
- **Disabling `_source`** as a related but distinct disk/storage tradeoff decision
- **Runtime fields** as an alternative to fielddata for ad hoc computed values without remapping