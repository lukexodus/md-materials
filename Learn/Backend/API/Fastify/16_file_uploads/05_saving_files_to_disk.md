## Saving Files to Disk in Fastify

Saving uploaded files to disk is one of the most common requirements in file upload handling. In Fastify, this is managed through the `@fastify/multipart` plugin, which provides access to incoming `multipart/form-data` streams. Writing those streams to disk requires either using the plugin's built-in disk storage option or piping streams manually using Node.js file system APIs.

---

### Prerequisites

Install the required plugin:

```bash
npm install @fastify/multipart
```

Register it before defining routes that handle file uploads:

```js
import Fastify from 'fastify'
import multipart from '@fastify/multipart'

const fastify = Fastify()
await fastify.register(multipart)
```

---

### Approach 1 — Manual Stream Piping with `pump`

The most direct method is to consume each file part as a stream and pipe it to a writable file stream using `fs.createWriteStream`. The `pump` utility (or its modern equivalent `pipeline`) is recommended over `.pipe()` because it propagates errors and handles backpressure correctly.

```bash
npm install pump
```

```js
import Fastify from 'fastify'
import multipart from '@fastify/multipart'
import { createWriteStream } from 'fs'
import { pipeline } from 'stream/promises'
import path from 'path'

const fastify = Fastify()
await fastify.register(multipart)

fastify.post('/upload', async (request, reply) => {
  const data = await request.file()

  const filename = path.basename(data.filename)
  const destination = path.join('/uploads', filename)

  await pipeline(data.file, createWriteStream(destination))

  return {
    saved: filename,
    mimetype: data.mimetype,
    encoding: data.encoding
  }
})
```

**Key Points:**
- `request.file()` returns the first file part in the multipart request
- `data.file` is a Node.js `Readable` stream
- `pipeline` from `stream/promises` awaits completion and throws on error — preferred over `.pipe()` for async/await flows
- `path.basename` strips any directory components from the client-supplied filename — omitting this is a path traversal risk

---

### Approach 2 — Using `request.files()` for Multiple Uploads

When the request contains more than one file field, use the async iterator `request.files()`:

```js
import { mkdir } from 'fs/promises'
import { createWriteStream } from 'fs'
import { pipeline } from 'stream/promises'
import path from 'path'

const UPLOAD_DIR = '/uploads'

fastify.post('/upload-multiple', async (request, reply) => {
  await mkdir(UPLOAD_DIR, { recursive: true })

  const saved = []

  for await (const part of request.files()) {
    const filename = path.basename(part.filename)
    const dest = path.join(UPLOAD_DIR, filename)

    await pipeline(part.file, createWriteStream(dest))

    saved.push({ field: part.fieldname, filename })
  }

  return { saved }
})
```

**Key Points:**
- `request.files()` is an async generator — `for await...of` consumes each file part in sequence
- Files are saved one at a time in this pattern; concurrent saving is possible but requires care to avoid overwhelming the disk or hitting file descriptor limits
- `mkdir` with `{ recursive: true }` avoids errors if the directory already exists

---

### Approach 3 — Saving with a Unique Filename

Client-supplied filenames are untrusted and may collide. Generating a unique name on the server avoids overwrites and reduces guessability:

```js
import { randomUUID } from 'crypto'
import path from 'path'
import { createWriteStream } from 'fs'
import { pipeline } from 'stream/promises'

fastify.post('/upload-safe', async (request, reply) => {
  const part = await request.file()

  const ext = path.extname(path.basename(part.filename)) || ''
  const uniqueName = `${randomUUID()}${ext}`
  const dest = path.join('/uploads', uniqueName)

  await pipeline(part.file, createWriteStream(dest))

  return { filename: uniqueName, original: part.filename }
})
```

**Key Points:**
- `randomUUID()` generates a Version 4 UUID — [Inference] collision probability is negligible for typical upload volumes, though this is not a cryptographic guarantee
- Preserving the extension while discarding the original stem retains MIME-type hints without exposing user-controlled path segments
- The original filename can be stored separately in a database alongside the server-generated name

---

### Approach 4 — Built-in Disk Storage via Plugin Options

`@fastify/multipart` does not ship with a built-in disk-storage engine in the same way that Multer does for Express. File destination handling is intentionally left to the application. [Inference] This is a deliberate design choice consistent with Fastify's philosophy of minimal built-in assumptions — though this is inferred from plugin design patterns, not official documentation.

For a Multer-like disk storage abstraction, the `fastify-multer` community plugin wraps Multer's storage engine:

```bash
npm install fastify-multer multer
```

```js
import Fastify from 'fastify'
import multer from 'fastify-multer'
import path from 'path'

const fastify = Fastify()
await fastify.register(multer.contentParser)

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, '/uploads')
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname)
    cb(null, `${Date.now()}-${file.fieldname}${ext}`)
  }
})

const upload = multer({ storage })

fastify.post(
  '/upload-multer',
  { preHandler: upload.single('avatar') },
  async (request, reply) => {
    return {
      filename: request.file.filename,
      path: request.file.path,
      size: request.file.size
    }
  }
)
```

**Key Points:**
- `multer.contentParser` registers the content type parser for `multipart/form-data`
- `upload.single('avatar')` is used as a `preHandler` hook, consistent with Fastify's lifecycle
- [Unverified] `fastify-multer` is a community package; verify compatibility with your Fastify version before adopting it in production
- Behavior of `request.file` follows Multer's API, not Fastify's native multipart API

---

### Enforcing File Size Limits

File size limits should be enforced at the plugin level to reject oversized uploads before they consume disk space:

```js
await fastify.register(multipart, {
  limits: {
    fileSize: 5 * 1024 * 1024,   // 5 MB per file
    files: 5,                      // maximum number of files per request
    fieldSize: 1024,               // maximum size of non-file fields in bytes
  }
})
```

When a file exceeds `fileSize`, the `part.file` stream emits a `'limit'` event. [Inference] If this event is not handled, the upload may silently truncate rather than return an error — behavior may vary by plugin version. Check for truncation explicitly:

```js
fastify.post('/upload-limited', async (request, reply) => {
  const part = await request.file()
  const dest = path.join('/uploads', path.basename(part.filename))
  const writeStream = createWriteStream(dest)

  await pipeline(part.file, writeStream)

  if (part.file.truncated) {
    // Remove partially written file
    await unlink(dest)
    return reply.code(413).send({ error: 'File too large' })
  }

  return { saved: path.basename(part.filename) }
})
```

**Key Points:**
- `part.file.truncated` is `true` when the file exceeded the configured `fileSize` limit
- The partially written file should be deleted to avoid leaving incomplete data on disk
- Returning a `413 Payload Too Large` status is semantically appropriate for this case

---

### Validating File Type Before Saving

MIME type from the client (`part.mimetype`) is untrusted — it is whatever the client sends in the Content-Type header of the part. [Inference] Server-side magic byte inspection is more reliable, though it adds a dependency. The `file-type` package reads the first bytes of the stream to detect the actual type:

```bash
npm install file-type
```

```js
import { fileTypeFromStream } from 'file-type'
import { PassThrough } from 'stream'
import { pipeline } from 'stream/promises'
import { createWriteStream } from 'fs'

const ALLOWED_TYPES = new Set(['image/jpeg', 'image/png', 'image/webp'])

fastify.post('/upload-validated', async (request, reply) => {
  const part = await request.file()

  // Split the stream so we can inspect and save simultaneously
  const pass = new PassThrough()
  const detected = await fileTypeFromStream(part.file.pipe(pass))

  if (!detected || !ALLOWED_TYPES.has(detected.mime)) {
    return reply.code(415).send({ error: 'Unsupported file type' })
  }

  const dest = path.join('/uploads', `${randomUUID()}.${detected.ext}`)
  await pipeline(pass, createWriteStream(dest))

  return { saved: path.basename(dest), type: detected.mime }
})
```

**Key Points:**
- [Inference] `fileTypeFromStream` reads the minimum bytes needed to detect the format; the stream continues normally after detection — verify with current `file-type` documentation as the API has changed across major versions
- Using a `PassThrough` allows the stream to be both inspected and piped to disk; the exact mechanics depend on stream timing and [Inference] may require adjustment depending on file-type version
- Return `415 Unsupported Media Type` for disallowed types

---

### Directory Structure and Organization

A flat `/uploads` directory becomes unmanageable at scale. [Inference] Organizing files into subdirectories — by date, user ID, or content type — reduces filesystem lookup overhead and simplifies access control:

```js
import { format } from 'date-fns'   // or use native Date methods
import { mkdir } from 'fs/promises'

async function getUploadPath(userId) {
  const datePart = new Date().toISOString().slice(0, 10)   // e.g. 2025-06-07
  const dir = path.join('/uploads', userId, datePart)
  await mkdir(dir, { recursive: true })
  return dir
}

fastify.post('/upload-organized', async (request, reply) => {
  const userId = request.user?.id ?? 'anonymous'
  const part = await request.file()

  const dir = await getUploadPath(userId)
  const filename = `${randomUUID()}${path.extname(part.filename)}`
  const dest = path.join(dir, filename)

  await pipeline(part.file, createWriteStream(dest))

  return { path: dest }
})
```

---

### Security Checklist

| Risk | Mitigation |
|---|---|
| Path traversal | Use `path.basename` on all client filenames |
| Filename collision | Generate server-side unique names |
| Oversized uploads | Set `limits.fileSize` in plugin registration |
| Untrusted MIME type | Inspect magic bytes with `file-type` or similar |
| Partial writes on error | Delete file if `pipeline` throws or `truncated` is true |
| Executable uploads | Disallow extensions like `.sh`, `.php`, `.exe` via allowlist |

---

### Flow Overview

```mermaid
flowchart TD
    A[Client sends multipart/form-data] --> B[Fastify receives stream]
    B --> C{Plugin registered?}
    C -- No --> D[400 Bad Request]
    C -- Yes --> E[request.file() or request.files()]
    E --> F[Validate MIME / size]
    F -- Invalid --> G[413 / 415 response]
    F -- Valid --> H[Generate unique filename]
    H --> I[pipeline to createWriteStream]
    I --> J{Truncated?}
    J -- Yes --> K[Delete partial file\n413 response]
    J -- No --> L[Return filename / metadata]
```

---

**Related Topics:**
- Serving uploaded files — using `@fastify/static` to expose saved files over HTTP
- Storing file metadata — persisting filename, path, size, and MIME type in a database
- Cloud storage — streaming uploads directly to S3 or GCS without writing to disk
- Multipart field handling — reading non-file form fields alongside file parts
- Virus scanning — integrating ClamAV or a cloud scanning API before finalizing saves
- Access control — restricting file access by user or role after upload