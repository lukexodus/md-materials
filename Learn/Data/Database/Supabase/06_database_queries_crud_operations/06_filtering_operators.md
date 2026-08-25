## Filtering Operators


Supabase provides various operators for filtering data through both SQL and the JavaScript client.

**Equality operators:**

```javascript
// Equal
.eq('status', 'published')
// SQL: WHERE status = 'published'

// Not equal
.neq('status', 'draft')
// SQL: WHERE status != 'draft'
```

**Comparison operators:**

```javascript
// Greater than
.gt('likes', 100)
// SQL: WHERE likes > 100

// Greater than or equal
.gte('age', 18)
// SQL: WHERE age >= 18

// Less than
.lt('stock', 10)
// SQL: WHERE stock < 10

// Less than or equal
.lte('price', 50.00)
// SQL: WHERE price <= 50.00
```

**Pattern matching:**

```javascript
// LIKE (case-sensitive pattern matching)
.like('title', '%PostgreSQL%')
// SQL: WHERE title LIKE '%PostgreSQL%'

// ILIKE (case-insensitive pattern matching)
.ilike('email', '%@gmail.com')
// SQL: WHERE email ILIKE '%@gmail.com'
```

**NULL operators:**

```javascript
// IS NULL
.is('deleted_at', null)
// SQL: WHERE deleted_at IS NULL

// IS NOT NULL
.not('featured_image', 'is', null)
// SQL: WHERE featured_image IS NOT NULL
```

**Array and range operators:**

```javascript
// IN (matches any value in array)
.in('category', ['tech', 'science', 'education'])
// SQL: WHERE category IN ('tech', 'science', 'education')

// NOT IN
.not('status', 'in', '(draft,archived)')
// SQL: WHERE status NOT IN ('draft', 'archived')

// Contains (for arrays and ranges)
.contains('tags', ['javascript', 'postgresql'])
// SQL: WHERE tags @> ARRAY['javascript', 'postgresql']

// Contained by
.containedBy('tags', ['javascript', 'postgresql', 'python'])
// SQL: WHERE tags <@ ARRAY['javascript', 'postgresql', 'python']

// Range overlaps
.overlaps('availability_dates', '[2024-01-01,2024-12-31]')
// SQL: WHERE availability_dates && '[2024-01-01,2024-12-31]'
```

**Full-text search operators:**

```javascript
// Text search (uses PostgreSQL's full-text search)
.textSearch('content', 'database & query')
// SQL: WHERE to_tsvector('english', content) @@ to_tsquery('english', 'database & query')

// Plain text search (automatically handles formatting)
.textSearch('content', 'database query', { type: 'plain' })

// Phrase search
.textSearch('content', 'database query', { type: 'phrase' })

// Websearch format (Google-like syntax)
.textSearch('content', '"exact phrase" -exclude +include', { type: 'websearch' })
```

**JSON operators:**

```javascript
// Access JSON field
.eq('metadata->color', 'blue')
// SQL: WHERE metadata->>'color' = 'blue'

// Deep JSON path
.eq('metadata->dimensions->width', 100)
// SQL: WHERE metadata#>>'{dimensions,width}' = '100'

// JSON contains
.contains('metadata', { color: 'blue' })
// SQL: WHERE metadata @> '{"color":"blue"}'
```

**Logical operators:**

```javascript
// AND (default behavior, chain multiple filters)
const { data } = await supabase
  .from('posts')
  .select('*')
  .eq('status', 'published')
  .gte('likes', 10);
// SQL: WHERE status = 'published' AND likes >= 10

// OR
.or('status.eq.published,status.eq.featured')
// SQL: WHERE (status = 'published' OR status = 'featured')

// Complex OR with AND
.or('status.eq.published,and(status.eq.draft,author_id.eq.uuid-here)')
// SQL: WHERE (status = 'published' OR (status = 'draft' AND author_id = 'uuid-here'))

// NOT
.not('status', 'eq', 'draft')
// SQL: WHERE NOT (status = 'draft')
```

**Filter modifier operators:**

```javascript
// Filter on foreign table
const { data } = await supabase
  .from('posts')
  .select('*, author:users!inner(*)')
  .eq('author.status', 'active');
// Inner join and filter on users.status

// Filter on nested relation
const { data } = await supabase
  .from('posts')
  .select('*, comments!inner(count)')
  .gte('comments.count', 5);
```

**Complete filtering example:**

```javascript
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .eq('status', 'published')
  .gte('created_at', '2024-01-01')
  .or('featured.eq.true,likes.gte.100')
  .ilike('title', '%postgresql%')
  .not('category', 'in', '(spam,deleted)')
  .is('deleted_at', null)
  .order('created_at', { ascending: false })
  .range(0, 9);
```

