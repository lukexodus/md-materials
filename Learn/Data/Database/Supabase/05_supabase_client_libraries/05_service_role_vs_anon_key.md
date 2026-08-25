## Service role vs anon key


Understanding the difference between service_role and anon keys is critical for security.

### Anon key characteristics

**Security level:** Limited access

**RLS enforcement:** YES - always respects Row Level Security policies

**Use cases:**

- Client-side applications
- Mobile applications
- Public API access
- User-facing operations

**What anon key CAN do:**

- Query tables with proper RLS policies
- Authenticate users
- Access data permitted by RLS
- Subscribe to realtime changes (filtered by RLS)
- Upload files with storage policies
- Call Edge Functions

**What anon key CANNOT do:**

- Bypass RLS policies
- Access restricted data without proper policies
- Modify system tables
- Change database schema
- Access other users' data (unless policy allows)

**Example - Anon key behavior:**

```typescript
const supabase = createClient(url, anonKey)

// User A is logged in
await supabase.auth.signInWithPassword({ email: 'userA@example.com', password: 'pass' })

// Can only see own profile (if RLS policy allows)
const { data } = await supabase
  .from('profiles')
  .select('*')
// Returns only userA's profile due to RLS

// Cannot access other user's data
const { data: otherProfile } = await supabase
  .from('profiles')
  .select('*')
  .eq('id', 'different-user-id')
// Returns null or error depending on RLS policy
```

**RLS policy example that anon key respects:**

```sql
-- Users can only read their own profile
CREATE POLICY "Users view own profile"
ON profiles FOR SELECT
USING (auth.uid() = id);

-- With anon key, this query only returns the authenticated user's profile
-- Cannot see other users' profiles
```

### Service role key characteristics

**Security level:** Full admin access

**RLS enforcement:** NO - bypasses all Row Level Security policies

**Use cases:**

- Server-side administrative tasks
- Data migrations
- Batch operations
- System maintenance
- Backend services
- Scheduled jobs

**What service_role key CAN do:**

- Access ALL data regardless of RLS
- Modify any table
- Create/alter schema
- Access system tables
- Bypass all security policies
- Perform bulk operations
- Administrative functions

**What service_role key MUST NEVER do:**

- Be exposed to client-side code
- Be committed to version control
- Be shared in public repositories
- Be used in browser/mobile apps

**Example - Service role behavior:**

```typescript
const supabaseAdmin = createClient(url, serviceRoleKey)

// No authentication needed
// Can access ALL profiles regardless of RLS
const { data: allProfiles } = await supabaseAdmin
  .from('profiles')
  .select('*')
// Returns EVERY user's profile

// Can modify any data
await supabaseAdmin
  .from('profiles')
  .update({ verified: true })
  .eq('email', 'someuser@example.com')
// Succeeds even if RLS would normally block this
```

### Security comparison

|Feature|Anon Key|Service Role Key|
|---|---|---|
|Bypasses RLS|No|Yes|
|Safe in client code|Yes|NO - NEVER|
|Requires authentication|For protected resources|No|
|Access scope|Limited by RLS|Full database access|
|Typical usage|Client-side|Server-side only|
|Can modify schema|No|Yes|
|Risk if exposed|Low|CRITICAL|

### Common mistakes and security risks

**CRITICAL MISTAKE - Exposing service role key:**

```typescript
// ❌ NEVER DO THIS
const supabase = createClient(
  'https://project.supabase.co',
  'eyJhbGciOiJIUz...'  // Service role key in client code = SECURITY BREACH
)
```

If service_role key is exposed:

- Anyone can access all database data
- Anyone can modify/delete all data
- All security is bypassed
- Must immediately rotate keys

**Correct approach:**

```typescript
// ✅ Client-side
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!  // Safe to expose
)

// ✅ Server-side only
const supabaseAdmin = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!  // Never exposed to client
)
```

### When to use each key

**Use anon key when:**

- Building client-side features
- Users interact directly
- RLS policies control access
- Authentication is handled by Supabase Auth
- Working in browser or mobile app

**Use service_role key when:**

- Running server-side scripts
- Performing administrative tasks
- Bypassing RLS intentionally for system operations
- Batch processing data
- Running in secure server environment
- No user context needed

**Example - Admin dashboard (correct pattern):**

Frontend (uses anon key):

```typescript
// components/AdminDashboard.tsx
async function fetchUsers() {
  // Call secure API route
  const response = await fetch('/api/admin/users', {
    headers: {
      'Authorization': `Bearer ${session.access_token}`
    }
  })
  const users = await response.json()
  return users
}
```

Backend API route (uses service_role key):

```typescript
// pages/api/admin/users.ts
import { createClient } from '@supabase/supabase-js'

export default async function handler(req, res) {
  // Verify user is admin (implement your auth logic)
  const isAdmin = await verifyAdminToken(req.headers.authorization)
  
  if (!isAdmin) {
    return res.status(403).json({ error: 'Forbidden' })
  }

  // Now safe to use service role
  const supabaseAdmin = createClient(
    process.env.SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!
  )

  const { data: users } = await supabaseAdmin
    .from('profiles')
    .select('*')

  res.json(users)
}
```

### Key rotation

If service_role key is accidentally exposed:

1. **Immediately rotate keys in dashboard:**
    
    - Settings → API → Generate new keys
2. **Update all server-side environment variables**
    
3. **Redeploy affected services**
    
4. **Audit database access logs** [Inference - if available on plan]
    
5. **Review RLS policies** to ensure data integrity
    

Anon key exposure is less critical but still recommended to rotate if concerned.

