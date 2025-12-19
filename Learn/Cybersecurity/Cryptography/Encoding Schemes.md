# Base64

Base64 is an encoding scheme that converts binary data into ASCII text format using 64 specific characters. It's widely used for transmitting data over systems designed to handle text.

## How Base64 Works

Base64 encoding takes binary data and converts it into a text representation using a specific alphabet of 64 characters: A-Z, a-z, 0-9, plus two additional characters (typically `+` and `/`), with `=` used for padding.

The conversion process works by:
1. Taking the binary data in groups of 3 bytes (24 bits)
2. Dividing those 24 bits into 4 groups of 6 bits each
3. Converting each 6-bit group to its corresponding Base64 character
4. Adding padding (`=`) if the input length isn't divisible by 3

For example, the text "Man" in ASCII is:
- M = 77 (01001101)
- a = 97 (01100001)  
- n = 110 (01101110)

Combined: `010011010110000101101110`

Split into 6-bit groups: `010011`, `010110`, `000101`, `101110`

These map to Base64 characters: `TWFu`

## Common Uses

Base64 is frequently used for:
- **Email attachments** - MIME encoding for sending binary files via email systems that only support text
- **Data URLs** - Embedding images or other files directly in HTML/CSS (e.g., `data:image/png;base64,iVBORw0KG...`)
- **Web APIs** - Transmitting binary data in JSON or XML
- **Basic authentication** - HTTP Basic Auth encodes credentials as Base64
- **Storing binary data** - In text-based formats like JSON or XML
- **Cryptographic keys and certificates** - PEM format uses Base64

## Important Characteristics

**Size increase**: Base64 encoding increases data size by approximately 33%. Every 3 bytes becomes 4 characters.

**Not encryption**: Base64 is encoding, not encryption. It provides no security and can be easily decoded by anyone.

**Text-safe**: The output contains only printable ASCII characters, making it safe for text-based protocols.

**Variants**: Several Base64 variants exist with different character sets for specific use cases (URL-safe Base64, modified Base64 for filenames, etc.).

## Encoding and Decoding

Most programming languages provide built-in Base64 support:

**JavaScript:**
```javascript
// Encoding
btoa("Hello") // "SGVsbG8="

// Decoding
atob("SGVsbG8=") // "Hello"
```

**Python:**
```python
import base64

# Encoding
base64.b64encode(b"Hello") # b'SGVsbG8='

# Decoding
base64.b64decode(b'SGVsbG8=') # b'Hello'
```

Base64 remains an essential tool for handling binary data in text-based contexts, despite its overhead and lack of security features.