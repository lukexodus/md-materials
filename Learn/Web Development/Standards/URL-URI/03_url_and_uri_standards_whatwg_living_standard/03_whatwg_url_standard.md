## WHATWG URL Standard


The WHATWG URL Standard is a living standard that defines URL parsing and manipulation as actually implemented in web browsers. Unlike RFC 3986, which provides formal grammar, the WHATWG standard provides detailed algorithms and error handling procedures.

### Living Standard Concept

A living standard is continuously updated without version numbers. Changes are made incrementally based on implementation feedback, bug reports, and new requirements. This approach allows the standard to evolve with the web platform while maintaining implementation consensus.

**Characteristics:**

- No version numbers or dated snapshots
- Continuous integration of improvements
- Alignment with actual browser implementations
- Detailed parsing algorithms with defined error handling
- Comprehensive test suites

### Differences from RFC 3986

The WHATWG URL Standard diverges from RFC 3986 in several significant ways:

**Parsing algorithm specificity:** The WHATWG standard provides character-by-character parsing algorithms with explicit state machines, while RFC 3986 provides BNF grammar.

**Error handling:** [Inference] WHATWG defines specific behavior for invalid input (often attempting recovery), while RFC 3986 typically treats such input as malformed without specifying recovery mechanisms.

**Host parsing:** WHATWG includes detailed algorithms for parsing domain names, IPv4, and IPv6 addresses, with specific error conditions. RFC 3986 provides syntax but less algorithmic detail.

**Percent-encoding differences:** The sets of characters requiring percent-encoding differ between the standards in certain contexts.

**Special schemes:** WHATWG defines "special schemes" (http, https, file, ftp, ws, wss) with scheme-specific parsing rules. RFC 3986 treats most schemes uniformly.

**Example of divergence:**

```
Input: http://example.com/path with spaces

RFC 3986: Invalid (spaces not allowed)
WHATWG: Likely percent-encodes spaces during parsing
```

**File URLs:** WHATWG provides extensive specifications for file: URLs, including Windows path handling and UNC paths. RFC 3986 offers minimal guidance for file: URLs.

**Setter behavior:** WHATWG specifies how URL properties can be individually modified, defining side effects and validation for each component.

### URL API

The WHATWG standard defines a JavaScript API for URL manipulation available in browsers and Node.js.

**Constructor:**

```javascript
new URL(url [, base])
```

**Example:**

```javascript
const url = new URL('https://example.com/path?query=value#fragment');

// Properties
console.log(url.protocol);  // "https:"
console.log(url.hostname);  // "example.com"
console.log(url.pathname);  // "/path"
console.log(url.search);    // "?query=value"
console.log(url.hash);      // "#fragment"

// Modification
url.pathname = '/new-path';
url.searchParams.set('page', '2');

// Result: https://example.com/new-path?query=value&page=2#fragment
```

**URLSearchParams API:**

```javascript
const params = new URLSearchParams('key1=value1&key2=value2');

params.append('key3', 'value3');
params.get('key1');        // "value1"
params.has('key2');        // true
params.delete('key2');
params.toString();         // "key1=value1&key3=value3"

// Iteration
for (const [key, value] of params) {
  console.log(key, value);
}
```

### Browser Implementation Alignment

The WHATWG URL Standard achieves high implementation alignment across major browsers through several mechanisms:

**Specification clarity:** Detailed algorithms eliminate ambiguity in interpretation.

**Test suites:** Comprehensive web-platform-tests ensure consistent behavior across implementations.

**Implementation feedback:** Browser vendors actively contribute to standard development, ensuring specifications are implementable.

**Interoperability focus:** The standard prioritizes interoperability over theoretical purity, making pragmatic decisions based on deployed content.

**Example of alignment:** Modern browsers consistently handle these cases according to WHATWG:

```javascript
new URL('HTTP://EXAMPLE.COM').hostname  // "example.com" (lowercased)
new URL('http://example.com:80').port   // "" (default port omitted)
new URL('//example.com', 'http://base.com').href  // "http://example.com/"
```

### Special URL Schemes

WHATWG defines special handling for certain schemes:

**Special schemes list:**

- `http:` - default port 80
- `https:` - default port 443
- `ws:` - default port 80
- `wss:` - default port 443
- `ftp:` - default port 21
- `file:` - local file access

**Special scheme behaviors:**

- Cannot have empty host (except file:)
- Use specific parsing rules
- Have default ports that are omitted when set
- Subject to additional validation

**Example:**

```javascript
// Special scheme - requires host
new URL('http:///path');  // Throws TypeError

// Non-special scheme - host optional
new URL('custom:///path');  // Valid
```

### URL Parsing State Machine

The WHATWG standard defines a detailed state machine for URL parsing with numerous states:

**Major states include:**

- Scheme start state
- Scheme state
- No scheme state
- Special relative or authority state
- Authority state
- Host state
- Port state
- Path start state
- Path state
- Query state
- Fragment state

Each state defines specific transitions based on the current character and context.

### Domain Name Processing

WHATWG specifies detailed domain name processing including:

**ASCII domain handling:**

- Lowercasing
- Forbidden domain code points
- Validation rules

**Internationalized Domain Names (IDN):**

- Conversion to ASCII using Unicode IDNA algorithm
- Punycode encoding
- Validation of domain labels

**Example:**

```javascript
new URL('http://münchen.de').hostname  // "xn--mnchen-3ya.de"
```

### URL Equivalence

WHATWG defines URL equivalence based on serialization:

Two URLs are equivalent if their serialized forms are identical after parsing.

**Example:**

```javascript
const url1 = new URL('HTTP://EXAMPLE.COM:80/Path');
const url2 = new URL('http://example.com/Path');

url1.href === url2.href  // true (both serialize to lowercase, port 80 omitted)
```

