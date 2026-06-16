## Multipart Handling with @fastify/multipart

`@fastify/multipart` is the official Fastify plugin for processing `multipart/form-data` requests. It wraps `busboy` and exposes several distinct consumption models — from low-level stream access to automatic body attachment — each suited to different use cases. This topic covers the full plugin API in depth.

---

### Installation

```bash
npm install @fastify/multipart
```

---

### Registration

```js
import Fastify from 'fastify'
import multipart from '@fastify/multipart'

const fastify = Fastify()

await fastify.register(multipart, {
  // options (covered below)
})
```

**Key Points:**
- Register on the root instance for global availability across all routes
- Registering inside a scoped plugin limits availability to that scope and its children
- The plugin adds `request.file()`, `request.files()`, `request.parts()`, and `request.saveRequestFiles()` to the Fastify request interface

---

### Core Concepts

Before examining individual APIs, three concepts underpin all usage:

**Parts** — Each segment of a multipart body is a part. Parts are either fields (text) or files (binary or text with a filename).

**Streams** — File parts expose a Node.js `Readable` stream. The stream must be consumed; leaving it unconsumed stalls the request indefinitely.

**Consumption obligation** — Every part iterated must be fully read. This applies even to parts you intend to discard.

---

### Global Plugin Options

```js
await fastify.register(multipart, {
  attachFieldsToBody: false,      // default; see below for modes
  throwFileSizeLimit: true,       // throw when fileSize limit exceeded (default: true)
  limits: {
    fieldNameSize: 100,           // max field name size in bytes (default: 100)
    fieldSize: 1048576,           // max field value size in bytes (default: 1 MB)
    fields: Infinity,             // max number of non-file fields
    fileSize: Infinity,           // max file size in bytes
    files: Infinity,              // max number of file parts
    headerPairs: 2000,            // max header key-value pairs per part
    parts: Infinity               // max total parts (fields + files)
  }
})
```

**Key Points:**
- All `limits` values default to `Infinity` except `fieldNameSize` (100) and `fieldSize` (1 MB) — set explicit limits for production use
- `throwFileSizeLimit: true` causes Fastify to respond with `413` automatically when `fileSize` is exceeded; setting it to `false` means truncation is silent and must be checked manually via `part.file.truncated`
- [Inference] Leaving `files`, `parts`, and `fileSize` as `Infinity` in production exposes the server to resource exhaustion via large or numerous uploads; always set explicit limits appropriate to your use case

---

### API 1 — `request.file()`

Resolves the first file part in the request. Text fields encountered before the file are accessible via `request.body` when `attachFieldsToBody` is enabled, otherwise they are discarded.

```js
fastify.post('/upload', async (request, reply) => {
  const data = await request.file()

  if (!data) {
    return reply.status(400).send({ error: 'No file found' })
  }

  console.log(data.filename)   // original filename
  console.log(data.mimetype)   // declared MIME type
  console.log(data.encoding)   // transfer encoding
  console.log(data.fieldname)  // form field name

  const buffer = await data.toBuffer()
  return { size: buffer.length }
})
```

**Key Points:**
- `request.file()` returns `undefined` if no file part is found
- Calling `toBuffer()` loads the entire file into memory; unsuitable for large files
- Fields appearing after the file part in the multipart body are not captured by `request.file()`
- Per-call options can override plugin-level limits:

```js
const data = await request.file({
  limits: { fileSize: 10 * 1024 * 1024 }
})
```

---

### API 2 — `request.files()`

Returns an async iterator over all file parts, skipping field parts.

```js
fastify.post('/gallery', async (request, reply) => {
  const results = []

  for await (const part of request.files()) {
    const buffer = await part.toBuffer()
    results.push({
      fieldname: part.fieldname,
      filename: part.filename,
      size: buffer.length,
      mimetype: part.mimetype
    })
  }

  return { uploaded: results }
})
```

**Key Points:**
- Field parts are silently consumed and discarded by the iterator
- All file parts must be consumed; exiting the loop early without consuming remaining parts will stall the request
- [Inference] If early exit is needed, drain remaining parts explicitly — behavior of an abandoned async iterator over a live stream is not guaranteed to clean up automatically

---

### API 3 — `request.parts()`

Returns an async iterator over all parts — both fields and files — in order of appearance.

```js
fastify.post('/mixed', async (request, reply) => {
  const fields = {}
  const files = []

  for await (const part of request.parts()) {
    if (part.type === 'file') {
      const buffer = await part.toBuffer()
      files.push({
        fieldname: part.fieldname,
        filename: part.filename,
        size: buffer.length
      })
    } else {
      fields[part.fieldname] = part.value
    }
  }

  return { fields, files }
})
```

**Key Points:**
- `part.type` is `'file'` or `'field'`
- Field parts expose `part.value` as a string directly
- File parts expose `part.file` (Readable stream) and `part.toBuffer()`
- This is the most flexible API and the appropriate choice when you need both fields and files with full control

---

### API 4 — `request.saveRequestFiles()`

Saves all file parts to a temporary directory automatically, returning an array of saved file descriptors. This is the highest-level API.

```js
fastify.post('/upload', async (request, reply) => {
  const files = await request.saveRequestFiles()

  for (const file of files) {
    console.log(file.filepath)   // absolute path to temp file
    console.log(file.filename)   // original filename
    console.log(file.mimetype)
    console.log(file.encoding)
    console.log(file.fields)     // other fields in the request
  }

  return { count: files.length }
})
```

**Key Points:**
- Temporary files are written to the OS temp directory by default
- Files are not automatically deleted after the request; clean up manually or use a lifecycle hook
- `file.fields` contains all non-file fields parsed from the request
- Per-call options are supported:

```js
const files = await request.saveRequestFiles({
  limits: { fileSize: 5 * 1024 * 1024 },
  tmpdir: '/custom/tmp'
})
```

---

### Streaming Files to Disk Manually

For production file handling, stream directly to a destination rather than buffering:

```js
import { pipeline } from 'node:stream/promises'
import { createWriteStream } from 'node:fs'
import { mkdir } from 'node:fs/promises'
import path from 'node:path'
import crypto from 'node:crypto'

const UPLOAD_DIR = '/var/uploads'

fastify.post('/upload', async (request, reply) => {
  await mkdir(UPLOAD_DIR, { recursive: true })

  const part = await request.file()

  if (!part) {
    return reply.status(400).send({ error: 'No file' })
  }

  const ext = path.extname(part.filename)
  const safeName = crypto.randomUUID() + ext
  const dest = path.join(UPLOAD_DIR, safeName)

  await pipeline(part.file, createWriteStream(dest))

  if (part.file.truncated) {
    return reply.status(413).send({ error: 'File exceeds size limit' })
  }

  return { stored: safeName, mimetype: part.mimetype }
})
```

**Key Points:**
- `crypto.randomUUID()` replaces the client-supplied filename, avoiding path traversal
- The truncation check must occur after `pipeline` completes — not before — because the stream must be fully consumed first
- [Inference] `part.file.truncated` is set by `busboy` after stream exhaustion; checking it before the stream is consumed may yield a false negative — behavior depends on when `busboy` sets the flag

---

### `attachFieldsToBody` Mode

Enabling this option causes the plugin to parse the entire multipart body before the handler runs and attach results to `request.body`.

#### Mode: `true`

```js
await fastify.register(multipart, {
  attachFieldsToBody: true
})

fastify.post('/profile', async (request, reply) => {
  const username = request.body.username.value  // text field
  const avatar = request.body.avatar            // file part object
  const buffer = await avatar.toBuffer()

  return { username, size: buffer.length }
})
```

- Text field values are accessed via `.value`
- File parts are still streaming objects requiring explicit consumption

#### Mode: `'keyValues'`

```js
await fastify.register(multipart, {
  attachFieldsToBody: 'keyValues'
})

fastify.post('/profile', async (request, reply) => {
  const username = request.body.username  // plain string
  const avatar = request.body.avatar      // file part object
  const buffer = await avatar.toBuffer()

  return { username, size: buffer.length }
})
```

**Key Points:**
- `'keyValues'` flattens text fields to plain strings; file parts remain as objects
- Neither mode coerces types; all text values are strings
- [Inference] Using `attachFieldsToBody` with Fastify's body schema validation may not produce results identical to JSON body validation; the schema sees the raw attached structure, not a plain deserialized object — test explicitly against your schema definitions and Fastify version

---

### Handling Truncated Files

When `throwFileSizeLimit` is `false`, size-exceeded files are truncated silently:

```js
await fastify.register(multipart, {
  throwFileSizeLimit: false,
  limits: { fileSize: 1024 * 1024 }
})

fastify.post('/upload', async (request, reply) => {
  const part = await request.file()
  const buffer = await part.toBuffer()

  if (part.file.truncated) {
    return reply.status(413).send({
      error: 'File too large',
      limit: '1 MB'
    })
  }

  return { size: buffer.length }
})
```

When `throwFileSizeLimit` is `true` (default), exceeding the limit throws a `FastifyError` with status `413` automatically.

---

### Cleanup After `saveRequestFiles`

Temporary files persist until explicitly removed. Use an `onResponse` hook for cleanup:

```js
fastify.addHook('onResponse', async (request, reply) => {
  await request.cleanRequestFiles()
})
```

**Key Points:**
- `request.cleanRequestFiles()` deletes all temporary files created by `saveRequestFiles()` during that request
- This hook fires after the response is sent, so cleanup does not delay the client
- [Inference] If the server crashes before the hook fires, temporary files are left on disk; implement periodic cleanup of the temp directory as a separate process if file accumulation is a concern

---

### Adding Shared Fields Across Parts

When using `request.parts()`, you can accumulate fields and files together:

```js
fastify.post('/order', async (request, reply) => {
  const result = { fields: {}, files: [] }

  for await (const part of request.parts()) {
    if (part.type === 'field') {
      result.fields[part.fieldname] = part.value
    } else {
      // stream to disk or buffer
      const buffer = await part.toBuffer()
      result.files.push({
        name: part.fieldname,
        originalName: part.filename,
        size: buffer.length,
        mimetype: part.mimetype
      })
    }
  }

  if (!result.fields.orderId) {
    return reply.status(400).send({ error: 'orderId is required' })
  }

  return result
})
```

---

### Decorators and Type Extensions

`@fastify/multipart` adds the following to the Fastify request interface:

| Decorator | Description |
|---|---|
| `request.file(opts?)` | Resolves first file part |
| `request.files(opts?)` | Async iterator over file parts |
| `request.parts(opts?)` | Async iterator over all parts |
| `request.saveRequestFiles(opts?)` | Saves all files to disk, returns descriptors |
| `request.cleanRequestFiles()` | Deletes temp files from `saveRequestFiles` |
| `request.isMultipart()` | Returns `true` if the request is multipart |

---

### `request.isMultipart()`

Useful for routes that accept both JSON and multipart:

```js
fastify.post('/flexible', async (request, reply) => {
  if (request.isMultipart()) {
    const part = await request.file()
    const buffer = await part.toBuffer()
    return { mode: 'multipart', size: buffer.length }
  }

  return { mode: 'json', body: request.body }
})
```

---

### Common Mistakes

| Mistake | Effect |
|---|---|
| Not consuming all parts | Request stalls; response never sent |
| Checking `part.file.truncated` before consuming stream | May yield incorrect result; check after full consumption |
| Using client `filename` directly in file paths | Path traversal vulnerability |
| Trusting `part.mimetype` for security decisions | MIME type is client-declared and unverified |
| Not cleaning up temp files from `saveRequestFiles` | Disk accumulation over time |
| Expecting `attachFieldsToBody` text fields as plain strings in `true` mode | Values are objects with `.value`; use `'keyValues'` mode for plain strings |
| Buffering large files with `toBuffer()` | Memory exhaustion on large payloads |

---

### Choosing the Right API

| Scenario | Recommended API |
|---|---|
| Single file upload, no fields needed | `request.file()` |
| Multiple files, no fields needed | `request.files()` |
| Mixed fields and files, full control | `request.parts()` |
| Simple forms, convenience over control | `attachFieldsToBody: 'keyValues'` |
| Delegated temp file management | `request.saveRequestFiles()` |

---

**Conclusion:**
`@fastify/multipart` provides a layered API ranging from raw stream access via `request.parts()` to fully managed file handling via `saveRequestFiles()`. The right choice depends on whether you need streaming, mixed content, or convenience. Across all modes, the obligation to consume every part, the untrustworthiness of client-supplied metadata, and the need for explicit size limits are constants that apply regardless of which API surface you use.