## Team Collaboration Workflows


Team collaboration on database migrations requires coordination to prevent conflicts and maintain database integrity across multiple developers and environments.

**Migration ownership:**

Assign each migration to a specific developer responsible for creation, testing, and deployment. This person ensures the migration is correct and handles issues during deployment.

**Pull request reviews:**

Require code reviews for all migrations before merging:

- **Schema review**: Verify table structures, relationships, and constraints are correct
- **Performance review**: Check for missing indexes, potentially slow queries
- **Backward compatibility**: Ensure changes don't break existing application code
- **Rollback plan**: Confirm rollback strategy is documented and tested

**Branch naming conventions:**

Use consistent branch naming for migration work:

```
feature/add-user-preferences-table
migration/optimize-product-indexes
hotfix/fix-orders-constraint
```

**Merge order coordination:**

When multiple developers create migrations simultaneously, coordinate merge order to maintain chronological migration sequence:

1. First developer merges migration A (timestamp: 120000)
2. Second developer rebases, ensuring migration B has later timestamp (120001)
3. Second developer merges migration B

**Communication protocols:**

Establish communication channels for migration coordination:

- Announce migration plans before creating them
- Share migration status in team chat during deployment
- Document breaking changes prominently
- Create calendar entries for scheduled production migrations

**Shared development database:**

[Inference] Teams may maintain a shared development database separate from individual local databases. This environment tests migration interactions before staging deployment.

**Migration review checklist:**

```markdown
## Migration Review Checklist

- [ ] Migration file follows naming convention
- [ ] SQL syntax is valid
- [ ] Indexes added for foreign keys and frequent queries
- [ ] RLS policies defined if applicable
- [ ] Backward compatible with current application code
- [ ] Rollback strategy documented
- [ ] Tested locally with `supabase db reset`
- [ ] No hardcoded production values
- [ ] Comments explain complex logic
- [ ] Related application code changes included
```

**Handling migration conflicts:**

When two developers create migrations with conflicting changes:

```bash
# Developer A creates migration adding column 'status'
# Developer B creates migration adding column 'state'

# Resolution:
1. Discuss which change should proceed
2. Developer B updates migration to use agreed-upon column name
3. Update application code accordingly
4. Merge in sequence
```

**Pairing for complex migrations:**

Schedule pair programming sessions for complex migrations involving data transformations or significant schema changes. Two perspectives reduce errors and improve design.

**Migration documentation requirements:**

Maintain a MIGRATIONS.md file documenting major changes:

```markdown
# Migration History

## 2024-10-04: User Preferences System
- **Migration**: `20241004120000_add_user_preferences.sql`
- **Purpose**: Add user customization options
- **Breaking Changes**: None
- **Rollback**: `20241004120001_rollback_user_preferences.sql`
- **Deployment Notes**: Applied to production 2024-10-05 03:00 UTC

## 2024-10-01: Product Search Optimization
- **Migration**: `20241001150000_add_product_search_index.sql`
- **Purpose**: Improve search query performance
- **Performance Impact**: Index creation takes ~2 minutes
- **Deployment Notes**: Deployed during maintenance window
```

**Testing coordination:**

Establish shared testing protocols:

- All migrations must pass in local environment
- Migrations must succeed in staging before production approval
- Integration tests must pass with new schema
- Performance tests verify no degradation

**Emergency migration procedures:**

Define fast-track procedures for critical hotfix migrations:

1. Create migration with clear HOTFIX prefix
2. Expedited review by senior developer
3. Deploy to staging for minimal validation
4. Deploy to production with rollback plan ready
5. Monitor closely for 1 hour post-deployment

