## Schema Versioning


Schema versioning tracks the state of your database structure over time. Supabase maintains a migration history table that records which migrations have been applied.

**Migration history tracking:**

Supabase stores applied migrations in the `supabase_migrations.schema_migrations` table. Each row contains the migration version (timestamp), name, and execution details. This table enables the system to determine which migrations need to be applied.

**Version numbering:**

Migrations use timestamp-based versioning: `YYYYMMDDHHMMSS`. This format ensures chronological ordering and prevents version conflicts when multiple developers create migrations simultaneously. The timestamp reflects when the migration file was created, not when it was applied.

**Viewing migration status:**

Check which migrations have been applied locally:

```bash
supabase migration list
```

This displays migration files and their application status. Applied migrations show with indicators, while pending migrations appear unmarked.

**Local vs. remote version synchronization:**

Local and remote databases may have different migration states. Before pushing migrations to production, verify the remote database's current state:

```bash
supabase db pull
```

This fetches the remote schema and identifies differences between local migrations and the remote database state.

**Handling version conflicts:**

When multiple developers create migrations simultaneously, timestamp conflicts rarely occur but can happen. If two migrations have identical timestamps, rename one migration file with a later timestamp:

```bash
mv supabase/migrations/20241004120000_add_field.sql \
   supabase/migrations/20241004120001_add_field.sql
```

**Version control integration:**

Commit migration files to Git immediately after creation. Include both the migration file and any related code changes in the same commit or pull request, ensuring database and application code remain synchronized.

**Baseline migrations:**

[Inference] For existing databases, create a baseline migration capturing the current schema state. This migration serves as the starting point for future changes:

```sql
-- Baseline migration: existing schema as of 2024-10-04
-- Generated from existing database structure

CREATE TABLE users (...);
CREATE TABLE products (...);
-- ... existing schema
```

**Schema drift detection:**

Schema drift occurs when manual changes are made directly to databases bypassing migrations. Detect drift by comparing the migration-generated schema with the actual database schema:

```bash
supabase db diff
```

This identifies tables, columns, or constraints present in the database but not defined in migrations, or vice versa.

**Migration squashing:**

[Inference] Long-running projects accumulate many migrations. Consider periodically squashing old migrations into a single baseline migration. This reduces the number of files and speeds up database recreation, though it loses granular history.

**Semantic versioning for major changes:**

While migrations use timestamp versioning, document major schema overhauls in release notes. Associate migration sets with application version numbers to track which migrations correspond to which application releases.

