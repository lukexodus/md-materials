## Invoking Functions from Client


Client applications call Edge Functions through HTTP requests to their unique endpoints. Supabase provides client libraries with built-in methods for simplified invocation.

**Using JavaScript client:**

```typescript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY)

const { data, error } = await supabase.functions.invoke('function-name', {
  body: { name: 'User' }
})
```

The `invoke` method handles authentication automatically, passing the user's JWT token in request headers when users are authenticated. This allows functions to verify user identity and enforce authorization rules.

**Direct HTTP requests:**

Functions accept standard HTTP requests from any client capable of making fetch calls:

```typescript
const response = await fetch(
  'https://your-project-ref.supabase.co/functions/v1/function-name',
  {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${ANON_KEY}`
    },
    body: JSON.stringify({ name: 'User' })
  }
)

const data = await response.json()
```

**Authentication and authorization:**

Include the `Authorization` header with either the anon key (for public access) or a user's JWT token (for authenticated requests). Functions can extract user information from the JWT to implement authorization logic.

**Request customization:**

Pass custom headers, query parameters, and request bodies based on your function's requirements:

```typescript
const { data, error } = await supabase.functions.invoke('function-name', {
  body: { key: 'value' },
  headers: { 'X-Custom-Header': 'value' },
  method: 'POST'
})
```

**Response handling:**

Functions return standard HTTP responses. The client library parses JSON responses automatically. Handle errors by checking the error object or response status codes:

```typescript
const { data, error } = await supabase.functions.invoke('function-name')

if (error) {
  console.error('Function error:', error.message)
  return
}

console.log('Function result:', data)
```

**Example with error handling:**

```typescript
try {
  const { data, error } = await supabase.functions.invoke('process-payment', {
    body: {
      amount: 1000,
      currency: 'USD'
    }
  })
  
  if (error) throw error
  
  console.log('Payment processed:', data.transactionId)
} catch (err) {
  console.error('Payment failed:', err.message)
}
```

