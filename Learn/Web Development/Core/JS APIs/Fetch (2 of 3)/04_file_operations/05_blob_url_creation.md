## Blob URL Creation


### Core Mechanism

Blob URLs are temporary, browser-generated references to binary data stored in memory. Created via `URL.createObjectURL()`, they produce strings with the `blob:` protocol scheme followed by an origin and unique identifier (e.g., `blob:https://example.com/550e8400-e29b-41d4-a716-446655440000`).

```javascript
const blob = new Blob(['Hello, world!'], { type: 'text/plain' });
const blobUrl = URL.createObjectURL(blob);
// Result: "blob:https://example.com/550e8400-e29b-41d4-a716-446655440000"
```

The browser maintains an internal registry mapping these URLs to Blob objects. The URL remains valid only within the creating document's context and lifetime.

### Blob Construction for URL Creation

#### From Raw Data

```javascript
// Text content
const textBlob = new Blob(['Line 1\n', 'Line 2'], { type: 'text/plain' });

// JSON data
const jsonBlob = new Blob(
  [JSON.stringify({ key: 'value' }, null, 2)], 
  { type: 'application/json' }
);

// Binary data from ArrayBuffer
const buffer = new Uint8Array([0x89, 0x50, 0x4E, 0x47]);
const binaryBlob = new Blob([buffer], { type: 'image/png' });

// Mixed content types
const htmlBlob = new Blob(
  ['<html><body>', '<h1>Title</h1>', '</body></html>'], 
  { type: 'text/html' }
);
```

#### From Canvas

```javascript
canvas.toBlob((blob) => {
  const url = URL.createObjectURL(blob);
  // Use url
  URL.revokeObjectURL(url);
}, 'image/png', 0.95);
```

#### From Fetch Response

```javascript
const response = await fetch('https://example.com/image.jpg');
const blob = await response.blob();
const url = URL.createObjectURL(blob);
```

#### From File Input

```javascript
input.addEventListener('change', (e) => {
  const file = e.target.files[0];
  const url = URL.createObjectURL(file);
  // File objects are Blob subclasses, work directly
});
```

### Memory Management

#### Manual Revocation

```javascript
const blob = new Blob(['data'], { type: 'text/plain' });
const url = URL.createObjectURL(blob);

// Use the URL
document.querySelector('img').src = url;

// Revoke when no longer needed
URL.revokeObjectURL(url);
```

Once revoked, the URL becomes invalid. Attempts to fetch it return network errors. [Inference] The browser may delay actual memory deallocation until all active references (e.g., loading images) complete.

#### Automatic Revocation on Document Unload

Blob URLs are automatically revoked when the document that created them unloads. They cannot be shared across origins or persisted beyond the browser session.

#### Memory Leak Prevention

```javascript
// BAD: Creates leak if revocation is forgotten
function displayImage(blob) {
  const url = URL.createObjectURL(blob);
  img.src = url;
  // Missing revocation
}

// GOOD: Revoke after load
function displayImage(blob) {
  const url = URL.createObjectURL(blob);
  img.src = url;
  img.onload = () => URL.revokeObjectURL(url);
}

// GOOD: Cleanup in finally block
async function processBlob(blob) {
  const url = URL.createObjectURL(blob);
  try {
    await someAsyncOperation(url);
  } finally {
    URL.revokeObjectURL(url);
  }
}
```

### Common Use Cases

#### Image Preview from File Upload

```javascript
const input = document.querySelector('input[type="file"]');
const preview = document.querySelector('img');

input.addEventListener('change', (e) => {
  const file = e.target.files[0];
  if (file && file.type.startsWith('image/')) {
    // Revoke previous URL to prevent leak
    if (preview.src.startsWith('blob:')) {
      URL.revokeObjectURL(preview.src);
    }
    
    const url = URL.createObjectURL(file);
    preview.src = url;
    
    // Revoke after image loads
    preview.onload = () => URL.revokeObjectURL(url);
  }
});
```

#### Download Generated Content

```javascript
function downloadJSON(data, filename) {
  const blob = new Blob([JSON.stringify(data, null, 2)], {
    type: 'application/json'
  });
  const url = URL.createObjectURL(blob);
  
  const a = document.createElement('a');
  a.href = url;
  a.download = filename;
  document.body.appendChild(a);
  a.click();
  
  // Cleanup
  document.body.removeChild(a);
  URL.revokeObjectURL(url);
}
```

#### Video/Audio Playback

```javascript
const response = await fetch('/video.mp4');
const blob = await response.blob();
const url = URL.createObjectURL(blob);

const video = document.querySelector('video');
video.src = url;

// Revoke when video ends or component unmounts
video.onended = () => URL.revokeObjectURL(url);
```

#### PDF Display in iframe

```javascript
async function displayPDF(pdfBlob) {
  const url = URL.createObjectURL(pdfBlob);
  const iframe = document.querySelector('iframe');
  iframe.src = url;
  
  // Cleanup when iframe is removed
  return () => URL.revokeObjectURL(url);
}
```

#### Worker Script Creation

```javascript
const workerCode = `
  self.addEventListener('message', (e) => {
    self.postMessage(e.data * 2);
  });
`;

const blob = new Blob([workerCode], { type: 'application/javascript' });
const url = URL.createObjectURL(blob);
const worker = new Worker(url);

worker.postMessage(5);
worker.onmessage = (e) => console.log(e.data); // 10

// Cleanup
worker.terminate();
URL.revokeObjectURL(url);
```

### Blob URL vs Data URL

#### Size Considerations

```javascript
// Small data: Data URL is efficient (no separate object in memory)
const dataUrl = 'data:text/plain;base64,SGVsbG8gd29ybGQ=';
img.src = dataUrl;

// Large data: Blob URL is better (no Base64 encoding overhead)
const largeBlob = new Blob([largeArrayBuffer]);
const blobUrl = URL.createObjectURL(largeBlob);
img.src = blobUrl;
```

Data URLs are immediately usable and persist in the HTML/CSS, but they:

- Increase size by ~33% due to Base64 encoding
- Are embedded in the document (increase memory/transfer size)
- Cannot be revoked

Blob URLs:

- No encoding overhead
- Can be revoked to free memory
- Only valid within the creating context
- Require active memory management

#### Performance Comparison

For data under ~1KB, Data URLs may be more efficient. For larger data (images, videos, documents), Blob URLs avoid encoding costs and enable memory cleanup.

### Cross-Origin and Security

Blob URLs inherit the origin of the document that created them. They cannot be accessed cross-origin:

```javascript
// On https://example.com
const blob = new Blob(['secret'], { type: 'text/plain' });
const url = URL.createObjectURL(blob);

// This URL cannot be accessed from https://other-site.com
// Even if the string is passed to another origin
```

Blob URLs are not subject to CORS because they reference local memory, not network resources. However, blobs created from fetch responses carry the same-origin policy of their source.

### Browser Storage Limitations

Blob URLs reference in-memory data. The total size is limited by available browser memory, not localStorage or sessionStorage quotas. [Inference] Browsers typically allow several hundred megabytes to a few gigabytes depending on available system resources and 32-bit vs 64-bit architecture.

Creating extremely large blobs may trigger out-of-memory errors:

```javascript
try {
  // Attempting to create 2GB blob
  const hugeBlob = new Blob([new ArrayBuffer(2 * 1024 * 1024 * 1024)]);
  const url = URL.createObjectURL(hugeBlob);
} catch (e) {
  console.error('Out of memory'); // [Inference] May occur on 32-bit systems
}
```

### Integration with Modern APIs

#### Clipboard API

```javascript
async function copyImageToClipboard(blob) {
  await navigator.clipboard.write([
    new ClipboardItem({ [blob.type]: blob })
  ]);
}
```

#### FileSystem Access API

```javascript
async function saveBlob(blob, suggestedName) {
  const handle = await window.showSaveFilePicker({ suggestedName });
  const writable = await handle.createWritable();
  await writable.write(blob);
  await writable.close();
}
```

#### Cache API

```javascript
const cache = await caches.open('v1');
const response = new Response(blob, {
  headers: { 'Content-Type': blob.type }
});
await cache.put('/cached-resource', response);
```

### React/Framework Patterns

```javascript
// React hook for blob URL management
function useBlobUrl(blob) {
  const [url, setUrl] = useState(null);
  
  useEffect(() => {
    if (!blob) return;
    
    const objectUrl = URL.createObjectURL(blob);
    setUrl(objectUrl);
    
    return () => URL.revokeObjectURL(objectUrl);
  }, [blob]);
  
  return url;
}

// Usage
function ImagePreview({ file }) {
  const url = useBlobUrl(file);
  return url ? <img src={url} alt="Preview" /> : null;
}
```

### Debugging Blob URLs

Blob URLs can be examined in DevTools:

```javascript
const blob = new Blob(['test'], { type: 'text/plain' });
const url = URL.createObjectURL(blob);

// In Chrome DevTools, paste the blob URL in the console
// Then use fetch to inspect contents
fetch(url).then(r => r.text()).then(console.log);
```

Network tabs show blob URL loads as "(blob)" with no network activity since data is local.

### Edge Cases

#### Multiple References

```javascript
const blob = new Blob(['data']);
const url1 = URL.createObjectURL(blob);
const url2 = URL.createObjectURL(blob);

// url1 !== url2 (different URLs, same underlying blob)
// Must revoke both to free memory fully [Inference]
URL.revokeObjectURL(url1);
URL.revokeObjectURL(url2);
```

#### Revocation Timing

```javascript
const url = URL.createObjectURL(blob);
img.src = url;
URL.revokeObjectURL(url); // Immediate revocation

// [Inference] Image may still load if browser has buffered the blob
// but new elements cannot use this URL
```

#### Empty Blobs

```javascript
const emptyBlob = new Blob([]);
const url = URL.createObjectURL(emptyBlob);
// Valid URL, points to 0-byte blob
```

---

