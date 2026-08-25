## Text Response Handling (Fetch Context)


### Stream Processing and Accumulation

Text responses from fetch operations typically arrive as streams that require progressive accumulation. The fundamental pattern involves collecting chunks as they arrive and maintaining state throughout the streaming process.

**Chunk Accumulation**: Responses arrive in fragments that must be concatenated in sequence. Each chunk represents a partial payload that contributes to the complete response body. The accumulation buffer grows progressively until the stream signals completion.

**Encoding Considerations**: Text streams may arrive in various encodings (UTF-8, UTF-16, ASCII). The decoder must match the declared content encoding from response headers. Mismatched encoding causes corruption of multi-byte characters, particularly affecting non-ASCII content.

### Response Object Structure

Fetch responses expose text content through multiple interfaces, each with distinct characteristics:

**text() Method**: Returns a promise that resolves to the complete response body as a string. This method consumes the entire stream and performs automatic encoding detection based on Content-Type headers. The body stream can only be read once - subsequent calls to text() will fail because the stream has been consumed.

**Body Stream Access**: The response.body property provides a ReadableStream that enables chunk-by-chunk processing before the complete response arrives. This allows progressive rendering and memory-efficient handling of large payloads.

```javascript
const response = await fetch(url);
const reader = response.body.getReader();
const decoder = new TextDecoder();

let accumulated = '';
while (true) {
  const {done, value} = await reader.read();
  if (done) break;
  accumulated += decoder.decode(value, {stream: true});
}
```

### Error State Management

**Network Failures**: Fetch rejects its promise for network-level failures (DNS resolution, connection refused, timeout). The response object never materializes in these scenarios - error handling must occur at the promise catch level.

**HTTP Error Status**: Successful fetch resolution doesn't indicate successful HTTP transactions. Status codes 4xx and 5xx resolve normally - the response object exists but represents an error state. Status validation requires explicit checking:

```javascript
if (!response.ok) {
  const errorText = await response.text();
  throw new Error(`HTTP ${response.status}: ${errorText}`);
}
```

**Partial Response Handling**: Stream interruptions mid-transfer create incomplete text responses. The accumulated content may be syntactically invalid (truncated JSON, incomplete HTML). Validation must occur after accumulation completes.

### Content-Type Processing

**MIME Type Inspection**: The Content-Type header dictates expected response format. Text responses may declare charset encoding: `text/html; charset=utf-8`. This informs decoder selection and parsing strategy.

**JSON Response Handling**: Despite being text-based, JSON requires post-processing. The json() method provides integrated parsing:

```javascript
const data = await response.json();  // Combines text() + JSON.parse()
```

Manual text extraction followed by JSON.parse() provides identical functionality with explicit error control over parsing failures.

### Large Response Strategies

**Progressive Processing**: For responses exceeding memory constraints, stream processing prevents buffer overflow. Each chunk undergoes immediate processing before the next arrives, maintaining constant memory usage regardless of total response size.

**Backpressure Management**: [Inference] When processing cannot keep pace with incoming chunks, backpressure mechanisms should signal the stream to pause delivery. The ReadableStream API supports this through reader.read() promise timing - slow consumption naturally applies backpressure.

**Line-Based Processing**: Text responses with line-delimited records (logs, CSV, NDJSON) benefit from line-oriented accumulation:

```javascript
let buffer = '';
const lines = [];

// For each chunk
buffer += chunkText;
const lineBreakIndex = buffer.lastIndexOf('\n');
if (lineBreakIndex !== -1) {
  const completeLines = buffer.substring(0, lineBreakIndex);
  buffer = buffer.substring(lineBreakIndex + 1);
  lines.push(...completeLines.split('\n'));
}
```

### Character Boundary Handling

Multi-byte character sequences may split across chunk boundaries. UTF-8 characters span 1-4 bytes, and a chunk might terminate mid-character.

**TextDecoder Stream Mode**: The {stream: true} option instructs the decoder to retain incomplete character bytes across decode() calls:

```javascript
decoder.decode(chunk, {stream: true});  // Preserves incomplete sequences
decoder.decode(finalChunk);  // stream: false (default) for final chunk
```

Without stream mode, truncated multi-byte sequences decode to replacement characters (�).

### Response Cloning

The response.clone() method creates an independent copy that allows multiple consumption strategies:

```javascript
const response = await fetch(url);
const clone = response.clone();

const text = await response.text();  // Consumes original
const json = await clone.json();      // Consumes clone independently
```

[Inference] Cloning duplicates the underlying stream, enabling parallel or sequential processing with different methods. This incurs memory overhead proportional to response size.

### Abort and Timeout Handling

**AbortController Integration**: Fetch accepts an abort signal that terminates in-progress requests:

```javascript
const controller = new AbortController();
const timeoutId = setTimeout(() => controller.abort(), 5000);

try {
  const response = await fetch(url, {signal: controller.signal});
  const text = await response.text();
} catch (err) {
  if (err.name === 'AbortError') {
    // Request was aborted
  }
} finally {
  clearTimeout(timeoutId);
}
```

Aborting during text() consumption terminates stream reading and rejects the promise.

### Memory Management

**Garbage Collection Dependencies**: [Inference] Response objects and their streams remain in memory until fully consumed or explicitly abandoned. Unread streams may prevent garbage collection of the response object and associated network resources.

**Large Text Accumulation**: Complete text extraction via text() loads the entire response into memory as a string. For multi-megabyte responses, this creates memory pressure and potential performance degradation from large string allocations.

### Binary vs Text Distinction

Fetch provides blob() and arrayBuffer() methods for binary content. Using text() on binary responses produces mojibake - the bytes get interpreted as character codes. Content-Type inspection should determine the appropriate extraction method.

**Base64-Encoded Text**: Some APIs return binary data encoded as base64 text. This requires text extraction followed by base64 decoding:

```javascript
const base64Text = await response.text();
const binaryString = atob(base64Text);
const bytes = new Uint8Array(binaryString.length);
for (let i = 0; i < binaryString.length; i++) {
  bytes[i] = binaryString.charCodeAt(i);
}
```

### Compression Handling

**Automatic Decompression**: Browsers automatically decompress gzip and deflate responses when the Content-Encoding header indicates compression. The text() method operates on decompressed content transparently.

**Brotli Support**: [Unverified - browser-dependent] Modern browsers support brotli (br) encoding with automatic decompression. Older environments may not decompress brotli, delivering compressed bytes that fail text decoding.

### Cross-Origin Considerations

**Opaque Responses**: Cross-origin requests without CORS headers produce opaque responses (type: 'opaque'). Text extraction from opaque responses fails - the body is inaccessible for security reasons.

**CORS and Text Access**: Successful CORS negotiation (appropriate Access-Control-Allow-Origin headers) produces basic or cors-type responses that permit text extraction.

### Event-Driven Processing

For UI applications requiring incremental updates during long downloads:

```javascript
const response = await fetch(url);
const contentLength = response.headers.get('Content-Length');
const reader = response.body.getReader();

let receivedLength = 0;
let chunks = [];

while (true) {
  const {done, value} = await reader.read();
  if (done) break;
  
  chunks.push(value);
  receivedLength += value.length;
  
  const progress = contentLength ? (receivedLength / contentLength) * 100 : 0;
  updateProgressBar(progress);
}

const allChunks = new Uint8Array(receivedLength);
let position = 0;
for (const chunk of chunks) {
  allChunks.set(chunk, position);
  position += chunk.length;
}

const text = new TextDecoder().decode(allChunks);
```

[Inference] This pattern enables responsive UIs during data transfer but adds complexity compared to simple await response.text().

### Retry and Resilience

**Idempotency Requirements**: Text fetches should generally target idempotent endpoints for safe retry logic. POST requests with side effects require careful consideration before retry attempts.

**Exponential Backoff**: [Inference - common pattern but not standardized] Retry strategies often employ exponential delays between attempts:

```javascript
async function fetchWithRetry(url, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      const response = await fetch(url);
      if (!response.ok && response.status >= 500) {
        throw new Error(`Server error: ${response.status}`);
      }
      return await response.text();
    } catch (err) {
      if (i === maxRetries - 1) throw err;
      await new Promise(resolve => setTimeout(resolve, Math.pow(2, i) * 1000));
    }
  }
}
```

**Partial Content Recovery**: [Speculation] Range requests could resume interrupted downloads, but this requires server support for byte-range requests and adds significant complexity to text response handling.

---

