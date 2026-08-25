## Query Parameters


PostgREST provides powerful query parameters for filtering, ordering, pagination, and data shaping.

**Filtering operators:**

- `eq` - equals: `?name=eq.John`
- `neq` - not equals: `?status=neq.deleted`
- `gt`, `gte`, `lt`, `lte` - comparison: `?age=gte.18`
- `like`, `ilike` - pattern matching: `?email=ilike.*@gmail.com`
- `in` - multiple values: `?status=in.(active,pending)`
- `is` - null checks: `?deleted_at=is.null`
- `fts` - full-text search: `?content=fts.search term`
- `cs`, `cd` - contains/contained by (arrays/JSON): `?tags=cs.{postgres,api}`
- `ov` - overlaps (arrays): `?categories=ov.{tech,news}`
- `not` - negation: `?status=not.eq.banned`

**Ordering:**

- `?order=created_at.desc` - descending order
- `?order=name.asc.nullsfirst` - ascending with null handling
- `?order=priority.desc,created_at.asc` - multiple columns

**Pagination:**

- Range-based: Headers `Range: 0-9` returns first 10 records with `Content-Range` response
- Offset/limit: `?limit=10&offset=20`
- Cursor-based: `?id=gt.100&limit=10&order=id.asc`

**Column selection:**

- Specific columns: `?select=id,name,email`
- Renaming: `?select=user_id:id,full_name:name`
- Aggregations: `?select=count,avg(price),sum(quantity)`

**Logical operators:**

- AND (default): `?status=eq.active&verified=eq.true`
- OR: `?or=(status.eq.active,status.eq.pending)`
- NOT: `?not.and=(status.eq.banned,role.eq.admin)`
- Complex: `?and=(status.eq.active,or(role.eq.admin,verified.eq.true))`

