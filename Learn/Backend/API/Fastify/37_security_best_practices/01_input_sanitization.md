## Input Sanitization

Input sanitization in Fastify spans several distinct concerns: preventing injection attacks, normalizing untrusted data before it reaches business logic, and deciding where in the request lifecycle sanitization belongs. Fastify's schema validation layer handles structural and type enforcement, but sanitization — transforming or rejecting input based on content rather than shape — is a separate responsibility that requires deliberate implementation.

---

### Sanitization vs. Validation — Distinction

These terms are often conflated. In the context of Fastify:

**Validation** — Does this input conform to the expected shape, type, and constraints? Fastify handles this via Ajv and JSON Schema. It rejects non-conforming input with a 400 error.

**Sanitization** — Given that input is structurally valid, is its content safe to use? Sanitization transforms or rejects input based on its semantic content: stripping HTML tags, escaping special characters, trimming whitespace, normalizing Unicode.

**Key Points:**
- Schema validation runs before the route handler. Sanitization must be explicitly wired in — Fastify does not sanitize input automatically.
- Validation and sanitization are complementary, not alternatives. Both should be applied.
- [Inference] Relying on schema validation alone to block malicious input is insufficient — a valid string type can still carry XSS payloads, SQL fragments, or path traversal sequences.

---

### What Fastify Does Not Do Automatically

Fastify's built-in request pipeline does not:
- Strip HTML or script tags from string fields
- Escape SQL special characters
- Normalize Unicode or homoglyph characters
- Trim leading/trailing whitespace
- Reject null bytes or control characters within otherwise valid strings
- Enforce content-level constraints beyond what JSON Schema expresses (minLength, maxLength, pattern)

Each of these must be implemented explicitly.

---

### Layer 1 — Schema Validation as the First Line of Defense

Before sanitization, schema validation eliminates structurally malformed input. Use it aggressively:

```typescript
import { FastifyInstance } from 'fastify'
import { Type, Static } from '@sinclair/typebox'

const CreateUserBody = Type.Object({
  username: Type.String({ minLength: 3, maxLength: 32, pattern: '^[a-zA-Z0-9_]+$' }),
  email: Type.String({ format: 'email', maxLength: 254 }),
  bio: Type.Optional(Type.String({ maxLength: 500 }))
})

type CreateUserBodyType = Static<typeof CreateUserBody>

async function userRoutes(fastify: FastifyInstance) {
  fastify.post<{ Body: CreateUserBodyType }>(
    '/users',
    {
      schema: {
        body: CreateUserBody
      }
    },
    async (request, reply) => {
      const { username, email, bio } = request.body
      // username is already constrained to alphanumeric + underscore by pattern
      // bio may still contain HTML — sanitize before storage or output
    }
  )
}
```

**Key Points:**
- The `pattern` keyword restricts the character set — an alphanumeric pattern rejects HTML and SQL metacharacters at the schema level.
- `format: 'email'` delegates to Ajv's format validation — [Unverified] the exact validation algorithm depends on the `ajv-formats` version registered; do not treat it as a security boundary without testing edge cases.
- `maxLength` limits input size and reduces the impact of certain payload-based attacks.

---

### Layer 2 — HTML Sanitization

For fields that accept user-generated content intended for display (bios, comments, descriptions), strip or escape HTML before storage or output. Do not rely on output escaping alone if content is stored and later served in multiple contexts.

**Recommended library — `sanitize-html`:**

```bash
npm install sanitize-html
npm install --save-dev @types/sanitize-html
```

```typescript
import sanitizeHtml from 'sanitize-html'

// Strict — strip all HTML tags
const strictSanitize = (input: string): string =>
  sanitizeHtml(input, { allowedTags: [], allowedAttributes: {} })

// Permissive — allow a subset of safe tags
const richTextSanitize = (input: string): string =>
  sanitizeHtml(input, {
    allowedTags: ['b', 'i', 'em', 'strong', 'a', 'ul', 'ol', 'li', 'p'],
    allowedAttributes: {
      a: ['href', 'target']
    },
    allowedSchemes: ['http', 'https', 'mailto']
  })

// In route handler
fastify.post<{ Body: { bio: string } }>(
  '/users/profile',
  { schema: { body: Type.Object({ bio: Type.String({ maxLength: 500 }) }) } },
  async (request, reply) => {
    const sanitizedBio = strictSanitize(request.body.bio)
    await updateUserBio(sanitizedBio)
    return reply.status(204).send()
  }
)
```

**Key Points:**
- `allowedTags: []` with `allowedAttributes: {}` strips all HTML — appropriate for plain-text fields.
- `allowedSchemes` prevents `javascript:` URIs in anchor tags.
- [Inference] Sanitizing at write time (before storage) is preferable to sanitizing at read time — it makes behavior consistent regardless of which API endpoint returns the data. Both approaches have tradeoffs; evaluate based on your data mutation patterns.

---

### Layer 3 — Preventing SQL Injection

Fastify does not interact with databases directly. SQL injection prevention is the responsibility of the database layer. The correct control is parameterized queries — not string sanitization.

**Correct — parameterized query (with `postgres` / `pg`):**

```typescript
import { pool } from './db'

fastify.get<{ Params: { id: string } }>(
  '/users/:id',
  { schema: { params: Type.Object({ id: Type.String({ format: 'uuid' }) }) } },
  async (request, reply) => {
    const { id } = request.params

    // Parameterized — id is never interpolated into the query string
    const result = await pool.query(
      'SELECT id, username, email FROM users WHERE id = $1',
      [id]
    )

    if (result.rows.length === 0) return reply.status(404).send({ error: 'Not found' })
    return result.rows[0]
  }
)
```

**Incorrect — string interpolation:**

```typescript
// Never do this
const result = await pool.query(
  `SELECT * FROM users WHERE id = '${request.params.id}'`
)
```

**Key Points:**
- Parameterized queries separate the query structure from the data — the database driver handles escaping internally.
- Schema validation (e.g., `format: 'uuid'`) adds a structural constraint before the query executes, but is not a substitute for parameterization.
- ORMs (Prisma, TypeORM, Drizzle) use parameterized queries internally for standard operations — verify that any raw query escape hatch in your ORM also uses parameterization.

---

### Layer 4 — Sanitizing Query Parameters and Path Params

Query parameters and path params are strings by default. Apply the same content-level scrutiny:

```typescript
const ListUsersQuery = Type.Object({
  search: Type.Optional(Type.String({ maxLength: 100 })),
  page: Type.Optional(Type.Integer({ minimum: 1, maximum: 1000 })),
  sort: Type.Optional(Type.Union([
    Type.Literal('asc'),
    Type.Literal('desc')
  ]))
})

fastify.get<{ Querystring: Static<typeof ListUsersQuery> }>(
  '/users',
  { schema: { querystring: ListUsersQuery } },
  async (request, reply) => {
    const { search, page = 1, sort = 'asc' } = request.querystring

    // search may contain user input — sanitize before use in display or DB query
    const sanitizedSearch = search ? strictSanitize(search) : undefined

    return getUserList({ search: sanitizedSearch, page, sort })
  }
)
```

**Key Points:**
- `Type.Literal` union for `sort` eliminates injection risk for that field by restricting to an explicit set of values.
- Enum-like constraints (`Type.Union([Type.Literal(...)])`) are the strongest sanitization available at the schema layer — they allow no variation from the defined values.
- Free-text search fields require content sanitization regardless of length constraints.

---

### Layer 5 — Null Bytes and Control Characters

Null bytes (`\x00`) and control characters can cause unexpected behavior in filesystems, databases, and C-extension modules. JSON Schema does not reject them by default.

```typescript
const removeNullBytes = (input: string): string =>
  input.replace(/\x00/g, '')

const removeControlCharacters = (input: string): string =>
  // Remove ASCII control characters except tab (0x09), LF (0x0A), CR (0x0D)
  input.replace(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/g, '')

// Apply in a preHandler hook for all string fields in body
fastify.addHook('preHandler', async (request) => {
  if (request.body && typeof request.body === 'object') {
    sanitizeStringFields(request.body as Record<string, unknown>)
  }
})

function sanitizeStringFields(obj: Record<string, unknown>): void {
  for (const key of Object.keys(obj)) {
    const val = obj[key]
    if (typeof val === 'string') {
      obj[key] = removeControlCharacters(val)
    } else if (val !== null && typeof val === 'object') {
      sanitizeStringFields(val as Record<string, unknown>)
    }
  }
}
```

[Inference] Mutating `request.body` in a `preHandler` hook modifies the object that the route handler receives. This works because Fastify passes the parsed body object by reference — behavior is not guaranteed to remain stable across major Fastify versions.

---

### Layer 6 — Path Traversal

When request input is used to construct filesystem paths, normalize and validate the resolved path before use:

```typescript
import path from 'path'
import fs from 'fs/promises'

const ALLOWED_BASE = path.resolve('/var/app/uploads')

fastify.get<{ Params: { filename: string } }>(
  '/files/:filename',
  {
    schema: {
      params: Type.Object({
        filename: Type.String({ pattern: '^[a-zA-Z0-9_\\-\\.]+$', maxLength: 128 })
      })
    }
  },
  async (request, reply) => {
    const { filename } = request.params
    const resolved = path.resolve(ALLOWED_BASE, filename)

    // Confirm resolved path is still within the allowed base
    if (!resolved.startsWith(ALLOWED_BASE + path.sep)) {
      return reply.status(400).send({ error: 'Invalid file path' })
    }

    const content = await fs.readFile(resolved)
    return reply.send(content)
  }
)
```

**Key Points:**
- The `pattern` on `filename` restricts to safe characters and prevents `../` sequences at the schema level.
- `path.resolve()` followed by `startsWith(ALLOWED_BASE)` is a defense-in-depth check — it catches traversal even if the pattern is not exhaustive.
- Both controls together are more robust than either alone.

---

### Centralizing Sanitization with a `preHandler` Hook

For sanitization logic that applies broadly, register it as a plugin-level or application-level `preHandler` hook rather than repeating it in every route handler:

```typescript
import fp from 'fastify-plugin'
import sanitizeHtml from 'sanitize-html'
import { FastifyInstance } from 'fastify'

async function sanitizationPlugin(fastify: FastifyInstance) {
  fastify.addHook('preHandler', async (request) => {
    if (!request.body || typeof request.body !== 'object') return

    deepSanitizeStrings(request.body as Record<string, unknown>)
  })
}

function deepSanitizeStrings(obj: Record<string, unknown>): void {
  for (const key of Object.keys(obj)) {
    const val = obj[key]
    if (typeof val === 'string') {
      obj[key] = sanitizeHtml(val, { allowedTags: [], allowedAttributes: {} })
        .replace(/[\x00-\x08\x0B\x0C\x0E-\x1F\x7F]/g, '')
        .trim()
    } else if (Array.isArray(val)) {
      val.forEach((item, i) => {
        if (typeof item === 'string') {
          val[i] = sanitizeHtml(item, { allowedTags: [], allowedAttributes: {} }).trim()
        } else if (item !== null && typeof item === 'object') {
          deepSanitizeStrings(item as Record<string, unknown>)
        }
      })
    } else if (val !== null && typeof val === 'object') {
      deepSanitizeStrings(val as Record<string, unknown>)
    }
  }
}

export default fp(sanitizationPlugin)
```

Register globally:

```typescript
await fastify.register(sanitizationPlugin)
```

**Key Points:**
- Wrapping with `fastify-plugin` (`fp`) makes the hook apply globally across all routes, not just those in a scoped plugin.
- A blanket strip-all-HTML approach suits APIs returning JSON. For content management systems or rich text endpoints, use a more permissive sanitizer on specific fields rather than globally.
- [Inference] Applying deep sanitization on every request body adds processing time proportional to body size and nesting depth — benchmark under realistic payload sizes if throughput is a concern.

---

### Ajv Custom Keywords for Content Validation

Ajv, which Fastify uses internally, supports custom keywords. This allows content-level rules to be expressed in the schema itself:

```typescript
fastify.setValidatorCompiler(({ schema }) => {
  const ajv = new Ajv()

  ajv.addKeyword({
    keyword: 'noHtml',
    type: 'string',
    validate: (schemaVal: boolean, data: string) => {
      if (!schemaVal) return true
      return !/<[^>]+>/.test(data)
    },
    errors: false
  })

  return ajv.compile(schema)
})
```

Usage in schema:

```typescript
const Body = Type.Object({
  comment: Type.String({ maxLength: 1000, noHtml: true } as any)
})
```

[Inference] Custom Ajv keywords integrate sanitization intent into the schema layer, making validation errors (400 responses) the outcome for HTML-containing input rather than silent stripping. Whether to reject or strip is a product decision — rejection is more explicit; stripping is more forgiving. Behavior may vary if the Ajv instance is reconfigured.

---

### Whitelist vs. Blacklist Approach

**Whitelist (allowlist):** Define exactly what is permitted. Reject or strip everything else.
- Example: `pattern: '^[a-zA-Z0-9_]+$'` allows only alphanumeric and underscore.
- More robust — unknown attack vectors are blocked by default.

**Blacklist (denylist):** Define what is forbidden. Allow everything else.
- Example: reject input containing `<script>`.
- Fragile — attackers encode, case-vary, or Unicode-normalize around blocklists.

**Key Points:**
- Prefer whitelist approaches wherever the valid input space is well-defined.
- For free-text fields where whitelisting the character set is not feasible, use a well-maintained sanitization library rather than a homegrown blocklist.
- [Inference] Homegrown blocklist regex for HTML or SQL is unlikely to be exhaustive against a motivated attacker — use established libraries.

---

### Sanitization Across the Response Path

Sanitization applies to input, but output encoding is a complementary concern:

- If sanitized data is returned in a JSON response, Fastify's JSON serializer handles encoding — no additional HTML escaping is applied to JSON string values. [Inference] This is safe for JSON API consumers; it is not safe if the JSON is rendered directly into HTML without escaping on the client side.
- If data is returned as HTML (using `reply.type('text/html').send(html)`), the application is responsible for escaping all user-derived content before interpolation.
- Fastify does not provide an HTML templating engine by default — use `@fastify/view` with a template engine that auto-escapes (e.g., Nunjucks with autoescaping enabled, Handlebars).

---

### Summary — Sanitization Layers

```
Incoming Request
       │
  [Schema validation] ── structural shape, type, length, pattern, format
       │
  [preHandler hook] ───── strip HTML, null bytes, control characters (global)
       │
  [Route handler] ──────── field-specific sanitization, path traversal checks
       │
  [Database layer] ──────── parameterized queries (SQL injection prevention)
       │
  [Response] ────────────── output encoding by template engine (if HTML output)
```

No single layer is sufficient in isolation. Defense in depth across all layers is the applicable standard.

---

**Related Topics:**
- Ajv custom keywords and custom validator compiler
- `@fastify/helmet` — HTTP security headers as a complement to input sanitization
- `@fastify/rate-limit` — limiting malicious input volume
- Content Security Policy configuration with `@fastify/helmet`
- TypeBox schema patterns for strict input constraints
- `@fastify/view` with auto-escaping template engines
- File upload sanitization with `@fastify/multipart`
- OWASP Input Validation Cheat Sheet — external reference for threat categorization