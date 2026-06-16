## Handling Multipart Form Data

### What Is Multipart Form Data?

Multipart form data is an HTTP encoding format (`multipart/form-data`) used to transmit binary data — most commonly file uploads — alongside text fields in a single request. It is distinct from `application/json`, which tRPC uses by default.

**Key Points:**

- tRPC's default request handler expects JSON bodies. It does not natively parse `multipart/form-data`.
- File uploads must be handled outside the standard tRPC procedure input pipeline, or via a dedicated middleware layer before tRPC processes the request.
- This is a known architectural boundary in tRPC — not a bug or oversight. [Inference]

---

### Why tRPC Does Not Handle It Natively

tRPC procedures receive input via Zod-validated JSON. The tRPC protocol has no built-in concept of file streams or multipart boundaries. Accepting a file upload therefore requires one of:

1. Parsing the multipart body before it reaches tRPC, then passing parsed data via context
2. Bypassing tRPC entirely for upload endpoints and handling them as raw HTTP routes
3. Converting file data to base64 and sending it as JSON (limited to small files)

[Inference] Option 1 is the most idiomatic tRPC-compatible approach for most use cases. Option 2 is pragmatic for large or streaming uploads. Option 3 is generally discouraged for anything beyond small thumbnails due to size and encoding overhead.

---

### Architecture Overview

```
Client (FormData)
       │
       ▼
HTTP Server (Express / Fastify / Next.js)
       │
       ├─── Multipart parser middleware (multer / busboy / formidable)
       │           │
       │           ▼
       │    Parsed fields + file buffers/paths
       │           │
       │           ▼
       └─── tRPC createContext()
                   │
                   ▼
            ctx.file / ctx.fields
                   │
                   ▼
            tRPC Procedure Handler
```

The multipart body is parsed before tRPC's own handler runs. Parsed results are injected into context, making them available to procedures without bypassing tRPC's type system for the non-file fields.

---

### Setup: Express + Multer

Multer is a widely used Node.js middleware for parsing `multipart/form-data`.

```bash
npm install multer
npm install --save-dev @types/multer
```

#### Configure Multer

```ts
// lib/multer.ts
import multer from 'multer';

export const upload = multer({
  storage: multer.memoryStorage(), // store file in memory as Buffer
  limits: {
    fileSize: 5 * 1024 * 1024, // 5MB limit
  },
});
```

#### Apply Before tRPC Handler

```ts
// server.ts
import express from 'express';
import { createExpressMiddleware } from '@trpc/server/adapters/express';
import { upload } from './lib/multer';
import { appRouter } from './router';
import { createContext } from './context';

const app = express();

// Apply multer before tRPC for upload routes
app.use(
  '/api/trpc',
  (req, res, next) => {
    const contentType = req.headers['content-type'] ?? '';
    if (contentType.includes('multipart/form-data')) {
      upload.single('file')(req, res, next);
    } else {
      next();
    }
  },
  createExpressMiddleware({ router: appRouter, createContext })
);
```

**Key Points:**

- Multer is applied conditionally — only for multipart requests. JSON requests pass through unaffected.
- `upload.single('file')` parses one file field named `file`. Use `upload.array()` or `upload.fields()` for multiple files.

---

### Passing Parsed Data via Context

```ts
// context.ts
import { Request, Response } from 'express';

export async function createContext({
  req,
  res,
}: {
  req: Request;
  res: Response;
}) {
  return {
    req,
    res,
    file: (req as any).file as Express.Multer.File | undefined,
    fields: req.body as Record<string, string>,
  };
}

export type Context = Awaited<ReturnType<typeof createContext>>;
```

---

### Procedure: Accessing the Uploaded File

```ts
// routers/upload.ts
import { z } from 'zod';
import { router, publicProcedure } from '../trpc';
import { TRPCError } from '@trpc/server';

export const uploadRouter = router({
  uploadAvatar: publicProcedure
    .input(z.object({
      userId: z.string(),
    }))
    .mutation(async ({ input, ctx }) => {
      if (!ctx.file) {
        throw new TRPCError({
          code: 'BAD_REQUEST',
          message: 'No file provided',
        });
      }

      const { buffer, mimetype, originalname, size } = ctx.file;

      // Validate MIME type in handler — Zod cannot validate file buffers
      const allowedTypes = ['image/jpeg', 'image/png', 'image/webp'];
      if (!allowedTypes.includes(mimetype)) {
        throw new TRPCError({
          code: 'BAD_REQUEST',
          message: `Unsupported file type: ${mimetype}`,
        });
      }

      // Pass buffer to your storage layer
      const url = await storageService.upload({
        buffer,
        filename: originalname,
        contentType: mimetype,
        userId: input.userId,
      });

      return { url };
    }),
});
```

**Key Points:**

- Zod validates only the JSON fields (e.g., `userId`). File validation (MIME type, size) must be done manually in the handler or in Multer's configuration.
- `ctx.file` is untyped by default — the cast to `Express.Multer.File` should be validated, not assumed. Behavior depends on whether Multer actually ran for the request.

---

### Client: Sending FormData

tRPC's default client sends JSON. To send `multipart/form-data`, you must bypass the tRPC client and use `fetch` directly, or use a custom link.

#### Direct fetch approach

```ts
// client-side
async function uploadAvatar(userId: string, file: File) {
  const formData = new FormData();
  formData.append('file', file);
  formData.append('userId', userId); // text field alongside file

  const response = await fetch('/api/trpc/upload.uploadAvatar', {
    method: 'POST',
    body: formData,
    // Do NOT set Content-Type manually — browser sets it with boundary
  });

  if (!response.ok) {
    throw new Error('Upload failed');
  }

  return response.json();
}
```

> ⚠️ Do not set `Content-Type: multipart/form-data` manually. The browser must set it automatically to include the correct `boundary` parameter. Manually setting it will cause parsing to fail.

[Inference] Because this bypasses the tRPC client, you lose automatic type inference on the response. You can re-add type safety by asserting the response type against your router's inferred output type, but this is manual and not enforced at runtime.

---

### Setup: Next.js App Router

In Next.js App Router, tRPC typically uses `fetchRequestHandler`. Multipart parsing requires intercepting the request before it reaches the handler.

```ts
// app/api/trpc/[trpc]/route.ts
import { fetchRequestHandler } from '@trpc/server/adapters/fetch';
import { appRouter } from '@/server/router';
import { createContext } from '@/server/context';

async function handler(req: Request) {
  const contentType = req.headers.get('content-type') ?? '';

  let file: File | undefined;
  let extraFields: Record<string, string> = {};

  if (contentType.includes('multipart/form-data')) {
    const formData = await req.formData();

    const fileEntry = formData.get('file');
    if (fileEntry instanceof File) {
      file = fileEntry;
    }

    for (const [key, value] of formData.entries()) {
      if (typeof value === 'string') {
        extraFields[key] = value;
      }
    }
  }

  return fetchRequestHandler({
    endpoint: '/api/trpc',
    req,
    router: appRouter,
    createContext: () => createContext({ req, file, extraFields }),
  });
}

export { handler as GET, handler as POST };
```

[Inference] Calling `req.formData()` consumes the request body. The `req` object passed to `fetchRequestHandler` will have an empty body afterward. Depending on your tRPC version and adapter internals, this may cause issues if the handler also attempts to read the body. Verify against your specific version.

---

### Fastify: Using `@fastify/multipart`

```bash
npm install @fastify/multipart
```

```ts
import Fastify from 'fastify';
import multipart from '@fastify/multipart';
import { fastifyTRPCPlugin } from '@trpc/server/adapters/fastify';
import { appRouter } from './router';
import { createContext } from './context';

const app = Fastify();

app.register(multipart, {
  limits: { fileSize: 5 * 1024 * 1024 },
});

// Parse multipart before tRPC sees the request
app.addHook('preHandler', async (req) => {
  const contentType = req.headers['content-type'] ?? '';
  if (contentType.includes('multipart/form-data')) {
    const data = await req.file();
    (req as any).uploadedFile = data;
  }
});

app.register(fastifyTRPCPlugin, {
  prefix: '/trpc',
  trpcOptions: { router: appRouter, createContext },
});
```

[Unverified: exact compatibility between `@fastify/multipart` hook ordering and `fastifyTRPCPlugin` registration — verify against your Fastify and tRPC adapter versions.]

---

### Validation Responsibilities

Since file data bypasses Zod, validation must be explicit:

| Concern | Where to validate |
| --- | --- |
| File presence | Procedure handler (`ctx.file` check) |
| MIME type | Multer `fileFilter` config or handler |
| File size | Multer `limits.fileSize` config |
| File count | Multer `upload.array()` with max count |
| Text field types | Zod `.input()` as normal |
| File content (e.g., real image) | Application layer — magic byte check [Inference] |

#### Multer fileFilter example

```ts
export const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (req, file, cb) => {
    const allowed = ['image/jpeg', 'image/png', 'image/webp'];
    if (allowed.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error(`Unsupported type: ${file.mimetype}`));
    }
  },
});
```

> ⚠️ MIME types reported by the client can be spoofed. Server-side MIME validation from file headers (magic bytes) provides stronger guarantees than trusting `file.mimetype` alone. [Inference] Libraries such as `file-type` can assist with this.

---

### Base64 Encoding Approach (Small Files Only)

For small files where multipart complexity is undesirable, base64 encoding allows the file to be sent as JSON:

```ts
// Client
const buffer = await file.arrayBuffer();
const base64 = btoa(String.fromCharCode(...new Uint8Array(buffer)));

await trpc.upload.uploadSmallImage.mutate({
  filename: file.name,
  mimeType: file.type,
  data: base64,
});
```

```ts
// Procedure
.input(z.object({
  filename: z.string(),
  mimeType: z.string(),
  data: z.string(), // base64
}))
.mutation(async ({ input }) => {
  const buffer = Buffer.from(input.data, 'base64');
  // use buffer...
});
```

**Limitations:**

- Base64 encoding increases payload size by approximately 33%.
- Large files will inflate memory usage and hit JSON body size limits.
- [Inference] Suitable only for small assets such as avatars or thumbnails — not documents or video.

---

### Presigned URL Pattern (Recommended for Large Files)

For large files, the recommended pattern is to avoid sending the file through your server entirely:

```
Client                  tRPC Server              Storage (S3 / GCS)
  │                         │                          │
  ├─ mutation: getUploadUrl ─►                          │
  │                         ├─ generate presigned URL ─►
  │                         ◄─ presigned URL ───────────┤
  ◄─ { uploadUrl, fileKey } ─┤                          │
  │                         │                          │
  ├─ PUT file directly ──────────────────────────────►  │
  │                         │                          │
  ├─ mutation: confirmUpload(fileKey) ─►                │
  │                         ├─ verify + finalize        │
  ◄─ { fileUrl } ───────────┤                          │
```

```ts
export const uploadRouter = router({
  getUploadUrl: protectedProcedure
    .input(z.object({
      filename: z.string(),
      contentType: z.string(),
      size: z.number().max(100 * 1024 * 1024), // 100MB max
    }))
    .mutation(async ({ input, ctx }) => {
      const key = `uploads/${ctx.user.id}/${Date.now()}-${input.filename}`;

      const uploadUrl = await s3.getSignedUrlPromise('putObject', {
        Bucket: process.env.S3_BUCKET,
        Key: key,
        ContentType: input.contentType,
        Expires: 300, // 5 minutes
      });

      return { uploadUrl, key };
    }),

  confirmUpload: protectedProcedure
    .input(z.object({ key: z.string() }))
    .mutation(async ({ input, ctx }) => {
      // Verify file exists in storage, then persist record
      await db.file.create({
        data: { key: input.key, userId: ctx.user.id },
      });
      return { success: true };
    }),
});
```

[Inference] This pattern offloads bandwidth and processing cost from your server. The tradeoff is additional round trips and dependency on the storage provider's presigned URL mechanism. Behavior depends on your storage provider's implementation.

---

### Approach Comparison

| Approach | File size | Complexity | Type safety | Server bandwidth |
| --- | --- | --- | --- | --- |
| Multer via context | Small–medium | Medium | Partial | Full |
| base64 JSON | Small only | Low | Full (Zod) | Full + 33% overhead |
| Presigned URL | Any | Higher | Partial | Bypassed |
| Raw HTTP route (no tRPC) | Any | Low | None | Full |

---

**Conclusion:**
tRPC has no native multipart support; file uploads require handling at the HTTP middleware layer before tRPC's pipeline runs. The three practical approaches — middleware parsing into context, base64 JSON, and presigned URLs — suit different file sizes and complexity tolerances. For most production use cases involving user-uploaded files, presigned URLs are [Inference] the most scalable option, while Multer-via-context works well for moderate file sizes without additional infrastructure.

**Next Steps:**

- Validate MIME types server-side using magic bytes, not client-reported values
- Set explicit file size limits at the middleware layer, not only in the procedure
- Consider virus scanning for user-uploaded content before storing or serving it