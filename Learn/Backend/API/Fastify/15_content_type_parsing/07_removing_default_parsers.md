## Removing Default Parsers

Fastify registers two content type parsers by default at startup: one for `application/json` and one for `text/plain`. Both can be removed individually or together. This is necessary when replacing them with custom implementations, or when you want Fastify to reject those content types explicitly.

---

### Why Remove Default Parsers

**Key Points:**
- Attempting to register a parser for a content type that already has one throws an error at startup
- Removing the default parser for `application/json` is required before substituting a custom JSON library or reviver
- Removing `text/plain` may be appropriate when your API does not accept plain text bodies and you want a hard `415` rejection rather than silent acceptance
- [Inference] Removing parsers without replacing them changes the observable API contract for clients; existing integrations sending those content types will receive `415 Unsupported Media Type` — communicate this change if applicable

---

### The Two Removal Methods

Fastify provides two distinct methods:

| Method | Effect |
|---|---|
| `removeContentTypeParser(contentType)` | Removes one or more specific parsers |
| `removeAllContentTypeParsers()` | Removes every registered parser, including all built-ins |

Both are synchronous and must be called before the server starts listening — typically during plugin registration or server setup.

---

### `removeContentTypeParser`

Removes a parser for a specific content type string or an array of content type strings.

#### Removing a single parser

```js
import Fastify from 'fastify'

const fastify = Fastify()

fastify.removeContentTypeParser('application/json')
```

After this call, requests with `Content-Type: application/json` will receive `415 Unsupported Media Type` unless a new parser is registered.

#### Removing multiple parsers at once

```js
fastify.removeContentTypeParser(['application/json', 'text/plain'])
```

**Key Points:**
- The argument must match the exact string used when the parser was registered
- Passing a content type string for which no parser exists does not throw; it silently does nothing
- [Inference] Passing a `RegExp` to `removeContentTypeParser` is not documented as supported in current stable Fastify releases; removing a regex-registered parser by its original pattern may not work as expected — verify against your version

---

### `removeAllContentTypeParsers`

Removes every parser currently registered on the instance, including both Fastify built-ins.

```js
import Fastify from 'fastify'

const fastify = Fastify()

fastify.removeAllContentTypeParsers()
```

After this call, all incoming requests with any `Content-Type` that has a body will receive `415 Unsupported Media Type` until new parsers are registered.

**Key Points:**
- This is the appropriate starting point when you want full control over which content types are accepted
- It does not affect parsers registered in child plugin scopes that have not yet been initialized; order of registration matters

---

### Removing and Replacing in Sequence

The typical pattern is remove then register:

```js
import Fastify from 'fastify'
import secureJson from 'secure-json-parse'

const fastify = Fastify()

fastify.removeContentTypeParser('application/json')

fastify.addContentTypeParser(
  'application/json',
  { parseAs: 'buffer' },
  function (req, body, done) {
    try {
      done(null, secureJson.parse(body))
    } catch (err) {
      err.statusCode = 400
      done(err)
    }
  }
)
```

**Key Points:**
- The removal and registration must occur on the same instance
- Reversing the order — registering before removing — throws because the parser already exists when `addContentTypeParser` is called

---

### Using `removeAllContentTypeParsers` Before Selective Registration

When you want to support only specific content types and reject everything else:

```js
import Fastify from 'fastify'
import { parse } from 'node:querystring'

const fastify = Fastify()

fastify.removeAllContentTypeParsers()

fastify.addContentTypeParser(
  'application/json',
  { parseAs: 'string' },
  function (req, body, done) {
    try {
      done(null, JSON.parse(body))
    } catch (err) {
      err.statusCode = 400
      done(err)
    }
  }
)

fastify.addContentTypeParser(
  'application/x-www-form-urlencoded',
  { parseAs: 'string' },
  function (req, body, done) {
    try {
      done(null, parse(body))
    } catch (err) {
      err.statusCode = 400
      done(err)
    }
  }
)
```

Now only `application/json` and `application/x-www-form-urlencoded` are accepted. Any other content type returns `415`.

---

### Scoping Behavior

Removal follows Fastify's plugin encapsulation model.

```js
import Fastify from 'fastify'

const fastify = Fastify()

fastify.register(async function (instance) {
  instance.removeContentTypeParser('application/json')

  instance.addContentTypeParser(
    'application/json',
    { parseAs: 'string' },
    function (req, body, done) {
      try {
        done(null, JSON.parse(body))
      } catch (err) {
        err.statusCode = 400
        done(err)
      }
    }
  )

  instance.post('/scoped', async (request, reply) => {
    return request.body
  })
})

fastify.post('/root', async (request, reply) => {
  // Uses the original built-in JSON parser
  return request.body
})

await fastify.listen({ port: 3000 })
```

**Key Points:**
- `removeContentTypeParser` inside a plugin affects only that plugin's scope and its children
- The root instance retains its original parsers
- [Inference] This scoping behavior follows the same encapsulation rules as decorators and hooks; a child plugin cannot remove a parser from the parent scope

---

### Removing `text/plain`

The `text/plain` default parser delivers the raw body as a string to `request.body`. Removing it causes Fastify to reject plain text requests:

```js
fastify.removeContentTypeParser('text/plain')
```

**Example — before removal:**

```
POST /echo
Content-Type: text/plain

Hello world
```

`request.body` → `"Hello world"`

**Example — after removal:**

```
HTTP/1.1 415 Unsupported Media Type
```

**Key Points:**
- If your API is JSON-only, removing `text/plain` prevents accidental acceptance of unstructured bodies
- [Inference] Some HTTP clients and proxies may send `text/plain` as a fallback or default; removing this parser may cause unexpected `415` responses in integration scenarios — test client behavior before removing in production

---

### Verifying Parser State

Use `hasContentTypeParser` to confirm a parser is present or absent:

```js
console.log(fastify.hasContentTypeParser('application/json')) // true (default)

fastify.removeContentTypeParser('application/json')

console.log(fastify.hasContentTypeParser('application/json')) // false
```

This is useful in plugins that conditionally register parsers:

```js
fastify.register(async function (instance) {
  if (instance.hasContentTypeParser('application/json')) {
    instance.removeContentTypeParser('application/json')
  }

  instance.addContentTypeParser(
    'application/json',
    { parseAs: 'buffer' },
    async function (req, body) {
      return JSON.parse(body)
    }
  )
})
```

---

### Interaction with `catchAllContentTypeParser`

Fastify also supports a catch-all parser registered with `addContentTypeParser` using `'*'` as the content type. Removing all parsers with `removeAllContentTypeParsers` also removes any catch-all parser that was registered:

```js
fastify.addContentTypeParser('*', function (req, payload, done) {
  done(null, payload) // pass stream through
})

fastify.removeAllContentTypeParsers()
// The '*' catch-all is also removed
```

**Key Points:**
- Register the catch-all after `removeAllContentTypeParsers` if you still need it
- A catch-all parser receives any content type not matched by a more specific parser

---

### Common Mistakes

| Mistake | Effect |
|---|---|
| Calling `addContentTypeParser` before `removeContentTypeParser` for the same type | Throws at startup: parser already registered |
| Removing in a child plugin expecting parent to be affected | Parent scope is unchanged; encapsulation boundary is not crossed |
| Calling removal methods after `fastify.listen()` | [Unverified] Behavior is undefined; parser modifications should occur during setup before the server starts |
| Passing a regex to `removeContentTypeParser` | [Unverified] Not documented as supported; results may be unexpected |
| Forgetting to re-register after `removeAllContentTypeParsers` | All content types return `415` until new parsers are added |

---

### Summary of Methods

```js
// Remove one
fastify.removeContentTypeParser('application/json')

// Remove several
fastify.removeContentTypeParser(['application/json', 'text/plain'])

// Remove all
fastify.removeAllContentTypeParsers()

// Check presence
fastify.hasContentTypeParser('application/json') // boolean
```

---

**Conclusion:**
Removing default parsers is a necessary step before replacing them, and a deliberate choice when restricting which content types your API accepts. The two removal methods — targeted and blanket — serve different purposes. Both follow Fastify's encapsulation model, meaning removals are scoped to the instance they are called on. Always pair a removal with an explicit re-registration if the content type still needs to be supported, and use `hasContentTypeParser` for conditional logic in reusable plugins.