## Parent-Child Relationships (Join Field)

---

### Overview

The `join` field type establishes parent-child relationships between documents within the same index. Unlike `nested` objects — which embed child data inside the parent document — join-based parent-child relationships store parent and child as **separate, independent documents** that can be indexed, updated, and deleted individually.

This distinction is the central reason to choose the join field: when child documents need to be managed independently of their parent, without triggering a full rewrite of the parent document.

---

### How the Join Field Works

The `join` field defines a set of named relationship roles. Each document is assigned one of these roles at index time. Elasticsearch uses this information to route related documents to the same shard, which is a hard requirement — parent and child documents must reside on the same shard for join queries to function correctly.

---

### Defining a Join Field Mapping

```json
PUT /company
{
  "mappings": {
    "properties": {
      "name": { "type": "text" },
      "relation": {
        "type": "join",
        "relations": {
          "department": "employee"
        }
      }
    }
  }
}
```

- `department` is the parent role
- `employee` is the child role
- The `relation` field holds the join metadata for each document

A single parent type can have multiple child types:

```json
"relations": {
  "department": ["employee", "contractor"]
}
```

Multiple levels of hierarchy are also supported:

```json
"relations": {
  "company":    "department",
  "department": "employee"
}
```

---

### Indexing Parent Documents

Parent documents set the `relation` field to their role name as a plain string.

```json
PUT /company/_doc/1
{
  "name": "Engineering",
  "relation": "department"
}

PUT /company/_doc/2
{
  "name": "Marketing",
  "relation": "department"
}
```

---

### Indexing Child Documents

Child documents must:

1. Set the `relation` field to an object specifying `name` (the child role) and `parent` (the ID of the parent document)
2. Use the `routing` parameter set to the parent document's ID to guarantee co-location on the same shard

```json
PUT /company/_doc/10?routing=1
{
  "name": "Ana Reyes",
  "relation": {
    "name":   "employee",
    "parent": "1"
  }
}

PUT /company/_doc/11?routing=1
{
  "name": "Marco Cruz",
  "relation": {
    "name":   "employee",
    "parent": "1"
  }
}

PUT /company/_doc/12?routing=2
{
  "name": "Lena Park",
  "relation": {
    "name":   "employee",
    "parent": "2"
  }
}
```

Omitting `routing` on a child document is a critical error — it may cause the child to land on a different shard than its parent, making join queries produce incorrect or empty results.

---

### Querying Parent-Child Relationships

#### has_child Query

Returns parent documents that have at least one child matching the inner query.

```json
GET /company/_search
{
  "query": {
    "has_child": {
      "type":  "employee",
      "query": {
        "match": { "name": "Ana" }
      }
    }
  }
}
```

**Output:** Returns the `department` document (id: `1`) — the parent of the matching employee.

#### has_parent Query

Returns child documents whose parent matches the inner query.

```json
GET /company/_search
{
  "query": {
    "has_parent": {
      "parent_type": "department",
      "query": {
        "match": { "name": "Engineering" }
      }
    }
  }
}
```

**Output:** Returns all employee documents whose parent is the Engineering department.

#### parent_id Query

Returns child documents that belong to a specific parent ID. More efficient than `has_parent` when the parent ID is known directly.

```json
GET /company/_search
{
  "query": {
    "parent_id": {
      "type": "employee",
      "id":   "1"
    }
  }
}
```

---

### Scoring in has_child and has_parent

#### has_child score_mode

Controls how matching children contribute to the parent document's score.

| Value | Behavior |
|---|---|
| `none` (default) | Parent score is unaffected by children |
| `avg` | Average score of matching children |
| `max` | Highest score among matching children |
| `min` | Lowest score among matching children |
| `sum` | Sum of scores of all matching children |

```json
{
  "has_child": {
    "type":       "employee",
    "score_mode": "max",
    "query": {
      "match": { "name": "Ana" }
    }
  }
}
```

#### has_parent score

`has_parent` accepts a `score` boolean (default: `false`). When `true`, the parent document's relevance score propagates to the matching child documents.

```json
{
  "has_parent": {
    "parent_type": "department",
    "score":       true,
    "query": {
      "match": { "name": "Engineering" }
    }
  }
}
```

---

### min_children and max_children

`has_child` supports `min_children` and `max_children` parameters to filter parents based on how many children match.

```json
GET /company/_search
{
  "query": {
    "has_child": {
      "type":         "employee",
      "min_children": 2,
      "max_children": 10,
      "query": {
        "match_all": {}
      }
    }
  }
}
```

**Output:** Returns only department documents that have between 2 and 10 employees.

---

### Aggregations with Join Fields

Standard aggregations run against whichever document type is matched by the query. To aggregate across related document types in a single request, you can combine `has_child` or `has_parent` queries with aggregations on the resulting document set.

**Example — count employees per department using children_agg:**

```json
GET /company/_search
{
  "query": {
    "term": { "relation": "department" }
  },
  "aggs": {
    "employees_per_dept": {
      "children": {
        "type": "employee"
      },
      "aggs": {
        "employee_count": {
          "value_count": { "field": "_id" }
        }
      }
    }
  }
}
```

The `children` aggregation switches the aggregation context from parent documents to their associated child documents, similar in concept to the `nested` aggregation.

---

### Updating Parent and Child Documents Independently

A primary advantage of the join field over `nested` is that parent and child documents are fully independent. Updating a child does not touch the parent.

**Update a child document:**

```json
POST /company/_update/10?routing=1
{
  "doc": {
    "name": "Ana Reyes-Santos"
  }
}
```

**Delete a child document:**

```json
DELETE /company/_doc/10?routing=1
```

**Delete a parent document:**

Deleting a parent does not automatically delete its children. Orphaned child documents remain in the index and will not appear in `has_parent` queries, but they consume storage. Managing child deletion is the application's responsibility.

> [Inference] Leaving orphaned child documents in an index after deleting their parent may cause unexpected storage growth over time. A cleanup strategy should be implemented at the application level. Behavior may vary.

---

### Multi-level Hierarchies

When the mapping defines a chain of relationships (e.g., `company → department → employee`), each level follows the same indexing rules: children must be routed to the same shard as their immediate parent, which must in turn be on the same shard as the grandparent.

**Mapping:**

```json
"relations": {
  "company":    "department",
  "department": "employee"
}
```

**Index a company:**

```json
PUT /org/_doc/100
{
  "name": "Acme Corp",
  "relation": "company"
}
```

**Index a department (child of company):**

```json
PUT /org/_doc/200?routing=100
{
  "name": "Engineering",
  "relation": {
    "name":   "department",
    "parent": "100"
  }
}
```

**Index an employee (child of department, routing still to root):**

```json
PUT /org/_doc/300?routing=100
{
  "name": "Ana Reyes",
  "relation": {
    "name":   "employee",
    "parent": "200"
  }
}
```

All three documents must share the same routing value — the top-level ancestor's ID — to guarantee shard co-location across all levels.

> [Inference] In multi-level hierarchies, all documents in the chain must route to the same shard. Using the root ancestor's ID as the routing key for all descendants is a common approach. Correctness depends on consistent routing at every index operation. Behavior may vary.

---

### Performance Characteristics

| Aspect | Detail |
|---|---|
| `has_child` query cost | [Inference] Higher than standard queries — requires joining across hidden parent-child mappings at query time; impact scales with child document count |
| `has_parent` query cost | [Inference] Runs the parent query, then fans out to children; may become expensive with large parent result sets |
| `parent_id` query cost | Lower than `has_parent` — direct lookup by known parent ID |
| Shard co-location requirement | Strict — routing errors produce silent result loss, not errors |
| Independent update cost | Low — only the modified document is rewritten |
| Multi-level query cost | [Inference] Increases with each additional hierarchy level; nested `has_child` / `has_parent` queries compound execution cost |

All performance claims above are inferences. Actual behavior depends on index size, shard configuration, hardware, and query patterns. Behavior may vary.

---

### join Field vs nested Type — Comparison

| Factor | join Field | nested Type |
|---|---|---|
| Storage model | Separate documents | Hidden docs inside parent |
| Independent child updates | Yes — no parent rewrite | No — full parent rewrite |
| Independent child deletion | Yes | No — must rewrite parent |
| Query syntax | `has_child`, `has_parent`, `parent_id` | `nested` query |
| Aggregation syntax | `children` aggregation | `nested` aggregation |
| Routing requirement | Explicit, mandatory | Handled internally |
| Multi-level hierarchy support | Yes | Yes (but compounds overhead) |
| Recommended for | Frequently updated child data | Stable embedded arrays |
| General recommendation | Use sparingly; denormalize if possible | Prefer over join when applicable |

---

### Limitations

- Only **one** `join` field is permitted per index mapping
- Parent and child documents must reside in the **same index**
- Routing must be managed explicitly by the application for all child and grandchild documents
- `has_child` and `has_parent` queries **cannot be used inside** a `nested` query context
- Join fields are not supported in cross-cluster search contexts in all configurations

> [Inference] The join field is considered an advanced feature with significant operational complexity. Elasticsearch's own documentation recommends denormalization as the preferred alternative in most cases. Behavior and support boundaries may vary across versions.

---

### Best Practices

- **Default to denormalization.** Duplicating parent data into child documents at index time avoids join queries entirely and produces simpler, faster searches in most use cases.
- **Use join fields only when child documents genuinely need independent lifecycle management** — independent creation, update, and deletion without touching the parent.
- **Always specify routing on child index, update, and delete operations.** Missing routing is a silent correctness failure, not a thrown error in most cases.
- **Use `parent_id` queries instead of `has_parent`** when the parent ID is known — it is more efficient.
- **Monitor orphaned children.** Implement application-level cleanup when parents are deleted.
- **Avoid more than two levels of hierarchy** unless the data model strictly requires it. Each additional level adds routing complexity and query cost.
- **Test join query performance under realistic data volumes** before committing to this model in production. Join queries do not scale the same way as standard term or match queries.

---