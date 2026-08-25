## Database Migrations


Migrations are version-controlled database schema changes that allow teams to track and apply database modifications systematically.

**Migration workflow in Supabase:**

Supabase CLI manages migrations through SQL files stored in `supabase/migrations/` directory. Each migration file has a timestamp prefix ensuring ordered execution.

**Setting up migrations:**

```bash
# Initialize Supabase in project
supabase init

# Create new migration
supabase migration new create_users_table

# This creates: supabase/migrations/20240101000000_create_users_table.sql
```

**Writing migrations:**

```sql
-- supabase/migrations/20240101000000_create_users_table.sql
CREATE TABLE users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Create policy
CREATE POLICY "Users can view own data"
  ON users FOR SELECT
  USING (auth.uid() = id);
```

**Applying migrations:**

```bash
# Apply migrations locally
supabase db reset

# Apply to remote database
supabase db push

# Generate migration from remote changes
supabase db pull
```

**Migration best practices:**

- Make migrations idempotent using `IF NOT EXISTS` and `IF EXISTS`
- Never modify existing migration files after they're applied
- Create new migrations for schema changes
- Test migrations locally before deploying
- Include both schema changes and data migrations in same file if needed
- Use transactions for complex migrations
- Add meaningful comments explaining changes

**Example migration with rollback:**

```sql
-- Migration: Add user profiles
BEGIN;

CREATE TABLE profiles (
  id UUID REFERENCES users(id) PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  bio TEXT,
  avatar_url TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_profiles_username ON profiles(username);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Profiles are viewable by everyone"
  ON profiles FOR SELECT
  USING (true);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

COMMIT;
```

**Data migrations:**

```sql
-- Migrate existing data to new structure
UPDATE posts
SET author_name = (SELECT full_name FROM users WHERE users.id = posts.author_id)
WHERE author_name IS NULL;
```

