## Ordering and Pagination


Ordering and pagination control how result sets are sorted and divided into manageable chunks.

**SQL ORDER BY:**

```sql
-- Order by single column ascending
SELECT * FROM posts ORDER BY created_at ASC;

-- Order by single column descending
SELECT * FROM posts ORDER BY created_at DESC;

-- Order by multiple columns
SELECT * FROM posts 
ORDER BY status ASC, created_at DESC;

-- Order with NULL handling
SELECT * FROM posts 
ORDER BY featured_image NULLS LAST;  -- NULLs at end
SELECT * FROM posts 
ORDER BY featured_image NULLS FIRST;  -- NULLs at beginning

-- Order by computed value
SELECT *, (likes + shares * 2) as engagement
FROM posts
ORDER BY engagement DESC;

-- Order by case expression
SELECT * FROM posts
ORDER BY 
  CASE status
    WHEN 'featured' THEN 1
    WHEN 'published' THEN 2
    WHEN 'draft' THEN 3
    ELSE 4
  END;
```

**SQL LIMIT and OFFSET (pagination):**

```sql
-- Limit results
SELECT * FROM posts ORDER BY created_at DESC LIMIT 10;

-- Pagination with OFFSET
SELECT * FROM posts 
ORDER BY created_at DESC 
LIMIT 10 OFFSET 0;  -- Page 1

SELECT * FROM posts 
ORDER BY created_at DESC 
LIMIT 10 OFFSET 10;  -- Page 2

SELECT * FROM posts 
ORDER BY created_at DESC 
LIMIT 10 OFFSET 20;  -- Page 3

-- General pagination formula: OFFSET = (page_number - 1) * page_size
```

**Cursor-based pagination (more efficient for large datasets):**

```sql
-- First page
SELECT * FROM posts 
WHERE deleted_at IS NULL
ORDER BY created_at DESC, id DESC
LIMIT 10;

-- Next page (using last item's created_at and id as cursor)
SELECT * FROM posts 
WHERE deleted_at IS NULL
  AND (created_at < '2024-01-15 10:30:00' 
       OR (created_at = '2024-01-15 10:30:00' AND id < 'last-uuid'))
ORDER BY created_at DESC, id DESC
LIMIT 10;
```

**Supabase JavaScript client ordering and pagination:**

```javascript
// Order by single column
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .order('created_at', { ascending: false });

// Order by multiple columns
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .order('status', { ascending: true })
  .order('created_at', { ascending: false });

// Order with NULL handling
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .order('featured_image', { ascending: true, nullsFirst: false });

// Basic pagination with range
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .range(0, 9)  // Returns rows 0-9 (first 10 items)
  .order('created_at', { ascending: false });

// Page 2
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .range(10, 19)  // Returns rows 10-19
  .order('created_at', { ascending: false });

// Pagination helper function
async function getPaginatedPosts(page, pageSize) {
  const from = (page - 1) * pageSize;
  const to = from + pageSize - 1;
  
  const { data, error, count } = await supabase
    .from('posts')
    .select('*', { count: 'exact' })  // Include total count
    .range(from, to)
    .order('created_at', { ascending: false });
    
  return {
    data,
    error,
    currentPage: page,
    pageSize,
    totalItems: count,
    totalPages: Math.ceil(count / pageSize)
  };
}

// Cursor-based pagination
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .lt('created_at', lastItemTimestamp)
  .order('created_at', { ascending: false })
  .limit(10);
```

