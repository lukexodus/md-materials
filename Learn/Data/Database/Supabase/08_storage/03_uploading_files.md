## Uploading Files


File uploads support multiple methods including direct file objects, blobs, ArrayBuffers, and base64 encoded strings.

Standard file upload:

```javascript
const file = event.target.files[0];
const { data, error } = await supabase
  .storage
  .from('avatars')
  .upload(`public/${user.id}/avatar.png`, file);
```

Upload with custom options:

```javascript
const { data, error } = await supabase
  .storage
  .from('avatars')
  .upload('user-avatar.png', file, {
    cacheControl: '3600',
    upsert: false,
    contentType: 'image/png'
  });
```

Upload to a nested path:

```javascript
const filePath = `${user.id}/documents/report-2024.pdf`;
const { data, error } = await supabase
  .storage
  .from('user-documents')
  .upload(filePath, file);
```

Upsert (overwrite existing file):

```javascript
const { data, error } = await supabase
  .storage
  .from('avatars')
  .upload('profile.jpg', file, { upsert: true });
```

Upload from base64:

```javascript
const base64String = 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUg...';
const { data, error } = await supabase
  .storage
  .from('avatars')
  .upload('image.png', decode(base64String), {
    contentType: 'image/png'
  });
```

Upload response structure:

```javascript
{
  data: {
    path: 'user-123/avatar.png',
    id: 'uuid-string',
    fullPath: 'avatars/user-123/avatar.png'
  },
  error: null
}
```

Handling upload errors:

```javascript
const { data, error } = await supabase
  .storage
  .from('avatars')
  .upload(filePath, file);

if (error) {
  if (error.message.includes('Duplicate')) {
    // File already exists
  } else if (error.message.includes('size')) {
    // File too large
  } else {
    // Other error
  }
}
```

