## Views and Materialized Views


Views are virtual tables based on SQL queries. They simplify complex queries and provide abstraction layers.

### Standard Views

Views execute their underlying query each time they're accessed.

```sql
-- Create view
CREATE VIEW active_posts AS
SELECT 
  p.id,
  p.title,
  p.content,
  p.created_at,
  u.full_name as author_name,
  u.email as author_email
FROM posts p
JOIN users u ON p.author_id = u.id
WHERE p.status = 'published'
  AND p.deleted_at IS NULL;

-- Query view like a table
SELECT * FROM active_posts WHERE author_name = 'John Doe';

-- Drop view
DROP VIEW active_posts;

-- Replace view
CREATE OR REPLACE VIEW active_posts AS
SELECT p.id, p.title, u.full_name as author_name
FROM posts p
JOIN users u ON p.author_id = u.id
WHERE p.status = 'published';
```

**Benefits:**

- Simplify complex queries
- Provide data abstraction and security (expose only certain columns)
- No storage overhead (virtual table)
- Always show current data

**Limitations:**

- Can be slow for complex queries
- Not indexed (though underlying tables can be)
- Cannot directly update in most cases

### Materialized Views

Materialized views store query results physically, like a cached table.

```sql
-- Create materialized view
CREATE MATERIALIZED VIEW post_statistics AS
SELECT 
  p.id as post_id,
  p.title,
  COUNT(DISTINCT c.id) as comment_count,
  COUNT(DISTINCT l.id) as like_count,
  MAX(c.created_at) as last_comment_at
FROM posts p
LEFT JOIN comments c ON p.id = c.post_id
LEFT JOIN likes l ON p.id = l.post_id
GROUP BY p.id, p.title;

-- Create index on materialized view
CREATE INDEX idx_post_stats_post ON post_statistics(post_id);

-- Query materialized view
SELECT * FROM post_statistics ORDER BY like_count DESC LIMIT 10;

-- Refresh materialized view (update cached data)
REFRESH MATERIALIZED VIEW post_statistics;

-- Refresh without locking (allows concurrent reads)
REFRESH MATERIALIZED VIEW CONCURRENTLY post_statistics;

-- Drop materialized view
DROP MATERIALIZED VIEW post_statistics;
```

**Benefits:**

- Fast query performance (pre-computed results)
- Can be indexed for further optimization
- Reduces load on source tables

**Limitations:**

- Takes up storage space
- Data can be stale (requires manual refresh)
- Refresh can be slow for large datasets
- CONCURRENTLY refresh requires unique index

**Automatic refresh with triggers:**

```sql
-- Function to refresh materialized view
CREATE OR REPLACE FUNCTION refresh_post_statistics()
RETURNS TRIGGER AS $$
BEGIN
  REFRESH MATERIALIZED VIEW CONCURRENTLY post_statistics;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Trigger on comments table
CREATE TRIGGER refresh_stats_on_comment
AFTER INSERT OR UPDATE OR DELETE ON comments
FOR EACH STATEMENT
EXECUTE FUNCTION refresh_post_statistics();
```

[Inference: Frequent refreshes may impact performance. Consider using job schedulers for periodic refreshes instead of triggers on high-traffic tables.]

**Choosing between views and materialized views:**

- Use standard views for: queries on small datasets, when real-time data is critical, simple transformations
- Use materialized views for: expensive aggregations, complex joins across large tables, reporting and analytics, data that doesn't need real-time accuracy

