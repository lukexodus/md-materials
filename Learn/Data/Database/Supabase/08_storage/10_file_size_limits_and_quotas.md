## File Size Limits and Quotas


Storage systems impose limits on file sizes and total storage capacity to manage resources and costs.

**Default file size limits:**

Free tier projects: 50MB per file Pro tier projects: 50MB per file (configurable) Enterprise: Custom limits

Setting bucket-specific size limits:

```javascript
const { data, error } = await supabase
  .storage
  .createBucket('documents', {
    public: false,
    fileSizeLimit: 10485760 // 10MB in bytes
  });
```

Updating bucket size limits:

```javascript
const { data, error } = await supabase
  .storage
  .updateBucket('documents', {
    fileSizeLimit: 52428800 // 50MB
  });
```

Enforcing size limits via RLS policy:

```sql
CREATE POLICY "Enforce file size limit"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars'
  AND (metadata->>'size')::bigint <= 5242880 -- 5MB
);
```

**Storage quotas:**

Free tier: 1GB total storage Pro tier: 100GB included, then pay per GB Enterprise: Custom allocations

**[Unverified]** Specific quota limits and pricing may change based on Supabase's current pricing structure and plan offerings.

Checking storage usage (via SQL):

```sql
SELECT 
  bucket_id,
  COUNT(*) as file_count,
  SUM((metadata->>'size')::bigint) as total_bytes
FROM storage.objects
GROUP BY bucket_id;
```

Client-side file size validation:

```javascript
const maxSize = 5 * 1024 * 1024; // 5MB

function validateFileSize(file) {
  if (file.size > maxSize) {
    throw new Error('File exceeds maximum size of 5MB');
  }
}

// Before upload
const file = event.target.files[0];
validateFileSize(file);

const { data, error } = await supabase
  .storage
  .from('avatars')
  .upload('avatar.png', file);
```

Handling quota exceeded errors:

```javascript
const { data, error } = await supabase
  .storage
  .from('documents')
  .upload('large-file.zip', file);

if (error) {
  if (error.message.includes('quota')) {
    // Storage quota exceeded
  } else if (error.message.includes('size')) {
    // File size limit exceeded
  }
}
```

