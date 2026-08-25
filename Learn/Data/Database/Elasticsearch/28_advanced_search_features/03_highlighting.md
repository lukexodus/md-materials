## Highlighting

### Overview

Highlighting returns fragments of matched fields with the matching terms wrapped in markup (by default `<em>` tags), allowing search results to display context around why a document matched — the familiar bolded-snippet pattern in search UIs. It is requested via a `highlight` section in the `_search` request, alongside the main `query`.

**Key Points**

- Three highlighter implementations are available: **unified** (default), **plain**, and **fvh** (fast vector highlighter), differing in accuracy, performance, and field storage requirements.
- Highlighting requires either term vectors, the field's original source (`_source`), or on-the-fly re-analysis, depending on the highlighter chosen.
- Highlighting operates on the fields specified in `highlight.fields`, independently of which fields were actually matched by the query, though matched fields are the typical target.

### Basic Usage

**Example**

```json
GET /articles/_search
{
  "query": {
    "match": { "content": "elasticsearch aggregations" }
  },
  "highlight": {
    "fields": {
      "content": {}
    }
  }
}
```

**Output**

```json
{
  "hits": {
    "hits": [
      {
        "_source": { "content": "Elasticsearch aggregations enable powerful analytics..." },
        "highlight": {
          "content": [
            "<em>Elasticsearch</em> <em>aggregations</em> enable powerful analytics..."
          ]
        }
      }
    ]
  }
}
```

The `highlight` object in each hit contains an array of fragments per field, separate from `_source` — the original field value is untouched.

### The Three Highlighters

#### Unified Highlighter (default)

- Uses the Lucene `UnifiedHighlighter`, which breaks the field into sentences (using a `BreakIterator`) and scores fragments using the same relevance logic as the main query, so returned fragments tend to align well with what actually drove the match.
- Works out of the box without requiring `term_vector` mapping settings — it re-analyzes field content or uses `_source` as needed — making it the lowest-setup option.
- Generally the recommended default for typical use cases due to this balance of accuracy and simplicity.

#### Plain Highlighter

- Re-analyzes the field content at query time using the field's configured analyzer, then matches query terms against the resulting tokens.
- Does not require term vectors, but re-analysis at query time is more expensive than reading precomputed vectors — cost that scales with field size and query volume.
- Struggles with accuracy on complex queries involving multiple clauses (e.g., nested `bool` queries with multiple `should` conditions), since it has less precise visibility into exactly which query component matched where, compared to the vector-based approach.
- Generally the least favored of the three for anything beyond simple queries on small fields.

#### Fast Vector Highlighter (FVH)

- Requires the field to be mapped with `"term_vector": "with_positions_offsets"`, which precomputes term positions at index time.
- Because positions are precomputed, the FVH avoids re-analysis at query time, making it the fastest option for **large fields** specifically — the performance benefit is most pronounced when field values are long (e.g., full document bodies) rather than short (e.g., titles).
- Supports additional customization not available in the other two: `boundary_scanner` options for custom fragment boundaries, and `matched_fields` for highlighting based on matches across multiple analyzed variants of the same underlying field.
- Tradeoff: the `with_positions_offsets` term vector setting increases index size and indexing time, since Lucene must store position/offset data per term at index time.

**Example — mapping for FVH**

```json
PUT /articles
{
  "mappings": {
    "properties": {
      "content": {
        "type": "text",
        "term_vector": "with_positions_offsets"
      }
    }
  }
}
```

```json
GET /articles/_search
{
  "query": { "match": { "content": "aggregations" } },
  "highlight": {
    "type": "fvh",
    "fields": {
      "content": {}
    }
  }
}
```

### Choosing a Highlighter

| Highlighter | Setup requirement | Best for | Query-time cost |
| --- | --- | --- | --- |
| Unified (default) | None | General-purpose, most use cases | Moderate |
| Plain | None | Small fields, simple queries | Higher (re-analysis) |
| FVH | `term_vector: with_positions_offsets` mapping | Large fields, high query volume, custom boundary control | Lowest (precomputed) |

===MERMAID_DIAGRAM===

flowchart TD

A[Search request with highlight] --> B{Highlighter type}

B -->|unified, default| C[BreakIterator sentence scoring]

B -->|plain| D[Re-analyze field at query time]

B -->|fvh| E[Read precomputed term vectors]

C --> F[Return scored fragments]

D --> F

E --> F

E -.requires.-> G[term_vector: with_positions_offsets mapping]

### Fragment Control

Common parameters that apply across highlighters (with some highlighter-specific variation in support):

- **`fragment_size`**: approximate character length of each returned fragment (default 100).
- **`number_of_fragments`**: how many fragments to return per field (default 5); setting this to `0` returns the entire field content with matches highlighted, rather than discrete fragments.
- **`pre_tags` / `post_tags`**: customize the wrapping markup, replacing the default `<em>`/`</em>` — useful for applying CSS classes (e.g., `<mark class="hl">`) instead of bare tags.
- **`order`**: `score` sorts returned fragments by relevance score rather than by position of appearance in the field.

**Example**

```json
GET /articles/_search
{
  "query": { "match": { "content": "aggregations" } },
  "highlight": {
    "pre_tags": ["<mark class=\"hl\">"],
    "post_tags": ["</mark>"],
    "fragment_size": 150,
    "number_of_fragments": 3,
    "order": "score",
    "fields": {
      "content": {}
    }
  }
}
```

### Highlighting on Multi-Field Mappings

A field indexed with multiple analyzed variants (via `fields` sub-mappings, e.g., a `text` field plus a `keyword` sub-field, or separate analyzers for different languages) can use `matched_fields` (FVH only) to combine match information from several variants into a single highlighted result — for example, highlighting based on both a stemmed and an unstemmed analysis of the same content so exact and stemmed matches are both reflected.

**Example**

```json
GET /articles/_search
{
  "query": {
    "multi_match": {
      "query": "aggregation",
      "fields": ["content", "content.exact"]
    }
  },
  "highlight": {
    "type": "fvh",
    "fields": {
      "content": {
        "matched_fields": ["content", "content.exact"]
      }
    }
  }
}
```

### Performance Considerations

- Highlighting is computed per matching document at query time (or read from precomputed vectors for FVH), so it adds cost proportional to the number of hits actually highlighted — this is naturally bounded by pagination (`size`), since only returned hits are highlighted, not the full match set.
- For very large fields, the plain highlighter's query-time re-analysis cost can become significant; FVH is the more scalable choice at the cost of extra index storage. [Inference] The unified highlighter sits between these in typical cost, benefiting from not requiring term vectors while avoiding some of the plain highlighter's overhead through its sentence-based approach — exact relative performance depends on field size, query complexity, and cluster resources, and is best confirmed with benchmarking on representative data.
- `require_field_match` (default `true`) restricts highlighting to only the field that actually matched the query; setting it to `false` highlights the field for terms matching anywhere in the query regardless of which field triggered the match — useful in some multi-field search UIs but can produce misleading fragments if applied without care.

### Related Topics

- Term vectors and their broader use beyond highlighting (e.g., "more like this" queries)
- `multi_match` query field combination strategies
- Source filtering (`_source` includes/excludes) and its interaction with highlighting
- Analyzer design for stemmed vs. exact-match sub-fields
- Snippet-based search UI patterns
- Percolator queries as a related but distinct "match explanation" mechanism