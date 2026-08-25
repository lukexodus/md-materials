## Legacy Browser Support


### Polyfills and Shims

The Fetch API is not natively supported in Internet Explorer (any version) or older versions of Safari, Chrome, Firefox, and Edge. A polyfill provides the necessary functionality for these browsers.

The most widely used polyfill is `whatwg-fetch` (GitHub's fetch polyfill):

```javascript
// Installation via npm
npm install whatwg-fetch

// Usage
import 'whatwg-fetch';

// Or via CDN
<script src="https://cdn.jsdelivr.net/npm/whatwg-fetch@3.6.2/dist/fetch.umd.js"></script>
```

Alternative polyfills include `unfetch` (lighter weight) and `isomorphic-fetch` (for Node.js compatibility).

### Browser Support Matrix

**Native Support:**

- Chrome 42+ (April 2015)
- Firefox 39+ (July 2015)
- Safari 10.1+ (March 2017)
- Edge 14+ (August 2016)
- Opera 29+ (April 2015)

**No Native Support:**

- Internet Explorer (all versions)
- Safari < 10.1
- Android Browser < 4.4

### Polyfill Limitations

Polyfills cannot perfectly replicate all Fetch API features:

**Streaming Responses:** The `ReadableStream` interface used by `response.body` is difficult to polyfill. Most polyfills do not support streaming and must buffer the entire response.

**Request Abortion:** While modern polyfills support `AbortController`, older polyfills may not handle abortion correctly, particularly with XMLHttpRequest limitations.

**Upload Progress:** The Fetch API does not provide native upload progress events. Polyfills cannot add this functionality without additional APIs.

**Credentials Behavior:** Some polyfills may have subtle differences in how `credentials: 'include'` or `credentials: 'same-origin'` behave across domains.

### Feature Detection

Always check for fetch support before relying on it:

```javascript
if (window.fetch) {
  // Use fetch
  fetch('/api/data')
    .then(response => response.json())
    .then(data => console.log(data));
} else {
  // Fallback to XMLHttpRequest
  var xhr = new XMLHttpRequest();
  xhr.open('GET', '/api/data');
  xhr.onload = function() {
    console.log(JSON.parse(xhr.responseText));
  };
  xhr.send();
}
```

### XMLHttpRequest Fallback

For environments where polyfills are not suitable, XMLHttpRequest remains the fallback:

```javascript
function fetchWithFallback(url, options = {}) {
  if (window.fetch) {
    return fetch(url, options);
  }
  
  return new Promise((resolve, reject) => {
    const xhr = new XMLHttpRequest();
    xhr.open(options.method || 'GET', url);
    
    // Set headers
    if (options.headers) {
      Object.keys(options.headers).forEach(key => {
        xhr.setRequestHeader(key, options.headers[key]);
      });
    }
    
    xhr.onload = () => {
      resolve({
        ok: xhr.status >= 200 && xhr.status < 300,
        status: xhr.status,
        statusText: xhr.statusText,
        json: () => Promise.resolve(JSON.parse(xhr.responseText)),
        text: () => Promise.resolve(xhr.responseText)
      });
    };
    
    xhr.onerror = () => reject(new Error('Network error'));
    xhr.send(options.body || null);
  });
}
```

### Polyfill Dependencies

Fetch polyfills typically require additional polyfills for older browsers:

**Promise:** Fetch returns promises, so a Promise polyfill is required for IE11 and older browsers.

```javascript
npm install promise-polyfill
```

**URL API:** Some fetch operations require the URL constructor.

```javascript
npm install url-polyfill
```

**AbortController:** For request cancellation in older browsers.

```javascript
npm install abortcontroller-polyfill
```

**Symbol:** Some polyfills use ES6 Symbols.

```javascript
npm install core-js
```

### Implementation Strategy

**Progressive Enhancement:**

```javascript
// Load polyfills conditionally
if (!window.fetch) {
  // Dynamically load polyfill
  const script = document.createElement('script');
  script.src = '/polyfills/fetch.js';
  document.head.appendChild(script);
}
```

**Bundler Configuration:**

With Webpack, use `@babel/preset-env` with `useBuiltIns: 'usage'`:

```javascript
// babel.config.js
module.exports = {
  presets: [
    ['@babel/preset-env', {
      useBuiltIns: 'usage',
      corejs: 3,
      targets: {
        ie: '11'
      }
    }]
  ]
};
```

**Polyfill Service:**

Use polyfill.io to serve polyfills based on user agent:

```html
<script src="https://polyfill.io/v3/polyfill.min.js?features=fetch"></script>
```

### CORS Considerations

Older browsers have stricter CORS implementations. The `mode` option may behave differently:

**IE11 CORS:** Does not support `credentials: 'include'` for cross-origin requests in the same way modern browsers do. Use `xhr.withCredentials = true` in XMLHttpRequest fallbacks.

**Safari CORS:** Older Safari versions (< 10.1) may have issues with preflight requests and custom headers.

### Testing Legacy Support

Test in actual legacy browsers or use services:

**BrowserStack:** Provides real browser testing environments including IE11.

**Sauce Labs:** Cloud-based cross-browser testing.

**Local VMs:** Set up virtual machines with older Windows versions and IE11.

### Performance Implications

Polyfills add bundle size overhead:

- `whatwg-fetch`: ~6KB minified
- Promise polyfill: ~3KB minified
- AbortController polyfill: ~4KB minified

Consider code-splitting to serve polyfills only to browsers that need them.

### Headers API Compatibility

The Headers constructor has limited support in polyfills:

```javascript
// This may not work in all polyfilled environments
const headers = new Headers();
headers.append('Content-Type', 'application/json');

// Use plain objects for better compatibility
const headers = {
  'Content-Type': 'application/json'
};
```

### FormData and File Uploads

Older polyfills may have issues with `FormData`:

```javascript
// Modern approach
const formData = new FormData();
formData.append('file', fileInput.files[0]);

fetch('/upload', {
  method: 'POST',
  body: formData
});

// May need special handling in IE11
```

### Response Type Handling

Not all response types are well-supported:

**Blob Support:** `response.blob()` may not work correctly in polyfills. Buffer the response as an ArrayBuffer instead.

**ArrayBuffer Support:** `response.arrayBuffer()` has better support than streaming alternatives.

**FormData Response:** `response.formData()` is rarely supported in polyfills.

### HTTP/2 and Protocol Considerations

Legacy browsers may not support HTTP/2, affecting:

- Request multiplexing benefits
- Server push features
- Header compression

The fetch polyfill will work but won't provide HTTP/2 advantages on older browsers.

### Deprecation Timeline

**[Inference]** Most organizations have dropped IE11 support as of 2022-2023, following Microsoft's official end of support in June 2022. Polyfill usage is decreasing as the minimum supported browser versions increase.

---

