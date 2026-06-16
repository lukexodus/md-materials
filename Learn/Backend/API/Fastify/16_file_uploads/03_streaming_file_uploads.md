## Streaming File Uploads

Streaming file uploads process incoming file data as it arrives, without loading the entire file into memory first. This is the appropriate strategy for large files, high-concurrency environments, or when forwarding upload data directly to another destination such as object storage or a downstream service.

---

### Why Streaming Matters

When `toBuffer()` is used, the entire file is held in process memory simultaneously. For a server receiving many concurrent uploads, this compounds quickly:

- 100 concurrent uploads × 10 MB each = ~1 GB of heap pressure
- Memory spikes during upload can trigger garbage collection pauses or OOM conditions

Streaming avoids this by processing chunks as they arrive and releasing them immediately after forwarding.

**Key Points:**
- Streaming trades implementation simplicity for lower and more predictable memory usage
- [Inference] Whether streaming produces a meaningful improvement depends on your concurrency profile, file sizes, and Node.js heap configuration — measure before assuming

---

### Core Tool: `node:stream/promises` `pipeline`

`pipeline` is the correct primitive for connecting a readable source to a writable destination. It handles backpressure, propagates errors from any stage, and resolves when the destination has finished writing.

```js
import { pipeline } from 'node:stream/promises'
```

**Key Points:**
- Do not use `.pipe()` for production streaming; it does not propagate errors from the destination and can silently drop data or leave streams open on failure
- `pipeline` from `node:stream/promises` returns a `Promise`; it integrates cleanly with `async/await`

---

### Streaming to Disk

The baseline pattern: pipe the upload stream directly to a file write stream.

```js
import Fastify from 'fastify'
import multipart from '@fastify/multipart'
import { pipeline } from 'node:stream/promises'
import { createWriteStream } from 'node:fs'
import { mkdir } from 'node:fs/promises'
import path from 'node:path'
import crypto from 'node:crypto'

const fastify = Fastify()
const UPLOAD_DIR = '/var/app/uploads'

await fastify.register(multipart, {
  limits: { fileSize: 100 * 1024 * 1024 } // 100 MB
})

fastify.post('/upload', async (request, reply) => {
  await mkdir(UPLOAD_DIR, { recursive: true })

  const part = await request.file()

  if (!part) {
    return reply.status(400).send({ error: 'No file provided' })
  }

  const ext = path.extname(part.filename).toLowerCase()
  const storedName = crypto.randomUUID() + ext
  const dest = path.join(UPLOAD_DIR, storedName)

  await pipeline(part.file, createWriteStream(dest))

  if (part.file.truncated) {
    return reply.status(413).send({ error: 'File exceeds size limit' })
  }

  return { stored: storedName, mimetype: part.mimetype }
})
```

**Key Points:**
- `part.file` is a Node.js `Readable` stream; it emits chunks as they arrive over the network
- `createWriteStream` opens a writable file handle; `pipeline` moves data between them chunk by chunk
- Memory usage per upload is bounded by the internal stream buffer size, not the file size
- Truncation must be checked after `pipeline` resolves; `busboy` sets `truncated` only after the stream ends

---

### Streaming Multiple Files

When handling multiple file parts, pipeline each sequentially or concurrently depending on I/O constraints:

#### Sequential

```js
fastify.post('/batch', async (request, reply) => {
  await mkdir(UPLOAD_DIR, { recursive: true })
  const results = []

  for await (const part of request.files()) {
    const storedName = crypto.randomUUID() + path.extname(part.filename).toLowerCase()
    const dest = path.join(UPLOAD_DIR, storedName)

    await pipeline(part.file, createWriteStream(dest))

    if (part.file.truncated) {
      return reply.status(413).send({
        error: `"${part.filename}" exceeds size limit`
      })
    }

    results.push({ stored: storedName, mimetype: part.mimetype })
  }

  return { files: results }
})
```

**Key Points:**
- Sequential processing serializes disk writes, which reduces I/O contention but increases total time
- Returning on truncation inside the loop leaves remaining parts unconsumed — drain them if early exit is required (see the previous topic for the drain pattern)

#### Concurrent

```js
fastify.post('/batch', async (request, reply) => {
  await mkdir(UPLOAD_DIR, { recursive: true })
  const writes = []

  for await (const part of request.files()) {
    const storedName = crypto.randomUUID() + path.extname(part.filename).toLowerCase()
    const dest = path.join(UPLOAD_DIR, storedName)

    // Collect promises without awaiting each individually
    writes.push(
      pipeline(part.file, createWriteStream(dest)).then(() => ({
        truncated: part.file.truncated,
        stored: storedName,
        mimetype: part.mimetype
      }))
    )
  }

  const results = await Promise.all(writes)
  const truncated = results.find(r => r.truncated)

  if (truncated) {
    return reply.status(413).send({ error: 'One or more files exceed the size limit' })
  }

  return { files: results }
})
```

**Key Points:**
- Parts must still be iterated to completion before `Promise.all` settles; the `for await` loop drives iteration, pipeline calls run concurrently
- [Inference] Concurrent writes to local disk may not be faster than sequential writes depending on storage type (HDD vs SSD vs network-attached); measure under realistic conditions
- Error handling in concurrent mode requires care — a rejected promise in `Promise.all` aborts the others; consider `Promise.allSettled` if partial success is acceptable

---

### Streaming to Object Storage (AWS S3)

A common production pattern: forward the upload stream directly to S3 without writing to disk at all.

```bash
npm install @aws-sdk/client-s3 @aws-sdk/lib-storage
```

```js
import { S3Client } from '@aws-sdk/client-s3'
import { Upload } from '@aws-sdk/lib-storage'

const s3 = new S3Client({ region: 'us-east-1' })
const BUCKET = 'my-upload-bucket'

fastify.post('/upload', async (request, reply) => {
  const part = await request.file()

  if (!part) {
    return reply.status(400).send({ error: 'No file provided' })
  }

  const key = `uploads/${crypto.randomUUID()}${path.extname(part.filename).toLowerCase()}`

  const upload = new Upload({
    client: s3,
    params: {
      Bucket: BUCKET,
      Key: key,
      Body: part.file,       // pass the readable stream directly
      ContentType: part.mimetype
    }
  })

  await upload.done()

  if (part.file.truncated) {
    return reply.status(413).send({ error: 'File exceeds size limit' })
  }

  return { key, bucket: BUCKET }
})
```

**Key Points:**
- `@aws-sdk/lib-storage` `Upload` handles multipart S3 upload internally, splitting the stream into parts and uploading concurrently
- The server acts as a pass-through; file data flows from the client socket to S3 without touching disk
- `part.file` is passed directly as `Body`; the SDK consumes the stream
- [Inference] Network latency between your server and S3 determines throughput; if the client uploads faster than S3 accepts, backpressure through `pipeline` would normally throttle the client — using the SDK's `Upload` class directly may or may not apply backpressure identically to `pipeline`; verify under load

---

### Streaming Through a Transform

Insert processing logic between the source and destination using a `Transform` stream. This is useful for hashing, compression, or encryption during upload.

#### Computing a Hash While Streaming

```js
import { createHash } from 'node:crypto'
import { Transform } from 'node:stream'

function hashStream (algorithm = 'sha256') {
  const hash = createHash(algorithm)
  let digest = null

  const transform = new Transform({
    transform (chunk, encoding, callback) {
      hash.update(chunk)
      this.push(chunk)
      callback()
    },
    flush (callback) {
      digest = hash.digest('hex')
      callback()
    }
  })

  return { transform, getDigest: () => digest }
}

fastify.post('/upload', async (request, reply) => {
  const part = await request.file()

  if (!part) {
    return reply.status(400).send({ error: 'No file provided' })
  }

  const storedName = crypto.randomUUID() + path.extname(part.filename).toLowerCase()
  const dest = path.join(UPLOAD_DIR, storedName)
  const { transform, getDigest } = hashStream('sha256')

  await pipeline(
    part.file,
    transform,
    createWriteStream(dest)
  )

  if (part.file.truncated) {
    return reply.status(413).send({ error: 'File too large' })
  }

  return {
    stored: storedName,
    sha256: getDigest()
  }
})
```

**Key Points:**
- The transform passes chunks through unchanged while updating the hash state
- `getDigest()` is only valid after the stream ends (after `pipeline` resolves)
- `pipeline` accepts any number of intermediate `Transform` stages between source and destination

---

#### Compressing While Streaming

```js
import { createGzip } from 'node:zlib'

fastify.post('/upload', async (request, reply) => {
  const part = await request.file()

  if (!part) {
    return reply.status(400).send({ error: 'No file provided' })
  }

  const storedName = crypto.randomUUID() + path.extname(part.filename).toLowerCase() + '.gz'
  const dest = path.join(UPLOAD_DIR, storedName)

  await pipeline(
    part.file,
    createGzip(),
    createWriteStream(dest)
  )

  if (part.file.truncated) {
    return reply.status(413).send({ error: 'File too large' })
  }

  return { stored: storedName }
})
```

**Key Points:**
- `createGzip()` is a built-in Node.js `Transform` stream; no additional dependencies required
- Compression ratio depends on file content; already-compressed formats (JPEG, MP4, ZIP) will not compress meaningfully
- [Inference] CPU usage from compression may become a bottleneck under high concurrency; evaluate whether server-side compression is the right layer for your architecture

---

### Forwarding an Upload to a Downstream HTTP Service

Stream the upload directly to another HTTP endpoint without buffering:

```js
import { pipeline } from 'node:stream/promises'
import { request as httpRequest } from 'node:https'

fastify.post('/proxy-upload', async (request, reply) => {
  const part = await request.file()

  if (!part) {
    return reply.status(400).send({ error: 'No file' })
  }

  await new Promise((resolve, reject) => {
    const req = httpRequest({
      hostname: 'storage.internal',
      port: 443,
      path: '/ingest',
      method: 'PUT',
      headers: {
        'Content-Type': part.mimetype,
        'Transfer-Encoding': 'chunked'
      }
    }, (res) => {
      res.resume() // consume response
      res.on('end', resolve)
    })

    req.on('error', reject)
    part.file.pipe(req)
  })

  return { forwarded: true }
})
```

**Key Points:**
- `Transfer-Encoding: chunked` is required when the content length is unknown at stream start
- `.pipe()` is used here because the downstream target is a raw `http.ClientRequest`, not a standard `stream.Writable` compatible with `pipeline` in all Node.js versions; verify compatibility with your runtime version
- [Inference] Backpressure behavior when piping to an outgoing HTTP request depends on the downstream server's read rate and Node.js's HTTP client implementation; monitor for memory growth under high load

---

### Tracking Upload Progress

Node.js streams do not natively emit progress events. Insert a counting `Transform` to track bytes:

```js
import { Transform } from 'node:stream'

function progressTracker (onProgress) {
  let bytesReceived = 0

  return new Transform({
    transform (chunk, encoding, callback) {
      bytesReceived += chunk.length
      onProgress(bytesReceived)
      this.push(chunk)
      callback()
    }
  })
}

fastify.post('/upload', async (request, reply) => {
  const part = await request.file()

  if (!part) {
    return reply.status(400).send({ error: 'No file' })
  }

  const storedName = crypto.randomUUID() + path.extname(part.filename).toLowerCase()
  const dest = path.join(UPLOAD_DIR, storedName)

  await pipeline(
    part.file,
    progressTracker(bytes => {
      fastify.log.info({ bytes }, 'upload progress')
    }),
    createWriteStream(dest)
  )

  return { stored: storedName }
})
```

**Key Points:**
- Progress tracking adds minimal overhead; the transform passes chunks through unchanged
- Logging every chunk may produce excessive output for large files; consider logging at intervals instead
- Reporting progress to the client in real time requires a separate channel (WebSocket, SSE); HTTP responses cannot send progress updates mid-stream in the standard request/response model

---

### Error Handling in Streaming Pipelines

`pipeline` rejects if any stage emits an error. Wrap in try/catch and clean up partial files:

```js
import { unlink } from 'node:fs/promises'

fastify.post('/upload', async (request, reply) => {
  const part = await request.file()

  if (!part) {
    return reply.status(400).send({ error: 'No file provided' })
  }

  const storedName = crypto.randomUUID() + path.extname(part.filename).toLowerCase()
  const dest = path.join(UPLOAD_DIR, storedName)

  try {
    await pipeline(part.file, createWriteStream(dest))
  } catch (err) {
    // Attempt to remove the partial file
    try {
      await unlink(dest)
    } catch {
      // File may not have been created; ignore
    }

    fastify.log.error({ err }, 'Upload pipeline failed')
    return reply.status(500).send({ error: 'Upload failed' })
  }

  if (part.file.truncated) {
    await unlink(dest).catch(() => {})
    return reply.status(413).send({ error: 'File too large' })
  }

  return { stored: storedName }
})
```

**Key Points:**
- A failed `pipeline` may leave a partial file at `dest`; always attempt cleanup on error
- `unlink` failures during cleanup are swallowed here because the primary error is more important to surface
- Truncation produces a complete (but truncated) file on disk; delete it before returning the error response

---

### Backpressure

Backpressure is the mechanism by which a slow destination signals a fast source to pause. `pipeline` manages this automatically.

```
Client → [network] → part.file (Readable) → pipeline → createWriteStream (Writable)
                                                ↕ backpressure
```

If the disk write is slower than the network receive rate, `pipeline` pauses reading from `part.file`, which causes the TCP receive buffer to fill, which causes the client's send rate to slow.

**Key Points:**
- `pipeline` handles backpressure correctly; `.pipe()` does not reliably do so in all error scenarios
- [Inference] Backpressure to the client depends on TCP flow control and the client's upload implementation; not all HTTP clients respond to backpressure signals correctly — behavior may vary by client

---

### Common Mistakes

| Mistake | Effect |
|---|---|
| Using `.pipe()` instead of `pipeline` | Errors from the destination are not propagated; partial files may be silently written |
| Checking `part.file.truncated` before stream ends | May yield a false result; check only after `pipeline` resolves |
| Not cleaning up partial files on pipeline error | Disk fills with incomplete files over time |
| Streaming concurrently without bounding parallelism | Uncontrolled I/O under high concurrency |
| Passing `part.file` to an SDK after the stream has been consumed | Stream is exhausted; SDK receives empty body |
| Logging progress on every chunk for large files | Log volume becomes excessive; use interval-based logging |

---

**Conclusion:**
Streaming file uploads in Fastify center on treating `part.file` as what it is — a Node.js `Readable` stream — and connecting it to a destination using `pipeline`. Whether the destination is local disk, object storage, or a downstream service, the mechanics are consistent: consume the stream completely, check truncation after completion, clean up on failure, and use `Transform` stages for any processing that must happen in flight.