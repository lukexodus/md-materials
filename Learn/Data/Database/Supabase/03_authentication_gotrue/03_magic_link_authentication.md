## Magic Link Authentication


Passwordless authentication where users receive a one-time login link via email. Clicking the link authenticates the user without requiring a password.

**Key points:**

- No password storage required
- Links are single-use and time-limited (default 1 hour)
- Token embedded in link validates the authentication request
- Reduces security risks associated with password management
- Requires email provider configuration

**Example:** Sending magic link

```javascript
const { data, error } = await supabase.auth.signInWithOtp({
  email: 'user@example.com',
  options: {
    emailRedirectTo: 'https://yourapp.com/welcome'
  }
})
```

The user clicks the link in their email, which contains a token. GoTrue validates the token and creates a session. The user is redirected to the specified URL with the session established.

