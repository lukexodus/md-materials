## Bulk Operations


Bulk operations efficiently handle multiple rows in a single database transaction.

**SQL bulk inserts:**

```sql
-- Insert multiple rows
INSERT INTO posts (title, content, author_id) VALUES
  ('Post 1', 'Content 1', 'uuid-1'),
  ('Post 2', 'Content 2', 'uuid-2'),
  ('Post 3', 'Content 3', 'uuid-3'),
  ('Post 4', 'Content 4', 'uuid-4');

-- Insert from SELECT
INSERT INTO archived_posts
SELECT * FROM posts
WHERE created_at < NOW() - INTERVAL '1 year';

-- Insert with ON CONFLICT (bulk upsert)
INSERT INTO user_settings (user_id, setting_key, setting_value) VALUES
  ('uuid-1', 'theme', 'dark'),
  ('uuid-2', 'theme', 'light'),
  ('uuid-3', 'theme', 'dark')
ON CONFLICT (user_id, setting_key)
DO UPDATE SET 
  setting_value = EXCLUDED.setting_value,
  updated_at = NOW();
```

**SQL bulk updates:**

```sql
-- Update multiple rows
UPDATE posts
SET status = 'published', published_at = NOW()
WHERE status = 'draft' AND created_at < NOW() - INTERVAL '7 days';

-- Update from VALUES (PostgreSQL 14+)
UPDATE posts
SET likes = updates.new_likes
FROM (VALUES
  ('uuid-1'::uuid, 150),
  ('uuid-2'::uuid, 200),
  ('uuid-3'::uuid, 175)
) AS updates(id, new_likes)
WHERE posts.id = updates.id;

-- Update from temporary table
CREATE TEMP TABLE post_updates (
  id UUID,
  new_status TEXT,
  new_likes INTEGER
);

INSERT INTO post_updates VALUES
  ('uuid-1', 'featured', 150),
  ('uuid-2', 'published', 200);

UPDATE posts
SET 
  status = post_updates.new_status,
  likes = post_updates.new_likes
FROM post_updates
WHERE posts.id = post_updates.id;

DROP TABLE post_updates;

-- Conditional bulk update with CASE
UPDATE posts
SET priority = CASE
  WHEN likes >= 1000 THEN 'high'
  WHEN likes >= 100 THEN 'medium'
  ELSE 'low'
END
WHERE status = 'published';
```

**SQL bulk deletes:**

```sql
-- Delete multiple rows
DELETE FROM posts
WHERE status = 'spam' OR deleted_at < NOW() - INTERVAL '30 days';

-- Delete with subquery
DELETE FROM comments
WHERE post_id IN (
  SELECT id FROM posts WHERE status = 'deleted'
);

-- Delete and archive
WITH deleted AS (
  DELETE FROM posts
  WHERE status = 'spam'
  RETURNING *
)
INSERT INTO spam_archive
SELECT * FROM deleted;

-- Bulk delete with USING
DELETE FROM comments c
USING posts p
WHERE c.post_id = p.id AND p.status = 'deleted';
```

**Supabase JavaScript client bulk operations:**

```javascript
// Bulk insert
const { data, error } = await supabase
  .from('posts')
  .insert([
    { title: 'Post 1', content: 'Content 1', author_id: 'uuid-1' },
    { title: 'Post 2', content: 'Content 2', author_id: 'uuid-2' },
    { title: 'Post 3', content: 'Content 3', author_id: 'uuid-3' },
    // ... up to thousands of rows
  ])
  .select();

// Bulk insert without returning data (faster)
const { error } = await supabase
  .from('posts')
  .insert(largeArrayOfPosts);

// Bulk upsert
const { data, error } = await supabase
  .from('user_settings')
  .upsert([
    { user_id: 'uuid-1', setting_key: 'theme', setting_value: 'dark' },
    { user_id: 'uuid-2', setting_key: 'theme', setting_value: 'light' },
    { user_id: 'uuid-3', setting_key: 'language', setting_value: 'en' }
  ])
  .select();

// Bulk update (updates all matching rows)
const { data, error } = await supabase
  .from('posts')
  .update({ status: 'archived' })
  .in('id', ['uuid-1', 'uuid-2', 'uuid-3'])
  .select();

// Bulk delete
const { error } = await supabase
  .from('comments')
  .delete()
  .in('id', commentIdsToDelete);

// Process large datasets in batches
async function bulkInsertWithBatching(items, batchSize = 1000) {
  const results = [];
  
  for (let i = 0; i < items.length; i += batchSize) {
    const batch = items.slice(i, i + batchSize);
    const { data, error } = await supabase
      .from('posts')
      .insert(batch)
      .select();
    
    if (error) {
      console.error(`Error inserting batch ${i / batchSize + 1}:`, error);
      throw error;
    }
    
    results.push(...data);
  }
  
  return results;
}

// Usage
const posts = [...]; // Large array of posts
const inserted = await bulkInsertWithBatching(posts);
```

**Transaction-based bulk operations:**

```sql
-- Ensure all operations succeed or all fail
BEGIN;

INSERT INTO orders (user_id, total_amount)
VALUES ('uuid-here', 100.00)
RETURNING id INTO order_id;

INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
  (order_id, 'product-1', 2, 25.00),
  (order_id, 'product-2', 1, 50.00);

UPDATE products
SET stock = stock - 2
WHERE id = 'product-1';

UPDATE products
SET stock = stock - 1
WHERE id = 'product-2';

COMMIT;
-- If any statement fails, use ROLLBACK;
```

**RPC for complex bulk operations:**

```sql
-- Create function for bulk upsert with custom logic
CREATE OR REPLACE FUNCTION bulk_upsert_posts(posts JSON)
RETURNS TABLE (
  id UUID,
  title TEXT,
  action TEXT
) AS $$
DECLARE
  post JSON;
BEGIN
  FOR post IN SELECT * FROM json_array_elements(posts)
  LOOP
    INSERT INTO posts (id, title, content, author_id)
    VALUES (
      (post->>'id')::UUID,
      post->>'title',
      post->>'content',
      (post->>'author_id')::UUID
    )
    ON CONFLICT (id)
    DO UPDATE SET
      title = EXCLUDED.title,
      content = EXCLUDED.content,
      updated_at = NOW()
    RETURNING posts.id, posts.title, 
      CASE WHEN xmax = 0 THEN 'inserted' ELSE 'updated' END;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Call from JavaScript
const { data, error } = await supabase.rpc('bulk_upsert_posts', {
  posts: JSON.stringify(postsArray)
});
```

**Performance considerations for bulk operations:**

[Inference: These are general database optimization principles. Specific performance characteristics may vary based on your infrastructure and data.]

- Use batch sizes of 500-1000 rows for optimal performance
- Disable triggers temporarily for very large bulk inserts if appropriate
- Use COPY command for importing millions of rows (faster than INSERT)
- Drop indexes before bulk insert, recreate after (for very large datasets)
- Use UNLOGGED tables for temporary bulk operations (not crash-safe)
- Consider partitioning for tables with billions of rows
- Monitor connection pool usage during bulk operations

```sql
-- Example: Efficient bulk import
BEGIN;

-- Disable triggers if safe
ALTER TABLE posts DISABLE TRIGGER ALL;

-- Drop non-essential indexes
DROP INDEX IF EXISTS idx_posts_created;
DROP INDEX IF EXISTS idx_posts_status;

-- Bulk insert
COPY posts (title, content, author_id) FROM '/path/to/data.csv' CSV HEADER;

-- Recreate indexes
CREATE INDEX idx_posts_created ON posts(created_at);
CREATE INDEX idx_posts_status ON posts(status);

-- Re-enable triggers
ALTER TABLE posts ENABLE TRIGGER ALL;

-- Update statistics
ANALYZE posts;

COMMIT;
```

**Key points:**

- CRUD operations form the foundation of database interactions in Supabase
- Filtering operators provide precise control over data retrieval
- Full-text search requires proper indexing with tsvector and GIN indexes
- Joins and nested queries enable complex data relationships
- Aggregations compute summary statistics across grouped data
- RETURNING clauses provide immediate feedback from mutations
- Bulk operations optimize performance for multiple-row transactions
- Always consider RLS policies when designing queries
- Use appropriate indexes to optimize query performance
- Batch large operations to avoid timeout and memory issues

---

