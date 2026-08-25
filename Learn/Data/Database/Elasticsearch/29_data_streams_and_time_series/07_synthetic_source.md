## Synthetic Source

### Overview

Synthetic `_source` is an Elasticsearch feature that reconstructs a document's `_source` on demand from indexed field data, rather than storing the original JSON `_source` payload verbatim on disk. Instead of persisting the raw document as submitted, Elasticsearch derives an equivalent representation at retrieval time from the values already captured in the index's doc values, stored fields, and other indexed structures.

The primary motivation is storage efficiency: the raw `_source` field is often one of the largest contributors to index size, since it duplicates every field's original value alongside the indexed/doc-values representations used for search and aggregation.

### How It Differs from Standard Source Storage

By default, Elasticsearch stores the original `_source` document as submitted, compressed, alongside the index structures used for search. With synthetic source enabled:

- The literal `_source` bytes are not stored.
- When a document is fetched (via `_source` retrieval, `_search` with source enabled, or `GET`), Elasticsearch reconstructs a JSON document from the underlying field data.
- The reconstructed document is **semantically equivalent** but not always **byte-for-byte identical** to the original — field ordering, exact formatting, and certain value representations can differ.

### Reconstruction Fidelity Considerations

Because synthetic source rebuilds documents from indexed representations rather than replaying the original bytes, several categories of information may not round-trip exactly:

- **Field order** — object key ordering in the reconstructed document is not guaranteed to match the original.
- **Array ordering** — for some field types, original array element order may not be preserved unless explicitly required by the mapping.
- **Whitespace and formatting** — cosmetic aspects of the original JSON are not retained, since only the semantic value is stored.
- **Ignored or malformed values** — fields that were rejected or coerced during indexing (e.g., a malformed number stored via `ignore_malformed`) reconstruct differently, since the original raw string may not be retrievable the same way.
- **Fields excluded from indexing** — fields mapped with `index: false` and no doc values may not be reconstructable at all, depending on type. [Inference: exact per-type reconstruction guarantees are detailed in field-type-specific documentation and have been refined across releases — verify behavior for specific field types before relying on exact round-tripping.]

### Enabling Synthetic Source

Synthetic source is configured at the mapping level:

```
PUT my-index
{
  "mappings": {
    "_source": {
      "mode": "synthetic"
    }
  }
}
```

It is also the **default source mode for Time Series Data Streams (TSDS)** and logsdb-mode indices in recent versions, reflecting its close alignment with observability and metrics use cases where storage efficiency at scale is a primary concern. [Inference: default behavior by index mode has changed across versions — confirm against the target version.]

### Field Type Compatibility

Not all field types support synthetic source reconstruction equally well. Historically, certain complex types (e.g., some `nested` configurations, or types lacking doc values) had restrictions or required additional mapping configuration to work correctly under synthetic source. Elasticsearch has progressively expanded synthetic source support across field types in successive releases. [Inference: consult the current version's field-type compatibility matrix, as this is an area of active expansion.]

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 800 300">
  <text x="400" y="28" text-anchor="middle" font-size="16" font-weight="bold" fill="#1a1a1a">Standard vs Synthetic Source (svg_diagram)</text>

  <text x="200" y="55" text-anchor="middle" font-size="13" font-weight="bold" fill="#1a1a1a">Standard Source</text>

  <rect x="60" y="70" width="280" height="45" rx="6" fill="#e8f0fe" stroke="#4285f4" stroke-width="2" />
  <text x="200" y="97" text-anchor="middle" font-size="11" fill="#1a1a1a">Original JSON document</text>

  <line x1="200" y1="115" x2="200" y2="145" stroke="#999" stroke-width="1.5" marker-end="url(#arr4)" />

  <rect x="60" y="150" width="280" height="45" rx="6" fill="#f1f3f4" stroke="#999" stroke-width="1.5" />
  <text x="200" y="177" text-anchor="middle" font-size="11" fill="#333">Stored verbatim (compressed) + indexed</text>

  <line x1="200" y1="195" x2="200" y2="220" stroke="#999" stroke-width="1.5" marker-end="url(#arr4)" />
  <text x="200" y="240" text-anchor="middle" font-size="10" fill="#555">Fetch returns exact original bytes</text>

  <text x="600" y="55" text-anchor="middle" font-size="13" font-weight="bold" fill="#1a1a1a">Synthetic Source</text>

  <rect x="460" y="70" width="280" height="45" rx="6" fill="#e8f0fe" stroke="#4285f4" stroke-width="2" />
  <text x="600" y="97" text-anchor="middle" font-size="11" fill="#1a1a1a">Original JSON document</text>

  <line x1="600" y1="115" x2="600" y2="145" stroke="#999" stroke-width="1.5" marker-end="url(#arr4)" />

  <rect x="460" y="150" width="280" height="45" rx="6" fill="#e6f4ea" stroke="#34a853" stroke-width="2" />
  <text x="600" y="177" text-anchor="middle" font-size="11" fill="#1a1a1a">Only indexed fields/doc values stored</text>

  <line x1="600" y1="195" x2="600" y2="220" stroke="#999" stroke-width="1.5" marker-end="url(#arr4)" />
  <text x="600" y="240" text-anchor="middle" font-size="10" fill="#555">Fetch reconstructs equivalent JSON on demand</text>

  </svg>

### Storage and Performance Tradeoffs

| Aspect | Standard Source | Synthetic Source |
|---|---|---|
| Disk usage | Higher (duplicate raw payload stored) | Lower (no verbatim `_source` stored) |
| Fetch cost | Low (direct decompression) | Higher (reconstruction work at read time) |
| Byte-exact round-trip | Yes | Not guaranteed |
| Typical use case | General-purpose indices, exact document retrieval needs | High-volume observability/metrics data, TSDS |

The performance cost of reconstruction is generally acceptable for typical observability access patterns (occasional document inspection, not high-throughput full-document retrieval), but may not suit workloads that frequently fetch large volumes of full source documents. [Inference: relative performance impact is workload-dependent and should be benchmarked for latency-sensitive use cases.]

### When to Use Synthetic Source

Synthetic source is most appropriate when:

- The workload is high-volume, time-series or log data (TSDS, logsdb).
- Storage cost reduction is a priority over guaranteed byte-exact source retrieval.
- Applications consuming the data can tolerate reconstructed field/array ordering rather than requiring the original literal document.
- The index's fields are of types well-supported by synthetic reconstruction.

It is less suitable when downstream systems depend on exact preservation of the original document structure, such as strict schema validation against the original payload or use cases requiring cryptographic verification of unmodified source bytes.

### Interaction with Reindexing and Update APIs

Because `_update` and `_update_by_query` operations rely on reading the current `_source` to apply partial updates, synthetic source reconstruction is used transparently as the basis for these operations. The reconstructed document, rather than a stored original, becomes the starting point for merge operations, which is consistent with append-only time series usage but worth noting for any workload that performs partial updates against synthetic-source-enabled indices.

### Key Points

- Synthetic source reconstructs `_source` from indexed field data instead of storing the raw document verbatim.
- Reduces storage significantly but does not guarantee byte-for-byte round-trip fidelity (field order, formatting, malformed values).
- Default source mode for TSDS and logsdb-mode indices in recent versions.
- Field type support has expanded over time; not all types behave identically under reconstruction.
- Best suited to high-volume time series/log workloads where storage savings outweigh exact document preservation needs.

### Related Topics

- Time Series Data Streams (TSDS) and dimension/metric fields
- `_source` filtering and disabling `_source` entirely
- Doc values and stored fields internals
- Index storage optimization strategies
- LogsDB index mode
- Mapping `ignore_malformed` and its interaction with source reconstruction