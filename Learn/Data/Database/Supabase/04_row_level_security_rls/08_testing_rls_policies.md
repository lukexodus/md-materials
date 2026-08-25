## Testing RLS Policies


Testing RLS policies requires verifying that policies correctly grant and deny access under different user contexts.

Manual testing using `set_config`:

```sql
-- Simulate authenticated user
SELECT set_config('request.jwt.claims', '{"sub":"user-uuid-here"}', true);

-- Test query
SELECT * FROM profiles;

-- Reset context
RESET request.jwt.claims;
```

Testing as anonymous user:

```sql
RESET request.jwt.claims;
SELECT * FROM profiles WHERE is_public = true;
```

Testing policy isolation by attempting unauthorized access:

```sql
-- Set user A's context
SELECT set_config('request.jwt.claims', '{"sub":"user-a-uuid"}', true);

-- Attempt to access user B's data (should return empty)
SELECT * FROM profiles WHERE user_id = 'user-b-uuid';
```

Testing with Supabase client (JavaScript):

```javascript
// Test as authenticated user
const { data: userData, error: userError } = await supabase
  .from('profiles')
  .select('*')
  .eq('user_id', user.id);

// Test as anonymous user (sign out first)
await supabase.auth.signOut();
const { data: publicData, error: publicError } = await supabase
  .from('profiles')
  .select('*')
  .eq('is_public', true);
```

**[Unverified]** The specific testing approach and level of test coverage needed depends on your application's security requirements.

