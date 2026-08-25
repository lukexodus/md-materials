## Indexes and Performance Optimization


Indexes dramatically improve query performance by allowing the database to find rows quickly without scanning entire tables.

**Creating indexes:**

```sql
-- Single column index
CREATE INDEX idx_users_email ON users(email);

-- Composite index (order matters)
CREATE INDEX idx_posts_author_created ON posts(author_id, created_at);

-- Unique index (enforces uniqueness)
CREATE UNIQUE INDEX idx_users_username ON users(username);

-- Partial index (only indexes subset of rows)
CREATE INDEX idx_active_users ON users(email) WHERE active = true;

-- Expression index
CREATE INDEX idx_users_lower_email ON users(LOWER(email));

-- Index on JSONB column
CREATE INDEX idx_metadata ON products USING GIN (metadata);

-- Full-text search index
CREATE INDEX idx_posts_search ON posts USING GIN (to_tsvector('english', title || ' ' || content));
```

Primary keys and unique constraints automatically create indexes. Foreign keys do NOT automatically create indexes on the referencing column, so you should create them manually:

```sql
CREATE INDEX idx_posts_author_id ON posts(author_id);
```

**Index types:**

- `BTREE` (default) - balanced tree, good for equality and range queries
- `HASH` - hash table, only for equality comparisons
- `GIN` (Generalized Inverted Index) - for JSONB, arrays, full-text search
- `GIST` (Generalized Search Tree) - for geometric data, full-text search
- `BRIN` (Block Range Index) - for very large tables with natural ordering

**Performance optimization strategies:**

Monitor query performance with `EXPLAIN ANALYZE`:

```sql
EXPLAIN ANALYZE SELECT * FROM posts WHERE author_id = 'uuid-here';
```

This shows the query execution plan and actual timing. Look for "Seq Scan" (sequential scan) which indicates missing indexes.

**Key optimization techniques:**

- Index foreign keys used in JOIN operations
- Index columns frequently used in WHERE, ORDER BY, and JOIN clauses
- Use composite indexes for queries filtering on multiple columns
- Avoid over-indexing (indexes slow down INSERT/UPDATE/DELETE operations)
- Use `VACUUM` and `ANALYZE` to maintain statistics (Supabase handles this automatically)
- Consider partitioning for very large tables
- Use connection pooling (Supabase includes PgBouncer by default)
- Limit result sets with pagination using LIMIT and OFFSET or cursor-based pagination

**Example:** For a social media application:

```sql
-- Posts table
CREATE INDEX idx_posts_author_created ON posts(author_id, created_at DESC);
CREATE INDEX idx_posts_created ON posts(created_at DESC);

-- Comments table
CREATE INDEX idx_comments_post ON comments(post_id);
CREATE INDEX idx_comments_user ON comments(user_id);

-- Followers table
CREATE INDEX idx_followers_following ON followers(following_id);
CREATE INDEX idx_followers_follower ON followers(follower_id);
```

