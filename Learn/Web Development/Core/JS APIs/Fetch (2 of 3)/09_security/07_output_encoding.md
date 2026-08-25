## Output Encoding


### Response Body Types

The fetch API provides multiple methods to decode response bodies, each handling encoding differently. The `Response` object exposes methods that interpret the raw byte stream according to specific encoding rules.

**Available decoding methods:**

- `response.text()` - Decodes as text using charset
- `response.json()` - Parses as JSON after text decoding
- `response.arrayBuffer()` - Returns raw bytes
- `response.blob()` - Returns binary data with MIME type
- `response.formData()` - Parses as form data
- `response.bytes()` - Returns Uint8Array (newer API)

Each method consumes the response body stream, making it unavailable for subsequent reads.

### Text Encoding Detection

The `text()` method determines character encoding through a priority hierarchy:

**Encoding detection order:**

1. BOM (Byte Order Mark) in response body
2. `charset` parameter in `Content-Type` header
3. [Inference] Default fallback (UTF-8)

```javascript
const response = await fetch('https://api.example.com/data');
const text = await response.text();
// Decoding uses Content-Type charset or UTF-8
```

**Content-Type header example:**

```
Content-Type: text/html; charset=ISO-8859-1
```

The `text()` method uses ISO-8859-1 to decode the byte stream in this case.

### UTF-8 Handling

UTF-8 is the dominant encoding on the web and the de facto default for fetch API responses without explicit charset declarations.

**UTF-8 characteristics:**

- Variable-length encoding (1-4 bytes per character)
- ASCII-compatible (first 128 characters)
- Self-synchronizing (error recovery possible)

```javascript
const response = await fetch('https://api.example.com/utf8-data');
const text = await response.text();
// Handles multi-byte UTF-8 sequences correctly
console.log(text);  // "Hello 世界 🌍"
```

Invalid UTF-8 sequences typically decode to the replacement character (U+FFFD �).

### JSON Encoding Requirements

The `json()` method first decodes the response as text, then parses it as JSON. JSON specification (RFC 8259) mandates UTF-8 encoding:

```javascript
const response = await fetch('https://api.example.com/data.json');
const data = await response.json();
```

**Process:**

1. Decode bytes to string using charset detection
2. Parse string as JSON
3. Return JavaScript object

[Inference] If the response claims a non-UTF-8 charset in `Content-Type`, the `text()` decoding step uses that charset, potentially causing JSON parsing errors if the actual encoding differs.

### Binary Data Preservation

The `arrayBuffer()` and `blob()` methods preserve raw bytes without text interpretation:

```javascript
const response = await fetch('https://cdn.example.com/image.png');
const buffer = await response.arrayBuffer();
// buffer contains exact bytes from response, no encoding applied
```

**Use cases for binary methods:**

- Images, audio, video
- Binary file formats (PDF, ZIP, etc.)
- Custom binary protocols
- Cryptographic operations requiring exact byte sequences

### Blob Encoding Metadata

Blobs carry MIME type metadata from the response's `Content-Type` header:

```javascript
const response = await fetch('https://api.example.com/document.pdf');
const blob = await response.blob();
console.log(blob.type);  // "application/pdf"
```

This metadata doesn't affect encoding but provides type information for subsequent processing:

```javascript
const url = URL.createObjectURL(blob);
// Browser uses blob.type to render correctly
```

### Form Data Encoding

The `formData()` method decodes `multipart/form-data` or `application/x-www-form-urlencoded` responses:

```javascript
const response = await fetch('https://api.example.com/form');
const form = await response.formData();

for (const [key, value] of form.entries()) {
  console.log(`${key}: ${value}`);
}
```

**Encoding handling:**

- Text fields decode using charset from Content-Type
- File fields preserve binary data as Blob objects
- URL-encoded forms decode percent-encoded sequences

### Manual Encoding Control

For precise encoding control, use `arrayBuffer()` with `TextDecoder`:

```javascript
const response = await fetch('https://api.example.com/legacy-data');
const buffer = await response.arrayBuffer();

const decoder = new TextDecoder('windows-1252');
const text = decoder.decode(buffer);
```

**TextDecoder options:**

- Supports numerous legacy encodings
- `fatal` option throws on invalid sequences instead of replacing
- `ignoreBOM` option controls BOM handling

```javascript
const decoder = new TextDecoder('utf-8', {
  fatal: true,      // Throw on invalid UTF-8
  ignoreBOM: false  // Respect BOM if present
});
```

### Encoding Mismatch Scenarios

When declared encoding doesn't match actual encoding, corruption occurs:

```javascript
// Server sends UTF-8 but declares ISO-8859-1
const response = await fetch('https://api.example.com/wrong-charset');
// Content-Type: text/plain; charset=ISO-8859-1
// Actual data: UTF-8 encoded "Café"

const text = await response.text();
console.log(text);  // "CafÃ©" (mojibake - double-encoded)
```

**Recovery strategy:**

```javascript
const buffer = await response.arrayBuffer();
const utf8Decoder = new TextDecoder('utf-8');
const corrected = utf8Decoder.decode(buffer);
console.log(corrected);  // "Café"
```

### Base64 Encoding

Binary data embedded in JSON typically uses Base64 encoding:

```javascript
const response = await fetch('https://api.example.com/data');
const data = await response.json();
// data.imageData = "iVBORw0KGgoAAAANSUhEUgA..." (Base64 string)

// Decode Base64 to binary
const binaryString = atob(data.imageData);
const bytes = Uint8Array.from(binaryString, c => c.charCodeAt(0));
```

**Modern alternative using Uint8Array:**

```javascript
const bytes = Uint8Array.from(atob(data.imageData), c => c.charCodeAt(0));
const blob = new Blob([bytes], { type: 'image/png' });
```

### Streaming Text Decoding

The Response body is a ReadableStream. Text can be decoded incrementally:

```javascript
const response = await fetch('https://api.example.com/large-text');
const reader = response.body.getReader();
const decoder = new TextDecoder();

while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  
  const chunk = decoder.decode(value, { stream: true });
  console.log(chunk);  // Process text incrementally
}

// Final chunk without stream flag
const final = decoder.decode();
```

The `stream: true` option handles multi-byte characters split across chunks correctly.

### Content-Encoding vs Character Encoding

`Content-Encoding` (compression) is distinct from character encoding:

```
Content-Encoding: gzip
Content-Type: text/html; charset=utf-8
```

The fetch API automatically decompresses `gzip`, `deflate`, and `br` (Brotli) content:

```javascript
const response = await fetch('https://api.example.com/compressed');
// Response body already decompressed by browser
const text = await response.text();  // Then character-decoded
```

This decompression happens transparently before any decoding method executes.

### Headers and Encoding

Response headers themselves use ISO-8859-1 (Latin-1) encoding per HTTP specification:

```javascript
const response = await fetch('https://api.example.com/data');
const header = response.headers.get('X-Custom-Header');
// Header values limited to ISO-8859-1 characters
```

Non-ASCII data in headers requires encoding schemes:

- RFC 2047 for older headers: `=?UTF-8?B?...?=`
- RFC 8187 for newer headers: `filename*=UTF-8''%E4%B8%AD%E6%96%87.txt`

### JSON Text Sequences

JSON Text Sequences (RFC 7464) use record separator characters:

```javascript
const response = await fetch('https://api.example.com/json-seq');
const text = await response.text();

const records = text.split('\x1E')  // ASCII RS (Record Separator)
  .filter(Boolean)
  .map(record => JSON.parse(record.replace(/^\x1E/, '')));
```

This format allows streaming JSON objects with clear delimiters.

### Character Reference Decoding

HTML/XML character references require explicit decoding:

```javascript
const response = await fetch('https://api.example.com/html-encoded');
const text = await response.text();
// text = "Hello &amp; goodbye &#x1F600;"

const parser = new DOMParser();
const doc = parser.parseFromString(text, 'text/html');
const decoded = doc.documentElement.textContent;
// decoded = "Hello & goodbye 😀"
```

The `text()` method doesn't decode HTML entities—they remain as literal strings.

### Encoding Detection Failures

[Inference] When encoding detection fails or produces incorrect results:

**Symptoms:**

- Replacement characters (�) appear in text
- Mojibake (garbled characters)
- Truncated text at invalid byte sequences

**Diagnostic approach:**

```javascript
const response = await fetch('https://api.example.com/data');

// Check declared encoding
const contentType = response.headers.get('Content-Type');
console.log('Declared:', contentType);

// Inspect raw bytes
const buffer = await response.arrayBuffer();
const bytes = new Uint8Array(buffer);
console.log('First bytes:', bytes.slice(0, 20));

// Try different decoders
const encodings = ['utf-8', 'iso-8859-1', 'windows-1252'];
encodings.forEach(encoding => {
  const decoder = new TextDecoder(encoding, { fatal: false });
  console.log(`${encoding}:`, decoder.decode(buffer).substring(0, 100));
});
```

### Unicode Normalization

Unicode characters can have multiple representations. Normalization ensures consistency:

```javascript
const response = await fetch('https://api.example.com/unicode');
const text = await response.text();

// Normalize to canonical composition (NFC)
const normalized = text.normalize('NFC');
```

**Normalization forms:**

- `NFC` - Canonical composition (most compact)
- `NFD` - Canonical decomposition
- `NFKC` - Compatibility composition
- `NFKD` - Compatibility decomposition

This is particularly important for comparing strings or using them as object keys.

### Response Cloning and Encoding

Cloning responses allows multiple decoding attempts:

```javascript
const response = await fetch('https://api.example.com/data');
const clone = response.clone();

// Try JSON first
try {
  const data = await response.json();
  return data;
} catch {
  // Fall back to text
  const text = await clone.text();
  return text;
}
```

Each clone maintains an independent stream, allowing different encoding strategies.

### Error Handling in Decoding

Decoding methods can fail for various reasons:

```javascript
const response = await fetch('https://api.example.com/data');

try {
  const data = await response.json();
} catch (error) {
  if (error instanceof SyntaxError) {
    console.error('Invalid JSON:', error.message);
    // Attempt text decode for diagnostic
    const text = await response.clone().text();
    console.log('Raw text:', text.substring(0, 100));
  }
}
```

**Common failures:**

- Invalid JSON syntax in `json()`
- Invalid UTF-8 sequences with fatal TextDecoder
- Malformed multipart data in `formData()`

### Encoding in Request Bodies

When sending data, explicit encoding may be necessary:

```javascript
const text = "Hello 世界";
const encoder = new TextEncoder();  // Always produces UTF-8
const bytes = encoder.encode(text);

await fetch('https://api.example.com/data', {
  method: 'POST',
  body: bytes,
  headers: {
    'Content-Type': 'text/plain; charset=utf-8'
  }
});
```

The `TextEncoder` API only supports UTF-8 output.

### Data URLs and Encoding

Data URLs embed encoded content directly:

```javascript
const text = "Hello 世界";
const encoded = encodeURIComponent(text);
const dataUrl = `data:text/plain;charset=utf-8,${encoded}`;

const response = await fetch(dataUrl);
const decoded = await response.text();
console.log(decoded);  // "Hello 世界"
```

**Base64 data URLs:**

```javascript
const bytes = new TextEncoder().encode(text);
const base64 = btoa(String.fromCharCode(...bytes));
const dataUrl = `data:text/plain;charset=utf-8;base64,${base64}`;
```

### CSV Encoding Considerations

CSV files often use various encodings:

```javascript
const response = await fetch('https://api.example.com/data.csv');

// Check for BOM
const buffer = await response.arrayBuffer();
const view = new Uint8Array(buffer);

let encoding = 'utf-8';
if (view[0] === 0xEF && view[1] === 0xBB && view[2] === 0xBF) {
  encoding = 'utf-8';  // UTF-8 BOM
} else if (view[0] === 0xFF && view[1] === 0xFE) {
  encoding = 'utf-16le';  // UTF-16 LE BOM
}

const decoder = new TextDecoder(encoding);
const text = decoder.decode(buffer);
```

### Encoding Performance Implications

Different decoding methods have varying performance characteristics:

[Inference] **Performance hierarchy (fastest to slowest):**

1. `arrayBuffer()` - No decoding overhead
2. `text()` - Single-pass UTF-8 decoding
3. `json()` - Text decoding + parsing
4. `formData()` - Complex multipart parsing

For large responses, streaming with manual decoding allows progressive processing:

```javascript
const response = await fetch('https://api.example.com/huge-file');
const reader = response.body.getReader();
const decoder = new TextDecoder();

let processedSize = 0;
while (true) {
  const { done, value } = await reader.read();
  if (done) break;
  
  processedSize += value.length;
  const chunk = decoder.decode(value, { stream: true });
  // Process chunk immediately, reducing memory footprint
}
```

### Charset in Requests vs Responses

The charset parameter behaves differently for requests and responses:

**Responses (covered above):**

- Server declares charset in Content-Type
- Client decodes accordingly

**Requests:**

```javascript
await fetch('https://api.example.com/data', {
  method: 'POST',
  headers: {
    'Content-Type': 'text/plain; charset=utf-8'
  },
  body: 'Hello 世界'
});
```

When sending a string body, the fetch API encodes it as UTF-8 regardless of declared charset. [Unverified] The charset declaration in request headers may not affect actual encoding—it primarily informs the server about the encoding used.

---



---


