## SELECT Queries and Filtering


SELECT queries retrieve data from tables based on specified criteria.

**Basic SELECT syntax:**

```sql
-- Select all columns
SELECT * FROM posts;

-- Select specific columns
SELECT id, title, created_at FROM posts;

-- Select with alias
SELECT 
  id,
  title as post_title,
  author_id as author
FROM posts;

-- Select distinct values
SELECT DISTINCT category FROM posts;

-- Select with computed columns
SELECT 
  title,
  LENGTH(content) as content_length,
  created_at,
  EXTRACT(YEAR FROM created_at) as year
FROM posts;
```

**WHERE clause for filtering:**

```sql
-- Equality
SELECT * FROM posts WHERE status = 'published';

-- Multiple conditions with AND
SELECT * FROM posts 
WHERE status = 'published' 
  AND author_id = 'uuid-here';

-- Multiple conditions with OR
SELECT * FROM posts 
WHERE status = 'published' 
  OR status = 'featured';

-- Combining AND/OR with parentheses
SELECT * FROM posts 
WHERE (status = 'published' OR status = 'featured')
  AND created_at > NOW() - INTERVAL '7 days';

-- NULL checks
SELECT * FROM posts WHERE deleted_at IS NULL;
SELECT * FROM posts WHERE featured_image IS NOT NULL;

-- IN operator
SELECT * FROM posts WHERE category IN ('tech', 'science', 'education');

-- NOT IN
SELECT * FROM posts WHERE status NOT IN ('draft', 'archived');

-- BETWEEN
SELECT * FROM posts 
WHERE created_at BETWEEN '2024-01-01' AND '2024-12-31';

-- LIKE for pattern matching (case-sensitive)
SELECT * FROM posts WHERE title LIKE '%PostgreSQL%';
SELECT * FROM posts WHERE title LIKE 'How to%';  -- Starts with
SELECT * FROM posts WHERE email LIKE '%@gmail.com';  -- Ends with

-- ILIKE for case-insensitive pattern matching
SELECT * FROM posts WHERE title ILIKE '%postgresql%';

-- Pattern matching wildcards:
-- % matches any sequence of characters
-- _ matches any single character
SELECT * FROM users WHERE phone LIKE '555-____';
```

**Comparison operators:**

```sql
-- Greater than / Less than
SELECT * FROM products WHERE price > 100;
SELECT * FROM products WHERE stock < 10;

-- Greater than or equal / Less than or equal
SELECT * FROM users WHERE age >= 18;
SELECT * FROM orders WHERE total <= 50.00;

-- Not equal
SELECT * FROM posts WHERE status != 'draft';
SELECT * FROM posts WHERE status <> 'draft';  -- Alternative syntax
```

**Supabase JavaScript client SELECT:**

```javascript
// Select all columns
const { data, error } = await supabase
  .from('posts')
  .select('*');

// Select specific columns
const { data, error } = await supabase
  .from('posts')
  .select('id, title, created_at');

// Select with filtering
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .eq('status', 'published')
  .gt('created_at', '2024-01-01');

// Select with multiple filters
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .eq('status', 'published')
  .gte('likes', 10)
  .order('created_at', { ascending: false });

// Select with OR conditions
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .or('status.eq.published,status.eq.featured');

// Select with NULL checks
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .is('deleted_at', null);

const { data, error } = await supabase
  .from('posts')
  .select('*')
  .not('featured_image', 'is', null);
```

