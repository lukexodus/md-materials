## Branching and Preview Environments


Branching strategies and preview environments enable parallel development of database changes while maintaining stability in shared environments.

**Git branching strategies:**

**Feature branch workflow:**

```bash
# Create feature branch
git checkout -b feature/add-notifications-system

# Create migration
supabase migration new create_notifications_table

# Develop and test locally
supabase db reset

# Commit migration
git add supabase/migrations/
git commit -m "Add notifications system migration"

# Push and create PR
git push origin feature/add-notifications-system
```

**Long-running branches:**

For features requiring multiple migrations over time:

```bash
# Create long-lived feature branch
git checkout -b feature/multi-tenant-support

# Create migrations incrementally
supabase migration new add_tenant_id_column
# ... develop ...
supabase migration new migrate_tenant_data
# ... develop ...
supabase migration new add_tenant_constraints

# Periodically merge main into feature branch
git merge main

# Final merge when complete
```

**Migration conflicts resolution:**

When rebasing or merging branches with migrations:

```bash
# Rebase feature branch onto main
git rebase main

# If migration timestamps conflict, rename
mv supabase/migrations/20241004120000_my_migration.sql \
   supabase/migrations/20241004130000_my_migration.sql

# Update application code if needed
git add .
git rebase --continue
```

**Preview environments:**

[Unverified] Supabase may support creating preview databases for pull requests, allowing each feature branch to have its own database instance.

**Manual preview environment setup:**

Create separate Supabase projects for preview environments:

```bash
# Link to preview project
supabase link --project-ref preview-project-ref

# Apply migrations to preview
supabase db push

# Test application against preview database
SUPABASE_URL=https://preview-project.supabase.co npm run dev
```

**Seeding preview environments:**

Create seed scripts for preview databases:

```sql
-- supabase/seed.sql
INSERT INTO users (id, email, name) VALUES
  ('11111111-1111-1111-1111-111111111111', 'test@example.com', 'Test User'),
  ('22222222-2222-2222-2222-222222222222', 'admin@example.com', 'Admin User');

INSERT INTO products (name, price) VALUES
  ('Test Product 1', 99.99),
  ('Test Product 2', 49.99);
```

Apply seeds to preview:

```bash
supabase db reset  # Applies migrations and seeds
```

**Environment-specific migrations:**

[Inference] Avoid creating environment-specific migrations. Instead, use configuration or feature flags to handle environment differences. All environments should use identical migration sets.

**Parallel development isolation:**

Each developer maintains their own local database:

```bash
# Developer 1 - local development
supabase start  # Starts local Supabase
supabase db reset  # Applies all migrations

# Developer 2 - separate local instance
supabase start  # Independent local database
supabase db reset  # Same migrations, different data
```

**Preview database lifecycle:**

Establish lifecycle policies for preview environments:

- Create preview database when PR is opened
- Apply branch's migrations automatically
- Destroy preview database when PR is merged/closed
- Limit preview database retention to 7-14 days

**Continuous integration with migrations:**

Configure CI/CD pipelines to test migrations:

```yaml
# .github/workflows/test-migrations.yml
name: Test Migrations

on: [pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Supabase CLI
        uses: supabase/setup-cli@v1
      
      - name: Start Supabase
        run: supabase start
      
      - name: Run migrations
        run: supabase db reset
      
      - name: Verify schema
        run: supabase db diff --schema public
      
      - name: Run tests
        run: npm test
```

**Schema comparison across branches:**

Compare schema between branches before merging:

```bash
# Check out main branch
git checkout main
supabase db reset
pg_dump --schema-only > main_schema.sql

# Check out feature branch
git checkout feature/my-feature
supabase db reset
pg_dump --schema-only > feature_schema.sql

# Compare schemas
diff main_schema.sql feature_schema.sql
```

**Branch protection for migrations:**

Configure repository branch protection rules:

- Require migration review approval from database-experienced team members
- Require CI tests to pass before merging
- Prevent direct pushes to main branch
- Require up-to-date branches before merging

**Preview environment URLs:**

When using preview environments, generate predictable URLs for testing:

```
Main: https://main-project.supabase.co
Feature: https://feature-123-preview.supabase.co
PR #45: https://pr-45-preview.supabase.co
```

**Environment synchronization:**

Keep environments synchronized with production schema:

```bash
# Pull production schema to update local
supabase db pull --project-ref production-ref

# Generate migration from differences
supabase db diff --file sync_with_production

# Review and commit sync migration
git add supabase/migrations/
git commit -m "Sync with production schema"
```

**Migration testing in CI/CD:**

```yaml
# .github/workflows/migration-tests.yml
name: Migration Tests

on:
  pull_request:
    paths:
      - 'supabase/migrations/**'

jobs:
  test-migrations:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Supabase
        uses: supabase/setup-cli@v1
      
      - name: Start local Supabase
        run: supabase start
      
      - name: Test forward migrations
        run: supabase db reset
      
      - name: Run integration tests
        run: npm run test:integration
      
      - name: Test migration idempotency
        run: supabase db reset
      
      - name: Validate schema
        run: |
          supabase db diff > schema_diff.txt
          if [ -s schema_diff.txt ]; then
            echo "Schema drift detected"
            cat schema_diff.txt
            exit 1
          fi
```

**Collaborative migration planning:**

Use planning documents for major migrations:

```markdown
# Migration Plan: User Multi-Factor Authentication

## Goal
Add MFA support to user authentication system

## Migration Sequence

### Migration 1: Add MFA tables
- `user_mfa_methods` table
- `user_mfa_backup_codes` table
- Indexes and foreign keys

### Migration 2: Add user MFA preferences
- Add `mfa_enabled` column to users
- Add `mfa_required` column to users
- Default to false for backward compatibility

### Migration 3: Create MFA functions
- `generate_backup_codes()` function
- `verify_mfa_code()` function
- `rotate_mfa_secret()` function

## Timeline
- Week 1: Development and local testing
- Week 2: Staging deployment and testing
- Week 3: Production deployment (off-peak hours)

## Rollback Strategy
Each migration has corresponding rollback migration prepared

## Testing Requirements
- Unit tests for MFA functions
- Integration tests for authentication flow
- Load testing with MFA enabled

## Dependencies
- Application code changes in PR #234
- Updated authentication documentation

## Team Assignments
- Database: @developer1
- Backend: @developer2
- Frontend: @developer3
- QA: @tester1
```

**Preview environment automation:**

[Inference] Automate preview environment creation with scripts:

```bash
#!/bin/bash
# scripts/create-preview-env.sh

PR_NUMBER=$1
BRANCH_NAME=$2

# Create preview project (if using Supabase API)
PREVIEW_REF="pr-${PR_NUMBER}-preview"

echo "Creating preview environment for PR #${PR_NUMBER}"

# Link to preview project
supabase link --project-ref ${PREVIEW_REF}

# Apply migrations
supabase db reset

# Apply seed data
psql $DATABASE_URL < supabase/seed.sql

echo "Preview environment ready at https://${PREVIEW_REF}.supabase.co"
```

**Cross-team migration reviews:**

For migrations affecting multiple teams:

```markdown
## Cross-Team Migration Review

**Migration**: Add analytics events table
**Affected Teams**: Backend, Data Engineering, Analytics

### Backend Team Review
- [ ] Schema design approved
- [ ] Performance impact assessed
- [ ] Integration points identified

### Data Engineering Review
- [ ] ETL pipeline compatibility verified
- [ ] Data warehouse sync requirements noted
- [ ] Partitioning strategy approved

### Analytics Team Review
- [ ] Event schema matches requirements
- [ ] Reporting queries validated
- [ ] Dashboard updates planned
```

**Handling emergency schema fixes:**

Process for urgent production schema fixes:

```bash
# Create hotfix branch from main
git checkout main
git pull
git checkout -b hotfix/fix-critical-constraint

# Create migration
supabase migration new hotfix_remove_invalid_constraint

# Write minimal fix
cat > supabase/migrations/20241004150000_hotfix_remove_invalid_constraint.sql << EOF
-- HOTFIX: Remove invalid constraint causing production errors
-- Ticket: URGENT-123
-- Deployed: 2024-10-04 15:00 UTC

ALTER TABLE orders DROP CONSTRAINT IF EXISTS invalid_status_check;

-- Add correct constraint
ALTER TABLE orders ADD CONSTRAINT valid_status_check 
  CHECK (status IN ('pending', 'processing', 'completed', 'cancelled'));
EOF

# Test locally
supabase db reset

# Fast-track review
git add supabase/migrations/
git commit -m "HOTFIX: Remove invalid constraint"
git push origin hotfix/fix-critical-constraint

# Create PR with URGENT label
# Deploy immediately after approval
```

**Branch cleanup procedures:**

Clean up migrations from abandoned branches:

```bash
# List branches with migrations
git branch --all | grep feature/

# Check if branch is stale
git log feature/old-feature --since="30 days ago"

# If abandoned, document and delete
echo "Branch feature/old-feature abandoned, migrations never deployed" >> MIGRATION_LOG.md
git branch -D feature/old-feature
git push origin --delete feature/old-feature
```

**Environment promotion workflow:**

Promote migrations through environments systematically:

```
Local → Staging → Production

1. Developer creates migration locally
2. PR merged to main
3. Auto-deploy to staging
4. QA testing in staging
5. Scheduled production deployment
6. Post-deployment monitoring
```

**Staging environment parity:**

Maintain staging environment that mirrors production:

```bash
# Periodic staging refresh from production
pg_dump production_db | psql staging_db

# Apply any new migrations
supabase link --project-ref staging-project
supabase db push

# Anonymize sensitive data
psql staging_db << EOF
UPDATE users SET 
  email = 'user_' || id || '@example.com',
  phone = NULL;
UPDATE orders SET customer_notes = 'Test data';
EOF
```

**Documenting deployment procedures:**

Create deployment runbooks for migrations:

```markdown
# Production Migration Deployment - User MFA System

## Pre-Deployment Checklist
- [ ] Staging testing completed successfully
- [ ] Rollback migration prepared and tested
- [ ] Database backup created
- [ ] Team notified of deployment window
- [ ] Monitoring dashboards open

## Deployment Steps

1. **Verify current state** (15:00 UTC)
   ``bash
   supabase migration list --project-ref production
   ``

2. **Create backup** (15:05 UTC)
    
    `bash
    ./scripts/backup-production.sh
    ``
    
3. **Apply migration** (15:10 UTC)
    
    ``bash
    supabase db push --project-ref production
    ``
    
4. **Verify schema** (15:15 UTC)
    
    `bash
    supabase db diff --project-ref production
    `
    
5. **Run validation queries** (15:20 UTC)
    
    ```sql
    SELECT COUNT(*) FROM user_mfa_methods;
    SELECT * FROM users WHERE mfa_enabled = true LIMIT 5;
    ``
    
2. **Deploy application code** (15:25 UTC)
   
    - Deploy backend services
    - Deploy frontend assets
    - Verify health checks
      
3. **Monitor for 30 minutes** (15:30-16:00 UTC)
   
    - Check error rates
    - Monitor query performance
    - Verify user reports

