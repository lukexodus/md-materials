## CSRF Protection with tRPC

---

### What CSRF Is and Why It Applies

Cross-Site Request Forgery (CSRF) is an attack in which a malicious website causes a victim's browser to send a request to a target server using the victim's existing credentials — typically cookies. Because the browser automatically attaches cookies to matching requests, the server cannot distinguish a legitimate request from a forged one based on cookies alone.

**Key Points:**
- CSRF is only relevant when authentication relies on cookies or other browser-managed credentials
- If authentication uses HTTP headers (e.g., `Authorization: Bearer <token>`) set explicitly by JavaScript, CSRF does not apply in the traditional sense — browsers do not automatically attach custom headers to cross-origin requests
- tRPC does not include built-in CSRF protection; protection must be implemented at the application or server level

---

### When tRPC Applications Are and Are Not Vulnerable

Whether a tRPC application is vulnerable to CSRF depends entirely on how authentication is implemented.

| Auth Mechanism | CSRF Risk |
|---|---|
| Cookie-based sessions (HttpOnly cookie) | At risk — browser sends cookie automatically |
| JWT in `Authorization` header (set by JS) | Not at risk from classic CSRF |
| JWT stored in a cookie | At risk — same as cookie-based sessions |
| API key in a custom header | Not at risk — custom headers require JS |

**Key Points:**
- The transport mechanism (HTTP, fetch, tRPC client) does not determine CSRF risk — cookie handling by the browser does
- [Inference] Many Next.js and full-stack tRPC applications use cookie-based sessions (e.g., via NextAuth / Auth.js), making CSRF protection relevant for those setups
- Behavior depends on how the authentication library and session management are configured

---

### Why tRPC's Default Transport Provides Partial Protection

tRPC queries use HTTP `GET` requests and mutations use HTTP `POST` requests by default. The `Content-Type` of tRPC batch requests is `application/json`.

A browser-initiated cross-origin `POST` with `Content-Type: application/json` triggers a CORS preflight (`OPTIONS`) request. If the server's CORS policy does not permit the origin, the preflight fails and the request is blocked.

**Key Points:**
- CORS and CSRF are separate mechanisms; CORS can mitigate some CSRF vectors but is not a complete CSRF defense
- CORS protects against cross-origin requests in browsers that enforce it, but does not protect against same-origin requests, server-side requests, or non-browser clients
- A strict CORS policy (`Access-Control-Allow-Origin` set to the exact application origin, not `*`) reduces cross-origin CSRF risk for `application/json` requests
- [Inference] Relying on CORS alone as a CSRF defense is generally considered insufficient for sensitive operations; it should be combined with explicit CSRF protection

---

### The Custom Header Technique

One lightweight CSRF mitigation that does not require tokens is requiring a custom HTTP header on all state-mutating requests. Browsers cannot send custom headers on cross-origin requests without a CORS preflight, which a correctly configured server will reject.

The tRPC client can be configured to send a custom header on every request:

```typescript
import { createTRPCProxyClient, httpBatchLink } from '@trpc/client';
import type { AppRouter } from '../server/router';

const trpc = createTRPCProxyClient<AppRouter>({
  links: [
    httpBatchLink({
      url: '/trpc',
      headers() {
        return {
          'x-trpc-source': 'web-client', // custom header
        };
      },
    }),
  ],
});
```

On the server, middleware can verify the header is present:

```typescript
// Express middleware before tRPC
app.use('/trpc', (req, res, next) => {
  if (req.method !== 'GET' && !req.headers['x-trpc-source']) {
    res.status(403).json({ error: 'CSRF check failed' });
    return;
  }
  next();
});
```

**Key Points:**
- This technique relies on the browser's enforcement of CORS preflight for custom headers — it is not a token-based guarantee
- The header value does not need to be secret; its presence is the signal
- [Inference] This approach is considered a reasonable defense-in-depth measure but is not equivalent to a cryptographically verified CSRF token; the level of protection depends on consistent CORS enforcement by the browser
- Non-browser clients (e.g., curl, server-to-server) are unaffected by this check and would need separate handling if applicable

---

### Token-Based CSRF Protection

The traditional and most widely accepted CSRF defense is the synchronizer token pattern. A unique, unpredictable token is issued by the server, stored server-side (associated with the session), sent to the client, and required on every state-mutating request. The server validates the token before processing the request.

**Step 1 — Issue a CSRF token endpoint:**
```typescript
// REST endpoint or tRPC query that issues the token
getCsrfToken: t.procedure.query(async ({ ctx }) => {
  const token = crypto.randomUUID();
  // Store token associated with the session
  await sessionStore.setCsrfToken(ctx.sessionId, token);
  return { csrfToken: token };
}),
```

**Step 2 — Client stores and sends the token:**
```typescript
const { csrfToken } = await trpc.getCsrfToken.query();

const trpcWithCsrf = createTRPCProxyClient<AppRouter>({
  links: [
    httpBatchLink({
      url: '/trpc',
      headers() {
        return {
          'x-csrf-token': csrfToken,
        };
      },
    }),
  ],
});
```

**Step 3 — Server validates the token in middleware:**
```typescript
const protectedProcedure = t.procedure.use(async ({ ctx, next }) => {
  const tokenFromHeader = ctx.req.headers['x-csrf-token'];
  const storedToken = await sessionStore.getCsrfToken(ctx.sessionId);

  if (!tokenFromHeader || tokenFromHeader !== storedToken) {
    throw new TRPCError({ code: 'FORBIDDEN', message: 'Invalid CSRF token' });
  }

  return next();
});
```

**Key Points:**
- The token must be unguessable and tied to the session
- The token is sent in a header, not a cookie — browsers do not attach headers automatically to cross-origin requests
- [Inference] Storing the CSRF token in a non-HttpOnly cookie (the "double submit cookie" pattern) is an alternative, though its security properties differ and depend on subdomain isolation
- Token rotation (issuing a new token after each mutation) increases security but adds implementation complexity

---

### CSRF Protection With NextAuth / Auth.js

NextAuth (now Auth.js) includes built-in CSRF token handling. When using NextAuth for session management in a tRPC application, its CSRF protection applies to NextAuth's own endpoints. tRPC procedures are not automatically covered.

**Key Points:**
- NextAuth's CSRF token protects `/api/auth/*` routes, not `/api/trpc/*` routes
- If tRPC mutations are authenticated via NextAuth sessions (cookies), those mutations require their own CSRF protection
- [Inference] A common approach is to read the NextAuth CSRF token from its endpoint and forward it as a header on tRPC requests, though this is not officially documented as a supported pattern — verify against current Auth.js documentation

```typescript
// Fetch CSRF token from NextAuth
const { csrfToken } = await fetch('/api/auth/csrf').then(r => r.json());

// Forward it on tRPC requests
httpBatchLink({
  url: '/api/trpc',
  headers() {
    return { 'x-csrf-token': csrfToken };
  },
}),
```

---

### Applying CSRF Checks Selectively via Middleware

CSRF protection is only meaningful for state-mutating operations. Read-only queries do not change server state and are generally not a CSRF concern. tRPC middleware can be scoped to mutations only.

```typescript
const csrfProtectedProcedure = t.procedure.use(async ({ ctx, type, next }) => {
  if (type === 'mutation') {
    const token = ctx.req.headers['x-csrf-token'];
    const valid = await validateCsrfToken(ctx.sessionId, token as string);

    if (!valid) {
      throw new TRPCError({ code: 'FORBIDDEN', message: 'CSRF validation failed' });
    }
  }

  return next();
});
```

**Key Points:**
- `type` in the middleware context is `'query'`, `'mutation'`, or `'subscription'`
- Scoping CSRF checks to mutations avoids unnecessary validation overhead on queries
- [Inference] Subscriptions over WebSockets have different CSRF characteristics; the initial HTTP upgrade handshake is where cookie-based credentials are presented, and protection strategies differ — this area warrants separate investigation depending on the WebSocket implementation used

---

### SameSite Cookie Attribute as a Complementary Defense

The `SameSite` attribute on session cookies instructs browsers not to send the cookie on cross-site requests. This is a complementary defense, not a standalone solution.

```
Set-Cookie: session=abc123; HttpOnly; Secure; SameSite=Strict
```

| SameSite Value | Behavior |
|---|---|
| `Strict` | Cookie not sent on any cross-site request |
| `Lax` | Cookie sent on top-level navigations (e.g., link clicks); not on subresource requests |
| `None` | Cookie sent on all requests; requires `Secure` |

**Key Points:**
- `SameSite=Strict` provides the strongest CSRF protection at the cookie level
- `SameSite=Lax` is the browser default in most modern browsers and provides partial protection
- `SameSite` is set by the server when issuing the cookie; tRPC has no direct involvement
- [Inference] `SameSite=Strict` may cause usability issues for applications where users arrive via external links and expect to be authenticated immediately — the appropriate value depends on application requirements
- Browser support and enforcement behavior may vary; `SameSite` should not be the sole CSRF defense

---

### Defense-in-Depth Summary

No single measure is sufficient. The following layers are complementary:

```
Layer 1 — SameSite cookie attribute
  Reduces browser's willingness to send cookies cross-site

Layer 2 — Strict CORS policy
  Rejects cross-origin preflight requests from unauthorized origins

Layer 3 — Custom header requirement
  Forces requests to originate from JavaScript (not passive browser behavior)

Layer 4 — CSRF token validation
  Cryptographic verification that the request originated from a legitimate session
```

**Key Points:**
- Layers 1 and 2 are configuration-level and apply broadly
- Layers 3 and 4 are application-level and require explicit implementation
- [Inference] For most tRPC applications using cookie-based authentication, combining `SameSite=Lax` or `Strict`, a strict CORS policy, and a custom header check provides reasonable protection; token-based CSRF is advisable for higher-security requirements
- The adequacy of any CSRF defense depends on the threat model of the specific application; this content does not constitute a security audit or guarantee

---

**Conclusion**

tRPC applications that rely on cookie-based authentication are subject to CSRF attacks by the same mechanisms as any other web application. tRPC provides no built-in CSRF protection. The primary defenses available are: a strict CORS policy, the custom header technique, synchronizer token validation, and the `SameSite` cookie attribute. These layers are complementary and should be selected based on the authentication mechanism in use and the application's security requirements. Applications using header-based JWT authentication without cookies are not at risk from classic CSRF.