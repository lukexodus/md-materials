## Downloading Files


Files are retrieved through direct downloads or by generating accessible URLs for client-side rendering.

Download as blob:

```javascript
const { data, error } = await supabase
  .storage
  .from('avatars')
  .download('user-123/avatar.png');

// data is a Blob object
const url = URL.createObjectURL(data);
```

Download with progress tracking:

```javascript
const { data, error } = await supabase
  .storage
  .from('documents')
  .download('large-file.pdf', {
    onDownloadProgress: (progressEvent) => {
      const percentCompleted = Math.round(
        (progressEvent.loaded * 100) / progressEvent.total
      );
      console.log(percentCompleted);
    }
  });
```

Get public URL (for public buckets):

```javascript
const { data } = supabase
  .storage
  .from('avatars')
  .getPublicUrl('user-123/avatar.png');

// data.publicUrl contains the direct URL
```

Public URL with transformation (images):

```javascript
const { data } = supabase
  .storage
  .from('avatars')
  .getPublicUrl('user-123/avatar.png', {
    transform: {
      width: 200,
      height: 200
    }
  });
```

Creating authenticated URLs for private buckets:

```javascript
const { data, error } = await supabase
  .storage
  .from('private-documents')
  .createSignedUrl('document.pdf', 60); // Expires in 60 seconds
```

Downloading and displaying an image:

```javascript
const { data, error } = await supabase
  .storage
  .from('avatars')
  .download('avatar.png');

if (data) {
  const url = URL.createObjectURL(data);
  document.getElementById('avatar').src = url;
}
```

