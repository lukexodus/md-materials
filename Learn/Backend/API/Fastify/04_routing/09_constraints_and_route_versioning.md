### Constraints and Route Versioning

#### Overview

Fastify's router supports constraints — conditions beyond the URL path that must be satisfied for a route to match a request. Two constraints are built in: `version` and `host`. Custom constraints can also be defined. This allows multiple routes to share the same HTTP method and path while matching different requests based on header values or other criteria.

---

#### How Constraints Work

Constraints are declared in the route options object under the `constraints` key. When a request arrives, `find-my-way` evaluates both the path and all declared constraints. A route only matches if every constraint is satisfied.

js

```
fastify.get('/api/resource', {
  constraints: { version: '2.0.0' }
}, async () => ({ version: 2 }));

fastify.get('/api/resource', {
  constraints: { version: '1.0.0' }
}, async () => ({ version: 1 }));
```

**Key Points:**

- Two routes may share the same method and path if they differ in at least one constraint value.
- Without a matching constraint, the router falls through to an unconstrained route for that path if one exists.
- Constraint evaluation is performed by `find-my-way` at request time, not at registration time.

---

#### Version Constraints

The built-in `version` constraint matches against the `Accept-Version` request header using semantic versioning (semver) rules.

js

```
fastify.get('/users', {
  constraints: { version: '2.0.0' }
}, async () => ({ api: 'v2', users: [] }));

fastify.get('/users', {
  constraints: { version: '1.0.0' }
}, async () => ({ api: 'v1', users: [] }));

fastify.get('/users', async () => ({ api: 'default', users: [] }));
```

**Request matching behavior:**

| `Accept-Version` header | Matched route |
| --- | --- |
| `2.0.0` | version `2.0.0` route |
| `2.x` | version `2.0.0` route |
| `1.0.0` | version `1.0.0` route |
| *(absent)* | unconstrained route |

**Key Points:**

- The `Accept-Version` header value is matched using semver range rules. A client sending `2.x` matches any `2.*` route.
- If no route matches the requested version and no unconstrained fallback exists, Fastify returns `404`.
- The unconstrained route acts as the default and is matched when no `Accept-Version` header is present.

---

#### Version Constraint with Semver Ranges

Because version matching uses semver, clients can request ranges and Fastify will resolve to the best matching registered version.

js

```
fastify.get('/data', {
  constraints: { version: '1.0.0' }
}, async () => ({ release: '1.0.0' }));

fastify.get('/data', {
  constraints: { version: '1.1.0' }
}, async () => ({ release: '1.1.0' }));

fastify.get('/data', {
  constraints: { version: '2.0.0' }
}, async () => ({ release: '2.0.0' }));
```

**Example requests:**

- `Accept-Version: 1.x` → matches `1.1.0` (highest satisfying version)
- `Accept-Version: ^1.0.0` → matches `1.1.0`
- `Accept-Version: 2.0.0` → matches `2.0.0`

> **Disclaimer:** Semver resolution behavior is implemented by `find-my-way`. Exact matching semantics for edge cases should be verified against the current `find-my-way` documentation, as behavior may vary across versions.

---

#### Host Constraints

The built-in `host` constraint matches against the `Host` request header. It accepts either an exact string or a regular expression.

**Exact host match:**

js

```
fastify.get('/dashboard', {
  constraints: { host: 'admin.example.com' }
}, async () => ({ portal: 'admin' }));

fastify.get('/dashboard', {
  constraints: { host: 'app.example.com' }
}, async () => ({ portal: 'app' }));
```

**Regex host match:**

js

```
fastify.get('/dashboard', {
  constraints: { host: /^staging\./ }
}, async () => ({ env: 'staging' }));
```

**Key Points:**

- The `Host` header is used for matching, which in HTTP/2 corresponds to the `:authority` pseudo-header.
- If the `Host` header does not match any constrained route and no unconstrained fallback exists, Fastify returns `404`.
- Regex constraints allow flexible subdomain or environment-based routing.

---

#### Combining Multiple Constraints

Multiple constraints can be applied to a single route simultaneously. All declared constraints must be satisfied for the route to match.

js

```
fastify.get('/resource', {
  constraints: {
    version: '2.0.0',
    host: 'api.example.com'
  }
}, async () => ({ matched: 'v2 on api subdomain' }));
```

**Key Points:**

- Constraint evaluation is conjunctive — all constraints must match.
- [Inference] Routes with more specific constraint combinations will only match requests that satisfy every declared condition, making them more narrowly targeted than single-constraint routes.

---

#### Custom Constraints

Fastify allows defining custom constraint strategies. A custom constraint is an object implementing a defined interface and registered on the Fastify instance at initialization time.

**Constraint strategy interface:**

js

```
const myConstraintStrategy = {
  name: 'myConstraint',          // unique name, used as key in constraints: {}
  storage() {
    const store = {};
    return {
      get(value) { return store[value] ?? null; },
      set(value, handler) { store[value] = handler; },
      del(value) { delete store[value]; },
      empty() { Object.keys(store).forEach(k => delete store[k]); }
    };
  },
  deriveConstraint(request, ctx) {
    // Extract the constraint value from the incoming request
    return request.headers['x-tenant-id'];
  },
  validate(value) {
    if (typeof value !== 'string') throw new Error('x-tenant-id must be a string');
  },
  mustMatchWhenDefined: true  // if true, routes with this constraint only match when header present
};
```

**Registering and using the custom constraint:**

js

```
const fastify = Fastify({
  constraints: {
    myConstraint: myConstraintStrategy
  }
});

fastify.get('/data', {
  constraints: { myConstraint: 'tenant-a' }
}, async () => ({ tenant: 'a' }));

fastify.get('/data', {
  constraints: { myConstraint: 'tenant-b' }
}, async () => ({ tenant: 'b' }));
```

**Request:** `GET /data` with header `x-tenant-id: tenant-a` → matches the `tenant-a` route.

**Key Points:**

- The `name` field must be unique across all registered constraints.
- `deriveConstraint` runs on every request against constrained routes — it should be fast and free of side effects.
- `mustMatchWhenDefined: true` means a route with this constraint will only be considered when the derived value is present. When `false`, the constraint is optional and routes may match without it.
- Custom constraint strategies are registered at instance creation time and cannot be added after `fastify.listen` or `fastify.ready` has been called.

> **Disclaimer:** The constraint strategy interface is defined by `find-my-way`. The exact required and optional fields should be verified against current `find-my-way` and Fastify documentation, as the interface may evolve across major versions.

---

#### Visual: Constraint-Based Route Resolution

<svg viewBox="0 0 680 310" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
<defs>
<marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
<path d="M0,0 L0,6 L8,3 z" fill="#888"/>
</marker>
</defs>
<!-- Incoming request -->
<rect x="220" y="10" width="240" height="44" rx="8" fill="#4A90D9"/>
<text x="340" y="28" text-anchor="middle" fill="white" font-weight="bold">Incoming Request</text>
<text x="340" y="46" text-anchor="middle" fill="white">GET /resource Accept-Version: 2.x</text>
<!-- Arrow -->
<line x1="340" y1="54" x2="340" y2="90" stroke="#888" stroke-width="1.5" marker-end="url(#arr)"/>
<!-- Router -->
<rect x="220" y="90" width="240" height="38" rx="8" fill="#7B68EE"/>
<text x="340" y="108" text-anchor="middle" fill="white" font-weight="bold">find-my-way</text>
<text x="340" y="122" text-anchor="middle" fill="white">path + constraint evaluation</text>
<!-- Three branches -->
<line x1="240" y1="128" x2="100" y2="175" stroke="#888" stroke-width="1.5" marker-end="url(#arr)"/>
<line x1="340" y1="128" x2="340" y2="175" stroke="#888" stroke-width="1.5" marker-end="url(#arr)"/>
<line x1="440" y1="128" x2="570" y2="175" stroke="#888" stroke-width="1.5" marker-end="url(#arr)"/>

<text x="148" y="160" text-anchor="middle" fill="#555">version: 1.0.0</text>
<text x="340" y="162" text-anchor="middle" fill="#555">version: 2.0.0</text>
<text x="510" y="160" text-anchor="middle" fill="#555">no constraint</text>

<!-- Route boxes -->
<rect x="20" y="175" width="160" height="38" rx="6" fill="#aaa"/>
<text x="100" y="193" text-anchor="middle" fill="white">GET /resource</text>
<text x="100" y="207" text-anchor="middle" fill="white">v1.0.0 — no match</text>
<rect x="240" y="175" width="200" height="38" rx="6" fill="#5CB85C"/>
<text x="340" y="193" text-anchor="middle" fill="white">GET /resource</text>
<text x="340" y="207" text-anchor="middle" fill="white">v2.0.0 — ✓ matched</text>
<rect x="490" y="175" width="170" height="38" rx="6" fill="#aaa"/>
<text x="575" y="193" text-anchor="middle" fill="white">GET /resource</text>
<text x="575" y="207" text-anchor="middle" fill="white">fallback — skipped</text>
<!-- Arrow to handler -->
<line x1="340" y1="213" x2="340" y2="255" stroke="#888" stroke-width="1.5" marker-end="url(#arr)"/>
<rect x="230" y="255" width="220" height="38" rx="6" fill="#4A90D9"/>
<text x="340" y="273" text-anchor="middle" fill="white" font-weight="bold">Handler Invoked</text>
<text x="340" y="289" text-anchor="middle" fill="white">{ release: '2.0.0' }</text>
</svg>

---

#### Version Constraint vs. URL-Based Versioning

Constraints-based versioning and prefix-based versioning (`/v1/`, `/v2/`) are both valid approaches. They serve different purposes and have different trade-offs.

| Aspect | Constraint versioning | Prefix versioning |
| --- | --- | --- |
| URL structure | Same path across versions | Different paths per version |
| Client requirement | Must send `Accept-Version` header | No special headers needed |
| Discoverability | Less visible to casual inspection | Immediately visible in URL |
| Route isolation | Scoped by constraint, same plugin | Scoped by prefix, separate plugins |
| Fallback behavior | Unconstrained route as default | No automatic fallback |

**Key Points:**

- Constraint-based versioning aligns with HTTP content negotiation conventions.
- Prefix-based versioning is simpler to reason about and easier to test manually.
- [Inference] The two approaches can be combined — e.g., prefix-based major versioning with constraint-based minor versioning — though this increases routing complexity.

---

#### Common Mistakes

**Expecting version fallback without an unconstrained route:**

js

```
fastify.get('/data', { constraints: { version: '1.0.0' } }, handlerV1);
fastify.get('/data', { constraints: { version: '2.0.0' } }, handlerV2);

// GET /data (no Accept-Version header) → 404
// No unconstrained fallback is registered
```

**Using version constraints without client coordination:**

js

```
// If clients do not send Accept-Version, constrained routes will never match
// Ensure the client layer is configured to send the header
```

**Registering custom constraints after server startup:**

js

```
// Custom constraint strategies must be declared at Fastify instantiation
// Adding them after fastify.ready() or fastify.listen() is not supported
```

**Mutating state in `deriveConstraint`:**

js

```
deriveConstraint(request, ctx) {
  // Avoid side effects — this runs on every matched request
  db.logAccess(request); // problematic
  return request.headers['x-tenant-id'];
}
```

---

**Conclusion**

Constraints extend Fastify's routing beyond URL path matching, enabling the same path to serve different handlers based on header values or custom request properties. The built-in `version` constraint implements semver-based API versioning via `Accept-Version`, while `host` enables virtual hosting and subdomain routing. Custom constraints provide a structured extension point for application-specific routing logic. All constraint strategies are evaluated by `find-my-way` at request time, so `deriveConstraint` implementations should be lightweight and side-effect free.

**Next Steps:** Fastify's lifecycle and request/reply objects.