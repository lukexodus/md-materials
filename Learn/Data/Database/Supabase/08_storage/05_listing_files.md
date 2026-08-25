## Listing Files


File listing operations retrieve metadata about stored objects within buckets and folders.

List all files in a bucket:

```javascript
const { data, error } = await supabase
  .storage
  .from('avatars')
  .list();
```

List files in a specific folder:

```javascript
const { data, error } = await supabase
  .storage
  .from('documents')
  .list('user-123/reports');
```

List with options:

```javascript
const { data, error } = await supabase
  .storage
  .from('documents')
  .list('user-123', {
    limit: 100,
    offset: 0,
    sortBy: { column: 'name', order: 'asc' }
  });
```

Search files by prefix:

```javascript
const { data, error } = await supabase
  .storage
  .from('documents')
  .list('user-123', {
    search: 'invoice'
  });
```

Response structure:

```javascript
[
  {
    name: 'avatar.png',
    id: 'uuid',
    updated_at: '2024-01-15T10:30:00.000Z',
    created_at: '2024-01-15T10:30:00.000Z',
    last_accessed_at: '2024-01-15T10:30:00.000Z',
    metadata: {
      eTag: '"abc123"',
      size: 524288,
      mimetype: 'image/png',
      cacheControl: 'max-age=3600'
    }
  }
]
```

Recursive listing through folders:

```javascript
async function listAllFiles(bucket, folder = '') {
  const files = [];
  const { data, error } = await supabase
    .storage
    .from(bucket)
    .list(folder);
  
  for (const item of data) {
    const path = folder ? `${folder}/${item.name}` : item.name;
    if (item.id === null) {
      // It's a folder
      const subFiles = await listAllFiles(bucket, path);
      files.push(...subFiles);
    } else {
      // It's a file
      files.push(path);
    }
  }
  
  return files;
}
```

