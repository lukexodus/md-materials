## XSS Mitigation

Cross-site scripting (XSS) occurs when untrusted content is rendered in a browser in a context where it is interpreted as executable code rather than inert data. Fastify is an API framework — it does not render HTML by default — but XSS remains relevant wherever Fastify serves HTML responses, reflects user input in responses, sets response headers derived from input, or provides data consumed by a frontend that renders it without escaping. Mitigation is distributed across the server, the response pipeline, and the consuming client.

---

### XSS Categories Relevant to Fastify Applications

**Stored XSS** — Malicious content is saved to a database via a Fastify endpoint and later retrieved and rendered by a client without escaping. The Fastify API is the ingestion point; the vulnerability manifests in the client.

**Reflected XSS** — User input from a request (query parameter, path, header) is echoed in a response without sanitization. Relevant when Fastify serves HTML or includes raw input in JSON that is unsafely rendered.

**DOM-based XSS** — Occurs entirely in the client. Fastify's responsibility is limited to not providing a vector (e.g., not reflecting attacker-controlled data in a `<script>` block or JSON-in-HTML context).

**Key Points:**
- A pure JSON API that never serves HTML has a significantly reduced XSS surface, but not zero — JSON can be rendered unsafely by clients, and certain response headers derived from input can introduce vectors.
- Mitigation must span both the server (Fastify) and the client (browser). Server-side controls alone are insufficient if the client renders data without escaping.
- [Inference] Treating XSS purely as a client-side problem is a common organizational blind spot — Fastify's role in sanitizing stored content and setting defensive headers is material to overall risk posture.

---

### Layer 1 — Content Security Policy via `@fastify/helmet`

Content Security Policy (CSP) is the most impactful server-side XSS mitigation control. It instructs the browser to restrict which sources may execute scripts, load resources, or submit forms. A script injected via XSS that violates the CSP will be blocked by the browser before execution.

```bash
npm install @fastify/helmet
```

```typescript
import Fastify from 'fastify'
import helmet from '@fastify/helmet'

const fastify = Fastify({ logger: true })

await fastify.register(helmet, {
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: [
        "'self'",
        // Add specific trusted CDN hashes or nonces — avoid 'unsafe-inline'
      ],
      styleSrc: ["'self'", "'unsafe-inline'"], // revisit if inline styles can be removed
      imgSrc: ["'self'", 'data:', 'https:'],
      connectSrc: ["'self'"],
      fontSrc: ["'self'"],
      objectSrc: ["'none'"],
      mediaSrc: ["'self'"],
      frameSrc: ["'none'"],
      baseUri: ["'self'"],
      formAction: ["'self'"],
      frameAncestors: ["'none'"]
    }
  }
})
```

**Key Points:**
- `objectSrc: ["'none'"]` and `frameSrc: ["'none'"]` eliminate Flash and iframe-based attack vectors.
- `'unsafe-inline'` in `scriptSrc` substantially weakens CSP — avoid it. Use nonces or hashes for any inline scripts.
- `frameAncestors: ["'none'"]` also serves as a clickjacking control, overlapping with the `X-Frame-Options` header.
- [Inference] A CSP that allows `'unsafe-inline'` or `'unsafe-eval'` in `scriptSrc` provides significantly reduced XSS protection — an injected inline script will execute despite the policy being present.
- CSP violations can be reported to a collection endpoint using the `reportTo` or deprecated `reportUri` directive — useful for detecting attempted exploitation.

---

### CSP Nonces for Inline Scripts

If the application must serve inline `<script>` blocks (e.g., server-rendered pages with hydration data), use per-request nonces rather than `'unsafe-inline'`:

```typescript
import crypto from 'crypto'

fastify.addHook('onRequest', async (request, reply) => {
  const nonce = crypto.randomBytes(16).toString('base64')
  // Store nonce on request for use in template and CSP header
  ;(request as any).cspNonce = nonce

  reply.header(
    'Content-Security-Policy',
    `default-src 'self'; script-src 'self' 'nonce-${nonce}'; object-src 'none'`
  )
})

fastify.get('/page', async (request, reply) => {
  const nonce = (request as any).cspNonce
  return reply
    .type('text/html')
    .send(`
      <html>
        <body>
          <script nonce="${nonce}">
            window.__APP_DATA__ = ${JSON.stringify(safeData)};
          </script>
        </body>
      </html>
    `)
})
```

**Key Points:**
- The nonce is generated fresh per request — it cannot be predicted or reused by an attacker.
- Only `<script>` tags bearing the matching `nonce` attribute execute — injected scripts without the nonce are blocked.
- The nonce must be set in the CSP header and the `<script>` tag within the same request lifecycle.
- [Inference] Nonce-based CSP is more complex to implement correctly than a hash-based approach for static inline scripts — evaluate which fits the rendering architecture.

---

### Layer 2 — Output Encoding in HTML Responses

When Fastify serves HTML (directly or via a template engine), all user-derived data interpolated into the HTML must be encoded for the context in which it appears. The encoding rules differ by context:

| Context | Required encoding | Example |
|---|---|---|
| HTML element content | HTML entity encoding | `<p>${htmlEncode(value)}</p>` |
| HTML attribute value | HTML attribute encoding | `<input value="${attrEncode(value)}">` |
| JavaScript string literal | JavaScript string encoding | `var x = "${jsEncode(value)}"` |
| URL parameter | `encodeURIComponent()` | `href="/?q=${encodeURIComponent(value)}"` |
| CSS value | CSS encoding | Avoid dynamic CSS values where possible |

**Using `@fastify/view` with a template engine that auto-escapes:**

```bash
npm install @fastify/view nunjucks
npm install --save-dev @types/nunjucks
```

```typescript
import view from '@fastify/view'
import nunjucks from 'nunjucks'

await fastify.register(view, {
  engine: { nunjucks },
  templates: './templates',
  options: {
    // Nunjucks auto-escapes HTML in {{ variable }} expressions by default
  }
})

fastify.get('/profile/:id', async (request, reply) => {
  const user = await getUserById(request.params.id)
  // user.bio may contain <script> tags — Nunjucks encodes them in {{ user.bio }}
  return reply.view('profile.njk', { user })
})
```

**profile.njk:**

```nunjucks
<p>{{ user.bio }}</p>           {# auto-escaped: <script> → &lt;script&gt; #}
<p>{{ user.bio | safe }}</p>    {# NOT escaped — only use for pre-sanitized content #}
```

**Key Points:**
- Nunjucks auto-escapes HTML entity characters (`<`, `>`, `&`, `"`, `'`) in `{{ }}` expressions by default.
- The `| safe` filter bypasses auto-escaping — only apply it to content that has been sanitized with a library like `sanitize-html` before being passed to the template.
- [Inference] Template engines that do not auto-escape by default (e.g., some Handlebars configurations) require explicit escaping at every interpolation point — a single missed interpolation is a vulnerability.

---

### Layer 3 — Sanitizing Stored Content at Ingestion

Content stored via Fastify endpoints and later rendered in a browser should be sanitized at write time. This ensures the sanitized form is what gets stored and retrieved — reducing the risk that a retrieval path bypasses sanitization.

```typescript
import sanitizeHtml from 'sanitize-html'
import { FastifyInstance } from 'fastify'
import { Type, Static } from '@sinclair/typebox'

const PostBody = Type.Object({
  title:   Type.String({ maxLength: 200 }),
  content: Type.String({ maxLength: 50000 })
})

type PostBodyType = Static<typeof PostBody>

// Allowlist for a rich-text content field
const allowedTags = [
  'p', 'br', 'b', 'i', 'em', 'strong', 'a',
  'ul', 'ol', 'li', 'blockquote', 'code', 'pre', 'h2', 'h3'
]

const sanitizeContent = (raw: string): string =>
  sanitizeHtml(raw, {
    allowedTags,
    allowedAttributes: {
      a: ['href', 'title', 'target'],
      code: ['class'] // for syntax highlighting class names
    },
    allowedSchemes: ['http', 'https', 'mailto'],
    allowedSchemesByTag: {
      a: ['http', 'https', 'mailto']
    },
    // Strip data: URIs from all attributes
    allowedSchemesAppliedToAttributes: ['href', 'src', 'action']
  })

async function postRoutes(fastify: FastifyInstance) {
  fastify.post<{ Body: PostBodyType }>(
    '/posts',
    { schema: { body: PostBody } },
    async (request, reply) => {
      const { title, content } = request.body

      const sanitizedTitle   = sanitizeHtml(title, { allowedTags: [], allowedAttributes: {} })
      const sanitizedContent = sanitizeContent(content)

      const post = await createPost({ title: sanitizedTitle, content: sanitizedContent })
      return reply.status(201).send(post)
    }
  )
}
```

**Key Points:**
- `title` is plain text — all HTML is stripped.
- `content` is rich text — an allowlist permits safe formatting tags while stripping `<script>`, `<iframe>`, event handlers, and `javascript:` URIs.
- `allowedSchemes` prevents `javascript:` URIs in `href` attributes — a common XSS vector in anchor tags.
- `data:` URIs are not included in `allowedSchemes` — they can carry executable content in some browser contexts.

---

### Layer 4 — JSON Responses and XSS

Fastify's default serializer returns `Content-Type: application/json`. Browsers do not execute JSON as HTML when the content type is set correctly. However, XSS via JSON responses remains possible in specific scenarios:

**Scenario 1 — JSON rendered into HTML without escaping on the client:**

```typescript
// Server returns safe JSON
fastify.get('/user', async () => ({ bio: '<script>alert(1)</script>' }))

// Client renders it unsafely — XSS occurs here, not in Fastify
document.getElementById('bio').innerHTML = data.bio // vulnerable
document.getElementById('bio').textContent = data.bio // safe
```

Fastify's responsibility: sanitize stored content at ingestion (Layer 3). The client's responsibility: use `textContent` instead of `innerHTML` for user-derived data.

**Scenario 2 — JSON served with wrong content type:**

```typescript
// Vulnerable — browser may interpret as HTML in some contexts
reply.type('text/html').send(JSON.stringify(data))

// Safe — explicit JSON content type
reply.type('application/json').send(data)
```

**Scenario 3 — JSON embedded in a `<script>` block:**

```typescript
// Vulnerable — if data contains </script>, it closes the script tag
reply.type('text/html').send(
  `<script>var data = ${JSON.stringify(userData)};</script>`
)

// Safer — escape </script> sequences within the JSON string
const safeJson = JSON.stringify(userData).replace(/<\/script>/gi, '<\\/script>')
reply.type('text/html').send(`<script>var data = ${safeJson};</script>`)
```

[Inference] The safest approach for embedding JSON in HTML is to use a `<script type="application/json">` tag and read it via `JSON.parse(document.getElementById('data').textContent)` — this avoids the script execution context entirely. Behavior of specific browser/context combinations is not guaranteed.

---

### Layer 5 — Security Headers Beyond CSP

`@fastify/helmet` sets several headers that complement CSP for XSS mitigation:

```typescript
await fastify.register(helmet, {
  // X-Content-Type-Options: nosniff
  // Prevents browser MIME-type sniffing — stops browser from
  // interpreting a JSON response as HTML
  xContentTypeOptions: true,

  // X-XSS-Protection: 0
  // Disables the legacy XSS auditor — modern guidance recommends
  // disabling it as it can introduce vulnerabilities in some browsers
  xXssProtection: false,

  // X-Frame-Options: DENY
  // Prevents page from being embedded in iframes (clickjacking defense)
  frameguard: { action: 'deny' },

  // Referrer-Policy
  referrerPolicy: { policy: 'strict-origin-when-cross-origin' }
})
```

**Key Points:**
- `X-Content-Type-Options: nosniff` is particularly relevant — it prevents Internet Explorer and older browsers from treating a JSON or plain text response as HTML if a script tag appears in the content. Modern browsers largely handle this correctly without the header, but the header remains a defense-in-depth control.
- `X-XSS-Protection: 0` (disabled) is the current recommended value — the legacy browser XSS auditor has known bypass techniques and in some cases introduced new vulnerabilities. [Unverified: browser support status as of the current knowledge cutoff — verify against current browser compatibility data.]
- CSP is a stronger and more granular control than `X-XSS-Protection`.

---

### Layer 6 — Cookie Security

XSS attacks frequently target session cookies. Mitigating cookie theft via XSS:

```typescript
import fastifyCookie from '@fastify/cookie'
import fastifySession from '@fastify/session'

await fastify.register(fastifyCookie)

await fastify.register(fastifySession, {
  secret: process.env.SESSION_SECRET!,
  cookie: {
    httpOnly: true,   // JavaScript cannot read this cookie — blocks XSS cookie theft
    secure: true,     // Cookie only sent over HTTPS
    sameSite: 'strict' // Cookie not sent on cross-site requests — CSRF defense
  }
})
```

**Key Points:**
- `httpOnly: true` is the primary XSS-cookie mitigation — a script injected via XSS cannot access `document.cookie` for cookies marked `HttpOnly`.
- `secure: true` reduces the attack surface to HTTPS contexts.
- `sameSite: 'strict'` limits CSRF risk but does not directly mitigate XSS.
- [Inference] `httpOnly` protects cookies from direct theft; it does not prevent XSS from making authenticated requests on behalf of the user using the cookie — CSRF tokens remain necessary for state-changing operations.

---

### Reflecting User Input in Responses

Any route that echoes request input back in the response body is a potential reflected XSS vector if the response is rendered as HTML:

```typescript
// Potentially vulnerable if response is rendered as HTML
fastify.get('/search', async (request, reply) => {
  const { q } = request.query as { q: string }
  return reply.type('text/html').send(
    `<h1>Results for: ${q}</h1>` // q is unescaped — XSS if q = <script>...</script>
  )
})

// Safe — encode before interpolation
import he from 'he' // HTML entity encoder

fastify.get('/search', async (request, reply) => {
  const { q } = request.query as { q: string }
  return reply.type('text/html').send(
    `<h1>Results for: ${he.encode(q)}</h1>`
  )
})
```

For JSON-only APIs, returning `q` as a JSON string value is safe from HTML injection in the response itself — the risk is in how the client renders it.

---

### Error Responses and XSS

Custom error handlers that reflect error messages into HTML responses are a common overlooked vector:

```typescript
// Vulnerable — reflects error message into HTML response
fastify.setErrorHandler((error, request, reply) => {
  reply.type('text/html').send(
    `<p>Error: ${error.message}</p>` // error.message could contain user input
  )
})

// Safe — encode error message, or return JSON
fastify.setErrorHandler((error, request, reply) => {
  // Option 1: JSON error response (no HTML injection risk)
  reply.status(error.statusCode ?? 500).send({
    error: error.message
  })

  // Option 2: HTML with encoded message
  // reply.type('text/html').send(`<p>Error: ${he.encode(error.message)}</p>`)
})
```

---

### Summary — XSS Mitigation Layers

```
Incoming Request
       │
  [Schema validation] ─── constrain input shape; reject structural anomalies
       │
  [Sanitization hook] ─── strip HTML from stored content (sanitize-html)
       │
  [Route handler] ──────── encode output for rendering context (he, nunjucks)
       │
  [Response headers] ───── CSP, X-Content-Type-Options, X-Frame-Options
       │
  [Cookie config] ──────── HttpOnly, Secure, SameSite
       │
  Browser
       │
  [Client rendering] ────── textContent not innerHTML; trusted type enforcement
```

No layer is individually sufficient. XSS is a defense-in-depth problem — the goal is that bypassing any single control does not result in exploitation.

---

**Related Topics:**
- `@fastify/helmet` — full header configuration reference
- CSP violation reporting endpoint implementation
- `@fastify/csrf-protection` — CSRF defense complementing XSS cookie controls
- `sanitize-html` allowlist configuration for rich text fields
- Nunjucks and Handlebars auto-escaping behavior
- `@fastify/session` cookie configuration
- Trusted Types API — browser-side enforcement of safe DOM mutations
- Input sanitization — server-side content cleaning at ingestion