## Streaming Binary Responses

### What Is Binary Streaming in tRPC?

Binary streaming refers to sending binary data — files, images, video, audio, generated content — as a continuous byte stream from server to client, rather than as a complete JSON response. tRPC's default transport is JSON over HTTP, which is unsuitable for raw binary data at any significant size.

**Key Points:**

- tRPC procedures return serializable JavaScript values. They cannot natively return a `ReadableStream`, `Buffer`, or `Blob` as a procedure output.
- Binary streaming requires stepping outside tRPC's response pipeline for the actual byte delivery.
- tRPC still has a role: authentication, authorization, metadata, and URL generation remain in procedures. The stream itself is served by a separate HTTP handler or a signed URL.

---

### Why tRPC Cannot Directly Stream Binary

tRPC's response pipeline:

```
Procedure return value
        │
        ▼
  Transformer (JSON.stringify / superjson)
        │
        ▼
  HTTP response body (text/JSON)
```

Every value returned from a procedure passes through a serialization transformer. Binary buffers serialized as JSON lose integrity unless base64-encoded, which defeats streaming. There is no mechanism in the current tRPC protocol to emit raw bytes mid-stream from a procedure return. [Unverified: whether future tRPC versions introduce native binary streaming — verify against release notes for your version.]

---

### Architectural Boundary

The correct architectural split is:

```
┌──────────────────────────────────────────────┐
│               tRPC Procedures                │
│                                              │
│  • Authenticate request                      │
│  • Authorize access to resource              │
│  • Generate signed / time-limited token      │
│  • Return { streamUrl } or { token }         │
└──────────────────┬───────────────────────────┘
                   │
                   │ client uses token/url
                   ▼
┌──────────────────────────────────────────────┐
│         Raw HTTP Streaming Endpoint          │
│   (Express route / Next.js route handler)    │
│                                              │
│  • Validate token                            │
│  • Open byte stream (file, S3, generated)    │
│  • Pipe to HTTP response                     │
│  • Set correct Content-Type headers          │
└──────────────────────────────────────────────┘
```

tRPC coordinates access. A separate HTTP handler delivers bytes.

---

### Pattern 1: tRPC Issues Token, Separate Endpoint Streams

This is the primary recommended pattern. tRPC generates a short-lived token scoped to a resource. The client uses that token to request the binary stream from a non-tRPC HTTP endpoint.

#### Step 1: tRPC procedure issues a stream token

```ts
// routers/files.ts
import { z } from 'zod';
import { router, protectedProcedure } from '../trpc';
import { TRPCError } from '@trpc/server';
import { signStreamToken } from '../lib/streamTokens';

export const filesRouter = router({
  getStreamToken: protectedProcedure
    .input(z.object({
      fileId: z.string(),
    }))
    .query(async ({ input, ctx }) => {
      const file = await db.file.findFirst({
        where: { id: input.fileId, userId: ctx.user.id },
      });

      if (!file) {
        throw new TRPCError({ code: 'NOT_FOUND', message: 'File not found' });
      }

      const token = await signStreamToken({
        fileId: file.id,
        storageKey: file.storageKey,
        userId: ctx.user.id,
        expiresIn: 60, // seconds
      });

      return { token, streamUrl: `/api/stream/${token}` };
    }),
});
```

#### Step 2: Stream token signing

```ts
// lib/streamTokens.ts
import jwt from 'jsonwebtoken';

const SECRET = process.env.STREAM_TOKEN_SECRET!;

export interface StreamTokenPayload {
  fileId: string;
  storageKey: string;
  userId: string;
}

export function signStreamToken(
  params: StreamTokenPayload & { expiresIn: number }
): string {
  return jwt.sign(
    { fileId: params.fileId, storageKey: params.storageKey, userId: params.userId },
    SECRET,
    { expiresIn: params.expiresIn }
  );
}

export function verifyStreamToken(token: string): StreamTokenPayload {
  return jwt.verify(token, SECRET) as StreamTokenPayload;
}
```

#### Step 3: Express streaming endpoint

```ts
// server.ts
import express from 'express';
import { GetObjectCommand } from '@aws-sdk/client-s3';
import { s3 } from './lib/s3';
import { verifyStreamToken } from './lib/streamTokens';

app.get('/api/stream/:token', async (req, res) => {
  let payload: StreamTokenPayload;

  try {
    payload = verifyStreamToken(req.params.token);
  } catch {
    return res.status(401).json({ error: 'Invalid or expired stream token' });
  }

  try {
    const command = new GetObjectCommand({
      Bucket: process.env.S3_BUCKET!,
      Key: payload.storageKey,
    });

    const s3Response = await s3.send(command);

    if (!s3Response.Body) {
      return res.status(404).json({ error: 'Object not found' });
    }

    // Forward S3 metadata headers
    if (s3Response.ContentType) {
      res.setHeader('Content-Type', s3Response.ContentType);
    }
    if (s3Response.ContentLength) {
      res.setHeader('Content-Length', s3Response.ContentLength);
    }

    res.setHeader('Cache-Control', 'private, no-store');
    res.setHeader('Content-Disposition', 'inline');

    // Pipe S3 readable stream directly to HTTP response
    const nodeStream = s3Response.Body.transformToWebStream();
    const reader = nodeStream.getReader();

    const pump = async () => {
      const { done, value } = await reader.read();
      if (done) { res.end(); return; }
      res.write(value);
      await pump();
    };

    await pump();
  } catch (err) {
    if (!res.headersSent) {
      res.status(500).json({ error: 'Stream error' });
    }
  }
});
```

[Inference] Piping directly from S3's response stream to the HTTP response avoids buffering the entire object in server memory. Behavior depends on your Node.js version, SDK version, and whether the stream is consumed correctly. Verify error handling for aborted client connections.

---

### Pattern 2: Redirect to Presigned URL

The simplest binary streaming pattern. tRPC authorizes the request and redirects the client to a presigned storage URL. The storage provider streams the bytes directly to the client.

```ts
// In an Express route handler wrapping a tRPC-authorized check
// Or as a non-tRPC route that validates a session cookie

app.get('/api/download/:fileId', requireAuth, async (req, res) => {
  const file = await db.file.findFirst({
    where: { id: req.params.fileId, userId: req.user.id },
  });

  if (!file) return res.status(404).end();

  const signedUrl = await storage.getDownloadUrl({
    key: file.storageKey,
    expiresIn: 30,
    filename: file.label,
  });

  res.redirect(302, signedUrl);
});
```

tRPC provides the `fileId` lookup and `{ downloadUrl }` in a query; the actual redirect and stream are handled outside tRPC.

**Key Points:**

- The presigned URL is visible to the client after redirect. If that is unacceptable (e.g., for DRM or audit reasons), use Pattern 1 instead.
- Short expiry (30 seconds) limits window for URL sharing. [Inference]

---

### Pattern 3: Streaming Generated Binary Content

For server-generated binary output — PDFs, images, archives, reports — the server generates the content on demand and streams it to the client.

#### PDF generation example (Express + pdfkit)

```ts
import PDFDocument from 'pdfkit';

app.get('/api/export/report/:token', async (req, res) => {
  let payload: StreamTokenPayload;

  try {
    payload = verifyStreamToken(req.params.token);
  } catch {
    return res.status(401).end();
  }

  const reportData = await db.report.findFirst({
    where: { id: payload.fileId, userId: payload.userId },
  });

  if (!reportData) return res.status(404).end();

  res.setHeader('Content-Type', 'application/pdf');
  res.setHeader(
    'Content-Disposition',
    `attachment; filename="report-${reportData.id}.pdf"`
  );
  res.setHeader('Transfer-Encoding', 'chunked');

  const doc = new PDFDocument({ autoFirstPage: false });
  doc.pipe(res);

  doc.addPage();
  doc.fontSize(18).text(reportData.title, { align: 'center' });
  doc.moveDown();
  doc.fontSize(12).text(reportData.content);

  doc.end();
});
```

tRPC procedure to initiate:

```ts
exportReport: protectedProcedure
  .input(z.object({ reportId: z.string() }))
  .mutation(async ({ input, ctx }) => {
    const report = await db.report.findFirst({
      where: { id: input.reportId, userId: ctx.user.id },
    });

    if (!report) {
      throw new TRPCError({ code: 'NOT_FOUND', message: 'Report not found' });
    }

    const token = signStreamToken({
      fileId: report.id,
      storageKey: '',
      userId: ctx.user.id,
      expiresIn: 120,
    });

    return { downloadUrl: `/api/export/report/${token}` };
  }),
```

---

### Pattern 4: Range Requests (Partial Content)

For media files (audio, video), clients issue HTTP range requests to seek without downloading the full file. This requires explicit range header handling.

```ts
app.get('/api/media/:token', async (req, res) => {
  let payload: StreamTokenPayload;

  try {
    payload = verifyStreamToken(req.params.token);
  } catch {
    return res.status(401).end();
  }

  const rangeHeader = req.headers.range;

  const command = new HeadObjectCommand({
    Bucket: process.env.S3_BUCKET!,
    Key: payload.storageKey,
  });

  const head = await s3.send(command);
  const totalSize = head.ContentLength ?? 0;
  const contentType = head.ContentType ?? 'application/octet-stream';

  if (!rangeHeader) {
    // No range — serve full file
    res.setHeader('Content-Type', contentType);
    res.setHeader('Content-Length', totalSize);
    res.setHeader('Accept-Ranges', 'bytes');

    const getCmd = new GetObjectCommand({
      Bucket: process.env.S3_BUCKET!,
      Key: payload.storageKey,
    });
    const obj = await s3.send(getCmd);
    (obj.Body as any).pipe(res);
    return;
  }

  // Parse range header: "bytes=start-end"
  const [startStr, endStr] = rangeHeader.replace('bytes=', '').split('-');
  const start = parseInt(startStr, 10);
  const end = endStr ? parseInt(endStr, 10) : totalSize - 1;
  const chunkSize = end - start + 1;

  res.status(206); // Partial Content
  res.setHeader('Content-Range', `bytes ${start}-${end}/${totalSize}`);
  res.setHeader('Accept-Ranges', 'bytes');
  res.setHeader('Content-Length', chunkSize);
  res.setHeader('Content-Type', contentType);

  const rangeCommand = new GetObjectCommand({
    Bucket: process.env.S3_BUCKET!,
    Key: payload.storageKey,
    Range: `bytes=${start}-${end}`,
  });

  const rangeResponse = await s3.send(rangeCommand);
  (rangeResponse.Body as any).pipe(res);
});
```

[Inference] Proper range request support is required for HTML5 `<video>` and `<audio>` elements to seek correctly. Without it, media elements may only play from the beginning and fail to support scrubbing. Behavior is browser-dependent.

---

### Pattern 5: Server-Sent Events for Progress + Separate Binary Stream

For long-running binary generation (large exports, video processing), combine SSE for progress reporting with a separate binary download URL.

```
Client                          Server
  │                               │
  ├─ mutation: startExport ──────►│
  ◄─ { jobId } ───────────────────┤
  │                               │
  ├─ EventSource /api/progress/{jobId}
  │◄── data: { percent: 20 } ─────┤
  │◄── data: { percent: 60 } ─────┤
  │◄── data: { percent: 100,       │
  │            downloadToken } ───┤
  │                               │
  ├─ GET /api/stream/{downloadToken}
  ◄─ binary stream ───────────────┤
```

#### SSE progress endpoint

```ts
app.get('/api/progress/:jobId', requireAuth, async (req, res) => {
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');
  res.flushHeaders();

  const send = (data: object) => {
    res.write(`data: ${JSON.stringify(data)}\n\n`);
  };

  const interval = setInterval(async () => {
    const job = await db.exportJob.findUnique({
      where: { id: req.params.jobId, userId: req.user.id },
    });

    if (!job) {
      send({ error: 'Job not found' });
      clearInterval(interval);
      res.end();
      return;
    }

    send({ percent: job.progress });

    if (job.status === 'complete') {
      const token = signStreamToken({
        fileId: job.id,
        storageKey: job.outputKey,
        userId: req.user.id,
        expiresIn: 300,
      });
      send({ percent: 100, downloadToken: token });
      clearInterval(interval);
      res.end();
    }

    if (job.status === 'failed') {
      send({ error: job.errorMessage });
      clearInterval(interval);
      res.end();
    }
  }, 1000);

  req.on('close', () => clearInterval(interval));
});
```

---

### HTTP Headers Reference for Binary Streaming

| Header | Purpose | Example value |
| --- | --- | --- |
| `Content-Type` | Declares byte format | `application/pdf`, `video/mp4` |
| `Content-Length` | Total byte count if known | `204800` |
| `Content-Disposition` | Browser download behavior | `attachment; filename="file.pdf"` |
| `Content-Range` | Range response boundaries | `bytes 0-1023/204800` |
| `Accept-Ranges` | Signals range support | `bytes` |
| `Transfer-Encoding` | For unknown-length streams | `chunked` |
| `Cache-Control` | Caching policy | `private, no-store` |

> ⚠️ Do not set both `Content-Length` and `Transfer-Encoding: chunked` simultaneously. They are mutually exclusive. [Inference] Some HTTP servers may strip one automatically, but relying on that is not safe.

---

### Client-Side Consumption

#### Triggering a download

```ts
async function downloadFile(fileId: string) {
  const { streamUrl } = await trpc.files.getStreamToken.query({ fileId });

  // Create a temporary anchor and trigger download
  const a = document.createElement('a');
  a.href = streamUrl;
  a.download = ''; // use server-provided filename from Content-Disposition
  document.body.appendChild(a);
  a.click();
  document.body.removeChild(a);
}
```

#### Streaming into a Blob for in-page use

```ts
async function loadFileAsBlob(fileId: string): Promise<string> {
  const { streamUrl } = await trpc.files.getStreamToken.query({ fileId });

  const response = await fetch(streamUrl);

  if (!response.ok) {
    throw new Error(`Stream request failed: ${response.status}`);
  }

  const blob = await response.blob();
  return URL.createObjectURL(blob); // use as src for <img>, <video>, etc.
}
```

[Inference] `URL.createObjectURL` produces an in-memory object URL. Call `URL.revokeObjectURL` when the URL is no longer needed to release memory. Behavior is browser-dependent.

---

### Security Considerations

| Concern | Mitigation |
| --- | --- |
| Token replay | Short expiry (30–120s); single-use tokens if required |
| Token scope | Embed `userId` and `fileId` in token; verify both server-side |
| Content-Type injection | Set `Content-Type` from your own database record, not from client input or raw S3 metadata |
| Directory traversal | Never use client-supplied paths; resolve keys from database only |
| Unbounded stream consumption | Set response timeouts; handle client disconnect events |
| Sensitive file exposure via URL | Use opaque tokens, not predictable keys or filenames, in stream URLs |

---

### Pattern Comparison

| Pattern | Use case | Server memory | Client sees storage URL | Seekable |
| --- | --- | --- | --- | --- |
| Token + proxy stream | Sensitive files, audit logging | Low (piped) | No | With range support |
| Redirect to presigned URL | Non-sensitive, simple downloads | None | Yes | Provider-dependent |
| Generated binary stream | On-demand PDFs, exports | Moderate | No | No |
| Range request support | Audio / video media | Low (piped) | No | Yes |
| SSE progress + stream | Long-running exports | Low | No | No |

---

**Conclusion:**
tRPC cannot natively stream binary responses — its serialization pipeline is designed for structured data. The correct approach is to use tRPC for what it does well (authentication, authorization, metadata) and delegate byte delivery to a raw HTTP endpoint or a storage provider's presigned URL. Token-based stream authorization keeps credentials off the client while preserving tRPC's type-safe coordination role. Choose the pattern based on whether the file is pre-stored or generated, whether the client should see the storage URL, and whether seeking is required.

**Next Steps:**

- Implement token expiry cleanup to prevent accumulation of unused stream tokens
- Add `Content-Disposition` headers consistently so browsers handle downloads correctly without client-side filename logic
- Test range request behavior explicitly with your target media player or browser before deploying media streaming