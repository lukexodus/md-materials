## Fuzzy Matching


Fuzzy matching finds approximate string matches using similarity algorithms, useful for typo tolerance and flexible searching.

### pg_trgm Extension

```sql
-- Enable extension
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Similarity search
SELECT name, similarity(name, 'PostgreSQL') as sim
FROM products
WHERE similarity(name, 'PostgreSQL') > 0.3
ORDER BY sim DESC;

-- Trigram index
CREATE INDEX idx_products_name_trgm ON products USING GIN (name gin_trgm_ops);
```

### Similarity Operators

```sql
-- Similar to (using threshold)
SELECT * FROM users WHERE email % 'john@example.com';

-- Word similarity
SELECT word_similarity('base', 'database') as sim;

-- Strict word similarity
SELECT strict_word_similarity('base', 'database') as sim;

-- Distance (inverse of similarity)
SELECT name <-> 'PostgreSQL' as distance
FROM products
ORDER BY distance
LIMIT 10;
```

### Fuzzy Search Function

```sql
CREATE OR REPLACE FUNCTION fuzzy_search_products(search_term text, threshold real DEFAULT 0.3)
RETURNS TABLE (
  id bigint,
  name text,
  similarity_score real
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id,
    p.name,
    similarity(p.name, search_term) as similarity_score
  FROM products p
  WHERE similarity(p.name, search_term) > threshold
  ORDER BY similarity_score DESC;
END;
$$ LANGUAGE plpgsql;
```

```javascript
const { data, error } = await supabase
  .rpc('fuzzy_search_products', { 
    search_term: 'PostgreSQL', 
    threshold: 0.3 
  })
```

### Levenshtein Distance

```sql
-- Enable fuzzystrmatch extension
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;

-- Calculate edit distance
SELECT levenshtein('PostgreSQL', 'Postgres');

-- Levenshtein with costs
SELECT levenshtein('PostgreSQL', 'Postgres', 1, 1, 2); -- ins, del, sub costs

-- Soundex matching
SELECT soundex('Smith') = soundex('Smyth');
```

