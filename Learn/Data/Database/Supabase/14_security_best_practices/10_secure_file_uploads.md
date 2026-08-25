## Secure File Uploads


File uploads introduce security risks including malware distribution, unauthorized access, storage abuse, and code execution vulnerabilities.

**Supabase Storage security:**

Supabase Storage provides built-in security features:

- **Authentication required**: Files are protected by RLS policies
- **Size limits**: Configurable maximum file sizes
- **MIME type validation**: Restrict allowed file types
- **Public vs private buckets**: Control access patterns

**Creating secure buckets:**

```javascript
// Create a private bucket
const { data, error } = await supabase
  .storage
  .createBucket('user-documents', {
    public: false,  // Requires authentication
    fileSizeLimit: 52428800,  // 50MB limit
    allowedMimeTypes: ['application/pdf', 'image/jpeg', 'image/png']
  });
```

**Storage RLS policies:**

Apply Row Level Security to storage objects:

```sql
-- Policy: Users can only upload to their own folder
CREATE POLICY "Users can upload to own folder"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'user-documents'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy: Users can only read their own files
CREATE POLICY "Users can view own files"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'user-documents'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy: Users can delete their own files
CREATE POLICY "Users can delete own files"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'user-documents'
  AND (storage.foldername(name))[1] = auth.uid()::text
);

-- Policy: Public read for avatar bucket
CREATE POLICY "Anyone can view avatars"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'avatars');
```

**Client-side upload validation:**

```javascript
async function secureUpload(file, userId) {
  // Validate file size (5MB limit)
  const maxSize = 5 * 1024 * 1024;
  if (file.size > maxSize) {
    throw new Error('File too large. Maximum size is 5MB.');
  }
  
  // Validate file type
  const allowedTypes = ['image/jpeg', 'image/png', 'image/gif', 'application/pdf'];
  if (!allowedTypes.includes(file.type)) {
    throw new Error('Invalid file type. Only images and PDFs allowed.');
  }
  
  // Validate file extension matches MIME type
  const extension = file.name.split('.').pop().toLowerCase();
  const mimeToExt = {
    'image/jpeg': ['jpg', 'jpeg'],
    'image/png': ['png'],
    'image/gif': ['gif'],
    'application/pdf': ['pdf']
  };
  
  const validExtensions = mimeToExt[file.type] || [];
  if (!validExtensions.includes(extension)) {
    throw new Error('File extension does not match file type.');
  }
  
  // Generate safe filename
  const timestamp = Date.now();
  const randomString = Math.random().toString(36).substring(7);
  const safeFilename = `${userId}/${timestamp}-${randomString}.${extension}`;
  
  // Upload to Supabase Storage
  const { data, error } = await supabase.storage
    .from('user-documents')
    .upload(safeFilename, file, {
      cacheControl: '3600',
      upsert: false
    });
  
  if (error) throw error;
  
  return data;
}
```

**Server-side validation with Edge Functions:**

```javascript
// Edge Function for server-side validation
import { createClient } from '@supabase/supabase-js';

Deno.serve(async (req) => {
  const formData = await req.formData();
  const file = formData.get('file');
  
  if (!file) {
    return new Response('No file provided', { status: 400 });
  }
  
  // Read file header to verify actual file type (magic bytes)
  const buffer = await file.arrayBuffer();
  const bytes = new Uint8Array(buffer);
  
  // Check file signature (magic bytes)
  const signatures = {
    'image/jpeg': [[0xFF, 0xD8, 0xFF]],
    'image/png': [[0x89, 0x50, 0x4E, 0x47]],
    'application/pdf': [[0x25, 0x50, 0x44, 0x46]]
  };
  
  let validSignature = false;
  for (const [mimeType, sigs] of Object.entries(signatures)) {
    for (const sig of sigs) {
      if (sig.every((byte, i) => bytes[i] === byte)) {
        validSignature = true;
        break;
      }
    }
  }
  
  if (!validSignature) {
    return new Response('Invalid file type', { status: 400 });
  }
  
  // Proceed with upload
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL'),
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')
  );
  
  const filename = `verified/${crypto.randomUUID()}`;
  const { data, error } = await supabase.storage
    .from('secure-uploads')
    .upload(filename, buffer, {
      contentType: file.type
    });
  
  if (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    });
  }
  
  return new Response(JSON.stringify({ path: data.path }), {
    headers: { 'Content-Type': 'application/json' }
  });
});
```

**Malware scanning:**

[Inference: Supabase doesn't include built-in malware scanning; this requires external integration]

```javascript
// Integration with malware scanning service
async function scanAndUpload(file, userId) {
  // Upload to temporary location
  const tempPath = `temp/${crypto.randomUUID()}`;
  await supabase.storage
    .from('temp-uploads')
    .upload(tempPath, file);
  
  // Get download URL
  const { data: { publicUrl } } = supabase.storage
    .from('temp-uploads')
    .getPublicUrl(tempPath);
  
  // Scan with external service (e.g., VirusTotal, ClamAV)
  const scanResult = await scanFile(publicUrl);
  
  if (scanResult.malicious) {
    // Delete infected file
    await supabase.storage
      .from('temp-uploads')
      .remove([tempPath]);
    
    throw new Error('File failed security scan');
  }
  
  // Move to permanent location
  const finalPath = `${userId}/${Date.now()}-${file.name}`;
  await supabase.storage
    .from('user-documents')
    .move(`temp-uploads/${tempPath}`, `user-documents/${finalPath}`);
  
  return finalPath;
}
```

**Image processing and sanitization:**

```javascript
// Process images to strip metadata and resize
import sharp from 'sharp';

async function processAndUploadImage(file, userId) {
  const buffer = await file.arrayBuffer();
  
  // Process image: resize, strip metadata, convert format
  const processed = await sharp(buffer)
    .resize(1920, 1080, { fit: 'inside', withoutEnlargement: true })
    .jpeg({ quality: 85 })  // Convert to JPEG
    .withMetadata(false)    // Strip EXIF data
    .toBuffer();
  
  const filename = `${userId}/${Date.now()}.jpg`;
  
  const { data, error } = await supabase.storage
    .from('images')
    .upload(filename, processed, {
      contentType: 'image/jpeg',
      cacheControl: '3600'
    });
  
  return data;
}
```

**Preventing path traversal:**

```javascript
// Sanitize filenames to prevent path traversal
function sanitizeFilename(filename) {
  // Remove path separators and special characters
  return filename
    .replace(/[^a-zA-Z0-9.-]/g, '_')  // Replace special chars
    .replace(/\.+/g, '.')             // Prevent multiple dots
    .substring(0, 255);               // Limit length
}

// Use with user-provided filenames
const userFilename = sanitizeFilename(file.name);
const securePath = `${userId}/${Date.now()}-${userFilename}`;
```

**Quota management:**

```sql
-- Track user storage usage
CREATE TABLE storage_quotas (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id),
  bytes_used BIGINT NOT NULL DEFAULT 0,
  bytes_limit BIGINT NOT NULL DEFAULT 1073741824,  -- 1GB default
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Function to check and update quota
CREATE FUNCTION check_storage_quota(
  p_user_id UUID,
  p_file_size BIGINT
)
RETURNS BOOLEAN AS $$
DECLARE
  v_quota RECORD;
BEGIN
  SELECT * INTO v_quota
  FROM storage_quotas
  WHERE user_id = p_user_id;
  
  IF NOT FOUND THEN
    -- Create default quota
    INSERT INTO storage_quotas (user_id, bytes_used)
    VALUES (p_user_id, 0);
    v_quota.bytes_used := 0;
    v_quota.bytes_limit := 1073741824;
  END IF;
  
  -- Check if upload would exceed quota
  IF v_quota.bytes_used + p_file_size > v_quota.bytes_limit THEN
    RETURN FALSE;
  END IF;
  
  -- Update usage
  UPDATE storage_quotas
  SET bytes_used = bytes_used + p_file_size,
      updated_at = NOW()
  WHERE user_id = p_user_id;
  
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql;
```

**Secure file serving:**

```javascript
// Generate temporary signed URLs
async function getSecureFileUrl(filePath, expiresIn = 3600) {
  const { data, error } = await supabase.storage
    .from('user-documents')
    .createSignedUrl(filePath, expiresIn);
  
  if (error) throw error;
  
  return data.signedUrl;  // URL expires after specified time
}

// Verify user has access before generating URL
async function getFileForUser(filePath, userId) {
  // Check ownership
  const [folderUserId] = filePath.split('/');
  
  if (folderUserId !== userId) {
    throw new Error('Unauthorized access');
  }
  
  return await getSecureFileUrl(filePath);
}
```

**Content Disposition headers:**

Prevent XSS through file downloads:

```javascript
// Set Content-Disposition to force download
const { data, error } = await supabase.storage
  .from('user-documents')
  .download(filePath, {
    download: true  // Forces download instead of inline display
  });
```

**Best practices:**

- Always validate file types on server-side (client validation can be bypassed)
- Use magic byte detection, not just file extensions or MIME types
- Implement file size limits appropriate to your use case
- Store files with generated names, not user-provided names
- Scan uploaded files for malware when handling user content
- Strip metadata from images (can contain sensitive information)
- Use signed URLs with expiration for private files
- Implement storage quotas per user or organization
- Separate upload location from serving location
- Use Content-Disposition headers to control how files are handled
- Log all upload and access activities
- Regularly audit and clean up unused files

---

**Key related topics:**

- **Database Backups & Recovery** - protecting data through automated backups
- **Supabase Auth Configuration** - securing authentication flows and user management
- **Network Security** - SSL/TLS configuration and secure connections
- **Compliance Frameworks** - implementing GDPR, HIPAA, SOC 2 requirements
- **Incident Response** - procedures for handling security breaches

---

