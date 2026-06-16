### Query String Handling

#### Overview

Fastify parses query strings automatically for every incoming request. The parsed result is available on `request.query` as a plain object. Fastify uses a built-in query string parser by default, and supports swapping it out for a custom implementation when needed.

---

#### Accessing Query Parameters

No configuration is required to read query parameters. They are available immediately in any route handler.

js

```
fastify.get('/search', async (request, reply) => {
  const { term, page } = request.query;
  return { term, page };
});
```

**Example request:** `GET /search?term=fastify&page=2`

**Output:**

json

```
{ "term": "fastify", "page": "2" }
```

**Key Points:**

- All values are strings by default. Type coercion does not occur unless schema validation with Ajv coercion is active.
- `request.query` is a plain object populated before the handler runs.
- If a key appears in the URL but has no value (e.g., `?flag`), its value will be an empty string `""`.

---

#### Schema Validation and Coercion

Fastify supports JSON Schema validation for query strings via the `schema.querystring` (or `schema.query`) property on a route definition.

> **Disclaimer:** Coercion behavior depends on Ajv configuration. Actual results may vary based on the version and settings in use.

js

```
fastify.get(
  '/items',
  {
    schema: {
      querystring: {
        type: 'object',
        properties: {
          page:  { type: 'integer' },
          limit: { type: 'integer' },
          q:     { type: 'string' }
        },
        required: ['page']
      }
    }
  },
  async (request, reply) => {
    const { page, limit, q } = request.query;
    return { page, limit, q };
  }
);
```

**Example request:** `GET /items?page=1&limit=10&q=widget`

**Output:**

json

```
{ "page": 1, "limit": 10, "q": "widget" }
```

**Key Points:**

- With Ajv's `coerceTypes` enabled (Fastify's default), string values that match the declared type are coerced — `"1"` becomes `1` for an `integer` field.
- If a `required` field is missing, Fastify returns `400 Bad Request` before the handler runs.
- `schema.querystring` and `schema.query` are both accepted; they are aliases. `querystring` is the conventional form.

---

#### Repeated Keys (Array Parameters)

When the same key appears multiple times in a query string, the default parser collects them into an array.

js

```
fastify.get('/filter', async (request, reply) => {
  return { tags: request.query.tags };
});
```

**Example request:** `GET /filter?tags=a&tags=b&tags=c`

**Output:**

json

```
{ "tags": ["a", "b", "c"] }
```

To validate this in a schema:

js

```
schema: {
  querystring: {
    type: 'object',
    properties: {
      tags: {
        type: 'array',
        items: { type: 'string' }
      }
    }
  }
}
```

**Key Points:**

- A single occurrence of a key produces a string; multiple occurrences produce an array. This asymmetry can cause type inconsistencies if not handled with schema validation.
- Using a schema with `type: 'array'` and Ajv coercion active [Inference] may normalize a single value into a single-element array, but this should be verified against your Ajv version and configuration.

---

#### Nested and Complex Query Strings

Fastify's default parser does not support nested object notation (e.g., `?filter[name]=foo`). For nested or complex query string formats, a custom parser is required.

**Default behavior — no nesting support:**

js

```
// GET /data?filter[name]=foo
// request.query → { 'filter[name]': 'foo' }  (treated as a literal key)
```

---

#### Custom Query String Parser

Fastify accepts a `querystringParser` option at the server level, allowing a fully custom parsing function.

js

```
import Fastify from 'fastify';
import qs from 'qs';

const fastify = Fastify({
  querystringParser: str => qs.parse(str)
});
```

With `qs`, nested objects and arrays using bracket notation are supported:

**Example request:** `GET /data?filter[name]=foo&filter[active]=true`

**Output of `request.query`:**

json

```
{
  "filter": {
    "name": "foo",
    "active": "true"
  }
}
```

**Key Points:**

- The `querystringParser` function receives the raw query string (without the leading `?`) and must return a plain object.
- The custom parser applies globally to all routes on that Fastify instance.
- Popular choices include `qs` and `querystring` (Node.js built-in, now legacy).
- Schema validation still applies after custom parsing; the parsed object is validated against the declared schema if one exists.

---

#### Raw Query String Access

If the raw, unparsed query string is needed, it is available via `request.raw.url` or by splitting on `?`.

js

```
fastify.get('/raw', async (request, reply) => {
  const raw = request.raw.url.split('?')[1] ?? '';
  return { raw };
});
```

**Example request:** `GET /raw?a=1&b=2`

**Output:**

json

```
{ "raw": "a=1&b=2" }
```

Alternatively, `request.url` on the Fastify request object also contains the full path including the query string.

---

#### Visual: Query String Processing Pipeline

<svg viewBox="0 0 680 120" xmlns="http://www.w3.org/2000/svg" font-family="monospace" font-size="12">
<defs>
<marker id="arr" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
<path d="M0,0 L0,6 L8,3 z" fill="#888"/>
</marker>
</defs>
<!-- Step 1 -->
<rect x="10" y="40" width="130" height="40" rx="6" fill="#4A90D9"/>
<text x="75" y="57" text-anchor="middle" fill="white" font-weight="bold">Incoming URL</text>
<text x="75" y="73" text-anchor="middle" fill="white">/path?a=1&amp;b=2</text>
<line x1="140" y1="60" x2="170" y2="60" stroke="#888" stroke-width="1.5" marker-end="url(#arr)"/>
<!-- Step 2 -->
<rect x="170" y="40" width="150" height="40" rx="6" fill="#7B68EE"/>
<text x="245" y="57" text-anchor="middle" fill="white" font-weight="bold">querystringParser</text>
<text x="245" y="73" text-anchor="middle" fill="white">(default or custom)</text>
<line x1="320" y1="60" x2="350" y2="60" stroke="#888" stroke-width="1.5" marker-end="url(#arr)"/>
<!-- Step 3 -->
<rect x="350" y="40" width="150" height="40" rx="6" fill="#F5A623"/>
<text x="425" y="57" text-anchor="middle" fill="white" font-weight="bold">Schema Validation</text>
<text x="425" y="73" text-anchor="middle" fill="white">&amp; Ajv Coercion</text>
<line x1="500" y1="60" x2="530" y2="60" stroke="#888" stroke-width="1.5" marker-end="url(#arr)"/>
<!-- Step 4 -->
<rect x="530" y="40" width="140" height="40" rx="6" fill="#5CB85C"/>
<text x="600" y="57" text-anchor="middle" fill="white" font-weight="bold">request.query</text>
<text x="600" y="73" text-anchor="middle" fill="white">(plain object)</text>
</svg>

---

#### Common Mistakes

**Assuming numeric types without a schema:**

js

```
// Without schema coercion, page is '2' (string), not 2 (number)
const { page } = request.query;
const offset = page * 10; // NaN risk if arithmetic is expected
```

**Not accounting for single vs. array inconsistency:**

js

```
// One tag → string. Two tags → array.
// Without schema enforcement, downstream code may break on either shape.
const { tags } = request.query;
tags.map(...); // throws if tags is a string
```

**Expecting nested keys without a custom parser:**

js

```
// GET /search?filter[type]=book
// Default parser gives: { 'filter[type]': 'book' }
// Not: { filter: { type: 'book' } }
```

---

**Conclusion**

Fastify parses query strings automatically and exposes the result on `request.query`. For simple flat key-value parameters, the default parser is sufficient. Schema validation with `querystring` adds type safety and coercion. For nested structures or bracket notation, a custom parser such as `qs` should be configured at the instance level. Awareness of the single-value vs. array asymmetry is important when handling repeated keys without schema enforcement.

**Next Steps:** Route-level hooks and `preHandler`.