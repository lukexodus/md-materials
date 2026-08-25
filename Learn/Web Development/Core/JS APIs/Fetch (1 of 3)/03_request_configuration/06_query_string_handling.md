## Query String Handling


### URLSearchParams Interface

The URLSearchParams interface defines utility methods to work with the query string of a URL.

**Key characteristics:**

- URLSearchParams objects are iterable, so they can directly be used in a for...of structure to iterate over key/value pairs in the same order as they appear in the query string
- Although URLSearchParams is functionally similar to a Map, when iterating, it may suffer from some pitfalls that Map doesn't encounter due to how it's implemented

---

### Constructor

#### URLSearchParams()

**Syntax:**

```javascript
new URLSearchParams()
new URLSearchParams(init)
```

**Parameter types:**

1. **String** - A query string (with or without leading `?`)
2. **Object literal** - Key-value pairs
3. **Array of arrays** - Sequence of name-value pairs
4. **FormData** - FormData object
5. **Another URLSearchParams** - Clones the object

**Examples:**

```javascript
// From query string
const params1 = new URLSearchParams('foo=1&bar=2');
const params2 = new URLSearchParams('?foo=1&bar=2'); // Leading ? is stripped

// From object literal
const params3 = new URLSearchParams({ foo: '1', bar: '2' });

// From array of arrays
const params4 = new URLSearchParams([
  ['foo', '1'],
  ['bar', '2']
]);

// From URL object's search property
const url = new URL('https://example.com?foo=1&bar=2');
const params5 = new URLSearchParams(url.search);

// From FormData
const form = document.querySelector('form');
const formData = new FormData(form);
const params6 = new URLSearchParams(formData);
```

**Important behaviors:**

- The URLSearchParams constructor does not parse full URLs. However, it will strip an initial leading ? off of a string, if present
- The URLSearchParams constructor interprets plus signs (+) as spaces, which might cause problems

---

### Instance Properties

#### `size` (Read-only)

**Type:** Number  
Indicates the total number of search parameter entries

```javascript
const params = new URLSearchParams('foo=1&bar=2&foo=3');
console.log(params.size); // 3
```

---

### Instance Methods

#### Reading Parameters

##### `get(name)`

Returns the first value associated with the given search parameter

**Returns:** String or `null` if not found

```javascript
const params = new URLSearchParams('foo=1&bar=2&foo=3');
console.log(params.get('foo')); // '1' (first value only)
console.log(params.get('baz')); // null
```

##### `getAll(name)`

Returns all the values associated with a given search parameter

**Returns:** Array of strings (empty array if not found)

```javascript
const params = new URLSearchParams('foo=1&bar=2&foo=3');
console.log(params.getAll('foo')); // ['1', '3']
console.log(params.getAll('baz')); // []
```

##### `has(name)` / `has(name, value)`

Returns a boolean value indicating if a given parameter, or parameter and value pair, exists

```javascript
const params = new URLSearchParams('foo=1&bar=2');
console.log(params.has('foo'));        // true
console.log(params.has('foo', '1'));   // true
console.log(params.has('foo', '2'));   // false
console.log(params.has('baz'));        // false
```

#### Modifying Parameters

##### `set(name, value)`

Sets the value associated with a given search parameter to the given value. If there are several values, the others are deleted

```javascript
const params = new URLSearchParams('foo=1&bar=2&foo=3');
params.set('foo', '999');
console.log(params.toString()); // 'foo=999&bar=2'

// Creates new parameter if it doesn't exist
params.set('baz', '4');
console.log(params.toString()); // 'foo=999&bar=2&baz=4'
```

##### `append(name, value)`

Appends a specified key/value pair as a new search parameter

```javascript
const params = new URLSearchParams('foo=1&bar=2');
params.append('foo', '3');
console.log(params.toString()); // 'foo=1&bar=2&foo=3'
```

**Note:** If the same key is appended multiple times, it will appear in the parameter string multiple times for each value

##### `delete(name)` / `delete(name, value)`

Deletes search parameters that match a name, and optional value, from the list of all search parameters

```javascript
const params = new URLSearchParams('foo=1&bar=2&foo=3');

// Delete all instances of a key
params.delete('foo');
console.log(params.toString()); // 'bar=2'

// Delete specific key-value pair
const params2 = new URLSearchParams('foo=1&bar=2&foo=3');
params2.delete('foo', '1');
console.log(params2.toString()); // 'bar=2&foo=3'
```

#### Utility Methods

##### `sort()`

Sorts all key/value pairs, if any, by their keys

```javascript
const params = new URLSearchParams('z=3&a=1&m=2');
params.sort();
console.log(params.toString()); // 'a=1&m=2&z=3'
```

##### `toString()`

Returns a string containing a query string suitable for use in a URL

```javascript
const params = new URLSearchParams({ foo: '1', bar: '2' });
console.log(params.toString()); // 'foo=1&bar=2'
```

#### Iteration Methods

##### `keys()`

Returns an iterator allowing iteration through all keys of the key/value pairs contained in this object

```javascript
const params = new URLSearchParams('foo=1&bar=2&foo=3');
for (const key of params.keys()) {
  console.log(key);
}
// Output: 'foo', 'bar', 'foo'
```

##### `values()`

Returns an iterator allowing iteration through all values of the key/value pairs contained in this object

```javascript
const params = new URLSearchParams('foo=1&bar=2&foo=3');
for (const value of params.values()) {
  console.log(value);
}
// Output: '1', '2', '3'
```

##### `entries()`

Returns an iterator allowing iteration through all key/value pairs contained in this object in the same order as they appear in the query string

```javascript
const params = new URLSearchParams('foo=1&bar=2');
for (const [key, value] of params.entries()) {
  console.log(`${key}: ${value}`);
}
// Output: 'foo: 1', 'bar: 2'
```

##### `forEach(callback)`

Allows iteration through all values contained in this object via a callback function

```javascript
const params = new URLSearchParams('foo=1&bar=2');
params.forEach((value, key) => {
  console.log(`${key}: ${value}`);
});
```

##### Direct iteration

```javascript
const params = new URLSearchParams('foo=1&bar=2');

// These two are equivalent
for (const [key, value] of params) {
  console.log(`${key}: ${value}`);
}

for (const [key, value] of params.entries()) {
  console.log(`${key}: ${value}`);
}
```

---

### Encoding Behavior

#### Percent Encoding

URLSearchParams objects percent-encode anything in the application/x-www-form-urlencoded percent-encode set (which contains all code points except ASCII alphanumeric, *, -, ., and _), and encode U+0020 SPACE as +

**Key points:**

- It only handles percent-encoding when serializing and deserializing full URL search params syntax. When interacting with individual keys and values, you always use the unencoded version

```javascript
// Percent-encoding is decoded when parsing
const params = new URLSearchParams('%24%25%26=%28%29%2B');
console.log([...params]); // [['$%&', '()+']]

// Use decoded keys to retrieve values
console.log(params.get('$%&')); // '()+'
console.log(params.get('%24%25%26')); // null

// Use unencoded keys and values when setting
params.append('$%&$#@+', '$#&*@#()+');

// Percent-encoding is applied when serializing
console.log(params.toString());
// '%24%25%26=%28%29%2B&%24%25%26%24%23%40%2B=%24%23%26*%40%23%28%29%2B'
```

**Warning:** If you append a key/value pair with a percent-encoded key, that key is treated as unencoded and is encoded again:

```javascript
const params = new URLSearchParams();
params.append('%24%26', 'value');
console.log(params.toString()); // '%2524%2526=value'
```

#### Preserving Plus Signs

The URLSearchParams constructor interprets plus signs (+) as spaces, which might cause problems

**Problem:**

```javascript
const rawData = '\x13à\x17@\x1F\x80';
const base64Data = btoa(rawData); // 'E+AXQB+A'

const searchParams = new URLSearchParams(`bin=${base64Data}`);
const binQuery = searchParams.get('bin'); // 'E AXQB A' - plus became space!

console.log(atob(binQuery) === rawData); // false
```

**Solution:** Never construct URLSearchParams using dynamically interpolated strings. Use `append()` instead:

```javascript
const rawData = '\x13à\x17@\x1F\x80';
const base64Data = btoa(rawData); // 'E+AXQB+A'

const searchParams = new URLSearchParams();
searchParams.append('bin', base64Data); // 'bin=E%2BAXQB%2BA'
const binQuery = searchParams.get('bin'); // 'E+AXQB+A'

console.log(atob(binQuery) === rawData); // true
```

---

### Special Cases

#### Empty Value vs. No Value

URLSearchParams doesn't distinguish between a parameter with nothing after the =, and a parameter that doesn't have a = altogether

```javascript
const emptyVal = new URLSearchParams('foo=&bar=baz');
console.log(emptyVal.get('foo')); // ''

const noEquals = new URLSearchParams('foo&bar=baz');
console.log(noEquals.get('foo')); // '' (same result)
console.log(noEquals.toString()); // 'foo=&bar=baz'
```

#### Duplicate Parameters

```javascript
const params = new URLSearchParams('foo=1&bar=2&foo=3');

console.log(params.has('foo'));      // true
console.log(params.get('foo'));      // '1' (first value only)
console.log(params.getAll('foo'));   // ['1', '3'] (all values)
console.log(params.toString());      // 'foo=1&bar=2&foo=3'
```

---

### Integration with URL

#### URL.searchParams Property

The URL.searchParams property exposes the URL's search string as a URLSearchParams object. When updating this URLSearchParams, the URL's search is updated with its serialization

```javascript
const url = new URL('https://example.com?foo=1&bar=2');
const params = url.searchParams;

params.set('baz', '3');
params.has('baz'); // true
console.log(params.toString()); // 'foo=1&bar=2&baz=3'
console.log(url.href); // 'https://example.com/?foo=1&bar=2&baz=3'
```

#### Encoding Differences

URL.search encodes a subset of characters that URLSearchParams does, and encodes spaces as %20 instead of +. This may cause some surprising interactions—if you update searchParams, even with the same values, the URL may be serialized differently

```javascript
const url = new URL('https://example.com/?a=b ~');
console.log(url.href);                    // 'https://example.com/?a=b%20~'
console.log(url.searchParams.toString()); // 'a=b+%7E'

// Updating searchParams changes URL's serialization
url.searchParams.sort();
console.log(url.href); // 'https://example.com/?a=b+%7E'
```

---

### Common Patterns

#### Reading Current Page's Query String

```javascript
// Get query params from current page
const params = new URLSearchParams(window.location.search);
const userId = params.get('userId');
const sortBy = params.get('sort');
```

#### Building API Request URLs

```javascript
const baseUrl = 'https://api.example.com/search';
const params = new URLSearchParams({
  q: 'javascript',
  page: '1',
  limit: '20'
});

const url = `${baseUrl}?${params.toString()}`;
// 'https://api.example.com/search?q=javascript&page=1&limit=20'

// Or use URL constructor
const apiUrl = new URL(baseUrl);
apiUrl.searchParams.set('q', 'javascript');
apiUrl.searchParams.set('page', '1');
apiUrl.searchParams.set('limit', '20');
```

#### Converting URLSearchParams to Object

```javascript
const params = new URLSearchParams('foo=1&bar=2&foo=3');

// Simple conversion (loses duplicate keys)
const obj = Object.fromEntries(params.entries());
// { foo: '3', bar: '2' } - only last 'foo' value kept

// Preserve all values
const objWithArrays = {};
for (const [key, value] of params) {
  if (objWithArrays[key]) {
    if (Array.isArray(objWithArrays[key])) {
      objWithArrays[key].push(value);
    } else {
      objWithArrays[key] = [objWithArrays[key], value];
    }
  } else {
    objWithArrays[key] = value;
  }
}
// { foo: ['1', '3'], bar: '2' }
```

#### Updating URL Without Page Reload

```javascript
const params = new URLSearchParams(window.location.search);
params.set('page', '2');
params.set('sort', 'date');

// Update browser URL without reload
window.history.replaceState(
  {},
  '',
  `${window.location.pathname}?${params}`
);
```

#### Using with fetch()

```javascript
const params = new URLSearchParams({
  userId: '123',
  includeDetails: 'true'
});

// GET request
fetch(`https://api.example.com/user?${params}`)
  .then(response => response.json())
  .then(data => console.log(data));

// POST with URLSearchParams as body
fetch('https://api.example.com/login', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/x-www-form-urlencoded'
  },
  body: params.toString()
});
```

---

### TypeScript Definition

```typescript
interface URLSearchParams {
  // Properties
  readonly size: number;
  
  // Methods
  append(name: string, value: string): void;
  delete(name: string, value?: string): void;
  get(name: string): string | null;
  getAll(name: string): string[];
  has(name: string, value?: string): boolean;
  set(name: string, value: string): void;
  sort(): void;
  toString(): string;
  
  // Iteration
  entries(): IterableIterator<[string, string]>;
  keys(): IterableIterator<string>;
  values(): IterableIterator<string>;
  forEach(
    callbackfn: (value: string, key: string, parent: URLSearchParams) => void,
    thisArg?: any
  ): void;
  
  [Symbol.iterator](): IterableIterator<[string, string]>;
}

interface URLSearchParamsConstructor {
  new(init?: string | URLSearchParams | Record<string, string> | [string, string][]): URLSearchParams;
}

declare var URLSearchParams: URLSearchParamsConstructor;
```

---

