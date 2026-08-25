## Payload Compression


### Request Payload Compression

#### Manual Compression

The Fetch API does not automatically compress request bodies. Compression must be implemented manually by transforming the payload before sending.

**Using CompressionStream API**

```javascript
async function compressPayload(data) {
  const blob = new Blob([JSON.stringify(data)]);
  const stream = blob.stream().pipeThrough(
    new CompressionStream('gzip')
  );
  return new Response(stream).blob();
}

const payload = { large: 'data', array: [...] };
const compressed = await compressPayload(payload);

await fetch('/api/endpoint', {
  method: 'POST',
  headers: {
    'Content-Encoding': 'gzip',
    'Content-Type': 'application/json'
  },
  body: compressed
});
```

**Compression Formats**

The CompressionStream API supports three formats:

- `gzip` - Most widely supported, good compression ratio
- `deflate` - Similar to gzip, less common
- `deflate-raw` - Raw DEFLATE without headers

#### Setting Content-Encoding Header

The `Content-Encoding` header informs the server about the compression applied to the request body.

```javascript
fetch('/api/data', {
  method: 'POST',
  headers: {
    'Content-Encoding': 'gzip',
    'Content-Type': 'application/json'
  },
  body: compressedData
});
```

**Important considerations:**

- The header value must match the actual compression algorithm used
- Multiple encodings can be specified in order of application: `Content-Encoding: gzip, br`
- The server must support the specified encoding scheme

#### Server Requirements

Server-side decompression requirements:

- Server must recognize and process `Content-Encoding` header
- Server must have decompression capabilities for the specified algorithm
- Many servers (Node.js, nginx, Apache) support automatic decompression
- Some frameworks require explicit middleware configuration

**Node.js Express example:**

```javascript
app.use(express.json({
  inflate: true  // Automatically decompress gzip/deflate
}));
```

#### When to Compress Requests

Compression trade-offs:

**Benefits:**

- Reduced bandwidth usage
- Faster transmission over slow networks
- Lower data transfer costs

**Costs:**

- CPU overhead for compression
- Processing time on both client and server
- Added complexity

**Recommended for:**

- Payloads larger than 1-2 KB
- Slow or metered network connections
- Highly compressible data (text, JSON, XML)

**Not recommended for:**

- Small payloads (< 1 KB) - overhead exceeds savings
- Already compressed data (images, videos, compressed files)
- Fast local networks
- Resource-constrained devices

### Response Payload Compression

#### Automatic Decompression

Modern browsers automatically handle response decompression when servers send compressed content.

```javascript
// Server sends: Content-Encoding: gzip
const response = await fetch('/api/data');
const data = await response.json();  // Automatically decompressed
```

The browser:

1. Reads the `Content-Encoding` response header
2. Identifies the compression algorithm(s)
3. Automatically decompresses the response body
4. Provides decompressed data to JavaScript

**No manual decompression needed** - this is handled transparently by the browser's network layer.

#### Accept-Encoding Header

The browser automatically sends `Accept-Encoding` to indicate supported compression algorithms:

```
Accept-Encoding: gzip, deflate, br
```

**Default behavior:**

- Browsers send this header automatically
- Cannot be modified via Fetch API for security reasons
- Indicates client support for `gzip`, `deflate`, and `br` (Brotli)

[Unverified: Browser-specific variations may exist in which compression algorithms are advertised]

#### Brotli Compression

Brotli (`br`) is a modern compression algorithm offering better compression ratios than gzip.

**Advantages:**

- 15-25% better compression than gzip for text content
- Supported by all modern browsers
- Particularly effective for static assets

**Server configuration:**

- Must be explicitly enabled on most servers
- Requires Brotli library installation
- Can be configured with different compression levels (0-11)

**nginx example:**

```nginx
brotli on;
brotli_comp_level 6;
brotli_types text/plain text/css application/json application/javascript;
```

**Browser support:**

- Chrome/Edge 50+
- Firefox 44+
- Safari 11+

#### Content-Encoding vs Transfer-Encoding

Two different compression mechanisms exist in HTTP:

**Content-Encoding:**

- Compression applied to the resource itself
- Persists through caching
- Specified in `Content-Encoding` header
- Examples: `gzip`, `br`, `deflate`

**Transfer-Encoding:**

- Compression applied to the message during transmission
- Not cached, removed by intermediaries
- Specified in `Transfer-Encoding` header
- Most common value: `chunked`
- `Transfer-Encoding: gzip` is deprecated

**Key differences:**

|Aspect|Content-Encoding|Transfer-Encoding|
|---|---|---|
|Purpose|Resource compression|Message framing|
|Caching|Cached compressed|Not cached|
|Visibility|Visible to application|Transparent hop-by-hop|
|Common use|Compression|Chunked streaming|

### Performance Considerations

#### Compression Ratio Analysis

Different content types achieve varying compression ratios:

**Highly compressible (70-90% reduction):**

- JSON with repetitive structure
- XML documents
- HTML pages
- Plain text
- CSV files

**Moderately compressible (40-70% reduction):**

- JavaScript source code
- CSS stylesheets
- SVG graphics

**Poorly compressible (< 20% reduction):**

- Already compressed formats (JPEG, PNG, MP4, ZIP)
- Encrypted data
- Random or binary data
- Small payloads with high entropy

#### Size Threshold Optimization

Optimal compression strategies by payload size:

**< 500 bytes:**

- Compression overhead exceeds benefits
- HTTP headers may be larger than payload
- Skip compression

**500 bytes - 1 KB:**

- Marginal benefits
- Consider only for text-heavy content
- Test actual transmission time

**1-10 KB:**

- Good candidate for compression
- Significant bandwidth savings
- Minimal CPU impact

**> 10 KB:**

- Strong candidate for compression
- Large bandwidth savings
- CPU cost amortized over size

**> 1 MB:**

- Consider streaming compression
- May want to use lower compression levels for speed
- Monitor memory usage

#### Computational Cost

Compression level impact on CPU and compression ratio:

**gzip levels (1-9):**

- Level 1: Fast compression, ~60% ratio
- Level 6 (default): Balanced, ~70% ratio
- Level 9: Slow compression, ~75% ratio

**Recommendation:** Use default levels (6 for gzip, 6-8 for Brotli) unless specific requirements exist.

**Client-side considerations:**

- Mobile devices have limited CPU
- Battery drain from compression
- May block UI if not done in worker

**Server-side considerations:**

- Pre-compress static assets at build time
- Cache compressed responses
- Use reverse proxy compression (nginx, Cloudflare)

#### Network Speed Impact

Compression effectiveness varies with network conditions:

**Slow networks (< 1 Mbps):**

- High compression recommended
- Transmission time dominates
- CPU cost negligible vs transfer time

**Medium networks (1-10 Mbps):**

- Standard compression levels optimal
- Balance compression time and transfer time

**Fast networks (> 100 Mbps):**

- Minimal benefit from compression
- May actually slow down due to compression overhead
- Consider skipping for local/fast connections

### Implementation Patterns

#### Client-Side Request Compression

```javascript
class CompressionClient {
  constructor(threshold = 1024) {
    this.threshold = threshold;
  }

  async compressIfNeeded(data) {
    const json = JSON.stringify(data);
    const size = new Blob([json]).size;
    
    if (size < this.threshold) {
      return {
        body: json,
        headers: { 'Content-Type': 'application/json' }
      };
    }

    const compressed = await this.compress(json);
    return {
      body: compressed,
      headers: {
        'Content-Type': 'application/json',
        'Content-Encoding': 'gzip'
      }
    };
  }

  async compress(text) {
    const blob = new Blob([text]);
    const stream = blob.stream().pipeThrough(
      new CompressionStream('gzip')
    );
    return new Response(stream).blob();
  }

  async post(url, data) {
    const { body, headers } = await this.compressIfNeeded(data);
    
    return fetch(url, {
      method: 'POST',
      headers,
      body
    });
  }
}

// Usage
const client = new CompressionClient(2048);
await client.post('/api/data', largePayload);
```

#### Streaming Compression

For large payloads, use streaming to avoid memory spikes:

```javascript
async function streamingCompress(readableStream) {
  return readableStream.pipeThrough(
    new CompressionStream('gzip')
  );
}

// Compress large file upload
const file = document.querySelector('input[type="file"]').files[0];
const compressed = streamingCompress(file.stream());

await fetch('/upload', {
  method: 'POST',
  headers: {
    'Content-Encoding': 'gzip',
    'Content-Type': file.type
  },
  body: compressed,
  duplex: 'half'  // Required for streaming request bodies
});
```

**Note:** The `duplex: 'half'` option is required when using streaming request bodies.

#### Conditional Compression

Compress based on runtime conditions:

```javascript
async function adaptivePost(url, data) {
  const compressed = await shouldCompress() 
    ? await compressPayload(data)
    : JSON.stringify(data);
  
  const headers = {
    'Content-Type': 'application/json'
  };
  
  if (await shouldCompress()) {
    headers['Content-Encoding'] = 'gzip';
  }
  
  return fetch(url, {
    method: 'POST',
    headers,
    body: compressed
  });
}

async function shouldCompress() {
  // Check network connection
  if ('connection' in navigator) {
    const { effectiveType, saveData } = navigator.connection;
    
    // Don't compress on fast connections
    if (effectiveType === '4g' && !saveData) {
      return false;
    }
    
    // Always compress on slow connections or data saver
    if (effectiveType === 'slow-2g' || effectiveType === '2g' || saveData) {
      return true;
    }
  }
  
  // Default: compress
  return true;
}
```

#### Server Configuration Examples

**Express.js (Node.js):**

```javascript
const compression = require('compression');

app.use(compression({
  filter: (req, res) => {
    if (req.headers['x-no-compression']) {
      return false;
    }
    return compression.filter(req, res);
  },
  level: 6,
  threshold: 1024
}));
```

**nginx:**

```nginx
http {
  gzip on;
  gzip_vary on;
  gzip_min_length 1024;
  gzip_types text/plain text/css text/xml text/javascript 
             application/json application/javascript application/xml+rss;
  gzip_comp_level 6;
  
  # Brotli (if module installed)
  brotli on;
  brotli_comp_level 6;
  brotli_types text/plain text/css application/json 
               application/javascript text/xml application/xml;
}
```

**Apache:**

```apache
<IfModule mod_deflate.c>
  AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css
  AddOutputFilterByType DEFLATE application/javascript application/json
  DeflateCompressionLevel 6
  SetOutputFilter DEFLATE
</IfModule>
```

### Browser Compatibility

#### CompressionStream API

Support for client-side compression:

- Chrome/Edge 80+
- Firefox 113+
- Safari 16.4+

**Fallback detection:**

```javascript
if ('CompressionStream' in window) {
  // Use native compression
  const stream = new CompressionStream('gzip');
} else {
  // Use polyfill or skip compression
  console.warn('CompressionStream not supported');
}
```

#### Polyfills and Libraries

For older browsers:

**pako** - Pure JavaScript implementation:

```javascript
import pako from 'pako';

function compressWithPako(data) {
  const json = JSON.stringify(data);
  const compressed = pako.gzip(json);
  return new Blob([compressed]);
}
```

**fflate** - Fast alternative:

```javascript
import { gzipSync } from 'fflate';

function compressWithFflate(data) {
  const json = JSON.stringify(data);
  const uint8 = new TextEncoder().encode(json);
  const compressed = gzipSync(uint8);
  return new Blob([compressed]);
}
```

### Security Considerations

#### BREACH Attack

Compression can expose encrypted data to timing attacks when:

- Response contains both secret data and attacker-controlled input
- Response is compressed
- Response is sent over HTTPS
- Attacker can make multiple requests

**Mitigation strategies:**

- Separate secret data from user input in responses
- Add random padding to responses
- Disable compression for sensitive endpoints
- Use CSRF tokens that change per request

#### Content-Length Manipulation

Compressed payloads have unpredictable sizes:

- Content-Length header may not reflect actual size
- Can complicate rate limiting based on size
- Monitor both compressed and decompressed sizes

#### Compression Bombs

Malicious payloads that expand significantly:

```javascript
// Server-side protection
app.use(express.json({
  limit: '1mb',  // Limit decompressed size
  inflate: true
}));
```

**Defense:**

- Set maximum decompressed size limits
- Timeout decompression operations
- Monitor memory usage during decompression

### Testing and Debugging

#### Verifying Compression

**Browser DevTools:**

1. Open Network tab
2. Check request/response headers
3. Look for `Content-Encoding` header
4. Compare Size vs Transferred size

**cURL testing:**

```bash
# Test response compression
curl -H "Accept-Encoding: gzip" -I https://example.com

# Test request compression
curl -X POST https://example.com/api \
  -H "Content-Encoding: gzip" \
  -H "Content-Type: application/json" \
  --data-binary @compressed.json.gz
```

#### Measuring Compression Ratios

```javascript
async function measureCompressionRatio(data) {
  const original = new Blob([JSON.stringify(data)]);
  const compressed = await compressPayload(data);
  
  const ratio = (1 - compressed.size / original.size) * 100;
  
  console.log(`Original: ${original.size} bytes`);
  console.log(`Compressed: ${compressed.size} bytes`);
  console.log(`Ratio: ${ratio.toFixed(2)}%`);
  
  return ratio;
}
```

#### Performance Profiling

```javascript
async function profileCompression(data) {
  const start = performance.now();
  
  const compressed = await compressPayload(data);
  
  const compressionTime = performance.now() - start;
  
  const fetchStart = performance.now();
  await fetch('/api/endpoint', {
    method: 'POST',
    body: compressed,
    headers: { 'Content-Encoding': 'gzip' }
  });
  const totalTime = performance.now() - fetchStart;
  
  console.log(`Compression: ${compressionTime.toFixed(2)}ms`);
  console.log(`Total request: ${totalTime.toFixed(2)}ms`);
}
```

### Best Practices

1. **Set reasonable size thresholds** - Don't compress payloads smaller than 1-2 KB
2. **Use appropriate compression levels** - Default levels balance speed and ratio
3. **Pre-compress static assets** - Avoid runtime compression overhead
4. **Cache compressed responses** - Don't recompress the same content repeatedly
5. **Consider network conditions** - Adapt compression strategy to connection speed
6. **Test compression effectiveness** - Measure actual improvements in your use case
7. **Handle compression failures gracefully** - Fall back to uncompressed on errors
8. **Document server requirements** - Ensure backend supports your compression scheme
9. **Monitor decompression costs** - Server-side decompression uses CPU and memory
10. **Use streaming for large payloads** - Avoid loading entire payload into memory

---

