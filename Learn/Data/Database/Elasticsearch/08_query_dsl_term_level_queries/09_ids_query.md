### Elasticsearch Query DSL – IDs Query

#### Overview

The **IDs query** retrieves documents based on their **`_id`** field values. It is one of the simplest term-level queries — you provide a list of document IDs, and Elasticsearch returns the matching documents from the specified index.

---

#### Basic Syntax

json

```
GET /index_name/_search
{
  "query": {
    "ids": {
      "values": ["id1", "id2", "id3"]
    }
  }
}
```

The only required parameter is `values`, which accepts an array of ID strings.

---

#### Full Example

**Scenario:** Retrieve specific product documents by their known IDs.

json

```
GET /products/_search
{
  "query": {
    "ids": {
      "values": ["101", "205", "348"]
    }
  }
}
```

**Output**

json

```
{
  "hits": {
    "total": {
      "value": 3,
      "relation": "eq"
    },
    "hits": [
      { "_id": "101", "_source": { "name": "Laptop", "price": 999 } },
      { "_id": "205", "_source": { "name": "Monitor", "price": 350 } },
      { "_id": "348", "_source": { "name": "Keyboard", "price": 75 } }
    ]
  }
}
```

> Actual output depends on indexed data and cluster configuration. Behavior is not guaranteed.

---

#### Parameter Reference

| Parameter | Type | Required | Description |
| --- | --- | --- | --- |
| `values` | array of strings | ✅ Yes | List of document `_id` values to match |

The IDs query has no additional parameters beyond `values`. It does not accept `boost`, `fuzziness`, or other term-level options directly.

---

#### How It Works

The `_id` field in Elasticsearch is a special metadata field. It is:

- Automatically indexed for every document
- Not stored in `_source` by default (though accessible via the `_id` field in hits)
- Stored in a dedicated internal structure optimized for direct lookups

[Inference] Because `_id` lookups use an internal data structure rather than the standard inverted index, IDs queries are generally efficient even for large ID lists. Actual performance may vary based on cluster size and shard configuration.

---

#### Behavior with Non-Existent IDs

If one or more IDs in the `values` array do not exist in the index, Elasticsearch silently omits them — no error is raised. Only documents with matching IDs that exist are returned.

**Example:** If IDs `["101", "999"]` are provided and `999` does not exist:

json

```
{
  "hits": {
    "total": { "value": 1, "relation": "eq" },
    "hits": [
      { "_id": "101", "_source": { "name": "Laptop" } }
    ]
  }
}
```

> Behavior is not guaranteed across all versions. Always validate returned results against expected IDs when exact counts matter.

---

#### Using IDs Query in a Bool Context

The IDs query can be combined with other queries inside a `bool` query for more refined retrieval.

**Example:** Retrieve specific documents but only if they are in stock.

json

```
GET /products/_search
{
  "query": {
    "bool": {
      "must": [
        {
          "ids": {
            "values": ["101", "205", "348"]
          }
        }
      ],
      "filter": [
        {
          "term": {
            "in_stock": true
          }
        }
      ]
    }
  }
}
```

> Combining IDs query with `filter` context avoids scoring overhead for the filter clause. Behavior may vary depending on query structure and Elasticsearch version.

---

#### IDs Query vs. Alternative Approaches

| Approach | Use Case | Notes |
| --- | --- | --- |
| `ids` query | Fetch by known `_id` values | Simplest and most direct method |
| `terms` query on `_id` | Functionally equivalent | `ids` query is the idiomatic approach |
| `GET /index/_doc/id` | Fetch a single document by ID | Use for single-document retrieval outside search context |
| `Multi Get API (mget)` | Fetch multiple documents by ID | More efficient than search for pure document retrieval by ID |

> **Note:** For pure document retrieval by ID without scoring or filtering needs, the **Multi Get API (`_mget`)** is generally more appropriate than the IDs query, as it bypasses the search layer entirely.

---

#### `_mget` vs. IDs Query — Quick Comparison

json

```
// IDs query — search context, returns scored hits
GET /products/_search
{
  "query": {
    "ids": { "values": ["101", "205"] }
  }
}

// _mget — direct document fetch, no scoring
GET /products/_mget
{
  "ids": ["101", "205"]
}
```

- Use `ids` query when you need the result in a search context (e.g., combined with other queries, aggregations, or highlighting)
- Use `_mget` when you only need the raw documents and scoring is irrelevant

---

#### Practical Use Cases

- **Retrieving bookmarked or saved items** — fetch a user's saved document IDs stored in an external database
- **Batch validation** — verify which of a known set of IDs exist in an index
- **Pipeline lookups** — use within a `bool` query to scope a larger query to a pre-filtered set of documents
- **Re-fetching previously retrieved documents** — retrieve specific results from a previous query by their returned IDs

---

#### Key Points

- The IDs query matches documents by their `_id` metadata field
- `values` is the only parameter — it accepts an array of ID strings
- Non-existent IDs are silently ignored; no error is raised
- IDs query can be used inside `bool` queries for compound logic
- For pure document retrieval without scoring, prefer `_mget` over the IDs query
- The IDs query is idiomatic Elasticsearch; using a `terms` query on `_id` is functionally equivalent but less conventional