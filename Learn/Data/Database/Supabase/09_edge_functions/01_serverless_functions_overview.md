## Serverless Functions Overview


Edge Functions execute code on-demand without managing servers. They run in isolated environments across multiple geographic regions, automatically scaling based on traffic. Each function operates independently with its own execution context, making them ideal for API endpoints, webhooks, data transformations, and background processing.

The functions use the Deno runtime, which provides native TypeScript support, secure-by-default execution, and Web Standard APIs. Unlike traditional serverless platforms, Edge Functions have minimal cold start times and can access Supabase services directly through pre-configured clients.

**Key characteristics:**

- **Geographic distribution**: Functions deploy to multiple edge locations globally, reducing latency by executing close to users
- **Automatic scaling**: Infrastructure scales from zero to handle millions of requests without configuration
- **Isolated execution**: Each invocation runs in a secure V8 isolate with resource limits and timeout controls
- **Native integrations**: Direct access to Supabase Auth, Database, Storage, and other services through environment variables
- **Standards-based**: Uses standard Web APIs (fetch, Request, Response) for compatibility and portability

