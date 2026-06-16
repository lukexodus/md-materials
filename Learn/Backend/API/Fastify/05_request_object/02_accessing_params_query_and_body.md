### Accessing Params, Query, and Body

These three properties of the `request` object are the primary means of reading client-supplied data in Fastify. Each has distinct parsing behavior, validation integration, and type coercion characteristics worth understanding in depth.

---

#### Route Parameters — `request.params`

Route parameters are named segments in the route path, prefixed with `:`. Fastify extracts them from the matched URL and places them on `request.params`.

js

```
fastify.get('/user/:userId/post/:postId', async (request, reply) => {
  const { userId, postId } = request.params
  return { userId, postId }
})
```

**Example request:** `GET /user/42/post/7`

**Output:**

json

```
{ "userId": "42", "postId": "7" }
```

**Key Points:**

- All values are strings by default — no automatic numeric coercion
- Parameter names must be unique within a single route pattern
- Wildcard parameters using `*` place the matched segment under `request.params['*']`

##### Wildcard Parameter

js

```
fastify.get('/files/*', async (request, reply) => {
  return { path: request.params['*'] }
})
```

**Example request:** `GET /files/docs/report.pdf`

**Output:**

json

```
{ "path": "docs/report.pdf" }
```

##### Schema Validation and Coercion for Params

Defining a schema for `params` enables validation and — with `coerceTypes` — automatic type conversion.

js

```
fastify.get('/user/:id', {
  schema: {
    params: {
      type: 'object',
      properties: {
        id: { type: 'integer' }
      },
      required: ['id']
    }
  },
  handler: async (request, reply) => {
    // request.params.id is now a number, not a string
    return { id: request.params.id, type: typeof request.params.id }
  }
})
```

**Output:**

json

```
{ "id": 42, "type": "number" }
```

> [Inference] Fastify enables `coerceTypes` in its AJV configuration by default, which allows string values from the URL to be coerced into the declared schema type. Behavior may vary depending on your AJV configuration or custom validator setup.

---

#### Query String — `request.query`

The query string is the portion of the URL after `?`. Fastify parses it and exposes the result as a plain object on `request.query`.

js

```
fastify.get('/search', async (request, reply) => {
  const { term, page, limit } = request.query
  return { term, page, limit }
})
```

**Example request:** `GET /search?term=fastify&page=2&limit=10`

**Output:**

json

```
{ "term": "fastify", "page": "2", "limit": "10" }
```

**Key Points:**

- All values arrive as strings unless a schema with coercion is applied
- Repeated keys (e.g. `?tag=a&tag=b`) produce an array: `{ tag: ['a', 'b'] }`
- Fastify uses `fast-querystring` by default — verify against your installed version

##### Repeated Query Keys

js

```
// GET /filter?tag=js&tag=node&tag=fastify
fastify.get('/filter', async (request, reply) => {
  return { tags: request.query.tag }
})
```

**Output:**

json

```
{ "tags": ["js", "node", "fastify"] }
```

##### Schema Validation and Coercion for Query

js

```
fastify.get('/items', {
  schema: {
    querystring: {
      type: 'object',
      properties: {
        page:  { type: 'integer', default: 1 },
        limit: { type: 'integer', default: 20 },
        active: { type: 'boolean' }
      }
    }
  },
  handler: async (request, reply) => {
    const { page, limit, active } = request.query
    return { page, limit, active }
  }
})
```

**Example request:** `GET /items?page=3&active=true`

**Output:**

json

```
{ "page": 3, "limit": 20, "active": true }
```

**Key Points:**

- The schema key is `querystring`, not `query` — using `query` may work in some versions but `querystring` is the documented key; verify against your version
- `default` values in the schema are applied when a key is absent from the request
- Boolean coercion maps the string `"true"` to `true` and `"false"` to `false`

##### Custom Query String Parser

js

```
import qs from 'qs'

const fastify = Fastify({
  querystringParser: str => qs.parse(str)
})
```

Using `qs` enables nested object parsing (e.g. `?filter[name]=alice&filter[age]=30`), which the default parser does not support.

---

#### Request Body — `request.body`

The parsed body of the incoming request. Fastify populates this automatically for content types it knows how to handle.

##### Default Content Type Support

Out of the box, Fastify parses `application/json` bodies.

js

```
fastify.post('/user', async (request, reply) => {
  const { name, email } = request.body
  return { created: true, name }
})
```

**Example request:**

```
POST /user
Content-Type: application/json

{ "name": "Alice", "email": "alice@example.com" }
```

**Output:**

json

```
{ "created": true, "name": "Alice" }
```

##### Schema Validation for Body

js

```
fastify.post('/user', {
  schema: {
    body: {
      type: 'object',
      required: ['name', 'email'],
      properties: {
        name:  { type: 'string', minLength: 1 },
        email: { type: 'string', format: 'email' },
        age:   { type: 'integer', minimum: 0 }
      },
      additionalProperties: false
    }
  },
  handler: async (request, reply) => {
    return { received: request.body }
  }
})
```

**Key Points:**

- Validation runs after parsing, before the handler is called
- A validation failure produces a `400` response automatically with error details
- `additionalProperties: false` rejects bodies with undeclared keys

##### Parsing `text/plain`

Fastify does not parse `text/plain` by default. You must add a content type parser.

js

```
fastify.addContentTypeParser(
  'text/plain',
  { parseAs: 'string' },
  (request, body, done) => {
    done(null, body)
  }
)

fastify.post('/echo', async (request, reply) => {
  return { received: request.body }
})
```

##### Parsing `application/x-www-form-urlencoded`

Form-encoded bodies also require a custom parser or a plugin such as `@fastify/formbody`.

js

```
import formbody from '@fastify/formbody'

await fastify.register(formbody)

fastify.post('/form', async (request, reply) => {
  // request.body is now a parsed object from form data
  return request.body
})
```

##### Parsing `multipart/form-data`

File uploads and multipart form data require `@fastify/multipart`.

js

```
import multipart from '@fastify/multipart'

await fastify.register(multipart)

fastify.post('/upload', async (request, reply) => {
  const data = await request.file()
  return { filename: data.filename }
})
```

##### Body Access on Non-Body Methods

`request.body` is `null` for `GET`, `HEAD`, `DELETE`, and `OPTIONS` requests by default, as these methods conventionally carry no body.

> [Inference] Sending a body with a `GET` request is technically permitted by HTTP but discouraged. Fastify's behavior when receiving such a request may vary by version and configuration — do not rely on `request.body` being populated for `GET` requests.

---

#### Validation Failure Behavior

When a schema is defined and the incoming data fails validation, Fastify responds before the handler is invoked.

```
HTTP/1.1 400 Bad Request
Content-Type: application/json

{
  "statusCode": 400,
  "error": "Bad Request",
  "message": "body must have required property 'email'"
}
```

You can customize this behavior using `setErrorHandler` or `setSchemaErrorFormatter`.

---

#### Interaction Between All Three

A single route can validate all three simultaneously.

js

```
fastify.post('/org/:orgId/user', {
  schema: {
    params: {
      type: 'object',
      properties: { orgId: { type: 'integer' } },
      required: ['orgId']
    },
    querystring: {
      type: 'object',
      properties: { notify: { type: 'boolean', default: false } }
    },
    body: {
      type: 'object',
      required: ['name'],
      properties: {
        name:  { type: 'string' },
        email: { type: 'string', format: 'email' }
      }
    }
  },
  handler: async (request, reply) => {
    const { orgId } = request.params
    const { notify } = request.query
    const { name, email } = request.body

    return { orgId, notify, name, email }
  }
})
```

**Example request:**

```
POST /org/5/user?notify=true
Content-Type: application/json

{ "name": "Bob", "email": "bob@example.com" }
```

**Output:**

json

```
{ "orgId": 5, "notify": true, "name": "Bob", "email": "bob@example.com" }
```

---

#### Summary

| Property | Source | Raw Type | Coercion Available |
| --- | --- | --- | --- |
| `request.params` | URL path segments | `string` | Yes, via schema |
| `request.query` | URL query string | `string` | Yes, via schema |
| `request.body` | Request body payload | parsed per content type | Yes, via schema |

---

#### Related Topics

- JSON Schema validation and AJV configuration
- Custom content type parsers
- Error handling and validation error formatting
- `@fastify/formbody` and `@fastify/multipart`