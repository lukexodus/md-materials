## UPDATE Operations


UPDATE operations modify existing rows in tables.

**SQL UPDATE syntax:**

```sql
-- Update single column
UPDATE posts 
SET status = 'published' 
WHERE id = 'uuid-here';

-- Update multiple columns
UPDATE posts 
SET 
  status = 'published',
  published_at = NOW(),
  updated_at = NOW()
WHERE id = 'uuid-here';

-- Update with computation
UPDATE products 
SET price = price * 1.1  -- Increase price by 10%
WHERE category = 'electronics';

-- Update from another table's data
UPDATE posts p
SET author_name = u.full_name
FROM users u
WHERE p.author_id = u.id;

-- Update with subquery
UPDATE posts
SET view_count = (
  SELECT COUNT(*) 
  FROM page_views 
  WHERE page_views.post_id = posts.id
)
WHERE id = 'uuid-here';

-- Update and return updated rows
UPDATE posts
SET status = 'published', published_at = NOW()
WHERE status = 'draft' AND created_at < NOW() - INTERVAL '7 days'
RETURNING *;

-- Conditional update
UPDATE users
SET status = CASE
  WHEN last_login < NOW() - INTERVAL '90 days' THEN 'inactive'
  WHEN last_login < NOW() - INTERVAL '30 days' THEN 'dormant'
  ELSE 'active'
END
WHERE status != 'banned';
```

**Supabase JavaScript client UPDATE:**

```javascript
// Update single row by ID
const { data, error } = await supabase
  .from('posts')
  .update({ status: 'published', published_at: new Date().toISOString() })
  .eq('id', 'uuid-here')
  .select();

// Update multiple rows
const { data, error } = await supabase
  .from('posts')
  .update({ status: 'archived' })
  .eq('author_id', 'uuid-here')
  .lt('created_at', '2023-01-01')
  .select();

// Update with multiple filters
const { data, error } = await supabase
  .from('posts')
  .update({ featured: true })
  .eq('status', 'published')
  .gte('likes', 100)
  .select();

// Update without returning data
const { error } = await supabase
  .from('posts')
  .update({ view_count: 150 })
  .eq('id', 'uuid-here');

// Increment numeric value
const { data, error } = await supabase.rpc('increment_view_count', {
  post_id: 'uuid-here'
});
// Requires database function:
// CREATE FUNCTION increment_view_count(post_id UUID)
// RETURNS void AS $$
//   UPDATE posts SET view_count = view_count + 1 WHERE id = post_id;
// $$ LANGUAGE sql;
```

