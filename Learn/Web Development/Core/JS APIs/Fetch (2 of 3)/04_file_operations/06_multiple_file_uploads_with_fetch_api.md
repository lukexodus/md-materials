## Multiple File Uploads with Fetch API


### Handling Multiple File Inputs

When uploading multiple files using the fetch API, you work with `<input type="file" multiple>` elements. The `files` property of the input returns a `FileList` object containing all selected files.

```javascript
const input = document.querySelector('input[type="file"]');
const files = input.files; // FileList object

// Iterate through files
for (let i = 0; i < files.length; i++) {
  console.log(files[i].name, files[i].size);
}
```

### Using FormData for Multiple Files

FormData is the standard approach for sending multiple files. You can append multiple files to the same field name or use different field names.

#### Same Field Name (Array-style)

```javascript
const formData = new FormData();
const fileInput = document.querySelector('input[type="file"]');

// Append all files to the same field name
for (const file of fileInput.files) {
  formData.append('files[]', file);
}

fetch('/upload', {
  method: 'POST',
  body: formData
});
```

#### Different Field Names

```javascript
const formData = new FormData();

formData.append('document', files[0]);
formData.append('image', files[1]);
formData.append('attachment', files[2]);

fetch('/upload', {
  method: 'POST',
  body: formData
});
```

### Complete Upload Implementation

```javascript
async function uploadMultipleFiles(files) {
  const formData = new FormData();
  
  // Append each file
  Array.from(files).forEach((file, index) => {
    formData.append('files[]', file);
    // Or use indexed names: formData.append(`file_${index}`, file);
  });
  
  // Add additional metadata
  formData.append('userId', '12345');
  formData.append('uploadDate', new Date().toISOString());
  
  try {
    const response = await fetch('/api/upload', {
      method: 'POST',
      body: formData
      // Note: Do NOT set Content-Type header manually
      // Browser sets it automatically with boundary parameter
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

### Progress Tracking with XMLHttpRequest

[Note: Fetch API does not natively support upload progress tracking. This requires XMLHttpRequest.]

```javascript
function uploadWithProgress(files, onProgress) {
  return new Promise((resolve, reject) => {
    const xhr = new XMLHttpRequest();
    const formData = new FormData();
    
    Array.from(files).forEach(file => {
      formData.append('files[]', file);
    });
    
    // Track upload progress
    xhr.upload.addEventListener('progress', (e) => {
      if (e.lengthComputable) {
        const percentComplete = (e.loaded / e.total) * 100;
        onProgress(percentComplete, e.loaded, e.total);
      }
    });
    
    xhr.addEventListener('load', () => {
      if (xhr.status >= 200 && xhr.status < 300) {
        resolve(JSON.parse(xhr.responseText));
      } else {
        reject(new Error(`Upload failed: ${xhr.status}`));
      }
    });
    
    xhr.addEventListener('error', () => {
      reject(new Error('Network error'));
    });
    
    xhr.open('POST', '/api/upload');
    xhr.send(formData);
  });
}

// Usage
uploadWithProgress(files, (percent, loaded, total) => {
  console.log(`${percent.toFixed(2)}% (${loaded}/${total} bytes)`);
});
```

### File Validation Before Upload

```javascript
function validateFiles(files, options = {}) {
  const {
    maxSize = 10 * 1024 * 1024, // 10MB default
    maxFiles = 10,
    allowedTypes = ['image/jpeg', 'image/png', 'application/pdf']
  } = options;
  
  const errors = [];
  
  // Check file count
  if (files.length > maxFiles) {
    errors.push(`Maximum ${maxFiles} files allowed`);
  }
  
  // Validate each file
  Array.from(files).forEach((file, index) => {
    // Check file size
    if (file.size > maxSize) {
      errors.push(`File ${index + 1} (${file.name}) exceeds ${maxSize / 1024 / 1024}MB`);
    }
    
    // Check file type
    if (!allowedTypes.includes(file.type)) {
      errors.push(`File ${index + 1} (${file.name}) has invalid type: ${file.type}`);
    }
  });
  
  return {
    valid: errors.length === 0,
    errors
  };
}

// Usage
const validation = validateFiles(fileInput.files, {
  maxSize: 5 * 1024 * 1024, // 5MB
  maxFiles: 5,
  allowedTypes: ['image/jpeg', 'image/png']
});

if (validation.valid) {
  await uploadMultipleFiles(fileInput.files);
} else {
  console.error('Validation errors:', validation.errors);
}
```

### Concurrent vs Sequential Uploads

#### Sequential Uploads

```javascript
async function uploadSequentially(files) {
  const results = [];
  
  for (const file of files) {
    const formData = new FormData();
    formData.append('file', file);
    
    const response = await fetch('/api/upload', {
      method: 'POST',
      body: formData
    });
    
    results.push(await response.json());
  }
  
  return results;
}
```

#### Concurrent Uploads

```javascript
async function uploadConcurrently(files) {
  const uploadPromises = Array.from(files).map(file => {
    const formData = new FormData();
    formData.append('file', file);
    
    return fetch('/api/upload', {
      method: 'POST',
      body: formData
    }).then(res => res.json());
  });
  
  return Promise.all(uploadPromises);
}
```

#### Controlled Concurrency (Chunked)

```javascript
async function uploadWithConcurrencyLimit(files, limit = 3) {
  const results = [];
  const fileArray = Array.from(files);
  
  for (let i = 0; i < fileArray.length; i += limit) {
    const chunk = fileArray.slice(i, i + limit);
    const chunkResults = await Promise.all(
      chunk.map(file => {
        const formData = new FormData();
        formData.append('file', file);
        
        return fetch('/api/upload', {
          method: 'POST',
          body: formData
        }).then(res => res.json());
      })
    );
    
    results.push(...chunkResults);
  }
  
  return results;
}
```

### Handling Upload Errors and Retries

```javascript
async function uploadWithRetry(file, maxRetries = 3) {
  let lastError;
  
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      const formData = new FormData();
      formData.append('file', file);
      
      const response = await fetch('/api/upload', {
        method: 'POST',
        body: formData
      });
      
      if (!response.ok) {
        throw new Error(`HTTP ${response.status}`);
      }
      
      return await response.json();
    } catch (error) {
      lastError = error;
      console.warn(`Upload attempt ${attempt} failed:`, error);
      
      if (attempt < maxRetries) {
        // Exponential backoff
        await new Promise(resolve => 
          setTimeout(resolve, Math.pow(2, attempt) * 1000)
        );
      }
    }
  }
  
  throw new Error(`Upload failed after ${maxRetries} attempts: ${lastError.message}`);
}

async function uploadMultipleWithRetry(files) {
  const results = await Promise.allSettled(
    Array.from(files).map(file => uploadWithRetry(file))
  );
  
  const successful = results.filter(r => r.status === 'fulfilled');
  const failed = results.filter(r => r.status === 'rejected');
  
  return {
    successful: successful.map(r => r.value),
    failed: failed.map(r => r.reason)
  };
}
```

### Chunked File Uploads for Large Files

```javascript
async function uploadFileInChunks(file, chunkSize = 1024 * 1024) { // 1MB chunks
  const chunks = Math.ceil(file.size / chunkSize);
  const uploadId = Date.now().toString();
  
  for (let i = 0; i < chunks; i++) {
    const start = i * chunkSize;
    const end = Math.min(start + chunkSize, file.size);
    const chunk = file.slice(start, end);
    
    const formData = new FormData();
    formData.append('chunk', chunk);
    formData.append('fileName', file.name);
    formData.append('uploadId', uploadId);
    formData.append('chunkIndex', i);
    formData.append('totalChunks', chunks);
    
    const response = await fetch('/api/upload/chunk', {
      method: 'POST',
      body: formData
    });
    
    if (!response.ok) {
      throw new Error(`Chunk ${i} upload failed`);
    }
  }
  
  // Finalize upload
  const finalResponse = await fetch('/api/upload/finalize', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      uploadId,
      fileName: file.name,
      totalChunks: chunks
    })
  });
  
  return finalResponse.json();
}
```

### Resumable Uploads

```javascript
class ResumableUpload {
  constructor(file, endpoint) {
    this.file = file;
    this.endpoint = endpoint;
    this.chunkSize = 1024 * 1024; // 1MB
    this.uploadedChunks = new Set();
    this.uploadId = null;
  }
  
  async start() {
    // Initialize upload session
    const initResponse = await fetch(`${this.endpoint}/init`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        fileName: this.file.name,
        fileSize: this.file.size,
        totalChunks: Math.ceil(this.file.size / this.chunkSize)
      })
    });
    
    const { uploadId, uploadedChunks } = await initResponse.json();
    this.uploadId = uploadId;
    this.uploadedChunks = new Set(uploadedChunks || []);
    
    await this.uploadChunks();
  }
  
  async uploadChunks() {
    const totalChunks = Math.ceil(this.file.size / this.chunkSize);
    
    for (let i = 0; i < totalChunks; i++) {
      if (this.uploadedChunks.has(i)) {
        continue; // Skip already uploaded chunks
      }
      
      const start = i * this.chunkSize;
      const end = Math.min(start + this.chunkSize, this.file.size);
      const chunk = this.file.slice(start, end);
      
      const formData = new FormData();
      formData.append('chunk', chunk);
      formData.append('uploadId', this.uploadId);
      formData.append('chunkIndex', i);
      
      await fetch(`${this.endpoint}/chunk`, {
        method: 'POST',
        body: formData
      });
      
      this.uploadedChunks.add(i);
    }
    
    // Finalize
    await fetch(`${this.endpoint}/finalize`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ uploadId: this.uploadId })
    });
  }
}

// Usage
const uploader = new ResumableUpload(file, '/api/upload');
await uploader.start();
```

### Drag and Drop Multiple Files

```javascript
const dropZone = document.getElementById('dropZone');

dropZone.addEventListener('dragover', (e) => {
  e.preventDefault();
  dropZone.classList.add('drag-over');
});

dropZone.addEventListener('dragleave', () => {
  dropZone.classList.remove('drag-over');
});

dropZone.addEventListener('drop', async (e) => {
  e.preventDefault();
  dropZone.classList.remove('drag-over');
  
  const files = Array.from(e.dataTransfer.files);
  
  // Handle directories if needed
  const items = e.dataTransfer.items;
  if (items) {
    const allFiles = [];
    
    for (const item of items) {
      if (item.kind === 'file') {
        const entry = item.webkitGetAsEntry();
        if (entry.isDirectory) {
          const dirFiles = await readDirectory(entry);
          allFiles.push(...dirFiles);
        } else {
          allFiles.push(item.getAsFile());
        }
      }
    }
    
    await uploadMultipleFiles(allFiles);
  } else {
    await uploadMultipleFiles(files);
  }
});

async function readDirectory(directoryEntry) {
  const files = [];
  const reader = directoryEntry.createReader();
  
  return new Promise((resolve) => {
    const readEntries = () => {
      reader.readEntries(async (entries) => {
        if (entries.length === 0) {
          resolve(files);
          return;
        }
        
        for (const entry of entries) {
          if (entry.isFile) {
            const file = await new Promise(res => entry.file(res));
            files.push(file);
          } else if (entry.isDirectory) {
            const dirFiles = await readDirectory(entry);
            files.push(...dirFiles);
          }
        }
        
        readEntries(); // Continue reading
      });
    };
    
    readEntries();
  });
}
```

### Response Handling and Status Updates

```javascript
async function uploadWithStatusUpdates(files, onUpdate) {
  const totalFiles = files.length;
  let completed = 0;
  
  onUpdate({ stage: 'starting', completed: 0, total: totalFiles });
  
  const results = [];
  
  for (const file of files) {
    onUpdate({ 
      stage: 'uploading', 
      currentFile: file.name,
      completed, 
      total: totalFiles 
    });
    
    try {
      const formData = new FormData();
      formData.append('file', file);
      
      const response = await fetch('/api/upload', {
        method: 'POST',
        body: formData
      });
      
      const result = await response.json();
      results.push({ file: file.name, success: true, data: result });
      
      completed++;
      onUpdate({ 
        stage: 'uploading', 
        completed, 
        total: totalFiles,
        lastCompleted: file.name
      });
    } catch (error) {
      results.push({ file: file.name, success: false, error: error.message });
      completed++;
    }
  }
  
  onUpdate({ stage: 'complete', completed: totalFiles, total: totalFiles, results });
  
  return results;
}

// Usage
await uploadWithStatusUpdates(files, (status) => {
  if (status.stage === 'uploading') {
    console.log(`Uploading ${status.currentFile} (${status.completed}/${status.total})`);
  } else if (status.stage === 'complete') {
    console.log('All uploads complete:', status.results);
  }
});
```

### Abort Multiple Uploads

```javascript
class MultiFileUploader {
  constructor() {
    this.controllers = new Map();
  }
  
  async uploadFile(file, fileId) {
    const controller = new AbortController();
    this.controllers.set(fileId, controller);
    
    const formData = new FormData();
    formData.append('file', file);
    
    try {
      const response = await fetch('/api/upload', {
        method: 'POST',
        body: formData,
        signal: controller.signal
      });
      
      return await response.json();
    } finally {
      this.controllers.delete(fileId);
    }
  }
  
  async uploadAll(files) {
    const uploads = Array.from(files).map((file, index) => {
      const fileId = `file_${index}`;
      return this.uploadFile(file, fileId);
    });
    
    return Promise.allSettled(uploads);
  }
  
  abort(fileId) {
    const controller = this.controllers.get(fileId);
    if (controller) {
      controller.abort();
    }
  }
  
  abortAll() {
    this.controllers.forEach(controller => controller.abort());
    this.controllers.clear();
  }
}

// Usage
const uploader = new MultiFileUploader();

// Start uploads
const uploadPromise = uploader.uploadAll(files);

// Cancel all uploads
uploader.abortAll();
```

### Memory Management for Large File Sets

```javascript
async function uploadLargeFileSet(files) {
  // Process files in batches to avoid memory issues
  const BATCH_SIZE = 5;
  const results = [];
  
  for (let i = 0; i < files.length; i += BATCH_SIZE) {
    const batch = Array.from(files).slice(i, i + BATCH_SIZE);
    
    const batchResults = await Promise.all(
      batch.map(async (file) => {
        const formData = new FormData();
        formData.append('file', file);
        
        const response = await fetch('/api/upload', {
          method: 'POST',
          body: formData
        });
        
        return response.json();
      })
    );
    
    results.push(...batchResults);
    
    // Allow garbage collection between batches
    await new Promise(resolve => setTimeout(resolve, 100));
  }
  
  return results;
}
```

---

