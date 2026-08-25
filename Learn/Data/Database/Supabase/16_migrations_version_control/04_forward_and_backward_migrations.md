## Forward and Backward Migrations


Forward migrations apply schema changes, while backward migrations (rollbacks) reverse them. Designing reversible migrations enables safe rollback when issues arise.

**Forward migration patterns:**

Forward migrations should be idempotent when possible, allowing safe re-application. Use conditional checks:

```sql
-- Safe to run multiple times
CREATE TABLE IF NOT EXISTS products (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL
);

-- Add column only if it doesn't exist
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'users' AND column_name = 'phone'
  ) THEN
    ALTER TABLE users ADD COLUMN phone TEXT;
  END IF;
END $$;
```

**Reversible operations:**

Some operations are naturally reversible:

- `CREATE TABLE` ↔ `DROP TABLE`
- `ADD COLUMN` ↔ `DROP COLUMN`
- `CREATE INDEX` ↔ `DROP INDEX`
- `ALTER TABLE ADD CONSTRAINT` ↔ `ALTER TABLE DROP CONSTRAINT`

**Irreversible operations:**

Certain operations cannot be safely reversed:

- `DROP COLUMN` (data loss)
- `DROP TABLE` (data loss)
- Data type changes that truncate values
- Constraint additions that reject existing data

**Creating rollback migrations:**

Create explicit rollback migrations for changes requiring reversal:

```sql
-- Forward migration: 20241004120000_add_user_roles.sql
CREATE TYPE user_role AS ENUM ('user', 'admin');
ALTER TABLE users ADD COLUMN role user_role DEFAULT 'user';

-- Rollback migration: 20241004120001_rollback_user_roles.sql
ALTER TABLE users DROP COLUMN role;
DROP TYPE user_role;
```

**Backward-compatible changes:**

Design migrations that don't break existing application code:

```sql
-- Bad: Breaking change - renames column immediately
ALTER TABLE users RENAME COLUMN email TO email_address;

-- Good: Backward-compatible approach
-- Step 1: Add new column
ALTER TABLE users ADD COLUMN email_address TEXT;

-- Step 2: Backfill data
UPDATE users SET email_address = email;

-- Step 3: In later migration (after application updated), remove old column
-- ALTER TABLE users DROP COLUMN email;
```

**Safe column removal:**

Before removing columns, ensure no application code references them:

```sql
-- Migration 1: Mark column as deprecated (add comment)
COMMENT ON COLUMN users.legacy_field IS 'DEPRECATED: Remove after 2024-12-01';

-- Migration 2: After confirming no usage, remove column
ALTER TABLE users DROP COLUMN legacy_field;
```

**Constraint modifications:**

Add constraints with consideration for existing data:

```sql
-- May fail if existing data violates constraint
-- ALTER TABLE products ADD CONSTRAINT price_positive CHECK (price > 0);

-- Safe approach: Add constraint as NOT VALID, then validate
ALTER TABLE products ADD CONSTRAINT price_positive CHECK (price > 0) NOT VALID;

-- Clean up invalid data first
UPDATE products SET price = 0.01 WHERE price <= 0;

-- Now validate the constraint
ALTER TABLE products VALIDATE CONSTRAINT price_positive;
```

**Function versioning:**

When modifying functions, create new versions rather than replacing:

```sql
-- Forward migration
CREATE OR REPLACE FUNCTION calculate_total_v2(order_id UUID)
RETURNS DECIMAL AS $$
  -- New implementation
$$ LANGUAGE sql;

-- Backward migration
CREATE OR REPLACE FUNCTION calculate_total_v2(order_id UUID)
RETURNS DECIMAL AS $$
  -- Revert to previous implementation
$$ LANGUAGE sql;
```

**Testing rollbacks:**

Test rollback procedures in development environments:

```bash
# Apply migration
supabase db reset

# Verify schema
supabase db diff

# Apply rollback migration
supabase migration new rollback_feature_x

# Verify rollback worked correctly
supabase db diff
```

