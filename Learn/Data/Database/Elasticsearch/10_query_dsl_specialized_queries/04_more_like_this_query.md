## Query DSL – Specialized Queries: `more_like_this` Query

### Overview

The `more_like_this` (MLT) query finds documents that are similar to a given set of input texts or documents. It works by extracting representative terms from the input, then constructing a query to find documents containing those terms.

It is commonly used for content recommendation, duplicate detection, and exploratory search.

---

### How It Works

The MLT query operates in two phases:

1. **Term selection** — Elasticsearch analyzes the input text and selects the most representative terms using statistical filters (minimum/maximum document frequency, term frequency thresholds, etc.).
2. **Query construction** — The selected terms are assembled into a `should` boolean query and executed against the index.

[Inference] The quality of results depends heavily on the analyzer used and the statistical distribution of terms in the index. Behavior may vary across datasets and configurations.

---

### Basic Syntax

```json
GET /index/_search
{
  "query": {
    "more_like_this": {
      "fields": ["title", "body"],
      "like": "Elasticsearch is a distributed search engine",
      "min_term_freq": 1,
      "max_query_terms": 12
    }
  }
}
```

---

### Input Types

The `like` parameter accepts multiple input forms.

#### Plain text string

```json
"like": "distributed systems and search engines"
```

#### Array of strings

```json
"like": ["search engine", "inverted index", "relevance scoring"]
```

#### Document reference (by ID)

```json
"like": [
  {
    "_index": "articles",
    "_id": "42"
  }
]
```

#### Inline document (artificial document)

```json
"like": [
  {
    "doc": {
      "title": "Understanding Sharding",
      "body": "Sharding splits an index into smaller pieces for scalability."
    }
  }
]
```

You can mix all of these within a single `like` array.

---

### Core Parameters

| Parameter | Type | Default | Description |
|---|---|---|---|
| `fields` | array | `_all` / all text fields | Fields to analyze and match against |
| `like` | string / array | *(required)* | Input text or document references |
| `unlike` | string / array | — | Terms to avoid; suppresses similarity to these inputs |
| `max_query_terms` | integer | `25` | Max number of terms selected for the query |
| `min_term_freq` | integer | `2` | Minimum frequency of a term in the input document |
| `min_doc_freq` | integer | `5` | Minimum number of docs a term must appear in (corpus-wide) |
| `max_doc_freq` | integer | unbounded | Excludes overly common terms (like stopwords) |
| `min_word_length` | integer | `0` | Minimum character length for a term to be selected |
| `max_word_length` | integer | `0` (unbounded) | Maximum character length for a term |
| `stop_words` | array | — | Terms to explicitly exclude from selection |
| `analyzer` | string | field's default analyzer | Analyzer applied to the input text |
| `minimum_should_match` | string | `"30%"` | How many selected terms must match in a result document |
| `boost_terms` | float | `0` (disabled) | Applies a boost to terms using term frequency |
| `include` | boolean | `false` | Whether to include the input documents themselves in results |
| `boost` | float | `1.0` | Boost factor for the entire MLT query |

---

### Term Selection Filters (Pipeline)

Understanding how terms are selected is critical to tuning MLT.

```
Input Text
    │
    ▼
Analyze with `analyzer`
    │
    ▼
Filter by `min_word_length` / `max_word_length`
    │
    ▼
Filter by `stop_words`
    │
    ▼
Filter by `min_term_freq` (frequency in input)
    │
    ▼
Filter by `min_doc_freq` / `max_doc_freq` (corpus frequency)
    │
    ▼
Select top N terms by `max_query_terms`
    │
    ▼
Build `should` boolean query
```

[Inference] Terms that survive all filters but are still too generic may degrade result quality. Tuning `min_doc_freq` and `max_doc_freq` together is often the most effective lever.

---

### The `unlike` Parameter

`unlike` specifies inputs whose representative terms are *excluded* from the constructed query. This allows negative steering.

```json
{
  "query": {
    "more_like_this": {
      "fields": ["body"],
      "like": "machine learning and neural networks",
      "unlike": "deep learning transformers",
      "min_term_freq": 1,
      "max_query_terms": 10
    }
  }
}
```

[Inference] `unlike` does not act as a hard filter on result documents — it only removes terms from query construction. Documents mentioning those concepts may still appear if they match via other selected terms. Behavior may vary.

---

### Using Multiple Document References

MLT can aggregate term selection across multiple source documents:

```json
{
  "query": {
    "more_like_this": {
      "fields": ["title", "summary"],
      "like": [
        { "_index": "articles", "_id": "10" },
        { "_index": "articles", "_id": "23" },
        "additional free text input"
      ],
      "min_term_freq": 1,
      "min_doc_freq": 3,
      "max_query_terms": 15
    }
  }
}
```

Terms are extracted from all inputs collectively before the frequency filters are applied.

---

### Combining with Other Queries

MLT integrates naturally into compound queries.

#### Scoped to a category

```json
{
  "query": {
    "bool": {
      "must": {
        "more_like_this": {
          "fields": ["body"],
          "like": { "_index": "posts", "_id": "7" },
          "min_term_freq": 1,
          "max_query_terms": 12
        }
      },
      "filter": {
        "term": { "category": "technology" }
      }
    }
  }
}
```

#### Excluding the source document

```json
{
  "query": {
    "bool": {
      "must": {
        "more_like_this": {
          "fields": ["title", "body"],
          "like": { "_index": "articles", "_id": "42" },
          "min_term_freq": 1,
          "max_query_terms": 10
        }
      },
      "must_not": {
        "ids": { "values": ["42"] }
      }
    }
  }
}
```

Note: The `include` parameter (`false` by default) already excludes input documents when using document references. The `must_not` + `ids` approach is an explicit alternative.

---

### Field Weighting

You can boost specific fields to influence which terms carry more weight in similarity matching:

```json
{
  "query": {
    "more_like_this": {
      "fields": ["title^3", "tags^2", "body"],
      "like": "distributed consensus algorithms",
      "min_term_freq": 1,
      "max_query_terms": 12
    }
  }
}
```

[Inference] Field boosts affect scoring of matched documents, not necessarily which terms are selected during extraction. Actual behavior depends on Elasticsearch version and internal implementation. Behavior may vary.

---

### Cross-Index Similarity

Document references can point to different indices:

```json
"like": [
  { "_index": "blog_posts", "_id": "5" },
  { "_index": "research_papers", "_id": "18" }
]
```

[Inference] Cross-index MLT queries rely on term statistics from the target index (where the query executes), not the source index. This can affect term selection quality when index compositions differ significantly.

---

### Performance Considerations

- MLT performs a **terms extraction pass** before the main search. For large inputs or many document references, this adds latency.
- `max_query_terms` directly controls the size of the generated boolean query. Higher values increase recall but add query overhead.
- `min_doc_freq` should be tuned to corpus size. A default of `5` may be too high for small indices, resulting in no terms being selected and empty results.
- [Inference] On large indices with many fields, reducing `fields` to only relevant ones may improve performance. Behavior may vary based on cluster configuration.

---

### Common Failure: No Results

A frequent issue is MLT returning zero results. Typical causes:

| Cause | Fix |
|---|---|
| `min_doc_freq` too high for index size | Lower to `1` or `2` for small indices |
| `min_term_freq` too high for short input | Lower to `1` |
| Input terms all filtered as stopwords | Check analyzer or set `stop_words: []` |
| `max_query_terms` too low | Increase to allow more candidate terms |
| Input document has no analyzed text | Verify field mappings and analyzer output |

---

### Retrieving Selected Terms (Debugging)

To inspect which terms MLT selects, use the **Termvectors API** on the input document, which reveals analyzed terms, frequencies, and statistics — the same data MLT uses internally:

```json
GET /articles/_termvectors/42
{
  "fields": ["title", "body"],
  "term_statistics": true,
  "field_statistics": true
}
```

[Inference] The terms shown in termvectors may not map 1:1 to terms selected by MLT, since MLT applies additional filters (`min_doc_freq`, `max_query_terms`, etc.) after extraction. Use termvectors as a diagnostic approximation, not a guaranteed mirror of MLT internals.

---

### Limitations

- MLT is **not a semantic similarity** query. It operates on term overlap, not meaning. Two documents about the same concept using different vocabulary will score poorly.
- It does not use embeddings or vector representations. For semantic similarity, use the `knn` query with dense vector fields.
- MLT quality degrades on very short texts (insufficient term diversity for selection).
- [Inference] MLT is sensitive to index composition. Adding or removing many documents can shift document frequency statistics and alter results over time.

---

### Summary

| Aspect | Detail |
|---|---|
| Similarity basis | Term frequency / document frequency statistics |
| Input types | Free text, document IDs, inline docs, mixed |
| Key tuning params | `min_doc_freq`, `min_term_freq`, `max_query_terms` |
| Negative steering | `unlike` parameter |
| Not suitable for | Semantic / conceptual similarity |
| Complementary API | Termvectors (for debugging term selection) |