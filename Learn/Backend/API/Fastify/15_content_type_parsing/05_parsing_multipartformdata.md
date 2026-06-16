## Parsing multipart/form-data

Fastify does not include a built-in parser for `multipart/form-data`. This content type is used for HTML forms that include file uploads, and for any form submission that mixes text fields with binary data. The official solution is the `@fastify/multipart` plugin, which wraps `busboy` internally.

---

### What This Content Type Looks Like

A `multipart/form-data` request body is split into named parts, each separated by a boundary string:

```
POST /upload HTTP/1.1
Content-Type: multipart/form-data; boundary=----FormBoundary7MA4YWxk

------FormBoundary7MA4YWxk
Content-Disposition: form-data; name="username"

jane
------FormBoundary7MA4YWxk
Content-Disposition: form-data; name="avatar"; filename="photo.jpg"
Content-Type: image/jpeg

<binary data>
------FormBoundary7MA4YWxk--
```

**Key Points:**
- Each part has its own headers (`Content-Disposition`, optionally `Content-Type`)
- Text fields and file uploads coexist in the same request
- The boundary is defined in the `Content-Type` header and is unique per request

---

### Installation

```bash
npm install @fastify/multipart
```

---

### Plugin Registration

```js
import Fastify from 'fastify'
import multipart from '@fastify/multipart'

const fastify = Fastify()

await fastify.register(multipart)
```

**Key Points:**
- Register on the root instance for global availability
- The plugin does not automatically parse every multipart request; by default you call parsing methods explicitly in each handler
- An `attachFieldsToBody` option exists to change this behavior (covered below)

---

### Processing Parts Manually

The default API gives you an async iterator or individual part accessors on `request.parts()`:

```js
fastify.post('/upload', async (request, reply) => {
  const parts = request.parts()

  for await (const part of parts) {
    if (part.type === 'file') {
      console.log(part.filename)
      console.log(part.mimetype)
      await part.toBuffer() // consume the file into memory
    } else {
      // text field
      console.log(part.fieldname, part.value)
    }
  }

  return { status: 'done' }
})
```

**Key Points:**
- `part.type` is either `'file'` or `'field'`
- Every part — including file parts — **must be consumed**; unconsumed parts may stall the request
- `part.toBuffer()` buffers the entire file in memory; avoid for large files
- Text field values are available directly on `part.value` without additional awaiting

---

### Part Properties

#### File parts

| Property | Type | Description |
|---|---|---|
| `type` | `'file'` | Always `'file'` for file parts |
| `fieldname` | `string` | Form field name |
| `filename` | `string` | Original filename from the client |
| `encoding` | `string` | Transfer encoding (e.g., `7bit`) |
| `mimetype` | `string` | MIME type declared by the client |
| `file` | `Readable` | Raw Node.js readable stream |
| `toBuffer()` | `Promise<Buffer>` | Buffers the entire file |
| `_buf` | `Buffer \| null` | Internal buffer after `toBuffer()` is called |

#### Field parts

| Property | Type | Description |
|---|---|---|
| `type` | `'field'` | Always `'field'` for text fields |
| `fieldname` | `string` | Form field name |
| `value` | `string` | Decoded field value |
| `encoding` | `string` | Field encoding |
| `mimetype` | `string` | Usually `text/plain` |

---

### Saving a File to Disk via Stream

Buffering into memory is unsuitable for large uploads. Stream directly to disk instead:

```js
import { pipeline } from 'node:stream/promises'
import { createWriteStream } from 'node:fs'
import path from 'node:path'

fastify.post('/upload', async (request, reply) => {
  const data = await request.file()

  if (!data) {
    return reply.status(400).send({ error: 'No file uploaded' })
  }

  const dest = path.join('/tmp', data.filename)
  await pipeline(data.file, createWriteStream(dest))

  return { saved: dest, mimetype: data.mimetype }
})
```

**Key Points:**
- `request.file()` resolves the first file part only; use `request.parts()` for mixed or multiple uploads
- `pipeline` from `node:stream/promises` handles backpressure and propagates stream errors cleanly
- [Inference] Writing files using the client-supplied `filename` directly is a security risk; sanitize or replace the filename before using it in a path — behavior of path traversal attacks depends entirely on your environment and is not mitigated by Fastify or the plugin

---

### Handling Multiple Files

```js
fastify.post('/gallery', async (request, reply) => {
  const files = []
  const parts = request.parts()

  for await (const part of parts) {
    if (part.type === 'file') {
      const buffer = await part.toBuffer()
      files.push({
        fieldname: part.fieldname,
        filename: part.filename,
        size: buffer.length,
        mimetype: part.mimetype
      })
    }
  }

  return { uploaded: files }
})
```

---

### `attachFieldsToBody` Mode

For simpler cases where you want `request.body` populated automatically — similar to how JSON parsing works — register the plugin with `attachFieldsToBody`:

```js
await fastify.register(multipart, {
  attachFieldsToBody: true
})

fastify.post('/profile', async (request, reply) => {
  const username = request.body.username.value
  const avatar = request.body.avatar
  const buffer = await avatar.toBuffer()

  return { username, size: buffer.length }
})
```

**Key Points:**
- With `attachFieldsToBody: true`, all parts are collected into `request.body` keyed by `fieldname`
- Text field values are accessed via `.value` on the field object, not directly as strings
- File parts are still stream objects; you must call `.toBuffer()` or pipe them yourself
- [Inference] `attachFieldsToBody` buffers all non-file fields eagerly; for requests with many large text fields this may affect memory usage, though behavior depends on payload size and server resources

---

### `attachFieldsToBody: 'keyValues'`

A variant that gives you a flatter structure for text fields:

```js
await fastify.register(multipart, {
  attachFieldsToBody: 'keyValues'
})

fastify.post('/profile', async (request, reply) => {
  const username = request.body.username // plain string, no .value
  return { username }
})
```

**Key Points:**
- File parts are still objects with stream access; only text fields are flattened to plain string values
- This mode is more ergonomic for forms with no or few file uploads

---

### Plugin-Level Options

```js
await fastify.register(multipart, {
  limits: {
    fieldNameSize: 100,   // max field name length in bytes
    fieldSize: 1000000,   // max field value size in bytes
    fields: 10,           // max number of non-file fields
    fileSize: 5242880,    // max file size in bytes (5 MB)
    files: 5,             // max number of file parts
    headerPairs: 2000,    // max number of header key-value pairs
    parts: 1000           // max number of parts (fields + files)
  }
})
```

**Key Points:**
- These limits are enforced by `busboy`, which `@fastify/multipart` wraps
- Exceeding `fileSize` does not automatically reject the request; it truncates the stream and sets `part.file.truncated = true`
- [Inference] You should check `part.file.truncated` after consuming a file part if you enforce size limits this way; undetected truncation may result in corrupted stored files — behavior depends on your consumption logic

---

### Detecting Truncated Files

```js
fastify.post('/upload', async (request, reply) => {
  const part = await request.file()
  const buffer = await part.toBuffer()

  if (part.file.truncated) {
    return reply.status(413).send({ error: 'File too large' })
  }

  return { size: buffer.length }
})
```

---

### Per-Request Options

Limits and options can be overridden per call:

```js
fastify.post('/upload', async (request, reply) => {
  const part = await request.file({
    limits: { fileSize: 10 * 1024 * 1024 } // 10 MB for this route only
  })
  // ...
})
```

---

### Schema Validation Considerations

Fastify's schema validation does not apply to multipart bodies in the same way as JSON. The body is not a plain object that Ajv can validate before the handler runs.

**Key Points:**
- Validate field values manually inside the handler after parsing
- [Inference] Using `attachFieldsToBody` with a body schema may partially integrate with Fastify's validation pipeline, but full Ajv validation of multipart bodies is not guaranteed to work identically to JSON body validation; test against your Fastify and plugin versions
- MIME type values reported in `part.mimetype` come from the client and cannot be trusted for security decisions; validate file content independently if file type matters

---

### Security Considerations

| Concern | Mitigation |
|---|---|
| Path traversal via `filename` | Never use `part.filename` directly in file paths; sanitize or replace |
| MIME type spoofing | Do not trust `part.mimetype`; inspect file magic bytes if needed |
| Unbounded upload size | Set `limits.fileSize` and `limits.files` |
| Denial of service via many parts | Set `limits.parts` and `limits.fields` |
| Memory exhaustion | Stream to disk rather than calling `toBuffer()` for large files |

**Key Points:**
- These are general guidance points; specific mitigations depend on your application's threat model
- [Inference] No combination of plugin options fully substitutes for application-level validation of file content; treat all uploaded data as untrusted

---

### Practical Example: Profile Update with Avatar

```js
import Fastify from 'fastify'
import multipart from '@fastify/multipart'
import { pipeline } from 'node:stream/promises'
import { createWriteStream } from 'node:fs'
import path from 'node:path'
import crypto from 'node:crypto'

const fastify = Fastify()

await fastify.register(multipart, {
  limits: { fileSize: 2 * 1024 * 1024 } // 2 MB
})

fastify.post('/profile', async (request, reply) => {
  const parts = request.parts()
  const fields = {}
  let avatarPath = null

  for await (const part of parts) {
    if (part.type === 'field') {
      fields[part.fieldname] = part.value
    } else if (part.type === 'file' && part.fieldname === 'avatar') {
      const safeName = crypto.randomUUID() + path.extname(part.filename)
      avatarPath = path.join('/tmp/uploads', safeName)
      await pipeline(part.file, createWriteStream(avatarPath))

      if (part.file.truncated) {
        return reply.status(413).send({ error: 'Avatar exceeds 2 MB limit' })
      }
    } else {
      await part.toBuffer() // consume and discard unexpected file parts
    }
  }

  return {
    username: fields.username ?? null,
    avatar: avatarPath
  }
})

await fastify.listen({ port: 3000 })
```

**Key Points:**
- `crypto.randomUUID()` replaces the client filename to avoid path traversal
- Unexpected file fields are consumed and discarded to prevent the request from stalling
- The truncation check occurs after `pipeline` completes, at which point the stream is fully consumed

---

**Conclusion:**
`multipart/form-data` handling in Fastify centers on `@fastify/multipart`, which exposes both a manual streaming API and an auto-attach mode. The core discipline is consuming every part, streaming large files rather than buffering them, and treating all client-supplied metadata — filenames, MIME types, field values — as untrusted input that requires explicit validation.