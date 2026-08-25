## Aggregations and Grouping


Aggregations compute summary values across multiple rows, while grouping organizes data into categories.

**Aggregate functions:**

```sql
-- COUNT: number of rows
SELECT COUNT(*) FROM posts;
SELECT COUNT(DISTINCT author_id) FROM posts;  -- Unique authors

-- SUM: total of numeric values
SELECT SUM(price) FROM orders;

-- AVG: average value
SELECT AVG(rating) FROM reviews;

-- MIN/MAX: minimum and maximum values
SELECT MIN(created_at), MAX(created_at) FROM posts;

-- String aggregation
SELECT string_agg(tag, ', ') FROM post_tags WHERE post_id = 'uuid-here';

-- JSON aggregation
SELECT json_agg(title) FROM posts;
SELECT json_agg(json_build_object('id', id, 'title', title)) FROM posts;

-- Array aggregation
SELECT array_agg(category) FROM posts;
```

**GROUP BY clause:**

```sql
-- Count posts per author
SELECT 
  author_id,
  COUNT(*) as post_count
FROM posts
GROUP BY author_id;

-- Multiple aggregations
SELECT 
  author_id,
  COUNT(*) as post_count,
  AVG(likes) as avg_likes,
  MAX(created_at) as latest_post
FROM posts
GROUP BY author_id;

-- Group by multiple columns
SELECT 
  category,
  status,
  COUNT(*) as count
FROM posts
GROUP BY category, status;

-- Group with joins
SELECT 
  u.full_name,
  COUNT(p.id) as post_count,
  SUM(p.likes) as total_likes
FROM users u
LEFT JOIN posts p ON u.id = p.author_id
GROUP BY u.id, u.full_name;

-- HAVING clause (filter after aggregation)
SELECT 
  author_id,
  COUNT(*) as post_count
FROM posts
GROUP BY author_id
HAVING COUNT(*) >= 10;

-- Complex HAVING
SELECT 
  category,
  AVG(likes) as avg_likes
FROM posts
WHERE status = 'published'
GROUP BY category
HAVING AVG(likes) > 50 AND COUNT(*) >= 5;
```

**Window functions (aggregations without grouping):**

```sql
-- Running total
SELECT 
  id,
  title,
  likes,
  SUM(likes) OVER (ORDER BY created_at) as running_total
FROM posts;

-- Rank posts by likes
SELECT 
  title,
  likes,
  RANK() OVER (ORDER BY likes DESC) as rank,
  DENSE_RANK() OVER (ORDER BY likes DESC) as dense_rank,
  ROW_NUMBER() OVER (ORDER BY likes DESC) as row_num
FROM posts;

-- Partition by category
SELECT 
  category,
  title,
  likes,
  AVG(likes) OVER (PARTITION BY category) as category_avg,
  likes - AVG(likes) OVER (PARTITION BY category) as diff_from_avg
FROM posts;

-- Top N per group
SELECT * FROM (
  SELECT 
    category,
    title,
    likes,
    ROW_NUMBER() OVER (PARTITION BY category ORDER BY likes DESC) as rn
  FROM posts
) ranked
WHERE rn <= 3;

-- Moving average
SELECT 
  created_at::date as date,
  COUNT(*) as daily_posts,
  AVG(COUNT(*)) OVER (
    ORDER BY created_at::date 
    ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
  ) as seven_day_avg
FROM posts
GROUP BY created_at::date;

-- LAG and LEAD (access previous/next rows)
SELECT 
  title,
  created_at,
  LAG(created_at) OVER (ORDER BY created_at) as previous_post_date,
  LEAD(created_at) OVER (ORDER BY created_at) as next_post_date,
  created_at - LAG(created_at) OVER (ORDER BY created_at) as time_since_last
FROM posts;
```

**ROLLUP and CUBE (hierarchical aggregations):**

```sql
-- ROLLUP (hierarchical subtotals)
SELECT 
  category,
  status,
  COUNT(*) as count
FROM posts
GROUP BY ROLLUP(category, status);
-- Returns counts for:
-- (category, status), (category, NULL), (NULL, NULL)

-- CUBE (all possible combinations)
SELECT 
  category,
  status,
  COUNT(*) as count
FROM posts
GROUP BY CUBE(category, status);
-- Returns counts for:
-- (category, status), (category, NULL), (NULL, status), (NULL, NULL)

-- GROUPING SETS (custom combinations)
SELECT 
  category,
  status,
  COUNT(*) as count
FROM posts
GROUP BY GROUPING SETS (
  (category, status),
  (category),
  ()
);
```

**Supabase JavaScript client aggregations:**

[Inference: The JavaScript client's aggregation capabilities are more limited than raw SQL. For complex aggregations, using RPC functions is often necessary.]

```javascript
// Count records
const { count, error } = await supabase
  .from('posts')
  .select('*', { count: 'exact', head: true });

// Count with filter
const { count, error } = await supabase
  .from('posts')
  .select('*', { count: 'exact', head: true })
  .eq('status', 'published');

// Count related records
const { data, error } = await supabase
  .from('users')
  .select(`
    id,
    full_name,
    posts (count)
  `);

// Using RPC for complex aggregations
const { data, error } = await supabase.rpc('get_post_statistics');

// Example RPC function:
// CREATE FUNCTION get_post_statistics()
// RETURNS TABLE (
//   category TEXT,
//   post_count BIGINT,
//   avg_likes NUMERIC,
//   total_likes BIGINT
// ) AS $$
//   SELECT 
//     category,
//     COUNT(*) as post_count,
//     AVG(likes) as avg_likes,
//     SUM(likes) as total_likes
//   FROM posts
//   WHERE status = 'published'
//   GROUP BY category
//   ORDER BY post_count DESC;
// $$ LANGUAGE sql;
```

