## Database Migration Strategies


Migration strategies determine how database schema changes are planned, tested, and deployed across environments. Effective strategies balance safety, reversibility, and team coordination.

**Migration-first development:**

Changes to database schema begin as migration files rather than manual SQL execution. This ensures all modifications are tracked, reviewable, and reproducible. Every schema change—whether adding tables, modifying columns, or adjusting constraints—should exist as a migration file committed to version control.

**Incremental vs. comprehensive migrations:**

Incremental migrations apply small, focused changes in sequence. Each migration handles a single logical change (adding one table, modifying one column). This approach simplifies debugging and rollback but creates more migration files over time.

Comprehensive migrations group related changes into single migration files. This reduces the total number of migrations but makes individual changes harder to isolate and reverse.

**Development workflow patterns:**

Create migrations locally using `supabase migration new migration-name`. This generates a timestamped SQL file in `supabase/migrations/`. Write the schema changes, test locally using `supabase db reset` to apply all migrations to a fresh database, then commit the migration file to version control.

**Environment progression:**

Migrations flow through environments: local development → staging → production. Each environment maintains its own migration history table tracking which migrations have been applied. The `supabase db push` command applies pending migrations to remote databases.

**Zero-downtime strategies:**

For production systems requiring continuous availability, implement migrations in phases:

1. **Additive phase**: Add new columns/tables without removing old ones
2. **Dual-write phase**: Application writes to both old and new structures
3. **Migration phase**: Backfill data from old to new structures
4. **Switchover phase**: Application reads from new structures
5. **Cleanup phase**: Remove old structures in subsequent migration

**Example zero-downtime migration:**

```sql
-- Migration 1: Add new column (additive)
ALTER TABLE users ADD COLUMN email_normalized TEXT;

-- Migration 2: Backfill data
UPDATE users SET email_normalized = LOWER(TRIM(email));

-- Migration 3: Add constraint and index
ALTER TABLE users ALTER COLUMN email_normalized SET NOT NULL;
CREATE UNIQUE INDEX idx_users_email_normalized ON users(email_normalized);

-- Migration 4: Remove old column (cleanup, after application updated)
-- ALTER TABLE users DROP COLUMN email;
```

**Testing strategies:**

Test migrations in isolation before deployment. Use `supabase db reset` to rebuild your local database from scratch, verifying migrations apply cleanly. Create seed data to validate schema changes don't break expected data patterns.

**Documentation practices:**

Include comments in migration files explaining the purpose and any special considerations:

```sql
-- Migration: Add user preferences table
-- Purpose: Store user-specific settings separate from core user data
-- Dependencies: Requires users table
-- Rollback notes: Safe to rollback if no preferences data exists

CREATE TABLE user_preferences (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  theme TEXT DEFAULT 'light',
  notifications_enabled BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Coordination strategies:**

For teams, establish migration ownership. Assign one developer to create and test each migration. Use pull request reviews specifically focused on migration correctness, ensuring reviewers verify both forward and backward compatibility.

