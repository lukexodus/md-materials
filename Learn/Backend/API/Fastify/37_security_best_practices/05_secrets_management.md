## Secrets Management

Secrets are credentials, tokens, keys, and other values that grant access to protected resources — database connection strings, API keys, JWT signing secrets, OAuth client secrets, encryption keys, and similar. In a Fastify application, secrets are consumed during plugin registration, route handlers, and service integrations. How they are sourced, stored, accessed, and rotated determines the blast radius of a compromise. This document covers the full lifecycle of secrets in a Fastify deployment context.

---

### What Counts as a Secret

Before establishing practices, the scope must be clear:

| Value type | Secret? | Notes |
|---|---|---|
| Database connection string | Yes | Contains credentials |
| JWT signing secret | Yes | Compromise allows token forgery |
| OAuth client secret | Yes | Grants OAuth flow initiation |
| API keys (third-party services) | Yes | Stripe, SendGrid, AWS, etc. |
| Encryption keys | Yes | AES keys, RSA private keys |
| Session secret | Yes | Compromise allows session forgery |
| TLS private key | Yes | Compromise allows traffic decryption |
| Database hostname only | No | Not a credential; not sensitive |
| `NODE_ENV` value | No | Configuration, not a secret |
| Feature flags | No | Configuration, not a secret |
| Public keys / certificates | No | Designed to be distributed |

[Inference] The line between configuration and secret is: if the value grants access to a resource or the ability to forge an identity, it is a secret. If it is lost or exposed, treating it as configuration creates unnecessary risk — treat it as a secret.

---

### The Fundamental Rule — Secrets Never in Source Code

Hardcoded secrets in source code are the most common and highest-impact secrets management failure. Version control history is permanent — a secret committed and later removed remains in the history and must be considered compromised.

```typescript
// Never do this
const fastify = Fastify()
await fastify.register(fastifyJwt, {
  secret: 'my-super-secret-key-hardcoded' // committed to git — compromised
})

// Correct — sourced from environment
await fastify.register(fastifyJwt, {
  secret: process.env.JWT_SECRET!
})
```

**Key Points:**
- Git history is not private even in private repositories — repository access changes over time.
- Secrets in source code are frequently exposed via accidental public repository creation, screenshot sharing, log output, and error reporting tools.
- If a secret is ever committed, rotate it immediately — removing the commit is insufficient on its own because forks, clones, and CI caches may retain the history.

---

### Environment Variables — The Baseline Approach

Environment variables are the minimum viable secrets sourcing mechanism. They decouple secrets from code and are supported by every deployment platform.

```typescript
// src/config.ts — centralize env var access and validation
import { FastifyInstance } from 'fastify'

export interface AppConfig {
  jwtSecret:        string
  databaseUrl:      string
  redisUrl:         string
  stripeSecretKey:  string
  sessionSecret:    string
  nodeEnv:          'development' | 'test' | 'production'
  port:             number
}

export function loadConfig(): AppConfig {
  const required = [
    'JWT_SECRET',
    'DATABASE_URL',
    'REDIS_URL',
    'STRIPE_SECRET_KEY',
    'SESSION_SECRET'
  ]

  const missing = required.filter(key => !process.env[key])
  if (missing.length > 0) {
    throw new Error(`Missing required environment variables: ${missing.join(', ')}`)
  }

  return {
    jwtSecret:       process.env.JWT_SECRET!,
    databaseUrl:     process.env.DATABASE_URL!,
    redisUrl:        process.env.REDIS_URL!,
    stripeSecretKey: process.env.STRIPE_SECRET_KEY!,
    sessionSecret:   process.env.SESSION_SECRET!,
    nodeEnv:         (process.env.NODE_ENV as AppConfig['nodeEnv']) ?? 'development',
    port:            parseInt(process.env.PORT ?? '3000', 10)
  }
}
```

**Registration with validated config:**

```typescript
import Fastify from 'fastify'
import { loadConfig } from './config'

const config = loadConfig() // throws on startup if required vars missing
const fastify = Fastify({ logger: { level: config.nodeEnv === 'production' ? 'info' : 'debug' } })

await fastify.register(fastifyJwt, { secret: config.jwtSecret })
await fastify.register(fastifyPostgres, { connectionString: config.databaseUrl })
```

**Key Points:**
- Validating required env vars at startup (not lazily at first use) causes the application to fail fast with a clear error message rather than failing at request time with a confusing undefined-related error.
- Centralizing env var access in a single config module makes the full set of required secrets visible in one place.
- [Inference] Accessing `process.env` scattered throughout the codebase makes it harder to audit what secrets the application requires and easier to miss validation.

---

### `.env` Files — Local Development Only

`.env` files are a development convenience. They are not a secrets management solution for production.

```bash
# .env — local development only
JWT_SECRET=local-dev-secret-not-real
DATABASE_URL=postgres://user:password@localhost:5432/myapp_dev
REDIS_URL=redis://localhost:6379
STRIPE_SECRET_KEY=sk_test_xxxxxxxxxxxx
SESSION_SECRET=local-session-secret
```

```bash
# .gitignore — always ignore .env files
.env
.env.local
.env.*.local
.env.production  # especially this one
```

```typescript
// Load .env in development — do not load in production
if (process.env.NODE_ENV !== 'production') {
  const { config } = await import('dotenv')
  config()
}
```

**Key Points:**
- `.env` files must be in `.gitignore` — committed `.env` files are one of the most common secret exposure vectors.
- Use `.env.example` (committed, no real values) as documentation of required variables.
- In production, secrets come from a secrets manager or platform-injected environment variables — not a `.env` file on disk.
- [Inference] A `.env` file on a production server is an unencrypted secrets store on the filesystem — it is readable by any process running as the same user, visible in process listings on some platforms, and may be captured in deployment artifacts.

---

### Schema Validation for Environment Variables — `env-schema`

Fastify's ecosystem includes `env-schema`, which applies Ajv JSON Schema validation to environment variables:

```bash
npm install env-schema @sinclair/typebox
```

```typescript
import envSchema from 'env-schema'
import { Type, Static } from '@sinclair/typebox'

const EnvSchema = Type.Object({
  NODE_ENV:          Type.Union([
                       Type.Literal('development'),
                       Type.Literal('test'),
                       Type.Literal('production')
                     ]),
  PORT:              Type.Integer({ default: 3000, minimum: 1, maximum: 65535 }),
  JWT_SECRET:        Type.String({ minLength: 32 }),
  DATABASE_URL:      Type.String({ minLength: 1 }),
  REDIS_URL:         Type.String({ minLength: 1 }),
  SESSION_SECRET:    Type.String({ minLength: 32 }),
  STRIPE_SECRET_KEY: Type.String({ pattern: '^sk_(test|live)_' })
})

type Env = Static<typeof EnvSchema>

const env = envSchema<Env>({
  schema: EnvSchema,
  dotenv: process.env.NODE_ENV !== 'production'
})

// env is fully typed and validated
console.log(env.PORT)         // number
console.log(env.JWT_SECRET)   // string, guaranteed minLength 32
```

**Key Points:**
- `minLength: 32` on secrets enforces a minimum entropy floor — a secret shorter than 32 characters fails validation at startup.
- The `pattern` constraint on `STRIPE_SECRET_KEY` verifies the expected format, catching environment misconfiguration (e.g., a test key used in production or vice versa).
- `dotenv: true` loads `.env` automatically in development — set conditionally on `NODE_ENV`.
- [Inference] Schema-validating env vars at startup catches misconfiguration before the application serves any traffic — the same principle as failing fast on missing required vars.

---

### Fastify Plugin for Config — Decorating the Instance

Expose validated config via a Fastify decorator so it is accessible in route handlers and plugins without importing the config module directly:

```typescript
import fp from 'fastify-plugin'
import envSchema from 'env-schema'
import { Type, Static } from '@sinclair/typebox'
import { FastifyInstance } from 'fastify'

const EnvSchema = Type.Object({
  JWT_SECRET:   Type.String({ minLength: 32 }),
  DATABASE_URL: Type.String({ minLength: 1 }),
  NODE_ENV:     Type.String({ default: 'development' })
})

type Env = Static<typeof EnvSchema>

declare module 'fastify' {
  interface FastifyInstance {
    config: Env
  }
}

async function configPlugin(fastify: FastifyInstance) {
  const env = envSchema<Env>({
    schema: EnvSchema,
    dotenv: process.env.NODE_ENV !== 'production'
  })

  fastify.decorate('config', env)
}

export default fp(configPlugin)
```

```typescript
// In a route plugin
fastify.get('/debug/config-check', async (request, reply) => {
  // Access via fastify.config — never expose secrets in responses
  const isJwtConfigured = fastify.config.JWT_SECRET.length >= 32
  return { jwtConfigured: isJwtConfigured }
})
```

---

### AWS Secrets Manager Integration

For production deployments on AWS, secrets are stored in AWS Secrets Manager and fetched at application startup or on demand. Credentials to access Secrets Manager are provided via IAM roles — not via hardcoded access keys.

```bash
npm install @aws-sdk/client-secrets-manager
```

```typescript
import {
  SecretsManagerClient,
  GetSecretValueCommand
} from '@aws-sdk/client-secrets-manager'

const client = new SecretsManagerClient({ region: process.env.AWS_REGION ?? 'us-east-1' })

interface AppSecrets {
  jwtSecret:       string
  databaseUrl:     string
  stripeSecretKey: string
}

async function fetchSecrets(secretName: string): Promise<AppSecrets> {
  const command = new GetSecretValueCommand({ SecretId: secretName })
  const response = await client.send(command)

  if (!response.SecretString) {
    throw new Error(`Secret ${secretName} has no string value`)
  }

  const parsed = JSON.parse(response.SecretString) as AppSecrets

  // Validate expected keys are present
  const required: (keyof AppSecrets)[] = ['jwtSecret', 'databaseUrl', 'stripeSecretKey']
  const missing = required.filter(k => !parsed[k])
  if (missing.length > 0) {
    throw new Error(`Secret ${secretName} missing keys: ${missing.join(', ')}`)
  }

  return parsed
}

// In app bootstrap
const secrets = await fetchSecrets(process.env.SECRET_NAME ?? 'myapp/production')

const fastify = Fastify({ logger: true })

await fastify.register(fastifyJwt, { secret: secrets.jwtSecret })
await fastify.register(fastifyPostgres, { connectionString: secrets.databaseUrl })
```

**Key Points:**
- The IAM role attached to the EC2 instance, ECS task, or Lambda function grants permission to call `GetSecretValue` — no AWS access keys are needed in the application code or environment.
- Secrets are fetched once at startup and held in memory — not re-fetched on every request.
- Rotation: AWS Secrets Manager supports automatic rotation. When a secret rotates, the application must either restart to pick up the new value or implement on-demand re-fetching with cache invalidation.
- [Unverified] Specific IAM policy syntax and rotation Lambda integration details — verify against current AWS documentation.

---

### HashiCorp Vault Integration

Vault is a platform-agnostic secrets manager commonly used in Kubernetes and multi-cloud environments.

```bash
npm install node-vault
```

```typescript
import vault from 'node-vault'

interface VaultSecrets {
  jwt_secret:        string
  database_url:      string
  stripe_secret_key: string
}

async function fetchVaultSecrets(): Promise<VaultSecrets> {
  const client = vault({
    apiVersion: 'v1',
    endpoint: process.env.VAULT_ADDR ?? 'http://127.0.0.1:8200',
    token: process.env.VAULT_TOKEN // in production, use AppRole or Kubernetes auth
  })

  const result = await client.read('secret/data/myapp/production')
  return result.data.data as VaultSecrets
}

const secrets = await fetchVaultSecrets()
```

**Kubernetes auth (preferred over token auth in production):**

```typescript
import fs from 'fs'

const client = vault({
  apiVersion: 'v1',
  endpoint: process.env.VAULT_ADDR!
})

// Exchange Kubernetes service account JWT for a Vault token
const jwt = fs.readFileSync(
  '/var/run/secrets/kubernetes.io/serviceaccount/token',
  'utf8'
)

const loginResult = await client.kubernetesLogin({
  role: 'myapp-production',
  jwt
})

client.token = loginResult.auth.client_token

const secrets = await client.read('secret/data/myapp/production')
```

**Key Points:**
- Token auth is appropriate for local development. Kubernetes auth or AppRole auth is appropriate for production — no long-lived token stored in the environment.
- [Inference] Vault's lease system means dynamic secrets (e.g., database credentials generated by Vault) have expiry times — the application must handle lease renewal or restart before the lease expires.
- [Unverified] `node-vault` maintenance status and compatibility with current Vault API versions — verify before adopting.

---

### GCP Secret Manager and Azure Key Vault

**GCP Secret Manager:**

```bash
npm install @google-cloud/secret-manager
```

```typescript
import { SecretManagerServiceClient } from '@google-cloud/secret-manager'

const smClient = new SecretManagerServiceClient()

async function getGcpSecret(secretName: string): Promise<string> {
  const [version] = await smClient.accessSecretVersion({ name: secretName })
  return version.payload!.data!.toString()
}

const jwtSecret = await getGcpSecret(
  `projects/${process.env.GCP_PROJECT_ID}/secrets/jwt-secret/versions/latest`
)
```

**Azure Key Vault:**

```bash
npm install @azure/keyvault-secrets @azure/identity
```

```typescript
import { SecretClient } from '@azure/keyvault-secrets'
import { DefaultAzureCredential } from '@azure/identity'

const credential = new DefaultAzureCredential() // uses managed identity in production
const kvClient = new SecretClient(process.env.KEY_VAULT_URL!, credential)

const jwtSecretBundle = await kvClient.getSecret('jwt-secret')
const jwtSecret = jwtSecretBundle.value!
```

**Key Points:**
- GCP uses Workload Identity for IAM-based access in GKE — no credentials needed in the application.
- Azure uses Managed Identity (`DefaultAzureCredential`) — no credentials in the application.
- [Unverified] Specific SDK versions, authentication flow details, and IAM configuration — verify against current GCP and Azure documentation.

---

### Secret Rotation Handling

Static secrets fetched at startup become stale when rotated. Strategies:

**Strategy 1 — Restart on rotation (simplest):**
Configure the secrets manager to trigger a deployment or pod restart on rotation. The new instance fetches the updated secret at startup.

**Strategy 2 — Periodic re-fetch with cache TTL:**

```typescript
interface CachedSecret {
  value:     string
  fetchedAt: number
  ttlMs:     number
}

class SecretCache {
  private cache = new Map<string, CachedSecret>()

  async get(
    secretName: string,
    fetcher: (name: string) => Promise<string>,
    ttlMs = 5 * 60 * 1000 // 5 minutes
  ): Promise<string> {
    const cached = this.cache.get(secretName)
    const now = Date.now()

    if (cached && now - cached.fetchedAt < cached.ttlMs) {
      return cached.value
    }

    const value = await fetcher(secretName)
    this.cache.set(secretName, { value, fetchedAt: now, ttlMs })
    return value
  }

  invalidate(secretName: string): void {
    this.cache.delete(secretName)
  }
}

const secretCache = new SecretCache()

// In a route that needs a fresh secret
const apiKey = await secretCache.get('stripe-api-key', fetchFromSecretsManager)
```

**Strategy 3 — JWT key rotation with multiple accepted keys:**

```typescript
// Accept both old and new signing keys during rotation window
await fastify.register(fastifyJwt, {
  secret: {
    private: newPrivateKey,
    public:  [newPublicKey, oldPublicKey] // accepts tokens signed with either key
  }
})
```

[Inference] Strategy 3 applies specifically to asymmetric JWT configurations — the specifics depend on the `@fastify/jwt` version and configuration. Verify against current plugin documentation.

---

### Preventing Secret Leakage in Logs and Errors

Fastify's Pino logger can inadvertently log secrets if request bodies, headers, or plugin options are serialized:

```typescript
const fastify = Fastify({
  logger: {
    level: 'info',
    redact: {
      paths: [
        'req.headers.authorization',
        'req.headers.cookie',
        'req.body.password',
        'req.body.token',
        'req.body.secret',
        'req.body.creditCard',
        '*.password',
        '*.secret',
        '*.token'
      ],
      censor: '[REDACTED]'
    }
  }
})
```

**Custom serializer to redact sensitive fields:**

```typescript
const fastify = Fastify({
  logger: {
    serializers: {
      req(request) {
        return {
          method:     request.method,
          url:        request.url,
          hostname:   request.hostname,
          remoteAddress: request.ip,
          // Explicitly exclude: headers, body
        }
      }
    }
  }
})
```

**Key Points:**
- Pino's `redact` option uses `fast-redact` internally — paths support wildcard patterns.
- `req.headers.authorization` contains Bearer tokens — always redact.
- `req.headers.cookie` may contain session identifiers — always redact.
- Error messages may contain connection strings if a database connection fails — [Inference] catch database initialization errors and log only the error code or a sanitized message, not the raw error which may contain the connection string including credentials.

---

### Secrets in Fastify Plugin Options

Plugin registration often passes secrets as options. These options may appear in stack traces or debug output:

```typescript
// Risk — secret visible in plugin options object if options are logged
await fastify.register(fastifyPostgres, {
  connectionString: config.databaseUrl // contains username:password
})

// Mitigation — do not log plugin options; configure Pino serializers to exclude them
// The plugin itself should not log its options — verify in the plugin's source
```

[Inference] Official `@fastify/*` plugins generally do not log their options. Third-party plugins may — review the source before registering plugins that receive secrets as options.

---

### CI/CD Secrets Management

Secrets used in CI/CD pipelines (for deployment, integration testing, or build processes) follow the same principles:

**GitHub Actions:**

```yaml
# Repository secrets configured in GitHub Settings → Secrets and Variables
steps:
  - name: Deploy
    env:
      DATABASE_URL:  ${{ secrets.DATABASE_URL }}
      JWT_SECRET:    ${{ secrets.JWT_SECRET }}
    run: npm run deploy
```

**Key Points:**
- GitHub Actions secrets are masked in logs — any value that matches a registered secret is replaced with `***`.
- Secrets should not be passed as command-line arguments — they appear in process listings. Use environment variables.
- [Inference] CI secrets are accessible to any workflow in the repository — restrict who can create or modify workflows via branch protection rules, as a malicious workflow could exfiltrate secrets.

---

### Minimum Privilege for Secrets Access

Each component of the application should have access only to the secrets it requires:

```typescript
// Instead of one monolithic secrets object with all credentials,
// pass only what each plugin needs

// Database plugin — gets only the database URL
await fastify.register(fastifyPostgres, {
  connectionString: secrets.databaseUrl
})

// JWT plugin — gets only the JWT secret
await fastify.register(fastifyJwt, {
  secret: secrets.jwtSecret
})

// Stripe plugin — gets only the Stripe key
await fastify.register(stripePlugin, {
  secretKey: secrets.stripeSecretKey
})
```

[Inference] If a plugin or module is compromised, minimum-privilege secret distribution limits what the attacker gains access to. Passing a single object containing all secrets to every plugin defeats this separation.

---

### Audit Trail for Secret Access

In production environments with a secrets manager, enable access logging:

- **AWS Secrets Manager** — CloudTrail logs all `GetSecretValue` calls: who accessed which secret, when, and from which IP/role.
- **HashiCorp Vault** — Audit log records all secret access with client identity.
- **GCP Secret Manager** — Cloud Audit Logs records `accessSecretVersion` calls.

[Inference] Anomalous access patterns (unexpected IPs, access outside business hours, high-frequency polling) are detectable via these logs and can indicate credential theft or misconfiguration.

---

### Summary — Secrets Lifecycle Controls

| Lifecycle stage | Control |
|---|---|
| Storage | Secrets manager (AWS, Vault, GCP, Azure) — not source code or `.env` |
| Sourcing at runtime | Environment injection or SDK fetch at startup |
| Validation | `env-schema` with `minLength` and format constraints |
| Access in app | Fastify config decorator — centralized, not scattered `process.env` calls |
| Log hygiene | Pino `redact` configuration |
| Rotation | Restart-on-rotation or TTL cache with invalidation |
| CI/CD | Platform secret stores (GitHub Secrets, etc.) — not hardcoded |
| Audit | Secrets manager access logs |
| Minimum privilege | Per-plugin secret distribution |

---

**Related Topics:**
- `env-schema` with TypeBox — full schema validation patterns for environment config
- `@fastify/jwt` — key configuration, asymmetric signing, and rotation
- Pino redaction — advanced path patterns with `fast-redact`
- `@fastify/postgres` and connection string security
- Kubernetes Secrets and external secrets operators (External Secrets Operator, Sealed Secrets)
- Doppler, Infisical — developer-focused secrets management platforms
- SOPS (Secrets OPerationS) — encrypted secrets in version control
- Secret scanning in CI — GitHub secret scanning, `gitleaks`, `trufflehog`