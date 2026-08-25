## Debugging RLS Issues


When queries return unexpected results or access is denied when it should be granted, systematic debugging reveals policy problems.

Enable detailed PostgreSQL logging:

```sql
SET client_min_messages TO DEBUG;
```

Check if RLS is enabled:

```sql
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public';
```

View all policies on a table:

```sql
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE tablename = 'your_table_name';
```

Test policy conditions directly:

```sql
-- Simulate user context
SELECT set_config('request.jwt.claims', '{"sub":"user-uuid"}', true);

-- Check what auth.uid() returns
SELECT auth.uid();

-- Test policy condition manually
SELECT * FROM your_table 
WHERE (your_policy_condition);
```

Check for policy conflicts (multiple policies where none match):

```sql
-- List all policies for a table
SELECT policyname, cmd, qual
FROM pg_policies
WHERE tablename = 'documents';
```

Common debugging scenarios:

**Policy returns no rows when it should:**

- Verify `auth.uid()` returns expected UUID
- Check if user_id column matches exactly (data type, null values)
- Ensure RLS is enabled on the table
- Verify the role (anon vs authenticated) matches policy target

**Policy allows unauthorized access:**

- Review `OR` conditions that may be too permissive
- Check for missing `auth.uid() IS NOT NULL` checks
- Verify subqueries don't return unexpected results

**INSERT/UPDATE fails unexpectedly:**

- Check `WITH CHECK` clause separately from `USING` clause
- Verify computed values satisfy the `WITH CHECK` condition
- Test if default column values violate policies

Supabase Dashboard provides a SQL editor where you can execute these debugging queries directly against your database.

