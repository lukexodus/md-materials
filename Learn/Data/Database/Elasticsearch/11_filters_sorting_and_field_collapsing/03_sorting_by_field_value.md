## Query DSL – Sorting by Field Value

### Overview

By default, Elasticsearch sorts results by `_score` in descending order. The `sort` parameter overrides or supplements this behavior, allowing results to be ordered by one or more field values, computed values, geographic distance, or script output.

Sorting by field value is used when relevance ranking is irrelevant or secondary — for example, sorting by date, price, alphabetical order, or numeric priority.

---

### Basic Syntax

```json
GET /index/_search
{
  "sort": [
    { "publish_date": { "order": "desc" } }
  ],
  "query": {
    "match_all": {}
  }
}
```

The `sort` parameter is a top-level sibling of `query`. It accepts an array of sort clauses evaluated in order — the first clause is the primary sort, subsequent clauses break ties.

---

### Shorthand Syntax

For ascending order on a single field, the field name alone is sufficient:

```json
{
  "sort": ["publish_date"]
}
```

This is equivalent to `{ "publish_date": { "order": "asc" } }`.

For descending order using shorthand:

```json
{
  "sort": ["_score", { "publish_date": "desc" }]
}
```

---

### Sort Order

| Value | Description |
|---|---|
| `asc` | Ascending (lowest first) |
| `desc` | Descending (highest first) |

Default order when not specified:
- `_score` → `desc`
- All other fields → `asc`

---

### Sorting on `_score`

`_score` can be included explicitly in a multi-field sort:

```json
{
  "sort": [
    { "publish_date": { "order": "desc" } },
    { "_score": { "order": "desc" } }
  ],
  "query": {
    "match": { "body": "distributed systems" }
  }
}
```

Documents are sorted by date first; among documents with the same date, relevance score breaks ties.

[Inference] When sorting primarily by a field other than `_score`, relevance scoring is still computed if a scoring query is present, but it only contributes to ranking where earlier sort clauses produce ties. If no scoring query is needed at all, using `filter` context and omitting `_score` from the sort may reduce overhead. Behavior may vary.

---

### Field Value Sort Parameters

```json
{
  "sort": [
    {
      "price": {
        "order": "asc",
        "missing": "_last",
        "unmapped_type": "float",
        "mode": "min",
        "numeric_type": "double"
      }
    }
  ]
}
```

#### `order`

Sort direction: `asc` or `desc`.

#### `missing`

Controls placement of documents where the sort field has no value:

| Value | Behavior |
|---|---|
| `"_last"` | Documents with missing values appear last |
| `"_first"` | Documents with missing values appear first |
| Any literal value | Missing values are treated as if they held this value |

```json
{ "price": { "order": "asc", "missing": 0 } }
```

#### `unmapped_type`

Prevents errors when the sort field is not mapped in one or more indices in a multi-index search. Elasticsearch treats unmapped fields as if they were of the specified type with no values:

```json
{ "price": { "order": "asc", "unmapped_type": "float" } }
```

Without this, sorting on an unmapped field raises an error.

#### `mode`

Applies when the sort field contains **multiple values** per document (multi-value fields or nested fields). Defines which value is used for sorting:

| Mode | Description |
|---|---|
| `min` | Use the lowest value |
| `max` | Use the highest value |
| `sum` | Use the sum of all values (numeric only) |
| `avg` | Use the average of all values (numeric only) |
| `median` | Use the median of all values (numeric only) |

```json
{
  "sort": [
    { "ratings": { "order": "desc", "mode": "avg" } }
  ]
}
```

#### `numeric_type`

Coerces the sort field value to a specific numeric type before sorting. Useful when sorting across indices where the same field has different numeric mappings:

| Value | Description |
|---|---|
| `"long"` | Coerce to 64-bit integer |
| `"double"` | Coerce to 64-bit float |
| `"date"` | Coerce to date (milliseconds since epoch) |
| `"date_nanos"` | Coerce to date with nanosecond precision |

---

### Multi-Field Sorting

Sort clauses are evaluated in order. The next clause is used only when the preceding clause produces equal values:

```json
{
  "sort": [
    { "category": { "order": "asc" } },
    { "publish_date": { "order": "desc" } },
    { "_score": { "order": "desc" } }
  ]
}
```

Primary sort: `category` ascending. Tie-break: `publish_date` descending. Final tie-break: relevance score.

---

### Sorting on `_doc`

`_doc` sorts by internal Lucene document order — the order in which documents are stored on disk within a segment. It has no semantic meaning but is the most performant sort option:

```json
{
  "sort": ["_doc"]
}
```

**Key point:** `_doc` sort is the recommended option when using the Scroll API for bulk document export, where order does not matter and maximum throughput is the goal.

---

### Sorting on Keyword Fields

Keyword fields sort lexicographically (alphabetical byte order):

```json
{
  "sort": [
    { "author.keyword": { "order": "asc" } }
  ]
}
```

**Key point:** Do not sort on `text` fields. Text fields are analyzed and not optimized for sorting. Elasticsearch will reject or warn on attempts to sort on a `text` field without a `fielddata` enable, which is discouraged.

For fields that need both full-text search and sorting, use a `text` field with a `keyword` sub-field:

```json
"author": {
  "type": "text",
  "fields": {
    "keyword": { "type": "keyword" }
  }
}
```

Sort on `author.keyword`; search on `author`.

---

### Sorting on `text` Fields with `fielddata`

Sorting on `text` fields is possible by enabling `fielddata` on the mapping, but this is strongly discouraged in production:

```json
PUT /index/_mapping
{
  "properties": {
    "description": {
      "type": "text",
      "fielddata": true
    }
  }
}
```

Enabling `fielddata` loads all analyzed token data for the field into the JVM heap for every document in the index. This consumes substantial memory and can cause heap pressure.

[Inference] Enabling `fielddata` on high-cardinality `text` fields in large indices poses a significant risk of heap exhaustion and performance degradation. The `keyword` sub-field approach is the appropriate alternative in nearly all cases. Behavior and memory impact may vary by index size and available heap.

---

### Sorting on Nested Fields

When the sort field is inside a `nested` object, the `nested` parameter is required to define the nested path and optionally filter which nested objects contribute to the sort value:

```json
{
  "sort": [
    {
      "reviews.score": {
        "order": "desc",
        "mode": "avg",
        "nested": {
          "path": "reviews",
          "filter": {
            "term": { "reviews.verified": true }
          }
        }
      }
    }
  ]
}
```

- `path` — the nested field path.
- `filter` — restricts which nested objects are considered when computing the sort value. Only nested objects matching this filter contribute to the `mode` calculation.

[Inference] Omitting the `nested` parameter when sorting on nested fields may produce an error or unexpected results. The behavior depends on Elasticsearch version. Always specify `nested.path` when the field is inside a `nested` mapping.

---

### Script-Based Sorting

A sort value can be computed at query time using a Painless script:

```json
{
  "sort": [
    {
      "_script": {
        "type": "number",
        "script": {
          "source": "doc['base_price'].value * params.tax_rate",
          "params": {
            "tax_rate": 1.12
          }
        },
        "order": "asc"
      }
    }
  ]
}
```

| Parameter | Description |
|---|---|
| `type` | Return type of the script: `number` or `string` |
| `script.source` | Painless script source |
| `script.params` | Parameters passed into the script |
| `order` | Sort direction |

[Inference] Script-based sorting executes the script against every matched document and is significantly more expensive than field value sorting. It bypasses doc values and cannot use the sort cache. Use only when computed sort values cannot be indexed ahead of time. Behavior and performance may vary.

---

### Geographic Distance Sorting

Results can be sorted by distance from a geographic point. This is covered under geo queries but is part of the same `sort` mechanism:

```json
{
  "sort": [
    {
      "_geo_distance": {
        "location": { "lat": 14.5995, "lon": 120.9842 },
        "order": "asc",
        "unit": "km",
        "mode": "min",
        "distance_type": "arc"
      }
    }
  ]
}
```

---

### Sort and `_source`

Sorting does not affect which fields are returned in `_source`. However, the sort value used for each document is returned in the `sort` array of each hit:

```json
"hits": [
  {
    "_id": "42",
    "_score": null,
    "_source": { ... },
    "sort": [1704067200000]
  }
]
```

- `_score` is `null` when sort does not include `_score` and no scoring query is used.
- `sort` contains the actual value(s) used for sorting — useful for **search after** pagination.

---

### Interaction with Pagination: `search_after`

The `sort` values returned per document enable cursor-based pagination via `search_after`. The sort array from the last document of a page is passed as `search_after` in the next request:

```json
{
  "sort": [
    { "publish_date": "desc" },
    { "_id": "asc" }
  ],
  "search_after": [1704067200000, "article-99"],
  "size": 10
}
```

**Key point:** A tiebreaker field with unique values (typically `_id`) must be included as the final sort clause to produce a consistent, stable sort order across pages. Without it, documents with equal sort values on the primary field may appear in different positions across pages.

---

### Doc Values and Sort Performance

Field value sorting relies on **doc values** — a columnar, on-disk data structure maintained alongside the inverted index. Doc values are enabled by default for most non-`text` field types.

| Field type | Doc values by default |
|---|---|
| `keyword` | Yes |
| `numeric` (long, float, etc.) | Yes |
| `date` | Yes |
| `boolean` | Yes |
| `text` | No (requires `fielddata`) |
| `object` / `nested` | No (sort on sub-fields) |

Sorting on a field without doc values (and without `fielddata`) will fail. Do not disable doc values on fields intended for sorting.

---

### Track Scores When Sorting by Field

When sorting by a non-score field, `_score` is not computed by default (it returns `null`). To force score computation alongside field sorting:

```json
{
  "sort": [
    { "publish_date": "desc" }
  ],
  "track_scores": true,
  "query": {
    "match": { "body": "elasticsearch" }
  }
}
```

With `track_scores: true`, `_score` is populated for all hits even though it does not drive the sort order.

[Inference] Enabling `track_scores` adds scoring overhead equivalent to running a scoring query. Use only when the score value is needed alongside a non-score sort, such as for display or secondary analysis. Behavior may vary.

---

### Limitations

| Limitation | Detail |
|---|---|
| `text` fields | Cannot sort without enabling `fielddata`; discouraged |
| Doc values required | Sorting fails on fields with `doc_values: false` |
| Script sort cost | No caching; evaluated per document per query |
| `now` in sort | [Inference] Dynamic date expressions in sort may not behave consistently across shard executions |
| Nested sort without `nested` param | Requires explicit `nested.path`; behavior without it is undefined |

---

### Summary

| Aspect | Detail |
|---|---|
| Default sort | `_score` descending |
| Sort parameter | Top-level array; clauses evaluated in order |
| Field types suitable | `keyword`, numeric, `date`, `boolean` |
| Multi-value fields | Use `mode`: `min`, `max`, `avg`, `sum`, `median` |
| Missing values | Control with `missing`: `_first`, `_last`, or literal |
| Unmapped fields | Use `unmapped_type` to avoid errors in multi-index search |
| Nested fields | Requires `nested.path`; optionally `nested.filter` |
| Script sort | Supported; expensive; use sparingly |
| Pagination integration | `sort` values in hits enable `search_after` cursor pagination |
| Score alongside sort | Use `track_scores: true` |
| Performance basis | Doc values (columnar on-disk structure) |