## Client initialization and configuration


### Basic client creation

**Import and create client:**

```typescript
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://your-project-ref.supabase.co'
const supabaseAnonKey = 'your-anon-key'

const supabase = createClient(supabaseUrl, supabaseAnonKey)
```

**Required parameters:**

- `supabaseUrl`: Your project URL from dashboard
- `supabaseKey`: Either anon key or service_role key

### Configuration options

**Full configuration object:**

```typescript
const supabase = createClient(supabaseUrl, supabaseAnonKey, {
  auth: {
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: true,
    storage: customStorageImplementation,
    storageKey: 'supabase.auth.token',
    flowType: 'pkce'
  },
  db: {
    schema: 'public'
  },
  global: {
    headers: {
      'x-custom-header': 'value'
    },
    fetch: customFetchImplementation
  },
  realtime: {
    params: {
      eventsPerSecond: 10
    }
  }
})
```

### Auth configuration options

**autoRefreshToken** (boolean, default: `true`): Automatically refresh access tokens before expiry

```typescript
auth: {
  autoRefreshToken: true  // Recommended for client-side
}
```

**persistSession** (boolean, default: `true`): Store session in browser localStorage/AsyncStorage

```typescript
auth: {
  persistSession: true  // Keep users logged in
}
```

**detectSessionInUrl** (boolean, default: `true`): Automatically detect auth callback parameters in URL

```typescript
auth: {
  detectSessionInUrl: true  // Handle OAuth redirects
}
```

**storage** (Storage interface): Custom storage implementation

```typescript
import AsyncStorage from '@react-native-async-storage/async-storage'

auth: {
  storage: AsyncStorage  // For React Native
}
```

**storageKey** (string, default: `'supabase.auth.token'`): Key used to store session in storage

```typescript
auth: {
  storageKey: 'my-app.auth.token'  // Custom key
}
```

**flowType** (string, default: `'implicit'`): OAuth flow type - `'implicit'` or `'pkce'`

```typescript
auth: {
  flowType: 'pkce'  // More secure, recommended
}
```

### Database configuration options

**schema** (string, default: `'public'`): Default schema for queries

```typescript
db: {
  schema: 'public'  // Or 'custom_schema'
}
```

### Global configuration options

**headers** (object): Custom headers sent with every request

```typescript
global: {
  headers: {
    'x-application-name': 'MyApp',
    'x-application-version': '1.0.0'
  }
}
```

**fetch** (function): Custom fetch implementation

```typescript
global: {
  fetch: customFetch  // For custom interceptors, logging, etc.
}
```

### Realtime configuration options

**params** (object): Realtime connection parameters

```typescript
realtime: {
  params: {
    eventsPerSecond: 10  // Throttle events
  }
}
```

### TypeScript-enhanced initialization

**With database types:**

```typescript
import { createClient } from '@supabase/supabase-js'
import { Database } from './types/supabase'

const supabase = createClient<Database>(
  supabaseUrl,
  supabaseAnonKey
)

// Now all queries are fully typed
const { data } = await supabase
  .from('profiles')  // Type-checked table name
  .select('username, full_name')  // Type-checked columns
```

### Client instance patterns

**Singleton pattern (recommended):**

Create single client instance shared across application.

`lib/supabase.ts`:

```typescript
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL!
const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!

export const supabase = createClient(supabaseUrl, supabaseAnonKey)
```

Usage:

```typescript
import { supabase } from '@/lib/supabase'

const { data } = await supabase.from('posts').select()
```

**Factory pattern:**

Create new client instances with different configurations.

```typescript
import { createClient, SupabaseClient } from '@supabase/supabase-js'

export function createSupabaseClient(accessToken?: string): SupabaseClient {
  return createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    {
      global: {
        headers: accessToken 
          ? { Authorization: `Bearer ${accessToken}` }
          : {}
      }
    }
  )
}
```

**Server-side client factory:**

```typescript
export function createServerClient(serviceRoleKey: string) {
  return createClient(
    process.env.SUPABASE_URL!,
    serviceRoleKey,
    {
      auth: {
        autoRefreshToken: false,
        persistSession: false,
        detectSessionInUrl: false
      }
    }
  )
}
```

