## URL and URLSearchParams


### What is a URL?

A **URL** (Uniform Resource Locator) is a reference to a web resource that specifies its location on a computer network and a mechanism for retrieving it. URLs are used to access web pages, images, videos, and other resources on the internet.

A typical URL structure looks like this:

```
https://www.example.com:8080/path/to/page?key1=value1&key2=value2#section
```

This breaks down into:
- **Protocol** (`https://`): The scheme used to access the resource
- **Domain** (`www.example.com`): The host server location
- **Port** (`:8080`): Optional port number
- **Path** (`/path/to/page`): The specific resource location
- **Query string** (`?key1=value1&key2=value2`): Parameters passed to the resource
- **Fragment** (`#section`): A specific section within the resource

### The URL API

JavaScript provides the `URL` API for parsing and manipulating URLs. This API is available in both browsers and Node.js environments.

#### Creating a URL Object

```javascript
// Absolute URL
const url = new URL('https://example.com/path?name=value');

// Relative URL (requires base URL)
const url2 = new URL('/path', 'https://example.com');
```

#### URL Properties

The `URL` object provides properties to access and modify different parts of the URL:

```javascript
const url = new URL('https://user:pass@example.com:8080/path/page?key=value#section');

console.log(url.href);       // Full URL
console.log(url.protocol);   // "https:"
console.log(url.username);   // "user"
console.log(url.password);   // "pass"
console.log(url.host);       // "example.com:8080"
console.log(url.hostname);   // "example.com"
console.log(url.port);       // "8080"
console.log(url.pathname);   // "/path/page"
console.log(url.search);     // "?key=value"
console.log(url.hash);       // "#section"
console.log(url.origin);     // "https://example.com:8080"
```

These properties are also writable, allowing you to modify the URL:

```javascript
url.pathname = '/new/path';
url.search = '?updated=true';
```

### URLSearchParams

The `URLSearchParams` API provides utilities for working with URL query strings. It makes it easy to read, modify, and construct query parameters.

#### Creating URLSearchParams

```javascript
// From a URL object
const url = new URL('https://example.com?name=John&age=30');
const params = url.searchParams;

// From a query string
const params2 = new URLSearchParams('name=John&age=30');

// From an object
const params3 = new URLSearchParams({ name: 'John', age: '30' });

// From an array of arrays
const params4 = new URLSearchParams([['name', 'John'], ['age', '30']]);
```

#### Reading Parameters

```javascript
const params = new URLSearchParams('name=John&age=30&hobby=reading&hobby=coding');

// Get a single value
params.get('name');        // "John"
params.get('missing');     // null

// Get all values for a key (useful for arrays)
params.getAll('hobby');    // ["reading", "coding"]

// Check if a key exists
params.has('name');        // true
params.has('missing');     // false

// Iterate over all parameters
params.forEach((value, key) => {
  console.log(`${key}: ${value}`);
});

// Get as an iterator
for (const [key, value] of params) {
  console.log(`${key}: ${value}`);
}
```

#### Modifying Parameters

```javascript
const params = new URLSearchParams('name=John&age=30');

// Set a parameter (replaces existing)
params.set('name', 'Jane');

// Append a parameter (doesn't replace)
params.append('hobby', 'reading');
params.append('hobby', 'coding');

// Delete a parameter
params.delete('age');

// Sort parameters alphabetically
params.sort();

// Convert to string
params.toString();  // "hobby=reading&hobby=coding&name=Jane"
```

#### Using with URL Objects

```javascript
const url = new URL('https://example.com/search');

// Modify query parameters
url.searchParams.set('q', 'javascript');
url.searchParams.set('page', '1');

console.log(url.href);  
// "https://example.com/search?q=javascript&page=1"

// Update the URL's search property
url.search = url.searchParams.toString();
```

### Practical Examples

#### Building a Search URL

```javascript
function buildSearchURL(baseUrl, filters) {
  const url = new URL(baseUrl);
  
  Object.entries(filters).forEach(([key, value]) => {
    if (Array.isArray(value)) {
      value.forEach(v => url.searchParams.append(key, v));
    } else if (value !== null && value !== undefined) {
      url.searchParams.set(key, value);
    }
  });
  
  return url.toString();
}

const searchUrl = buildSearchURL('https://api.example.com/products', {
  category: 'electronics',
  tags: ['sale', 'featured'],
  minPrice: 100
});
// "https://api.example.com/products?category=electronics&tags=sale&tags=featured&minPrice=100"
```

#### Parsing Query Parameters from Current Page

```javascript
// In a browser
const currentParams = new URLSearchParams(window.location.search);
const userId = currentParams.get('userId');
const filters = currentParams.getAll('filter');
```

#### URL Encoding and Decoding

The `URLSearchParams` API automatically handles encoding and decoding of special characters:

```javascript
const params = new URLSearchParams();
params.set('message', 'Hello World! Special chars: & = ?');

console.log(params.toString());
// "message=Hello+World%21+Special+chars%3A+%26+%3D+%3F"

console.log(params.get('message'));
// "Hello World! Special chars: & = ?"
```

### Browser and Environment Support

Both `URL` and `URLSearchParams` are widely supported in modern browsers and Node.js (version 10+). They are part of the WHATWG URL Standard and provide a standardized way to work with URLs across different JavaScript environments.

---

