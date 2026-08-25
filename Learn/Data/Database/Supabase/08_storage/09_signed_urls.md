## Signed URLs


Signed URLs provide temporary, authenticated access to files in private buckets without requiring the client to maintain authentication state.

Creating a signed URL:

```javascript
const { data, error } = await supabase
  .storage
  .from('private-documents')
  .createSignedUrl('document.pdf', 3600); // Expires in 3600 seconds (1 hour)

// data.signedUrl contains the temporary URL
```

Signed URL with transformations:

```javascript
const { data, error } = await supabase
  .storage
  .from('private-photos')
  .createSignedUrl('photo.jpg', 3600, {
    transform: {
      width: 400,
      height: 300,
      resize: 'cover',
      quality: 85
    }
  });
```

Creating multiple signed URLs:

```javascript
const files = ['file1.pdf', 'file2.pdf', 'file3.pdf'];
const { data, error } = await supabase
  .storage
  .from('documents')
  .createSignedUrls(files, 3600);

// data is an array of signed URL objects
```

Response structure:

```javascript
{
  data: {
    signedUrl: 'https://[project].supabase.co/storage/v1/object/sign/[bucket]/[path]?token=[token]',
    path: 'documents/file.pdf'
  },
  error: null
}
```

Signed URL expiration options:

```javascript
// Short-lived (5 minutes)
createSignedUrl('file.pdf', 300)

// Medium-lived (1 hour)
createSignedUrl('file.pdf', 3600)

// Long-lived (24 hours)
createSignedUrl('file.pdf', 86400)
```

Using signed URLs in applications:

```javascript
// Generate signed URL server-side
const { data } = await supabase
  .storage
  .from('private-videos')
  .createSignedUrl('video.mp4', 7200);

// Send to client
return { videoUrl: data.signedUrl };

// Client displays video
<video src={videoUrl} controls />
```

Download file using signed URL:

```javascript
const { data } = await supabase
  .storage
  .from('reports')
  .createSignedUrl('monthly-report.pdf', 600);

// Trigger download in browser
const link = document.createElement('a');
link.href = data.signedUrl;
link.download = 'report.pdf';
link.click();
```

**[Inference]** Signed URLs expire after the specified duration, requiring regeneration for continued access, which may require application logic to refresh URLs before expiration.

