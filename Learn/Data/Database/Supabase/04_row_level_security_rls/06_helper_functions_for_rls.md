## Helper Functions for RLS


Supabase provides helper functions that access the authenticated user's JWT context within policy expressions.

`auth.uid()` returns the current user's UUID from their JWT token:

```sql
USING (user_id = auth.uid())
```

Returns `NULL` for unauthenticated requests, which can be used to differentiate access:

```sql
USING (
  visibility = 'public' 
  OR (auth.uid() IS NOT NULL AND user_id = auth.uid())
)
```

`auth.jwt()` returns the complete JWT payload as JSON, allowing access to custom claims:

```sql
USING (auth.jwt()->>'email' LIKE '%@company.com')
USING (auth.jwt()->>'role' = 'admin')
USING ((auth.jwt()->>'app_metadata')::json->>'subscription' = 'premium')
```

Custom JWT claims must be set during authentication or through user metadata updates:

```sql
USING (
  auth.jwt()->>'user_role' = 'moderator'
  OR auth.jwt()->>'user_role' = 'admin'
)
```

