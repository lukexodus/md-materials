## Password Reset Flows


Process for users to recover access when they forget their password. Involves sending a secure reset link via email and allowing password change.

**Key points:**

- Reset link contains time-limited token (default 1 hour)
- Tokens are single-use and invalidated after password change
- Reset request does not confirm if email exists (prevents enumeration)
- Custom redirect URLs can be specified for reset completion
- Email templates customizable in Supabase dashboard
- Password reset can be rate-limited to prevent abuse

**Example:** Requesting password reset

```javascript
const { data, error } = await supabase.auth.resetPasswordForEmail(
  'user@example.com',
  {
    redirectTo: 'https://yourapp.com/update-password'
  }
)
```

**Example:** Updating password after reset

```javascript
// After user clicks reset link and is redirected to your app
// The access token is in the URL fragment or handled by client library

const { data, error } = await supabase.auth.updateUser({
  password: 'newSecurePassword123'
})
```

The flow: user requests reset → reset email sent → user clicks link → session established with special recovery token → user provides new password → password updated and normal session created.

