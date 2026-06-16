## File Upload Patterns with tRPC

### Overview

File uploading in tRPC is not a single solved pattern — it is a design decision with multiple valid approaches, each with different tradeoffs around file size, server load, type safety, and infrastructure complexity. This topic covers the full range of patterns, when to use each, and how to implement them correctly.

**Key Points:**

- tRPC has no native file upload API. All patterns are built on top of HTTP primitives or third-party storage services.
- The right pattern depends on file size, security requirements, and whether you control the storage layer.
- Patterns are not mutually exclusive — large applications often use different patterns for different upload types.

---

### Pattern Taxonomy

```
File Upload Patterns
│
├── 1. Base64 JSON (inline, small files)
├── 2. Multipart via Middleware (server-proxied)
├── 3. Presigned URL (client-to-storage direct)
├── 4. Chunked Upload (large files, resumable)
└── 5. tRPC Mutation + Separate Upload Endpoint (hybrid)
```

---

### Pattern 1: Base64 JSON

The file is converted to a base64 string on the client and sent as part of a standard tRPC mutation input.

#### When to use

- Files under ~1MB
- No additional infrastructure available
- Simplicity is the priority

#### When to avoid

- Files over 1MB — base64 inflates size by ~33% and stresses JSON body limits
- High request volume — base64 decoding is CPU-bound [Inference]

#### Client

```ts
async function uploadFile(file: File) {
  const buffer = await file.arrayBuffer();
  const base64 = Buffer.from(buffer).toString('base64');

  await trpc.files.uploadBase64.mutate({
    filename: file.name,
    mimeType: file.type,
    data: base64,
  });
}
```

#### Procedure

```ts
import { z } from 'zod';
import { router, protectedProcedure } from '../trpc';

const MAX_BASE64_SIZE = 1_400_000; // ~1MB after encoding overhead

export const filesRouter = router({
  uploadBase64: protectedProcedure
    .input(z.object({
      filename: z.string().max(255),
      mimeType: z.string().max(100),
      data: z.string().max(MAX_BASE64_SIZE),
    }))
    .mutation(async ({ input, ctx }) => {
      const buffer = Buffer.from(input.data, 'base64');

      // Validate actual content — do not trust client-reported mimeType
      const { fileTypeFromBuffer } = await import('file-type');
      const detected = await fileTypeFromBuffer(buffer);

      if (!detected || !['image/jpeg', 'image/png'].includes(detected.mime)) {
        throw new TRPCError({
          code: 'BAD_REQUEST',
          message: 'Unsupported or undetectable file type',
        });
      }

      const url = await storageService.save(buffer, {
        filename: input.filename,
        contentType: detected.mime,
      });

      return { url };
    }),
});
```

**Key Points:**

- Always validate file type server-side from the buffer, not from `input.mimeType`. Client-reported MIME types can be spoofed.
- Set `z.string().max()` to enforce a size ceiling at the Zod layer before decoding.

---

### Pattern 2: Multipart via Server Middleware

The file is sent as `multipart/form-data`. A middleware layer (Multer, Busboy, or native `formData()`) parses it before tRPC runs, and the result is injected into context.

#### When to use

- Files up to tens of MB
- You want server-side control over the uploaded bytes
- Acceptable to route file traffic through your server

#### When to avoid

- Very large files — ties up server memory and bandwidth
- Serverless environments with strict request body size limits (e.g., Vercel: 4.5MB body limit on hobby plans) [Unverified: exact limit — verify against your provider's current documentation]

Full implementation covered in the preceding topic (Handling Multipart Form Data). Key points are summarized here for comparison.

```
Client ──multipart/form-data──► Server middleware (Multer)
                                        │
                                   parsed buffer
                                        │
                                   ctx.file ──► tRPC handler ──► storage
```

#### Context shape

```ts
export type Context = {
  user: User | null;
  file?: Express.Multer.File;
  fields: Record<string, string>;
};
```

#### Procedure pattern

```ts
uploadFile: protectedProcedure
  .input(z.object({ folderId: z.string() }))
  .mutation(async ({ input, ctx }) => {
    if (!ctx.file) {
      throw new TRPCError({ code: 'BAD_REQUEST', message: 'No file received' });
    }

    const url = await storageService.upload(ctx.file.buffer, {
      contentType: ctx.file.mimetype,
      folder: input.folderId,
    });

    return { url };
  }),
```

---

### Pattern 3: Presigned URL (Client-to-Storage Direct)

The server generates a short-lived signed URL from a storage provider (S3, GCS, Cloudflare R2, etc.). The client uploads directly to storage using that URL, bypassing your server entirely for the file bytes.

#### When to use

- Files of any size, especially large ones
- You want to offload bandwidth from your server
- Using a cloud storage provider that supports presigned URLs

#### When to avoid

- Environments where you cannot expose storage credentials or bucket configuration
- Use cases requiring server-side processing of file bytes before storage

#### Flow

```
Client                    tRPC Server                  S3 / R2 / GCS
  │                            │                              │
  ├─ mutation: requestUpload ──►                              │
  │   { filename, size, type } │                              │
  │                            ├─ validate input              │
  │                            ├─ generate presigned URL ─────►
  │                            ◄─ { uploadUrl, key } ─────────┤
  ◄─ { uploadUrl, key } ───────┤                              │
  │                            │                              │
  ├─ PUT file to uploadUrl ─────────────────────────────────► │
  │   (direct, no server)      │                              │
  │                            │                              │
  ├─ mutation: confirmUpload ──►                              │
  │   { key }                  ├─ verify key exists           │
  │                            ├─ persist record in DB        │
  ◄─ { fileUrl } ──────────────┤                              │
```

#### Step 1: Request upload URL

```ts
import { z } from 'zod';
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';

const s3 = new S3Client({ region: process.env.AWS_REGION });

const ALLOWED_TYPES = ['image/jpeg', 'image/png', 'image/webp', 'application/pdf'];
const MAX_SIZE = 50 * 1024 * 1024; // 50MB

export const filesRouter = router({
  requestUpload: protectedProcedure
    .input(z.object({
      filename: z.string().max(255),
      contentType: z.string().refine(
        (t) => ALLOWED_TYPES.includes(t),
        { message: 'Unsupported file type' }
      ),
      size: z.number().int().positive().max(MAX_SIZE),
    }))
    .mutation(async ({ input, ctx }) => {
      const key = `${ctx.user.id}/${Date.now()}-${input.filename}`;

      const command = new PutObjectCommand({
        Bucket: process.env.S3_BUCKET!,
        Key: key,
        ContentType: input.contentType,
        ContentLength: input.size,
      });

      const uploadUrl = await getSignedUrl(s3, command, { expiresIn: 300 });

      // Persist pending record — not yet confirmed
      await db.upload.create({
        data: {
          key,
          userId: ctx.user.id,
          status: 'pending',
          filename: input.filename,
        },
      });

      return { uploadUrl, key };
    }),
```

#### Step 2: Client uploads directly

```ts
async function uploadToStorage(file: File) {
  // 1. Get presigned URL
  const { uploadUrl, key } = await trpc.files.requestUpload.mutate({
    filename: file.name,
    contentType: file.type,
    size: file.size,
  });

  // 2. PUT directly to storage
  const res = await fetch(uploadUrl, {
    method: 'PUT',
    body: file,
    headers: {
      'Content-Type': file.type,
    },
  });

  if (!res.ok) {
    throw new Error(`Storage upload failed: ${res.status}`);
  }

  // 3. Confirm with server
  const result = await trpc.files.confirmUpload.mutate({ key });
  return result;
}
```

#### Step 3: Confirm upload

```ts
  confirmUpload: protectedProcedure
    .input(z.object({ key: z.string() }))
    .mutation(async ({ input, ctx }) => {
      // Verify the key belongs to this user
      const record = await db.upload.findFirst({
        where: {
          key: input.key,
          userId: ctx.user.id,
          status: 'pending',
        },
      });

      if (!record) {
        throw new TRPCError({
          code: 'NOT_FOUND',
          message: 'Upload record not found or already confirmed',
        });
      }

      // Optionally: verify object actually exists in S3 before confirming
      await db.upload.update({
        where: { id: record.id },
        data: { status: 'confirmed' },
      });

      const fileUrl = `https://${process.env.S3_BUCKET}.s3.amazonaws.com/${input.key}`;
      return { fileUrl };
    }),
});
```

**Key Points:**

- Always scope presigned URLs to the authenticated user's namespace (e.g., key prefix by user ID).
- Set `expiresIn` conservatively — 5 minutes is sufficient for most cases.
- The confirm step is important: without it, you cannot know if the client actually completed the upload. [Inference]
- [Inference] `ContentLength` in the presigned URL command may constrain the upload to the declared size, depending on your storage provider's enforcement. Verify with your provider.

---

### Pattern 4: Chunked Upload

Large files (hundreds of MB or more) are split into chunks on the client and uploaded sequentially or in parallel. The server reassembles them. This enables resumable uploads.

#### When to use

- Files over ~100MB
- Unreliable network conditions where resumability matters
- Progress tracking is required

#### When to avoid

- Small files — chunking adds unnecessary round trips and complexity

#### Concept

```
Client splits file into chunks:
[chunk_0][chunk_1][chunk_2]...[chunk_n]
         │
         ▼
mutation: initUpload({ filename, totalChunks })
  → { uploadId }

for each chunk:
  mutation: uploadChunk({ uploadId, index, data: base64 })

mutation: finalizeUpload({ uploadId })
  → { fileUrl }
```

#### Server-side implementation sketch

```ts
export const filesRouter = router({
  initUpload: protectedProcedure
    .input(z.object({
      filename: z.string(),
      totalChunks: z.number().int().positive().max(1000),
      mimeType: z.string(),
    }))
    .mutation(async ({ input, ctx }) => {
      const uploadId = crypto.randomUUID();

      await db.chunkedUpload.create({
        data: {
          id: uploadId,
          userId: ctx.user.id,
          filename: input.filename,
          totalChunks: input.totalChunks,
          receivedChunks: 0,
          status: 'in_progress',
        },
      });

      return { uploadId };
    }),

  uploadChunk: protectedProcedure
    .input(z.object({
      uploadId: z.string().uuid(),
      chunkIndex: z.number().int().min(0),
      data: z.string(), // base64-encoded chunk
    }))
    .mutation(async ({ input, ctx }) => {
      const upload = await db.chunkedUpload.findFirst({
        where: { id: input.uploadId, userId: ctx.user.id, status: 'in_progress' },
      });

      if (!upload) {
        throw new TRPCError({ code: 'NOT_FOUND', message: 'Upload session not found' });
      }

      const chunkBuffer = Buffer.from(input.data, 'base64');

      // Write chunk to temporary storage (disk or object store)
      await tempStorage.writeChunk(input.uploadId, input.chunkIndex, chunkBuffer);

      await db.chunkedUpload.update({
        where: { id: input.uploadId },
        data: { receivedChunks: { increment: 1 } },
      });

      return { received: input.chunkIndex };
    }),

  finalizeUpload: protectedProcedure
    .input(z.object({ uploadId: z.string().uuid() }))
    .mutation(async ({ input, ctx }) => {
      const upload = await db.chunkedUpload.findFirst({
        where: { id: input.uploadId, userId: ctx.user.id },
      });

      if (!upload || upload.receivedChunks !== upload.totalChunks) {
        throw new TRPCError({
          code: 'BAD_REQUEST',
          message: 'Upload incomplete — not all chunks received',
        });
      }

      const assembled = await tempStorage.assembleChunks(input.uploadId, upload.totalChunks);
      const url = await storageService.upload(assembled, { filename: upload.filename });

      await db.chunkedUpload.update({
        where: { id: input.uploadId },
        data: { status: 'complete' },
      });

      await tempStorage.cleanup(input.uploadId);

      return { url };
    }),
});
```

[Inference] For very large files on S3, AWS Multipart Upload is more appropriate than reassembling chunks in application code. The pattern above is illustrative for custom storage scenarios. Behavior and performance depend heavily on your storage and server infrastructure.

---

### Pattern 5: Hybrid — tRPC Mutation + Separate Upload Endpoint

tRPC handles metadata and coordination. A separate, non-tRPC HTTP endpoint handles the raw file bytes.

#### When to use

- You want tRPC for type-safe metadata but need streaming or raw body access for the file
- Your HTTP framework makes raw body access cleaner outside tRPC

#### Flow

```
POST /api/upload (raw HTTP, not tRPC)
  → server parses file, stores it, returns { key }

trpc.files.registerUpload.mutate({ key, metadata })
  → server validates key + persists record
```

#### Raw upload endpoint (Express)

```ts
app.post('/api/upload', authenticate, upload.single('file'), async (req, res) => {
  if (!req.file) {
    return res.status(400).json({ error: 'No file' });
  }

  const key = await storageService.upload(req.file.buffer, {
    contentType: req.file.mimetype,
    userId: req.user.id,
  });

  res.json({ key });
});
```

#### tRPC metadata registration

```ts
registerUpload: protectedProcedure
  .input(z.object({
    key: z.string(),
    label: z.string().optional(),
    folderId: z.string().optional(),
  }))
  .mutation(async ({ input, ctx }) => {
    // Verify key was actually uploaded by this user
    const exists = await storageService.exists(input.key, ctx.user.id);

    if (!exists) {
      throw new TRPCError({ code: 'NOT_FOUND', message: 'File key not found' });
    }

    const file = await db.file.create({
      data: {
        storageKey: input.key,
        label: input.label,
        folderId: input.folderId,
        userId: ctx.user.id,
      },
    });

    return { fileId: file.id };
  }),
```

---

### Security Considerations Across All Patterns

| Concern | Mitigation |
| --- | --- |
| MIME type spoofing | Validate from buffer magic bytes server-side |
| Oversized uploads | Enforce limits at middleware and Zod input layers |
| Path traversal in filenames | Sanitize or replace filenames server-side; never use raw client filename as storage key |
| Unauthorized access to others' files | Scope storage keys by user ID; verify ownership on confirm/register |
| Stale presigned URLs | Set short expiry; clean up pending records with a background job |
| Malicious file content | Scan with antivirus service before serving [Inference — implementation varies] |
| Incomplete chunked uploads | Implement TTL-based cleanup for abandoned sessions |

---

### Pattern Comparison

| Pattern | Max practical size | Server bandwidth | Type safety | Complexity | Resumable |
| --- | --- | --- | --- | --- | --- |
| Base64 JSON | ~1MB | Full + 33% | Full (Zod) | Low | No |
| Multipart middleware | ~50MB | Full | Partial | Medium | No |
| Presigned URL | Unlimited | Bypassed | Partial | Medium | No |
| Chunked upload | Unlimited | Full (per chunk) | Partial | High | Yes |
| Hybrid endpoint | Unlimited | Full | Partial | Medium | No |

---

**Conclusion:**
No single pattern is universally correct for tRPC file uploads. Base64 suits small, infrequent uploads where simplicity matters. Multipart middleware is appropriate for moderate file sizes with server control. Presigned URLs are [Inference] the most scalable choice for production cloud-hosted apps. Chunked uploads are necessary only when file sizes or network reliability demand it. The hybrid pattern offers a pragmatic escape hatch when tRPC's constraints conflict with streaming requirements.

**Next Steps:**

- Choose your pattern based on expected file sizes and infrastructure constraints before implementation
- Add upload progress tracking on the client for any pattern involving large files
- Implement cleanup jobs for abandoned pending or chunked uploads to prevent storage accumulation