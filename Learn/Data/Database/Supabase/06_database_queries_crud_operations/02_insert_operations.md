## INSERT Operations


INSERT operations add new rows to tables.

**SQL INSERT syntax:**

```sql
-- Insert single row
INSERT INTO posts (title, content, author_id, status)
VALUES ('My First Post', 'This is the content', 'uuid-here', 'draft');

-- Insert with default values
INSERT INTO posts (title, content, author_id)
VALUES ('Another Post', 'More content', 'uuid-here');
-- status will use DEFAULT value if defined

-- Insert multiple rows
INSERT INTO posts (title, content, author_id) VALUES
  ('Post 1', 'Content 1', 'uuid-1'),
  ('Post 2', 'Content 2', 'uuid-2'),
  ('Post 3', 'Content 3', 'uuid-3');

-- Insert from SELECT (copy data from another table)
INSERT INTO archived_posts (id, title, content, author_id)
SELECT id, title, content, author_id
FROM posts
WHERE created_at < NOW() - INTERVAL '1 year';

-- Insert and return inserted row
INSERT INTO posts (title, content, author_id)
VALUES ('New Post', 'Fresh content', 'uuid-here')
RETURNING *;

-- Insert and return specific columns
INSERT INTO posts (title, content, author_id)
VALUES ('New Post', 'Fresh content', 'uuid-here')
RETURNING id, created_at;
```

**Handling conflicts with UPSERT (INSERT ... ON CONFLICT):**

```sql
-- Insert or do nothing if conflict
INSERT INTO users (id, email, full_name)
VALUES ('uuid-here', 'user@example.com', 'John Doe')
ON CONFLICT (email) DO NOTHING;

-- Insert or update if conflict (UPSERT)
INSERT INTO users (id, email, full_name, updated_at)
VALUES ('uuid-here', 'user@example.com', 'John Doe', NOW())
ON CONFLICT (email) 
DO UPDATE SET 
  full_name = EXCLUDED.full_name,
  updated_at = NOW();

-- Upsert with condition
INSERT INTO page_views (page_id, view_count)
VALUES ('page-uuid', 1)
ON CONFLICT (page_id)
DO UPDATE SET 
  view_count = page_views.view_count + 1,
  updated_at = NOW();
```

**Supabase JavaScript client INSERT:**

```javascript
// Insert single row
const { data, error } = await supabase
  .from('posts')
  .insert({
    title: 'My First Post',
    content: 'This is the content',
    author_id: 'uuid-here',
    status: 'draft'
  })
  .select();  // Returns inserted row

// Insert without returning data
const { error } = await supabase
  .from('posts')
  .insert({
    title: 'My First Post',
    content: 'This is the content',
    author_id: 'uuid-here'
  });

// Insert multiple rows
const { data, error } = await supabase
  .from('posts')
  .insert([
    { title: 'Post 1', content: 'Content 1', author_id: 'uuid-1' },
    { title: 'Post 2', content: 'Content 2', author_id: 'uuid-2' },
    { title: 'Post 3', content: 'Content 3', author_id: 'uuid-3' }
  ])
  .select();

// Upsert (insert or update if exists)
const { data, error } = await supabase
  .from('users')
  .upsert({
    id: 'uuid-here',
    email: 'user@example.com',
    full_name: 'John Doe'
  })
  .select();

// Upsert with onConflict option
const { data, error } = await supabase
  .from('users')
  .upsert(
    { email: 'user@example.com', full_name: 'John Doe' },
    { onConflict: 'email' }
  )
  .select();

// Insert with ignoreDuplicates option
const { data, error } = await supabase
  .from('users')
  .upsert(
    { email: 'user@example.com', full_name: 'John Doe' },
    { onConflict: 'email', ignoreDuplicates: true }
  )
  .select();
```

