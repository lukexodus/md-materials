## Joins and Nested Queries


Joins combine data from multiple tables, while nested queries embed related data in the response.

**SQL JOIN types:**

```sql
-- INNER JOIN (only matching rows from both tables)
SELECT 
  p.id,
  p.title,
  u.full_name as author_name
FROM posts p
INNER JOIN users u ON p.author_id = u.id;

-- LEFT JOIN (all rows from left table, matching rows from right)
SELECT 
  p.id,
  p.title,
  u.full_name as author_name
FROM posts p
LEFT JOIN users u ON p.author_id = u.id;

-- RIGHT JOIN (all rows from right table, matching rows from left)
SELECT 
  u.id,
  u.full_name,
  p.title
FROM posts p
RIGHT JOIN users u ON p.author_id = u.id;

-- FULL OUTER JOIN (all rows from both tables)
SELECT 
  u.full_name,
  p.title
FROM users u
FULL OUTER JOIN posts p ON u.id = p.author_id;

-- CROSS JOIN (Cartesian product - every combination)
SELECT 
  c.name as category,
  t.name as tag
FROM categories c
CROSS JOIN tags t;
```

**Multiple joins:**

```sql
SELECT 
  p.id,
  p.title,
  u.full_name as author_name,
  c.name as category_name,
  COUNT(l.id) as like_count
FROM posts p
INNER JOIN users u ON p.author_id = u.id
LEFT JOIN categories c ON p.category_id = c.id
LEFT JOIN likes l ON p.id = l.post_id
WHERE p.status = 'published'
GROUP BY p.id, p.title, u.full_name, c.name;
```

**Self join (joining table to itself):**

```sql
-- Find users who live in the same city
SELECT 
  u1.full_name as user1,
  u2.full_name as user2,
  u1.city
FROM users u1
INNER JOIN users u2 ON u1.city = u2.city AND u1.id < u2.id;

-- Employee and manager relationship
SELECT 
  e.full_name as employee,
  m.full_name as manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.id;
```

**Subqueries in SELECT:**

```sql
-- Subquery in SELECT clause
SELECT 
  p.id,
  p.title,
  (SELECT COUNT(*) FROM comments c WHERE c.post_id = p.id) as comment_count,
  (SELECT MAX(created_at) FROM comments c WHERE c.post_id = p.id) as last_comment_at
FROM posts p;

-- Subquery in WHERE clause
SELECT * FROM posts
WHERE author_id IN (
  SELECT id FROM users WHERE status = 'verified'
);

-- Correlated subquery (references outer query)
SELECT * FROM posts p
WHERE EXISTS (
  SELECT 1 FROM comments c 
  WHERE c.post_id = p.id AND c.created_at > NOW() - INTERVAL '7 days'
);

-- NOT EXISTS
SELECT * FROM users u
WHERE NOT EXISTS (
  SELECT 1 FROM posts p WHERE p.author_id = u.id
);

-- Subquery with ANY/ALL
SELECT * FROM products
WHERE price > ALL (
  SELECT price FROM products WHERE category = 'budget'
);

SELECT * FROM products
WHERE price < ANY (
  SELECT price FROM products WHERE category = 'premium'
);
```

**Common Table Expressions (CTEs):**

```sql
-- Single CTE
WITH popular_posts AS (
  SELECT * FROM posts
  WHERE likes >= 100
)
SELECT 
  p.*,
  u.full_name as author_name
FROM popular_posts p
JOIN users u ON p.author_id = u.id;

-- Multiple CTEs
WITH 
  active_users AS (
    SELECT * FROM users 
    WHERE last_login > NOW() - INTERVAL '30 days'
  ),
  user_stats AS (
    SELECT 
      author_id,
      COUNT(*) as post_count,
      AVG(likes) as avg_likes
    FROM posts
    GROUP BY author_id
  )
SELECT 
  u.full_name,
  us.post_count,
  us.avg_likes
FROM active_users u
JOIN user_stats us ON u.id = us.author_id
ORDER BY us.post_count DESC;

-- Recursive CTE (for hierarchical data)
WITH RECURSIVE category_tree AS (
  -- Base case: top-level categories
  SELECT id, name, parent_id, 0 as level
  FROM categories
  WHERE parent_id IS NULL
  
  UNION ALL
  
  -- Recursive case: child categories
  SELECT c.id, c.name, c.parent_id, ct.level + 1
  FROM categories c
  JOIN category_tree ct ON c.parent_id = ct.id
)
SELECT * FROM category_tree ORDER BY level, name;
```

**Supabase JavaScript client joins (nested queries):**

```javascript
// Basic join (one-to-one or many-to-one)
const { data, error } = await supabase
  .from('posts')
  .select(`
    id,
    title,
    author:users (
      id,
      full_name,
      email
    )
  `);
// Returns: { id, title, author: { id, full_name, email } }

// Multiple joins
const { data, error } = await supabase
  .from('posts')
  .select(`
    id,
    title,
    author:users (
      full_name
    ),
    category:categories (
      name
    )
  `);

// One-to-many relationship
const { data, error } = await supabase
  .from('posts')
  .select(`
    id,
    title,
    comments (
      id,
      content,
      user:users (
        full_name
      )
    )
  `);
// Returns: { id, title, comments: [{ id, content, user: { full_name } }] }

// Many-to-many through junction table
const { data, error } = await supabase
  .from('students')
  .select(`
    id,
    name,
    enrollments (
      enrolled_at,
      grade,
      course:courses (
        title,
        credits
      )
    )
  `);

// Filtering on joined table
const { data, error } = await supabase
  .from('posts')
  .select(`
    *,
    author:users!inner (
      full_name
    )
  `)
  .eq('author.status', 'verified');
// !inner forces INNER JOIN instead of LEFT JOIN

// Count related records
const { data, error } = await supabase
  .from('posts')
  .select(`
    id,
    title,
    comments (count)
  `);
// Returns: { id, title, comments: [{ count: 5 }] }

// Nested filtering
const { data, error } = await supabase
  .from('posts')
  .select(`
    id,
    title,
    comments!inner (
      id,
      content
    )
  `)
  .eq('comments.flagged', false)
  .gte('comments.created_at', '2024-01-01');

// Deep nesting (3+ levels)
const { data, error } = await supabase
  .from('posts')
  .select(`
    id,
    title,
    comments (
      id,
      content,
      user:users (
        full_name,
        profile:profiles (
          avatar_url,
          bio
        )
      )
    )
  `);

// Using foreign key hint when multiple foreign keys exist
const { data, error } = await supabase
  .from('messages')
  .select(`
    id,
    content,
    sender:users!messages_sender_id_fkey (
      full_name
    ),
    recipient:users!messages_recipient_id_fkey (
      full_name
    )
  `);
```

**RPC for complex joins:**

```sql
-- Create function for complex query
CREATE OR REPLACE FUNCTION get_post_with_stats(post_uuid UUID)
RETURNS TABLE (
  id UUID,
  title TEXT,
  author_name TEXT,
  comment_count BIGINT,
  like_count BIGINT,
  recent_comments JSON
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id,
    p.title,
    u.full_name,
    COUNT(DISTINCT c.id) as comment_count,
    COUNT(DISTINCT l.id) as like_count,
    (
      SELECT json_agg(json_build_object(
        'content', c2.content,
        'author', u2.full_name,
        'created_at', c2.created_at
      ))
      FROM comments c2
      JOIN users u2 ON c2.user_id = u2.id
      WHERE c2.post_id = p.id
      ORDER BY c2.created_at DESC
      LIMIT 5
    ) as recent_comments
  FROM posts p
  JOIN users u ON p.author_id = u.id
  LEFT JOIN comments c ON p.id = c.post_id
  LEFT JOIN likes l ON p.id = l.post_id
  WHERE p.id = post_uuid
  GROUP BY p.id, p.title, u.full_name;
END;
$$ LANGUAGE plpgsql;

-- Call from JavaScript
const { data, error } = await supabase.rpc('get_post_with_stats', {
  post_uuid: 'uuid-here'
});
```

