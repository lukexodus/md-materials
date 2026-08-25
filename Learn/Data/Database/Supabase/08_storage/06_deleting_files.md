## Deleting Files


File deletion removes objects permanently from storage buckets.

Delete a single file:

```javascript
const { data, error } = await supabase
  .storage
  .from('avatars')
  .remove(['user-123/avatar.png']);
```

Delete multiple files:

```javascript
const filePaths = [
  'user-123/old-avatar.png',
  'user-123/temp-file.txt',
  'user-123/document.pdf'
];

const { data, error } = await supabase
  .storage
  .from('documents')
  .remove(filePaths);
```

Delete all files in a folder:

```javascript
// First list all files
const { data: files, error: listError } = await supabase
  .storage
  .from('documents')
  .list('user-123/temp');

// Extract file paths
const filePaths = files.map(file => `user-123/temp/${file.name}`);

// Delete all files
const { data, error } = await supabase
  .storage
  .from('documents')
  .remove(filePaths);
```

Delete with error handling:

```javascript
const { data, error } = await supabase
  .storage
  .from('avatars')
  .remove(['avatar.png']);

if (error) {
  if (error.message.includes('not found')) {
    // File doesn't exist
  } else if (error.message.includes('permission')) {
    // Insufficient permissions
  }
}
```

**[Inference]** Deleting files is permanent and cannot be undone unless you have implemented your own versioning or backup system.

