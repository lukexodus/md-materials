## Secrets Management

---

### What Secrets Management Means in tRPC Projects

Secrets management covers how sensitive configuration values — database connection strings, API keys, signing secrets, third-party credentials — are stored, accessed, rotated, and kept out of source control. tRPC projects are Node.js applications and inherit the same secrets management concerns as any backend service.

**Key Points:**
- tRPC has no involvement in secrets management; this is an application and infrastructure concern
- Secrets are consumed in `createContext`, router initialization, service clients, and middleware — the places where external dependencies are configured
- The risk is not specific to tRPC; it applies to any server-side Node.js project

---

### The Environment Variable Baseline

The standard baseline for secrets in Node.js is environment variables. Secrets are set in the process environment and read via `process.env` at runtime. They are never committed to source control.

```typescript
// db.ts
import { PrismaClient } from '@prisma/client';

const connectionString = process.env.DATABASE_URL;
if (!connectionString) {
  throw new Error('DATABASE_URL is not set');
}

export const prisma = new PrismaClient({
  datasources: { db: { url: connectionString } },
});
```

**Key Points:**
- Failing fast on missing environment variables (throwing at startup rather than at first use) surfaces misconfiguration immediately
- `process.env` values are always strings or `undefined`; type coercion and validation are the application's responsibility
- Environment variables are visible to all code in the process; they do not provide isolation between modules

---

### Validating Environment Variables at Startup

Accessing `process.env` values ad hoc throughout the codebase makes it easy to miss a missing or malformed variable until the relevant code path is exercised. A dedicated environment validation module, run at startup, catches all issues at once.

```typescript
// env.ts
import { z } from 'zod';

const envSchema = z.object({
  DATABASE_URL: z.string().url(),
  JWT_SECRET: z.string().min(32),
  STRIPE_SECRET_KEY: z.string().startsWith('sk_'),
  SENDGRID_API_KEY: z.string().startsWith('SG.'),
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.coerce.number().int().min(1).max(65535).default(3000),
});

const result = envSchema.safeParse(process.env);

if (!result.success) {
  console.error('Invalid environment configuration:');
  console.error(result.error.flatten().fieldErrors);
  process.exit(1);
}

export const env = result.data;
```

```typescript
// Usage elsewhere — no direct process.env access
import { env } from './env';

const stripe = new Stripe(env.STRIPE_SECRET_KEY);
```

**Key Points:**
- `z.coerce.number()` handles the string-to-number conversion that `process.env` requires
- `process.exit(1)` at startup prevents the application from running in a misconfigured state
- All `process.env` access is centralized in one module; the rest of the codebase uses `env.*`
- [Inference] Centralizing environment access makes it easier to audit what secrets the application consumes, though this depends on the team enforcing the pattern consistently

---

### `.env` Files: Development Only

`.env` files (loaded by libraries such as `dotenv` or framework-native loaders) are a development convenience. They must not be used as the secrets mechanism in production.

```bash
# .env.local — development only, never committed
DATABASE_URL=postgresql://user:password@localhost:5432/mydb
JWT_SECRET=dev-secret-not-for-production-use
STRIPE_SECRET_KEY=sk_test_abc123
```

```typescript
// Load .env in development entry point only
import 'dotenv/config';
import { env } from './env';
```

**.gitignore:**
```
.env
.env.local
.env.*.local
```

**Key Points:**
- `.env.example` (with placeholder values, no real secrets) should be committed as documentation
- `.env` files containing real secrets must be in `.gitignore`
- In production, environment variables are injected by the deployment platform (e.g., Vercel, Railway, Fly.io, Kubernetes), not by `.env` files
- [Inference] Accidentally committing a `.env` file is a common source of credential exposure; secret scanning tools in CI pipelines can help detect this before it reaches the repository — effectiveness depends on tool configuration

---

### Secret Scanning and Leak Prevention

Secrets that appear in source control, logs, or error messages represent a significant exposure risk.

**In source control — use pre-commit hooks:**
```bash
# Install git-secrets or trufflehog as a pre-commit hook
# Example using lefthook
# lefthook.yml
pre-commit:
  commands:
    secret-scan:
      run: trufflehog filesystem --directory=. --only-verified
```

**In logs — never log secret values:**
```typescript
// Problematic
console.log('Connecting with key:', process.env.STRIPE_SECRET_KEY);

// Safe — log presence, not value
console.log('Stripe key present:', !!env.STRIPE_SECRET_KEY);
```

**In error messages — sanitize before surfacing:**
```typescript
export const appRouter = router({
  // ...
});

// tRPC error formatter — strip internal details in production
const t = initTRPC.context<Context>().create({
  errorFormatter({ shape, error }) {
    return {
      ...shape,
      data: {
        ...shape.data,
        // Do not expose stack traces or internal messages in production
        stack: env.NODE_ENV === 'development' ? error.stack : undefined,
      },
    };
  },
});
```

**Key Points:**
- Stack traces may contain file paths, variable names, or configuration details that reveal internal structure
- tRPC's error formatter is the appropriate place to control what error detail reaches clients
- [Inference] Logging frameworks with redaction support (e.g., `pino` with redact paths) can systematically prevent specific fields from appearing in logs — behavior depends on configuration

---

### Secrets in the tRPC Context

The context factory is a common place where secrets are used — to verify tokens, initialize clients, or look up credentials. Secrets should be consumed here through the validated `env` module, not accessed directly from `process.env`.

```typescript
// server/context.ts
import { env } from '../env';
import { verifyJwt } from '../lib/jwt';

export async function createContext({ req }: CreateExpressContextOptions) {
  const authHeader = req.headers.authorization;
  const token = authHeader?.split(' ')[1];

  if (!token) return { user: null };

  try {
    const payload = verifyJwt(token, env.JWT_SECRET);
    return { user: payload };
  } catch {
    return { user: null };
  }
}
```

**Key Points:**
- `env.JWT_SECRET` is validated at startup; by the time `createContext` runs, its presence and format are guaranteed by the schema
- The secret is used to verify a token — it is never returned from the context or exposed to procedure logic directly
- [Inference] Passing raw secret values through the context object (e.g., `return { jwtSecret: env.JWT_SECRET }`) is an anti-pattern; secrets should be consumed in utility functions, not threaded through the application

---

### External Secrets Managers

For production environments with elevated security requirements, secrets are stored in a dedicated secrets manager rather than as environment variables set directly on the host. The application fetches secrets at startup or on demand.

**AWS Secrets Manager example:**
```typescript
import {
  SecretsManagerClient,
  GetSecretValueCommand,
} from '@aws-sdk/client-secrets-manager';

const client = new SecretsManagerClient({ region: 'us-east-1' });

export async function getSecret(secretName: string): Promise<string> {
  const command = new GetSecretValueCommand({ SecretId: secretName });
  const response = await client.send(command);

  if (!response.SecretString) {
    throw new Error(`Secret ${secretName} has no string value`);
  }

  return response.SecretString;
}
```

```typescript
// server/index.ts — fetch secrets before starting the server
const dbUrl = await getSecret('prod/myapp/database-url');
const jwtSecret = await getSecret('prod/myapp/jwt-secret');

// Inject into process.env or pass directly to consumers
process.env.DATABASE_URL = dbUrl;
process.env.JWT_SECRET = jwtSecret;

// Now validate and start
const { env } = await import('./env');
await startServer(env);
```

**Key Points:**
- Secrets managers provide access logging, rotation automation, and fine-grained IAM policies
- The application's IAM role determines which secrets it can access — no credentials are hardcoded
- [Inference] Fetching secrets at startup introduces a startup dependency on the secrets manager; if the service is unavailable, the application will not start — this trade-off is generally acceptable for the security benefits, but depends on infrastructure reliability requirements
- Specific behavior and API details vary by provider (AWS, GCP Secret Manager, HashiCorp Vault, Azure Key Vault)

---

### Secret Rotation

Secrets should be rotatable without requiring application redeployment where possible. The two main strategies are restart-based rotation and live rotation.

**Restart-based rotation:**
```
1. Generate new secret value in secrets manager
2. Update environment variable in deployment platform
3. Redeploy or restart the application
4. Old secret is no longer valid
```

**Live rotation (for API keys with grace periods):**
```typescript
// Support both current and previous secret during rotation window
const validSecrets = [env.JWT_SECRET, env.JWT_SECRET_PREVIOUS].filter(Boolean);

export function verifyJwtWithRotation(token: string): JwtPayload {
  for (const secret of validSecrets) {
    try {
      return verifyJwt(token, secret);
    } catch {
      continue;
    }
  }
  throw new Error('Token verification failed');
}
```

**Key Points:**
- Live rotation requires the application to accept tokens signed with either the current or the previous secret during a transition window
- `JWT_SECRET_PREVIOUS` is set during rotation and removed after all existing tokens have expired or been reissued
- [Inference] The rotation window duration should be at least as long as the token TTL to avoid invalidating tokens issued just before rotation — the appropriate duration depends on token expiry configuration
- Behavior of token verification during rotation depends on correct implementation; this is not guaranteed by any framework

---

### Secrets in Serverless and Edge Environments

In serverless deployments (Vercel, AWS Lambda, Cloudflare Workers), the secrets management model differs from long-running servers.

**Key Points:**
- Environment variables are set in the platform's deployment configuration, not in files
- Secrets fetched from external managers at cold start add latency to cold starts; caching the fetched value in module scope reduces this for warm invocations
- Cloudflare Workers uses a separate secrets system (`wrangler secret put`) rather than standard environment variables; access is through a bindings API rather than `process.env`
- [Inference] Edge runtimes may have restrictions on which Node.js APIs are available, which can affect which secrets management SDKs are compatible — verify SDK compatibility against the target runtime before adopting

```typescript
// Vercel / Lambda — environment variables set in platform config
// Accessed the same way as standard Node.js
import { env } from './env';

export const appRouter = router({
  ping: publicProcedure.query(() => ({
    db: !!env.DATABASE_URL,
    stripe: !!env.STRIPE_SECRET_KEY,
  })),
});
```

---

### What Must Never Appear in Client Bundles

In full-stack frameworks (Next.js, SvelteKit, Nuxt), a common mistake is importing server-side secrets into code that is bundled for the client.

**Problematic — importing server env in a shared file:**
```typescript
// lib/config.ts — imported by both server and client code
export const stripeKey = process.env.STRIPE_SECRET_KEY; // exposed in client bundle
```

**Safe — server-only module:**
```typescript
// server/env.ts — only imported in server-side code
import 'server-only'; // Next.js package that throws if imported client-side
export { env } from '../env';
```

**Key Points:**
- Next.js exposes only variables prefixed with `NEXT_PUBLIC_` to the client bundle; unprefixed variables are server-only
- The `server-only` package causes a build error if a server module is accidentally imported in client code
- tRPC server code (routers, context, middleware) runs server-side only and should never be imported into client components
- [Inference] The separation between server and client modules must be maintained deliberately; build tooling can catch some violations but not all — code review and module boundary discipline are also necessary

---

### Summary of Practices

| Practice | Purpose |
|---|---|
| Validate all env vars at startup with Zod | Catch misconfiguration before runtime |
| Centralize `process.env` access in one module | Auditable, no scattered raw access |
| Never commit `.env` files with real values | Prevent credential exposure in source control |
| Use secret scanning in CI | Detect accidental commits before they merge |
| Strip stack traces in production error responses | Prevent internal detail leakage via tRPC errors |
| Use secrets managers in production | Rotation, access logging, IAM-based access control |
| Mark server modules as server-only | Prevent secrets leaking into client bundles |
| Never log secret values | Prevent exposure in log aggregation systems |

---

**Conclusion**

Secrets management in tRPC projects follows the same principles as any Node.js backend: validate environment variables at startup, centralize their access, keep them out of source control and client bundles, and use dedicated secrets managers in production. tRPC's surface area intersects with secrets management primarily at the context factory, error formatter, and middleware layer — the places where credentials are verified and where care must be taken not to surface sensitive values in responses or logs. None of these protections are automatic; each requires deliberate implementation.