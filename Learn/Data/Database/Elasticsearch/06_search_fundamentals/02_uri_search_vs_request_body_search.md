## URI search vs request body search

### Overview

Elasticsearch supports two distinct syntaxes for executing searches: URI search (query string parameters in the URL) and request body search (JSON in the request body). Each approach has different capabilities, performance implications, and appropriate use cases. Understanding when to use each method is essential for building effective search applications and avoiding security pitfalls. URI search offers simplicity for basic queries, while request body search provides the full power of Query DSL for complex searches.

### URI Search Basics

URI search encodes search parameters directly in the URL as query string parameters:

**Syntax:**

```
GET /<index>/_search?q=<query>
GET /<index>/_search?q=<field>:<value>
```

**Simple example — match all documents:**

```
GET /products/_search?q=*
```

Returns all documents in the products index.

**Search specific field:**

```
GET /products/_search?q=name:laptop
```

Returns documents where the `name` field contains "laptop".

**Multiple field search:**

```
GET /products/_search?q=name:laptop+category:Electronics
```

Returns documents where `name` contains "laptop" AND `category` contains "Electronics".

### URI Search Query String Syntax

URI search uses a simplified query syntax within the `q` parameter:

**Term search:**

```
GET /products/_search?q=status:active
```

Searches for documents where `status` equals "active".

**Phrase search:**

```
GET /products/_search?q=name:"Dell XPS"
```

Searches for exact phrase "Dell XPS" in the name field.

**Wildcard search:**

```
GET /products/_search?q=name:lap*
```

Searches for terms starting with "lap" (wildcard matching).

**Range search:**

```
GET /products/_search?q=price:[100+TO+1000]
```

Searches for documents where price is between 100 and 1000.

**Boolean operators:**

```
GET /products/_search?q=name:laptop+AND+price:>500
```

Uses AND, OR, NOT operators to combine conditions.

```
GET /products/_search?q=name:laptop+OR+name:desktop
```

Matches documents with either "laptop" or "desktop" in name.

```
GET /products/_search?q=name:laptop+NOT+status:discontinued
```

Matches "laptop" documents excluding discontinued status.

### URI Search Parameters

Beyond the `q` parameter, URI search supports additional parameters:

**df parameter (default field):**

```
GET /products/_search?q=laptop&df=name
```

If no field is specified in the query, `laptop` is searched in the `name` field.

**analyzer parameter:**

```
GET /products/_search?q=laptops&analyzer=standard
```

Uses the specified analyzer for tokenizing the query.

**from and size parameters:**

```
GET /products/_search?q=laptop&from=20&size=10
```

Pagination: skip 20 results, return 10.

**sort parameter:**

```
GET /products/_search?q=laptop&sort=price:asc
```

Sort results by price in ascending order.

**timeout parameter:**

```
GET /products/_search?q=laptop&timeout=5s
```

Limit search to 5 seconds.

**_source parameter:**

```
GET /products/_search?q=laptop&_source=name,price
```

Return only name and price fields.

**explain parameter:**

```
GET /products/_search?q=laptop&explain=true
```

Include scoring explanation for each result.

### URI Search Example with Multiple Parameters

**Request:**

```
GET /products/_search?q=name:laptop+AND+price:<1000&sort=price:asc&size=20&timeout=3s&_source=name,price,rating
```

**Components:**

- `q=name:laptop+AND+price:<1000`: Search for laptops under 1000
- `sort=price:asc`: Sort by price ascending
- `size=20`: Return 20 results
- `timeout=3s`: Timeout after 3 seconds
- `_source=name,price,rating`: Return only these fields

### Request Body Search Basics

Request body search encodes all search parameters in a JSON request body:

**Syntax:**

```json
GET /<index>/_search
{
  "query": { ... },
  "sort": [ ... ],
  "size": 10,
  "from": 0,
  ...
}
```

**Simple example — match query:**

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

Searches for documents where the `name` field contains "laptop".

**Multiple conditions with bool query:**

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
        { "term": { "status": "active" } }
      ]
    }
  }
}
```

Combines multiple conditions with AND logic.

### Request Body Search Features

Request body search supports the complete Query DSL and additional features:

**Complex nested queries:**

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
      "should": [
        { "term": { "featured": true } }
      ],
      "filter": [
        { "range": { "price": { "gte": 500, "lte": 2000 } } },
        { "terms": { "category": ["Electronics", "Computers"] } }
      ]
    }
  }
}
```

Supports field weighting, scoring modifiers, and complex logic.

**Aggregations:**

```json
GET /products/_search
{
  "size": 0,
  "aggs": {
    "categories": {
      "terms": {
        "field": "category.keyword"
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

Aggregations are only available in request body search.

**Highlighting:**

```json
GET /products/_search
{
  "query": {
    "match": {
      "description": "high performance"
    }
  },
  "highlight": {
    "fields": {
      "description": {}
    },
    "pre_tags": ["<em>"],
    "post_tags": ["</em>"]
  }
}
```

Highlighting with custom tags is only available in request body search.

**Source filtering:**

```json
GET /products/_search
{
  "query": { "match_all": {} },
  "_source": {
    "includes": ["name", "price"],
    "excludes": ["internal_notes"]
  }
}
```

Advanced source filtering with includes and excludes.

**Script scoring:**

```json
GET /products/_search
{
  "query": {
    "match": { "name": "laptop" }
  },
  "script_score": {
    "query": { "match_all": {} },
    "script": {
      "source": "_score * doc['boost'].value"
    }
  }
}
```

Custom scoring logic using scripts.

### Comparison: URI Search vs. Request Body Search

| Feature | URI Search | Request Body |
|---------|-----------|--------------|
| **Syntax** | Query parameters | JSON body |
| **Simplicity** | Simple queries only | Full Query DSL |
| **Aggregations** | Not supported | Supported |
| **Highlighting** | Basic only | Full support |
| **Sorting** | Single sort | Multiple sorts |
| **Performance** | Good (simple) | Optimized (complex) |
| **Debugging** | Easy (visible in URL) | Requires viewing body |
| **Security** | URL parameter risks | Body encoding safer |
| **File uploads** | N/A | Supported in body |

### Real-World Use Cases

**URI Search — simple web search:**

```
GET /articles/_search?q=machine+learning&size=10&sort=published_at:desc
```

Simple search box in web interface with basic pagination and sorting.

**URI Search — API filter with defaults:**

```
GET /products/_search?q=category:Electronics&df=category&timeout=2s
```

API endpoint filtering products by category with reasonable defaults.

**Request Body — complex e-commerce search:**

```json
GET /products/_search
{
  "size": 20,
  "from": 0,
  "query": {
    "bool": {
      "must": [
        { "multi_match": { "query": "laptop", "fields": ["name^3", "description"] } }
      ],
      "filter": [
        { "range": { "price": { "gte": 500, "lte": 2000 } } },
        { "terms": { "brand": ["Dell", "HP", "Lenovo"] } },
        { "range": { "rating": { "gte": 4.0 } } }
      ]
    }
  },
  "sort": [
    { "_score": { "order": "desc" } },
    { "popularity": { "order": "desc" } }
  ],
  "aggs": {
    "price_ranges": {
      "range": {
        "field": "price",
        "ranges": [
          { "to": 1000 },
          { "from": 1000, "to": 2000 },
          { "from": 2000 }
        ]
      }
    },
    "brands": {
      "terms": { "field": "brand.keyword", "size": 10 }
    }
  },
  "_source": ["name", "price", "rating", "image_url"]
}
```

Complex search with filters, aggregations, sorting, and field selection.

**Request Body — analytical query:**

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
    "errors_by_service": {
      "terms": { "field": "service.keyword", "size": 20 },
      "aggs": {
        "errors_by_hour": {
          "date_histogram": { "field": "timestamp", "calendar_interval": "1h" }
        }
      }
    }
  }
}
```

Multi-level aggregation for error analysis.

### URI Search Security Considerations

URI search parameters are visible in URLs, creating potential security issues:

**Exposed credentials:**

```
GET /products/_search?q=user:admin&password:secret
```

Sensitive data in URLs may be logged, cached, or exposed in browser history.

**URL length limitations:**

Complex queries can exceed URL length limits (typically 2,000-8,000 characters depending on browser/server).

**Injection vulnerabilities:**

```
GET /products/_search?q=name:*&category:*
```

[Inference] Special characters in URI parameters require careful escaping to prevent injection attacks.

**Request Body advantages:**

```json
POST /products/_search
{
  "query": {
    "match": {
      "name": "sensitive_term"
    }
  }
}
```

Request bodies aren't typically logged in URL logs, providing better security for sensitive searches.

### URI Search Query String Syntax Details

**Escaping special characters:**

```
GET /products/_search?q=name:%22Dell+XPS%22
```

Special characters must be URL-encoded (`%22` for quotes, `+` for spaces).

**Field names with special characters:**

```
GET /products/_search?q=product.name:laptop
```

Dot notation accesses nested fields.

**Range operators:**

```
GET /products/_search?q=price:[100+TO+1000]
```

Inclusive range (both bounds included).

```
GET /products/_search?q=price:{100+TO+1000}
```

Exclusive range (both bounds excluded).

**Fuzzy search:**

```
GET /products/_search?q=name:lapto~
```

Matches terms similar to "lapto" (typo tolerance).

**Boost operator:**

```
GET /products/_search?q=name:laptop^2+category:Electronics
```

The `name:laptop` field is boosted (scored twice as high).

### Choosing Between URI and Request Body Search

**Use URI search when:**

- Query is simple (single field, single term)
- Building quick debugging queries
- Building simple API endpoints with limited filtering
- Query complexity doesn't require aggregations or highlighting
- URL length is acceptable

**Use request body search when:**

- Query is complex (multiple fields, boolean logic)
- Aggregations are needed
- Highlighting with custom tags is required
- Advanced sorting or scoring is needed
- Field filtering is complex
- Security is a concern (sensitive data)
- Query may exceed URL length limits

### Converting URI Search to Request Body

**URI search example:**

```
GET /products/_search?q=name:laptop+AND+price:<1000&sort=price:asc&size=20
```

**Equivalent request body search:**

```json
GET /products/_search
{
  "query": {
    "bool": {
      "must": [
        { "match": { "name": "laptop" } }
      ],
      "filter": [
        { "range": { "price": { "lt": 1000 } } }
      ]
    }
  },
  "sort": [
    { "price": { "order": "asc" } }
  ],
  "size": 20
}
```

Request body provides more explicit control and better readability for complex queries.

### Performance Considerations

**URI search caching:**

Simple URI searches may benefit from query result caching, especially for repeated queries with identical parameters.

**Request body optimization:**

Complex request body searches allow Elasticsearch to optimize query execution plans, potentially faster than simple URI searches.

[Inference] Performance differences are typically minimal for standard queries; query complexity and shard count have greater impact than syntax choice.

### Hybrid Approach

Applications can support both syntaxes for flexibility:

**Simple search — use URI:**

```
GET /products/_search?q=laptop&size=10
```

**Advanced search — use request body:**

```json
POST /products/_search
{
  "query": { ... },
  "aggs": { ... }
}
```

Detect query complexity and route to appropriate endpoint.

### Error Handling Differences

**URI search error:**

```
GET /products/_search?q=invalid[syntax

Error: org.elasticsearch.index.query.QueryParsingException
```

URI search errors relate to query string parsing.

**Request body error:**

```json
POST /products/_search
{
  "query": {
    "invalid_type": {
      "field": "value"
    }
  }
}

Error: parsing_exception: Unknown query type
```

Request body errors relate to Query DSL structure.

### Real-World Application Example

**Web application search implementation:**

```javascript
// Simple search from search box
function searchProducts(query) {
  fetch(`/api/products/_search?q=${encodeURIComponent(query)}&size=20`)
    .then(response => response.json())
    .then(data => displayResults(data.hits.hits));
}

// Advanced filtered search
function advancedSearch(filters) {
  const query = {
    query: {
      bool: {
        must: [
          { multi_match: { query: filters.searchText, fields: ["name", "description"] } }
        ],
        filter: [
          { range: { price: { gte: filters.minPrice, lte: filters.maxPrice } } },
          { terms: { category: filters.selectedCategories } }
        ]
      }
    },
    aggs: {
      brands: { terms: { field: "brand.keyword", size: 10 } },
      price_ranges: { range: { field: "price", ranges: filters.priceRanges } }
    }
  };
  
  fetch(`/api/products/_search`, {
    method: "POST",
    body: JSON.stringify(query)
  })
    .then(response => response.json())
    .then(data => displayResults(data));
}
```

Simple searches use URI syntax; advanced searches with filters and aggregations use request body.

### Debugging and Monitoring

**URI search transparency:**

```
GET /products/_search?q=laptop&explain=true
```

Query is visible in URL; easy to spot issues.

**Request body debugging:**

```json
POST /products/_search
{
  "explain": true,
  "query": { ... }
}
```

Use explain parameter to understand scoring; log request body for debugging.

**Key Points:**
- URI search encodes queries in URL parameters; request body search uses JSON
- URI search is simple for basic queries; request body search supports full Query DSL complexity
- Aggregations, highlighting, and advanced scoring are only available in request body search
- URI search has simpler syntax but limited expressiveness
- Request body search provides better security for sensitive data and avoids URL length limits
- URI search parameters are visible in URLs, potentially exposing sensitive information
- Complex queries with multiple conditions, aggregations, or custom scoring require request body search
- Simple single-field queries or basic filtering are appropriate for URI search
- URI search query string syntax supports wildcards, ranges, fuzzy matching, and boolean operators
- Both approaches can coexist in applications with routing based on query complexity
- Request body search allows for optimization of complex query execution plans
- URL encoding is required for special characters in URI search parameters