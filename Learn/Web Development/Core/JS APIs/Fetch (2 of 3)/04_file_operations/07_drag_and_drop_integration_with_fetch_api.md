## Drag-and-Drop Integration with Fetch API


### Overview of Integration Patterns

Drag-and-drop file uploads combine the HTML5 Drag and Drop API with the Fetch API to create seamless file transfer experiences. The integration involves capturing drag events, extracting file data from `DataTransfer` objects, and transmitting files via fetch requests with `FormData` or binary payloads.

### Event Handlers for Drag Operations

#### Essential Drag Events

Four primary events handle the drag-and-drop lifecycle:

- **`dragenter`**: Fired when dragged items enter a valid drop target
- **`dragover`**: Continuously fired while items are over the drop zone
- **`dragleave`**: Fired when items leave the drop zone boundary
- **`drop`**: Fired when items are released over the drop zone

#### Preventing Default Behaviors

```javascript
dropZone.addEventListener('dragover', (e) => {
  e.preventDefault();
  e.stopPropagation();
});

dropZone.addEventListener('drop', (e) => {
  e.preventDefault();
  e.stopPropagation();
});
```

Both `dragover` and `drop` require `preventDefault()` to override the browser's default behavior (typically opening files in a new tab). Without this, the drop operation will not function as intended.

### Extracting Files from DataTransfer

#### Accessing Files from Drop Events

```javascript
dropZone.addEventListener('drop', (e) => {
  e.preventDefault();
  
  const files = e.dataTransfer.files;
  
  if (files.length > 0) {
    handleFiles(files);
  }
});
```

The `e.dataTransfer.files` property returns a `FileList` object containing all dropped files. This is array-like but not a true array.

#### Handling DataTransfer Items

For more granular control, especially when dealing with directories or non-file data:

```javascript
dropZone.addEventListener('drop', async (e) => {
  e.preventDefault();
  
  const items = e.dataTransfer.items;
  
  for (let i = 0; i < items.length; i++) {
    const item = items[i];
    
    if (item.kind === 'file') {
      const file = item.getAsFile();
      await uploadFile(file);
    }
  }
});
```

The `DataTransferItem` interface provides `kind` property ('file' or 'string') and methods like `getAsFile()` for more sophisticated handling.

### Upload Strategies with Fetch

#### Single File Upload with FormData

```javascript
async function uploadFile(file) {
  const formData = new FormData();
  formData.append('file', file);
  formData.append('filename', file.name);
  
  try {
    const response = await fetch('/upload', {
      method: 'POST',
      body: formData
      // Do not set Content-Type header - browser sets it automatically with boundary
    });
    
    if (!response.ok) {
      throw new Error(`Upload failed: ${response.status}`);
    }
    
    const result = await response.json();
    return result;
  } catch (error) {
    console.error('Upload error:', error);
    throw error;
  }
}
```

When using `FormData`, the browser automatically sets the `Content-Type` header to `multipart/form-data` with the appropriate boundary parameter.

#### Multiple File Upload

```javascript
async function uploadMultipleFiles(files) {
  const formData = new FormData();
  
  Array.from(files).forEach((file, index) => {
    formData.append('files[]', file);
    // Or use unique keys: formData.append(`file_${index}`, file);
  });
  
  const response = await fetch('/upload/multiple', {
    method: 'POST',
    body: formData
  });
  
  return response.json();
}
```

#### Binary Upload (Direct File Stream)

```javascript
async function uploadBinary(file) {
  const response = await fetch('/upload/binary', {
    method: 'POST',
    headers: {
      'Content-Type': file.type || 'application/octet-stream',
      'X-File-Name': encodeURIComponent(file.name),
      'X-File-Size': file.size.toString()
    },
    body: file // File objects are Blob-like and can be sent directly
  });
  
  return response.json();
}
```

This approach sends the raw file data without multipart encoding, useful for APIs that expect binary payloads.

### Progress Tracking Integration

#### Using Fetch with Progress Events

[Inference] Fetch API does not natively support upload progress tracking. The standard approach combines `XMLHttpRequest` with drag-and-drop for progress monitoring, or uses the Streams API for approximations.

#### XMLHttpRequest Alternative for Progress

```javascript
function uploadWithProgress(file, onProgress) {
  return new Promise((resolve, reject) => {
    const xhr = new XMLHttpRequest();
    const formData = new FormData();
    formData.append('file', file);
    
    xhr.upload.addEventListener('progress', (e) => {
      if (e.lengthComputable) {
        const percentage = (e.loaded / e.total) * 100;
        onProgress(percentage);
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
    xhr.addEventListener('abort', () => reject(new Error('Upload aborted')));
    
    xhr.open('POST', '/upload');
    xhr.send(formData);
  });
}

// Usage with drag-and-drop
dropZone.addEventListener('drop', async (e) => {
  e.preventDefault();
  const files = e.dataTransfer.files;
  
  for (const file of files) {
    await uploadWithProgress(file, (percent) => {
      console.log(`${file.name}: ${percent}%`);
    });
  }
});
```

#### Streams API for Chunked Upload

```javascript
async function uploadWithChunks(file, chunkSize = 1024 * 1024) {
  let offset = 0;
  
  while (offset < file.size) {
    const chunk = file.slice(offset, offset + chunkSize);
    
    await fetch('/upload/chunk', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/octet-stream',
        'X-Chunk-Index': Math.floor(offset / chunkSize).toString(),
        'X-Total-Size': file.size.toString(),
        'X-File-Name': encodeURIComponent(file.name)
      },
      body: chunk
    });
    
    offset += chunkSize;
    
    const progress = (offset / file.size) * 100;
    updateProgressBar(progress);
  }
  
  // Finalize upload
  await fetch('/upload/finalize', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ filename: file.name, totalSize: file.size })
  });
}
```

### Visual Feedback Patterns

#### Drag State Management

```javascript
const dropZone = document.getElementById('dropzone');
let dragCounter = 0;

dropZone.addEventListener('dragenter', (e) => {
  e.preventDefault();
  dragCounter++;
  dropZone.classList.add('drag-over');
});

dropZone.addEventListener('dragleave', (e) => {
  e.preventDefault();
  dragCounter--;
  
  if (dragCounter === 0) {
    dropZone.classList.remove('drag-over');
  }
});

dropZone.addEventListener('drop', (e) => {
  e.preventDefault();
  dragCounter = 0;
  dropZone.classList.remove('drag-over');
  
  const files = e.dataTransfer.files;
  handleFileDrop(files);
});
```

The `dragCounter` pattern handles nested elements within the drop zone that can trigger false `dragleave` events.

#### Drop Effect Indicators

```javascript
dropZone.addEventListener('dragover', (e) => {
  e.preventDefault();
  e.dataTransfer.dropEffect = 'copy'; // Shows copy cursor
  // Other values: 'move', 'link', 'none'
});
```

### File Validation Before Upload

#### Type and Size Validation

```javascript
function validateFile(file, options = {}) {
  const {
    maxSize = 10 * 1024 * 1024, // 10MB default
    allowedTypes = ['image/jpeg', 'image/png', 'application/pdf']
  } = options;
  
  const errors = [];
  
  if (file.size > maxSize) {
    errors.push(`File size ${(file.size / 1024 / 1024).toFixed(2)}MB exceeds limit of ${(maxSize / 1024 / 1024).toFixed(2)}MB`);
  }
  
  if (allowedTypes.length > 0 && !allowedTypes.includes(file.type)) {
    errors.push(`File type ${file.type} not allowed. Allowed: ${allowedTypes.join(', ')}`);
  }
  
  return {
    valid: errors.length === 0,
    errors
  };
}

dropZone.addEventListener('drop', async (e) => {
  e.preventDefault();
  const files = Array.from(e.dataTransfer.files);
  
  for (const file of files) {
    const validation = validateFile(file, {
      maxSize: 5 * 1024 * 1024,
      allowedTypes: ['image/jpeg', 'image/png']
    });
    
    if (validation.valid) {
      await uploadFile(file);
    } else {
      console.error(`Validation failed for ${file.name}:`, validation.errors);
    }
  }
});
```

#### MIME Type Verification

[Inference] Client-side MIME type checking via `file.type` relies on file extensions and can be spoofed. Server-side verification by reading file headers is necessary for security-critical applications.

```javascript
async function verifyFileType(file) {
  return new Promise((resolve) => {
    const reader = new FileReader();
    
    reader.onload = (e) => {
      const arr = new Uint8Array(e.target.result).subarray(0, 4);
      let header = '';
      for (let i = 0; i < arr.length; i++) {
        header += arr[i].toString(16);
      }
      
      // Common file signatures (magic numbers)
      const signatures = {
        '89504e47': 'image/png',
        'ffd8ffe0': 'image/jpeg',
        'ffd8ffe1': 'image/jpeg',
        '25504446': 'application/pdf'
      };
      
      const detectedType = signatures[header.toLowerCase()];
      resolve({
        declared: file.type,
        detected: detectedType,
        matches: file.type === detectedType
      });
    };
    
    reader.readAsArrayBuffer(file.slice(0, 4));
  });
}
```

### Concurrent Upload Management

#### Parallel Uploads with Concurrency Limit

```javascript
async function uploadFilesWithLimit(files, concurrency = 3) {
  const results = [];
  const executing = [];
  
  for (const file of files) {
    const promise = uploadFile(file).then(result => {
      executing.splice(executing.indexOf(promise), 1);
      return result;
    });
    
    results.push(promise);
    executing.push(promise);
    
    if (executing.length >= concurrency) {
      await Promise.race(executing);
    }
  }
  
  return Promise.all(results);
}

dropZone.addEventListener('drop', async (e) => {
  e.preventDefault();
  const files = Array.from(e.dataTransfer.files);
  
  try {
    const uploadResults = await uploadFilesWithLimit(files, 3);
    console.log('All uploads completed:', uploadResults);
  } catch (error) {
    console.error('Upload batch failed:', error);
  }
});
```

#### Queue-Based Upload System

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
      const result = await uploadFile(file);
      resolve(result);
    } catch (error) {
      reject(error);
    } finally {
      this.active--;
      this.process();
    }
  }
}

const uploadQueue = new UploadQueue(3);

dropZone.addEventListener('drop', async (e) => {
  e.preventDefault();
  const files = Array.from(e.dataTransfer.files);
  
  const uploads = files.map(file => uploadQueue.add(file));
  await Promise.allSettled(uploads);
});
```

### Error Handling and Retry Logic

#### Exponential Backoff Retry

```javascript
async function uploadWithRetry(file, maxRetries = 3) {
  let lastError;
  
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      const response = await fetch('/upload', {
        method: 'POST',
        body: createFormData(file)
      });
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }
      
      return await response.json();
      
    } catch (error) {
      lastError = error;
      
      if (attempt < maxRetries - 1) {
        const delay = Math.pow(2, attempt) * 1000; // 1s, 2s, 4s
        console.log(`Upload attempt ${attempt + 1} failed, retrying in ${delay}ms...`);
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  }
  
  throw new Error(`Upload failed after ${maxRetries} attempts: ${lastError.message}`);
}
```

#### Network Error Detection

```javascript
async function uploadWithNetworkCheck(file) {
  try {
    const response = await fetch('/upload', {
      method: 'POST',
      body: createFormData(file),
      signal: AbortSignal.timeout(30000) // 30 second timeout
    });
    
    return await response.json();
    
  } catch (error) {
    if (error.name === 'AbortError' || error.name === 'TimeoutError') {
      throw new Error('Upload timeout - check your connection');
    }
    
    if (!navigator.onLine) {
      throw new Error('No internet connection detected');
    }
    
    if (error instanceof TypeError && error.message.includes('fetch')) {
      throw new Error('Network request failed - unable to reach server');
    }
    
    throw error;
  }
}
```

### Drag-and-Drop from External Sources

#### Handling URLs and Text

```javascript
dropZone.addEventListener('drop', async (e) => {
  e.preventDefault();
  
  // Check for URL data
  const url = e.dataTransfer.getData('text/uri-list');
  if (url) {
    await handleUrlDrop(url);
    return;
  }
  
  // Check for plain text
  const text = e.dataTransfer.getData('text/plain');
  if (text) {
    await handleTextDrop(text);
    return;
  }
  
  // Handle files
  const files = e.dataTransfer.files;
  if (files.length > 0) {
    await handleFileDrop(files);
  }
});

async function handleUrlDrop(url) {
  // Fetch the URL content and upload
  const response = await fetch(url);
  const blob = await response.blob();
  
  // Extract filename from URL
  const filename = url.split('/').pop() || 'download';
  const file = new File([blob], filename, { type: blob.type });
  
  await uploadFile(file);
}
```

#### Downloading Remote Images

```javascript
async function downloadAndUploadImage(imageUrl) {
  try {
    const response = await fetch(imageUrl, {
      mode: 'cors'
    });
    
    if (!response.ok) {
      throw new Error(`Failed to fetch image: ${response.status}`);
    }
    
    const blob = await response.blob();
    const filename = imageUrl.split('/').pop().split('?')[0] || 'image.jpg';
    const file = new File([blob], filename, { type: blob.type });
    
    return await uploadFile(file);
    
  } catch (error) {
    console.error('Image download failed:', error);
    throw error;
  }
}
```

### Directory Drop Handling

#### Recursive Directory Traversal

```javascript
async function handleDirectoryDrop(item) {
  const files = [];
  
  async function traverseDirectory(directoryReader, path = '') {
    const entries = await new Promise((resolve, reject) => {
      directoryReader.readEntries(resolve, reject);
    });
    
    for (const entry of entries) {
      if (entry.isFile) {
        const file = await new Promise((resolve, reject) => {
          entry.file(resolve, reject);
        });
        
        // Preserve directory structure
        Object.defineProperty(file, 'webkitRelativePath', {
          value: path + file.name
        });
        
        files.push(file);
      } else if (entry.isDirectory) {
        const reader = entry.createReader();
        await traverseDirectory(reader, path + entry.name + '/');
      }
    }
    
    // Continue reading if there are more entries
    if (entries.length > 0) {
      await traverseDirectory(directoryReader, path);
    }
  }
  
  if (item.isDirectory) {
    const reader = item.createReader();
    await traverseDirectory(reader);
  }
  
  return files;
}

dropZone.addEventListener('drop', async (e) => {
  e.preventDefault();
  const items = Array.from(e.dataTransfer.items);
  const allFiles = [];
  
  for (const item of items) {
    if (item.kind === 'file') {
      const entry = item.webkitGetAsEntry();
      
      if (entry.isDirectory) {
        const dirFiles = await handleDirectoryDrop(entry);
        allFiles.push(...dirFiles);
      } else {
        allFiles.push(item.getAsFile());
      }
    }
  }
  
  await uploadMultipleFiles(allFiles);
});
```

### Abort and Cancellation

#### AbortController Integration

```javascript
class UploadManager {
  constructor() {
    this.controllers = new Map();
  }
  
  async upload(file) {
    const controller = new AbortController();
    const uploadId = `${file.name}-${Date.now()}`;
    
    this.controllers.set(uploadId, controller);
    
    try {
      const formData = new FormData();
      formData.append('file', file);
      
      const response = await fetch('/upload', {
        method: 'POST',
        body: formData,
        signal: controller.signal
      });
      
      if (!response.ok) {
        throw new Error(`Upload failed: ${response.status}`);
      }
      
      return await response.json();
      
    } catch (error) {
      if (error.name === 'AbortError') {
        console.log(`Upload cancelled: ${file.name}`);
        return null;
      }
      throw error;
      
    } finally {
      this.controllers.delete(uploadId);
    }
  }
  
  cancel(uploadId) {
    const controller = this.controllers.get(uploadId);
    if (controller) {
      controller.abort();
    }
  }
  
  cancelAll() {
    this.controllers.forEach(controller => controller.abort());
    this.controllers.clear();
  }
}

const uploadManager = new UploadManager();

dropZone.addEventListener('drop', async (e) => {
  e.preventDefault();
  const files = Array.from(e.dataTransfer.files);
  
  for (const file of files) {
    uploadManager.upload(file);
  }
});

cancelButton.addEventListener('click', () => {
  uploadManager.cancelAll();
});
```

### Security Considerations

#### Content Security Policy Headers

```javascript
async function uploadWithCSRF(file) {
  // Retrieve CSRF token from meta tag or cookie
  const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content;
  
  const formData = new FormData();
  formData.append('file', file);
  
  const response = await fetch('/upload', {
    method: 'POST',
    headers: {
      'X-CSRF-Token': csrfToken
    },
    body: formData,
    credentials: 'same-origin' // Include cookies
  });
  
  return response.json();
}
```

#### File Name Sanitization

```javascript
function sanitizeFilename(filename) {
  // Remove path traversal attempts
  filename = filename.replace(/^.*[\\\/]/, '');
  
  // Remove potentially dangerous characters
  filename = filename.replace(/[^a-zA-Z0-9._-]/g, '_');
  
  // Limit length
  const maxLength = 255;
  if (filename.length > maxLength) {
    const ext = filename.split('.').pop();
    const name = filename.substring(0, maxLength - ext.length - 1);
    filename = `${name}.${ext}`;
  }
  
  return filename;
}

async function uploadSafeFile(file) {
  const safeFilename = sanitizeFilename(file.name);
  const safeFile = new File([file], safeFilename, { type: file.type });
  
  return uploadFile(safeFile);
}
```

### Performance Optimization

#### File Reading Optimization

```javascript
async function optimizeImageBeforeUpload(file, maxWidth = 1920, maxHeight = 1080, quality = 0.85) {
  if (!file.type.startsWith('image/')) {
    return file;
  }
  
  return new Promise((resolve) => {
    const img = new Image();
    const canvas = document.createElement('canvas');
    const ctx = canvas.getContext('2d');
    
    img.onload = () => {
      let { width, height } = img;
      
      if (width > maxWidth || height > maxHeight) {
        const ratio = Math.min(maxWidth / width, maxHeight / height);
        width *= ratio;
        height *= ratio;
      }
      
      canvas.width = width;
      canvas.height = height;
      ctx.drawImage(img, 0, 0, width, height);
      
      canvas.toBlob(
        (blob) => {
          const optimizedFile = new File([blob], file.name, {
            type: 'image/jpeg',
            lastModified: Date.now()
          });
          resolve(optimizedFile);
        },
        'image/jpeg',
        quality
      );
    };
    
    img.src = URL.createObjectURL(file);
  });
}

dropZone.addEventListener('drop', async (e) => {
  e.preventDefault();
  const files = Array.from(e.dataTransfer.files);
  
  for (const file of files) {
    const optimized = await optimizeImageBeforeUpload(file);
    await uploadFile(optimized);
  }
});
```

#### Memory Management for Large Files

```javascript
async function uploadLargeFile(file) {
  const chunkSize = 5 * 1024 * 1024; // 5MB chunks
  const chunks = Math.ceil(file.size / chunkSize);
  
  for (let i = 0; i < chunks; i++) {
    const start = i * chunkSize;
    const end = Math.min(start + chunkSize, file.size);
    const chunk = file.slice(start, end);
    
    const formData = new FormData();
    formData.append('chunk', chunk);
    formData.append('chunkIndex', i.toString());
    formData.append('totalChunks', chunks.toString());
    formData.append('filename', file.name);
    
    await fetch('/upload/chunk', {
      method: 'POST',
      body: formData
    });
    
    // Chunk goes out of scope and can be garbage collected
  }
  
  // Finalize
  await fetch('/upload/complete', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ filename: file.name, totalChunks: chunks })
  });
}
```

### Authentication and Authorization

#### Token-Based Upload

```javascript
async function uploadWithAuth(file, accessToken) {
  const formData = new FormData();
  formData.append('file', file);
  
  const response = await fetch('/upload', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${accessToken}`
    },
    body: formData
  });
  
  if (response.status === 401) {
    // Token expired, refresh and retry
    const newToken = await refreshAccessToken();
    return uploadWithAuth(file, newToken);
  }
  
  return response.json();
}

async function refreshAccessToken() {
  const response = await fetch('/auth/refresh', {
    method: 'POST',
    credentials: 'include'
  });
  
  const data = await response.json();
  return data.accessToken;
}
```

#### Pre-signed URL Upload

```javascript
async function uploadToPresignedUrl(file) {
  // Get pre-signed URL from your server
  const urlResponse = await fetch('/upload/presigned-url', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      filename: file.name,
      contentType: file.type,
      size: file.size
    })
  });
  
  const { uploadUrl, key } = await urlResponse.json();
  
  // Upload directly to storage (e.g., S3)
  const uploadResponse = await fetch(uploadUrl, {
    method: 'PUT',
    headers: {
      'Content-Type': file.type
    },
    body: file
  });
  
  if (!uploadResponse.ok) {
    throw new Error(`Upload to storage failed: ${uploadResponse.status}`);
  }
  
  // Confirm upload with your server
  await fetch('/upload/confirm', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ key, filename: file.name })
  });
  
  return { key, filename: file.name };
}
```

### Cross-Browser Compatibility

#### Feature Detection

```javascript
function checkDragDropSupport() {
  const div = document.createElement('div');
  const support = {
    dragAndDrop: ('draggable' in div) || ('ondragstart' in div && 'ondrop' in div),
    fileAPI: 'FileReader' in window,
    formData: 'FormData' in window,
    fetch: 'fetch' in window
  };
  
  return support;
}

const support = checkDragDropSupport();

if (!support.dragAndDrop) {
  // Fallback to input file element
  showFileInputFallback();
} else {
  initializeDragDrop();
}
```

#### Polyfill Strategy

```javascript
// Check for fetch support
if (!window.fetch) {
  // Load fetch polyfill
  const script = document.createElement('script');
  script.src = 'https://cdnjs.cloudflare.com/ajax/libs/fetch/3.6.2/fetch.min.js';
  document.head.appendChild(script);
}

// Fallback for older browsers
function uploadWithXHR(file) {
  return new Promise((resolve, reject) => {
    const xhr = new XMLHttpRequest();
    const formData = new FormData();
    formData.append('file', file);
    
    xhr.onload = () => {
      if (xhr.status >= 200 && xhr.status < 300) {
        resolve(JSON.parse(xhr.responseText));
      } else {
        reject(new Error(`Upload failed: ${xhr.status}`));
      }
    };
    
    xhr.onerror = () => reject(new Error('Network error'));
    xhr.open('POST', '/upload');
    xhr.send(formData);
  });
}

// Use appropriate method
const uploadMethod = window.fetch ? uploadFile : uploadWithXHR;
```

### Testing Strategies

#### Mock File Creation for Testing

```javascript
function createMockFile(name, size, type) {
  const content = new Array(size).fill('a').join('');
  const blob = new Blob([content], { type });
  return new File([blob], name, { type, lastModified: Date.now() });
}

// Simulate drop event
function simulateFileDrop(element, files) {
  const dataTransfer = new DataTransfer();
  
  files.forEach(file => {
    dataTransfer.items.add(file);
  });
  
  const dropEvent = new DragEvent('drop', {
    bubbles: true,
    cancelable: true,
    dataTransfer
  });
  
  element.dispatchEvent(dropEvent);
}

// Test usage
const testFile = createMockFile('test.jpg', 1024 * 1024, 'image/jpeg');
simulateFileDrop(dropZone, [testFile]);
```

#### Integration Test Example

```javascript
async function testDragDropUpload() {
  const testFile = createMockFile('test-image.png', 2048, 'image/png');
  
  // Mock fetch
  global.fetch = jest.fn(() =>
    Promise.resolve({
      ok: true,
      json: () => Promise.resolve({ id: '123', url: '/files/123' })
    })
  );
  
  // Simulate drop
  const files = [testFile];
  const result = await uploadMultipleFiles(files);
  
  expect(fetch).toHaveBeenCalledWith('/upload/multiple', {
    method: 'POST',
    body: expect.any(FormData)
  });
  
  expect(result).toHaveProperty('id');
}
```

---

