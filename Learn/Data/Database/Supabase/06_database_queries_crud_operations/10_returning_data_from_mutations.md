## Returning Data from Mutations


PostgreSQL's RETURNING clause allows INSERT, UPDATE, and DELETE operations to return data from affected rows.

**SQL RETURNING clause:**

```sql
-- Insert and return inserted row
INSERT INTO posts (title, content, author_id)
VALUES ('New Post', 'Content here', 'uuid-here')
RETURNING *;

-- Insert and return specific columns
INSERT INTO posts (title, content, author_id)
VALUES ('New Post', 'Content here', 'uuid-here')
RETURNING id, created_at;

-- Insert multiple and return all
INSERT INTO posts (title, content, author_id) VALUES
  ('Post 1', 'Content 1', 'uuid-1'),
  ('Post 2', 'Content 2', 'uuid-2')
RETURNING *;

-- Update and return updated rows
UPDATE posts
SET status = 'published', published_at = NOW()
WHERE status = 'draft' AND created_at < NOW() - INTERVAL '7 days'
RETURNING id, title, published_at;

-- Update and return computed values
UPDATE products
SET price = price * 1.1
RETURNING id, name, price as new_price, price / 1.1 as old_price;

-- Delete and return deleted rows
DELETE FROM posts
WHERE status = 'spam'
RETURNING id, title, author_id;

-- Complex RETURNING with joins (using CTEs)
WITH deleted AS (
  DELETE FROM comments
  WHERE created_at < NOW() - INTERVAL '1 year'
  RETURNING *
)
SELECT 
  d.*,
  u.full_name as author_name
FROM deleted d
JOIN users u ON d.user_id = u.id;
```

**Supabase JavaScript client returning data:**

```javascript
// Insert and return
const { data, error } = await supabase
  .from('posts')
  .insert({
    title: 'New Post',
    content: 'Content here',
    author_id: 'uuid-here'
  })
  .select();  // Returns inserted row

// Insert specific columns only
const { data, error } = await supabase
  .from('posts')
  .insert({
    title: 'New Post',
    content: 'Content here',
    author_id: 'uuid-here'
  })
  .select('id, title, created_at');

// Insert multiple and return
const { data, error } = await supabase
  .from('posts')
  .insert([
    { title: 'Post 1', content: 'Content 1', author_id: 'uuid-1' },
    { title: 'Post 2', content: 'Content 2', author_id: 'uuid-2' }
  ])
  .select();

// Insert with nested select
const { data, error } = await supabase
  .from('posts')
  .insert({
    title: 'New Post',
    content: 'Content here',
    author_id: 'uuid-here'
  })
  .select(`
    id,
    title,
    author:users (
      full_name,
      email
    )
  `);

// Update and return
const { data, error } = await supabase
  .from('posts')
  .update({ status: 'published', published_at: new Date().toISOString() })
  .eq('id', 'uuid-here')
  .select();

// Update multiple and return
const { data, error } = await supabase
  .from('posts')
  .update({ featured: true })
  .gte('likes', 100)
  .select('id, title, likes');

// Delete and return
const { data, error } = await supabase
  .from('posts')
  .delete()
  .eq('status', 'spam')
  .select();

// Upsert and return
const { data, error } = await supabase
  .from('users')
  .upsert({
    id: 'uuid-here',
    email: 'user@example.com',
    full_name: 'John Doe'
  })
  .select();

// Don't return data (faster for bulk operations)
const { error } = await supabase
  .from('posts')
  .insert({ title: 'New Post', content: 'Content' });
// No .select() call
```

**Using returned data:**

```javascript
// Single insert
const { data, error } = await supabase
  .from('posts')
  .insert({
    title: 'New Post',
    content: 'Content here',
    author_id: userId
  })
  .select()
  .single();  // Returns single object instead of array

if (error) {
  console.error('Error:', error);
} else {
  console.log('Created post ID:', data.id);
  console.log('Created at:', data.created_at);
}

// Multiple inserts
const { data, error } = await supabase
  .from('comments')
  .insert(commentsArray)
  .select();

if (data) {
  const insertedIds = data.map(comment => comment.id);
  console.log('Inserted IDs:', insertedIds);
}

// Update with returned data
const { data, error } = await supabase
  .from('posts')
  .update({ view_count: 150 })
  .eq('id', postId)
  .select()
  .single();

if (data) {
  // Use updated data to update UI
  updateUI(data);
}
```

