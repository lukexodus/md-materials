## Full-Text Search


SQLite includes the FTS5 extension for full-text search.

```sql
-- Create a virtual FTS5 table
CREATE VIRTUAL TABLE articles_fts USING fts5(title, body);

-- Populate it
INSERT INTO articles_fts SELECT title, body FROM articles;

-- Query it
SELECT * FROM articles_fts WHERE articles_fts MATCH 'sqlite database';

-- Ranked results
SELECT *, rank FROM articles_fts WHERE articles_fts MATCH 'sqlite' ORDER BY rank;
```

FTS5 supports boolean operators (`AND`, `OR`, `NOT`), phrase queries (`"exact phrase"`), and prefix queries (`sqlite*`).

---

