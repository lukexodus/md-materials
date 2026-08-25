## The search API

### Overview

The Search API is the primary mechanism for querying documents in Elasticsearch, enabling complex searches across one or more indexes using query DSL (Domain Specific Language). Unlike the Get API which retrieves specific documents by ID, the Search API discovers documents matching search criteria, applies filters, aggregations, sorting, and relevance scoring. Understanding the Search API is fundamental to building effective search experiences, analytics, and data discovery applications in Elasticsearch.

### Basic Search Syntax

The Search API supports simple searches for specific queries:

**Syntax:**

```
GET /<index>/_search
POST /<index>/_search
GET /_search
POST /_search
```

**Simple search request:**

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

**Response structure:**

```json
{
  "took": 5,
  "timed_out": false,
  "_shards": {
    "total": 5,
    "successful": 5,
    "skipped": 0,
    "failed": 0
  },
  "hits": {
    "total": {
      "value": 42,
      "relation": "eq"
    },
    "max_score": 8.5,
    "hits": [
      {
        "_index": "products",
        "_id": "laptop_001",
        "_score": 8.5,
        "_source": {
          "name": "Dell XPS 13 Laptop",
          "price": 999.99,
          "category": "Electronics"
        }
      },
      {
        "_index": "products",
        "_id": "laptop_002",
        "_score": 7.2,
        "_source": {
          "name": "HP ProBook Laptop",
          "price": 799.99,
          "category": "Electronics"
        }
      }
    ]
  }
}
```

### Search Response Components

The Search API response contains several important sections:

- **`took`**: Milliseconds required to execute the search
- **`timed_out`**: Boolean indicating whether the search was interrupted by timeout
- **`_shards`**: Information about shard participation (total, successful, skipped, failed)
- **`hits.total`**: Total number of matching documents (`value`) and relation type (`eq` or `gte`)
- **`hits.max_score`**: Highest relevance score among results
- **`hits.hits`**: Array of actual matching documents with their metadata and scores

### Query DSL Basics

The Query DSL provides flexible syntax for constructing searches. Common query types include:

**Match query (full-text search):**

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

Searches for documents where the `name` field contains "laptop" or "computer" (analyzes the input).

**Term query (exact match):**

```json
GET /products/_search
{
  "query": {
    "term": {
      "status": "active"
    }
  }
}
```

Matches documents where `status` field exactly equals "active" (no analysis).

**Range query:**

```json
GET /products/_search
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

**Bool query (combining conditions):**

```json
GET /products/_search
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
      ]
    }
  }
}
```

Combines multiple query conditions with different logic:
- **`must`**: All conditions must match (AND logic)
- **`filter`**: Conditions must match but don't affect score
- **`must_not`**: Conditions must not match (NOT logic)
- **`should`**: At least one condition should match (OR logic)

### Pagination with from and size

The `from` and `size` parameters control result pagination:

**Request for page 2 (results 20-30):**

```json
GET /products/_search
{
  "from": 20,
  "size": 10,
  "query": {
    "match": {
      "name": "laptop"
    }
  }
}
```

- **`from: 20`**: Skip first 20 results
- **`size: 10`**: Return 10 results

**Response with pagination metadata:**

```json
{
  "hits": {
    "total": {
      "value": 150,
      "relation": "eq"
    },
    "hits": [
      { ... },
      { ... }
    ]
  }
}
```

[Inference] Deep pagination (large `from` values) is inefficient; for large result sets, use search_after or scroll for better performance.

### Sorting Results

The `sort` parameter controls result ordering:

**Sort by field:**

```json
GET /products/_search
{
  "sort": [
    { "price": { "order": "asc" } },
    { "_score": { "order": "desc" } }
  ],
  "query": {
    "match": {
      "name": "laptop"
    }
  }
}
```

Results are sorted by price ascending, then by relevance score descending.

**Sort options:**

```json
{
  "sort": [
    { "created_at": { "order": "desc", "mode": "avg" } },
    { "rating": { "order": "desc", "missing": "_last" } }
  ]
}
```

- **`order`**: `asc` or `desc`
- **`mode`**: How to handle multi-valued fields (`min`, `max`, `avg`)
- **`missing`**: Where to place documents without the sort field (`_last` or `_first`)

### Filtering with Filter Context

Filter context is more efficient than query context for conditions that don't require relevance scoring:

**Query context (affects scoring):**

```json
GET /products/_search
{
  "query": {
    "match": {
      "description": "high performance"
    }
  }
}
```

Relevance scoring is calculated based on "high performance" match.

**Filter context (doesn't affect scoring):**

```json
GET /products/_search
{
  "query": {
    "bool": {
      "must": [
        { "match": { "name": "laptop" } }
      ],
      "filter": [
        { "range": { "price": { "lte": 1000 } } },
        { "term": { "in_stock": true } }
      ]
    }
  }
}
```

Filter conditions must match but don't affect relevance scores. [Inference] Filters are cached by Elasticsearch, improving performance on repeated queries.

### Source Filtering

The `_source` parameter controls which fields are returned:

**Include specific fields:**

```json
GET /products/_search
{
  "_source": ["name", "price", "category"],
  "query": {
    "match": {
      "name": "laptop"
    }
  }
}
```

Only `name`, `price`, and `category` fields are returned.

**Exclude specific fields:**

```json
GET /products/_search
{
  "_source": {
    "excludes": ["description", "internal_notes"]
  },
  "query": {
    "match": {
      "name": "laptop"
    }
  }
}
```

All fields except `description` and `internal_notes` are returned.

**Disable source entirely:**

```json
GET /products/_search
{
  "_source": false,
  "query": {
    "match": {
      "name": "laptop"
    }
  }
}
```

Only metadata (ID, score, etc.) is returned; document content is omitted.

### Search with Highlighting

The `highlight` parameter returns matching terms wrapped in highlighting tags:

**Basic highlighting:**

```json
GET /products/_search
{
  "highlight": {
    "fields": {
      "name": {},
      "description": {}
    }
  },
  "query": {
    "match": {
      "name": "laptop"
    }
  }
}
```

**Response with highlights:**

```json
{
  "hits": {
    "hits": [
      {
        "_source": {
          "name": "Dell XPS 13 Laptop",
          "description": "High-performance laptop for professionals"
        },
        "highlight": {
          "name": ["Dell XPS 13 <em>Laptop</em>"],
          "description": ["High-performance <em>laptop</em> for professionals"]
        }
      }
    ]
  }
}
```

Matching terms are wrapped in `<em>` tags (configurable).

**Custom highlight tags:**

```json
{
  "highlight": {
    "pre_tags": ["<mark>"],
    "post_tags": ["</mark>"],
    "fields": {
      "name": {}
    }
  }
}
```

### Aggregations

Aggregations compute metrics and group data within search results:

**Aggregation example — average price by category:**

```json
GET /products/_search
{
  "size": 0,
  "aggs": {
    "categories": {
      "terms": {
        "field": "category.keyword",
        "size": 10
      },
      "aggs": {
        "average_price": {
          "avg": {
            "field": "price"
          }
        }
      }
    }
  }
}
```

Response:

```json
{
  "aggregations": {
    "categories": {
      "buckets": [
        {
          "key": "Electronics",
          "doc_count": 45,
          "average_price": {
            "value": 749.99
          }
        },
        {
          "key": "Accessories",
          "doc_count": 120,
          "average_price": {
            "value": 45.50
          }
        }
      ]
    }
  }
}
```

Aggregations group documents into buckets and compute metrics for each bucket.

**Common aggregation types:**

- **`terms`**: Group by field values
- **`date_histogram`**: Group by date ranges
- **`range`**: Group by custom numeric ranges
- **`avg`, `sum`, `min`, `max`**: Compute metrics
- **`percentiles`**: Calculate percentile values

### Search Across Multiple Indexes

Search multiple indexes simultaneously:

**Request:**

```json
GET /products,orders/_search
{
  "query": {
    "match": {
      "name": "laptop"
    }
  }
}
```

Searches both `products` and `orders` indexes.

**Using wildcards:**

```json
GET /logs-*/_search
{
  "query": {
    "range": {
      "timestamp": {
        "gte": "2024-01-01"
      }
    }
  }
}
```

Searches all indexes matching the pattern `logs-*`.

### Explain Query

The `explain` parameter shows how Elasticsearch scores each document:

**Request:**

```json
GET /products/_search
{
  "explain": true,
  "query": {
    "match": {
      "name": "laptop"
    }
  }
}
```

**Response with explanation:**

```json
{
  "hits": {
    "hits": [
      {
        "_id": "laptop_001",
        "_score": 8.5,
        "_explanation": {
          "value": 8.5,
          "description": "sum of:",
          "details": [
            {
              "value": 8.5,
              "description": "weight(name:laptop in 0) [BM25], result of:",
              "details": [ ... ]
            }
          ]
        }
      }
    ]
  }
}
```

Explanations show the scoring formula and component values, useful for debugging relevance issues.

### Search with Scroll

The scroll API retrieves large result sets efficiently:

**Initial scroll request:**

```json
GET /logs/_search?scroll=1m
{
  "size": 100,
  "query": {
    "match_all": {}
  }
}
```

Response:

```json
{
  "_scroll_id": "DXF1ZXJ5QW5kRmV0Y2gBAAAAAAAAAAEWYmFzaWNfMTAwLWN1cnN...",
  "hits": {
    "hits": [
      { ... },
      { ... }
    ]
  }
}
```

The `scroll_id` identifies the search context.

**Fetch next batch:**

```json
GET /_search/scroll
{
  "scroll": "1m",
  "scroll_id": "DXF1ZXJ5QW5kRmV0Y2gBAAAAAAAAAAEWYmFzaWNfMTAwLWN1cnM..."
}
```

Continues from where the previous request stopped.

[Inference] Scroll is useful for exporting large datasets but maintains server-side state; search_after is more efficient for pagination.

### Search with Search After

Search_after provides efficient pagination without offset limitations:

**Initial search:**

```json
GET /products/_search
{
  "size": 10,
  "sort": [
    { "created_at": { "order": "desc" } },
    { "_id": { "order": "asc" } }
  ],
  "query": {
    "match_all": {}
  }
}
```

Last document in response:

```json
{
  "_id": "product_123",
  "sort": ["2024-01-15T10:30:00Z", "product_123"]
}
```

**Fetch next page with search_after:**

```json
GET /products/_search
{
  "size": 10,
  "sort": [
    { "created_at": { "order": "desc" } },
    { "_id": { "order": "asc" } }
  ],
  "search_after": ["2024-01-15T10:30:00Z", "product_123"],
  "query": {
    "match_all": {}
  }
}
```

Returns results after the specified sort values, enabling efficient deep pagination.

### Real-World Use Cases

**E-commerce product search:**

```json
GET /products/_search
{
  "size": 20,
  "sort": [
    { "_score": { "order": "desc" } },
    { "created_at": { "order": "desc" } }
  ],
  "query": {
    "bool": {
      "must": [
        { "multi_match": { "query": "laptop", "fields": ["name", "description"] } }
      ],
      "filter": [
        { "range": { "price": { "gte": 500, "lte": 2000 } } },
        { "term": { "in_stock": true } },
        { "terms": { "category": ["Electronics", "Computers"] } }
      ]
    }
  },
  "aggs": {
    "brands": {
      "terms": {
        "field": "brand.keyword",
        "size": 5
      }
    },
    "price_ranges": {
      "range": {
        "field": "price",
        "ranges": [
          { "to": 500 },
          { "from": 500, "to": 1000 },
          { "from": 1000 }
        ]
      }
    }
  }
}
```

Search for laptops within price and stock filters, returning results sorted by relevance with facet options.

**Log analysis with time-based aggregation:**

```json
GET /logs-2024-01-*/_search
{
  "size": 0,
  "query": {
    "bool": {
      "must": [
        { "match": { "level": "ERROR" } }
      ],
      "filter": [
        { "range": { "timestamp": { "gte": "2024-01-15", "lte": "2024-01-16" } } }
      ]
    }
  },
  "aggs": {
    "errors_by_hour": {
      "date_histogram": {
        "field": "timestamp",
        "calendar_interval": "1h"
      },
      "aggs": {
        "error_types": {
          "terms": {
            "field": "error_type.keyword"
          }
        }
      }
    }
  }
}
```

Analyze error logs over time, grouped by hour and error type.

**User-generated content discovery:**

```json
GET /articles/_search
{
  "size": 10,
  "_source": ["title", "author", "published_at", "excerpt"],
  "query": {
    "bool": {
      "must": [
        { "match": { "content": "machine learning" } }
      ],
      "filter": [
        { "range": { "published_at": { "gte": "2023-01-01" } } },
        { "term": { "published": true } }
      ]
    }
  },
  "highlight": {
    "fields": {
      "content": {}
    }
  },
  "sort": [
    { "published_at": { "order": "desc" } }
  ]
}
```

Find published articles about machine learning published after 2023, highlighted and sorted by date.

**Analytics dashboard query:**

```json
GET /events/_search
{
  "size": 0,
  "query": {
    "range": {
      "timestamp": {
        "gte": "now-30d"
      }
    }
  },
  "aggs": {
    "daily_users": {
      "date_histogram": {
        "field": "timestamp",
        "calendar_interval": "day"
      },
      "aggs": {
        "unique_users": {
          "cardinality": {
            "field": "user_id"
          }
        }
      }
    },
    "top_pages": {
      "terms": {
        "field": "page_path.keyword",
        "size": 10
      },
      "aggs": {
        "average_session_time": {
          "avg": {
            "field": "session_duration_seconds"
          }
        }
      }
    }
  }
}
```

Analyze user engagement metrics over the last 30 days.

### Search Performance Optimization

**Use filter context instead of query context:**

```json
{
  "query": {
    "bool": {
      "must": [
        { "match": { "name": "laptop" } }
      ],
      "filter": [
        { "term": { "status": "active" } },
        { "range": { "price": { "lte": 1000 } } }
      ]
    }
  }
}
```

Filters are cached and faster than scored queries.

**Avoid expensive nested queries:**

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

[Inference] Nested queries are more expensive than flat document queries; consider denormalization for frequently nested queries.

**Use appropriate field types:**

Keyword fields for exact matching (faster filtering):

```json
{
  "mappings": {
    "properties": {
      "status": { "type": "keyword" }
    }
  }
}
```

**Limit aggregation cardinality:**

```json
{
  "aggs": {
    "categories": {
      "terms": {
        "field": "category.keyword",
        "size": 10
      }
    }
  }
}
```

Limit the number of buckets to reduce memory consumption.

### Search Timeout

Set timeout to prevent long-running queries:

**Request with timeout:**

```json
GET /products/_search?timeout=5s
{
  "query": {
    "match": {
      "name": "laptop"
    }
  }
}
```

Search completes within 5 seconds or returns partial results with `timed_out: true`.

### Comparison: Search vs. Get

| Aspect | Search API | Get API |
|--------|-----------|---------|
| **Input** | Query criteria | Document ID |
| **Output** | Matching documents | Specific document |
| **Flexibility** | Complex queries | Direct lookup |
| **Performance** | Slower (scanning) | Very fast (direct) |
| **Use case** | Discovery, filtering | Exact retrieval |
| **Scoring** | Relevance calculated | N/A |

### Limitations and Considerations

**Window limitation with from/size:**

[Unverified] Large `from` values with small `size` can be memory-intensive; Elasticsearch has internal limits (typically 10,000 results maximum with default settings).

**Score consistency:**

Scores may vary slightly across queries due to shard distribution. [Inference] Don't rely on exact score values for critical logic; use score ranges or thresholds.

**Aggregation precision:**

Aggregations on distributed shards are approximate. [Inference] For exact metrics, use smaller result windows or increase `size` parameter in terms aggregations.

**Empty query behavior:**

```json
GET /products/_search
{
  "query": {}
}
```

Empty query matches all documents (equivalent to `match_all`).

**Key Points:**
- The Search API queries documents using Query DSL, enabling complex filtering, scoring, and aggregations
- Query context affects relevance scoring; filter context is cached and faster
- The `from` and `size` parameters control pagination; `search_after` is more efficient for deep pagination
- Sorting results modifies relevance order; combine sort with score ordering for best results
- Highlighting returns matching terms wrapped in tags for display purposes
- Aggregations compute metrics and group data within search results
- Source filtering controls which fields are returned, reducing bandwidth
- Multi-index searches use comma-separated index names or wildcards
- Explain parameter shows scoring calculations for debugging relevance issues
- Scroll and search_after provide efficient mechanisms for large result set retrieval
- Filter context should be preferred over query context for conditions that don't require relevance scoring