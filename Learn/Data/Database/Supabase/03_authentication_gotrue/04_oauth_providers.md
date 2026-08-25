## OAuth Providers


Third-party authentication through providers like Google, GitHub, Apple, Azure, Facebook, Discord, and others. Users authenticate through the provider's interface, and Supabase receives identity information.

**Key points:**

- Providers must be enabled and configured in Supabase dashboard
- Requires OAuth client ID and secret from each provider
- Redirect URLs must be configured on provider's platform
- User identity stored in `auth.identities` table
- Can link multiple providers to single user account
- Profile information from provider can be accessed via user metadata

**Example:** OAuth sign-in

```javascript
const { data, error } = await supabase.auth.signInWithOAuth({
  provider: 'google',
  options: {
    redirectTo: 'https://yourapp.com/auth/callback',
    scopes: 'email profile',
    queryParams: {
      access_type: 'offline',
      prompt: 'consent'
    }
  }
})
```

The OAuth flow redirects users to the provider's login page, then back to your application with authentication credentials. Supabase handles the token exchange and session creation.

