### URL Parameters and Wildcards in Fastify

#### Overview

Fastify's router (powered by `find-my-way`) supports named URL parameters and wildcard segments, enabling dynamic route matching. These are declared directly in the route path string and are accessible at request time via `request.params`.

---

#### Named Parameters

A named parameter is declared by prefixing a path segment with a colon (`:`). It matches any non-empty string in that segment position.

js

```
fastify.get('/users/:userId', async (request, reply) => {
  const { userId } = request.params;
  return { userId };
});
```

**Example request:** `GET /users/42`

**Output:**

json

```
{ "userId": "42" }
```

**Key Points:**

- All parameter values are strings regardless of how they appear in the URL. Type coercion is not performed automatically.
- A named parameter matches exactly one path segment — it does not match slashes.
- Parameter names must be unique within a single route path.

---

#### Multiple Parameters

Multiple named parameters can appear in a single path, including in adjacent or nested segments.

js

```
fastify.get('/orgs/:orgId/teams/:teamId', async (request, reply) => {
  const { orgId, teamId } = request.params;
  return { orgId, teamId };
});
```

**Example request:** `GET /orgs/9/teams/3`

**Output:**

json

```
{ "orgId": "9", "teamId": "3" }
```

---

#### Wildcard Routes

A wildcard is declared using `*` and matches everything after the preceding path prefix, including slashes.

js

```
fastify.get('/static/*', async (request, reply) => {
  const rest = request.params['*'];
  return { path: rest };
});
```

**Example request:** `GET /static/assets/icons/logo.svg`

**Output:**

json

```
{ "path": "assets/icons/logo.svg" }
```

**Key Points:**

- The wildcard value is accessible via `request.params['*']`.
- The wildcard segment must appear at the end of the route path.
- It matches zero or more characters, including path separators (`/`).

---

#### Named Wildcard Parameters

Fastify allows naming a wildcard segment for more readable access, using `*name` syntax.

js

```
fastify.get('/files/*filepath', async (request, reply) => {
  const { filepath } = request.params;
  return { filepath };
});
```

**Example request:** `GET /files/docs/api/reference.md`

**Output:**

json

```
{ "filepath": "docs/api/reference.md" }
```

---

#### Route Specificity and Matching Priority

When multiple routes could match a given URL, `find-my-way` resolves priority deterministically. The general order, from highest to lowest specificity, is:

1. Static segments (e.g., `/users/me`)
2. Named parameters (e.g., `/users/:id`)
3. Wildcards (e.g., `/users/*`)

js

```
fastify.get('/users/me', async (request, reply) => {
  return { user: 'current' };
});

fastify.get('/users/:id', async (request, reply) => {
  return { user: request.params.id };
});
```

**Example request:** `GET /users/me` → matches the static route, not the parameterized one.

**Key Points:**

- Static routes take precedence over parameterized routes at the same segment position.
- This behavior is determined by `find-my-way` and is consistent across Fastify versions, though exact behavior in edge cases should be verified against the router's documentation.

---

#### Constraints on Parameter and Wildcard Names

- Parameter names must begin with a letter or underscore and contain only alphanumeric characters and underscores. [Verify against current `find-my-way` documentation for the exact allowed character set.]
- Duplicate parameter names within the same route path will throw an error at registration time.
- A route cannot mix a wildcard and a named parameter at the same segment level.

---

#### Route Parameter Schema Validation

While Fastify does not coerce parameter types automatically, it does support JSON Schema validation for `params`. When a schema is defined, Fastify validates and can coerce incoming parameter values before the handler runs.

> **Disclaimer:** Coercion behavior depends on the schema and the validation library in use (default: Ajv). Actual behavior may vary based on configuration.

js

```
fastify.get(
  '/products/:productId',
  {
    schema: {
      params: {
        type: 'object',
        properties: {
          productId: { type: 'integer' }
        },
        required: ['productId']
      }
    }
  },
  async (request, reply) => {
    // productId will be an integer if Ajv coercion is enabled
    return { productId: request.params.productId };
  }
);
```

**Key Points:**

- Ajv coercion must be enabled (`ajv.coerceTypes: true`) for type conversion to take effect.
- If validation fails, Fastify returns a `400 Bad Request` by default.
- Schema validation on params applies before the handler is invoked.

---

#### Visual: Route Matching Flow

<svg viewBox="0 0 660 340" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="13">
<!-- Incoming Request -->
<rect x="230" y="10" width="200" height="40" rx="8" fill="#4A90D9" />
<text x="330" y="35" text-anchor="middle" fill="white" font-weight="bold">Incoming Request URL</text>
<!-- Arrow down -->
<line x1="330" y1="50" x2="330" y2="80" stroke="#888" stroke-width="1.5" marker-end="url(#arrow)"/>
<!-- find-my-way router -->
<rect x="210" y="80" width="240" height="40" rx="8" fill="#7B68EE" />
<text x="330" y="105" text-anchor="middle" fill="white" font-weight="bold">find-my-way Router</text>
<!-- Arrow down -->
<line x1="330" y1="120" x2="330" y2="150" stroke="#888" stroke-width="1.5" marker-end="url(#arrow)"/>
<!-- Decision -->
<polygon points="330,150 460,195 330,240 200,195" fill="#F5A623" />
<text x="330" y="190" text-anchor="middle" fill="white" font-weight="bold">Match</text>
<text x="330" y="207" text-anchor="middle" fill="white" font-weight="bold">Type?</text>
<!-- Static -->
<line x1="200" y1="195" x2="90" y2="195" stroke="#888" stroke-width="1.5" marker-end="url(#arrow)"/>
<text x="145" y="188" text-anchor="middle" fill="#555" font-size="11">static</text>
<rect x="10" y="175" width="80" height="40" rx="6" fill="#5CB85C" />
<text x="50" y="200" text-anchor="middle" fill="white">/users/me</text>
<!-- Param -->
<line x1="330" y1="240" x2="330" y2="270" stroke="#888" stroke-width="1.5" marker-end="url(#arrow)"/>
<text x="345" y="260" fill="#555" font-size="11">param</text>
<rect x="240" y="270" width="180" height="40" rx="6" fill="#5CB85C" />
<text x="330" y="295" text-anchor="middle" fill="white">/users/:id → params.id</text>
<!-- Wildcard -->
<line x1="460" y1="195" x2="560" y2="195" stroke="#888" stroke-width="1.5" marker-end="url(#arrow)"/>
<text x="510" y="188" text-anchor="middle" fill="#555" font-size="11">wildcard</text>
<rect x="560" y="175" width="90" height="40" rx="6" fill="#5CB85C" />
<text x="605" y="195" text-anchor="middle" fill="white">/static/\*</text>
<text x="605" y="210" text-anchor="middle" fill="white">params['\*']</text>
<defs>
<marker id="arrow" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
<path d="M0,0 L0,6 L8,3 z" fill="#888"/>
</marker>
</defs>
</svg>

---

#### Common Mistakes

**Using a parameter to match multiple segments:**

js

```
// This will NOT match /users/42/profile — :id only matches one segment
fastify.get('/users/:id', handler);
```

Use a wildcard or add explicit segments if multi-segment matching is needed.

**Assuming numeric types:**

js

```
// userId is '42' (string), not 42 (number) — unless schema coercion is active
const { userId } = request.params;
```

**Registering conflicting wildcard routes:**

js

```
// Ambiguous — avoid registering two wildcards for overlapping prefixes
// without understanding find-my-way's resolution rules
fastify.get('/files/*', handlerA);
fastify.get('/files/*name', handlerB); // [Unverified] — behavior may be router-version-dependent
```

---

**Conclusion**

Named parameters and wildcards are the primary tools for dynamic routing in Fastify. Parameters capture individual segments; wildcards capture the remainder of a path. Route specificity follows a deterministic order (static → param → wildcard), and schema validation with Ajv can add type coercion and input validation at the param level. Understanding how `find-my-way` resolves matches helps avoid subtle routing conflicts.

**Next Steps:** Route constraints (version, host, and custom constraints).