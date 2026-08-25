## User Roles and Permissions


PostgreSQL roles define the database identity executing queries. Supabase uses specific roles for different contexts:

- `anon` - Unauthenticated users (public access)
- `authenticated` - Any logged-in user
- `service_role` - Server-side operations with bypass capabilities

Policies target specific roles using the `TO` clause:

```sql
CREATE POLICY "Public profiles are viewable by everyone"
ON profiles
FOR SELECT
TO anon, authenticated
USING (is_public = true);
```

```sql
CREATE POLICY "Users can update own profile"
ON profiles
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id);
```

**[Inference]** The `service_role` bypasses RLS entirely and should only be used in trusted server environments, never exposed to client applications.

