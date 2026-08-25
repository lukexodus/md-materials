## File Upload with the Fetch API


### Basic File Upload

The fetch API handles file uploads by sending `File` or `Blob` objects within a `FormData` payload. The browser automatically sets the appropriate `Content-Type` header with boundary parameters.

```javascript
const fileInput = document.querySelector('input[type="file"]');
const file = fileInput.files[0];

const formData = new FormData();
formData.append('file', file);

fetch('/upload', {
  method: 'POST',
  body: formData
})
  .then(response => response.json())
  .then(data => console.log(data))
  .catch(error => console.error(error));
```

### Multiple File Upload

FormData supports appending multiple files to the same field name or different field names.

```javascript
const fileInput = document.querySelector('input[type="file"][multiple]');
const files = fileInput.files;

const formData = new FormData();

// Same field name (creates array on server)
for (let i = 0; i < files.length; i++) {
  formData.append('files[]', files[i]);
}

// Or different field names
Array.from(files).forEach((file, index) => {
  formData.append(`file_${index}`, file);
});

fetch('/upload-multiple', {
  method: 'POST',
  body: formData
});
```

### File Upload with Additional Fields

FormData can combine file uploads with other form data in a single request.

```javascript
const formData = new FormData();
formData.append('file', file);
formData.append('userId', '12345');
formData.append('description', 'Profile photo');
formData.append('category', 'images');
formData.append('metadata', JSON.stringify({ tags: ['profile', 'user'] }));

fetch('/upload', {
  method: 'POST',
  body: formData
});
```

### Custom Filename and MIME Type

The `append()` method accepts an optional third parameter to specify a custom filename, which is particularly useful for Blob objects.

```javascript
const blob = new Blob(['file content'], { type: 'text/plain' });

formData.append('file', blob, 'custom-filename.txt');

// For File objects, override the original filename
formData.append('file', file, 'renamed-file.pdf');
```

### Direct Binary Upload

Files can be uploaded directly as the request body without FormData, requiring manual `Content-Type` header configuration.

```javascript
const file = fileInput.files[0];

fetch('/upload', {
  method: 'POST',
  headers: {
    'Content-Type': file.type,
    'Content-Length': file.size.toString(),
    'X-Filename': encodeURIComponent(file.name)
  },
  body: file
});
```

### Upload Progress Tracking

The fetch API itself does not expose upload progress events. [Inference] Progress tracking requires XMLHttpRequest or the emerging Upload Progress API proposal (not yet standardized).

```javascript
// Using XMLHttpRequest for progress
function uploadWithProgress(file, onProgress) {
  return new Promise((resolve, reject) => {
    const xhr = new XMLHttpRequest();
    
    xhr.upload.addEventListener('progress', (e) => {
      if (e.lengthComputable) {
        const percentComplete = (e.loaded / e.total) * 100;
        onProgress(percentComplete);
      }
    });
    
    xhr.addEventListener('load', () => {
      if (xhr.status >= 200 && xhr.status < 300) {
        resolve(JSON.parse(xhr.responseText));
      } else {
        reject(new Error(`Upload failed: ${xhr.status}`));
      }
    });
    
    xhr.addEventListener('error', () => reject(new Error('Upload failed')));
    
    const formData = new FormData();
    formData.append('file', file);
    
    xhr.open('POST', '/upload');
    xhr.send(formData);
  });
}

uploadWithProgress(file, (percent) => {
  console.log(`Upload progress: ${percent.toFixed(2)}%`);
});
```

### Chunked File Upload

Large files can be split into chunks and uploaded sequentially or in parallel, enabling resume functionality and better error handling.

```javascript
async function uploadFileInChunks(file, chunkSize = 1024 * 1024) {
  const totalChunks = Math.ceil(file.size / chunkSize);
  
  for (let i = 0; i < totalChunks; i++) {
    const start = i * chunkSize;
    const end = Math.min(start + chunkSize, file.size);
    const chunk = file.slice(start, end);
    
    const formData = new FormData();
    formData.append('chunk', chunk);
    formData.append('chunkIndex', i.toString());
    formData.append('totalChunks', totalChunks.toString());
    formData.append('fileId', generateFileId(file));
    
    const response = await fetch('/upload-chunk', {
      method: 'POST',
      body: formData
    });
    
    if (!response.ok) {
      throw new Error(`Chunk ${i} upload failed`);
    }
  }
}

function generateFileId(file) {
  return `${file.name}-${file.size}-${file.lastModified}`;
}
```

### Parallel Chunk Upload

```javascript
async function uploadFileInParallel(file, chunkSize = 1024 * 1024, maxParallel = 3) {
  const totalChunks = Math.ceil(file.size / chunkSize);
  const chunks = [];
  
  for (let i = 0; i < totalChunks; i++) {
    chunks.push(i);
  }
  
  async function uploadChunk(index) {
    const start = index * chunkSize;
    const end = Math.min(start + chunkSize, file.size);
    const chunk = file.slice(start, end);
    
    const formData = new FormData();
    formData.append('chunk', chunk);
    formData.append('chunkIndex', index.toString());
    formData.append('totalChunks', totalChunks.toString());
    
    return fetch('/upload-chunk', {
      method: 'POST',
      body: formData
    });
  }
  
  // Upload in batches
  for (let i = 0; i < chunks.length; i += maxParallel) {
    const batch = chunks.slice(i, i + maxParallel);
    await Promise.all(batch.map(uploadChunk));
  }
}
```

### Upload with Authentication

Authentication credentials can be included via headers or cookies, depending on the authentication mechanism.

```javascript
// Bearer token
fetch('/upload', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer ' + authToken
  },
  body: formData
});

// With credentials (cookies)
fetch('/upload', {
  method: 'POST',
  credentials: 'include',
  body: formData
});

// API key
fetch('/upload', {
  method: 'POST',
  headers: {
    'X-API-Key': apiKey
  },
  body: formData
});
```

### File Validation Before Upload

Client-side validation reduces unnecessary server requests but should always be complemented with server-side validation.

```javascript
function validateFile(file, options = {}) {
  const {
    maxSize = 10 * 1024 * 1024, // 10MB
    allowedTypes = ['image/jpeg', 'image/png', 'application/pdf'],
    allowedExtensions = ['.jpg', '.jpeg', '.png', '.pdf']
  } = options;
  
  // Size validation
  if (file.size > maxSize) {
    throw new Error(`File size exceeds ${maxSize / (1024 * 1024)}MB`);
  }
  
  // MIME type validation
  if (!allowedTypes.includes(file.type)) {
    throw new Error(`File type ${file.type} not allowed`);
  }
  
  // Extension validation
  const extension = file.name.substring(file.name.lastIndexOf('.')).toLowerCase();
  if (!allowedExtensions.includes(extension)) {
    throw new Error(`File extension ${extension} not allowed`);
  }
  
  return true;
}

// Usage
try {
  validateFile(file);
  // Proceed with upload
} catch (error) {
  console.error('Validation failed:', error.message);
}
```

### Image Preview Before Upload

```javascript
function previewImage(file) {
  return new Promise((resolve, reject) => {
    if (!file.type.startsWith('image/')) {
      reject(new Error('Not an image file'));
      return;
    }
    
    const reader = new FileReader();
    
    reader.onload = (e) => {
      const img = document.createElement('img');
      img.src = e.target.result;
      img.style.maxWidth = '300px';
      document.getElementById('preview').appendChild(img);
      resolve(e.target.result);
    };
    
    reader.onerror = () => reject(new Error('Failed to read file'));
    
    reader.readAsDataURL(file);
  });
}
```

### Upload Retry Logic

Implementing automatic retry with exponential backoff improves reliability for transient network failures.

```javascript
async function uploadWithRetry(file, maxRetries = 3, baseDelay = 1000) {
  const formData = new FormData();
  formData.append('file', file);
  
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      const response = await fetch('/upload', {
        method: 'POST',
        body: formData
      });
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }
      
      return await response.json();
    } catch (error) {
      if (attempt === maxRetries) {
        throw new Error(`Upload failed after ${maxRetries} retries: ${error.message}`);
      }
      
      const delay = baseDelay * Math.pow(2, attempt);
      console.log(`Retry ${attempt + 1} after ${delay}ms`);
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
}
```

### Drag and Drop File Upload

```javascript
const dropZone = document.getElementById('drop-zone');

dropZone.addEventListener('dragover', (e) => {
  e.preventDefault();
  e.stopPropagation();
  dropZone.classList.add('dragover');
});

dropZone.addEventListener('dragleave', (e) => {
  e.preventDefault();
  e.stopPropagation();
  dropZone.classList.remove('dragover');
});

dropZone.addEventListener('drop', async (e) => {
  e.preventDefault();
  e.stopPropagation();
  dropZone.classList.remove('dragover');
  
  const files = Array.from(e.dataTransfer.files);
  
  for (const file of files) {
    const formData = new FormData();
    formData.append('file', file);
    
    try {
      const response = await fetch('/upload', {
        method: 'POST',
        body: formData
      });
      
      const result = await response.json();
      console.log('Uploaded:', result);
    } catch (error) {
      console.error('Upload failed:', error);
    }
  }
});
```

### Upload Cancellation

The AbortController enables upload cancellation, though the server-side handling depends on implementation.

```javascript
const controller = new AbortController();
const signal = controller.signal;

const uploadPromise = fetch('/upload', {
  method: 'POST',
  body: formData,
  signal: signal
});

// Cancel after 5 seconds or on user action
setTimeout(() => controller.abort(), 5000);

// Or bind to button
document.getElementById('cancel-btn').addEventListener('click', () => {
  controller.abort();
});

uploadPromise
  .then(response => response.json())
  .catch(error => {
    if (error.name === 'AbortError') {
      console.log('Upload cancelled');
    } else {
      console.error('Upload failed:', error);
    }
  });
```

### Multipart Upload for Large Files

Some servers require multipart upload initiation, chunk upload, and completion steps for very large files.

```javascript
async function multipartUpload(file) {
  // Step 1: Initiate multipart upload
  const initResponse = await fetch('/upload/initiate', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      filename: file.name,
      contentType: file.type,
      size: file.size
    })
  });
  
  const { uploadId, partSize } = await initResponse.json();
  
  // Step 2: Upload parts
  const totalParts = Math.ceil(file.size / partSize);
  const parts = [];
  
  for (let partNumber = 1; partNumber <= totalParts; partNumber++) {
    const start = (partNumber - 1) * partSize;
    const end = Math.min(start + partSize, file.size);
    const chunk = file.slice(start, end);
    
    const partResponse = await fetch(`/upload/part?uploadId=${uploadId}&partNumber=${partNumber}`, {
      method: 'PUT',
      body: chunk
    });
    
    const { etag } = await partResponse.json();
    parts.push({ partNumber, etag });
  }
  
  // Step 3: Complete multipart upload
  const completeResponse = await fetch('/upload/complete', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      uploadId,
      parts
    })
  });
  
  return await completeResponse.json();
}
```

### Reading File Content Before Upload

File content can be read into various formats before or instead of uploading.

```javascript
// Read as text
function readAsText(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(reader.result);
    reader.onerror = reject;
    reader.readAsText(file);
  });
}

// Read as Data URL (base64)
function readAsDataURL(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(reader.result);
    reader.onerror = reject;
    reader.readAsDataURL(file);
  });
}

// Read as ArrayBuffer
function readAsArrayBuffer(file) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    reader.onload = () => resolve(reader.result);
    reader.onerror = reject;
    reader.readAsArrayBuffer(file);
  });
}

// Upload base64 encoded file
async function uploadBase64(file) {
  const base64 = await readAsDataURL(file);
  
  await fetch('/upload-base64', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      filename: file.name,
      contentType: file.type,
      data: base64
    })
  });
}
```

### Compressing Images Before Upload

```javascript
async function compressImage(file, maxWidth = 1920, quality = 0.8) {
  return new Promise((resolve, reject) => {
    const reader = new FileReader();
    
    reader.onload = (e) => {
      const img = new Image();
      
      img.onload = () => {
        const canvas = document.createElement('canvas');
        let width = img.width;
        let height = img.height;
        
        if (width > maxWidth) {
          height *= maxWidth / width;
          width = maxWidth;
        }
        
        canvas.width = width;
        canvas.height = height;
        
        const ctx = canvas.getContext('2d');
        ctx.drawImage(img, 0, 0, width, height);
        
        canvas.toBlob((blob) => {
          resolve(new File([blob], file.name, {
            type: 'image/jpeg',
            lastModified: Date.now()
          }));
        }, 'image/jpeg', quality);
      };
      
      img.onerror = reject;
      img.src = e.target.result;
    };
    
    reader.onerror = reject;
    reader.readAsDataURL(file);
  });
}

// Usage
const compressed = await compressImage(originalFile);
const formData = new FormData();
formData.append('file', compressed);
await fetch('/upload', { method: 'POST', body: formData });
```

### Handling Upload Responses

```javascript
async function handleUpload(file) {
  const formData = new FormData();
  formData.append('file', file);
  
  try {
    const response = await fetch('/upload', {
      method: 'POST',
      body: formData
    });
    
    // Check response status
    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.message || `HTTP ${response.status}`);
    }
    
    // Parse success response
    const result = await response.json();
    
    // Common response fields
    console.log('File ID:', result.id);
    console.log('File URL:', result.url);
    console.log('File size:', result.size);
    console.log('Upload timestamp:', result.uploadedAt);
    
    return result;
  } catch (error) {
    if (error.name === 'TypeError') {
      console.error('Network error:', error.message);
    } else {
      console.error('Upload error:', error.message);
    }
    throw error;
  }
}
```

### CORS Considerations

Cross-origin file uploads require proper CORS headers on the server. The client must handle preflight requests for methods other than simple POST requests.

```javascript
// For cross-origin uploads
fetch('https://api.example.com/upload', {
  method: 'POST',
  body: formData,
  credentials: 'include', // If cookies needed
  headers: {
    // Do NOT set Content-Type manually for FormData
    // Browser sets it with boundary
    'Authorization': 'Bearer token'
  }
});

// Server must respond with:
// Access-Control-Allow-Origin: https://your-domain.com
// Access-Control-Allow-Methods: POST, OPTIONS
// Access-Control-Allow-Headers: Authorization
// Access-Control-Allow-Credentials: true (if using credentials)
```

### FormData Inspection

FormData contents are not directly enumerable in all browsers, but can be inspected via iterator methods.

```javascript
const formData = new FormData();
formData.append('file', file);
formData.append('userId', '123');

// Iterate over entries
for (const [key, value] of formData.entries()) {
  console.log(key, value);
}

// Get specific values
console.log(formData.get('userId')); // '123'

// Get all values for a key
console.log(formData.getAll('files[]'));

// Check if key exists
console.log(formData.has('file')); // true

// Delete entry
formData.delete('userId');
```

### Memory Management for Large Files

File objects reference disk data and don't necessarily load entirely into memory. However, operations like slicing or reading can increase memory usage.

```javascript
// Efficient: uses references
const chunk = file.slice(0, 1024 * 1024);

// Less efficient: loads entire file into memory
const arrayBuffer = await file.arrayBuffer();

// Clean up object URLs after use
const url = URL.createObjectURL(file);
// Use url...
URL.revokeObjectURL(url); // Free memory
```

### Uploading from Clipboard

```javascript
document.addEventListener('paste', async (e) => {
  const items = e.clipboardData.items;
  
  for (const item of items) {
    if (item.type.startsWith('image/')) {
      const file = item.getAsFile();
      
      const formData = new FormData();
      formData.append('file', file, `pasted-${Date.now()}.png`);
      
      await fetch('/upload', {
        method: 'POST',
        body: formData
      });
    }
  }
});
```

### Upload Queue Management

```javascript
class UploadQueue {
  constructor(concurrency = 2) {
    this.concurrency = concurrency;
    this.queue = [];
    this.active = 0;
  }
  
  async add(file) {
    return new Promise((resolve, reject) => {
      this.queue.push({ file, resolve, reject });
      this.process();
    });
  }
  
  async process() {
    if (this.active >= this.concurrency || this.queue.length === 0) {
      return;
    }
    
    this.active++;
    const { file, resolve, reject } = this.queue.shift();
    
    try {
      const formData = new FormData();
      formData.append('file', file);
      
      const response = await fetch('/upload', {
        method: 'POST',
        body: formData
      });
      
      const result = await response.json();
      resolve(result);
    } catch (error) {
      reject(error);
    } finally {
      this.active--;
      this.process();
    }
  }
}

// Usage
const queue = new UploadQueue(3);
const files = fileInput.files;

for (const file of files) {
  queue.add(file)
    .then(result => console.log('Uploaded:', result))
    .catch(error => console.error('Failed:', error));
}
```

### Presigned URL Upload

Some services (like AWS S3) provide presigned URLs that allow direct client-to-storage uploads without proxying through your server.

```javascript
async function uploadToPresignedUrl(file) {
  // Step 1: Get presigned URL from your server
  const urlResponse = await fetch('/get-upload-url', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      filename: file.name,
      contentType: file.type
    })
  });
  
  const { uploadUrl, fileUrl } = await urlResponse.json();
  
  // Step 2: Upload directly to storage
  await fetch(uploadUrl, {
    method: 'PUT',
    headers: {
      'Content-Type': file.type
    },
    body: file
  });
  
  // Step 3: Notify your server of completion (optional)
  await fetch('/upload-complete', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ fileUrl })
  });
  
  return fileUrl;
}
```

---

