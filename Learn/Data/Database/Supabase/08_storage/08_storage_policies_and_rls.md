## Storage Policies and RLS


Storage buckets use PostgreSQL Row Level Security policies applied to the `storage.objects` table, controlling file access based on user authentication and custom conditions.

The `storage.objects` table structure includes:

- `bucket_id`: Bucket identifier
- `name`: File path within bucket
- `owner`: User ID of file uploader
- `created_at`: Upload timestamp
- `updated_at`: Last modification timestamp
- `metadata`: JSON object with file metadata

Basic policy allowing users to upload files:

```sql
CREATE POLICY "Users can upload own files"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars' 
  AND auth.uid()::text = (storage.foldername(name))[1]
);
```

Policy allowing users to read their own files:

```sql
CREATE POLICY "Users can read own files"
ON storage.objects
FOR SELECT
TO authenticated
USING (
  bucket_id = 'avatars'
  AND auth.uid()::text = (storage.foldername(name))[1]
);
```

Policy allowing users to update their own files:

```sql
CREATE POLICY "Users can update own files"
ON storage.objects
FOR UPDATE
TO authenticated
USING (
  bucket_id = 'avatars'
  AND auth.uid()::text = (storage.foldername(name))[1]
);
```

Policy allowing users to delete their own files:

```sql
CREATE POLICY "Users can delete own files"
ON storage.objects
FOR DELETE
TO authenticated
USING (
  bucket_id = 'avatars'
  AND auth.uid()::text = (storage.foldername(name))[1]
);
```

Helper function `storage.foldername()` extracts folder segments from file paths:

```sql
-- For path 'user-123/subfolder/file.png'
-- storage.foldername(name) returns ['user-123', 'subfolder']
```

Public read policy (for public assets):

```sql
CREATE POLICY "Public assets are publicly accessible"
ON storage.objects
FOR SELECT
TO public
USING (bucket_id = 'public-assets');
```

Policy based on file ownership:

```sql
CREATE POLICY "Owner can manage files"
ON storage.objects
FOR ALL
TO authenticated
USING (auth.uid() = owner);
```

Team-based access policy:

```sql
CREATE POLICY "Team members can access team files"
ON storage.objects
FOR SELECT
TO authenticated
USING (
  bucket_id = 'team-documents'
  AND (storage.foldername(name))[1] IN (
    SELECT team_id::text FROM team_members
    WHERE user_id = auth.uid()
  )
);
```

File type restriction policy:

```sql
CREATE POLICY "Only images allowed"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'avatars'
  AND (metadata->>'mimetype' LIKE 'image/%')
);
```

Size restriction policy:

```sql
CREATE POLICY "Limit file size"
ON storage.objects
FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'documents'
  AND (metadata->>'size')::int < 10485760 -- 10MB
);
```

**[Inference]** Storage policies execute for every file operation, potentially impacting performance for buckets with complex access rules or large numbers of files.

