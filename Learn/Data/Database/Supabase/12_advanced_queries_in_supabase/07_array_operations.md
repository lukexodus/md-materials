## Array Operations


PostgreSQL arrays store multiple values in a single column with powerful querying capabilities.

### Array Creation and Querying

```javascript
// Insert array
const { data, error } = await supabase
  .from('posts')
  .insert({ 
    title: 'My Post', 
    tags: ['javascript', 'supabase', 'postgres'] 
  })

// Query with array contains
const { data, error } = await supabase
  .from('posts')
  .select()
  .contains('tags', ['javascript'])

// Overlap check
const { data, error } = await supabase
  .from('posts')
  .select()
  .overlaps('tags', ['javascript', 'python'])
```

### Array Functions in SQL

```sql
-- Array length
SELECT array_length(tags, 1) FROM posts;

-- Array append
UPDATE posts SET tags = array_append(tags, 'new-tag');

-- Array remove
UPDATE posts SET tags = array_remove(tags, 'old-tag');

-- Array concatenation
UPDATE posts SET tags = tags || ARRAY['tag1', 'tag2'];

-- Unnest (expand to rows)
SELECT unnest(tags) as tag FROM posts WHERE id = 1;

-- Array aggregation
SELECT array_agg(name) as all_names FROM users;
```

### Array Operators

```sql
-- Contains
SELECT * FROM posts WHERE tags @> ARRAY['postgres'];

-- Contained by
SELECT * FROM posts WHERE ARRAY['postgres'] <@ tags;

-- Overlap
SELECT * FROM posts WHERE tags && ARRAY['javascript', 'python'];

-- Array element access
SELECT tags[1] as first_tag FROM posts;

-- Array slicing
SELECT tags[1:3] FROM posts;
```

### Array Indexing

```sql
-- GIN index for array containment
CREATE INDEX idx_tags_gin ON posts USING GIN (tags);
```

