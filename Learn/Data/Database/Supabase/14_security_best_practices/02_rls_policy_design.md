## RLS Policy Design


Row Level Security policies enforce authorization at the database level, ensuring users can only access data they're permitted to see regardless of how they connect to the database.

**Enabling RLS:**

```sql
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
```

Without policies defined, enabling RLS blocks all access. You must explicitly create policies granting permissions.

**Policy structure:**

Policies consist of:

- **Operation**: SELECT, INSERT, UPDATE, DELETE, or ALL
- **Role**: Which database role the policy applies to (typically `authenticated` or `anon`)
- **USING clause**: Boolean expression determining which rows are visible (for SELECT/UPDATE/DELETE)
- **WITH CHECK clause**: Boolean expression validating new/modified rows (for INSERT/UPDATE)

**Basic ownership pattern:**

```sql
CREATE POLICY "Users can view own data"
ON profiles FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can update own data"
ON profiles FOR UPDATE
TO authenticated
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);
```

**Public read, authenticated write:**

```sql
CREATE POLICY "Anyone can read posts"
ON posts FOR SELECT
TO anon, authenticated
USING (true);

CREATE POLICY "Authenticated users can insert posts"
ON posts FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = author_id);
```

**Role-based access:**

```sql
CREATE POLICY "Admins can do everything"
ON sensitive_data FOR ALL
TO authenticated
USING (
  EXISTS (
    SELECT 1 FROM user_roles
    WHERE user_roles.user_id = auth.uid()
    AND user_roles.role = 'admin'
  )
);
```

**Multi-tenancy pattern:**

```sql
CREATE POLICY "Users see only their organization's data"
ON documents FOR SELECT
TO authenticated
USING (
  organization_id IN (
    SELECT organization_id FROM user_organizations
    WHERE user_id = auth.uid()
  )
);
```

**Time-based access:**

```sql
CREATE POLICY "View published posts only"
ON posts FOR SELECT
TO anon, authenticated
USING (
  status = 'published'
  AND published_at <= NOW()
);
```

**Design principles:**

- **Deny by default**: Enable RLS on all tables and explicitly grant permissions
- **Test thoroughly**: RLS policies can be complex; test with different user roles and scenarios
- **Avoid performance bottlenecks**: Complex subqueries in policies can slow down queries; consider denormalizing data or using indexed columns
- **Use consistent patterns**: Apply similar policy structures across related tables
- **Document policies**: Add comments explaining business logic behind complex policies
- **Separate concerns**: Create distinct policies for each operation rather than using ALL when possible

**Helper functions:**

Create reusable functions for common checks:

```sql
CREATE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM user_roles
    WHERE user_id = auth.uid() AND role = 'admin'
  );
$$ LANGUAGE SQL STABLE SECURITY DEFINER;

CREATE POLICY "Admins manage users"
ON users FOR ALL
TO authenticated
USING (is_admin());
```

**Common pitfalls:**

- Forgetting to enable RLS on new tables
- Using USING clause when WITH CHECK is needed (allows reading data but prevents modifying it appropriately)
- Creating overly complex policies that degrade performance
- Not testing policies with actual user sessions
- Assuming policies cascade to related tables (each table needs its own policies)

