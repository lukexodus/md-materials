## CORS Handling


Cross-Origin Resource Sharing (CORS) controls which web applications can call your Edge Functions. Proper CORS configuration is essential for browser-based clients.

**Default CORS behavior:**

Edge Functions do not automatically handle CORS. Browsers block requests from different origins unless the function explicitly allows them through response headers.

**Implementing CORS:**

Add CORS headers to function responses manually:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  // Process actual request
  const data = { message: 'Success' }
  
  return new Response(
    JSON.stringify(data),
    { 
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200 
    }
  )
})
```

**Preflight requests:**

Browsers send OPTIONS requests before actual requests for cross-origin calls. Functions must respond to OPTIONS requests with appropriate CORS headers and a 200 status code.

**Restrictive CORS:**

For production environments, specify exact origins instead of wildcards:

```typescript
const corsHeaders = {
  'Access-Control-Allow-Origin': 'https://yourdomain.com',
  'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
  'Access-Control-Allow-Headers': 'authorization, content-type',
  'Access-Control-Max-Age': '86400', // Cache preflight for 24 hours
}
```

**Credentials and authentication:**

When using credentials (cookies, authorization headers), set `Access-Control-Allow-Credentials: true` and specify an exact origin (wildcards not allowed with credentials):

```typescript
const corsHeaders = {
  'Access-Control-Allow-Origin': 'https://app.yourdomain.com',
  'Access-Control-Allow-Credentials': 'true',
  'Access-Control-Allow-Headers': 'authorization, content-type',
}
```

**Helper function for CORS:**

```typescript
function corsResponse(data: any, status = 200) {
  return new Response(
    JSON.stringify(data),
    {
      status,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
        'Content-Type': 'application/json',
      }
    }
  )
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return corsResponse('ok')
  }
  
  const result = { success: true }
  return corsResponse(result)
})
```

