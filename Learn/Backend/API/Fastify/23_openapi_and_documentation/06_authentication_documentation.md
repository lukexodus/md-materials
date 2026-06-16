## Authentication Documentation

Documenting authentication in OpenAPI means declaring security schemes in `components/securitySchemes`, applying them globally or per-operation via `security` arrays, and annotating request parameters (headers, query strings) that carry credentials. The documentation describes the authentication contract to API consumers — it does not implement or enforce authentication at runtime. Runtime enforcement is always handled separately by Fastify hooks and plugins.

---

### Core Concepts

Three distinct layers interact:

| Layer | Responsibility | Where declared |
|---|---|---|
| **Security scheme definition** | Names and describes an auth mechanism | `components/securitySchemes` in plugin config |
| **Security requirement** | Applies a scheme to operations | Global `security` array or per-route `schema.security` |
| **Runtime enforcement** | Validates credentials on actual requests | Fastify hooks, `@fastify/jwt`, `@fastify/auth`, etc. |

[Inference] OpenAPI security documentation has no effect on runtime behavior. A route marked `security: [{ bearerAuth: [] }]` in the schema will not reject unauthenticated requests unless a corresponding hook or plugin enforces it.

---

### Declaring Security Schemes

All schemes are declared in the `components/securitySchemes` section of the plugin configuration. The key name (e.g., `bearerAuth`) is what route `security` arrays reference.

#### HTTP Bearer (JWT)

```typescript
await app.register(fastifySwagger, {
  openapi: {
    info: { title: 'My API', version: '1.0.0' },
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
          description: `JWT issued by \`POST /auth/token\`.

Include in the \`Authorization\` header:
\`\`\`
Authorization: Bearer <token>
\`\`\`

Tokens expire after **1 hour**. Refresh using \`POST /auth/refresh\`.`,
        },
      },
    },
  },
});
```

#### API Key in Header

```typescript
apiKeyHeader: {
  type: 'apiKey',
  in: 'header',
  name: 'x-api-key',
  description: 'API key issued from the developer portal. Included in every request header.',
},
```

#### API Key in Query String

```typescript
apiKeyQuery: {
  type: 'apiKey',
  in: 'query',
  name: 'api_key',
  description: `API key passed as a query parameter.

**Use only for contexts where headers cannot be set** (e.g., direct browser links, webhook URLs). Prefer the header form for all other uses.`,
},
```

#### HTTP Basic Auth

```typescript
basicAuth: {
  type: 'http',
  scheme: 'basic',
  description: 'Base64-encoded `username:password` in the Authorization header.',
},
```

#### Cookie-Based Session

```typescript
cookieAuth: {
  type: 'apiKey',
  in: 'cookie',
  name: 'sessionId',
  description: 'Session cookie set by `POST /auth/login`. Sent automatically by the browser.',
},
```

#### OAuth 2.0

```typescript
oauth2: {
  type: 'oauth2',
  description: 'OAuth 2.0 authorization. Use the authorization code flow for user-facing applications.',
  flows: {
    authorizationCode: {
      authorizationUrl: 'https://auth.example.com/authorize',
      tokenUrl: 'https://auth.example.com/token',
      refreshUrl: 'https://auth.example.com/refresh',
      scopes: {
        'read:products': 'Read product catalogue',
        'write:products': 'Create and modify products',
        'read:orders': 'Read order history',
        'write:orders': 'Place and cancel orders',
        'admin': 'Full administrative access',
      },
    },
    clientCredentials: {
      tokenUrl: 'https://auth.example.com/token',
      scopes: {
        'read:products': 'Read product catalogue',
        'write:products': 'Create and modify products',
      },
    },
  },
},
```

#### OpenID Connect

```typescript
openIdConnect: {
  type: 'openIdConnect',
  openIdConnectUrl: 'https://auth.example.com/.well-known/openid-configuration',
  description: 'OpenID Connect discovery document URL.',
},
```

---

### Applying Security Globally

A `security` array at the top level of the OpenAPI config applies the listed scheme(s) to all operations by default.

```typescript
await app.register(fastifySwagger, {
  openapi: {
    info: { title: 'My API', version: '1.0.0' },
    components: {
      securitySchemes: {
        bearerAuth: { type: 'http', scheme: 'bearer', bearerFormat: 'JWT' },
        apiKeyHeader: { type: 'apiKey', in: 'header', name: 'x-api-key' },
      },
    },
    // Global default: all routes require bearerAuth unless overridden
    security: [{ bearerAuth: [] }],
  },
});
```

---

### Per-Route Security Override

Individual routes override or remove the global default using `schema.security`.

```typescript
// No auth required — overrides global default
app.get(
  '/public/status',
  {
    schema: {
      tags: ['system'],
      summary: 'Health check',
      security: [],
    },
  },
  async () => ({ status: 'ok' })
);

// Specific scheme — overrides global default
app.get(
  '/webhooks/inbound',
  {
    schema: {
      tags: ['webhooks'],
      summary: 'Receive inbound webhook',
      security: [{ apiKeyHeader: [] }],
    },
  },
  handler
);

// Multiple alternative schemes — consumer satisfies any one (OR)
app.get(
  '/reports',
  {
    schema: {
      tags: ['reports'],
      summary: 'Download report',
      security: [{ bearerAuth: [] }, { apiKeyHeader: [] }],
    },
  },
  handler
);

// Multiple required schemes — consumer must satisfy all (AND)
app.delete(
  '/admin/nuke',
  {
    schema: {
      tags: ['admin'],
      summary: 'Destructive admin operation',
      security: [{ bearerAuth: [], apiKeyHeader: [] }],
    },
  },
  handler
);
```

**Key Points:**
- Multiple objects in the `security` array = OR (any one satisfies)
- Multiple keys inside one object = AND (all must be satisfied)
- `security: []` explicitly declares no authentication required, overriding the global default
- [Inference] Swagger UI renders a lock icon on operations with non-empty security requirements; an open lock or no icon for `security: []`

---

### Documenting the Token Endpoint

The authentication endpoint itself should be fully documented with request/response schemas, even though it is the entry point that issues credentials.

```typescript
app.post(
  '/auth/token',
  {
    schema: {
      operationId: 'issueToken',
      tags: ['auth'],
      summary: 'Issue access token',
      description: `Authenticates a user and returns a short-lived JWT access token and a long-lived refresh token.

**Token lifetimes:**
- Access token: 1 hour
- Refresh token: 30 days (single use)

Supply the access token as \`Authorization: Bearer <token>\` on subsequent requests.`,
      security: [],  // No auth required — this is the auth endpoint
      body: {
        type: 'object',
        required: ['username', 'password'],
        properties: {
          username: {
            type: 'string',
            description: 'Registered account username or email address',
            example: 'jane.doe@example.com',
          },
          password: {
            type: 'string',
            format: 'password',
            description: 'Account password. Not logged or stored in plaintext.',
            example: 'correct-horse-battery-staple',
          },
          mfaCode: {
            type: 'string',
            pattern: '^[0-9]{6}$',
            description: 'Six-digit TOTP code. Required if MFA is enabled on the account.',
            example: '482910',
          },
        },
      },
      response: {
        200: {
          description: 'Authentication successful.',
          type: 'object',
          properties: {
            accessToken: {
              type: 'string',
              description: 'JWT access token. Valid for 1 hour.',
              example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
            },
            refreshToken: {
              type: 'string',
              description: 'Opaque refresh token. Valid for 30 days, single use.',
              example: 'dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4...',
            },
            expiresIn: {
              type: 'integer',
              description: 'Access token lifetime in seconds',
              example: 3600,
            },
            tokenType: {
              type: 'string',
              enum: ['Bearer'],
              example: 'Bearer',
            },
          },
        },
        401: {
          description: 'Invalid credentials.',
          type: 'object',
          properties: {
            error: { type: 'string', example: 'Invalid username or password' },
          },
        },
        403: {
          description: 'MFA code required or invalid.',
          type: 'object',
          properties: {
            error: { type: 'string', example: 'MFA code required' },
            mfaRequired: { type: 'boolean', example: true },
          },
        },
        429: {
          description: 'Too many failed attempts. Account temporarily locked.',
          type: 'object',
          properties: {
            error: { type: 'string' },
            retryAfter: {
              type: 'integer',
              description: 'Seconds until login attempts are allowed again',
              example: 300,
            },
          },
        },
      },
    },
  },
  handler
);
```

---

### Documenting Token Refresh and Revocation

```typescript
app.post(
  '/auth/refresh',
  {
    schema: {
      operationId: 'refreshToken',
      tags: ['auth'],
      summary: 'Refresh access token',
      description: 'Exchanges a valid refresh token for a new access token and a new refresh token. The supplied refresh token is invalidated immediately.',
      security: [],
      body: {
        type: 'object',
        required: ['refreshToken'],
        properties: {
          refreshToken: {
            type: 'string',
            description: 'The refresh token received from `POST /auth/token` or a prior refresh.',
            example: 'dGhpcyBpcyBhIHJlZnJlc2ggdG9rZW4...',
          },
        },
      },
      response: {
        200: {
          description: 'New token pair issued.',
          type: 'object',
          properties: {
            accessToken: { type: 'string' },
            refreshToken: { type: 'string' },
            expiresIn: { type: 'integer', example: 3600 },
          },
        },
        401: {
          description: 'Refresh token is invalid, expired, or already used.',
          type: 'object',
          properties: { error: { type: 'string' } },
        },
      },
    },
  },
  handler
);

app.post(
  '/auth/revoke',
  {
    schema: {
      operationId: 'revokeToken',
      tags: ['auth'],
      summary: 'Revoke refresh token',
      description: 'Immediately invalidates a refresh token. Use on logout.',
      security: [{ bearerAuth: [] }],
      body: {
        type: 'object',
        required: ['refreshToken'],
        properties: {
          refreshToken: { type: 'string' },
        },
      },
      response: {
        204: { description: 'Token revoked. No content returned.' },
        404: { description: 'Token not found or already revoked.', type: 'object', properties: { error: { type: 'string' } } },
      },
    },
  },
  handler
);
```

---

### Documenting API Key Provisioning

If your API issues API keys through an endpoint, document it alongside the token endpoints.

```typescript
app.post(
  '/developer/api-keys',
  {
    schema: {
      operationId: 'createApiKey',
      tags: ['auth'],
      summary: 'Create API key',
      description: `Creates a new API key for programmatic access.

**The key value is only returned once** at creation time. Store it securely — it cannot be retrieved again.

Keys can be scoped to specific permissions and given an expiry date.`,
      security: [{ bearerAuth: [] }],
      body: {
        type: 'object',
        required: ['name'],
        properties: {
          name: {
            type: 'string',
            maxLength: 100,
            description: 'Human-readable label for this key',
            example: 'CI/CD pipeline key',
          },
          scopes: {
            type: 'array',
            items: {
              type: 'string',
              enum: ['read:products', 'write:products', 'read:orders'],
            },
            description: 'Permission scopes granted to this key. Defaults to read-only.',
            example: ['read:products', 'read:orders'],
          },
          expiresAt: {
            type: 'string',
            format: 'date-time',
            description: 'Optional expiry timestamp. Omit for a non-expiring key.',
            example: '2027-01-01T00:00:00Z',
          },
        },
      },
      response: {
        201: {
          description: 'API key created. The `key` field is only returned here.',
          type: 'object',
          properties: {
            id: { type: 'string', format: 'uuid', description: 'Key identifier for management operations' },
            key: {
              type: 'string',
              description: 'The API key value. **Shown only once. Store immediately.**',
              example: 'sk_live_abc123def456...',
            },
            name: { type: 'string' },
            scopes: { type: 'array', items: { type: 'string' } },
            createdAt: { type: 'string', format: 'date-time' },
            expiresAt: { type: 'string', format: 'date-time', nullable: true },
          },
        },
      },
    },
  },
  handler
);
```

---

### Swagger UI Authorization Flow

When `securitySchemes` are declared, Swagger UI renders an **Authorize** button at the top of the page. Clicking it opens a dialog where users enter credentials. Entered values are stored in browser memory (or `localStorage` if `persistAuthorization: true`) and attached to all "Try it out" requests.

```typescript
await app.register(fastifySwaggerUi, {
  routePrefix: '/docs',
  uiConfig: {
    persistAuthorization: true,   // retains token across page reloads
    displayRequestDuration: true, // shows response time after each try-it-out request
  },
});
```

**Key Points:**
- The Authorize dialog is populated from `securitySchemes` — scheme names, types, and descriptions appear in the dialog
- `persistAuthorization: true` stores credentials in `localStorage`; [Speculation] this may be inappropriate for shared or public terminals — consider disabling in sensitive environments
- Swagger UI sends credentials only in "Try it out" mode; the documentation itself does not make any requests on load

---

### Documenting Request-Level Auth Headers Directly

In some APIs, authentication parameters are passed as explicit headers rather than through a security scheme (e.g., legacy systems, HMAC signatures). These can be documented at the property level within the `headers` schema.

```typescript
app.post(
  '/webhooks/send',
  {
    schema: {
      tags: ['webhooks'],
      summary: 'Send webhook',
      security: [],
      headers: {
        type: 'object',
        required: ['x-api-key', 'x-timestamp', 'x-signature'],
        properties: {
          'x-api-key': {
            type: 'string',
            description: 'Your API key',
            example: 'sk_live_abc123',
          },
          'x-timestamp': {
            type: 'string',
            description: 'Unix timestamp of the request in seconds. Must be within 300 seconds of server time.',
            example: '1718000000',
          },
          'x-signature': {
            type: 'string',
            description: `HMAC-SHA256 of \`timestamp + "." + request_body\` using your API secret.

\`\`\`
signature = HMAC-SHA256(secret, timestamp + "." + body)
\`\`\``,
            example: 'a3f8c2d1e4b7...',
          },
        },
      },
      response: {
        202: { description: 'Webhook accepted for delivery.' },
        401: { description: 'Missing or invalid authentication headers.' },
      },
    },
  },
  handler
);
```

---

### Diagram: Security Documentation Structure

```mermaid
flowchart TD
    A[fastifySwagger config\ncomponents.securitySchemes]
    A --> B[bearerAuth\ntype: http, bearer]
    A --> C[apiKeyHeader\ntype: apiKey, in: header]
    A --> D[oauth2\ntype: oauth2, flows]
    A --> E[cookieAuth\ntype: apiKey, in: cookie]

    F[Global security array\nsecurity: bearerAuth]
    F --> G[Applied to all routes\nby default]

    H[Route schema.security]
    H --> I[security: []\nNo auth required]
    H --> J[security: bearerAuth\nOverrides global]
    H --> K[security: bearerAuth, apiKey\nAND — both required]
    H --> L[security: bearerAuth OR apiKey\nOR — either sufficient]

    M[Swagger UI\nAuthorize button]
    B --> M
    C --> M
    D --> M
    E --> M
```

---

### Common Mistakes

| Mistake | Effect |
|---|---|
| Declaring a scheme but applying no global or route `security` | Scheme appears in the Authorize dialog but no operations are locked |
| Route `security` references an undeclared scheme name | Lock icon renders in UI; scheme definition is missing — linters warn |
| Omitting `security: []` on truly public routes when a global default is set | Public routes appear as auth-required in the docs |
| Conflating documentation security with runtime enforcement | `schema.security` affects docs only; unenforced routes remain accessible |
| Documenting sensitive headers (passwords, raw secrets) with realistic `example` values | Real-looking credentials in docs may cause confusion or accidental exposure |
| `persistAuthorization: true` in a shared or public-facing docs environment | [Speculation] Stored credentials in `localStorage` may persist across user sessions on shared machines |
| Using `format: 'password'` expecting Swagger UI to mask input | `format: 'password'` is a hint to renderers; [Inference] Swagger UI may or may not mask the try-it-out input field — verify in your version |

---

**Related Topics:**
- `@fastify/jwt` integration — runtime JWT verification that corresponds to `bearerAuth` documentation
- `@fastify/auth` — composing multiple authentication strategies at the route level
- OAuth 2.0 PKCE flow documentation — documenting the authorization code flow with PKCE for public clients
- Scope-based authorization documentation — documenting which scopes are required per operation
- `uiHooks` for docs access control — preventing unauthenticated access to the Swagger UI itself
- Security scheme descriptions as onboarding documentation — writing scheme `description` fields as self-contained integration guides