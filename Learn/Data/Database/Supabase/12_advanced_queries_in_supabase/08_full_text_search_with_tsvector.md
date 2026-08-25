## Full-Text Search with tsvector


PostgreSQL's full-text search converts text to lexemes (normalized words) and enables ranked search results.

### Basic Setup

```sql
-- Add tsvector column
ALTER TABLE articles ADD COLUMN search_vector tsvector;

-- Generate tsvector
UPDATE articles 
SET search_vector = to_tsvector('english', title || ' ' || body);

-- Create trigger for automatic updates
CREATE TRIGGER articles_search_update
BEFORE INSERT OR UPDATE ON articles
FOR EACH ROW EXECUTE FUNCTION
tsvector_update_trigger(search_vector, 'pg_catalog.english', title, body);

-- Create GIN index
CREATE INDEX idx_articles_search ON articles USING GIN (search_vector);
```

### Querying

```sql
-- Basic search
CREATE OR REPLACE FUNCTION search_articles(search_query text)
RETURNS TABLE (
  id bigint,
  title text,
  rank real
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    a.id,
    a.title,
    ts_rank(a.search_vector, to_tsquery('english', search_query)) as rank
  FROM articles a
  WHERE a.search_vector @@ to_tsquery('english', search_query)
  ORDER BY rank DESC;
END;
$$ LANGUAGE plpgsql;
```

```javascript
const { data, error } = await supabase
  .rpc('search_articles', { search_query: 'postgres & supabase' })
```

### Advanced Query Operators

```sql
-- AND operation
to_tsquery('postgres & supabase')

-- OR operation
to_tsquery('postgres | mysql')

-- NOT operation
to_tsquery('postgres & !mysql')

-- Phrase search
to_tsquery('postgres <-> supabase')

-- Proximity search (within 3 words)
to_tsquery('postgres <3> supabase')

-- Prefix search
to_tsquery('post:*')
```

### Highlighting Results

```sql
SELECT 
  id,
  title,
  ts_headline('english', body, to_tsquery('english', 'postgres'), 
    'StartSel=<mark>, StopSel=</mark>') as highlighted_body
FROM articles
WHERE search_vector @@ to_tsquery('english', 'postgres');
```

### Weighted Search

```sql
-- Assign weights (A = highest, D = lowest)
UPDATE articles 
SET search_vector = 
  setweight(to_tsvector('english', coalesce(title, '')), 'A') ||
  setweight(to_tsvector('english', coalesce(body, '')), 'B') ||
  setweight(to_tsvector('english', coalesce(tags::text, '')), 'C');

-- Rank with weights
SELECT ts_rank('{0.1, 0.2, 0.4, 1.0}', search_vector, query) as rank
FROM articles, to_tsquery('postgres') query
WHERE search_vector @@ query;
```

