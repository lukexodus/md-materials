## Single and Multiple File Uploads

Building on the `@fastify/multipart` API, this topic focuses specifically on the patterns, decisions, and edge cases involved in handling single and multiple file uploads in production routes. This includes stream handling, memory management, validation, and storage strategies.

---

### Prerequisites

```bash
npm install @fastify/multipart
```

```js
import Fastify from 'fastify'
import multipart from '@fastify/multipart'

const fastify = Fastify()

await fastify.register(multipart, {
  limits: {
    fileSize: 5 * 1024 * 1024,  // 5 MB per file
    files: 10                    // max 10 files per request
  }
})
```

---

### Single File Upload

#### Basic Pattern

```js
fastify.post('/upload', async (request, reply) => {
  const part = await request.file()

  if (!part) {
    return reply.status(400).send({ error: 'No file provided' })
  }

  const buffer = await part.toBuffer()

  return {
    fieldname: part.fieldname,
    filename: part.filename,
    mimetype: part.mimetype,
    size: buffer.length
  }
})
```

**Key Points:**
- `request.file()` resolves the first file part only; any subsequent file parts are ignored
- `toBuffer()` is appropriate only for small files; for larger files, stream to disk (shown below)
- `part.filename` is the original name supplied by the client — treat as untrusted input

#### Streaming a Single File to Disk

```js
import { pipeline } from 'node:stream/promises'
import { createWriteStream } from 'node:fs'
import { mkdir } from 'node:fs/promises'
import path from 'node:path'
import crypto from 'node:crypto'

const UPLOAD_DIR = '/var/app/uploads'

fastify.post('/upload', async (request, reply) => {
  await mkdir(UPLOAD_DIR, { recursive: true })

  const part = await request.file()

  if (!part) {
    return reply.status(400).send({ error: 'No file provided' })
  }

  const ext = path.extname(part.filename).toLowerCase()
  const storedName = crypto.randomUUID() + ext
  const filePath = path.join(UPLOAD_DIR, storedName)

  await pipeline(part.file, createWriteStream(filePath))

  if (part.file.truncated) {
    return reply.status(413).send({ error: 'File exceeds size limit' })
  }

  return {
    stored: storedName,
    originalName: part.filename,
    mimetype: part.mimetype
  }
})
```

**Key Points:**
- `crypto.randomUUID()` generates an unpredictable, collision-resistant filename
- `path.extname` preserves the file extension for storage convenience; validate allowed extensions before using
- The truncation check must occur after `pipeline` resolves, not before — the stream must be fully consumed first
- `mkdir` with `{ recursive: true }` is idempotent; it does not throw if the directory already exists

---

### Single File Upload with Field Data

When the form includes both text fields and a file, use `request.parts()` to capture everything:

```js
fastify.post('/profile', async (request, reply) => {
  const fields = {}
  let file = null

  for await (const part of request.parts()) {
    if (part.type === 'field') {
      fields[part.fieldname] = part.value
    } else if (part.type === 'file' && part.fieldname === 'avatar') {
      const ext = path.extname(part.filename).toLowerCase()
      const storedName = crypto.randomUUID() + ext
      const filePath = path.join(UPLOAD_DIR, storedName)

      await pipeline(part.file, createWriteStream(filePath))

      if (part.file.truncated) {
        return reply.status(413).send({ error: 'File exceeds size limit' })
      }

      file = { storedName, mimetype: part.mimetype }
    } else {
      await part.toBuffer() // consume and discard unexpected file parts
    }
  }

  if (!fields.username) {
    return reply.status(400).send({ error: 'username is required' })
  }

  return { username: fields.username, avatar: file }
})
```

**Key Points:**
- Parts arrive in the order the client sends them; field position relative to file parts is not guaranteed by the multipart spec
- Unexpected file parts must be consumed and discarded to prevent the request from stalling
- [Inference] Validating required fields after the loop is necessary because parts are processed as they stream in — you cannot know which fields are present until all parts are consumed

---

### Multiple File Uploads

#### All Files from One Field

When a form submits multiple files under the same field name (e.g., `<input type="file" multiple>`):

```js
fastify.post('/gallery', async (request, reply) => {
  const uploaded = []

  for await (const part of request.files()) {
    const ext = path.extname(part.filename).toLowerCase()
    const storedName = crypto.randomUUID() + ext
    const filePath = path.join(UPLOAD_DIR, storedName)

    await pipeline(part.file, createWriteStream(filePath))

    if (part.file.truncated) {
      return reply.status(413).send({
        error: `File "${part.filename}" exceeds size limit`
      })
    }

    uploaded.push({
      fieldname: part.fieldname,
      originalName: part.filename,
      stored: storedName,
      mimetype: part.mimetype
    })
  }

  return { count: uploaded.length, files: uploaded }
})
```

**Key Points:**
- `request.files()` iterates only file parts; field parts are silently consumed and discarded
- Returning early inside the loop when truncation is detected leaves remaining parts unconsumed, which stalls the request — drain remaining parts or restructure error handling (see below)

#### Draining Remaining Parts After Early Exit

When you need to abort processing but must still consume the stream:

```js
fastify.post('/gallery', async (request, reply) => {
  const uploaded = []
  let error = null
  const parts = request.files()

  for await (const part of parts) {
    if (error) {
      await part.toBuffer() // consume and discard
      continue
    }

    const ext = path.extname(part.filename).toLowerCase()
    const storedName = crypto.randomUUID() + ext
    const filePath = path.join(UPLOAD_DIR, storedName)

    await pipeline(part.file, createWriteStream(filePath))

    if (part.file.truncated) {
      error = `File "${part.filename}" exceeds size limit`
      continue
    }

    uploaded.push({ stored: storedName, mimetype: part.mimetype })
  }

  if (error) {
    return reply.status(413).send({ error })
  }

  return { count: uploaded.length, files: uploaded }
})
```

**Key Points:**
- The `error` flag defers response until all parts are consumed
- `part.toBuffer()` on discarded parts pulls the stream into memory briefly; for very large discarded files this still uses memory — [Inference] piping to a null sink (`stream.Writable` that discards) avoids memory allocation but adds complexity

#### Piping to a Null Sink

For discarding large file streams without buffering:

```js
import { Writable } from 'node:stream'

function devNull () {
  return new Writable({ write (chunk, enc, cb) { cb() } })
}

// Inside the loop, to discard without memory allocation:
await pipeline(part.file, devNull())
```

---

### Multiple Files from Different Fields

When a form has several distinct file inputs (e.g., `resume` and `coverLetter`):

```js
fastify.post('/apply', async (request, reply) => {
  const expectedFiles = new Set(['resume', 'coverLetter'])
  const saved = {}
  const fields = {}

  for await (const part of request.parts()) {
    if (part.type === 'field') {
      fields[part.fieldname] = part.value
      continue
    }

    if (!expectedFiles.has(part.fieldname)) {
      await part.toBuffer() // discard unexpected
      continue
    }

    const ext = path.extname(part.filename).toLowerCase()
    const storedName = crypto.randomUUID() + ext
    const filePath = path.join(UPLOAD_DIR, storedName)

    await pipeline(part.file, createWriteStream(filePath))

    if (part.file.truncated) {
      return reply.status(413).send({
        error: `${part.fieldname} exceeds size limit`
      })
    }

    saved[part.fieldname] = {
      stored: storedName,
      originalName: part.filename,
      mimetype: part.mimetype
    }
  }

  if (!saved.resume) {
    return reply.status(400).send({ error: 'resume is required' })
  }

  return { fields, files: saved }
})
```

---

### File Type Validation

`part.mimetype` is client-declared and cannot be trusted for security decisions. Validate by inspecting the file's magic bytes instead:

```bash
npm install file-type
```

```js
import { fileTypeFromBuffer } from 'file-type'

const ALLOWED_TYPES = new Set(['image/jpeg', 'image/png', 'image/webp'])

fastify.post('/avatar', async (request, reply) => {
  const part = await request.file()

  if (!part) {
    return reply.status(400).send({ error: 'No file provided' })
  }

  const buffer = await part.toBuffer()

  if (part.file.truncated) {
    return reply.status(413).send({ error: 'File too large' })
  }

  const detected = await fileTypeFromBuffer(buffer)

  if (!detected || !ALLOWED_TYPES.has(detected.mime)) {
    return reply.status(415).send({
      error: 'Unsupported file type',
      detected: detected?.mime ?? 'unknown'
    })
  }

  const storedName = crypto.randomUUID() + '.' + detected.ext
  const filePath = path.join(UPLOAD_DIR, storedName)
  await fs.writeFile(filePath, buffer)

  return { stored: storedName, type: detected.mime }
})
```

**Key Points:**
- `file-type` reads the first few bytes of the buffer to detect the actual format
- This approach requires buffering the file into memory; for large files, read only the header bytes and stream the rest separately
- [Inference] Magic byte detection is more reliable than MIME type headers but is not infallible; some file formats share headers or can be constructed to pass detection — treat it as one layer of a broader validation strategy, not a complete solution
- `file-type` is a third-party library; install separately

---

### Extension Allowlist

A lighter alternative to magic byte detection — validate the file extension against an allowlist:

```js
const ALLOWED_EXTENSIONS = new Set(['.jpg', '.jpeg', '.png', '.webp', '.pdf'])

function validateExtension (filename) {
  const ext = path.extname(filename).toLowerCase()
  return ALLOWED_EXTENSIONS.has(ext) ? ext : null
}
```

**Key Points:**
- Extension validation alone is weaker than magic byte detection; a renamed file bypasses it
- [Inference] Combining extension allowlist with MIME type check and magic byte detection provides layered defense, but no combination fully substitutes for server-side content scanning in high-risk environments

---

### Using `saveRequestFiles` for Multiple Uploads

For simpler cases where you do not need streaming control:

```js
fastify.post('/batch', async (request, reply) => {
  const files = await request.saveRequestFiles()

  const result = files.map(f => ({
    fieldname: f.fieldname,
    originalName: f.filename,
    tempPath: f.filepath,
    mimetype: f.mimetype,
    size: f.file.bytesRead
  }))

  return { count: result.length, files: result }
})

fastify.addHook('onResponse', async (request) => {
  await request.cleanRequestFiles()
})
```

**Key Points:**
- `saveRequestFiles` handles stream consumption internally
- Temp files persist beyond the request until `cleanRequestFiles()` is called
- `f.file.bytesRead` reflects bytes written to disk, which equals the file size when not truncated

---

### Limiting Concurrent Disk Writes

When processing many files simultaneously, uncontrolled concurrent writes may strain I/O:

```js
fastify.post('/batch', async (request, reply) => {
  const parts = []

  for await (const part of request.files()) {
    parts.push(part)
  }

  // Process sequentially to limit concurrent I/O
  const results = []
  for (const part of parts) {
    const storedName = crypto.randomUUID() + path.extname(part.filename)
    const filePath = path.join(UPLOAD_DIR, storedName)
    await pipeline(part.file, createWriteStream(filePath))
    results.push({ stored: storedName, mimetype: part.mimetype })
  }

  return { files: results }
})
```

**Key Points:**
- Collecting parts into an array before processing serializes I/O at the cost of holding stream references open longer
- [Inference] Whether sequential or parallel I/O is preferable depends on your storage backend, server resources, and concurrency profile — benchmark under realistic load before optimizing

---

### Summary of Patterns

| Scenario | API | Notes |
|---|---|---|
| Single file, small | `request.file()` + `toBuffer()` | Simple; unsuitable for large files |
| Single file, large | `request.file()` + `pipeline` | Streams to disk; low memory |
| Single file + fields | `request.parts()` | Full control over part order |
| Multiple files, same field | `request.files()` | Skips field parts automatically |
| Multiple files, different fields | `request.parts()` | Distinguishes by `fieldname` |
| Convenience, no streaming control | `saveRequestFiles()` | Temp files; requires cleanup |
| File type validation | `file-type` + `toBuffer()` | Requires buffering for inspection |

---

**Conclusion:**
Single and multiple file uploads share the same underlying mechanics — part consumption, stream handling, and size enforcement — but differ in how parts are selected, iterated, and validated. The key discipline across all patterns is consuming every part to completion, validating file content independently of client-supplied metadata, generating safe storage names, and applying explicit size and count limits. Stream-based handling and buffered handling serve different trade-offs between memory usage and implementation simplicity.