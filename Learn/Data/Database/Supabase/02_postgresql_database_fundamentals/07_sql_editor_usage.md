## SQL Editor Usage


The Supabase SQL Editor is a web-based interface for executing SQL queries directly against your PostgreSQL database.

**Key features:**

- Syntax highlighting and autocomplete
- Query history and saved queries
- Multiple query execution (separated by semicolons)
- Results export to CSV
- Query templates for common operations
- Keyboard shortcuts (Ctrl/Cmd + Enter to run)

**Accessing SQL Editor:** Navigate to SQL Editor in the Supabase Dashboard sidebar. The editor displays your database schema in the sidebar for reference.

**Running queries:**

```sql
-- Select data
SELECT * FROM users LIMIT 10;

-- Insert data
INSERT INTO posts (title, content, author_id)
VALUES ('Hello World', 'This is my first post', 'uuid-here');

-- Update data
UPDATE users
SET full_name = 'John Doe'
WHERE id = 'uuid-here';

-- Delete data
DELETE FROM posts WHERE created_at < NOW() - INTERVAL '1 year';
```

**Using variables (prepared statements):**

[Unverified: The exact syntax for parameterized queries in Supabase SQL Editor may vary. Verify in Supabase documentation.]

**Query templates:** Supabase provides templates for common operations:

- Create table with RLS
- Create foreign key relationship
- Create storage bucket
- Enable realtime
- Create function

**Best practices:**

- Save frequently used queries for reuse
- Use transactions for multiple related operations
- Test destructive operations with `SELECT` before `UPDATE` or `DELETE`
- Use `LIMIT` when exploring large tables
- Comment complex queries for future reference
- Use proper formatting for readability

**Example workflow:**

```sql
-- 1. Check existing data
SELECT COUNT(*) FROM users;

-- 2. Begin transaction
BEGIN;

-- 3. Make changes
DELETE FROM posts WHERE status = 'draft' AND created_at < NOW() - INTERVAL '30 days';

-- 4. Verify changes
SELECT COUNT(*) FROM posts WHERE status = 'draft';

-- 5. Commit or rollback
COMMIT;
-- Or if something's wrong:
-- ROLLBACK;
```

