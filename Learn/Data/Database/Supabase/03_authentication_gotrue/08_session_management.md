## Session Management


Handling of user sessions including creation, persistence, refresh, and termination. Sessions track active authenticated users and manage token lifecycle.

**Key points:**

- Sessions stored in `auth.sessions` table with device and location information
- Client libraries automatically handle session persistence and refresh
- Session refresh occurs before access token expiration
- Multiple sessions per user supported across devices
- Sessions can be individually revoked or all terminated at once
- Session events emitted for state changes (SIGNED_IN, SIGNED_OUT, TOKEN_REFRESHED)

**Example:** Listening to auth state changes

```javascript
supabase.auth.onAuthStateChange((event, session) => {
  if (event === 'SIGNED_IN') {
    console.log('User signed in', session)
  } else if (event === 'SIGNED_OUT') {
    console.log('User signed out')
  } else if (event === 'TOKEN_REFRESHED') {
    console.log('Token refreshed', session)
  }
})
```

**Example:** Getting current session

```javascript
const { data: { session }, error } = await supabase.auth.getSession()
```

**Example:** Refreshing session manually

```javascript
const { data: { session }, error } = await supabase.auth.refreshSession()
```

**Example:** Signing out

```javascript
// Sign out from current session
await supabase.auth.signOut()

// Sign out from all sessions
await supabase.auth.signOut({ scope: 'global' })
```

