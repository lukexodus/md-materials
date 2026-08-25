## File Validation with Fetch API


### Client-Side Validation Before Upload

#### MIME Type Validation

Validate file types using the `type` property from File objects before sending via fetch:

```javascript
const allowedTypes = ['image/jpeg', 'image/png', 'application/pdf'];
const file = input.files[0];

if (!allowedTypes.includes(file.type)) {
  throw new Error(`Invalid file type: ${file.type}`);
}
```

**Critical limitation**: MIME types are user-controllable and should never be trusted as the sole validation mechanism. Browsers determine MIME types from file extensions, which can be spoofed.

#### Extension-Based Validation

```javascript
const allowedExtensions = ['.jpg', '.jpeg', '.png', '.pdf'];
const fileName = file.name.toLowerCase();
const hasValidExtension = allowedExtensions.some(ext => fileName.endsWith(ext));

if (!hasValidExtension) {
  throw new Error('Invalid file extension');
}
```

Combine with MIME type checking for defense-in-depth:

```javascript
function validateFileType(file, config) {
  const ext = file.name.toLowerCase().match(/\.[^.]+$/)?.[0];
  const expectedMime = config.extensionToMime[ext];
  
  return ext && 
         config.allowedExtensions.includes(ext) &&
         file.type === expectedMime;
}
```

#### File Size Validation

```javascript
const maxSize = 5 * 1024 * 1024; // 5MB
if (file.size > maxSize) {
  throw new Error(`File too large: ${(file.size / 1024 / 1024).toFixed(2)}MB`);
}

if (file.size === 0) {
  throw new Error('Empty file not allowed');
}
```

### Magic Number (File Signature) Validation

Validate actual file content by reading magic bytes—the most reliable client-side validation method:

```javascript
async function validateFileSignature(file, expectedSignatures) {
  const buffer = await file.slice(0, 8).arrayBuffer();
  const bytes = new Uint8Array(buffer);
  const signature = Array.from(bytes)
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');
  
  return expectedSignatures.some(sig => 
    signature.toLowerCase().startsWith(sig.toLowerCase())
  );
}

// Usage
const jpegSignatures = ['ffd8ffe0', 'ffd8ffe1', 'ffd8ffe2'];
const pngSignature = ['89504e47'];

const isValidJpeg = await validateFileSignature(file, jpegSignatures);
```

Common file signatures:

- JPEG: `FF D8 FF`
- PNG: `89 50 4E 47 0D 0A 1A 0A`
- PDF: `25 50 44 46` (%PDF)
- GIF: `47 49 46 38` (GIF8)
- ZIP: `50 4B 03 04` or `50 4B 05 06`

### Dimension Validation for Images

```javascript
async function validateImageDimensions(file, maxWidth, maxHeight) {
  return new Promise((resolve, reject) => {
    const img = new Image();
    const url = URL.createObjectURL(file);
    
    img.onload = () => {
      URL.revokeObjectURL(url);
      if (img.width > maxWidth || img.height > maxHeight) {
        reject(new Error(`Image dimensions ${img.width}x${img.height} exceed limit`));
      } else {
        resolve({ width: img.width, height: img.height });
      }
    };
    
    img.onerror = () => {
      URL.revokeObjectURL(url);
      reject(new Error('Failed to load image'));
    };
    
    img.src = url;
  });
}
```

Validate aspect ratio:

```javascript
function validateAspectRatio(width, height, expectedRatio, tolerance = 0.01) {
  const actualRatio = width / height;
  return Math.abs(actualRatio - expectedRatio) <= tolerance;
}
```

### Content Validation

#### Image Content Analysis

Detect corrupt images by attempting to decode:

```javascript
async function validateImageIntegrity(file) {
  const bitmap = await createImageBitmap(file);
  bitmap.close();
  return true; // Will throw if corrupt
}
```

#### Text File Content Validation

```javascript
async function validateTextContent(file, maxLines, maxLineLength) {
  const text = await file.text();
  const lines = text.split('\n');
  
  if (lines.length > maxLines) {
    throw new Error(`Too many lines: ${lines.length}`);
  }
  
  const longLine = lines.find(line => line.length > maxLineLength);
  if (longLine) {
    throw new Error(`Line exceeds maximum length`);
  }
  
  return text;
}
```

Validate character encoding:

```javascript
async function validateUTF8(file) {
  const buffer = await file.arrayBuffer();
  const decoder = new TextDecoder('utf-8', { fatal: true });
  
  try {
    decoder.decode(buffer);
    return true;
  } catch (e) {
    throw new Error('Invalid UTF-8 encoding');
  }
}
```

### Sending Validated Files with Fetch

#### FormData Approach

```javascript
async function uploadValidatedFile(file, endpoint) {
  // Perform all validations
  await validateFileSignature(file, expectedSignatures);
  if (file.size > maxSize) throw new Error('File too large');
  
  const formData = new FormData();
  formData.append('file', file);
  formData.append('originalName', file.name);
  formData.append('clientValidated', 'true');
  
  const response = await fetch(endpoint, {
    method: 'POST',
    body: formData
    // Note: Don't set Content-Type header; browser sets it with boundary
  });
  
  if (!response.ok) {
    const error = await response.json();
    throw new Error(error.message || 'Upload failed');
  }
  
  return response.json();
}
```

#### Multiple File Upload with Validation

```javascript
async function uploadMultipleFiles(files, endpoint) {
  const validationResults = await Promise.allSettled(
    files.map(file => validateFile(file))
  );
  
  const validFiles = validationResults
    .map((result, index) => result.status === 'fulfilled' ? files[index] : null)
    .filter(Boolean);
  
  const failedFiles = validationResults
    .map((result, index) => result.status === 'rejected' ? {
      file: files[index].name,
      error: result.reason.message
    } : null)
    .filter(Boolean);
  
  if (validFiles.length === 0) {
    throw new Error('No valid files to upload');
  }
  
  const formData = new FormData();
  validFiles.forEach((file, index) => {
    formData.append(`files[${index}]`, file);
  });
  
  const response = await fetch(endpoint, {
    method: 'POST',
    body: formData
  });
  
  return {
    uploaded: await response.json(),
    failed: failedFiles
  };
}
```

### Server Response Validation

#### Handling Server-Side Validation Errors

```javascript
async function handleUploadWithServerValidation(file, endpoint) {
  const formData = new FormData();
  formData.append('file', file);
  
  const response = await fetch(endpoint, {
    method: 'POST',
    body: formData
  });
  
  const data = await response.json();
  
  if (!response.ok) {
    // Parse structured validation errors
    if (data.validationErrors) {
      const errors = data.validationErrors.map(err => 
        `${err.field}: ${err.message}`
      ).join(', ');
      throw new Error(`Validation failed: ${errors}`);
    }
    throw new Error(data.message || 'Upload failed');
  }
  
  // Verify server response contains expected fields
  if (!data.fileId || !data.url) {
    throw new Error('Invalid server response');
  }
  
  return data;
}
```

#### Validating File URL from Server

```javascript
async function validateUploadedFile(fileUrl, expectedMime) {
  const response = await fetch(fileUrl, { method: 'HEAD' });
  
  const contentType = response.headers.get('content-type');
  const contentLength = parseInt(response.headers.get('content-length'));
  
  if (!contentType.startsWith(expectedMime)) {
    throw new Error(`Unexpected content type: ${contentType}`);
  }
  
  if (contentLength === 0) {
    throw new Error('Uploaded file is empty');
  }
  
  return { contentType, contentLength };
}
```

### Chunked Upload with Validation

For large files, validate chunks before and during upload:

```javascript
async function uploadFileInChunks(file, endpoint, chunkSize = 1024 * 1024) {
  // Initial validation
  await validateFile(file);
  
  const totalChunks = Math.ceil(file.size / chunkSize);
  const fileId = crypto.randomUUID();
  
  for (let chunkIndex = 0; chunkIndex < totalChunks; chunkIndex++) {
    const start = chunkIndex * chunkSize;
    const end = Math.min(start + chunkSize, file.size);
    const chunk = file.slice(start, end);
    
    // Validate chunk
    if (chunk.size === 0) {
      throw new Error(`Invalid chunk at index ${chunkIndex}`);
    }
    
    const formData = new FormData();
    formData.append('chunk', chunk);
    formData.append('chunkIndex', chunkIndex);
    formData.append('totalChunks', totalChunks);
    formData.append('fileId', fileId);
    formData.append('fileName', file.name);
    
    const response = await fetch(endpoint, {
      method: 'POST',
      body: formData
    });
    
    if (!response.ok) {
      throw new Error(`Chunk ${chunkIndex} upload failed`);
    }
    
    const result = await response.json();
    
    // Validate server received correct chunk
    if (result.chunkIndex !== chunkIndex) {
      throw new Error('Chunk index mismatch');
    }
  }
  
  // Finalize upload
  return await fetch(`${endpoint}/finalize`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ fileId, fileName: file.name })
  }).then(r => r.json());
}
```

### Checksum Validation

Validate file integrity using checksums:

```javascript
async function calculateChecksum(file, algorithm = 'SHA-256') {
  const buffer = await file.arrayBuffer();
  const hashBuffer = await crypto.subtle.digest(algorithm, buffer);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
}

async function uploadWithChecksum(file, endpoint) {
  const checksum = await calculateChecksum(file);
  
  const formData = new FormData();
  formData.append('file', file);
  formData.append('checksum', checksum);
  formData.append('algorithm', 'SHA-256');
  
  const response = await fetch(endpoint, {
    method: 'POST',
    body: formData
  });
  
  const data = await response.json();
  
  // Verify server calculated same checksum
  if (data.checksum !== checksum) {
    throw new Error('Checksum mismatch - file may be corrupted');
  }
  
  return data;
}
```

### Virus Scanning Integration

Handle virus scanning during upload:

```javascript
async function uploadWithVirusScan(file, endpoint) {
  const formData = new FormData();
  formData.append('file', file);
  
  const response = await fetch(endpoint, {
    method: 'POST',
    body: formData
  });
  
  const data = await response.json();
  
  if (data.scanStatus === 'infected') {
    throw new Error(`File infected: ${data.threatName}`);
  }
  
  if (data.scanStatus === 'pending') {
    // Poll for scan results
    return await pollScanResults(data.scanId);
  }
  
  return data;
}

async function pollScanResults(scanId, maxAttempts = 30) {
  for (let i = 0; i < maxAttempts; i++) {
    await new Promise(resolve => setTimeout(resolve, 2000));
    
    const response = await fetch(`/api/scan-status/${scanId}`);
    const data = await response.json();
    
    if (data.status === 'clean') return data;
    if (data.status === 'infected') throw new Error('File infected');
  }
  
  throw new Error('Scan timeout');
}
```

### Comprehensive Validation Pipeline

```javascript
class FileValidator {
  constructor(config) {
    this.config = {
      maxSize: config.maxSize || 10 * 1024 * 1024,
      allowedTypes: config.allowedTypes || [],
      allowedExtensions: config.allowedExtensions || [],
      magicNumbers: config.magicNumbers || {},
      checkDimensions: config.checkDimensions || false,
      maxWidth: config.maxWidth,
      maxHeight: config.maxHeight,
      calculateChecksum: config.calculateChecksum || false
    };
  }
  
  async validate(file) {
    const errors = [];
    
    // Size validation
    if (file.size > this.config.maxSize) {
      errors.push(`File size ${file.size} exceeds maximum ${this.config.maxSize}`);
    }
    
    if (file.size === 0) {
      errors.push('File is empty');
    }
    
    // Type validation
    if (this.config.allowedTypes.length > 0 && 
        !this.config.allowedTypes.includes(file.type)) {
      errors.push(`File type ${file.type} not allowed`);
    }
    
    // Extension validation
    const ext = file.name.toLowerCase().match(/\.[^.]+$/)?.[0];
    if (this.config.allowedExtensions.length > 0 && 
        !this.config.allowedExtensions.includes(ext)) {
      errors.push(`File extension ${ext} not allowed`);
    }
    
    // Magic number validation
    if (this.config.magicNumbers[ext]) {
      try {
        const isValid = await validateFileSignature(
          file, 
          this.config.magicNumbers[ext]
        );
        if (!isValid) {
          errors.push('File signature does not match extension');
        }
      } catch (e) {
        errors.push(`Signature validation failed: ${e.message}`);
      }
    }
    
    // Image dimension validation
    if (this.config.checkDimensions && file.type.startsWith('image/')) {
      try {
        await validateImageDimensions(
          file, 
          this.config.maxWidth, 
          this.config.maxHeight
        );
      } catch (e) {
        errors.push(e.message);
      }
    }
    
    if (errors.length > 0) {
      throw new Error(`Validation failed: ${errors.join('; ')}`);
    }
    
    // Calculate checksum if needed
    let checksum;
    if (this.config.calculateChecksum) {
      checksum = await calculateChecksum(file);
    }
    
    return {
      valid: true,
      file,
      checksum,
      metadata: {
        name: file.name,
        size: file.size,
        type: file.type,
        lastModified: file.lastModified
      }
    };
  }
  
  async validateAndUpload(file, endpoint) {
    const result = await this.validate(file);
    
    const formData = new FormData();
    formData.append('file', file);
    
    if (result.checksum) {
      formData.append('checksum', result.checksum);
    }
    
    const response = await fetch(endpoint, {
      method: 'POST',
      body: formData
    });
    
    if (!response.ok) {
      const error = await response.json();
      throw new Error(error.message || 'Upload failed');
    }
    
    return response.json();
  }
}

// Usage
const validator = new FileValidator({
  maxSize: 5 * 1024 * 1024,
  allowedTypes: ['image/jpeg', 'image/png'],
  allowedExtensions: ['.jpg', '.jpeg', '.png'],
  magicNumbers: {
    '.jpg': ['ffd8ffe0', 'ffd8ffe1'],
    '.jpeg': ['ffd8ffe0', 'ffd8ffe1'],
    '.png': ['89504e47']
  },
  checkDimensions: true,
  maxWidth: 4096,
  maxHeight: 4096,
  calculateChecksum: true
});

try {
  const result = await validator.validateAndUpload(file, '/api/upload');
  console.log('Upload successful:', result);
} catch (error) {
  console.error('Validation/upload failed:', error.message);
}
```

### Error Recovery and Retry Logic

```javascript
async function uploadWithRetry(file, endpoint, maxRetries = 3) {
  let lastError;
  
  for (let attempt = 0; attempt < maxRetries; attempt++) {
    try {
      // Revalidate before each attempt
      await validateFile(file);
      
      const formData = new FormData();
      formData.append('file', file);
      formData.append('attempt', attempt + 1);
      
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 30000);
      
      const response = await fetch(endpoint, {
        method: 'POST',
        body: formData,
        signal: controller.signal
      });
      
      clearTimeout(timeoutId);
      
      if (!response.ok) {
        const error = await response.json();
        
        // Don't retry validation errors
        if (response.status === 400 || response.status === 413) {
          throw new Error(error.message);
        }
        
        throw new Error(`HTTP ${response.status}: ${error.message}`);
      }
      
      return await response.json();
      
    } catch (error) {
      lastError = error;
      
      if (error.name === 'AbortError') {
        console.warn(`Upload attempt ${attempt + 1} timed out`);
      } else if (!error.message.includes('Validation')) {
        console.warn(`Upload attempt ${attempt + 1} failed:`, error.message);
      } else {
        // Don't retry validation errors
        throw error;
      }
      
      if (attempt < maxRetries - 1) {
        const delay = Math.pow(2, attempt) * 1000; // Exponential backoff
        await new Promise(resolve => setTimeout(resolve, delay));
      }
    }
  }
  
  throw new Error(`Upload failed after ${maxRetries} attempts: ${lastError.message}`);
}
```

### Security Considerations

Never trust client-side validation alone. All validation must be repeated server-side because:

- JavaScript can be disabled or modified
- Requests can be crafted outside the browser
- File contents can be manipulated after client validation
- MIME types and extensions are trivially spoofed

Additional security measures:

```javascript
// Sanitize filename before upload
function sanitizeFileName(fileName) {
  return fileName
    .replace(/[^a-zA-Z0-9.-]/g, '_')
    .replace(/\.{2,}/g, '.')
    .substring(0, 255);
}

// Validate Content-Disposition header in response
async function validateDownloadResponse(response, expectedFileName) {
  const contentDisposition = response.headers.get('content-disposition');
  
  if (!contentDisposition || !contentDisposition.includes('attachment')) {
    throw new Error('Invalid content disposition');
  }
  
  // Prevent path traversal in filename
  const filenameMatch = contentDisposition.match(/filename="?([^"]+)"?/);
  if (filenameMatch) {
    const filename = filenameMatch[1];
    if (filename.includes('..') || filename.includes('/') || filename.includes('\\')) {
      throw new Error('Invalid filename in response');
    }
  }
  
  return response;
}
```

---

