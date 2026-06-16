### Reply Object — Redirects

A redirect instructs the client to navigate to a different URL. Fastify provides a dedicated method on the `reply` object to send redirect responses without manually setting status codes and `Location` headers.

---

#### The `reply.redirect()` Method

`reply.redirect(url)` sends a redirect response to the client with a `Location` header pointing to the target URL.

js

```
fastify.get('/old-path', async (request, reply) => {
  return reply.redirect('/new-path');
});
```

By default, Fastify uses HTTP status code `302` (Found) for redirects.

---

#### Specifying a Status Code

You can specify the redirect status code by chaining `reply.code()` before calling `reply.redirect()`, or by passing it as a second argument.

**Using `reply.code()` (recommended pattern):**

js

```
fastify.get('/moved', async (request, reply) => {
  return reply.code(301).redirect('/permanent-location');
});
```

**Passing the code directly (Fastify v4.x+):**

js

```
fastify.get('/moved', async (request, reply) => {
  return reply.redirect('/permanent-location', 301);
});
```

> [Inference] Both approaches produce the same HTTP response. The two-argument form was introduced to provide a more concise API. Confirm the supported signature against your installed Fastify version, as behavior may vary across minor versions.

---

#### Common Redirect Status Codes

| Code | Name | Typical Use |
| --- | --- | --- |
| `301` | Moved Permanently | Resource has permanently moved; clients and search engines update their records |
| `302` | Found | Temporary redirect; default in Fastify |
| `303` | See Other | Redirect after a POST to a GET endpoint |
| `307` | Temporary Redirect | Temporary redirect; preserves the HTTP method |
| `308` | Permanent Redirect | Permanent redirect; preserves the HTTP method |

**Key distinction — method preservation:**

- `301` and `302` allow clients to switch to `GET` on redirect (many browsers do this)
- `307` and `308` require clients to repeat the original method (e.g., `POST` stays `POST`)

---

#### Redirecting to an Absolute URL

`reply.redirect()` accepts both relative and absolute URLs.

js

```
fastify.get('/go-external', async (request, reply) => {
  return reply.redirect('https://example.com/landing');
});
```

> [Inference] Fastify passes the URL string directly into the `Location` header without validation. It is the developer's responsibility to sanitize redirect targets, particularly when they are derived from user input.

---

#### Open Redirect Risk

When the redirect target is built from user-supplied input, unvalidated redirects can be exploited to send users to malicious sites.

**Unsafe pattern:**

js

```
fastify.get('/forward', async (request, reply) => {
  const { to } = request.query;
  return reply.redirect(to); // [Unverified] — dangerous if 'to' is not validated
});
```

**Safer pattern — allowlist approach:**

js

```
const ALLOWED = new Set(['/dashboard', '/profile', '/home']);

fastify.get('/forward', async (request, reply) => {
  const { to } = request.query;

  if (!ALLOWED.has(to)) {
    return reply.code(400).send({ error: 'Invalid redirect target' });
  }

  return reply.redirect(to);
});
```

> [Inference] An allowlist approach reduces the surface area for open redirect attacks. No single technique eliminates the risk entirely; defense in depth is advisable.

---

#### Redirects in Non-Async Handlers

Redirects work the same way in callback-style handlers. Return or call `reply.redirect()` once and do not call `reply.send()` afterward.

js

```
fastify.get('/legacy', (request, reply) => {
  reply.redirect('/new-path');
});
```

> [Inference] Calling both `reply.redirect()` and `reply.send()` in the same handler may cause an error or result in undefined behavior, since the response can only be sent once. Behavior may vary.

---

#### Redirects Inside Hooks

You can issue a redirect from a hook to short-circuit a request before it reaches the route handler.

js

```
fastify.addHook('onRequest', async (request, reply) => {
  if (!request.headers['x-api-key']) {
    return reply.redirect('/unauthorized');
  }
});
```

Returning the result of `reply.redirect()` inside an `async` hook signals to Fastify that the response has been handled and the request lifecycle should stop.

> [Inference] This is a common pattern for authentication guards. The actual lifecycle termination behavior depends on Fastify's hook execution model and may vary in edge cases.

---

#### Redirect vs. Manual Header Setting

`reply.redirect()` is shorthand for setting the `Location` header and sending a response with an appropriate status code. The two approaches below are functionally equivalent:

**Using `reply.redirect()`:**

js

```
return reply.code(301).redirect('/new');
```

**Manual equivalent:**

js

```
reply.code(301);
reply.header('Location', '/new');
return reply.send();
```

Prefer `reply.redirect()` for clarity and conciseness. The manual approach may be useful when additional header manipulation is needed before the response is sent.

---

#### What `reply.redirect()` Does Internally

At a high level, the method:

1. Sets the `Location` header to the provided URL
2. Sets the response status code (default `302`, or as specified)
3. Calls `reply.send()` to finalize and flush the response

> [Inference] This is a reasonable description based on Fastify's documented behavior and open-source codebase. Internal implementation details may change across versions.

---

#### Summary

| Scenario | Recommended Approach |
| --- | --- |
| Temporary redirect (default) | `reply.redirect('/path')` |
| Permanent redirect | `reply.code(301).redirect('/path')` |
| Method-preserving redirect | `reply.code(307).redirect('/path')` |
| Post-to-get redirect | `reply.code(303).redirect('/path')` |
| Redirect in a hook | `return reply.redirect('/path')` inside async hook |
| External URL | `reply.redirect('https://example.com')` |
| User-supplied target | Validate against an allowlist before redirecting |