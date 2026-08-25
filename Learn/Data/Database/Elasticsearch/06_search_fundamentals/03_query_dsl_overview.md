## Query DSL overview

### Overview

The Query Domain Specific Language (Query DSL) is Elasticsearch's powerful, flexible JSON-based syntax for constructing complex search queries. Unlike simple keyword searches, Query DSL enables precise control over how documents are matched, scored, and filtered through a composable set of query types. Understanding Query DSL is fundamental to building effective search applications, as it provides the mechanisms for full-text search, filtering, boolean logic, range queries, and specialized search patterns required in production systems.

### Query DSL Structure

Query DSL queries are always nested within a `query` clause in the request body:

**Basic structure:**

```json
{
  "query": {
    "query_type": {
      "parameters": "values"
    }
  }
}
```

**Example:**

```json
GET /products/_search
{
  "query": {
    "match": {
      "name": "laptop"
    }
  }
}
```

### Query Context vs. Filter Context

Query DSL distinguishes between two contexts with different behaviors:

**Query context (affects relevance scoring):**

```json
{
  "query": {
    "match": {
      "description": "high performance"
    }
  }
}
```

The match is scored; more relevant documents receive higher scores.

**Filter context (no relevance scoring):**

```json
{
  "query": {
    "bool": {
      "must": [
        { "match": { "name": "laptop" } }
      ],
      "filter": [
        { "range": { "price": { "lte": 1000 } } }
      ]
    }
  }
}
```

The range condition in `filter` must match but doesn't affect scores. [Inference] Filters are cached by Elasticsearch for performance; use filter context for conditions that don't require relevance scoring.

### Match Query

The match query is the standard full-text search query, analyzing input and matching documents:

**Basic match query:**

```json
GET /products/_search
{
  "query": {
    "match": {
      "name": "laptop computer"
    }
  }
}
```

Matches documents where `name` contains "laptop" or "computer" (tokenized and analyzed).

**Match with operator:**

```json
{
  "query": {
    "match": {
      "description": {
        "query": "high performance laptop",
        "operator": "and"
      }
    }
  }
}
```

With `operator: and`, all terms must match. Default is `or` (any term matches).

**Match with fuzziness:**

```json
{
  "query": {
    "match": {
      "name": {
        "query": "lapto",
        "fuzziness": "AUTO"
      }
    }
  }
}
```

Matches terms similar to the query (typo tolerance). `fuzziness: AUTO` automatically determines tolerance level.

### Match Phrase Query

Match phrase queries match exact phrase sequences:

**Basic match_phrase:**

```json
{
  "query": {
    "match_phrase": {
      "description": "high performance laptop"
    }
  }
}
```

Matches only documents where "high performance laptop" appears as a contiguous phrase.

**Match phrase with slop:**

```json
{
  "query": {
    "match_phrase": {
      "description": {
        "query": "high laptop",
        "slop": 2
      }
    }
  }
}
```

`slop: 2` allows up to 2 words between "high" and "laptop". Matches "high performance laptop" (1 word between).

### Term Query

The term query matches exact values without analysis:

**Basic term query:**

```json
{
  "query": {
    "term": {
      "status": "active"
    }
  }
}
```

Matches documents where `status` field exactly equals "active" (case-sensitive, no tokenization).

**Terms query (multiple values):**

```json
{
  "query": {
    "terms": {
      "category": ["Electronics", "Computers", "Accessories"]
    }
  }
}
```

Matches documents where `category` is one of the specified values (OR logic).

### Range Query

Range queries match documents within numeric, date, or other ranges:

**Basic range query:**

```json
{
  "query": {
    "range": {
      "price": {
        "gte": 500,
        "lte": 1500
      }
    }
  }
}
```

Matches documents where `price` is between 500 and 1500 (inclusive).

**Range operators:**

```json
{
  "query": {
    "range": {
      "created_at": {
        "gte": "2024-01-01",
        "lt": "2024-02-01"
      }
    }
  }
}
```

- **`gte`**: Greater than or equal
- **`lte`**: Less than or equal
- **`gt`**: Greater than
- **`lt`**: Less than

**Range with date math:**

```json
{
  "query": {
    "range": {
      "timestamp": {
        "gte": "now-30d",
        "lte": "now"
      }
    }
  }
}
```

Matches documents from the last 30 days using date math syntax.

### Bool Query

The bool query combines multiple queries using boolean logic:

**Basic bool query:**

```json
{
  "query": {
    "bool": {
      "must": [
        { "match": { "name": "laptop" } }
      ],
      "filter": [
        { "range": { "price": { "lte": 1000 } } }
      ],
      "must_not": [
        { "term": { "status": "discontinued" } }
      ],
      "should": [
        { "term": { "featured": true } }
      ]
    }
  }
}
```

**Clauses in bool query:**

- **`must`**: Conditions that must match (AND). Affects scoring.
- **`filter`**: Conditions that must match (AND). Doesn't affect scoring (cached).
- **`must_not`**: Conditions that must NOT match (NOT).
- **`should`**: Conditions that should match (OR). Optional; affects scoring if any match.

**Bool with should and minimum_should_match:**

```json
{
  "query": {
    "bool": {
      "should": [
        { "match": { "name": "laptop" } },
        { "match": { "brand": "Dell" } },
        { "match": { "rating": 5 } }
      ],
      "minimum_should_match": 2
    }
  }
}
```

At least 2 of the 3 conditions must match.

### Multi-Match Query

Multi-match queries search across multiple fields simultaneously:

**Basic multi_match:**

```json
{
  "query": {
    "multi_match": {
      "query": "laptop computer",
      "fields": ["name", "description", "category"]
    }
  }
}
```

Searches for "laptop computer" across name, description, and category fields.

**Multi-match with field boosting:**

```json
{
  "query": {
    "multi_match": {
      "query": "laptop",
      "fields": ["name^3", "description^2", "category"]
    }
  }
}
```

Matches in `name` are scored 3x higher; matches in `description` are scored 2x higher; `category` matches are scored normally.

**Multi-match with type:**

```json
{
  "query": {
    "multi_match": {
      "query": "high performance laptop",
      "fields": ["name", "description"],
      "type": "phrase"
    }
  }
}
```

`type: phrase` matches the entire phrase across fields (equivalent to match_phrase).

**Multi-match types:**

- **`best_fields`**: Use best-matching field (default)
- **`most_fields`**: Require matching in most fields
- **`cross_fields`**: Match terms across different fields
- **`phrase`**: Match as phrase in any field
- **`phrase_prefix`**: Match as phrase prefix

### Prefix Query

Prefix queries match terms starting with a specific prefix:

**Basic prefix query:**

```json
{
  "query": {
    "prefix": {
      "name": "lap"
    }
  }
}
```

Matches documents where `name` starts with "lap" ("laptop", "lapping", etc.).

[Inference] Prefix queries can be slow on large fields; consider using ngram tokenizer for better performance on frequently-queried prefixes.

### Wildcard Query

Wildcard queries use `*` and `?` wildcards for pattern matching:

**Wildcard with asterisk:**

```json
{
  "query": {
    "wildcard": {
      "name": "lap*top"
    }
  }
}
```

Matches "laptop", "lapeltop", "lap-top", etc. (`*` matches any number of characters).

**Wildcard with question mark:**

```json
{
  "query": {
    "wildcard": {
      "name": "lap?op"
    }
  }
}
```

`?` matches exactly one character ("lapbop", "lapcop", "lapdop", etc.).

[Inference] Wildcard queries are slow; avoid leading wildcards which scan entire fields.

### Regex Query

Regular expression queries match documents using regex patterns:

**Basic regex query:**

```json
{
  "query": {
    "regexp": {
      "name": "lap.*top"
    }
  }
}
```

Matches any term matching the regex pattern "lap.*top".

[Inference] Regex queries are computationally expensive; test performance with realistic data before production use.

### Fuzzy Query

Fuzzy queries match terms similar to the query term, tolerating typos:

**Basic fuzzy query:**

```json
{
  "query": {
    "fuzzy": {
      "name": {
        "value": "lapto",
        "fuzziness": 1
      }
    }
  }
}
```

Matches terms within 1 edit distance from "lapto" ("laptop", "lato", etc.).

**Fuzziness levels:**

```json
{
  "fuzzy": {
    "name": {
      "value": "laptop",
      "fuzziness": "AUTO"
    }
  }
}
```

- **`AUTO`**: Elasticsearch determines fuzziness (0 for short terms, 1-2 for longer)
- **`0`**: Exact match
- **`1` or `2`**: Edit distance tolerance

### Exists Query

The exists query matches documents where a field has any value:

**Basic exists query:**

```json
{
  "query": {
    "exists": {
      "field": "description"
    }
  }
}
```

Matches documents where `description` field has a value (not null/missing).

**Negating with must_not:**

```json
{
  "query": {
    "bool": {
      "must_not": [
        { "exists": { "field": "discontinued_date" } }
      ]
    }
  }
}
```

Matches documents where `discontinued_date` is missing.

### Constant Score Query

Constant score query wraps a filter and assigns all matching documents the same score:

**Basic constant_score:**

```json
{
  "query": {
    "constant_score": {
      "filter": {
        "term": {
          "status": "active"
        }
      },
      "boost": 1.2
    }
  }
}
```

All documents matching the filter get score 1.2 (no relevance variation).

[Inference] Use constant_score for filtering without relevance scoring; more efficient than must clauses in bool queries.

### Nested Query

Nested queries search within nested objects (arrays of objects):

**Mapping with nested field:**

```json
{
  "mappings": {
    "properties": {
      "comments": {
        "type": "nested",
        "properties": {
          "text": { "type": "text" },
          "rating": { "type": "integer" }
        }
      }
    }
  }
}
```

**Nested query:**

```json
{
  "query": {
    "nested": {
      "path": "comments",
      "query": {
        "bool": {
          "must": [
            { "match": { "comments.text": "excellent" } },
            { "range": { "comments.rating": { "gte": 5 } } }
          ]
        }
      }
    }
  }
}
```

Matches documents where a single comment element is both "excellent" AND has rating >= 5.

[Inference] Nested queries are expensive; denormalization may improve performance for frequently-queried nested fields.

### Has Child and Has Parent Queries

These queries work with parent-child document relationships (less common than nested):

**Has child query:**

```json
{
  "query": {
    "has_child": {
      "type": "comment",
      "query": {
        "match": { "text": "excellent" }
      }
    }
  }
}
```

Matches parent documents that have child documents matching the query.

**Has parent query:**

```json
{
  "query": {
    "has_parent": {
      "parent_type": "product",
      "query": {
        "term": { "category": "Electronics" }
      }
    }
  }
}
```

Matches child documents whose parent matches the query.

### Match All Query

The match_all query matches all documents:

**Basic match_all:**

```json
{
  "query": {
    "match_all": {}
  }
}
```

Returns all documents in the index.

**Match all with boost:**

```json
{
  "query": {
    "match_all": {
      "boost": 1.2
    }
  }
}
```

Returns all documents with specified boost value.

### Dis Max Query

The dis_max (disjunction max) query returns the highest score from any matching clause:

**Basic dis_max:**

```json
{
  "query": {
    "dis_max": {
      "queries": [
        { "match": { "name": "laptop" } },
        { "match": { "description": "laptop" } }
      ],
      "tie_breaker": 0.3
    }
  }
}
```

Returns the maximum score between matching clauses, plus a small contribution from other matches via `tie_breaker`.

[Inference] Dis_max is useful when you want best-matching field to dominate scoring rather than summing all matches.

### Combining Queries — Real Examples

**E-commerce search with multiple conditions:**

```json
GET /products/_search
{
  "query": {
    "bool": {
      "must": [
        {
          "multi_match": {
            "query": "laptop",
            "fields": ["name^2", "description"]
          }
        }
      ],
      "filter": [
        { "range": { "price": { "gte": 500, "lte": 2000 } } },
        { "terms": { "brand": ["Dell", "HP"] } },
        { "term": { "in_stock": true } }
      ],
      "should": [
        { "term": { "featured": true } },
        { "range": { "rating": { "gte": 4.5 } } }
      ],
      "minimum_should_match": 1
    }
  }
}
```

Searches for laptops in price/brand range, with in-stock requirement; boosts featured or highly-rated products.

**Content recommendation with complex logic:**

```json
{
  "query": {
    "bool": {
      "must": [
        { "match": { "status": "published" } }
      ],
      "filter": [
        { "range": { "published_date": { "gte": "now-90d" } } },
        {
          "bool": {
            "should": [
              { "match": { "tags": "machine learning" } },
              { "match": { "category": "AI" } }
            ],
            "minimum_should_match": 1
          }
        }
      ],
      "should": [
        { "match": { "author_id": "user_123" } }
      ]
    }
  }
}
```

Finds published content from last 90 days tagged with machine learning or AI category, boosting content from specific author.

**User profile search with optional fields:**

```json
{
  "query": {
    "bool": {
      "must": [
        {
          "multi_match": {
            "query": "John",
            "fields": ["first_name", "last_name", "username"]
          }
        }
      ],
      "filter": [
        { "term": { "verified": true } }
      ],
      "should": [
        { "match": { "biography": "developer" } },
        { "range": { "created_at": { "gte": "now-1y" } } }
      ]
    }
  }
}
```

Searches for verified users named "John", optionally boosting developers or recent members.

### Query Performance Considerations

**Use filter context for non-scored conditions:**

```json
{
  "query": {
    "bool": {
      "must": [
        { "match": { "name": "laptop" } }
      ],
      "filter": [
        { "range": { "price": { "lte": 1000 } } }
      ]
    }
  }
}
```

Filters are cached; prefer them over must clauses when scoring isn't needed.

**Avoid expensive queries:**

```json
{
  "query": {
    "wildcard": {
      "name": "*laptop*"
    }
  }
}
```

Leading wildcards and regex queries are expensive. Use n-gram tokenizers or prefix queries instead.

**Use term queries for exact matches:**

```json
{
  "query": {
    "term": {
      "status": "active"
    }
  }
}
```

Term queries are faster than match queries for exact matching on keyword fields.

**Limit nested query depth:**

```json
{
  "query": {
    "nested": {
      "path": "comments",
      "query": {
        "nested": {
          "path": "comments.replies"
        }
      }
    }
  }
}
```

[Inference] Deeply nested queries are expensive; consider denormalization if nested structures are frequently queried.

### Query Validation

Test complex queries before production deployment:

**Validate query syntax:**

```json
POST /products/_validate/query
{
  "query": {
    "bool": {
      "must": [
        { "match": { "name": "laptop" } }
      ]
    }
  }
}
```

Returns validation result indicating syntax errors if present.

**Get query explanation:**

```json
GET /products/_search
{
  "explain": true,
  "query": {
    "match": { "name": "laptop" }
  }
}
```

Shows how each document is scored, useful for debugging relevance issues.

### Query DSL Best Practices

**Use meaningful field names:**

Clear field names make queries self-documenting.

**Leverage field analysis:**

Use appropriate analyzers for field types (text, keyword, etc.).

**Compose reusable query patterns:**

Abstract common query structures for consistency.

**Monitor slow queries:**

Enable slow query logging to identify performance bottlenecks.

```json
{
  "index.search.slowlog.threshold.query.warn": "10s",
  "index.search.slowlog.threshold.query.info": "5s"
}
```

**Test with realistic data:**

Performance characteristics change with actual data volume and distribution.

**Key Points:**
- Query DSL is a flexible JSON-based syntax for constructing complex searches using composable query types
- Query context affects relevance scoring; filter context doesn't but is cached for better performance
- Match query performs full-text search with analysis; term query matches exact values without analysis
- Bool query combines queries using must, filter, must_not, and should clauses for boolean logic
- Range queries match documents within numeric, date, or other value ranges
- Multi-match query searches across multiple fields simultaneously with optional field boosting
- Match phrase query matches exact phrase sequences; slop parameter allows word gaps
- Fuzzy query tolerates typos and misspellings using edit distance
- Nested query searches within nested object arrays; has_child and has_parent work with parent-child relationships
- Constant_score query assigns the same score to all matches; useful for filtering without relevance variation
- Wildcard and regex queries are expensive; avoid leading wildcards or test performance thoroughly
- Filter context is preferred over query context when relevance scoring isn't needed (better performance)
- Complex queries can be combined using bool query to create sophisticated multi-condition searches
- Explain parameter shows scoring calculations for debugging relevance issues
- Query validation helps identify syntax errors before production deployment