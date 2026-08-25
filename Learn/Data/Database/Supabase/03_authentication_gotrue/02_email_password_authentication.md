## Email/Password Authentication


Traditional email and password authentication where users register with an email address and password. Passwords are hashed using bcrypt before storage.

**Key points:**

- Passwords must meet configurable strength requirements
- Email confirmation can be required or optional
- Password hashing uses bcrypt with configurable cost factor
- Users stored in `auth.users` table with encrypted password
- Sign-up creates user record and optionally sends confirmation email

**Example:** Basic sign-up flow

```javascript
const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'securePassword123',
  options: {
    data: {
      first_name: 'John',
      age: 27
    }
  }
})
```

**Example:** Sign-in flow

```javascript
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'user@example.com',
  password: 'securePassword123'
})
```

After successful authentication, the session is automatically managed by the Supabase client, and the access token is included in subsequent database queries.

