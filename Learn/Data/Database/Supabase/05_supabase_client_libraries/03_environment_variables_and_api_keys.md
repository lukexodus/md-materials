## Environment variables and API keys


### Environment variable setup

**Standard environment variables:**

`.env.local` (for Next.js, Vite, etc.):

```bash
# Public variables (safe for client-side)
NEXT_PUBLIC_SUPABASE_URL=https://your-project-ref.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Private variables (server-side only)
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_DB_PASSWORD=your-database-password
```

**Naming conventions:**

Different frameworks use different prefixes for public variables:

**Next.js:** `NEXT_PUBLIC_`

```bash
NEXT_PUBLIC_SUPABASE_URL=...
NEXT_PUBLIC_SUPABASE_ANON_KEY=...
```

**Vite:** `VITE_`

```bash
VITE_SUPABASE_URL=...
VITE_SUPABASE_ANON_KEY=...
```

**Create React App:** `REACT_APP_`

```bash
REACT_APP_SUPABASE_URL=...
REACT_APP_SUPABASE_ANON_KEY=...
```

**SvelteKit:** No prefix needed, use `$env/static/public`

```bash
PUBLIC_SUPABASE_URL=...
PUBLIC_SUPABASE_ANON_KEY=...
```

### API key types and usage

**anon (public) key:**

- Safe to expose in client-side code
- Respects Row Level Security (RLS)
- Users can only access data allowed by RLS policies
- Used for client-side operations
- Cannot bypass security rules

```typescript
// Client-side usage
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY  // Safe to expose
)
```

**service_role key:**

- Must NEVER be exposed to client-side
- Bypasses all Row Level Security
- Full admin access to database
- Used for server-side operations only
- Administrative tasks, migrations, system operations

```typescript
// Server-side only
const supabaseAdmin = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY  // NEVER expose to client
)
```

### Finding API keys

**In Supabase Dashboard:**

1. Open project
2. Navigate to Settings → API
3. Copy keys from "Project API keys" section

**Two keys displayed:**

- `anon` / `public`: For client-side
- `service_role`: For server-side (hidden by default, click to reveal)

**Project URL:** Also on Settings → API page: `https://your-project-ref.supabase.co`

### Loading environment variables

**Next.js:**

```typescript
// Automatic loading from .env.local
const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)
```

**Vite:**

```typescript
const supabase = createClient(
  import.meta.env.VITE_SUPABASE_URL,
  import.meta.env.VITE_SUPABASE_ANON_KEY
)
```

**Node.js (with dotenv):**

```typescript
import 'dotenv/config'

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_ANON_KEY!
)
```

**SvelteKit:**

```typescript
import { PUBLIC_SUPABASE_URL, PUBLIC_SUPABASE_ANON_KEY } from '$env/static/public'

const supabase = createClient(
  PUBLIC_SUPABASE_URL,
  PUBLIC_SUPABASE_ANON_KEY
)
```

### Security best practices

**Never commit sensitive keys:**

`.gitignore`:

```
.env
.env.local
.env.*.local
```

**Different keys per environment:**

`.env.development`:

```bash
NEXT_PUBLIC_SUPABASE_URL=https://dev-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=dev-anon-key
```

`.env.production`:

```bash
NEXT_PUBLIC_SUPABASE_URL=https://prod-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=prod-anon-key
```

**Validate environment variables:**

```typescript
function validateEnv() {
  const required = [
    'NEXT_PUBLIC_SUPABASE_URL',
    'NEXT_PUBLIC_SUPABASE_ANON_KEY'
  ]
  
  for (const key of required) {
    if (!process.env[key]) {
      throw new Error(`Missing required environment variable: ${key}`)
    }
  }
}

validateEnv()
```

**Type-safe environment variables:**

```typescript
// env.ts
export const env = {
  supabase: {
    url: process.env.NEXT_PUBLIC_SUPABASE_URL as string,
    anonKey: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY as string,
  }
}

// Validate at startup
if (!env.supabase.url || !env.supabase.anonKey) {
  throw new Error('Missing Supabase environment variables')
}
```

**Rotate keys periodically:**

[Inference] While Supabase doesn't require regular key rotation, it's a security best practice:

1. Generate new keys in dashboard (Settings → API)
2. Update environment variables
3. Redeploy applications
4. Revoke old keys (if feature available)

