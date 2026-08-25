## Creating and Managing Tables


Tables store structured data in rows and columns. In Supabase, tables can be created through the Table Editor GUI or SQL Editor.

**Creating tables via SQL:**

```sql
CREATE TABLE users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

**Creating tables via Table Editor:** Navigate to Table Editor → New Table, then define columns, data types, and constraints through the interface. The GUI generates the SQL automatically.

**Managing tables:**

```sql
-- Rename table
ALTER TABLE users RENAME TO profiles;

-- Add column
ALTER TABLE users ADD COLUMN phone TEXT;

-- Modify column
ALTER TABLE users ALTER COLUMN email TYPE VARCHAR(255);

-- Drop column
ALTER TABLE users DROP COLUMN phone;

-- Drop table
DROP TABLE users;

-- Drop table if exists (safer)
DROP TABLE IF EXISTS users CASCADE;
```

Supabase automatically creates a `public` schema for user tables. Tables in this schema can be exposed through the auto-generated API if RLS policies allow.

