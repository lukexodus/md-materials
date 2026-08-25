## Migration File Creation


Migration files are SQL scripts with timestamps that define schema changes. The Supabase CLI generates these files with proper naming conventions and structure.

**Creating new migrations:**

```bash
supabase migration new create_products_table
```

This generates a file like `supabase/migrations/20241004120000_create_products_table.sql` with a timestamp prefix ensuring chronological ordering.

**File naming conventions:**

Migration names should be descriptive and use snake_case. Names become part of the migration history and help identify changes quickly:

- `create_orders_table.sql`
- `add_email_index_to_users.sql`
- `modify_products_price_precision.sql`
- `create_audit_triggers.sql`

**Basic migration structure:**

```sql
-- Create products table with basic fields
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL,
  stock_quantity INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add indexes for common queries
CREATE INDEX idx_products_name ON products(name);
CREATE INDEX idx_products_created_at ON products(created_at DESC);

-- Enable Row Level Security
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Public read access" ON products
  FOR SELECT USING (true);

CREATE POLICY "Authenticated users can insert" ON products
  FOR INSERT WITH CHECK (auth.role() = 'authenticated');
```

**Multiple table migrations:**

```sql
-- Create related tables in a single migration
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  slug TEXT NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
  name TEXT NOT NULL,
  price DECIMAL(10, 2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_products_category ON products(category_id);
```

**Adding columns to existing tables:**

```sql
-- Add social media fields to users table
ALTER TABLE users ADD COLUMN twitter_handle TEXT;
ALTER TABLE users ADD COLUMN linkedin_url TEXT;
ALTER TABLE users ADD COLUMN github_username TEXT;

-- Add constraints
ALTER TABLE users ADD CONSTRAINT twitter_handle_format 
  CHECK (twitter_handle IS NULL OR twitter_handle ~ '^@?[A-Za-z0-9_]{1,15}$');
```

**Creating indexes:**

```sql
-- Add performance indexes
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX idx_orders_status ON orders(status) WHERE status != 'completed';

-- Composite indexes for common queries
CREATE INDEX idx_orders_user_status ON orders(user_id, status);

-- Full-text search indexes
CREATE INDEX idx_products_search ON products USING GIN (to_tsvector('english', name || ' ' || description));
```

**Creating functions and triggers:**

```sql
-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to tables
CREATE TRIGGER update_products_updated_at
  BEFORE UPDATE ON products
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

**Creating views:**

```sql
-- Create materialized view for reporting
CREATE MATERIALIZED VIEW order_summary AS
SELECT 
  DATE_TRUNC('day', created_at) AS order_date,
  COUNT(*) AS total_orders,
  SUM(total_amount) AS total_revenue,
  AVG(total_amount) AS avg_order_value
FROM orders
WHERE status = 'completed'
GROUP BY DATE_TRUNC('day', created_at);

-- Add index to materialized view
CREATE INDEX idx_order_summary_date ON order_summary(order_date DESC);
```

**Setting up Row Level Security:**

```sql
-- Enable RLS on table
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view published posts" ON posts
  FOR SELECT USING (status = 'published' OR author_id = auth.uid());

CREATE POLICY "Users can insert their own posts" ON posts
  FOR INSERT WITH CHECK (author_id = auth.uid());

CREATE POLICY "Users can update their own posts" ON posts
  FOR UPDATE USING (author_id = auth.uid());

CREATE POLICY "Users can delete their own posts" ON posts
  FOR DELETE USING (author_id = auth.uid());
```

**Creating enum types:**

```sql
-- Create custom enum types
CREATE TYPE order_status AS ENUM ('pending', 'processing', 'shipped', 'delivered', 'cancelled');
CREATE TYPE user_role AS ENUM ('user', 'moderator', 'admin');

-- Use enum in table
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  status order_status DEFAULT 'pending',
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Foreign key relationships:**

```sql
-- Create tables with proper foreign key constraints
CREATE TABLE authors (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL
);

CREATE TABLE books (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id UUID NOT NULL REFERENCES authors(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  isbn TEXT UNIQUE
);

-- Junction table for many-to-many
CREATE TABLE book_categories (
  book_id UUID REFERENCES books(id) ON DELETE CASCADE,
  category_id UUID REFERENCES categories(id) ON DELETE CASCADE,
  PRIMARY KEY (book_id, category_id)
);
```

