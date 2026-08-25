## Pagination Standards


### Offset-Based Pagination

#### Page Number Strategy

Traditional page-based navigation:

```
GET /users?page=1&limit=20
GET /users?page=2&limit=20
GET /users?page=3&limit=20
```

Response structure:

```json
{
  "data": [
    { "id": 21, "name": "User 21" },
    { "id": 22, "name": "User 22" }
  ],
  "pagination": {
    "page": 2,
    "limit": 20,
    "total": 1250,
    "totalPages": 63,
    "hasNext": true,
    "hasPrevious": true
  }
}
```

#### Offset and Limit Strategy

Direct offset control:

```
GET /users?offset=40&limit=20
GET /users?offset=60&limit=20
```

Response structure:

```json
{
  "data": [...],
  "pagination": {
    "offset": 40,
    "limit": 20,
    "total": 1250,
    "hasNext": true,
    "hasPrevious": true
  }
}
```

Calculation relationship:

```
offset = (page - 1) × limit
page = (offset ÷ limit) + 1
```

#### Default Values

Establish sensible defaults:

```
GET /users
# Equivalent to: /users?page=1&limit=20

GET /users?page=1
# Uses default limit=20

GET /users?limit=50
# Uses default page=1
```

Common default limits: 10, 20, 25, 50

#### Maximum Limits

Enforce upper bounds:

```
GET /users?limit=10000

400 Bad Request
{
  "error": {
    "code": "INVALID_LIMIT",
    "message": "Limit exceeds maximum allowed value of 100",
    "maxLimit": 100,
    "requestedLimit": 10000
  }
}
```

Typical maximum limits: 100, 250, 500

#### Advantages

- Simple implementation and understanding
- Direct page access (jump to page 10)
- Easy calculation of total pages
- URL bookmarkable for specific pages
- Client can calculate progress (page 5 of 10)

#### Disadvantages

- Performance degrades with high offsets
- Inconsistent results with real-time data changes
- Skip/duplicate records when data modified during pagination
- Database query cost increases with offset size

Performance impact example:

```sql
-- Fast: Low offset
SELECT * FROM users LIMIT 20 OFFSET 0;

-- Slow: High offset (database must read and discard 100,000 rows)
SELECT * FROM users LIMIT 20 OFFSET 100000;
```

#### Deep Pagination Problem

High offsets cause performance issues:

```
GET /users?page=5000&limit=20
# offset = 99,980

# Database must:
# 1. Read 100,000 rows
# 2. Discard first 99,980 rows
# 3. Return 20 rows
```

Solutions:
- Implement cursor-based pagination for deep pages
- Limit maximum page/offset values
- Use search/filtering instead of deep pagination

#### Data Consistency Issues

Records shift between page requests:

```
# Initial state: 100 users
GET /users?page=1&limit=20
# Returns users 1-20

# 5 new users added at top
# User 16 moves to position 21

GET /users?page=2&limit=20
# Returns users 21-40
# User 16 appears again (duplicate)

# Or if 5 users deleted:
# User 21 moves to position 16
GET /users?page=2&limit=20
# Returns users 21-40
# User 16-20 skipped (missing)
```

### Cursor-Based Pagination

#### Opaque Cursor Strategy

Cursor encodes position without exposing internal structure:

```
GET /users?limit=20

Response:
{
  "data": [...],
  "pagination": {
    "nextCursor": "eyJpZCI6MjAsImNyZWF0ZWRBdCI6IjIwMjQtMDEtMTVUMTA6MzA6MDAuMDAwWiJ9",
    "prevCursor": null,
    "hasNext": true,
    "hasPrevious": false
  }
}

# Next page
GET /users?cursor=eyJpZCI6MjAsImNyZWF0ZWRBdCI6IjIwMjQtMDEtMTVUMTA6MzA6MDAuMDAwWiJ9&limit=20
```

Cursor typically base64-encoded JSON:

```javascript
// Decoded cursor
{
  "id": 20,
  "createdAt": "2024-01-15T10:30:00.000Z"
}

// Encoding cursor
const cursor = Buffer.from(JSON.stringify({ id: 20, createdAt: timestamp }))
  .toString('base64url');

// Decoding cursor
const decoded = JSON.parse(Buffer.from(cursor, 'base64url').toString());
```

#### Cursor Construction

Cursor contains values for ordering columns:

```javascript
// For: ORDER BY created_at DESC, id DESC
const cursor = {
  createdAt: "2024-01-15T10:30:00.000Z",
  id: 123
};

// Query using cursor
SELECT * FROM users
WHERE (created_at, id) < (?, ?)
ORDER BY created_at DESC, id DESC
LIMIT 20;
```

#### Bidirectional Navigation

Support forward and backward pagination:

```json
{
  "data": [...],
  "pagination": {
    "nextCursor": "eyJpZCI6NDB9",
    "prevCursor": "eyJpZCI6MjF9",
    "hasNext": true,
    "hasPrevious": true
  }
}
```

Query logic:

```sql
-- Forward pagination (after cursor)
SELECT * FROM users
WHERE id > ?
ORDER BY id ASC
LIMIT 21;

-- Backward pagination (before cursor)
SELECT * FROM users
WHERE id < ?
ORDER BY id DESC
LIMIT 21;
```

Fetch limit+1 to determine if more pages exist.

#### Parameter Naming Conventions

Common parameter names:

```
# Standard cursor
GET /users?cursor=abc123&limit=20

# Explicit direction
GET /users?after=abc123&limit=20
GET /users?before=xyz789&limit=20

# First/last terminology
GET /users?first=20&after=abc123
GET /users?last=20&before=xyz789
```

#### Advantages

- Consistent performance regardless of position
- No duplicate/missing records with real-time data
- Handles large datasets efficiently
- Database-friendly (uses indexed columns)

#### Disadvantages

- Cannot jump to arbitrary pages
- No total count or page indicators
- Cannot determine position in dataset
- More complex implementation
- Cursor invalidation on data deletion

#### Cursor Invalidation

Cursors may become invalid:

```
GET /users?cursor=eyJpZCI6MTIzfQ&limit=20

400 Bad Request
{
  "error": {
    "code": "INVALID_CURSOR",
    "message": "The provided cursor is invalid or expired",
    "suggestion": "Start pagination from the beginning"
  }
}
```

Causes:
- Referenced record deleted
- Cursor format changed (API update)
- Cursor expired (time-limited cursors)

#### Composite Cursors

Multiple fields for tie-breaking:

```javascript
// When multiple records share same timestamp
const cursor = {
  createdAt: "2024-01-15T10:30:00.000Z",
  id: 123  // Tie-breaker using unique ID
};

// SQL query
SELECT * FROM users
WHERE created_at < ?
   OR (created_at = ? AND id < ?)
ORDER BY created_at DESC, id DESC
LIMIT 20;
```

Always include unique identifier as final cursor component.

### Keyset Pagination

#### Keyset Principle

Navigate using last seen value from indexed column:

```
# First page
GET /users?limit=20
ORDER BY id ASC

Response:
{
  "data": [
    { "id": 1, "name": "User 1" },
    ...
    { "id": 20, "name": "User 20" }
  ],
  "pagination": {
    "lastId": 20
  }
}

# Next page
GET /users?lastId=20&limit=20

# SQL: WHERE id > 20 ORDER BY id ASC LIMIT 20
```

#### Multiple Column Keyset

Keyset with non-unique ordering:

```
# Order by created_at, then id
GET /users?limit=20
ORDER BY created_at DESC, id DESC

Response:
{
  "data": [...],
  "pagination": {
    "lastCreatedAt": "2024-01-15T10:30:00.000Z",
    "lastId": 20
  }
}

# Next page
GET /users?lastCreatedAt=2024-01-15T10:30:00.000Z&lastId=20&limit=20

# SQL:
WHERE (created_at, id) < (?, ?)
ORDER BY created_at DESC, id DESC
LIMIT 20
```

#### Seek Method Implementation

Database-specific syntax:

```sql
-- PostgreSQL: Row value comparison
SELECT * FROM users
WHERE (created_at, id) < (?, ?)
ORDER BY created_at DESC, id DESC
LIMIT 20;

-- MySQL: Expanded condition
SELECT * FROM users
WHERE created_at < ?
   OR (created_at = ? AND id < ?)
ORDER BY created_at DESC, id DESC
LIMIT 20;
```

#### Index Requirements

Requires composite index on ordering columns:

```sql
-- Required index for efficient keyset pagination
CREATE INDEX idx_users_created_id ON users(created_at DESC, id DESC);

-- Query uses index efficiently
EXPLAIN SELECT * FROM users
WHERE (created_at, id) < (?, ?)
ORDER BY created_at DESC, id DESC
LIMIT 20;
```

#### Advantages

- Extremely fast, constant time complexity O(1)
- No offset calculation overhead
- Works well with billions of records
- Predictable performance
- Real-time data consistency

#### Disadvantages

- Cannot skip pages or jump to arbitrary position
- Requires indexed columns for ordering
- Complex with multiple sort orders
- Client must track last seen values
- Bidirectional navigation requires extra logic

### Timestamp-Based Pagination

#### Time Range Strategy

Paginate using time windows:

```
GET /events?since=2024-01-15T10:00:00Z&until=2024-01-15T11:00:00Z&limit=100

Response:
{
  "data": [...],
  "pagination": {
    "since": "2024-01-15T10:00:00Z",
    "until": "2024-01-15T11:00:00Z",
    "nextUntil": "2024-01-15T10:30:00Z",
    "hasNext": true
  }
}

# Next page
GET /events?since=2024-01-15T10:00:00Z&until=2024-01-15T10:30:00Z&limit=100
```

#### Polling Use Case

Fetch new items since last request:

```
# Initial request
GET /notifications?since=2024-01-15T10:00:00Z

Response:
{
  "data": [...],
  "pagination": {
    "since": "2024-01-15T10:00:00Z",
    "latestTimestamp": "2024-01-15T10:30:00Z"
  }
}

# Poll for new items
GET /notifications?since=2024-01-15T10:30:00Z
```

#### Time Precision Handling

Handle records with identical timestamps:

```javascript
// Use timestamp + ID for uniqueness
const cursor = {
  timestamp: "2024-01-15T10:30:00.123Z",
  id: 456
};

// Query
SELECT * FROM events
WHERE timestamp > ?
   OR (timestamp = ? AND id > ?)
ORDER BY timestamp ASC, id ASC
LIMIT 100;
```

#### Advantages

- Natural for time-series data
- Efficient polling for updates
- Easy to implement time-range queries
- Works well with indexed timestamp columns

#### Disadvantages

- Requires reliable timestamps
- Clock skew issues in distributed systems
- Multiple records with same timestamp need tie-breaker
- Cannot determine total count easily

### Link Header Pagination (RFC 5988)

#### Standard Link Relations

Provide navigation URLs in headers:

```
GET /users?page=5&limit=20

Link: </users?page=1&limit=20>; rel="first",
      </users?page=4&limit=20>; rel="prev",
      </users?page=6&limit=20>; rel="next",
      </users?page=50&limit=20>; rel="last"
```

#### Relation Types

Standard rel values:

```
rel="first"    # First page
rel="prev"     # Previous page
rel="next"     # Next page
rel="last"     # Last page
rel="self"     # Current page
```

#### Multiple Links

Comma-separated links:

```
Link: </users?page=1>; rel="first",
      </users?page=4>; rel="prev",
      </users?page=5>; rel="self",
      </users?page=6>; rel="next",
      </users?page=50>; rel="last"
```

#### Cursor with Link Headers

Combine cursors with link headers:

```
GET /users?cursor=abc123

Link: </users?cursor=xyz789>; rel="next",
      </users?cursor=def456>; rel="prev"
```

#### Parsing Link Headers

Client-side parsing:

```javascript
// Parse Link header
function parseLinkHeader(header) {
  const links = {};
  const parts = header.split(',');
  
  parts.forEach(part => {
    const [url, rel] = part.split(';');
    const cleanUrl = url.trim().slice(1, -1); // Remove < >
    const relMatch = rel.match(/rel="(.+?)"/);
    
    if (relMatch) {
      links[relMatch[1]] = cleanUrl;
    }
  });
  
  return links;
}

// Usage
const linkHeader = response.headers.get('Link');
const links = parseLinkHeader(linkHeader);
// { first: '/users?page=1', next: '/users?page=6', ... }
```

#### Advantages

- Standards-based approach
- Keeps response body clean
- Complete URLs eliminate URL construction
- Easy discovery of available navigation

#### Disadvantages

- Less visible than body-based pagination
- Requires header parsing
- Not all HTTP clients handle headers easily
- Limited metadata capability

### Range Header Pagination (RFC 7233)

#### Range Request Syntax

Use HTTP Range header:

```
GET /users
Range: items=0-19

206 Partial Content
Content-Range: items 0-19/1250
Accept-Ranges: items

[
  { "id": 1, "name": "User 1" },
  ...
  { "id": 20, "name": "User 20" }
]
```

#### Unbounded Range

Request from offset to end:

```
GET /users
Range: items=1000-

206 Partial Content
Content-Range: items 1000-1249/1250
```

#### Suffix Range

Request last N items:

```
GET /users
Range: items=-50

206 Partial Content
Content-Range: items 1200-1249/1250
```

#### Unsatisfiable Range

Handle invalid ranges:

```
GET /users
Range: items=2000-2999

416 Range Not Satisfiable
Content-Range: items */1250

{
  "error": {
    "code": "RANGE_NOT_SATISFIABLE",
    "message": "Requested range exceeds total items",
    "totalItems": 1250
  }
}
```

#### Accept-Ranges Header

Advertise range support:

```
GET /users

200 OK
Accept-Ranges: items
Content-Range: items 0-19/1250
```

Or decline range support:

```
Accept-Ranges: none
```

#### Advantages

- HTTP standard compliance
- Semantic meaning clear from headers
- Client controls exact range
- Works with HTTP caching

#### Disadvantages

- Limited adoption in REST APIs
- Less intuitive than query parameters
- Some proxies may not handle correctly
- Complex header parsing

### GraphQL-Style Pagination

#### Relay Connection Specification

Cursor-based with standardized structure:

```graphql
query {
  users(first: 20, after: "cursor123") {
    edges {
      node {
        id
        name
        email
      }
      cursor
    }
    pageInfo {
      hasNextPage
      hasPreviousPage
      startCursor
      endCursor
    }
    totalCount
  }
}
```

REST adaptation:

```
GET /users?first=20&after=cursor123

Response:
{
  "edges": [
    {
      "node": { "id": 1, "name": "User 1" },
      "cursor": "cursor001"
    },
    ...
  ],
  "pageInfo": {
    "hasNextPage": true,
    "hasPreviousPage": false,
    "startCursor": "cursor001",
    "endCursor": "cursor020"
  },
  "totalCount": 1250
}
```

#### Forward and Backward Pagination

Explicit directional parameters:

```
# Forward pagination
GET /users?first=20&after=cursor123

# Backward pagination
GET /users?last=20&before=cursor456
```

#### Edge Metadata

Additional per-item metadata:

```json
{
  "edges": [
    {
      "node": { "id": 1, "name": "User 1" },
      "cursor": "cursor001",
      "addedAt": "2024-01-15T10:30:00Z",
      "relevanceScore": 0.95
    }
  ]
}
```

#### Advantages

- Standardized structure
- Rich metadata support
- Clear forward/backward semantics
- Per-item cursor availability

#### Disadvantages

- Verbose response structure
- Overhead for simple use cases
- Complexity for basic needs
- Primarily designed for GraphQL

### Hybrid Pagination Approaches

#### Offset with Cursor Fallback

Start with offset, switch to cursor for deep pages:

```
# Shallow pagination: offset-based
GET /users?page=1&limit=20
GET /users?page=2&limit=20

# Deep pagination: cursor-based
GET /users?cursor=abc123&limit=20

Response:
{
  "data": [...],
  "pagination": {
    "cursor": "abc123",
    "page": null,
    "hasNext": true,
    "deepPaginationThreshold": 100
  }
}
```

#### Total Count Strategy

Provide count for offset, omit for cursor:

```
# Offset pagination with count
GET /users?page=1&limit=20

Response:
{
  "data": [...],
  "pagination": {
    "page": 1,
    "total": 1250,
    "totalPages": 63
  }
}

# Cursor pagination without count
GET /users?cursor=abc123&limit=20

Response:
{
  "data": [...],
  "pagination": {
    "nextCursor": "def456",
    "hasNext": true
    # No total count for performance
  }
}
```

#### Estimated Counts

Provide fast estimates instead of exact counts:

```json
{
  "data": [...],
  "pagination": {
    "page": 1,
    "total": "~50000",
    "isEstimate": true,
    "hasNext": true
  }
}
```

Database estimation techniques:

```sql
-- PostgreSQL: Fast estimate from statistics
SELECT reltuples::bigint AS estimate
FROM pg_class
WHERE relname = 'users';

-- MySQL: Estimate from information_schema
SELECT table_rows AS estimate
FROM information_schema.tables
WHERE table_name = 'users';
```

Exact counts expensive for large tables:

```sql
-- Slow on large tables
SELECT COUNT(*) FROM users;

-- Fast estimate
SELECT reltuples FROM pg_class WHERE relname = 'users';
```

### Pagination Metadata

#### Essential Metadata Fields

Core pagination information:

```json
{
  "data": [...],
  "pagination": {
    "currentPage": 5,
    "pageSize": 20,
    "totalItems": 1250,
    "totalPages": 63,
    "hasNext": true,
    "hasPrevious": true,
    "isFirst": false,
    "isLast": false
  }
}
```

#### Navigation URLs

Pre-constructed navigation links:

```json
{
  "data": [...],
  "pagination": {
    "page": 5,
    "links": {
      "first": "/users?page=1&limit=20",
      "previous": "/users?page=4&limit=20",
      "self": "/users?page=5&limit=20",
      "next": "/users?page=6&limit=20",
      "last": "/users?page=63&limit=20"
    }
  }
}
```

#### Cursor Metadata

Cursor-specific information:

```json
{
  "data": [...],
  "pagination": {
    "cursor": {
      "next": "eyJpZCI6NDB9",
      "previous": "eyJpZCI6MjF9"
    },
    "hasNext": true,
    "hasPrevious": true,
    "pageSize": 20
  }
}
```

#### Result Statistics

Additional context about results:

```json
{
  "data": [...],
  "pagination": {
    "page": 5,
    "returned": 20,
    "total": 1250,
    "rangeStart": 81,
    "rangeEnd": 100
  }
}
```

### Performance Considerations

#### Count Query Optimization

Avoid expensive counts for large datasets:

```
# Strategy 1: Count only when needed
GET /users?page=1&includeCount=true

# Strategy 2: Estimate for display
GET /users?page=1
Response: { "total": "10000+", "isEstimate": true }

# Strategy 3: Omit count entirely
GET /users?cursor=abc123
Response: { "hasNext": true }  # No total provided
```

#### Index Optimization

Ensure proper indexing for pagination queries:

```sql
-- Offset pagination index
CREATE INDEX idx_users_id ON users(id);

-- Timestamp-based pagination index
CREATE INDEX idx_users_created ON users(created_at DESC, id DESC);

-- Filtered pagination index
CREATE INDEX idx_users_active_created 
ON users(status, created_at DESC) 
WHERE status = 'active';
```

#### Query Execution Plans

Verify efficient execution:

```sql
-- Check query plan
EXPLAIN ANALYZE
SELECT * FROM users
WHERE created_at < ?
ORDER BY created_at DESC
LIMIT 20;

-- Look for:
-- - Index usage (not Seq Scan)
-- - Low execution time
-- - Minimal rows examined
```

#### Lazy Loading Counts

Defer count calculation:

```javascript
// Don't calculate count on every request
GET /users?page=1&limit=20

// Client requests count separately if needed
GET /users/count?filters=...

Response:
{
  "count": 1250,
  "isExact": true,
  "calculatedAt": "2024-01-15T10:30:00Z"
}
```

#### Caching Strategies

Cache paginated results:

```
# Cache key includes all pagination parameters
GET /users?page=5&limit=20&sort=-createdAt

Cache-Control: public, max-age=60
ETag: "page5-20-created-v1"
```

Invalidation considerations:

```javascript
// Invalidate affected pages on mutation
POST /users
// Invalidate: page 1, counts, recent user lists

DELETE /users/123
// Invalidate: specific user, list pages, counts
```

### Error Handling

#### Invalid Page Numbers

Handle out-of-range pages:

```
GET /users?page=9999&limit=20

# Option 1: Return empty results
200 OK
{
  "data": [],
  "pagination": {
    "page": 9999,
    "total": 1250,
    "totalPages": 63,
    "hasNext": false
  }
}

# Option 2: Return error
400 Bad Request
{
  "error": {
    "code": "INVALID_PAGE",
    "message": "Page 9999 exceeds total pages (63)",
    "maxPage": 63
  }
}
```

#### Invalid Cursors

Handle malformed or expired cursors:

```
GET /users?cursor=invalid_cursor

400 Bad Request
{
  "error": {
    "code": "INVALID_CURSOR",
    "message": "The provided cursor is invalid",
    "details": "Cursor format is malformed or expired"
  }
}
```

#### Limit Validation

Enforce limit constraints:

```
GET /users?limit=-5

400 Bad Request
{
  "error": {
    "code": "INVALID_LIMIT",
    "message": "Limit must be between 1 and 100",
    "minLimit": 1,
    "maxLimit": 100,
    "requestedLimit": -5
  }
}
```

### Client Implementation Patterns

#### Infinite Scroll

Cursor-based infinite loading:

```javascript
async function loadMore() {
  const response = await fetch(
    `/users?cursor=${nextCursor}&limit=20`
  );
  const data = await response.json();
  
  users.push(...data.data);
  nextCursor = data.pagination.nextCursor;
  hasMore = data.pagination.hasNext;
}

// Trigger on scroll
window.addEventListener('scroll', () => {
  if (nearBottom() && hasMore && !loading) {
    loadMore();
  }
});
```

#### Page Navigation

Offset-based page selector:

```javascript
async function goToPage(pageNum) {
  const response = await fetch(
    `/users?page=${pageNum}&limit=20`
  );
  const data = await response.json();
  
  displayUsers(data.data);
  updatePagination(data.pagination);
}

// Render page numbers
function renderPagination(pagination) {
  const pages = [];
  for (let i = 1; i <= pagination.totalPages; i++) {
    pages.push(
      <button onClick={() => goToPage(i)}>
        {i}
      </button>
    );
  }
  return pages;
}
```

#### Load More Button

Explicit user-triggered loading:

```javascript
async function loadMore() {
  const response = await fetch(
    `/users?cursor=${nextCursor}&limit=20`
  );
  const data = await response.json();
  
  users.push(...data.data);
  nextCursor = data.pagination.nextCursor;
  showLoadMore = data.pagination.hasNext;
}

// UI
{showLoadMore && (
  <button onClick={loadMore}>
    Load More
  </button>
)}
```

### API Design Recommendations

#### Choose Pagination Type by Use Case

Selection guide:

```
Offset-based:
- Small to medium datasets (< 100k records)
- Need page numbers/total counts
- Direct page access required
- Admin interfaces, reports

Cursor-based:
- Large datasets (> 100k records)
- Real-time data (social feeds)
- Infinite scroll UIs
- Performance-critical APIs

Keyset:
- Very large datasets (millions+)
- Time-series data
- Analytics queries
- High-performance requirements

Timestamp:
- Event streams
- Activity logs
- Polling for updates
- Time-based filtering
```

#### Consistency Across Endpoints

Maintain uniform pagination:

```
✅ Consistent:
GET /users?page=1&limit=20
GET /products?page=1&limit=20
GET /orders?page=1&limit=20

❌ Inconsistent:
GET /users?page=1&limit=20
GET /products?offset=0&max=20
GET /orders?cursor=abc&size=20
```

#### Document Default Behavior

Explicitly document defaults:

```
GET /users
# Defaults: page=1, limit=20, sort=-createdAt

Response:
{
  "data": [...],
  "pagination": {
    "page": 1,
    "limit": 20,
    "defaults": {
      "limit": 20,
      "sort": "-createdAt"
    }
  }
}
```

#### Provide Configuration Options

Allow client customization:

```
# Custom page size
GET /users?limit=50

# Different sort order
GET /users?sort=name

# Combined
GET /users?page=2&limit=50&sort=name
```

Document limits and constraints:

```
Parameters:
- page: integer, min=1, default=1
- limit: integer, min=1, max=100, default=20
- sort: string, allowed=[-]createdAt,[-]name,[-]email
```

---

