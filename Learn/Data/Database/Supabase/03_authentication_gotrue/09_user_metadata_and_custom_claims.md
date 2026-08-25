## User Metadata and Custom Claims


Additional information stored with user accounts beyond authentication credentials. Metadata is divided into public metadata (accessible to all) and private metadata (only accessible to the user and server).

**Key points:**

- User metadata stored in `raw_user_meta_data` field of `auth.users` table
- App metadata stored in `raw_app_meta_data` (server-controlled only)
- Public metadata included in JWT payload (visible to client)
- Metadata is JSON and can contain nested structures
- Custom claims in JWT used for authorization and RLS policies
- Metadata updated via `updateUser()` method

**Example:** Setting user metadata during sign-up

```javascript
const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'password123',
  options: {
    data: {
      full_name: 'John Doe',
      avatar_url: 'https://example.com/avatar.jpg',
      subscription_tier: 'free'
    }
  }
})
```

**Example:** Updating user metadata

```javascript
const { data, error } = await supabase.auth.updateUser({
  data: {
    full_name: 'Jane Doe',
    preferences: {
      theme: 'dark',
      notifications: true
    }
  }
})
```

**Example:** Accessing metadata in RLS policy

```sql
CREATE POLICY "Users can view own profile"
ON profiles FOR SELECT
USING (auth.uid() = user_id);

CREATE POLICY "Premium users can access feature"
ON premium_content FOR SELECT
USING (
  (auth.jwt() ->> 'user_metadata')::jsonb ->> 'subscription_tier' = 'premium'
);
```

[Note: App metadata must be set server-side through admin API or database functions, not through client SDK]

