## Email Confirmation Flows


Process to verify user email addresses during registration. Ensures users have access to the email address they provided.

**Key points:**

- Confirmation can be required or optional (configurable in dashboard)
- Unconfirmed users cannot sign in if confirmation required
- Confirmation link contains time-limited token
- Tokens single-use and invalidated after confirmation
- Custom redirect URLs supported
- Confirmation can be resent if expired or not received
- Email templates customizable

**Example:** Sign-up with email confirmation

```javascript
const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'password123',
  options: {
    emailRedirectTo: 'https://yourapp.com/welcome'
  }
})

// User receives email with confirmation link
// After clicking link, they are redirected to specified URL
```

**Example:** Resending confirmation email

```javascript
const { data, error } = await supabase.auth.resend({
  type: 'signup',
  email: 'user@example.com',
  options: {
    emailRedirectTo: 'https://yourapp.com/welcome'
  }
})
```

When confirmation is required, the user record is created but `email_confirmed_at` field is null until confirmation. After clicking the link, the field is populated and the user can sign in.

