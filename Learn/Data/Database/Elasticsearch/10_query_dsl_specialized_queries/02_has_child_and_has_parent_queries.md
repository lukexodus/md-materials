## Query DSL – Joining Queries: `has_child` and `has_parent` Queries

### Overview

The `has_child` and `has_parent` queries operate on indices that use the **`join` field type** — Elasticsearch's mechanism for modeling parent-child relationships between documents stored in the **same index**. Unlike nested documents, parent and child documents are independent top-level documents that are linked by a join field value and routed to the same shard.

- **`has_child`** — returns parent documents whose child documents match a given query.
- **`has_parent`** — returns child documents whose parent document matches a given query.

---

### The `join` Field Type

Before using either query, the index must define a `join` field that declares the relationship names and their hierarchy.

```json
PUT /company
{
  "mappings": {
    "properties": {
      "name":        { "type": "keyword" },
      "description": { "type": "text" },
      "salary":      { "type": "integer" },
      "department":  { "type": "keyword" },
      "join_field": {
        "type": "join",
        "relations": {
          "department": "employee"
        }
      }
    }
  }
}
```

This declares `department` as the parent type and `employee` as the child type. A single `join` field can define multiple parent-child relationships.

---

### Indexing Parent and Child Documents

#### Indexing a Parent Document

```json
PUT /company/_doc/1?routing=1
{
  "name": "Engineering",
  "description": "Software development department",
  "join_field": {
    "name": "department"
  }
}
```

#### Indexing a Child Document

Child documents must specify:
- The join field `name` set to the child type.
- The `parent` field set to the parent document's ID.
- The same `routing` value as the parent (to land on the same shard).

```json
PUT /company/_doc/101?routing=1
{
  "name":       "alice",
  "salary":     95000,
  "department": "engineering",
  "join_field": {
    "name":   "employee",
    "parent": "1"
  }
}

PUT /company/_doc/102?routing=1
{
  "name":       "bob",
  "salary":     120000,
  "department": "engineering",
  "join_field": {
    "name":   "employee",
    "parent": "1"
  }
}
```

> [Inference] The `routing` parameter is critical. Parent and child documents must reside on the same shard for join queries to work correctly. Omitting or mismatching routing values may cause child documents to be unreachable from parent queries and vice versa. Behavior may vary by Elasticsearch version.

---

### Sample Data Setup

```json
PUT /company/_doc/2?routing=2
{
  "name": "Marketing",
  "description": "Brand and communications department",
  "join_field": { "name": "department" }
}

PUT /company/_doc/201?routing=2
{
  "name": "carol", "salary": 78000, "department": "marketing",
  "join_field": { "name": "employee", "parent": "2" }
}

PUT /company/_doc/202?routing=2
{
  "name": "dave", "salary": 65000, "department": "marketing",
  "join_field": { "name": "employee", "parent": "2" }
}

PUT /company/_doc/3?routing=3
{
  "name": "Data",
  "description": "Data science and analytics department",
  "join_field": { "name": "department" }
}

PUT /company/_doc/301?routing=3
{
  "name": "eve", "salary": 110000, "department": "data",
  "join_field": { "name": "employee", "parent": "3" }
}
```

---

### `has_child` Query

Returns **parent documents** that have at least one child document matching the inner query.

#### Basic Syntax

```json
GET /company/_search
{
  "query": {
    "has_child": {
      "type":                "employee",
      "query":               { <query_on_child_fields> },
      "score_mode":          "none",
      "min_children":        1,
      "max_children":        100,
      "ignore_unmapped":     false
    }
  }
}
```

| Parameter | Required | Description |
|-----------|----------|-------------|
| `type` | ✅ Yes | The child relationship name as defined in the `join` field. |
| `query` | ✅ Yes | Query executed against child documents. |
| `score_mode` | ❌ No | How child scores contribute to the parent score. Default: `none`. |
| `min_children` | ❌ No | Minimum number of matching children required. Default: `1`. |
| `max_children` | ❌ No | Maximum number of matching children allowed. |
| `ignore_unmapped` | ❌ No | Silently ignore query if `type` is not mapped. Default: `false`. |

---

#### `score_mode` Options for `has_child`

| `score_mode` | Behavior |
|-------------|----------|
| `none` (default) | Parent score is not influenced by child scores |
| `avg` | Average of matching child scores |
| `sum` | Sum of matching child scores |
| `min` | Lowest matching child score |
| `max` | Highest matching child score |

---

#### Example: Find Departments with High-Earning Employees

```json
GET /company/_search
{
  "query": {
    "has_child": {
      "type": "employee",
      "query": {
        "range": {
          "salary": { "gte": 100000 }
        }
      },
      "score_mode": "max"
    }
  }
}
```

**Output behavior:**

| Parent Doc | Department | Children with salary ≥ 100k | Returned? |
|------------|------------|----------------------------|-----------|
| 1 | Engineering | bob (120,000) | ✅ Yes |
| 2 | Marketing | None | ❌ No |
| 3 | Data | eve (110,000) | ✅ Yes |

Engineering and Data departments are returned. With `score_mode: max`, each parent's score is the highest score among its matching children.

---

#### Example: Using `min_children` and `max_children`

Find departments that have **at least 2** employees earning more than 60,000:

```json
GET /company/_search
{
  "query": {
    "has_child": {
      "type": "employee",
      "query": {
        "range": { "salary": { "gt": 60000 } }
      },
      "min_children": 2
    }
  }
}
```

| Parent | Matching Children | Count | Returned? |
|--------|-------------------|-------|-----------|
| 1 — Engineering | alice (95k), bob (120k) | 2 | ✅ Yes |
| 2 — Marketing | carol (78k), dave (65k) | 2 | ✅ Yes |
| 3 — Data | eve (110k) | 1 | ❌ No |

---

#### Example: Full-Text Search on Child with Parent Returned

Find departments that have an employee named "alice":

```json
GET /company/_search
{
  "query": {
    "has_child": {
      "type":  "employee",
      "query": { "term": { "name": "alice" } }
    }
  }
}
```

Returns the Engineering department document — the parent of alice.

---

### `has_parent` Query

Returns **child documents** whose parent document matches the inner query.

#### Basic Syntax

```json
GET /company/_search
{
  "query": {
    "has_parent": {
      "parent_type":     "department",
      "query":           { <query_on_parent_fields> },
      "score":           false,
      "ignore_unmapped": false
    }
  }
}
```

| Parameter | Required | Description |
|-----------|----------|-------------|
| `parent_type` | ✅ Yes | The parent relationship name as defined in the `join` field. |
| `query` | ✅ Yes | Query executed against parent documents. |
| `score` | ❌ No | If `true`, the parent's score is included in the child's score. Default: `false`. |
| `ignore_unmapped` | ❌ No | Silently ignore if `parent_type` is not mapped. Default: `false`. |

---

#### Example: Find Employees in Departments Matching a Description

Find all employees whose department description mentions "software":

```json
GET /company/_search
{
  "query": {
    "has_parent": {
      "parent_type": "department",
      "query": {
        "match": { "description": "software" }
      },
      "score": true
    }
  }
}
```

**Output behavior:**

| Child Doc | Employee | Parent Department | Returned? |
|-----------|----------|-------------------|-----------|
| 101 | alice | Engineering (matches "software") | ✅ Yes |
| 102 | bob | Engineering (matches "software") | ✅ Yes |
| 201 | carol | Marketing (no match) | ❌ No |
| 202 | dave | Marketing (no match) | ❌ No |
| 301 | eve | Data (no match) | ❌ No |

With `score: true`, the relevance score of the parent document propagates to each matching child.

---

#### Example: Find Employees in a Specific Department by Name

```json
GET /company/_search
{
  "query": {
    "has_parent": {
      "parent_type": "department",
      "query": {
        "term": { "name": "Marketing" }
      }
    }
  }
}
```

Returns carol and dave — all employees belonging to the Marketing department.

---

### Combining `has_child` and `has_parent` with `bool`

Both queries integrate naturally into `bool` compound queries.

**Example:** Find employees in the Engineering department earning more than 90,000:

```json
GET /company/_search
{
  "query": {
    "bool": {
      "must": [
        {
          "has_parent": {
            "parent_type": "department",
            "query": {
              "term": { "name": "Engineering" }
            }
          }
        },
        {
          "range": { "salary": { "gt": 90000 } }
        }
      ]
    }
  }
}
```

Returns alice (95,000) — an Engineering employee earning above 90,000. Bob (120,000) also qualifies if present. The `range` query runs against child fields; `has_parent` restricts to Engineering children.

---

**Example:** Find departments that have at least one employee in data science AND whose department name contains "Data":

```json
GET /company/_search
{
  "query": {
    "bool": {
      "must": [
        { "match": { "description": "data science" } },
        {
          "has_child": {
            "type":  "employee",
            "query": { "range": { "salary": { "gte": 100000 } } }
          }
        }
      ]
    }
  }
}
```

---

### `inner_hits` with `has_child` and `has_parent`

Both queries support `inner_hits` to return the matching related documents alongside the primary result.

**Example:** Return departments and include the specific employees that matched:

```json
GET /company/_search
{
  "query": {
    "has_child": {
      "type": "employee",
      "query": {
        "range": { "salary": { "gte": 100000 } }
      },
      "inner_hits": {
        "name": "high_earners",
        "size": 10
      }
    }
  }
}
```

**Response structure:**

```json
{
  "hits": {
    "hits": [
      {
        "_id": "1",
        "_source": { "name": "Engineering", ... },
        "inner_hits": {
          "high_earners": {
            "hits": {
              "hits": [
                { "_id": "102", "_source": { "name": "bob", "salary": 120000 } }
              ]
            }
          }
        }
      }
    ]
  }
}
```

---

### `has_child` vs `has_parent` Summary

| Characteristic | `has_child` | `has_parent` |
|----------------|------------|--------------|
| Query runs against | Child documents | Parent documents |
| Returns | Parent documents | Child documents |
| Score propagation parameter | `score_mode` | `score` (boolean) |
| Child count constraints | `min_children`, `max_children` | Not applicable |
| Common use case | Find parents by child attributes | Find children by parent attributes |

---

### `join` Field vs `nested` Type Comparison

| Characteristic | `nested` | `join` field |
|----------------|----------|--------------|
| Document storage | Sub-documents hidden within parent | Independent top-level documents |
| Shard requirement | No constraint | Parent and child must share a shard |
| Update granularity | Entire parent must be reindexed | Child can be updated independently |
| Query types | `nested` query | `has_child`, `has_parent` |
| Suitable for | Arrays of structured objects per document | Large, independently managed related entities |
| Index size impact | [Inference] Moderate (hidden docs per parent) | [Inference] Higher flexibility but more complex routing |
| Recommended for | Product variants, order line items | Employee-department, blog post-comments |

---

### Performance Considerations

- [Inference] `has_child` and `has_parent` queries are among the more expensive query types in Elasticsearch because they require joining across documents at query time on each shard. On large indices with many children per parent, query latency may be significant. Actual performance depends on shard count, data volume, and hardware.
- [Inference] `has_child` with `score_mode` other than `none` requires collecting and aggregating child scores, which adds overhead compared to `score_mode: none`. Use `none` when parent scoring from child matches is not needed.
- [Inference] `has_parent` with `score: true` propagates parent scores to children, which may add computation. Use `score: false` (default) when parent score propagation is not needed.
- Routing must be consistent. [Inference] Incorrect routing at index time causes parent-child relationships to break silently — queries return no results without errors. Always verify routing during indexing.
- Elasticsearch documentation discourages using the `join` field type for general use and recommends it only when the data model genuinely requires independent parent-child document management. [Inference] For most relational modeling needs, denormalization or `nested` types are preferable.

---

### Multi-Level Joins

The `join` field supports multi-level hierarchies (grandparent → parent → child):

```json
"relations": {
  "company":    "department",
  "department": "employee"
}
```

Querying across multiple levels requires chaining `has_child` or `has_parent` queries:

```json
GET /org/_search
{
  "query": {
    "has_child": {
      "type": "department",
      "query": {
        "has_child": {
          "type":  "employee",
          "query": { "term": { "name": "alice" } }
        }
      }
    }
  }
}
```

Returns company documents that have a department which has an employee named "alice".

> [Inference] Multi-level join queries compound the performance implications of each join level. Each additional level requires an additional join pass on each shard. Use with caution on large datasets.

---

**Conclusion**

The `has_child` and `has_parent` queries provide document-level join semantics within a single Elasticsearch index, enabling parent-child relationship traversal in both directions. They are powerful when documents in a relationship need to be indexed, updated, and queried independently — such as departments and employees, or blog posts and comments. However, their performance cost, routing requirements, and modeling complexity mean they should be chosen deliberately over simpler alternatives like `nested` types or denormalization when the use case genuinely warrants independent document management.