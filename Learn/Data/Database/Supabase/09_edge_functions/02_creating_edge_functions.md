## Creating Edge Functions


Edge Functions are created using the Supabase CLI. Each function exists as a TypeScript file in your project's `supabase/functions` directory with a specific structure that exports a default handler.

**Basic function structure:**

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  const { name } = await req.json()
  const data = {
    message: `Hello ${name}!`,
  }

  return new Response(
    JSON.stringify(data),
    { headers: { "Content-Type": "application/json" } },
  )
})
```

**Creation process:**

Create a new function using the CLI command `supabase functions new function-name`. This generates a directory structure with a default index.ts file. The function name becomes part of its URL endpoint and should use kebab-case naming.

Functions must export a handler that accepts a Request object and returns a Response object, following the standard Fetch API specification. This handler processes incoming HTTP requests and generates appropriate responses.

**Function organization:**

- Each function resides in `supabase/functions/[function-name]/index.ts`
- Shared code can be placed in `supabase/functions/_shared/` for imports across multiple functions
- Local dependencies use relative imports with `.ts` extensions
- External dependencies import from URLs (Deno-style) with version pinning

**Example with multiple operations:**

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  const { method } = req
  const url = new URL(req.url)
  
  if (method === "GET") {
    return new Response(JSON.stringify({ status: "active" }))
  }
  
  if (method === "POST") {
    const body = await req.json()
    // Process POST data
    return new Response(JSON.stringify({ received: body }))
  }
  
  return new Response("Method not allowed", { status: 405 })
})
```

