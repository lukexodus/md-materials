## Full-Text Search


Full-text search enables efficient searching of text content using PostgreSQL's built-in text search capabilities.

**Setting up full-text search in SQL:**

```sql
-- Add tsvector column for search index
ALTER TABLE posts ADD COLUMN search_vector tsvector;

-- Create function to update search vector
CREATE OR REPLACE FUNCTION update_search_vector()
RETURNS TRIGGER AS $$
BEGIN
  NEW.search_vector = 
    setweight(to_tsvector('english', COALESCE(NEW.title, '')), 'A') ||
    setweight(to_tsvector('english', COALESCE(NEW.content, '')), 'B') ||
    setweight(to_tsvector('english', COALESCE(NEW.tags::text, '')), 'C');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update search vector
CREATE TRIGGER posts_search_vector_update
  BEFORE INSERT OR UPDATE ON posts
  FOR EACH ROW
  EXECUTE FUNCTION update_search_vector();

-- Create GIN index for fast searching
CREATE INDEX posts_search_idx ON posts USING GIN (search_vector);

-- Update existing rows
UPDATE posts SET search_vector = 
  setweight(to_tsvector('english', COALESCE(title, '')), 'A') ||
  setweight(to_tsvector('english', COALESCE(content, '')), 'B') ||
  setweight(to_tsvector('english', COALESCE(tags::text, '')), 'C');
```

**Full-text search queries in SQL:**

```sql
-- Basic full-text search
SELECT * FROM posts
WHERE search_vector @@ to_tsquery('english', 'postgresql & database');

-- Search with ranking
SELECT 
  *,
  ts_rank(search_vector, to_tsquery('english', 'postgresql & database')) as rank
FROM posts
WHERE search_vector @@ to_tsquery('english', 'postgresql & database')
ORDER BY rank DESC;

-- Phrase search
SELECT * FROM posts
WHERE search_vector @@ phraseto_tsquery('english', 'database management system');

-- Plain text search (handles special characters automatically)
SELECT * FROM posts
WHERE search_vector @@ plainto_tsquery('english', 'postgresql database');

-- Websearch syntax (Google-like: quotes for phrases, - for exclusion)
SELECT * FROM posts
WHERE search_vector @@ websearch_to_tsquery('english', '"full text" search -mysql');

-- Search with highlighting
SELECT 
  id,
  title,
  ts_headline('english', content, 
    to_tsquery('english', 'postgresql & database'),
    'StartSel=<mark>, StopSel=</mark>, MaxWords=50, MinWords=25'
  ) as highlighted_content
FROM posts
WHERE search_vector @@ to_tsquery('english', 'postgresql & database');

-- Fuzzy search with similarity (requires pg_trgm extension)
CREATE EXTENSION IF NOT EXISTS pg_trgm;

SELECT *, similarity(title, 'postgressql') as sim
FROM posts
WHERE title % 'postgressql'  -- % is similarity operator
ORDER BY sim DESC;
```

**Full-text search operators:**

- `&` - AND (both terms must be present)
- `|` - OR (either term must be present)
- `!` - NOT (term must not be present)
- `<->` - followed by (terms must be adjacent)
- `<N>` - distance (terms must be within N words)

```sql
-- Examples
'postgresql & database'  -- Both words must appear
'postgresql | mysql'  -- Either word must appear
'database & !mysql'  -- database must appear, mysql must not
'database <-> management'  -- Words must be adjacent
'database <2> system'  -- Words must be within 2 positions
```

**Supabase JavaScript client full-text search:**

```javascript
// Basic text search
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .textSearch('search_vector', 'postgresql & database');

// Plain text search
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .textSearch('search_vector', 'postgresql database', { type: 'plain' });

// Phrase search
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .textSearch('search_vector', 'database management system', { type: 'phrase' });

// Websearch syntax
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .textSearch('search_vector', '"full text" search -mysql', { type: 'websearch' });

// Search with additional filters
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .textSearch('search_vector', 'postgresql')
  .eq('status', 'published')
  .gte('created_at', '2024-01-01')
  .order('created_at', { ascending: false });

// Search across multiple columns without tsvector column
const { data, error } = await supabase
  .from('posts')
  .select('*')
  .or('title.ilike.%postgresql%,content.ilike.%postgresql%');
```

**Custom search function with ranking:**

```sql
-- Create function for ranked search
CREATE OR REPLACE FUNCTION search_posts(search_query text)
RETURNS TABLE (
  id UUID,
  title TEXT,
  content TEXT,
  rank REAL
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id,
    p.title,
    p.content,
    ts_rank(p.search_vector, websearch_to_tsquery('english', search_query)) as rank
  FROM posts p
  WHERE p.search_vector @@ websearch_to_tsquery('english', search_query)
    AND p.deleted_at IS NULL
  ORDER BY rank DESC
  LIMIT 50;
END;
$$ LANGUAGE plpgsql;

-- Call from JavaScript
const { data, error } = await supabase.rpc('search_posts', {
  search_query: 'postgresql database'
});
```

