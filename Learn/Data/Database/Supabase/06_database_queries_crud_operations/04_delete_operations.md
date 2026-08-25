## DELETE Operations


DELETE operations remove rows from tables.

**SQL DELETE syntax:**

```sql
-- Delete specific row
DELETE FROM posts WHERE id = 'uuid-here';

-- Delete multiple rows
DELETE FROM posts WHERE status = 'draft' AND created_at < NOW() - INTERVAL '30 days';

-- Delete with subquery
DELETE FROM comments
WHERE post_id IN (
  SELECT id FROM posts WHERE status = 'deleted'
);

-- Delete from multiple tables (using CASCADE foreign keys)
DELETE FROM users WHERE id = 'uuid-here';
-- Automatically deletes related posts, comments if foreign keys set with ON DELETE CASCADE

-- Delete and return deleted rows
DELETE FROM posts
WHERE status = 'spam'
RETURNING *;

-- Delete all rows (use with caution)
DELETE FROM temporary_logs;

-- Truncate table (faster than DELETE, resets sequences)
TRUNCATE TABLE temporary_logs;
TRUNCATE TABLE temporary_logs RESTART IDENTITY;  -- Reset auto-increment
TRUNCATE TABLE temporary_logs CASCADE;  -- Also truncate dependent tables
```

**Soft delete pattern:**

```sql
-- Add deleted_at column
ALTER TABLE posts ADD COLUMN deleted_at TIMESTAMPTZ;

-- Soft delete (mark as deleted)
UPDATE posts 
SET deleted_at = NOW() 
WHERE id = 'uuid-here';

-- Query excluding soft-deleted rows
SELECT * FROM posts WHERE deleted_at IS NULL;

-- Create view for active records
CREATE VIEW active_posts AS
SELECT * FROM posts WHERE deleted_at IS NULL;

-- Restore soft-deleted row
UPDATE posts 
SET deleted_at = NULL 
WHERE id = 'uuid-here';

-- Hard delete soft-deleted rows older than 30 days
DELETE FROM posts 
WHERE deleted_at < NOW() - INTERVAL '30 days';
```

**Supabase JavaScript client DELETE:**

```javascript
// Delete single row
const { error } = await supabase
  .from('posts')
  .delete()
  .eq('id', 'uuid-here');

// Delete multiple rows
const { error } = await supabase
  .from('posts')
  .delete()
  .eq('status', 'draft')
  .lt('created_at', '2023-01-01');

// Delete with multiple filters
const { error } = await supabase
  .from('comments')
  .delete()
  .eq('post_id', 'uuid-here')
  .eq('flagged', true);

// Delete and return deleted rows
const { data, error } = await supabase
  .from('posts')
  .delete()
  .eq('status', 'spam')
  .select();

// Soft delete implementation
const { error } = await supabase
  .from('posts')
  .update({ deleted_at: new Date().toISOString() })
  .eq('id', 'uuid-here');
```

