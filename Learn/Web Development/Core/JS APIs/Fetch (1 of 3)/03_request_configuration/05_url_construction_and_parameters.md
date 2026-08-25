## URL Construction and Parameters


### The URL Interface

The URL API provides a constructor-based approach to URL manipulation, replacing string concatenation and regular expression parsing. The `URL` constructor accepts an absolute URL string or a relative URL with a base URL as the second parameter.

```javascript
const url = new URL('https://api.example.com/users');
const relative = new URL('/api/users', 'https://example.com');
```

The URL object parses the input into discrete components accessible as properties: `protocol`, `username`, `password`, `hostname`, `port`, `pathname`, `search`, `searchParams`, and `hash`. Each property provides read/write access to its respective URL segment, with automatic encoding and validation.

The `href` property returns the complete serialized URL string. Modifying any component property automatically updates `href` to reflect the change. The `origin` property (read-only) combines `protocol`, `hostname`, and `port` into the origin string used for same-origin policy checks.

### URLSearchParams for Query String Management

The `URLSearchParams` interface manages query string parameters through a dedicated API, eliminating manual parsing and encoding. Accessed via `url.searchParams`, it provides methods for parameter manipulation that automatically handle encoding and serialization.

The `append(name, value)` method adds parameters without removing existing ones with the same name, supporting multiple values per key. The `set(name, value)` method replaces all existing parameters with the given name, ensuring only one value exists. The `get(name)` method returns the first value for a parameter, while `getAll(name)` returns an array of all values.

The `has(name)` method checks parameter existence without retrieving values. The `delete(name)` method removes all parameters with the specified name. The `keys()`, `values()`, and `entries()` methods return iterators for parameter traversal.

URLSearchParams implements the iterable protocol, enabling `for...of` loops that yield `[name, value]` pairs:

```javascript
for (const [key, value] of url.searchParams) {
  console.log(`${key}: ${value}`);
}
```

The `toString()` method serializes parameters to a query string without the leading `?`, useful for manual URL construction or form data encoding.

### Parameter Encoding Behavior

URLSearchParams automatically applies percent-encoding to parameter names and values, handling special characters according to the `application/x-www-form-urlencoded` format. Spaces encode as `+` rather than `%20` in the serialized string, matching HTML form submission behavior.

Reserved characters like `&`, `=`, `#`, and `?` receive percent-encoding when used in values, preventing parsing ambiguity. Non-ASCII characters encode as UTF-8 byte sequences with each byte percent-encoded.

The encoding differs slightly from `encodeURIComponent()`, which encodes spaces as `%20` and follows RFC 3986 rather than the form encoding specification. URLSearchParams uses WHATWG URL Standard encoding, optimized for query parameter contexts.

Characters like `!`, `'`, `(`, `)`, and `*` remain unencoded in URLSearchParams despite being encoded by `encodeURIComponent()`. This difference reflects the application/x-www-form-urlencoded specification's legacy compatibility with HTML form submissions.

### Constructing URLs with Parameters

Creating URLs with multiple parameters benefits from method chaining or bulk initialization. URLSearchParams accepts several constructor argument types: a query string (with or without leading `?`), an object with string values, an array of `[key, value]` pairs, or another URLSearchParams instance.

```javascript
// From object
const params = new URLSearchParams({
  search: 'javascript',
  limit: '10',
  offset: '0'
});

// From array of pairs
const params = new URLSearchParams([
  ['search', 'javascript'],
  ['category', 'tutorial'],
  ['category', 'reference']
]);

// From string
const params = new URLSearchParams('?search=javascript&limit=10');
```

Building URLs programmatically through property assignment:

```javascript
const url = new URL('https://api.example.com/search');
url.searchParams.set('q', 'javascript');
url.searchParams.set('page', '1');
url.searchParams.append('filter', 'recent');
url.searchParams.append('filter', 'popular');
```

The automatic synchronization between `url.search` and `url.searchParams` means modifying parameters updates the serialized query string immediately, and vice versa.

### Multiple Values Per Parameter

URLSearchParams natively supports multiple values for a single parameter name through repeated `append()` calls. The `getAll(name)` method retrieves all values as an array, while `get(name)` returns only the first value.

This design accommodates server-side frameworks that parse repeated parameters into arrays, common in REST APIs for filtering or multi-select operations:

```javascript
url.searchParams.append('tag', 'javascript');
url.searchParams.append('tag', 'web');
url.searchParams.append('tag', 'api');

// Results in: ?tag=javascript&tag=web&tag=api
```

Using `set()` replaces all existing values, removing duplicates. This distinction matters when updating existing URLs where parameter count is unknown:

```javascript
// Replace all 'tag' parameters with a single value
url.searchParams.set('tag', 'javascript');
// Now only: ?tag=javascript
```

Deleting parameters removes all instances, regardless of how many values exist.

### Array and Object Serialization

[Inference] URLSearchParams provides no built-in array or object serialization—complex data structures require custom serialization strategies. Common approaches include JSON stringification, bracket notation, or repeated parameters.

JSON serialization encodes entire structures as single parameter values:

```javascript
const filters = { minPrice: 100, maxPrice: 500, inStock: true };
params.set('filters', JSON.stringify(filters));
// Results in: ?filters=%7B%22minPrice%22%3A100%2C%22maxPrice%22%3A500%2C%22inStock%22%3Atrue%7D
```

Bracket notation mimics PHP and Rails conventions, flattening nested structures:

```javascript
params.set('filters[minPrice]', '100');
params.set('filters[maxPrice]', '500');
params.set('filters[inStock]', 'true');
// Results in: ?filters[minPrice]=100&filters[maxPrice]=500&filters[inStock]=true
```

Repeated parameters represent arrays without explicit indices:

```javascript
['red', 'blue', 'green'].forEach(color => {
  params.append('colors', color);
});
// Results in: ?colors=red&colors=blue&colors=green
```

[Inference] Server-side interpretation of these patterns varies—some frameworks parse bracket notation automatically, while others require manual parsing or expect JSON. API documentation should specify expected parameter formats.

### URL Validation and Error Handling

The URL constructor throws a `TypeError` when provided invalid URLs. URLs must include a scheme (protocol), and relative URLs require a valid base. Malformed syntax like missing colons, invalid characters in hostnames, or unparseable ports trigger errors.

```javascript
try {
  const url = new URL('not a valid url');
} catch (error) {
  console.error('Invalid URL:', error.message);
}
```

URL validation occurs during construction, not during property modification. Setting invalid values for properties like `port` (non-numeric strings) or `protocol` (invalid schemes) may silently fail or coerce values rather than throwing.

The `URL.canParse()` static method (added in more recent specifications) provides validation without exception handling:

```javascript
if (URL.canParse(urlString)) {
  const url = new URL(urlString);
}
```

[Unverified] Browser support for `URL.canParse()` may be incomplete as of late 2024—checking compatibility before relying on this method is advisable.

### Pathname Manipulation

The `pathname` property represents the URL's path component, starting with `/` for absolute paths. Setting `pathname` automatically encodes special characters except forward slashes, which serve as path segment separators.

```javascript
url.pathname = '/api/users/search';
url.pathname = '/files/document name.pdf'; // Encodes spaces
```

Path segments containing literal forward slashes require percent-encoding before assignment to prevent misinterpretation as segment separators. The encoding must be manual, as setting `pathname` treats all slashes as separators.

Building paths from segments benefits from joining with slashes while ensuring proper encoding:

```javascript
const segments = ['api', 'users', userId, 'posts'];
url.pathname = '/' + segments.map(encodeURIComponent).join('/');
```

The pathname doesn't automatically normalize `..` or `.` segments—these remain literal unless the URL is reparsed through the constructor or explicitly normalized.

### Hash Fragment Handling

The `hash` property contains the URL fragment identifier, including the leading `#`. Setting `hash` to a value without `#` automatically prepends it. Empty string assignment removes the fragment entirely.

```javascript
url.hash = 'section-2'; // Sets to '#section-2'
url.hash = '#section-2'; // Also sets to '#section-2'
url.hash = ''; // Removes hash
```

Fragment values receive percent-encoding for special characters. Fragments don't transmit to servers in HTTP requests—they're purely client-side, used for document anchors and client-side routing.

The fragment can contain any URL-encodable content, making it suitable for encoding application state in single-page applications:

```javascript
url.hash = JSON.stringify({ tab: 'settings', modal: 'open' });
```

### URL Modification Patterns

Modifying existing URLs while preserving certain components requires selective property updates. Common patterns include changing only the pathname while maintaining parameters:

```javascript
const currentUrl = new URL(window.location.href);
currentUrl.pathname = '/new/path';
// Parameters, hash, and origin remain unchanged
```

Adding parameters to existing URLs without disturbing others:

```javascript
const url = new URL(existingUrl);
url.searchParams.set('newParam', 'value');
// Existing parameters remain
```

Removing specific parameters while keeping others requires explicit deletion:

```javascript
url.searchParams.delete('unwantedParam');
// All other parameters preserved
```

Clearing all parameters while maintaining the rest of the URL:

```javascript
url.search = ''; // Removes all parameters
// Or
url.searchParams = new URLSearchParams(); // Alternative approach
```

[Inference] The `url.searchParams = new URLSearchParams()` assignment may not work in all environments—directly modifying `url.search` is more universally compatible.

### Base URL Resolution

Relative URLs resolve against a base URL through the constructor's second parameter. Resolution follows RFC 3986 rules, handling absolute paths, relative paths, query-only, and fragment-only URLs.

```javascript
// Absolute path replaces entire path
new URL('/api/users', 'https://example.com/old/path');
// Results in: https://example.com/api/users

// Relative path appends to base path
new URL('users', 'https://example.com/api/');
// Results in: https://example.com/api/users

// Query-only preserves base path
new URL('?page=2', 'https://example.com/api/users');
// Results in: https://example.com/api/users?page=2

// Fragment-only preserves everything except fragment
new URL('#section-2', 'https://example.com/page?x=1');
// Results in: https://example.com/page?x=1#section-2
```

Relative paths without leading slashes append to the base path's directory. Paths with leading slashes replace the entire path component. The base URL must be absolute—relative bases aren't supported.

Path normalization occurs during resolution, removing redundant `.` segments and resolving `..` segments to parent directories:

```javascript
new URL('../api/users', 'https://example.com/old/path/');
// Results in: https://example.com/old/api/users
```

### Username and Password in URLs

URLs support embedded authentication credentials through `username` and `password` properties, appearing in the format `protocol://username:password@hostname/path`.

```javascript
const url = new URL('https://example.com');
url.username = 'admin';
url.password = 'secret';
// Results in: https://admin:secret@example.com/
```

[Inference] Embedding credentials in URLs is generally discouraged for security reasons—credentials appear in browser history, server logs, and referrer headers. Modern authentication uses headers (Authorization) or cookies rather than URL credentials.

Browsers often display warnings or strip credentials from visible URLs while still sending them in requests. Some contexts, particularly HTTPS to HTTP transitions, may refuse to send credentials to prevent credential exposure.

Reading credentials from externally provided URLs requires explicit extraction:

```javascript
const externalUrl = new URL(untrustedInput);
if (externalUrl.username || externalUrl.password) {
  // Handle or strip credentials
}
```

### Port Handling

The `port` property represents the port number as a string. Empty string indicates the default port for the protocol (80 for HTTP, 443 for HTTPS). Setting port to protocol defaults automatically clears the port from the serialized URL.

```javascript
const url = new URL('https://example.com:443/path');
console.log(url.port); // '443'
url.port = ''; // Removes explicit port
console.log(url.href); // 'https://example.com/path'
```

Non-numeric port values or invalid port numbers may be rejected or cause errors during assignment. Valid ports range from 1 to 65535.

The `host` property combines hostname and port as `hostname:port`, while `hostname` excludes the port. Setting `host` with a port string updates both hostname and port atomically:

```javascript
url.host = 'newhost.com:8080';
console.log(url.hostname); // 'newhost.com'
console.log(url.port); // '8080'
```

### Protocol Switching

Changing the `protocol` property updates the URL scheme. The protocol must include the trailing colon or it's added automatically:

```javascript
url.protocol = 'wss:'; // WebSocket secure
url.protocol = 'wss'; // Also valid, colon added automatically
```

Protocol changes may affect default port interpretation. Switching from `http:` to `https:` with an explicit port 80 leaves port 80 in place, creating `https://example.com:80`, which is unusual but valid.

[Inference] Security policies in browsers may restrict protocol changes in certain contexts, particularly changing from HTTPS to HTTP for security reasons. Content Security Policy and mixed content rules apply.

### Converting Between URL and String

The `toString()` and `toJSON()` methods serialize URLs to strings, equivalent to accessing the `href` property. This enables automatic string conversion in contexts expecting strings:

```javascript
const url = new URL('https://example.com/path');
console.log(url.toString()); // 'https://example.com/path'
console.log(String(url)); // Same result
console.log(`Navigating to ${url}`); // Template literal conversion
```

JSON serialization with `JSON.stringify()` calls `toJSON()`, which returns the URL string:

```javascript
const data = { endpoint: url };
JSON.stringify(data); // {"endpoint":"https://example.com/path"}
```

Converting strings to URLs for manipulation and back to strings is a common pattern for URL transformation:

```javascript
function addParam(urlString, key, value) {
  const url = new URL(urlString);
  url.searchParams.set(key, value);
  return url.toString();
}
```

### URLSearchParams Independence

URLSearchParams can be instantiated independently from URL objects, useful for working with query strings in isolation or building form data:

```javascript
const params = new URLSearchParams();
params.set('search', 'javascript');
params.set('category', 'tutorial');

const queryString = params.toString();
// Use in fetch or form submission
```

Detached URLSearchParams instances don't automatically synchronize with URLs. Changes to a detached instance don't affect the URL it originated from:

```javascript
const url = new URL('https://example.com?x=1');
const params = new URLSearchParams(url.search);
params.set('y', '2');
console.log(url.search); // Still '?x=1'
console.log(params.toString()); // 'x=1&y=2'
```

Synchronization requires explicit assignment back to the URL:

```javascript
url.search = params.toString();
```

### Parameter Sorting

URLSearchParams maintains insertion order for parameters. The `sort()` method arranges parameters alphabetically by key, useful for generating canonical URLs or cache keys:

```javascript
const params = new URLSearchParams('z=3&a=1&m=2');
params.sort();
console.log(params.toString()); // 'a=1&m=2&z=3'
```

Sorting occurs in-place, modifying the URLSearchParams instance directly. Multiple values for the same key remain grouped together after sorting, maintaining their relative order.

Sorted parameters enable consistent URL comparisons and cache key generation:

```javascript
function getCacheKey(url) {
  const parsed = new URL(url);
  parsed.searchParams.sort();
  return parsed.toString();
}
```

### Working with FormData

URLSearchParams and FormData serve similar purposes but differ in encoding and use cases. URLSearchParams handles URL query parameters with `application/x-www-form-urlencoded` encoding, while FormData manages `multipart/form-data` for file uploads and form submissions.

Converting between them requires iteration:

```javascript
// FormData to URLSearchParams
const formData = new FormData(formElement);
const params = new URLSearchParams();
for (const [key, value] of formData) {
  if (typeof value === 'string') {
    params.append(key, value);
  }
}

// URLSearchParams to FormData
const formData = new FormData();
for (const [key, value] of params) {
  formData.append(key, value);
}
```

[Inference] FormData with file inputs can't directly convert to URLSearchParams since files aren't representable as URL-encoded strings. The conversion only preserves string values.

### Immutability Patterns

URL objects are mutable—property modifications change the object in place. Creating immutable URL transformations requires cloning:

```javascript
function withParam(url, key, value) {
  const newUrl = new URL(url.href);
  newUrl.searchParams.set(key, value);
  return newUrl;
}

const original = new URL('https://example.com?x=1');
const modified = withParam(original, 'y', '2');
// original unchanged
```

Functional approaches to URL building maintain immutability throughout transformation chains:

```javascript
const buildUrl = (base) => ({
  setPath: (path) => {
    const url = new URL(base);
    url.pathname = path;
    return buildUrl(url.href);
  },
  addParam: (key, value) => {
    const url = new URL(base);
    url.searchParams.set(key, value);
    return buildUrl(url.href);
  },
  build: () => base
});

const finalUrl = buildUrl('https://api.example.com')
  .setPath('/users')
  .addParam('active', 'true')
  .addParam('limit', '50')
  .build();
```

### Special Character Handling

Certain characters have special meaning in URLs and require careful handling. The `#` character separates the fragment, `?` begins the query string, and `&` separates parameters. Using these literally in pathnames or parameter values requires percent-encoding.

The URL API handles most encoding automatically, but manual encoding may be necessary when constructing path segments:

```javascript
// Pathname with query-like characters
const filename = 'report?final&approved.pdf';
url.pathname = `/files/${encodeURIComponent(filename)}`;
// Results in: /files/report%3Ffinal%26approved.pdf
```

Parameter names and values encode automatically through URLSearchParams:

```javascript
params.set('search', 'price>100'); // Encodes >
params.set('filter', 'status=active'); // Encodes =
```

Unicode characters encode as UTF-8 byte sequences:

```javascript
params.set('name', '日本語'); // Properly encodes multi-byte characters
```

### Template URL Construction

Building URLs from templates with variable substitution benefits from helper functions:

```javascript
function buildUrl(template, params, query = {}) {
  // Replace path parameters
  let path = template;
  for (const [key, value] of Object.entries(params)) {
    path = path.replace(`:${key}`, encodeURIComponent(value));
  }
  
  const url = new URL(path, 'https://api.example.com');
  
  // Add query parameters
  for (const [key, value] of Object.entries(query)) {
    if (value !== undefined && value !== null) {
      url.searchParams.set(key, value);
    }
  }
  
  return url.toString();
}

buildUrl('/users/:id/posts/:postId', 
  { id: 123, postId: 456 },
  { include: 'comments', limit: 10 }
);
// https://api.example.com/users/123/posts/456?include=comments&limit=10
```

Template systems can handle optional parameters, default values, and validation before URL construction.

### URL Parsing from Current Location

Browser environments provide `window.location` as a Location object with similar properties to URL but with live updates. Converting Location to URL enables manipulation without affecting browser state:

```javascript
const currentUrl = new URL(window.location.href);
currentUrl.searchParams.set('page', '2');
// Doesn't navigate, just creates modified URL
```

Relative URL construction against the current page:

```javascript
const relativeUrl = new URL('/api/data', window.location.href);
// Resolves relative to current page origin and path
```

Extracting current query parameters for modification:

```javascript
const params = new URLSearchParams(window.location.search);
params.delete('tempParam');
const cleanedUrl = `${window.location.pathname}?${params.toString()}`;
```

---

