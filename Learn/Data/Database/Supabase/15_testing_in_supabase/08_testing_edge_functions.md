## Testing Edge Functions


Edge Functions are serverless functions deployed to Supabase's edge network, requiring specialized testing approaches.

### Edge Function Structure

```typescript
// supabase/functions/hello/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    const { name } = await req.json()
    
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? ''
    )

    const { data, error } = await supabase
      .from('greetings')
      .insert({ name, message: `Hello, ${name}!` })
      .select()
      .single()

    if (error) throw error

    return new Response(
      JSON.stringify(data),
      { headers: { 'Content-Type': 'application/json' } }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 400, headers: { 'Content-Type': 'application/json' } }
    )
  }
})
```

### Local Edge Function Testing

```typescript
// supabase/functions/hello/index.test.ts
import { assertEquals } from 'https://deno.land/std@0.168.0/testing/asserts.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const SUPABASE_URL = Deno.env.get('SUPABASE_URL') || 'http://localhost:54321'
const SUPABASE_ANON_KEY = Deno.env.get('SUPABASE_ANON_KEY') || 'your-anon-key'

Deno.test('hello function returns greeting', async () => {
  const response = await fetch(`${SUPABASE_URL}/functions/v1/hello`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
    },
    body: JSON.stringify({ name: 'World' })
  })

  const data = await response.json()
  
  assertEquals(response.status, 200)
  assertEquals(data.message, 'Hello, World!')
})

Deno.test('hello function handles missing name', async () => {
  const response = await fetch(`${SUPABASE_URL}/functions/v1/hello`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
    },
    body: JSON.stringify({})
  })

  assertEquals(response.status, 400)
})
```

### Running Edge Function Tests

```bash
# Start Supabase locally
supabase start

# Serve function locally
supabase functions serve hello --env-file .env.local

# Run tests
deno test --allow-net --allow-env supabase/functions/hello/index.test.ts
```

### Mocking Edge Function Dependencies

```typescript
// supabase/functions/_shared/supabase-mock.ts
export class SupabaseMock {
  private mockData: Record<string, any[]> = {}

  from(table: string) {
    return {
      insert: (data: any) => ({
        select: () => ({
          single: async () => {
            const record = Array.isArray(data) ? data[0] : data
            this.mockData[table] = this.mockData[table] || []
            this.mockData[table].push(record)
            return { data: record, error: null }
          }
        })
      }),
      select: () => ({
        eq: (column: string, value: any) => ({
          single: async () => {
            const items = this.mockData[table] || []
            const item = items.find(i => i[column] === value)
            return { data: item || null, error: item ? null : { message: 'Not found' } }
          }
        })
      })
    }
  }

  reset() {
    this.mockData = {}
  }
}
```

### Integration Testing Edge Functions

```javascript
// tests/edge-functions.test.js
import { createClient } from '@supabase/supabase-js'

describe('Edge Functions Integration', () => {
  const supabase = createClient(
    process.env.SUPABASE_URL,
    process.env.SUPABASE_ANON_KEY
  )

  test('hello function creates database record', async () => {
    const { data, error } = await supabase.functions.invoke('hello', {
      body: { name: 'Test User' }
    })

    expect(error).toBeNull()
    expect(data.message).toBe('Hello, Test User!')

    // Verify database record
    const { data: greeting } = await supabase
      .from('greetings')
      .select()
      .eq('name', 'Test User')
      .single()

    expect(greeting).not.toBeNull()
    expect(greeting.message).toBe('Hello, Test User!')

    // Cleanup
    await supabase.from('greetings').delete().eq('name', 'Test User')
  })

  test('authenticated function requires auth', async () => {
    const anonClient = createClient(
      process.env.SUPABASE_URL,
      process.env.SUPABASE_ANON_KEY
    )

    const { error } = await anonClient.functions.invoke('protected-function')

    expect(error).not.toBeNull()
    expect(error.message).toContain('auth')
  })
})
```

### Testing Edge Function Authorization

```typescript
// supabase/functions/protected/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const authHeader = req.headers.get('Authorization')
  if (!authHeader) {
    return new Response(
      JSON.stringify({ error: 'Authorization required' }),
      { status: 401, headers: { 'Content-Type': 'application/json' } }
    )
  }

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    {
      global: {
        headers: { Authorization: authHeader }
      }
    }
  )

  const { data: { user }, error } = await supabase.auth.getUser()

  if (error || !user) {
    return new Response(
      JSON.stringify({ error: 'Invalid token' }),
      { status: 401, headers: { 'Content-Type': 'application/json' } }
    )
  }

  return new Response(
    JSON.stringify({ message: `Hello, ${user.email}!` }),
    { headers: { 'Content-Type': 'application/json' } }
  )
})
```

```typescript
// Test with authentication
Deno.test('protected function requires valid JWT', async () => {
  const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)

  // Sign in test user
  const { data: authData } = await supabase.auth.signInWithPassword({
    email: 'test@example.com',
    password: 'testpass123'
  })

  const response = await fetch(`${SUPABASE_URL}/functions/v1/protected`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${authData.session.access_token}`
    }
  })

  assertEquals(response.status, 200)
})
```

### Edge Function CI/CD

```yaml
# .github/workflows/edge-functions.yml
name: Edge Functions Tests

on:
  push:
    paths:
      - 'supabase/functions/**'

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Deno
        uses: denoland/setup-deno@v1
        with:
          deno-version: v1.x

      - name: Setup Supabase CLI
        uses: supabase/setup-cli@v1

      - name: Start Supabase
        run: supabase start

      - name: Run Edge Function tests
        run: |
          for func in supabase/functions/*/index.test.ts; do
            deno test --allow-all "$func"
          done

      - name: Deploy Edge Functions
        if: github.ref == 'refs/heads/main'
        run: |
          supabase functions deploy
        env:
          SUPABASE_ACCESS_TOKEN: ${{ secrets.SUPABASE_ACCESS_TOKEN }}
          SUPABASE_PROJECT_ID: ${{ secrets.SUPABASE_PROJECT_ID }}
```

**Key Points:**

- Unit tests validate database functions using pgTAP in PostgreSQL or Jest/Vitest in JavaScript
- RLS policy testing requires creating authenticated test clients and verifying access controls across different user contexts
- Integration tests verify complete workflows including database operations, authentication, and real-time features
- Mocking the Supabase client enables fast unit tests without database dependencies
- Dedicated test databases with Docker or Supabase CLI provide isolation from production environments
- Seed data through SQL files, JavaScript functions, or factory patterns ensures consistent test fixtures
- CI/CD pipelines automate test execution on GitHub Actions, GitLab CI, or CircleCI
- Edge Functions require Deno-based testing with local serving and deployment validation

**Important subtopics to explore:**

- Performance testing and load testing strategies
- Visual regression testing for UI components
- Contract testing for API boundaries
- Snapshot testing for data structures
- Test coverage analysis and reporting
- Security testing and penetration testing approaches

---

