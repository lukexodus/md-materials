## Function Runtime and Environment


Edge Functions execute in the Deno runtime, providing a secure, modern JavaScript/TypeScript environment with specific capabilities and constraints.

**Runtime specifications:**

- **Language support**: Native TypeScript and JavaScript (ES2022+) without transpilation requirements
- **V8 isolates**: Each invocation runs in an isolated V8 environment preventing cross-contamination
- **Execution limits**: Default timeout of 150 seconds per invocation; configurable resource limits for memory and CPU
- **Standard APIs**: Full support for Web APIs including fetch, Request, Response, Headers, URL, crypto, and streams

**Deno-specific features:**

Deno's security model requires explicit permissions for file system, network, and environment access. Edge Functions run with pre-configured permissions appropriate for serverless execution. The runtime does not support Node.js built-in modules directly; use Deno-compatible alternatives or npm specifiers.

Import maps can configure module resolution, though Edge Functions typically use direct URL imports for dependencies. Version pinning in imports ensures reproducible builds.

**Environment characteristics:**

Functions are stateless between invocations. Each request starts with a clean execution context. Persistent data must be stored in databases, storage buckets, or external services. Global variables reset between invocations and cannot reliably share state.

Cold starts occur when a function hasn't been invoked recently in a specific region. Warm invocations reuse existing isolates for faster execution. [Inference] The platform likely optimizes for minimal cold start times through V8 isolate pooling.

**Supported Web Standards:**

- Fetch API for HTTP requests
- Streams API for processing large data
- Web Crypto API for cryptographic operations
- TextEncoder/TextDecoder for text processing
- URLPattern for route matching
- AbortController for cancellation

**Example using Web Standards:**

```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  // Using Web Crypto API
  const data = new TextEncoder().encode("sensitive data")
  const hashBuffer = await crypto.subtle.digest("SHA-256", data)
  const hash = Array.from(new Uint8Array(hashBuffer))
    .map(b => b.toString(16).padStart(2, '0'))
    .join('')
  
  return new Response(JSON.stringify({ hash }))
})
```

