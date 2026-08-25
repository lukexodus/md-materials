## Policy Expressions and Conditions


Policy conditions are PostgreSQL expressions that return boolean values. These expressions can reference table columns, function results, subqueries, and JWT claims.

Simple equality checks:

```sql
USING (user_id = auth.uid())
USING (status = 'published')
```

Complex boolean logic:

```sql
USING (
  user_id = auth.uid() 
  OR visibility = 'public'
  OR auth.uid() IN (
    SELECT user_id FROM collaborators WHERE document_id = documents.id
  )
)
```

Time-based conditions:

```sql
USING (published_at <= now() AND (expires_at IS NULL OR expires_at > now()))
```

JSON field checks:

```sql
USING (metadata->>'is_public' = 'true')
```

Subquery patterns for relationships:

```sql
USING (
  EXISTS (
    SELECT 1 FROM team_members
    WHERE team_members.team_id = projects.team_id
    AND team_members.user_id = auth.uid()
  )
)
```

