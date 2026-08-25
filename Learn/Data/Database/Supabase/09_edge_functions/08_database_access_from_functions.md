## Database Access from Functions


Edge Functions access your Supabase Postgres database through the Supabase JavaScript client, with full support for queries, mutations, and real-time subscriptions.

**Initializing the database client:**

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabaseClient = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    { global: { headers: { Authorization: req.headers.get('Authorization')! } } }
  )
  
  // Query database
  const { data, error } = await supabaseClient
    .from('users')
    .select('*')
    .limit(10)
  
  return new Response(JSON.stringify(data))
})
```

**Using service role for admin operations:**

For operations requiring elevated privileges (bypassing RLS), use the service role key:

```typescript
const supabaseAdmin = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
)

// This bypasses RLS policies
const { data, error } = await supabaseAdmin
  .from('private_data')
  .select('*')
```

**Respecting user context:**

Pass the user's authorization token to respect Row Level Security policies:

```typescript
const authHeader = req.headers.get('Authorization')
const supabaseClient = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_ANON_KEY') ?? '',
  { global: { headers: { Authorization: authHeader! } } }
)

// Queries respect RLS policies based on the authenticated user
const { data } = await supabaseClient
  .from('user_data')
  .select('*')
```

**Complex database operations:**

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )
  
  // Insert with related data
  const { data: order, error } = await supabase
    .from('orders')
    .insert({
      customer_id: 123,
      total: 99.99,
      status: 'pending'
    })
    .select()
    .single()
  
  if (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 400 })
  }
  
  // Insert order items
  await supabase
    .from('order_items')
    .insert([
      { order_id: order.id, product_id: 1, quantity: 2 },
      { order_id: order.id, product_id: 3, quantity: 1 }
    ])
  
  return new Response(JSON.stringify({ order }))
})
```

**Calling Postgres functions:**

Execute stored procedures or custom SQL functions:

```typescript
const { data, error } = await supabaseClient
  .rpc('calculate_order_total', { order_id: 123 })

if (error) {
  return new Response(JSON.stringify({ error: error.message }), { status: 500 })
}

return new Response(JSON.stringify({ total: data }))
```

**Transaction handling:**

[Inference] Edge Functions can execute multiple database operations atomically by using Postgres stored procedures that implement transaction logic, as the JavaScript client doesn't provide explicit transaction APIs.

