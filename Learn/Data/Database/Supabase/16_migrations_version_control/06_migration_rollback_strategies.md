## Migration Rollback Strategies


Rollback strategies enable recovery when migrations cause issues in production. Planning rollback approaches before deploying migrations reduces risk and downtime.

**Immediate rollback approach:**

Create explicit rollback migrations in advance:

```bash
# Create forward migration
supabase migration new add_feature_x

# Immediately create rollback migration
supabase migration new rollback_feature_x
```

Write rollback SQL that reverses the forward migration completely:

```sql
-- Forward: 20241004120000_add_feature_x.sql
CREATE TABLE feature_data (...);
ALTER TABLE users ADD COLUMN feature_flag BOOLEAN DEFAULT false;

-- Rollback: 20241004120001_rollback_feature_x.sql
ALTER TABLE users DROP COLUMN feature_flag;
DROP TABLE feature_data;
```

**Database backups before migrations:**

Always create database backups before applying migrations to production:

```bash
# Backup production database
pg_dump -h your-db-host -U postgres -d your_database > backup_pre_migration.sql

# Apply migration
supabase db push

# If problems occur, restore backup
psql -h your-db-host -U postgres -d your_database < backup_pre_migration.sql
```

**Point-in-time recovery:**

[Unverified] Supabase projects may support point-in-time recovery, allowing database restoration to any moment before a problematic migration. Check your project's backup settings and retention periods.

**Gradual rollout strategy:**

Apply migrations to subsets of data first:

```sql
-- Phase 1: Apply to 10% of users
UPDATE users
SET new_feature_enabled = true
WHERE id IN (
  SELECT id FROM users 
  WHERE MOD(HASHTEXT(id::TEXT), 10) = 0
);

-- Monitor for issues before proceeding

-- Phase 2: Apply to remaining users
UPDATE users
SET new_feature_enabled = true
WHERE new_feature_enabled = false;
```

**Feature flags in migrations:**

Include feature flags in schema changes, allowing application-level rollback without database changes:

```sql
ALTER TABLE users ADD COLUMN use_new_system BOOLEAN DEFAULT false;

-- Application can toggle behavior without migration rollback
-- If issues occur, disable at application level
```

**Two-phase rollback:**

For complex migrations, implement rollback in phases:

```sql
-- Phase 1: Disable new functionality
ALTER TABLE products DISABLE TRIGGER new_feature_trigger;

-- Phase 2: After confirming stability, remove completely
DROP TRIGGER new_feature_trigger ON products;
ALTER TABLE products DROP COLUMN new_feature_data;
```

**Rollback testing:**

Test rollback procedures in staging environments:

```bash
# Staging environment
supabase link --project-ref staging-project

# Apply migration
supabase migration new test_feature
supabase db push

# Test application with migration

# Apply rollback
supabase migration new rollback_test_feature
supabase db push

# Verify application still functions
```

**Documentation for rollback procedures:**

Document rollback steps in migration files:

```sql
/*
ROLLBACK PROCEDURE:
1. Apply rollback migration: 20241004120001_rollback_user_preferences.sql
2. Restart application servers to clear caches
3. Verify users.preferences column removed
4. Monitor error logs for 30 minutes

ROLLBACK RISK: Medium
- No data loss (column is nullable)
- Application gracefully handles missing column

RECOVERY TIME: ~5 minutes
*/

ALTER TABLE users DROP COLUMN preferences;
```

**Partial rollback strategies:**

Sometimes full rollback isn't necessary. Remove only problematic portions:

```sql
-- Forward migration added multiple elements
CREATE TABLE new_feature (...);
ALTER TABLE users ADD COLUMN feature_flag BOOLEAN;
CREATE INDEX idx_user_feature ON users(feature_flag);

-- Partial rollback: Keep table but remove index if causing performance issues
DROP INDEX idx_user_feature;
```

**Monitoring-driven rollback:**

Establish monitoring thresholds that trigger rollback:

- Error rate increases above baseline
- Query performance degrades beyond acceptable limits
- Application metrics show user impact

Automate rollback triggers based on these metrics in your deployment pipeline.

