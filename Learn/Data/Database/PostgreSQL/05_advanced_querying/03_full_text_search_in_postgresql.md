## Full-Text Search in PostgreSQL


### Introduction to PostgreSQL Full-Text Search

PostgreSQL offers powerful built-in full-text search capabilities that allow you to efficiently search through text data, ranking results by relevance. Unlike simple pattern matching using LIKE or regular expressions, PostgreSQL's full-text search understands concepts like stemming, ranking, and linguistic processing to deliver more intelligent search results.

### Core Concepts

#### Text Search Data Types

PostgreSQL introduces specialized data types for text search:

- `tsvector`: Represents a document optimized for text search, containing sorted, normalized lexemes
- `tsquery`: Represents a search query with boolean operators and lexemes to search for

#### Text Search Functions

- `to_tsvector()`: Converts text to a tsvector
- `to_tsquery()`: Parses text into a tsquery
- `plainto_tsquery()`: Converts plain text to tsquery without special operators
- `phraseto_tsquery()`: Creates a tsquery that searches for exact phrases
- `websearch_to_tsquery()`: Parses web-style search syntax with quotes and operators
- `ts_rank()`: Ranks documents by relevance
- `ts_rank_cd()`: Ranks documents using cover density ranking

### Basic Full-Text Search Setup

#### Creating a Simple Text Search

```sql
SELECT to_tsvector('english', 'The quick brown fox jumps over the lazy dog');
```

**Output:**

```
'brown':3 'dog':9 'fox':4 'jump':5 'lazi':8 'over':6 'quick':2
```

#### Performing a Simple Search

```sql
SELECT to_tsvector('english', 'The quick brown fox jumps over the lazy dog') @@ 
       to_tsquery('english', 'fox & dog');
```

**Output:**

```
true
```

### Advanced Search Techniques

#### GIN Index for Performance

For improved performance on text search operations, create a GIN (Generalized Inverted Index) index:

```sql
CREATE INDEX idx_fts_article_content ON articles 
USING GIN (to_tsvector('english', content));
```

#### Using Text Search in WHERE Clauses

```sql
SELECT title, content 
FROM articles 
WHERE to_tsvector('english', content) @@ to_tsquery('english', 'database & postgresql');
```

#### Ranking Search Results

```sql
SELECT title, 
       ts_rank(to_tsvector('english', content), to_tsquery('english', 'postgresql')) AS rank
FROM articles
WHERE to_tsvector('english', content) @@ to_tsquery('english', 'postgresql')
ORDER BY rank DESC;
```

### Search Configuration

#### Available Languages

PostgreSQL supports multiple languages for text search configuration. Some examples:

- english
- spanish
- french
- german
- russian
- chinese
- japanese

Check available configurations:

```sql
SELECT cfgname FROM pg_ts_config;
```

#### Custom Search Configurations

Create custom dictionaries and configurations for specialized search needs:

```sql
CREATE TEXT SEARCH DICTIONARY my_simple_dict (
    TEMPLATE = pg_catalog.simple
);

CREATE TEXT SEARCH CONFIGURATION my_configuration (
    COPY = english
);

ALTER TEXT SEARCH CONFIGURATION my_configuration
    ALTER MAPPING FOR asciiword WITH my_simple_dict;
```

### Full-Text Search with Document Preprocessing

#### Creating a Search Vector Column

For frequently searched tables, store the tsvector directly:

```sql
ALTER TABLE articles 
ADD COLUMN search_vector tsvector;

UPDATE articles SET search_vector = 
    to_tsvector('english', coalesce(title,'') || ' ' || coalesce(content,''));

CREATE INDEX idx_fts_article ON articles 
USING GIN (search_vector);
```

#### Automatic Vector Updates with Triggers

```sql
CREATE FUNCTION articles_search_vector_update() RETURNS trigger AS $$
BEGIN
    NEW.search_vector := 
        to_tsvector('english', coalesce(NEW.title,'') || ' ' || coalesce(NEW.content,''));
    RETURN NEW;
END
$$ LANGUAGE plpgsql;

CREATE TRIGGER articles_search_vector_update
BEFORE INSERT OR UPDATE ON articles
FOR EACH ROW EXECUTE FUNCTION articles_search_vector_update();
```

### Advanced Search Operators

#### Boolean Operators

- `&` (AND): Requires both terms
- `|` (OR): Requires at least one term
- `!` (NOT): Excludes documents containing the term

```sql
SELECT title FROM articles 
WHERE search_vector @@ to_tsquery('english', 'postgresql & !mysql');
```

#### Proximity Searches

Find terms near each other with the `<->` operator:

```sql
SELECT title FROM articles 
WHERE search_vector @@ to_tsquery('english', 'postgresql <-> database');
```

#### Prefix Matching

Use `:*` for prefix matching:

```sql
SELECT title FROM articles 
WHERE search_vector @@ to_tsquery('english', 'post:*');
```

### Highlighting Search Results

PostgreSQL provides functions to highlight matching terms:

```sql
SELECT title,
       ts_headline('english', content, to_tsquery('english', 'postgresql'),
                  'StartSel = <b>, StopSel = </b>, MaxWords=35, MinWords=15');
FROM articles
WHERE search_vector @@ to_tsquery('english', 'postgresql');
```

### Handling Phrases and Special Characters

#### Phrase Searches

```sql
SELECT title FROM articles 
WHERE search_vector @@ phraseto_tsquery('english', 'PostgreSQL database');
```

#### Handling Special Characters

```sql
SELECT title FROM articles 
WHERE search_vector @@ websearch_to_tsquery('english', '"PostgreSQL database" -oracle');
```

### Performance Considerations

- Use GIN indexes for faster search
- Pre-compute tsvector values when possible
- Use covering indexes to avoid table lookups
- Consider partitioning large tables
- Monitor and analyze query performance

### Language-Specific Features

#### Stemming

Stemming reduces words to their base form, allowing matches across different forms:

```sql
SELECT to_tsvector('english', 'running runs runner') @@ to_tsquery('english', 'run');
```

**Output:**

```
true
```

#### Stop Words

Common words (like "the", "and", "is") are automatically removed:

```sql
SELECT to_tsvector('english', 'The quick brown fox');
```

**Output:**

```
'brown':3 'fox':4 'quick':2
```

### Integration with Application Development

#### Full-Text Search in ORMs

Example with Ruby on Rails:

```ruby
class Article < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search_full_text, 
                  against: {
                    title: 'A',
                    content: 'B'
                  },
                  using: {
                    tsearch: {
                      dictionary: 'english',
                      tsvector_column: 'search_vector'
                    }
                  }
end
```

### Comparison with Other Search Technologies

While PostgreSQL's full-text search is powerful, consider these alternatives for specific needs:

- Elasticsearch: Better for distributed, large-scale search
- Apache Solr: Rich features for faceted search and analytics
- PostgreSQL FTS: Excellent when keeping search within your database is preferred

### Common Troubleshooting

- Check text search configuration
- Verify proper indexing
- Analyze search patterns with `EXPLAIN ANALYZE`
- Ensure up-to-date search vectors for modified content
- Consider normalization for international text

### Real-World Use Cases

- Document management systems
- Content management systems
- E-commerce product search
- Knowledge bases and wikis
- Log and audit trail analysis

### Further Reading and Resources

Important subtopics for deeper study:

- tsvector and GIN index optimization techniques
- Multi-language search implementations
- Combining full-text search with geographic and metadata filtering
- Fuzzy search extensions like pg_trgm
- Text search dictionary customization

---

