## Performance Considerations with RLS


RLS policies execute with every query, potentially impacting performance when policies involve complex conditions or subqueries.

**Subquery performance impact:**

Policies with subqueries execute the subquery for every row evaluated:

```sql
-- Potentially slow if team_members table is large
USING (
  team_id IN (
    SELECT team_id FROM team_members WHERE user_id = auth.uid()
  )
)
```

**[Inference]** Optimizing this pattern may involve denormalizing team membership or using more efficient join patterns, though the specific optimization depends on your data structure and query patterns.

**Index requirements:**

RLS policies benefit from indexes on columns referenced in policy conditions:

```sql
-- Policy uses user_id
CREATE INDEX idx_documents_user_id ON documents(user_id);

-- Policy checks foreign key relationships
CREATE INDEX idx_projects_team_id ON projects(team_id);
CREATE INDEX idx_team_members_user_team ON team_members(user_id, team_id);
```

**Function-based policies:**

Extracting complex policy logic into functions can improve maintainability but may impact performance:

```sql
CREATE FUNCTION user_can_access_document(doc_id uuid)
RETURNS boolean AS $$
  SELECT EXISTS (
    SELECT 1 FROM documents d
    LEFT JOIN document_shares ds ON ds.document_id = d.id
    WHERE d.id = doc_id
    AND (d.user_id = auth.uid() OR ds.shared_with_user_id = auth.uid())
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE;

CREATE POLICY "function_based_access"
ON documents
USING (user_can_access_document(id));
```

**[Inference]** The `STABLE` keyword indicates the function result won't change within a single query, potentially allowing PostgreSQL to cache results, though actual caching behavior depends on query planning.

**Policy complexity trade-offs:**

Simpler policies generally perform better:

```sql
-- Simpler, faster
USING (user_id = auth.uid())

-- More complex, slower
USING (
  user_id = auth.uid()
  OR id IN (SELECT resource_id FROM permissions WHERE user_id = auth.uid())
  OR EXISTS (SELECT 1 FROM team_members tm 
             JOIN teams t ON t.id = tm.team_id 
             WHERE tm.user_id = auth.uid() 
             AND t.id = team_id)
)
```

**Monitoring policy performance:**

```sql
EXPLAIN ANALYZE
SELECT * FROM documents WHERE team_id = 'some-team-id';
```

The query plan shows how RLS policies affect query execution and which indexes are used.

**[Unverified]** The specific performance impact of RLS policies varies significantly based on data volume, policy complexity, and database configuration.

---

**Related topics for deeper understanding:** Supabase Auth JWT customization, PostgreSQL query optimization, database indexing strategies, multi-tenancy patterns, security policy testing frameworks.

---

