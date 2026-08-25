## Writing RLS Policies


Policies define who can perform which operations on which rows. The basic syntax structure is:

```sql
CREATE POLICY policy_name ON table_name
FOR operation
TO role
USING (condition)
WITH CHECK (condition);
```

The `USING` clause determines which existing rows are visible for SELECT, UPDATE, and DELETE operations. The `WITH CHECK` clause determines which rows can be inserted or which new values are allowed during UPDATE operations.

Basic policy allowing users to read their own profile:

```sql
CREATE POLICY "Users can view own profile"
ON profiles
FOR SELECT
USING (auth.uid() = user_id);
```

Policy allowing users to insert their own profile:

```sql
CREATE POLICY "Users can insert own profile"
ON profiles
FOR INSERT
WITH CHECK (auth.uid() = user_id);
```

Policy allowing users to update their own profile:

```sql
CREATE POLICY "Users can update own profile"
ON profiles
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);
```

