## Client-side vs server-side usage


Understanding when and how to use Supabase client-side versus server-side is crucial for security and proper application architecture.

### Client-side usage

**Characteristics:**

- Runs in browser environment
- Uses anon key (respects RLS)
- Session stored in localStorage/sessionStorage
- Automatic token refresh
- Direct user interaction

**When to use client-side:**

- User authentication flows
- Querying data permitted by RLS
- Realtime subscriptions
- User-initiated CRUD operations
- File uploads by users
- Reading public data

**Example - React component:**

```typescript
import { useEffect, useState } from 'react'
import { supabase } from '@/lib/supabase'

function UserProfile() {
  const [profile, setProfile] = useState(null)

  useEffect(() => {
    async function loadProfile() {
      // Client-side query - respects RLS
      const { data } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', supabase.auth.getUser().data.user?.id)
        .single()
      
      setProfile(data)
    }
    
    loadProfile()
  }, [])

  return <div>{profile?.username}</div>
}
```

**Example - Authentication:**

```typescript
// Sign up - client-side
async function handleSignUp(email: string, password: string) {
  const { data, error } = await supabase.auth.signUp({
    email,
    password,
  })
  
  if (error) console.error(error)
  else console.log('User created:', data.user)
}

// Sign in - client-side
async function handleSignIn(email: string, password: string) {
  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password,
  })
  
  if (error) console.error(error)
  else console.log('Signed in:', data.session)
}
```

**Example - Realtime subscription:**

```typescript
useEffect(() => {
  // Client-side realtime - respects RLS
  const channel = supabase
    .channel('public:posts')
    .on(
      'postgres_changes',
      { event: '*', schema: 'public', table: 'posts' },
      (payload) => {
        console.log('Change detected:', payload)
      }
    )
    .subscribe()

  return () => {
    supabase.removeChannel(channel)
  }
}, [])
```

### Server-side usage

**Characteristics:**

- Runs on server/serverless functions
- Can use service_role key (bypasses RLS)
- No session persistence needed
- No automatic token refresh
- Backend operations

**When to use server-side:**

- Administrative operations
- Bypassing RLS for system tasks
- Batch operations
- Scheduled jobs/cron tasks
- Server-side rendering with user context
- Webhook processing
- Data migrations

**Example - Next.js API route (service role):**

```typescript
// pages/api/admin/users.ts
import { createClient } from '@supabase/supabase-js'

export default async function handler(req, res) {
  // Server-side admin client - bypasses RLS
  const supabaseAdmin = createClient(
    process.env.SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY!,
    {
      auth: {
        autoRefreshToken: false,
        persistSession: false
      }
    }
  )

  // Can access all users regardless of RLS
  const { data: users } = await supabaseAdmin
    .from('profiles')
    .select('*')

  res.json(users)
}
```

**Example - Next.js API route (with user context):**

```typescript
// pages/api/user/profile.ts
import { createClient } from '@supabase/supabase-js'

export default async function handler(req, res) {
  // Get user token from request
  const token = req.headers.authorization?.replace('Bearer ', '')

  if (!token) {
    return res.status(401).json({ error: 'Unauthorized' })
  }

  // Create client with user's token - respects RLS
  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      global: {
        headers: {
          Authorization: `Bearer ${token}`
        }
      }
    }
  )

  // Query runs with user's permissions
  const { data, error } = await supabase
    .from('profiles')
    .select('*')
    .single()

  if (error) return res.status(400).json({ error: error.message })
  res.json(data)
}
```

**Example - Server-side rendering (Next.js):**

```typescript
// pages/posts/[id].tsx
import { createClient } from '@supabase/supabase-js'
import { GetServerSideProps } from 'next'

export const getServerSideProps: GetServerSideProps = async (context) => {
  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )

  const { data: post } = await supabase
    .from('posts')
    .select('*')
    .eq('id', context.params?.id)
    .single()

  return {
    props: { post }
  }
}

export default function Post({ post }) {
  return <article>{post.title}</article>
}
```

**Example - Scheduled task (Edge Function):**

```typescript
// supabase/functions/daily-cleanup/index.ts
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

Deno.serve(async (req) => {
  // Service role for admin operations
  const supabaseAdmin = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  // Delete old records (bypasses RLS)
  const { error } = await supabaseAdmin
    .from('temp_data')
    .delete()
    .lt('created_at', new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString())

  return new Response(
    JSON.stringify({ success: !error }),
    { headers: { 'Content-Type': 'application/json' } }
  )
})
```

### Hybrid patterns

**Server-side with user authentication:**

Use auth helpers to maintain user session server-side while respecting RLS.

**Next.js with auth helpers:**

```typescript
import { createServerComponentClient } from '@supabase/auth-helpers-nextjs'
import { cookies } from 'next/headers'

export default async function ServerComponent() {
  // Server component with user session
  const supabase = createServerComponentClient({ cookies })
  
  // Query respects RLS for current user
  const { data: posts } = await supabase
    .from('posts')
    .select('*')
    .eq('user_id', (await supabase.auth.getUser()).data.user?.id)

  return <div>{posts?.map(p => <div key={p.id}>{p.title}</div>)}</div>
}
```

**SvelteKit load function:**

```typescript
// +page.server.ts
import { createServerClient } from '@supabase/auth-helpers-sveltekit'

export const load = async ({ locals, cookies }) => {
  const supabase = createServerClient(locals.supabase)
  
  const { data: posts } = await supabase
    .from('posts')
    .select('*')
  
  return { posts }
}
```

### Decision matrix

|Scenario|Client-Side|Server-Side|Key Type|
|---|---|---|---|
|User login|✓||anon|
|Fetch user's own data|✓|✓|anon|
|Admin dashboard||✓|service_role|
|Public data query|✓|✓|anon|
|Bulk data import||✓|service_role|
|Real-time subscriptions|✓||anon|
|Scheduled cleanup||✓|service_role|
|SSR with auth||✓|anon (with user token)|
|User file upload|✓||anon|
|System file operations||✓|service_role|

