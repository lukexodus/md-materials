## Post-Deployment


- [ ] Update MIGRATIONS.md with deployment notes
- [ ] Close deployment ticket
- [ ] Schedule retrospective if issues occurred
- [ ] Archive backup after 30 days
```

**Important related topics:** Schema validation and constraint design patterns, managing database permissions and roles through migrations, implementing audit logging for schema changes, database performance testing strategies for migrations, handling timezone and data type migrations, coordinating frontend and backend deployments with database changes, disaster recovery procedures for failed migrations, implementing database seeding strategies for different environments, managing secrets and environment variables across branches, schema documentation generation and maintenance.

---

# Framework Integration

## Next.js Integration Patterns

**Key Points:**

- Supabase provides official support for Next.js through `@supabase/ssr` package
- Integration differs between App Router and Pages Router architectures
- Requires careful handling of client/server component boundaries
- Cookie-based session management for server-side operations

### App Router Implementation

The App Router uses React Server Components by default, requiring separate client configurations:

```typescript
// utils/supabase/server.ts
import { createServerClient, type CookieOptions } from '@supabase/ssr'
import { cookies } from 'next/headers'

export function createClient() {
  const cookieStore = cookies()

  return createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get(name: string) {
          return cookieStore.get(name)?.value
        },
        set(name: string, value: string, options: CookieOptions) {
          cookieStore.set({ name, value, ...options })
        },
        remove(name: string, options: CookieOptions) {
          cookieStore.set({ name, value: '', ...options })
        },
      },
    }
  )
}
```

```typescript
// utils/supabase/client.ts
import { createBrowserClient } from '@supabase/ssr'

export function createClient() {
  return createBrowserClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  )
}
```

### Pages Router Implementation

Pages Router uses a middleware-based approach for authentication:

```typescript
// utils/supabase-server.ts
import { createServerSupabaseClient } from '@supabase/auth-helpers-nextjs'
import type { NextApiRequest, NextApiResponse } from 'next'

export const createClient = (req: NextApiRequest, res: NextApiResponse) => {
  return createServerSupabaseClient({ req, res })
}
```

### Middleware Configuration

Authentication state synchronization across requests:

```typescript
// middleware.ts
import { createMiddlewareClient } from '@supabase/auth-helpers-nextjs'
import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export async function middleware(req: NextRequest) {
  const res = NextResponse.next()
  const supabase = createMiddlewareClient({ req, res })
  await supabase.auth.getSession()
  return res
}

export const config = {
  matcher: ['/((?!_next/static|_next/image|favicon.ico).*)'],
}
```

### Route Handlers and API Routes

```typescript
// app/api/data/route.ts
import { createClient } from '@/utils/supabase/server'
import { NextResponse } from 'next/server'

export async function GET() {
  const supabase = createClient()
  const { data, error } = await supabase.from('users').select()
  
  if (error) {
    return NextResponse.json({ error: error.message }, { status: 500 })
  }
  
  return NextResponse.json({ data })
}
```

### Protected Routes Pattern

```typescript
// app/dashboard/page.tsx
import { redirect } from 'next/navigation'
import { createClient } from '@/utils/supabase/server'

export default async function DashboardPage() {
  const supabase = createClient()
  const { data: { user } } = await supabase.auth.getUser()
  
  if (!user) {
    redirect('/login')
  }
  
  return <div>Protected Dashboard Content</div>
}
```

### Real-time Subscriptions in Client Components

```typescript
'use client'

import { createClient } from '@/utils/supabase/client'
import { useEffect, useState } from 'react'

export function RealtimeComponent() {
  const [messages, setMessages] = useState([])
  const supabase = createClient()

  useEffect(() => {
    const channel = supabase
      .channel('messages')
      .on('postgres_changes', 
        { event: 'INSERT', schema: 'public', table: 'messages' },
        (payload) => setMessages(prev => [...prev, payload.new])
      )
      .subscribe()

    return () => {
      supabase.removeChannel(channel)
    }
  }, [])

  return <div>{/* Render messages */}</div>
}
```

## React Integration

**Key Points:**

- Direct client-side integration using `@supabase/supabase-js`
- Context-based authentication state management
- Custom hooks for common operations
- Real-time subscription lifecycle management

### Basic Setup

```typescript
// supabaseClient.ts
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.REACT_APP_SUPABASE_URL!
const supabaseAnonKey = process.env.REACT_APP_SUPABASE_ANON_KEY!

export const supabase = createClient(supabaseUrl, supabaseAnonKey)
```

### Authentication Context

```typescript
// contexts/AuthContext.tsx
import { createContext, useContext, useEffect, useState } from 'react'
import { Session, User } from '@supabase/supabase-js'
import { supabase } from '../supabaseClient'

interface AuthContextType {
  user: User | null
  session: Session | null
  signIn: (email: string, password: string) => Promise<void>
  signOut: () => Promise<void>
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [session, setSession] = useState<Session | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session)
      setUser(session?.user ?? null)
      setLoading(false)
    })

    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      (_event, session) => {
        setSession(session)
        setUser(session?.user ?? null)
      }
    )

    return () => subscription.unsubscribe()
  }, [])

  const signIn = async (email: string, password: string) => {
    const { error } = await supabase.auth.signInWithPassword({ email, password })
    if (error) throw error
  }

  const signOut = async () => {
    const { error } = await supabase.auth.signOut()
    if (error) throw error
  }

  return (
    <AuthContext.Provider value={{ user, session, signIn, signOut }}>
      {!loading && children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => {
  const context = useContext(AuthContext)
  if (context === undefined) {
    throw new Error('useAuth must be used within AuthProvider')
  }
  return context
}
```

### Custom Data Fetching Hook

```typescript
// hooks/useSupabaseQuery.ts
import { useEffect, useState } from 'react'
import { supabase } from '../supabaseClient'

export function useSupabaseQuery<T>(
  query: () => Promise<{ data: T | null; error: any }>
) {
  const [data, setData] = useState<T | null>(null)
  const [error, setError] = useState<any>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    query()
      .then(({ data, error }) => {
        setData(data)
        setError(error)
      })
      .finally(() => setLoading(false))
  }, [])

  return { data, error, loading }
}
```

### Protected Route Component

```typescript
// components/ProtectedRoute.tsx
import { Navigate } from 'react-router-dom'
import { useAuth } from '../contexts/AuthContext'

export function ProtectedRoute({ children }: { children: React.ReactNode }) {
  const { user } = useAuth()
  
  if (!user) {
    return <Navigate to="/login" replace />
  }
  
  return <>{children}</>
}
```

## Vue.js Integration

**Key Points:**

- Composables for reactive Supabase operations
- Pinia store integration for state management
- Vue Router navigation guards for authentication
- TypeScript support with proper type inference

### Composable Setup

```typescript
// composables/useSupabase.ts
import { createClient } from '@supabase/supabase-js'
import { ref, computed } from 'vue'
import type { User, Session } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

export function useAuth() {
  const user = ref<User | null>(null)
  const session = ref<Session | null>(null)
  const loading = ref(true)

  const isAuthenticated = computed(() => !!user.value)

  const initialize = async () => {
    const { data: { session: currentSession } } = await supabase.auth.getSession()
    session.value = currentSession
    user.value = currentSession?.user ?? null
    loading.value = false

    supabase.auth.onAuthStateChange((_event, newSession) => {
      session.value = newSession
      user.value = newSession?.user ?? null
    })
  }

  const signIn = async (email: string, password: string) => {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })
    if (error) throw error
    return data
  }

  const signOut = async () => {
    const { error } = await supabase.auth.signOut()
    if (error) throw error
  }

  return {
    user,
    session,
    loading,
    isAuthenticated,
    initialize,
    signIn,
    signOut,
  }
}
```

### Pinia Store Integration

```typescript
// stores/auth.ts
import { defineStore } from 'pinia'
import { supabase } from '@/composables/useSupabase'
import type { User } from '@supabase/supabase-js'

export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null as User | null,
    loading: false,
  }),

  getters: {
    isAuthenticated: (state) => !!state.user,
  },

  actions: {
    async initialize() {
      const { data: { session } } = await supabase.auth.getSession()
      this.user = session?.user ?? null

      supabase.auth.onAuthStateChange((_event, session) => {
        this.user = session?.user ?? null
      })
    },

    async signIn(email: string, password: string) {
      this.loading = true
      try {
        const { error } = await supabase.auth.signInWithPassword({
          email,
          password,
        })
        if (error) throw error
      } finally {
        this.loading = false
      }
    },

    async signOut() {
      const { error } = await supabase.auth.signOut()
      if (error) throw error
    },
  },
})
```

### Router Guards

```typescript
// router/index.ts
import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/dashboard',
      component: () => import('@/views/Dashboard.vue'),
      meta: { requiresAuth: true },
    },
    // other routes
  ],
})

router.beforeEach(async (to, from, next) => {
  const authStore = useAuthStore()
  
  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    next('/login')
  } else {
    next()
  }
})

export default router
```

### Component Usage

```vue
<!-- components/UserProfile.vue -->
<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '@/composables/useSupabase'

interface Profile {
  id: string
  username: string
  avatar_url: string
}

const profile = ref<Profile | null>(null)
const loading = ref(true)

onMounted(async () => {
  const { data: { user } } = await supabase.auth.getUser()
  
  if (user) {
    const { data, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', user.id)
      .single()
    
    profile.value = data
  }
  
  loading.value = false
})
</script>

<template>
  <div v-if="loading">Loading...</div>
  <div v-else-if="profile">
    <h2>{{ profile.username }}</h2>
    <img :src="profile.avatar_url" />
  </div>
</template>
```

## Svelte Integration

**Key Points:**

- Svelte stores for reactive authentication state
- SvelteKit-specific server/client patterns
- Form actions for server-side mutations
- Type-safe database queries with generated types

### Client Setup

```typescript
// lib/supabaseClient.ts
import { createClient } from '@supabase/supabase-js'
import { writable } from 'svelte/store'
import type { User, Session } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

export const user = writable<User | null>(null)
export const session = writable<Session | null>(null)

supabase.auth.getSession().then(({ data: { session: currentSession } }) => {
  session.set(currentSession)
  user.set(currentSession?.user ?? null)
})

supabase.auth.onAuthStateChange((_event, newSession) => {
  session.set(newSession)
  user.set(newSession?.user ?? null)
})
```

### SvelteKit Server-Side Integration

```typescript
// src/hooks.server.ts
import { createServerClient } from '@supabase/ssr'
import type { Handle } from '@sveltejs/kit'

export const handle: Handle = async ({ event, resolve }) => {
  event.locals.supabase = createServerClient(
    process.env.PUBLIC_SUPABASE_URL!,
    process.env.PUBLIC_SUPABASE_ANON_KEY!,
    {
      cookies: {
        get: (key) => event.cookies.get(key),
        set: (key, value, options) => {
          event.cookies.set(key, value, options)
        },
        remove: (key, options) => {
          event.cookies.delete(key, options)
        },
      },
    }
  )

  event.locals.getSession = async () => {
    const {
      data: { session },
    } = await event.locals.supabase.auth.getSession()
    return session
  }

  return resolve(event, {
    filterSerializedResponseHeaders(name) {
      return name === 'content-range'
    },
  })
}
```

### Page Load Function

```typescript
// routes/dashboard/+page.server.ts
import { redirect } from '@sveltejs/kit'
import type { PageServerLoad } from './$types'

export const load: PageServerLoad = async ({ locals: { supabase, getSession } }) => {
  const session = await getSession()

  if (!session) {
    throw redirect(303, '/login')
  }

  const { data: profile } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', session.user.id)
    .single()

  return {
    session,
    profile,
  }
}
```

### Form Actions

```typescript
// routes/login/+page.server.ts
import { fail, redirect } from '@sveltejs/kit'
import type { Actions } from './$types'

export const actions: Actions = {
  login: async ({ request, locals: { supabase } }) => {
    const formData = await request.formData()
    const email = formData.get('email') as string
    const password = formData.get('password') as string

    const { error } = await supabase.auth.signInWithPassword({
      email,
      password,
    })

    if (error) {
      return fail(400, { email, error: error.message })
    }

    throw redirect(303, '/dashboard')
  },
}
```

### Component with Real-time Subscription

```svelte
<!-- routes/messages/+page.svelte -->
<script lang="ts">
  import { onMount, onDestroy } from 'svelte'
  import { supabase } from '$lib/supabaseClient'
  
  let messages: any[] = []
  let channel: any

  onMount(() => {
    loadMessages()
    
    channel = supabase
      .channel('messages')
      .on('postgres_changes', 
        { event: 'INSERT', schema: 'public', table: 'messages' },
        (payload) => {
          messages = [...messages, payload.new]
        }
      )
      .subscribe()
  })

  onDestroy(() => {
    if (channel) {
      supabase.removeChannel(channel)
    }
  })

  async function loadMessages() {
    const { data } = await supabase
      .from('messages')
      .select('*')
      .order('created_at', { ascending: false })
    
    if (data) messages = data
  }
</script>

<div>
  {#each messages as message}
    <div>{message.content}</div>
  {/each}
</div>
```

## React Native Mobile Apps

**Key Points:**

- AsyncStorage for persistent session storage
- Deep linking for OAuth callbacks
- Biometric authentication integration
- Offline-first patterns with local caching

### Project Setup

```typescript
// lib/supabase.ts
import 'react-native-url-polyfill/auto'
import { createClient } from '@supabase/supabase-js'
import AsyncStorage from '@react-native-async-storage/async-storage'

const supabaseUrl = process.env.EXPO_PUBLIC_SUPABASE_URL!
const supabaseAnonKey = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY!

export const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    storage: AsyncStorage,
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
  },
})
```

### Authentication Context

```typescript
// contexts/AuthContext.tsx
import { createContext, useContext, useEffect, useState } from 'react'
import { Session } from '@supabase/supabase-js'
import { supabase } from '../lib/supabase'

interface AuthContextType {
  session: Session | null
  loading: boolean
}

const AuthContext = createContext<AuthContextType>({
  session: null,
  loading: true,
})

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [session, setSession] = useState<Session | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    supabase.auth.getSession().then(({ data: { session } }) => {
      setSession(session)
      setLoading(false)
    })

    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      (_event, session) => {
        setSession(session)
      }
    )

    return () => subscription.unsubscribe()
  }, [])

  return (
    <AuthContext.Provider value={{ session, loading }}>
      {children}
    </AuthContext.Provider>
  )
}

export const useAuth = () => useContext(AuthContext)
```

### OAuth with Deep Linking (Expo)

```typescript
// app.json configuration
{
  "expo": {
    "scheme": "myapp",
    "plugins": [
      [
        "expo-build-properties",
        {
          "android": {
            "usesCleartextTraffic": true
          }
        }
      ]
    ]
  }
}
```

```typescript
// screens/Auth.tsx
import { supabase } from '../lib/supabase'
import * as WebBrowser from 'expo-web-browser'
import { makeRedirectUri } from 'expo-auth-session'

WebBrowser.maybeCompleteAuthSession()

const redirectTo = makeRedirectUri()

async function signInWithGithub() {
  const { data, error } = await supabase.auth.signInWithOAuth({
    provider: 'github',
    options: {
      redirectTo,
      skipBrowserRedirect: true,
    },
  })

  if (error) throw error

  const res = await WebBrowser.openAuthSessionAsync(
    data.url,
    redirectTo
  )

  if (res.type === 'success') {
    const { url } = res
    const params = new URLSearchParams(url.split('#')[1])
    const accessToken = params.get('access_token')
    
    if (accessToken) {
      await supabase.auth.setSession({
        access_token: accessToken,
        refresh_token: params.get('refresh_token')!,
      })
    }
  }
}
```

### Biometric Authentication

```typescript
// hooks/useBiometrics.ts
import * as LocalAuthentication from 'expo-local-authentication'
import { useEffect, useState } from 'react'
import AsyncStorage from '@react-native-async-storage/async-storage'

export function useBiometrics() {
  const [isAvailable, setIsAvailable] = useState(false)

  useEffect(() => {
    checkBiometrics()
  }, [])

  async function checkBiometrics() {
    const compatible = await LocalAuthentication.hasHardwareAsync()
    const enrolled = await LocalAuthentication.isEnrolledAsync()
    setIsAvailable(compatible && enrolled)
  }

  async function authenticate() {
    const result = await LocalAuthentication.authenticateAsync({
      promptMessage: 'Authenticate to access your account',
      fallbackLabel: 'Use passcode',
    })
    return result.success
  }

  async function enableBiometrics(credentials: { email: string; password: string }) {
    await AsyncStorage.setItem('biometrics_enabled', 'true')
    await AsyncStorage.setItem('credentials', JSON.stringify(credentials))
  }

  return {
    isAvailable,
    authenticate,
    enableBiometrics,
  }
}
```

### Offline Data Sync

```typescript
// hooks/useOfflineSync.ts
import { useEffect, useState } from 'react'
import { supabase } from '../lib/supabase'
import AsyncStorage from '@react-native-async-storage/async-storage'
import NetInfo from '@react-native-community/netinfo'

export function useOfflineSync<T>(
  table: string,
  cacheKey: string
) {
  const [data, setData] = useState<T[]>([])
  const [isOnline, setIsOnline] = useState(true)

  useEffect(() => {
    const unsubscribe = NetInfo.addEventListener(state => {
      setIsOnline(state.isConnected ?? false)
    })

    loadData()
    return unsubscribe
  }, [])

  async function loadData() {
    // Try loading from cache first
    const cached = await AsyncStorage.getItem(cacheKey)
    if (cached) {
      setData(JSON.parse(cached))
    }

    // Fetch fresh data if online
    if (isOnline) {
      const { data: freshData } = await supabase
        .from(table)
        .select('*')
      
      if (freshData) {
        setData(freshData)
        await AsyncStorage.setItem(cacheKey, JSON.stringify(freshData))
      }
    }
  }

  return { data, isOnline, refresh: loadData }
}
```

## Flutter Integration

**Key Points:**

- Official `supabase_flutter` package with platform-specific handling
- Deep linking configuration for iOS and Android
- Provider or Riverpod for state management
- GoRouter integration for authentication routing

### Project Setup

```yaml
