## TypeScript type generation


TypeScript types ensure type safety when working with your database schema.

### Generating types with CLI

**Basic type generation:**

```bash
supabase gen types typescript --local > types/supabase.ts
```

**From linked project:**

```bash
supabase gen types typescript --linked > types/supabase.ts
```

**Specific project:**

```bash
supabase gen types typescript --project-id your-project-ref > types/supabase.ts
```

**Multiple schemas:**

```bash
supabase gen types typescript --schema public --schema auth > types/supabase.ts
```

### Generated type structure

**Example database schema:**

```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  username TEXT UNIQUE NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE posts (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  content TEXT,
  author_id UUID REFERENCES profiles(id),
  published BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

**Generated types:**

```typescript
export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export interface Database {
  public: {
    Tables: {
      profiles: {
        Row: {
          id: string
          username: string
          full_name: string | null
          avatar_url: string | null
          created_at: string
        }
        Insert: {
          id?: string
          username: string
          full_name?: string | null
          avatar_url?: string | null
          created_at?: string
        }
        Update: {
          id?: string
          username?: string
          full_name?: string | null
          avatar_url?: string | null
          created_at?: string
        }
        Relationships: []
      }
      posts: {
        Row: {
          id: number
          title: string
          content: string | null
          author_id: string | null
          published: boolean | null
          created_at: string
        }
        Insert: {
          id?: number
          title: string
          content?: string | null
          author_id?: string | null
          published?: boolean | null
          created_at?: string
        }
        Update: {
          id?: number
          title?: string
          content?: string | null
          author_id?: string | null
          published?: boolean | null
          created_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "posts_author_id_fkey"
            columns: ["author_id"]
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          }
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      [_ in never]: never
    }
    Enums: {
      [_ in never]: never
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}
```

### Using types with client

**Basic typed client:**

```typescript
import { createClient } from '@supabase/supabase-js'
import { Database } from './types/supabase'

const supabase = createClient<Database>(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
)

// Now queries are fully typed
const { data } = await supabase
  .from('profiles')  // ✓ Type-checked table name
  .select('username, full_name')  // ✓ Type-checked column names
  .eq('id', 'uuid')  // ✓ Type-checked

// data is typed as:
// Array<{ username: string; full_name: string | null }> | null
```

**Type inference in queries:**

```typescript
// TypeScript knows the exact shape of returned data
const { data: profile } = await supabase
  .from('profiles')
  .select('username, full_name, avatar_url')
  .eq('id', userId)
  .single()

// profile is typed as:
// {
//   username: string
//   full_name: string | null
//   avatar_url: string | null
// } | null

// Autocomplete works
console.log(profile?.username)  // ✓
console.log(profile?.nonexistent)  // ✗ TypeScript error
```

**Insert with types:**

```typescript
const { data, error } = await supabase
  .from('posts')
  .insert({
    title: 'My Post',
    content: 'Content here',
    author_id: userId,
    published: true
  })
  // TypeScript validates all fields
  // Missing 'title' would cause error
  // Wrong type for 'published' would cause error
```

**Update with types:**

```typescript
const { data, error } = await supabase
  .from('profiles')
  .update({
    full_name: 'John Doe',
    avatar_url: 'https://example.com/avatar.jpg'
  })
  .eq('id', userId)
  // All fields are optional
  // Only provided fields will be updated
```

### Type helpers

**Extract specific types:**

```typescript
import { Database } from './types/supabase'

// Get Row type for a table
type Profile = Database['public']['Tables']['profiles']['Row']

// Get Insert type for a table
type ProfileInsert = Database['public']['Tables']['profiles']['Insert']

// Get Update type for a table
type ProfileUpdate = Database['public']['Tables']['profiles']['Update']

// Use in functions
function createProfile(profile: ProfileInsert) {
  return supabase.from('profiles').insert(profile)
}

function updateProfile(id: string, updates: ProfileUpdate) {
  return supabase.from('profiles').update(updates).eq('id', id)
}
```

**Custom type aliases:**

```typescript
// types/database.ts
import { Database } from './supabase'

export type Tables<T extends keyof Database['public']['Tables']> =
  Database['public']['Tables'][T]['Row']

export type Inserts<T extends keyof Database['public']['Tables']> =
  Database['public']['Tables'][T]['Insert']

export type Updates<T extends keyof Database['public']['Tables']> =
  Database['public']['Tables'][T]['Update']

// Usage
export type Profile = Tables<'profiles'>
export type Post = Tables<'posts'>
export type PostInsert = Inserts<'posts'>
export type PostUpdate = Updates<'posts'>
```

**Join type inference:**

```typescript
const { data } = await supabase
  .from('posts')
  .select(`
    id,
    title,
    content,
    author:profiles(username, avatar_url)
  `)

// data is typed as:
// Array<{
//   id: number
//   title: string
//   content: string | null
//   author: {
//     username: string
//     avatar_url: string | null
//   } | null
// }> | null
```

### Enum types

**Database enum:**

```sql
CREATE TYPE user_role AS ENUM ('admin', 'moderator', 'user');

ALTER TABLE profiles ADD COLUMN role user_role DEFAULT 'user';
```

**Generated enum type:**

```typescript
export interface Database {
  public: {
    Enums: {
      user_role: 'admin' | 'moderator' | 'user'
    }
    Tables: {
      profiles: {
        Row: {
          role: Database['public']['Enums']['user_role']
          // ...
        }
      }
    }
  }
}

// Extract enum type
type UserRole = Database['public']['Enums']['user_role']

// Use in code
function checkRole(role: UserRole) {
  if (role === 'admin') {
    // ...
  }
}
```

### Function types

**Database function:**

```sql
CREATE FUNCTION get_user_posts(user_id UUID)
RETURNS TABLE(id BIGINT, title TEXT, created_at TIMESTAMPTZ) AS $$
  SELECT id, title, created_at FROM posts WHERE author_id = user_id;
$$ LANGUAGE SQL;
```

**Generated function type:**

```typescript
export interface Database {
  public: {
    Functions: {
      get_user_posts: {
        Args: {
          user_id: string
        }
        Returns: Array<{
          id: number
          title: string
          created_at: string
        }>
      }
    }
  }
}

// Call with types
const { data, error } = await supabase
  .rpc('get_user_posts', {
    user_id: userId  // Type-checked parameter
  })

// data is typed as Return type
```

### Automating type generation

**npm script:**

`package.json`:

```json
{
  "scripts": {
    "types": "supabase gen types typescript --linked > types/supabase.ts",
    "types:local": "supabase gen types typescript --local > types/supabase.ts"
  }
}
```

Run with:

```bash
npm run types
```

**Pre-commit hook:**

`.husky/pre-commit`:

```bash
#!/bin/sh
npm run types
git add types/supabase.ts
```

**CI/CD integration:**

`.github/workflows/types.yml`:

```yaml
name: Update Types

on:
  push:
    paths:
      - 'supabase/migrations/**'

jobs:
  update-types:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Node
        uses: actions/setup-node@v3
        with:
          node-version: '18'
      
      - name: Install Supabase CLI
        run: npm install -g supabase
      
      - name: Generate Types
        run: |
          supabase gen types typescript --project-id ${{ secrets.SUPABASE_PROJECT_ID }} > types/supabase.ts
        env:
          SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}
      
      - name: Commit Types
        run: |
          git config user.name "GitHub Actions"
          git config user.email "actions@github.com"
          git add types/supabase.ts
          git commit -m "Update database types" || echo "No changes"
          git push
```

### Type safety best practices

**Always regenerate after schema changes:**

```bash
# After running migrations
supabase db push
npm run types
```

**Use strict TypeScript config:**

`tsconfig.json`:

```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true
  }
}
```

**Validate at runtime:**

```typescript
import { z } from 'zod'

const ProfileSchema = z.object({
  id: z.string().uuid(),
  username: z.string(),
  full_name: z.string().nullable(),
  avatar_url: z.string().url().nullable()
})

async function getProfile(id: string) {
  const { data, error } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', id)
    .single()
  
  if (error) throw error
  
  // Validate at runtime
  return ProfileSchema.parse(data)
}
```

