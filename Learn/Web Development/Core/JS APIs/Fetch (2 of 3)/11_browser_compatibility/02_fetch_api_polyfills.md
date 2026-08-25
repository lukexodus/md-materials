## Fetch API Polyfills


### Purpose and Need

Polyfills provide fetch API functionality in environments where it's not natively supported. Primary targets include Internet Explorer 11, older versions of Safari, and Node.js versions prior to 18.0.0.

### whatwg-fetch

The canonical polyfill maintained by GitHub, implementing the WHATWG Fetch specification.

**Installation:**

```bash
npm install whatwg-fetch --save
```

**Basic Usage:**

```javascript
import 'whatwg-fetch';

// fetch is now available globally
fetch('/api/data')
  .then(response => response.json())
  .then(data => console.log(data));
```

**Features:**

- Implements the complete Fetch API surface including Request, Response, Headers
- Requires a Promise polyfill (e.g., `promise-polyfill`) for IE11
- Does not support streaming responses in older browsers
- Handles URL normalization and encoding
- Respects CORS behavior based on browser capabilities

**Limitations:**

- Cannot polyfill streaming in environments without ReadableStream support
- Does not implement request abortion in IE11 (no AbortController)
- File upload progress tracking unavailable
- Service Worker integration limited by browser capabilities

### node-fetch

Brings fetch API to Node.js environments, closely matching browser behavior.

**Installation:**

```bash
npm install node-fetch
```

**Usage:**

```javascript
import fetch from 'node-fetch';

const response = await fetch('https://api.example.com/data');
const data = await response.json();
```

**Node.js Specific Behaviors:**

- Supports both CommonJS and ESM
- Handles Node.js streams for request/response bodies
- Respects `http_proxy` and `https_proxy` environment variables
- Provides custom Agent support for connection pooling
- Implements `response.buffer()` method for binary data

**Version Differences:**

- v2.x: CommonJS, requires Node.js 4+
- v3.x: Pure ESM, requires Node.js 12.20+
- Node.js 18+: Native fetch available, polyfill unnecessary

**Advanced Configuration:**

```javascript
import fetch from 'node-fetch';
import https from 'https';

const agent = new https.Agent({
  rejectUnauthorized: false
});

const response = await fetch('https://self-signed.example.com', {
  agent
});
```

### cross-fetch

Universal polyfill working in both browser and Node.js environments.

**Installation:**

```bash
npm install cross-fetch
```

**Usage:**

```javascript
import fetch from 'cross-fetch';

// Works identically in browser and Node.js
fetch('https://api.example.com')
  .then(res => res.json())
  .then(data => console.log(data));
```

**Implementation:**

- Browser: Uses whatwg-fetch
- Node.js: Uses node-fetch
- Provides unified API across platforms
- Automatic environment detection
- No configuration needed for basic usage

### isomorphic-fetch

Another universal solution combining whatwg-fetch and node-fetch.

**Installation:**

```bash
npm install isomorphic-fetch
```

**Usage:**

```javascript
require('isomorphic-fetch');

// fetch now available globally in both environments
fetch('https://api.example.com')
  .then(res => res.json());
```

**Characteristics:**

- Automatically polyfills global fetch
- Older alternative to cross-fetch
- Less actively maintained
- Heavier bundle size compared to cross-fetch

### unfetch

Minimal fetch polyfill optimized for size.

**Installation:**

```bash
npm install unfetch
```

**Usage:**

```javascript
import fetch from 'unfetch';

fetch('/api')
  .then(r => r.json())
  .then(data => console.log(data));
```

**Tradeoffs:**

- Only ~1KB minified and gzipped
- Implements core fetch functionality only
- Missing advanced features:
    - No streaming support
    - No Request/Response constructors
    - No Headers manipulation
    - Limited error handling
- Best for simple GET/POST requests in size-constrained applications

### Implementation Considerations

**Dependency Requirements:**

[Inference] Most fetch polyfills require a Promise polyfill for IE11:

```javascript
import 'promise-polyfill/src/polyfill';
import 'whatwg-fetch';
```

**Conditional Loading:**

```javascript
// Only load polyfill if fetch is unavailable
if (!window.fetch) {
  require('whatwg-fetch');
}
```

**Webpack Configuration:**

```javascript
// webpack.config.js
module.exports = {
  entry: ['whatwg-fetch', './src/index.js'],
  // ...
};
```

**Feature Detection Pattern:**

```javascript
const fetchAPI = window.fetch || require('node-fetch');

fetchAPI('https://api.example.com')
  .then(response => response.json());
```

### AbortController Polyfill

Fetch abortion requires separate polyfilling:

**Installation:**

```bash
npm install abortcontroller-polyfill
```

**Usage:**

```javascript
import 'abortcontroller-polyfill/dist/polyfill-patch-fetch';

const controller = new AbortController();
const signal = controller.signal;

fetch('/api/data', { signal })
  .then(response => response.json())
  .catch(err => {
    if (err.name === 'AbortError') {
      console.log('Request aborted');
    }
  });

// Abort the request
controller.abort();
```

### Streams Polyfill

For environments lacking ReadableStream support:

**Installation:**

```bash
npm install web-streams-polyfill
```

**Usage:**

```javascript
import 'web-streams-polyfill';
import 'whatwg-fetch';

fetch('/large-file')
  .then(response => {
    const reader = response.body.getReader();
    return reader.read();
  });
```

### Testing Considerations

**Mocking Polyfilled Fetch:**

```javascript
// Using jest
global.fetch = require('jest-fetch-mock');

// Using sinon
const fetchStub = sinon.stub(window, 'fetch');
fetchStub.returns(Promise.resolve(new Response('{"data": "test"}')));
```

**Node.js Test Setup:**

```javascript
// test-setup.js
import fetch from 'node-fetch';

if (!globalThis.fetch) {
  globalThis.fetch = fetch;
  globalThis.Headers = fetch.Headers;
  globalThis.Request = fetch.Request;
  globalThis.Response = fetch.Response;
}
```

### Migration Paths

**From XMLHttpRequest Libraries:**

Gradual migration approach using adapter pattern:

```javascript
function fetchAdapter(config) {
  return fetch(config.url, {
    method: config.method,
    headers: config.headers,
    body: config.data
  }).then(response => {
    return {
      data: response.json(),
      status: response.status,
      statusText: response.statusText
    };
  });
}
```

**Removing Polyfills:**

When dropping legacy browser support:

```javascript
// Before
import 'whatwg-fetch';

// After (modern browsers only)
// Remove polyfill import entirely
```

### Bundle Size Impact

Approximate sizes (minified + gzipped):

- whatwg-fetch: ~3KB
- node-fetch: ~4KB (Node.js only)
- cross-fetch: ~1.5KB (wrapper)
- unfetch: ~1KB
- isomorphic-fetch: ~5KB

**Tree Shaking:**

[Inference] Modern bundlers can eliminate unused polyfill code when targeting environments with native fetch:

```javascript
// babel.config.js
module.exports = {
  presets: [
    ['@babel/preset-env', {
      targets: '> 0.5%, not dead',
      useBuiltIns: 'usage',
      corejs: 3
    }]
  ]
};
```

### Browser Compatibility Strategy

**Differential Serving:**

```javascript
// modern.js (no polyfills)
fetch('/api/data').then(r => r.json());

// legacy.js (with polyfills)
import 'whatwg-fetch';
fetch('/api/data').then(r => r.json());
```

**HTML Loading:**

```html
<script type="module" src="modern.js"></script>
<script nomodule src="legacy.js"></script>
```

This approach sends smaller bundles to modern browsers while maintaining compatibility with older environments.

---

