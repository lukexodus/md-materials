# Axios Comprehensive Guide

## What It Is

Axios is a promise-based HTTP client for both Node.js and the browser. In Node.js it uses the built-in `http`/`https` modules; in the browser it uses `XMLHttpRequest`. The same API works in both environments with no code changes.

It is not a fetch wrapper — it is an independent implementation with its own interceptor system, automatic transforms, and cancellation support.

---

## Installation

```bash
npm install axios
```

```js
// CommonJS
const axios = require('axios');

// ESM
import axios from 'axios';
```

Browser via CDN:

```html
<script src="https://cdn.jsdelivr.net/npm/axios/dist/axios.min.js"></script>
```

---

## Making Requests

### Shorthand methods

```js
axios.get(url, config)
axios.post(url, data, config)
axios.put(url, data, config)
axios.patch(url, data, config)
axios.delete(url, config)
axios.head(url, config)
axios.options(url, config)
```

### Generic method

```js
axios({
  method: 'post',
  url: '/users',
  data: { name: 'Luke' }
});
```

### Examples

```js
// GET
const res = await axios.get('https://api.example.com/users');
console.log(res.data);

// GET with query params
const res = await axios.get('/users', {
  params: { page: 2, limit: 20 }
});
// sends: GET /users?page=2&limit=20

// POST with JSON body
const res = await axios.post('/users', {
  name: 'Luke',
  role: 'admin'
});

// DELETE
await axios.delete(`/users/${id}`);
```

---

## The Response Object

Every resolved Axios promise yields a response object with these fields:

|Field|Type|Description|
|---|---|---|
|`data`|any|Response body, parsed automatically|
|`status`|number|HTTP status code|
|`statusText`|string|HTTP status message|
|`headers`|object|Response headers|
|`config`|object|The config used for the request|
|`request`|object|The underlying request object|

```js
const { data, status, headers } = await axios.get('/users');
```

---

## Request Configuration

All options can be passed as the `config` argument, or as the only argument to `axios()`.

### URL and method

```js
{
  url: '/users',
  method: 'get',           // default
  baseURL: 'https://api.example.com'
}
```

`baseURL` is prepended to `url` unless `url` is absolute.

### Headers

```js
{
  headers: {
    'Authorization': `Bearer ${token}`,
    'Content-Type': 'application/json',
    'X-Request-ID': uuid()
  }
}
```

Axios sets `Content-Type: application/json` automatically when the request body is a plain object.

### Query parameters

```js
{
  params: {
    page: 1,
    sort: 'desc'
  }
}
```

You can also provide a custom serializer:

```js
{
  params: { ids: [1, 2, 3] },
  paramsSerializer: (params) => qs.stringify(params, { arrayFormat: 'repeat' })
  // produces: ids=1&ids=2&ids=3
}
```

### Request body

```js
{
  data: { name: 'Luke' }   // plain object → serialized as JSON
}

{
  data: 'raw=string&form=value'  // string → sent as-is
}

{
  data: new FormData()     // FormData → multipart/form-data
}
```

### Timeout

```js
{
  timeout: 5000  // milliseconds; 0 = no timeout (default)
}
```

If the request takes longer than `timeout`, it is aborted and the error has `code: 'ECONNABORTED'`.

### Authentication

```js
{
  auth: {
    username: 'user',
    password: 'pass'
  }
  // Sets Authorization: Basic <base64>
}
```

### Response type

```js
{
  responseType: 'json'       // default — parses JSON automatically
  responseType: 'text'       // plain string
  responseType: 'blob'       // Blob (browser only)
  responseType: 'arraybuffer'
  responseType: 'stream'     // Node.js only
  responseType: 'document'   // browser only
}
```

### Validating status

By default, Axios treats any status outside `2xx` as an error. Override:

```js
{
  validateStatus: (status) => status < 500
  // 4xx responses resolve instead of reject
}
```

### Max redirects (Node.js)

```js
{
  maxRedirects: 5   // default; 0 = no redirects
}
```

### Max content length (Node.js)

```js
{
  maxContentLength: 10 * 1024 * 1024,  // 10 MB
  maxBodyLength: 10 * 1024 * 1024
}
```

### Proxy (Node.js)

```js
{
  proxy: {
    protocol: 'http',
    host: '127.0.0.1',
    port: 8080,
    auth: { username: 'user', password: 'pass' }
  }
}
```

Set `proxy: false` to bypass environment proxy variables (`HTTP_PROXY`, `HTTPS_PROXY`).

### Decompress

```js
{
  decompress: true  // default — decompresses gzip/deflate responses in Node.js
}
```

---

## Defaults

### Global defaults

```js
axios.defaults.baseURL = 'https://api.example.com';
axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;
axios.defaults.headers.post['Content-Type'] = 'application/json';
axios.defaults.timeout = 10000;
```

### Header precedence order

Config is merged in this order (later overrides earlier):

1. `axios.defaults`
2. Instance defaults (if using a custom instance)
3. Per-request config

---

## Custom Instances

Creating a custom instance isolates configuration from the global `axios` object. Recommended for any non-trivial application.

```js
const api = axios.create({
  baseURL: 'https://api.example.com/v1',
  timeout: 8000,
  headers: {
    'Accept': 'application/json'
  }
});

// Use like the global axios
const res = await api.get('/users');
```

Instances have their own defaults and interceptors, fully independent of the global instance.

---

## Interceptors

Interceptors let you run code before a request is sent or after a response is received, without modifying every call site.

### Request interceptor

```js
api.interceptors.request.use(
  (config) => {
    const token = getToken();
    if (token) config.headers['Authorization'] = `Bearer ${token}`;
    return config;
  },
  (error) => Promise.reject(error)
);
```

### Response interceptor

```js
api.interceptors.response.use(
  (response) => response,
  (error) => {
    if (error.response?.status === 401) {
      logout();
    }
    return Promise.reject(error);
  }
);
```

### Removing an interceptor

```js
const id = api.interceptors.request.use(handler);
api.interceptors.request.eject(id);
```

### Clearing all interceptors

```js
api.interceptors.request.clear();
api.interceptors.response.clear();
```

### Interceptor execution order

Multiple request interceptors run in reverse order of registration (LIFO). Multiple response interceptors run in registration order (FIFO).

```js
api.interceptors.request.use(A); // runs second
api.interceptors.request.use(B); // runs first
```

### Token refresh pattern

```js
let isRefreshing = false;
let queue = [];

api.interceptors.response.use(null, async (error) => {
  const original = error.config;

  if (error.response?.status !== 401 || original._retry) {
    return Promise.reject(error);
  }

  if (isRefreshing) {
    return new Promise((resolve, reject) => {
      queue.push({ resolve, reject });
    }).then((token) => {
      original.headers['Authorization'] = `Bearer ${token}`;
      return api(original);
    });
  }

  original._retry = true;
  isRefreshing = true;

  try {
    const token = await refreshAccessToken();
    queue.forEach(({ resolve }) => resolve(token));
    queue = [];
    original.headers['Authorization'] = `Bearer ${token}`;
    return api(original);
  } catch (err) {
    queue.forEach(({ reject }) => reject(err));
    queue = [];
    return Promise.reject(err);
  } finally {
    isRefreshing = false;
  }
});
```

---

## Error Handling

Axios rejects the promise on network errors and on HTTP errors (status outside `2xx` by default).

### Error shape

```js
try {
  await axios.get('/users');
} catch (err) {
  if (err.response) {
    // Server responded with a status outside 2xx
    console.log(err.response.status);
    console.log(err.response.data);
    console.log(err.response.headers);
  } else if (err.request) {
    // Request was sent but no response received
    console.log(err.request);
  } else {
    // Error setting up the request
    console.log(err.message);
  }
}
```

### `axios.isAxiosError()`

```js
if (axios.isAxiosError(err)) {
  // narrowed to AxiosError type
}
```

### Common error codes

|Code|Cause|
|---|---|
|`ECONNABORTED`|Request exceeded `timeout`|
|`ERR_NETWORK`|Network failure (DNS, TCP)|
|`ERR_CANCELED`|Request was manually cancelled|
|`ERR_BAD_RESPONSE`|Response could not be parsed|
|`ERR_BAD_REQUEST`|Invalid request config|

---

## Cancellation

### `AbortController` (recommended, Axios ≥ 1.x)

```js
const controller = new AbortController();

axios.get('/users', { signal: controller.signal });

// Cancel it
controller.abort();
```

### Cancelling on component unmount (React)

```js
useEffect(() => {
  const controller = new AbortController();

  axios.get('/users', { signal: controller.signal })
    .then((res) => setUsers(res.data))
    .catch((err) => {
      if (axios.isCancel(err)) return; // ignore cancellation
      setError(err);
    });

  return () => controller.abort();
}, []);
```

### `CancelToken` (deprecated)

Available in older versions. Replaced by `AbortController`. Do not use in new code.

---

## Transforms

Transform request or response data before it reaches your code or leaves your application.

### Default transforms

Axios automatically:

- Serializes plain objects to JSON on request.
- Parses JSON response bodies.

### Custom transforms

```js
{
  transformRequest: [
    (data, headers) => {
      headers['X-Sent-At'] = Date.now();
      return JSON.stringify(data);
    }
  ],
  transformResponse: [
    (data) => {
      const parsed = JSON.parse(data);
      return parsed.results ?? parsed;
    }
  ]
}
```

To extend rather than replace the defaults:

```js
import axios from 'axios';

{
  transformRequest: [
    ...axios.defaults.transformRequest,
    (data) => { /* additional transform */ return data; }
  ]
}
```

---

## File Uploads

### Node.js with `form-data`

```js
const FormData = require('form-data');
const fs = require('fs');

const form = new FormData();
form.append('file', fs.createReadStream('/path/to/file.pdf'));
form.append('userId', '42');

await axios.post('/upload', form, {
  headers: form.getHeaders()
});
```

### Browser with `FormData`

```js
const form = new FormData();
form.append('file', fileInput.files[0]);

await axios.post('/upload', form);
// Content-Type: multipart/form-data set automatically
```

### Upload progress (browser)

```js
await axios.post('/upload', form, {
  onUploadProgress: (event) => {
    const percent = Math.round((event.loaded / event.total) * 100);
    console.log(`${percent}%`);
  }
});
```

---

## Download Progress and Streaming

### Download progress (browser)

```js
const res = await axios.get('/file.zip', {
  responseType: 'blob',
  onDownloadProgress: (event) => {
    const percent = Math.round((event.loaded / event.total) * 100);
    console.log(`${percent}%`);
  }
});

const url = URL.createObjectURL(res.data);
```

### Streaming response (Node.js)

```js
const fs = require('fs');
const { pipeline } = require('stream/promises');

const res = await axios.get('https://example.com/large-file.zip', {
  responseType: 'stream'
});

await pipeline(res.data, fs.createWriteStream('./large-file.zip'));
```

---

## Concurrent Requests

```js
const [users, posts] = await Promise.all([
  api.get('/users'),
  api.get('/posts')
]);
```

`axios.all()` and `axios.spread()` are thin wrappers around `Promise.all` and destructuring. They are not deprecated but offer no real advantage over native syntax.

---

## TypeScript

Axios ships with built-in TypeScript declarations.

```ts
import axios, { AxiosResponse, AxiosError } from 'axios';

interface User {
  id: number;
  name: string;
}

// Generic type parameter types the response data
const res: AxiosResponse<User[]> = await axios.get<User[]>('/users');
const users: User[] = res.data;
```

### Typed instance

```ts
import axios from 'axios';

const api = axios.create({ baseURL: 'https://api.example.com' });

async function getUser(id: number): Promise<User> {
  const res = await api.get<User>(`/users/${id}`);
  return res.data;
}
```

### Typed error handling

```ts
import { AxiosError } from 'axios';

try {
  await api.get('/users');
} catch (err) {
  if (err instanceof AxiosError) {
    console.log(err.response?.status);
  }
}
```

---

## CSRF Protection

In browser environments, you can configure Axios to read a CSRF token from a cookie and attach it to requests as a header:

```js
const api = axios.create({
  xsrfCookieName: 'XSRF-TOKEN',   // cookie name to read
  xsrfHeaderName: 'X-XSRF-TOKEN'  // header name to set
});
```

This is a browser-only feature. In Node.js these options have no effect.

---

## Axios vs Fetch

|Concern|Axios|Fetch|
|---|---|---|
|JSON auto-parse|Yes|Manual `.json()` call|
|JSON auto-serialize|Yes|Manual `JSON.stringify()`|
|HTTP errors throw|Yes|No — only network errors throw|
|Request interceptors|Yes|No|
|Upload progress|Yes|No (streams API needed)|
|Timeout option|Yes|No (AbortController needed)|
|Node.js support|Yes|Native from Node 18|
|Bundle size|~13 KB gzip|Zero (built-in)|
|TypeScript types|Bundled|Bundled in `lib.dom.d.ts`|

---

## Full Production Example

```js
import axios from 'axios';

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL,
  timeout: 10000,
  headers: { 'Accept': 'application/json' }
});

// Attach token
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('token');
  if (token) config.headers['Authorization'] = `Bearer ${token}`;
  return config;
});

// Handle errors globally
api.interceptors.response.use(
  (res) => res,
  (err) => {
    if (err.response?.status === 401) {
      window.location.href = '/login';
    }
    if (err.response?.status >= 500) {
      console.error('Server error', err.response.data);
    }
    return Promise.reject(err);
  }
);

export default api;
```