## Anonymous Users


Temporary users created without credentials, allowing interaction with the application before requiring registration. Anonymous sessions can later be converted to permanent accounts.

**Key points:**

- Creates user with UUID but no identifying information
- Useful for guest experiences or trials
- Can be converted to permanent user by adding email/password or OAuth
- Anonymous users have same RLS capabilities as authenticated users
- Session expires according to standard token lifetime
- Converting preserves user data and ID

**Example:** Creating anonymous user

```javascript
const { data, error } = await supabase.auth.signInAnonymously()
```

**Example:** Converting to permanent user

```javascript
// User must be signed in as anonymous user first
const { data, error } = await supabase.auth.updateUser({
  email: 'user@example.com',
  password: 'newPassword123'
})
```

[Inference: The conversion process likely maintains the same user ID to preserve associated data, though specific implementation details may vary.]

