## Integrating with Cloud Storage Providers

### Overview

Cloud storage integration in tRPC applications means using a managed object storage service — AWS S3, Google Cloud Storage, Cloudflare R2, or similar — to store, retrieve, and manage files. tRPC itself has no storage opinions; it coordinates the interaction through procedures while the storage provider handles persistence.

**Key Points:**

- tRPC procedures act as a coordination and authorization layer, not a storage layer.
- All major providers expose an SDK and a presigned URL mechanism. The patterns are structurally similar across providers.
- Credentials must never be exposed to the client. All signed operations originate server-side within tRPC procedures.

---

### Conceptual Role of tRPC in Storage Workflows

```
┌─────────────────────────────────────────────────────────────┐
│                        Client                               │
│   trpc.files.requestUpload()   trpc.files.getDownloadUrl()  │
└────────────────┬────────────────────────┬───────────────────┘
                 │                        │
                 ▼                        ▼
┌─────────────────────────────────────────────────────────────┐
│                     tRPC Server                             │
│  • Authenticate user          • Authorize access            │
│  • Validate input             • Generate signed URLs        │
│  • Persist metadata           • Enforce size/type rules     │
└────────────────┬────────────────────────┬───────────────────┘
                 │                        │
                 ▼                        ▼
┌─────────────────────────────────────────────────────────────┐
│                  Cloud Storage Provider                     │
│         S3 / GCS / R2 / Azure Blob / Backblaze B2           │
│  • Object persistence         • Access control              │
│  • CDN delivery               • Lifecycle policies          │
└─────────────────────────────────────────────────────────────┘
```

tRPC owns authentication, authorization, and metadata. The storage provider owns bytes.

---

### Provider Overview

| Provider | SDK | Presigned upload | Presigned download | S3-compatible |
| --- | --- | --- | --- | --- |
| AWS S3 | `@aws-sdk/client-s3` | Yes | Yes | Native |
| Google Cloud Storage | `@google-cloud/storage` | Yes | Yes | Partial |
| Cloudflare R2 | `@aws-sdk/client-s3` | Yes | Yes | Yes (S3-compatible) |
| Azure Blob Storage | `@azure/storage-blob` | Yes (SAS) | Yes (SAS) | No |
| Backblaze B2 | `@aws-sdk/client-s3` | Yes | Yes | Yes (S3-compatible) |

[Inference] S3-compatible providers (R2, B2) can use the AWS SDK with a custom endpoint, which reduces integration effort if you are already familiar with S3. Verify compatibility for specific SDK features against the provider's documentation.

---

### Shared Abstractions

Before provider-specific implementations, define a shared storage interface. This decouples your tRPC procedures from any single provider.

```ts
// lib/storage/types.ts
export interface StorageProvider {
  getUploadUrl(params: UploadUrlParams): Promise<SignedUploadResult>;
  getDownloadUrl(params: DownloadUrlParams): Promise<string>;
  deleteObject(key: string): Promise<void>;
  objectExists(key: string): Promise<boolean>;
}

export interface UploadUrlParams {
  key: string;
  contentType: string;
  contentLength: number;
  expiresIn?: number; // seconds
}

export interface SignedUploadResult {
  uploadUrl: string;
  key: string;
  expiresAt: Date;
}

export interface DownloadUrlParams {
  key: string;
  expiresIn?: number;
  filename?: string; // for Content-Disposition
}
```

Each provider implements this interface. tRPC procedures depend on `StorageProvider`, not a concrete SDK.

---

### AWS S3

#### Installation

```bash
npm install @aws-sdk/client-s3 @aws-sdk/s3-request-presigner
```

#### Provider implementation

```ts
// lib/storage/s3.ts
import {
  S3Client,
  PutObjectCommand,
  GetObjectCommand,
  DeleteObjectCommand,
  HeadObjectCommand,
} from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';
import type { StorageProvider, UploadUrlParams, SignedUploadResult, DownloadUrlParams } from './types';

const s3 = new S3Client({
  region: process.env.AWS_REGION!,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID!,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY!,
  },
});

const BUCKET = process.env.S3_BUCKET!;

export const s3Storage: StorageProvider = {
  async getUploadUrl(params: UploadUrlParams): Promise<SignedUploadResult> {
    const command = new PutObjectCommand({
      Bucket: BUCKET,
      Key: params.key,
      ContentType: params.contentType,
      ContentLength: params.contentLength,
    });

    const expiresIn = params.expiresIn ?? 300;
    const uploadUrl = await getSignedUrl(s3, command, { expiresIn });

    return {
      uploadUrl,
      key: params.key,
      expiresAt: new Date(Date.now() + expiresIn * 1000),
    };
  },

  async getDownloadUrl(params: DownloadUrlParams): Promise<string> {
    const command = new GetObjectCommand({
      Bucket: BUCKET,
      Key: params.key,
      ResponseContentDisposition: params.filename
        ? `attachment; filename="${params.filename}"`
        : undefined,
    });

    return getSignedUrl(s3, command, { expiresIn: params.expiresIn ?? 3600 });
  },

  async deleteObject(key: string): Promise<void> {
    await s3.send(new DeleteObjectCommand({ Bucket: BUCKET, Key: key }));
  },

  async objectExists(key: string): Promise<boolean> {
    try {
      await s3.send(new HeadObjectCommand({ Bucket: BUCKET, Key: key }));
      return true;
    } catch {
      return false;
    }
  },
};
```

#### IAM policy (minimum required permissions)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:HeadObject"
      ],
      "Resource": "arn:aws:s3:::your-bucket-name/*"
    }
  ]
}
```

> ⚠️ Do not use root credentials or overly broad IAM policies. Apply least-privilege access. [Inference] Using `s3:*` on `*` is a significant security risk in production.

---

### Cloudflare R2

R2 is S3-compatible and uses the AWS SDK with a custom endpoint. It has no egress fees for data served via Cloudflare's network. [Unverified: pricing details are subject to change — verify against Cloudflare's current documentation.]

#### Installation

```bash
npm install @aws-sdk/client-s3 @aws-sdk/s3-request-presigner
 Same SDK as S3
```

#### Provider implementation

```ts
// lib/storage/r2.ts
import { S3Client } from '@aws-sdk/client-s3';
import { s3Storage } from './s3'; // Reuse S3 implementation

const r2Client = new S3Client({
  region: 'auto',
  endpoint: `https://${process.env.CF_ACCOUNT_ID}.r2.cloudflarestorage.com`,
  credentials: {
    accessKeyId: process.env.R2_ACCESS_KEY_ID!,
    secretAccessKey: process.env.R2_SECRET_ACCESS_KEY!,
  },
});

// R2 reuses the same command structure as S3
// Wrap or re-instantiate with r2Client instead of s3Client
```

[Inference] Because R2 is S3-compatible, you can reuse the S3 provider implementation by swapping the client instance. Some advanced S3 features (e.g., object tagging, certain ACL behaviors) may not be supported in R2 — verify against Cloudflare's R2 compatibility documentation.

---

### Google Cloud Storage

GCS has its own SDK and presigned URL mechanism (using service account credentials), but the conceptual pattern is the same.

#### Installation

```bash
npm install @google-cloud/storage
```

#### Provider implementation

```ts
// lib/storage/gcs.ts
import { Storage } from '@google-cloud/storage';
import type { StorageProvider, UploadUrlParams, SignedUploadResult, DownloadUrlParams } from './types';

const gcs = new Storage({
  keyFilename: process.env.GCS_KEY_FILE, // path to service account JSON
  projectId: process.env.GCS_PROJECT_ID,
});

const bucket = gcs.bucket(process.env.GCS_BUCKET!);

export const gcsStorage: StorageProvider = {
  async getUploadUrl(params: UploadUrlParams): Promise<SignedUploadResult> {
    const expiresIn = params.expiresIn ?? 300;

    const [uploadUrl] = await bucket.file(params.key).generateSignedPostPolicyV4({
      expires: Date.now() + expiresIn * 1000,
      conditions: [
        ['content-length-range', 0, params.contentLength],
        ['eq', '$Content-Type', params.contentType],
      ],
    });

    return {
      uploadUrl: uploadUrl.url,
      key: params.key,
      expiresAt: new Date(Date.now() + expiresIn * 1000),
    };
  },

  async getDownloadUrl(params: DownloadUrlParams): Promise<string> {
    const expiresIn = params.expiresIn ?? 3600;

    const [url] = await bucket.file(params.key).getSignedUrl({
      action: 'read',
      expires: Date.now() + expiresIn * 1000,
      responseDisposition: params.filename
        ? `attachment; filename="${params.filename}"`
        : undefined,
    });

    return url;
  },

  async deleteObject(key: string): Promise<void> {
    await bucket.file(key).delete();
  },

  async objectExists(key: string): Promise<boolean> {
    const [exists] = await bucket.file(key).exists();
    return exists;
  },
};
```

[Unverified: `generateSignedPostPolicyV4` behavior may differ from `getSignedUrl` for PUT operations — consult the GCS documentation for your use case and SDK version.]

---

### Azure Blob Storage

Azure uses Shared Access Signatures (SAS) rather than presigned URLs, but serves the same purpose.

#### Installation

```bash
npm install @azure/storage-blob
```

#### Provider implementation

```ts
// lib/storage/azure.ts
import {
  BlobServiceClient,
  generateBlobSASQueryParameters,
  BlobSASPermissions,
  StorageSharedKeyCredential,
} from '@azure/storage-blob';
import type { StorageProvider, UploadUrlParams, SignedUploadResult, DownloadUrlParams } from './types';

const account = process.env.AZURE_STORAGE_ACCOUNT!;
const accountKey = process.env.AZURE_STORAGE_KEY!;
const containerName = process.env.AZURE_CONTAINER!;

const credential = new StorageSharedKeyCredential(account, accountKey);
const blobServiceClient = new BlobServiceClient(
  `https://${account}.blob.core.windows.net`,
  credential
);

export const azureStorage: StorageProvider = {
  async getUploadUrl(params: UploadUrlParams): Promise<SignedUploadResult> {
    const expiresIn = params.expiresIn ?? 300;
    const expiresAt = new Date(Date.now() + expiresIn * 1000);

    const sasToken = generateBlobSASQueryParameters(
      {
        containerName,
        blobName: params.key,
        permissions: BlobSASPermissions.parse('w'),
        startsOn: new Date(),
        expiresOn: expiresAt,
        contentType: params.contentType,
      },
      credential
    ).toString();

    const uploadUrl = `https://${account}.blob.core.windows.net/${containerName}/${params.key}?${sasToken}`;

    return { uploadUrl, key: params.key, expiresAt };
  },

  async getDownloadUrl(params: DownloadUrlParams): Promise<string> {
    const expiresIn = params.expiresIn ?? 3600;
    const expiresAt = new Date(Date.now() + expiresIn * 1000);

    const sasToken = generateBlobSASQueryParameters(
      {
        containerName,
        blobName: params.key,
        permissions: BlobSASPermissions.parse('r'),
        startsOn: new Date(),
        expiresOn: expiresAt,
      },
      credential
    ).toString();

    return `https://${account}.blob.core.windows.net/${containerName}/${params.key}?${sasToken}`;
  },

  async deleteObject(key: string): Promise<void> {
    await blobServiceClient
      .getContainerClient(containerName)
      .getBlobClient(params.key)
      .delete();
  },

  async objectExists(key: string): Promise<boolean> {
    return blobServiceClient
      .getContainerClient(containerName)
      .getBlobClient(key)
      .exists();
  },
};
```

---

### tRPC Router: Provider-Agnostic

With the shared interface in place, the router depends only on `StorageProvider`:

```ts
// routers/files.ts
import { z } from 'zod';
import { router, protectedProcedure } from '../trpc';
import { TRPCError } from '@trpc/server';
import { storage } from '../lib/storage'; // resolves to active provider

const ALLOWED_TYPES = ['image/jpeg', 'image/png', 'image/webp', 'application/pdf'];
const MAX_SIZE_BYTES = 100 * 1024 * 1024; // 100MB

export const filesRouter = router({
  requestUpload: protectedProcedure
    .input(z.object({
      filename: z.string().max(255),
      contentType: z.string().refine(
        (t) => ALLOWED_TYPES.includes(t),
        { message: 'File type not permitted' }
      ),
      size: z.number().int().positive().max(MAX_SIZE_BYTES, {
        message: 'File exceeds maximum allowed size',
      }),
    }))
    .mutation(async ({ input, ctx }) => {
      // Sanitize filename — never use raw client filename as storage key
      const safeFilename = input.filename.replace(/[^a-zA-Z0-9._-]/g, '_');
      const key = `users/${ctx.user.id}/${Date.now()}-${safeFilename}`;

      const result = await storage.getUploadUrl({
        key,
        contentType: input.contentType,
        contentLength: input.size,
        expiresIn: 300,
      });

      await db.pendingUpload.create({
        data: {
          key,
          userId: ctx.user.id,
          expiresAt: result.expiresAt,
        },
      });

      return result;
    }),

  confirmUpload: protectedProcedure
    .input(z.object({
      key: z.string().max(1024),
      label: z.string().max(255).optional(),
    }))
    .mutation(async ({ input, ctx }) => {
      const pending = await db.pendingUpload.findFirst({
        where: {
          key: input.key,
          userId: ctx.user.id,
          expiresAt: { gt: new Date() },
        },
      });

      if (!pending) {
        throw new TRPCError({
          code: 'NOT_FOUND',
          message: 'No valid pending upload found for this key',
        });
      }

      const exists = await storage.objectExists(input.key);
      if (!exists) {
        throw new TRPCError({
          code: 'BAD_REQUEST',
          message: 'File was not found in storage — upload may have failed',
        });
      }

      const file = await db.file.create({
        data: {
          storageKey: input.key,
          label: input.label ?? pending.key.split('/').pop() ?? 'Untitled',
          userId: ctx.user.id,
        },
      });

      await db.pendingUpload.delete({ where: { id: pending.id } });

      return { fileId: file.id };
    }),

  getDownloadUrl: protectedProcedure
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

      const url = await storage.getDownloadUrl({
        key: file.storageKey,
        expiresIn: 3600,
        filename: file.label,
      });

      return { url, expiresIn: 3600 };
    }),

  deleteFile: protectedProcedure
    .input(z.object({ fileId: z.string() }))
    .mutation(async ({ input, ctx }) => {
      const file = await db.file.findFirst({
        where: { id: input.fileId, userId: ctx.user.id },
      });

      if (!file) {
        throw new TRPCError({ code: 'NOT_FOUND', message: 'File not found' });
      }

      await storage.deleteObject(file.storageKey);
      await db.file.delete({ where: { id: file.id } });

      return { deleted: true };
    }),
});
```

---

### Provider Selection via Environment

```ts
// lib/storage/index.ts
import type { StorageProvider } from './types';

function resolveStorage(): StorageProvider {
  const provider = process.env.STORAGE_PROVIDER;

  switch (provider) {
    case 's3':
      return require('./s3').s3Storage;
    case 'r2':
      return require('./r2').r2Storage;
    case 'gcs':
      return require('./gcs').gcsStorage;
    case 'azure':
      return require('./azure').azureStorage;
    default:
      throw new Error(`Unknown STORAGE_PROVIDER: "${provider}"`);
  }
}

export const storage: StorageProvider = resolveStorage();
```

Setting `STORAGE_PROVIDER=r2` in your environment switches providers without touching procedure code.

---

### Key Naming Strategy

Storage keys are the primary identifier for objects. A consistent naming scheme prevents collisions and enables lifecycle policies.

```
users/{userId}/{timestamp}-{safeFilename}
  └── per-user namespace
                └── timestamp prevents collisions for same filename
                               └── sanitized client filename

Examples:
  users/usr_abc123/1717000000000-profile_photo.jpg
  users/usr_abc123/1717000001000-report_final.pdf
  temp/uploads/1717000002000-pending.png   ← pending uploads, TTL-deleted
```

**Key Points:**

- Never use raw client-supplied filenames as storage keys. Sanitize or replace them entirely.
- Prefix by user ID to scope access and enable per-user lifecycle rules.
- Use timestamps rather than sequential IDs to avoid enumeration. [Inference]

---

### Bucket Security Configuration

Regardless of provider, apply these baseline settings:

| Setting | Recommended value |
| --- | --- |
| Public access | Blocked — all access via signed URLs |
| Default encryption | Enabled (SSE-S3 or SSE-KMS on AWS) |
| Versioning | Optional — useful for audit trails |
| Lifecycle rules | Auto-delete `temp/` prefix after 24h |
| CORS | Restrict to your domain only |
| Logging | Enabled for audit and anomaly detection |

#### Example CORS configuration (S3)

```json
[
  {
    "AllowedHeaders": ["Content-Type", "Content-Length"],
    "AllowedMethods": ["PUT"],
    "AllowedOrigins": ["https://your-app.com"],
    "ExposeHeaders": ["ETag"],
    "MaxAgeSeconds": 3000
  }
]
```

[Inference] CORS must be configured on the bucket itself, not only on your server. Without it, browser PUT requests to presigned URLs will be blocked by the browser's CORS policy. Exact configuration syntax varies by provider.

---

### Cleanup: Handling Abandoned Uploads

Pending uploads that are never confirmed accumulate stale records and objects. A background job handles cleanup:

```ts
// jobs/cleanupPendingUploads.ts
export async function cleanupExpiredUploads() {
  const expired = await db.pendingUpload.findMany({
    where: { expiresAt: { lt: new Date() } },
  });

  for (const record of expired) {
    try {
      await storage.deleteObject(record.key);
    } catch {
      // Object may already not exist — log and continue
    }
    await db.pendingUpload.delete({ where: { id: record.id } });
  }

  return { cleaned: expired.length };
}
```

Run this on a schedule (cron, queue worker, or a tRPC admin procedure called by your scheduler). [Inference] Alternatively, configure a lifecycle rule on the bucket to auto-expire objects under a `temp/` prefix — this removes the need for application-level cleanup of the objects themselves, though database records still require cleanup.

---

### Client-Side Upload with Progress

```ts
async function uploadWithProgress(
  file: File,
  onProgress: (percent: number) => void
) {
  const { uploadUrl, key } = await trpc.files.requestUpload.mutate({
    filename: file.name,
    contentType: file.type,
    size: file.size,
  });

  await new Promise<void>((resolve, reject) => {
    const xhr = new XMLHttpRequest();

    xhr.upload.addEventListener('progress', (e) => {
      if (e.lengthComputable) {
        onProgress(Math.round((e.loaded / e.total) * 100));
      }
    });

    xhr.addEventListener('load', () => {
      if (xhr.status >= 200 && xhr.status < 300) resolve();
      else reject(new Error(`Upload failed: ${xhr.status}`));
    });

    xhr.addEventListener('error', () => reject(new Error('Network error')));

    xhr.open('PUT', uploadUrl);
    xhr.setRequestHeader('Content-Type', file.type);
    xhr.send(file);
  });

  return trpc.files.confirmUpload.mutate({ key });
}
```

[Inference] `fetch` does not currently support upload progress events in most browsers. `XMLHttpRequest` is the reliable cross-browser option for progress tracking. This may change as the Streams API matures — verify against your target environment.

---

**Conclusion:**
Cloud storage integration in tRPC follows a consistent pattern regardless of provider: tRPC procedures handle authentication, authorization, and metadata while the storage provider handles persistence. Defining a shared `StorageProvider` interface decouples your procedures from any specific SDK, making provider migration or multi-provider setups tractable. Key security responsibilities — credential isolation, key sanitization, access scoping, and cleanup — belong to the tRPC layer, not the storage provider.

**Next Steps:**

- Implement a lifecycle rule on your bucket to auto-expire objects in a `temp/` prefix
- Add virus scanning as a post-upload step before confirming files as available
- Consider a CDN layer (CloudFront, Cloudflare) in front of your storage for frequently accessed files