## File Size and Field Limits

`@fastify/multipart` exposes a granular limits API inherited from `busboy`. These limits control how much data the server accepts before truncating or rejecting parts of a multipart request. Setting them correctly is a prerequisite for safe production deployments.

---

### Why Limits Matter

Without explicit limits, the defaults for most fields are `Infinity`. An unconstrained server accepts:

- Files of arbitrary size, exhausting disk or memory
- Arbitrarily many fields or files per request
- Field names and values of arbitrary length

**Key Points:**
- Limits are enforced by `busboy` before data reaches your handler
- [Inference] Running without explicit limits in production exposes the server to resource exhaustion via oversized or numerous uploads; set limits appropriate to your application's requirements
- Limits operate on raw bytes, not parsed values

---

### The `limits` Object

All limit options are passed under the `limits` key during plugin registration:

```js
await fastify.register(multipart, {
  limits: {
    fieldNameSize: 100,       // max field name length in bytes
    fieldSize:     1048576,   // max non-file field value size in bytes (1 MB)
    fields:        10,        // max number of non-file fields
    fileSize:      5242880,   // max file size in bytes (5 MB)
    files:         5,         // max number of file parts
    headerPairs:   2000,      // max header key-value pairs per part
    parts:         15         // max total parts (fields + files combined)
  }
})
```

---

### Limit Reference

| Option | Default | Unit | Controls |
|---|---|---|---|
| `fieldNameSize` | `100` | bytes | Maximum length of a field or file input name |
| `fieldSize` | `1048576` | bytes | Maximum size of a non-file field value |
| `fields` | `Infinity` | count | Maximum number of non-file text fields |
| `fileSize` | `Infinity` | bytes | Maximum size of a single file |
| `files` | `Infinity` | count | Maximum number of file parts |
| `headerPairs` | `2000` | count | Maximum header key-value pairs per part |
| `parts` | `Infinity` | count | Maximum total parts (fields + files) |

**Key Points:**
- `fieldNameSize` and `fieldSize` have non-infinite defaults; all others default to `Infinity`
- `parts` is a ceiling over the combined total of `fields` and `files`; setting all three is more precise than relying on `parts` alone
- `headerPairs` limits per-part headers, not request headers

---

### `fileSize` — Per-File Size Limit

Controls the maximum number of bytes accepted for a single file part.

```js
await fastify.register(multipart, {
  limits: { fileSize: 10 * 1024 * 1024 } // 10 MB
})
```

#### Behavior When Exceeded

The behavior depends on `throwFileSizeLimit`:

```js
await fastify.register(multipart, {
  throwFileSizeLimit: true, // default
  limits: { fileSize: 5 * 1024 * 1024 }
})
```

| `throwFileSizeLimit` | Behavior when `fileSize` exceeded |
|---|---|
| `true` (default) | Fastify automatically responds `413 Payload Too Large`; handler is not reached |
| `false` | Stream is truncated silently; `part.file.truncated` is set to `true`; handler continues |

#### Checking Truncation Manually (`throwFileSizeLimit: false`)

```js
await fastify.register(multipart, {
  throwFileSizeLimit: false,
  limits: { fileSize: 5 * 1024 * 1024 }
})

fastify.post('/upload', async (request, reply) => {
  const part = await request.file()

  if (!part) {
    return reply.status(400).send({ error: 'No file provided' })
  }

  const buffer = await part.toBuffer()

  if (part.file.truncated) {
    return reply.status(413).send({
      error: 'File exceeds 5 MB limit',
      received: buffer.length
    })
  }

  return { size: buffer.length }
})
```

**Key Points:**
- `part.file.truncated` is only reliable after the stream is fully consumed
- With `throwFileSizeLimit: true`, your handler never runs for oversized files; no manual check is needed
- With `throwFileSizeLimit: false`, you are responsible for checking and responding; forgetting to check means accepting truncated data silently

---

### `files` — Maximum File Count

Limits the number of file parts accepted per request.

```js
await fastify.register(multipart, {
  limits: { files: 3 }
})
```

**Key Points:**
- When `files` is exceeded, `busboy` emits a `'filesLimit'` event
- [Inference] `@fastify/multipart` handles the `filesLimit` event internally; the exact HTTP response code returned when this limit is breached depends on the plugin version — verify against your installed version's behavior
- Parts beyond the limit are silently dropped by `busboy`; the handler receives only the permitted number of file parts

---

### `fields` — Maximum Non-File Field Count

Limits the number of text fields accepted.

```js
await fastify.register(multipart, {
  limits: { fields: 5 }
})
```

**Key Points:**
- Fields beyond the limit are silently ignored by `busboy`
- [Inference] Silent field dropping means your handler may receive an incomplete set of fields without any error signal; validate that all required fields are present after parsing

---

### `parts` — Total Parts Ceiling

Limits the combined count of fields and files.

```js
await fastify.register(multipart, {
  limits: {
    fields: 10,
    files:  5,
    parts:  15 // consistent with fields + files
  }
})
```

**Key Points:**
- `parts` is a hard ceiling; even if `fields` and `files` individually permit more, `parts` caps the total
- Setting `parts` to a value lower than `fields + files` means the combined limit will be hit first
- [Inference] Inconsistent values between `fields`, `files`, and `parts` may produce confusing behavior; set them consistently or omit `parts` and rely on `fields` and `files` separately

---

### `fieldSize` — Non-File Field Value Size

Limits the size of individual text field values in bytes.

```js
await fastify.register(multipart, {
  limits: { fieldSize: 65536 } // 64 KB
})
```

**Key Points:**
- The default is 1 MB (1048576 bytes), which is already set; this is one of the two non-infinite defaults
- Fields exceeding this limit are truncated; the truncated value is delivered to the handler without error
- [Inference] Silent truncation of field values may cause validation to pass on an incomplete value; be especially careful with fields that carry structured data like JSON strings

---

### `fieldNameSize` — Field Name Length

Limits the byte length of field and file input names.

```js
await fastify.register(multipart, {
  limits: { fieldNameSize: 50 }
})
```

**Key Points:**
- The default is 100 bytes
- Field names exceeding this limit cause the part to be skipped
- In practice, form field names are short and rarely approach this limit; the default is generally sufficient

---

### `headerPairs` — Per-Part Header Count

Limits the number of header key-value pairs in each part's header block.

```js
await fastify.register(multipart, {
  limits: { headerPairs: 100 }
})
```

**Key Points:**
- The default is 2000, matching Node.js's own HTTP header limit
- This is rarely a concern for standard form submissions
- [Inference] Reducing this value may reject malformed or adversarially crafted multipart requests with inflated part headers, though actual security benefit depends on your threat model

---

### Per-Request Limit Overrides

Limits set at registration time are defaults. Individual handler calls can override them:

```js
fastify.post('/avatar', async (request, reply) => {
  const part = await request.file({
    limits: { fileSize: 2 * 1024 * 1024 } // 2 MB for this route only
  })

  if (!part) {
    return reply.status(400).send({ error: 'No file provided' })
  }

  const buffer = await part.toBuffer()

  if (part.file.truncated) {
    return reply.status(413).send({ error: 'Avatar must be under 2 MB' })
  }

  return { size: buffer.length }
})
```

```js
fastify.post('/documents', async (request, reply) => {
  const files = await request.saveRequestFiles({
    limits: {
      fileSize: 20 * 1024 * 1024, // 20 MB per file for documents
      files: 3
    }
  })

  return { count: files.length }
})
```

**Key Points:**
- Per-call limits apply only to that invocation; the plugin-level defaults remain unchanged for other routes
- Per-call overrides are available on `request.file()`, `request.files()`, `request.parts()`, and `request.saveRequestFiles()`

---

### Route-Level Limit Strategy

A practical pattern is to set conservative global limits at registration and loosen them per route as needed:

```js
// Conservative global defaults
await fastify.register(multipart, {
  limits: {
    fileSize: 1 * 1024 * 1024,  // 1 MB default
    files: 1,
    fields: 5,
    parts: 6
  }
})

// Standard upload: uses global limits
fastify.post('/upload', async (request, reply) => {
  const part = await request.file()
  // ...
})

// Bulk upload: explicitly relaxed
fastify.post('/bulk-upload', async (request, reply) => {
  const parts = request.files({
    limits: {
      fileSize: 50 * 1024 * 1024, // 50 MB per file
      files: 20
    }
  })

  const results = []
  for await (const part of parts) {
    const buffer = await part.toBuffer()
    results.push({ filename: part.filename, size: buffer.length })
  }

  return { files: results }
})
```

---

### Combining with Fastify's `bodyLimit`

Fastify's top-level `bodyLimit` applies to all request bodies before any content-type parser or multipart plugin processes them. It is a raw byte ceiling on the entire request body.

```js
const fastify = Fastify({
  bodyLimit: 200 * 1024 * 1024 // 200 MB raw body ceiling
})

await fastify.register(multipart, {
  limits: {
    fileSize: 50 * 1024 * 1024,  // 50 MB per file
    files: 3                      // max 3 files
    // effective max payload ≈ 150 MB, within the 200 MB bodyLimit
  }
})
```

**Key Points:**
- `bodyLimit` is enforced first; a request exceeding it receives `413` before multipart parsing begins
- `limits.fileSize` is enforced per file during streaming; it is a tighter, more granular control
- Both should be set consistently; a `bodyLimit` lower than `files × fileSize` means the body limit will trigger before the per-file limit

---

### Checking Limits Programmatically

If you need to reflect configured limits in a response (e.g., to inform clients of upload constraints):

```js
const FILE_SIZE_LIMIT = 5 * 1024 * 1024

await fastify.register(multipart, {
  limits: { fileSize: FILE_SIZE_LIMIT }
})

fastify.get('/upload-config', async (request, reply) => {
  return {
    maxFileSize: FILE_SIZE_LIMIT,
    maxFileSizeMB: FILE_SIZE_LIMIT / (1024 * 1024)
  }
})
```

**Key Points:**
- Store limit values as named constants rather than inline literals; this makes them reusable across registration and informational endpoints

---

### Detecting Limit Events Directly (Advanced)

`busboy` emits named events when specific limits are hit. `@fastify/multipart` handles these internally, but you can observe them on the `busboy` instance if needed through lower-level access.

**Key Points:**
- `'filesLimit'` fires when the `files` count is reached
- `'fieldsLimit'` fires when the `fields` count is reached
- `'partsLimit'` fires when the `parts` count is reached
- [Unverified] Direct access to the underlying `busboy` instance through `@fastify/multipart`'s public API is not documented as stable; this approach may change across plugin versions — treat as internal behavior

---

### Common Mistakes

| Mistake | Effect |
|---|---|
| Leaving `fileSize` at `Infinity` | Server accepts arbitrarily large files; memory or disk exhaustion possible |
| Leaving `files` at `Infinity` | Single request can upload unbounded numbers of files |
| Using `throwFileSizeLimit: false` without checking `truncated` | Truncated files accepted and stored silently |
| Checking `part.file.truncated` before consuming the stream | May yield incorrect result; only reliable after full consumption |
| Setting `parts` lower than `fields + files` | Combined limit hit unexpectedly before individual limits |
| Setting `bodyLimit` lower than the expected total upload size | Request rejected at the transport level before multipart parsing begins |
| Assuming fields exceeding `fields` limit produce an error | Excess fields are silently dropped; validate required fields explicitly |

---

### Limit Sizing Reference

Common reference points for choosing values:

| Use Case | Suggested `fileSize` | Suggested `files` |
|---|---|---|
| Avatar / profile image | 2–5 MB | 1 |
| Document upload (PDF) | 10–25 MB | 1–5 |
| Media upload (video) | 500 MB–2 GB | 1 |
| Bulk spreadsheet import | 10–50 MB | 1–10 |
| General form with attachments | 5–10 MB | 1–3 |

**Key Points:**
- These are illustrative starting points, not recommendations; appropriate values depend on your infrastructure, cost model, and user expectations
- For video and large media, consider a pre-signed URL approach where the client uploads directly to object storage, bypassing your server entirely

---

**Conclusion:**
File size and field limits in `@fastify/multipart` are a thin layer over `busboy`'s limit system. The key practices are: set all relevant limits explicitly rather than relying on defaults; store limit values as named constants for reuse; understand the difference between truncation with `throwFileSizeLimit: false` and rejection with `true`; align `bodyLimit` at the Fastify level with your per-file and per-request expectations; and validate required fields explicitly, since excess fields are dropped silently rather than rejected with an error.