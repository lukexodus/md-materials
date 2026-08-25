## Query DSL – Specialized Queries: Pinned Query

### Overview

The `pinned` query promotes specific documents to the top of search results, forcing them to appear before any organically scored documents. The pinned documents receive an artificially high relevance score, while the remaining results are produced by an underlying `organic` query that runs normally.

It is used in scenarios such as editorial curation, sponsored results, featured content promotion, and search merchandising.

---

### Basic Syntax

```json
GET /index/_search
{
  "query": {
    "pinned": {
      "ids": ["doc-1", "doc-2", "doc-3"],
      "organic": {
        "match": {
          "body": "elasticsearch performance"
        }
      }
    }
  }
}
```

Pinned documents appear first, in the order specified by `ids`, followed by results from the `organic` query ranked by their natural scores.

---

### Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `ids` | array of strings | Yes (or `docs`) | Document IDs to pin; matched against the queried index |
| `docs` | array of objects | Yes (or `ids`) | Pin documents by `_index` + `_id`; used for cross-index pinning |
| `organic` | query object | Yes | The underlying query that produces the rest of the results |

`ids` and `docs` are mutually exclusive — only one may be present per `pinned` query.

---

### Pinning by ID

Pins documents from the index being searched, identified by `_id` alone:

```json
{
  "query": {
    "pinned": {
      "ids": ["featured-guide", "getting-started"],
      "organic": {
        "match": {
          "title": "elasticsearch"
        }
      }
    }
  }
}
```

---

### Pinning by Document Reference (`docs`)

Used when pinned documents may reside in different indices, or when you need to specify the index explicitly:

```json
{
  "query": {
    "pinned": {
      "docs": [
        { "_index": "promotions", "_id": "promo-42" },
        { "_index": "articles", "_id": "article-7" }
      ],
      "organic": {
        "match": {
          "body": "getting started"
        }
      }
    }
  }
}
```

[Inference] When using `docs` with multiple indices, the target index context of the search request still applies. Cross-index behavior depends on whether the query is executed against an alias or multi-index pattern that includes the referenced indices. Behavior may vary.

---

### Scoring Behavior

Pinned documents are assigned a score equal to `Float.MAX_VALUE / 4` internally — a fixed very large number that pushes them above any organically scored document.

[Inference] The exact score value assigned to pinned documents is an implementation detail and may differ across Elasticsearch versions. Do not rely on this value for external logic. Behavior may vary.

Organic results retain their normal relevance scores and are ranked among themselves as usual, appearing after all pinned documents.

---

### Order of Pinned Documents

Pinned documents appear in the **exact order** specified in the `ids` or `docs` array, regardless of their organic relevance scores.

```json
"ids": ["doc-c", "doc-a", "doc-b"]
```

Result order: `doc-c` → `doc-a` → `doc-b` → (organic results)

---

### Behavior When a Pinned Document Does Not Match the Organic Query

If a pinned document exists in the index but does not match the `organic` query, it is still returned and pinned at the top.

[Inference] This is intentional — the `pinned` query is designed for editorial override, not filtered promotion. If you need pinned documents to also satisfy certain conditions, apply those conditions via a wrapping `bool` query with a `filter`. Behavior may vary by version.

---

### Behavior When a Pinned Document Is Not Found

If a pinned document ID does not exist in the index, it is silently omitted from results. No error is raised.

---

### Combining with Filters

To restrict both pinned and organic results to a subset of documents, wrap the `pinned` query inside a `bool` query:

```json
{
  "query": {
    "bool": {
      "must": {
        "pinned": {
          "ids": ["featured-1"],
          "organic": {
            "match": { "body": "logging best practices" }
          }
        }
      },
      "filter": {
        "term": { "status": "published" }
      }
    }
  }
}
```

[Inference] The `filter` applies to all results including pinned documents. A pinned document that does not satisfy the filter clause will be excluded. Behavior may vary.

---

### Pagination Behavior

Pinned documents occupy the first positions in the result set. When paginating with `from` / `size`:

- On page 1 (`from: 0`), pinned documents appear first.
- On subsequent pages (`from: N` where N ≥ number of pinned docs), pinned documents no longer appear — only organic results fill those pages.

[Inference] There is no mechanism to re-pin documents on subsequent pages. If your use case requires pinned items to persist across pages, that logic must be handled at the application layer.

---

### Deduplication with Organic Results

If a pinned document also appears in the organic result set, it is **not duplicated**. It appears only once, in its pinned position.

---

### Use with Rules-Based Search (Elasticsearch Relevance Engine)

Elasticsearch provides a higher-level **Query Rules** API (introduced in 8.10) that can apply pinning and other result modifications based on query-time conditions, without requiring the client to construct `pinned` queries manually.

[Inference] For deployments using Query Rules, the `pinned` query may be constructed internally by Elasticsearch when a matching rule fires, rather than being authored explicitly by the client. This is a distinct workflow from direct use of the `pinned` query clause.

---

### Limitations

| Limitation | Detail |
|---|---|
| No conditional pinning | All listed IDs are pinned unconditionally for the query |
| No per-pin boost control | All pinned docs receive the same fixed score; relative ordering among them is positional only |
| No cross-page persistence | Pinned items do not follow across paginated result pages |
| `ids` and `docs` are mutually exclusive | Cannot mix both in one `pinned` clause |
| Not a filter | Pinned docs appear even if they do not match the `organic` query |

---

### Comparison with Related Approaches

| Approach | Mechanism | Use Case |
|---|---|---|
| `pinned` query | Fixed score override by ID | Editorial promotion, featured results |
| `function_score` | Score modification via functions | Flexible relevance tuning |
| `boosting` query | Positive/negative query scoring | Demoting unwanted results |
| Query Rules API | Server-side conditional rule application | Automated merchandising, A/B rules |

---

### Summary

| Aspect | Detail |
|---|---|
| Purpose | Force specific documents to top of results |
| Pin input | Document IDs (`ids`) or index+ID pairs (`docs`) |
| Ordering | Exact order of `ids` / `docs` array |
| Organic query | Required; produces remaining ranked results |
| Deduplication | Pinned docs appear once only |
| Not found handling | Missing pinned IDs are silently skipped |
| Filter interaction | Wrap in `bool` + `filter` to constrain pinned docs |