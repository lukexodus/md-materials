## Public vs Private Buckets


Public buckets allow unauthenticated access to files without authentication tokens. Private buckets require authentication and policy evaluation for every access.

**Public bucket characteristics:**

- Files accessible via direct URLs without authentication
- Suitable for assets like logos, public images, or downloadable resources
- Still respect RLS policies if configured
- URLs remain stable and cacheable

Creating a public bucket:

```javascript
const { data, error } = await supabase
  .storage
  .createBucket('public-assets', { public: true });
```

Public file URL structure:

```
https://[project-ref].supabase.co/storage/v1/object/public/[bucket-name]/[file-path]
```

**Private bucket characteristics:**

- Require authentication headers or signed URLs for access
- Default security posture for sensitive files
- Policy evaluation on every request
- URLs require authorization tokens

Creating a private bucket:

```javascript
const { data, error } = await supabase
  .storage
  .createBucket('user-documents', { public: false });
```

Converting bucket visibility:

```javascript
const { data, error } = await supabase
  .storage
  .updateBucket('avatars', { public: true });
```

**[Inference]** Changing a bucket from private to public exposes all existing files to unauthenticated access, which could create security risks if files contain sensitive information.

