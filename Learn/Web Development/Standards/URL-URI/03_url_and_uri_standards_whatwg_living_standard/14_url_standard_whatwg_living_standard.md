## URL Standard (WHATWG Living Standard)


The WHATWG URL Standard represents the modern specification for URL parsing and handling. Unlike RFC 3986, which is relatively static, the WHATWG standard is a living document that evolves with web platform needs.

### URL Parsing Algorithm

The URL parsing algorithm defines precisely how browsers and modern applications should parse URL strings. It provides detailed steps for handling edge cases, invalid input, and legacy formats that RFC 3986 leaves ambiguous.

The algorithm operates as a state machine with distinct states for parsing different URL components. It handles scheme parsing, authority parsing with special cases for special schemes, path parsing with scheme-specific rules, query parsing, and fragment parsing.

**Key Points:**

- Defines exact parsing behavior for ambiguous cases
- Handles legacy formats for backward compatibility
- Specifies error handling and validation
- Provides deterministic results across implementations

### Special Schemes

The WHATWG standard defines special handling for certain schemes: ftp, file, http, https, ws, and wss. These schemes have specific parsing rules, always use authority components, and have scheme-specific path handling.

Special schemes use special host parsing, which handles domain names, IPv4 addresses, IPv6 addresses, and opaque hosts differently than other schemes.

### URL Serialization

URL serialization converts a parsed URL object back into a string representation. The standard defines precise rules for serializing each component, ensuring consistent output across implementations.

Serialization includes proper percent-encoding of special characters, formatting of IPv6 addresses, handling of credentials in authority, and assembly of components in the correct order.

### Modern URL Handling

The WHATWG standard introduces the URL and URLSearchParams interfaces for JavaScript. These provide programmatic access to URL components with automatic parsing and serialization.

The URL constructor accepts absolute or relative URL strings and optional base URLs. Properties provide access to individual components with automatic encoding/decoding. Methods enable component modification with validation.

**Example:**

```javascript
const url = new URL('https://example.com:8080/path?query=value#fragment');
console.log(url.protocol); // "https:"
console.log(url.hostname); // "example.com"
console.log(url.port); // "8080"
console.log(url.pathname); // "/path"
console.log(url.search); // "?query=value"
console.log(url.hash); // "#fragment"

url.searchParams.append('newParam', 'newValue');
console.log(url.href); // Updated URL string
```

### URLSearchParams Interface

URLSearchParams provides methods for working with query strings: append, delete, get, getAll, has, set, and iteration methods. It handles encoding/decoding automatically and supports multiple values per parameter name.

**Example:**

```javascript
const params = new URLSearchParams('foo=1&bar=2&foo=3');
params.get('foo'); // "1" (first value)
params.getAll('foo'); // ["1", "3"] (all values)
params.append('baz', '4');
params.toString(); // "foo=1&bar=2&foo=3&baz=4"
```

### Backward Compatibility Considerations

The WHATWG standard maintains compatibility with existing web content while clarifying ambiguities. It documents how browsers actually behave rather than prescribing idealized behavior.

Legacy URL formats are parsed consistently with historical browser behavior. Invalid URLs produce predictable results rather than undefined behavior. The standard aligns with RFC 3986 where practical but diverges when web compatibility requires different handling.

