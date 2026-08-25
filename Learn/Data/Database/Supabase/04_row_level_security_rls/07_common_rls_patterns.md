## Common RLS Patterns


**User-owned records pattern:**

```sql
CREATE POLICY "users_own_records"
ON documents
USING (user_id = auth.uid());
```

**Public read, authenticated write pattern:**

```sql
CREATE POLICY "public_read"
ON posts
FOR SELECT
TO anon, authenticated
USING (published = true);

CREATE POLICY "authenticated_insert"
ON posts
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = author_id);
```

**Team/organization access pattern:**

```sql
CREATE POLICY "team_member_access"
ON projects
USING (
  team_id IN (
    SELECT team_id FROM team_members
    WHERE user_id = auth.uid()
  )
);
```

**Role-based access pattern:**

```sql
CREATE POLICY "admin_full_access"
ON sensitive_data
USING (auth.jwt()->>'role' = 'admin');

CREATE POLICY "manager_read_access"
ON sensitive_data
FOR SELECT
USING (
  auth.jwt()->>'role' = 'manager'
  OR auth.jwt()->>'role' = 'admin'
);
```

**Shared resource pattern:**

```sql
CREATE POLICY "shared_documents"
ON documents
USING (
  user_id = auth.uid()
  OR id IN (
    SELECT document_id FROM document_shares
    WHERE shared_with_user_id = auth.uid()
  )
);
```

**Time-based access pattern:**

```sql
CREATE POLICY "scheduled_content"
ON posts
FOR SELECT
USING (
  (publish_at IS NULL OR publish_at <= now())
  AND (unpublish_at IS NULL OR unpublish_at > now())
);
```

**Hierarchical access pattern (cascading permissions):**

```sql
CREATE POLICY "folder_access"
ON files
USING (
  folder_id IN (
    WITH RECURSIVE folder_tree AS (
      SELECT id FROM folders WHERE user_id = auth.uid()
      UNION
      SELECT f.id FROM folders f
      INNER JOIN folder_tree ft ON f.parent_id = ft.id
    )
    SELECT id FROM folder_tree
  )
);
```

