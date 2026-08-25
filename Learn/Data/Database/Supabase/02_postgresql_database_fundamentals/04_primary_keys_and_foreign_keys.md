## Primary Keys and Foreign Keys


**Primary keys** uniquely identify each row in a table. Every table should have a primary key.

```sql
-- UUID primary key (recommended in Supabase)
CREATE TABLE posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL
);

-- Auto-incrementing integer primary key
CREATE TABLE categories (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL
);

-- Composite primary key (multiple columns)
CREATE TABLE order_items (
  order_id UUID,
  product_id UUID,
  quantity INTEGER,
  PRIMARY KEY (order_id, product_id)
);
```

Supabase recommends using UUID primary keys because they're globally unique, work well in distributed systems, prevent enumeration attacks, and can be generated client-side.

**Foreign keys** establish relationships between tables by referencing primary keys in other tables.

```sql
CREATE TABLE posts (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  title TEXT NOT NULL,
  author_id UUID REFERENCES users(id),  -- Foreign key to users table
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Foreign key with explicit constraint name and actions
CREATE TABLE comments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  content TEXT NOT NULL,
  post_id UUID NOT NULL,
  user_id UUID NOT NULL,
  CONSTRAINT fk_post
    FOREIGN KEY (post_id)
    REFERENCES posts(id)
    ON DELETE CASCADE,  -- Delete comments when post is deleted
  CONSTRAINT fk_user
    FOREIGN KEY (user_id)
    REFERENCES users(id)
    ON DELETE SET NULL  -- Set to NULL when user is deleted
);
```

**Referential actions:**

- `ON DELETE CASCADE` - delete child rows when parent is deleted
- `ON DELETE SET NULL` - set foreign key to null when parent is deleted
- `ON DELETE RESTRICT` - prevent deletion of parent if children exist (default)
- `ON DELETE NO ACTION` - similar to RESTRICT
- `ON UPDATE CASCADE` - update foreign key when parent key changes

