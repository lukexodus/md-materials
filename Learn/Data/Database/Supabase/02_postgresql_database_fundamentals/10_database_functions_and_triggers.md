## Database Functions and Triggers


Functions encapsulate reusable SQL logic, while triggers automatically execute functions in response to database events.

### Database Functions

Functions are stored procedures written in PL/pgSQL or other supported languages.

**Basic function:**

```sql
-- Function to calculate user age
CREATE OR REPLACE FUNCTION calculate_age(birth_date DATE)
RETURNS INTEGER AS $$
BEGIN
  RETURN EXTRACT(YEAR FROM AGE(birth_date));
END;
$$ LANGUAGE plpgsql;

-- Usage
SELECT calculate_age('1990-01-01');
```

**Function with table query:**

```sql
-- Function to get user post count
CREATE OR REPLACE FUNCTION get_post_count(user_uuid UUID)
RETURNS INTEGER AS $$
DECLARE
  post_count INTEGER;
BEGIN
  SELECT COUNT(*) INTO post_count
  FROM posts
  WHERE author_id = user_uuid AND deleted_at IS NULL;
  
  RETURN post_count;
END;
$$ LANGUAGE plpgsql;

-- Usage
SELECT get_post_count('uuid-here');
```

**Function returning table:**

```sql
-- Function to get popular posts
CREATE OR REPLACE FUNCTION get_popular_posts(min_likes INTEGER DEFAULT 10)
RETURNS TABLE (
  post_id UUID,
  title TEXT,
  like_count BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    p.id,
    p.title,
    COUNT(l.id) as like_count
  FROM posts p
  LEFT JOIN likes l ON p.id = l.post_id
  GROUP BY p.id, p.title
  HAVING COUNT(l.id) >= min_likes
  ORDER BY like_count DESC;
END;
$$ LANGUAGE plpgsql;

-- Usage
SELECT * FROM get_popular_posts(20);
```

**Function with security definer:**

```sql
-- Function that bypasses RLS (runs with creator's permissions)
CREATE OR REPLACE FUNCTION admin_delete_user(user_uuid UUID)
RETURNS VOID
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  DELETE FROM users WHERE id = user_uuid;
END;
$$ LANGUAGE plpgsql;
```

### Triggers

Triggers automatically execute functions when specific database events occur.

**Trigger timing:**

- `BEFORE` - runs before the operation
- `AFTER` - runs after the operation
- `INSTEAD OF` - replaces the operation (for views)

**Trigger events:**

- `INSERT`, `UPDATE`, `DELETE`, `TRUNCATE`

**Example: Update timestamp on modification**

```sql
-- Function to update timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger on posts table
CREATE TRIGGER update_posts_updated_at
  BEFORE UPDATE ON posts
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

**Example: Audit log**

```sql
-- Audit table
CREATE TABLE audit_log (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  table_name TEXT NOT NULL,
  operation TEXT NOT NULL,
  old_data JSONB,
  new_data JSONB,
  user_id UUID,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Audit function
CREATE OR REPLACE FUNCTION audit_changes()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO audit_log (table_name, operation, old_data, new_data, user_id)
  VALUES (
    TG_TABLE_NAME,
    TG_OP,
    CASE WHEN TG_OP = 'DELETE' THEN row_to_json(OLD) ELSE NULL END,
    CASE WHEN TG_OP IN ('INSERT', 'UPDATE') THEN row_to_json(NEW) ELSE NULL END,
    auth.uid()  -- Supabase auth user ID
  );
  
  RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Apply trigger to posts table
CREATE TRIGGER posts_audit
  AFTER INSERT OR UPDATE OR DELETE ON posts
  FOR EACH ROW
  EXECUTE FUNCTION audit_changes();
```

**Example: Cascade soft delete**

```sql
-- Soft delete posts when user is soft deleted
CREATE OR REPLACE FUNCTION cascade_soft_delete()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL THEN
    UPDATE posts
    SET deleted_at = NEW.deleted_at
    WHERE author_id = NEW.id AND deleted_at IS NULL;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER soft_delete_user_posts
  AFTER UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION cascade_soft_delete();
```

**Example: Validate data before insert**

```sql
-- Ensure username is lowercase
CREATE OR REPLACE FUNCTION lowercase_username()
RETURNS TRIGGER AS $$
BEGIN
  NEW.username = LOWER(NEW.username);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER ensure_lowercase_username
  BEFORE INSERT OR UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION lowercase_username();
```

**Example: Prevent updates on certain conditions**

```sql
-- Prevent editing published posts after 24 hours
CREATE OR REPLACE FUNCTION prevent_old_post_edits()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.status = 'published' 
     AND OLD.published_at < NOW() - INTERVAL '24 hours' THEN
    RAISE EXCEPTION 'Cannot edit posts published more than 24 hours ago';
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_post_edit_time
  BEFORE UPDATE ON posts
  FOR EACH ROW
  EXECUTE FUNCTION prevent_old_post_edits();
```

**Managing triggers:**

```sql
-- Disable trigger
ALTER TABLE posts DISABLE TRIGGER update_posts_updated_at;

-- Enable trigger
ALTER TABLE posts ENABLE TRIGGER update_posts_updated_at;

-- Drop trigger
DROP TRIGGER IF EXISTS update_posts_updated_at ON posts;

-- List all triggers
SELECT trigger_name, event_object_table, action_statement
FROM information_schema.triggers
WHERE trigger_schema = 'public';
```

**Best practices:**

- Keep trigger logic simple and fast (they run on every operation)
- Use `BEFORE` triggers for validation and data transformation
- Use `AFTER` triggers for logging and cascading actions
- Avoid triggers that modify the same table (can cause infinite loops)
- Consider using constraints instead of triggers when possible
- Document trigger behavior thoroughly
- Test triggers carefully with edge cases

**Key points:**

- PostgreSQL in Supabase provides enterprise-grade features with developer-friendly tooling
- Proper indexing and relationship design are critical for performance at scale
- Row Level Security (RLS) policies work alongside database constraints for security
- Migrations enable version-controlled, reproducible schema changes
- Views simplify complex queries; materialized views cache expensive computations
- Functions and triggers enable sophisticated business logic at the database layer
- The SQL Editor provides immediate access for development and debugging
- Understanding data types, constraints, and relationships forms the foundation for reliable applications

---

