## Function Secrets and Environment Variables


Edge Functions access configuration and sensitive data through environment variables, which are managed separately from code for security and flexibility.

**Setting environment variables:**

Variables are configured using the Supabase CLI or dashboard. Secrets like API keys should never be committed to code. Use the command `supabase secrets set SECRET_NAME=value` to configure secrets for your functions.

**Accessing variables in functions:**

Environment variables are available through `Deno.env.get()`:

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  const apiKey = Deno.env.get('THIRD_PARTY_API_KEY')
  
  if (!apiKey) {
    return new Response('Configuration error', { status: 500 })
  }
  
  // Use the API key
  const response = await fetch('https://api.example.com/data', {
    headers: { 'Authorization': `Bearer ${apiKey}` }
  })
  
  return response
})
```

**Built-in environment variables:**

Supabase automatically provides several environment variables to functions:

- `SUPABASE_URL`: Your project's API URL
- `SUPABASE_ANON_KEY`: Public anonymous key for client requests
- `SUPABASE_SERVICE_ROLE_KEY`: Service role key with full database access (use carefully)

**Security considerations:**

Service role keys bypass Row Level Security policies and should only be used for administrative operations. Never expose service role keys to clients. Use the anon key for client-facing operations and rely on RLS policies for security.

**Local development:**

Create a `.env` file in your project root for local testing. The Supabase CLI loads these variables when running functions locally with `supabase functions serve`:

```
THIRD_PARTY_API_KEY=your-dev-api-key
CUSTOM_CONFIG=value
```

**Example with multiple secrets:**

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  const stripeKey = Deno.env.get('STRIPE_SECRET_KEY')
  const webhookSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET')
  const sendgridKey = Deno.env.get('SENDGRID_API_KEY')
  
  // Verify all required secrets are present
  if (!stripeKey || !webhookSecret || !sendgridKey) {
    return new Response('Missing required configuration', { status: 500 })
  }
  
  // Use secrets for operations
})
```

