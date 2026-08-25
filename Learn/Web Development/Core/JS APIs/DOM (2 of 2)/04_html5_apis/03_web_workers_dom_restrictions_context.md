## Web Workers (DOM Restrictions Context)


### The Fundamental Isolation Model

Web Workers execute in a completely separate global context from the main thread, with no access to the DOM, Window object, or Document object. This isolation is architectural—workers operate in a `WorkerGlobalScope` (or `DedicatedWorkerGlobalScope` for standard workers) that lacks any DOM APIs entirely.

The separation is enforced at the JavaScript engine level. Workers cannot:

- Access `document`, `window`, or any DOM nodes
- Manipulate HTML elements or their properties
- Read or write to `localStorage` or `sessionStorage`
- Access the parent window's global scope or variables
- Use `document.cookie`
- Directly call any function defined in the main thread

This creates a hard boundary where workers can compute, but cannot render or interact with the page structure.

### Available APIs in Workers

Despite DOM restrictions, workers retain access to substantial JavaScript functionality:

```javascript
// worker.js - Available APIs
self.console.log('Logging works');
self.setTimeout(() => {}, 1000);
self.setInterval(() => {}, 1000);

const data = await fetch('https://api.example.com/data');
const response = await data.json();

const ws = new WebSocket('wss://example.com');
const db = indexedDB.open('myDatabase');

importScripts('lib1.js', 'lib2.js'); // Synchronous script loading
```

**Core available APIs:**

- **Timers**: `setTimeout`, `setInterval`, `clearTimeout`, `clearInterval`
- **Network**: `fetch`, `XMLHttpRequest`, `WebSocket`, `EventSource`
- **Storage**: `IndexedDB`, `Cache API`
- **Workers**: Can spawn sub-workers (`new Worker()`)
- **Crypto**: `crypto.subtle` for cryptographic operations
- **Performance**: `performance.now()`, performance marks/measures
- **Console**: Full console API for debugging
- **Math**: All standard JavaScript built-ins (Math, Date, JSON, etc.)

### Message Passing Architecture

Communication occurs exclusively through structured cloning via `postMessage`:

```javascript
// main.js
const worker = new Worker('worker.js');

worker.postMessage({
  type: 'PROCESS_DATA',
  payload: { values: [1, 2, 3, 4, 5] }
});

worker.onmessage = (event) => {
  const { type, result } = event.data;
  if (type === 'RESULT') {
    updateDOM(result); // Main thread handles DOM
  }
};

// worker.js
self.onmessage = (event) => {
  const { type, payload } = event.data;
  
  if (type === 'PROCESS_DATA') {
    const result = heavyComputation(payload.values);
    self.postMessage({ type: 'RESULT', result });
  }
};
```

The structured clone algorithm serializes data deeply, supporting most JavaScript types but with limitations:

- **Supported**: primitives, objects, arrays, Date, RegExp, Map, Set, ArrayBuffer, TypedArrays, Blob, File, ImageData
- **Not supported**: Functions, DOM nodes, symbols, WeakMap, WeakSet, proxies with non-cloneable targets

Attempting to post DOM nodes fails immediately:

```javascript
// main.js
const element = document.querySelector('div');
worker.postMessage({ element }); // DOMException: Failed to execute 'postMessage'
```

### Transferable Objects and Zero-Copy

Transferable objects enable ownership transfer without copying, critical for large binary data:

```javascript
// main.js
const buffer = new ArrayBuffer(1024 * 1024 * 100); // 100MB
const view = new Uint8Array(buffer);
// Fill buffer with data...

worker.postMessage(
  { type: 'PROCESS', buffer: view.buffer },
  [view.buffer] // Transfer list
);

// buffer is now neutered (length becomes 0)
console.log(buffer.byteLength); // 0
```

After transfer:

- The sender's reference becomes detached (unusable)
- The receiver gains ownership without copying
- Performance is O(1) regardless of size

**Transferable types:**

- `ArrayBuffer`
- `MessagePort`
- `ImageBitmap`
- `OffscreenCanvas`
- `ReadableStream`, `WritableStream`, `TransformStream`

### Working Without DOM: Data Processing Patterns

Since workers cannot read DOM, the main thread must extract and send data:

```javascript
// main.js - Extract DOM data before sending
const tableRows = Array.from(document.querySelectorAll('table tr'));
const data = tableRows.map(row => ({
  cells: Array.from(row.cells).map(cell => cell.textContent),
  id: row.dataset.id
}));

worker.postMessage({ type: 'ANALYZE_TABLE', data });

worker.onmessage = (event) => {
  const { type, results } = event.data;
  
  if (type === 'ANALYSIS_COMPLETE') {
    // Update DOM with results
    results.forEach((result, index) => {
      tableRows[index].classList.toggle('highlight', result.shouldHighlight);
    });
  }
};
```

The pattern separates concerns:

1. **Main thread**: DOM reading → data extraction → message send → DOM writing
2. **Worker**: Data processing only
3. **Main thread**: Apply results to DOM

### Canvas Offloading with OffscreenCanvas

`OffscreenCanvas` enables canvas rendering in workers by transferring canvas control:

```javascript
// main.js
const canvas = document.querySelector('canvas');
const offscreen = canvas.transferControlToOffscreen();

worker.postMessage(
  { type: 'INIT_CANVAS', canvas: offscreen },
  [offscreen]
);

// main.js can no longer draw to this canvas

// worker.js
let ctx;

self.onmessage = (event) => {
  if (event.data.type === 'INIT_CANVAS') {
    ctx = event.data.canvas.getContext('2d');
    animate();
  }
};

function animate() {
  ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
  
  // Perform rendering
  ctx.fillRect(50, 50, 100, 100);
  
  requestAnimationFrame(animate); // Available in worker!
}
```

This pattern offloads rendering computation entirely, though the canvas remains in the document. The main thread loses drawing control but can still:

- Receive input events on the canvas element
- Forward interaction data to the worker via messages

```javascript
// main.js
canvas.addEventListener('click', (event) => {
  const rect = canvas.getBoundingClientRect();
  worker.postMessage({
    type: 'CANVAS_CLICK',
    x: event.clientX - rect.left,
    y: event.clientY - rect.top
  });
});
```

### Storage API Restrictions

Workers cannot access `localStorage` or `sessionStorage` as these are synchronous APIs tied to the document:

```javascript
// worker.js
try {
  localStorage.setItem('key', 'value'); // ReferenceError: localStorage is not defined
} catch (error) {
  console.error('localStorage unavailable');
}
```

Alternative storage in workers:

#### IndexedDB (Asynchronous)

```javascript
// worker.js
const request = indexedDB.open('WorkerDB', 1);

request.onupgradeneeded = (event) => {
  const db = event.target.result;
  db.createObjectStore('data', { keyPath: 'id' });
};

request.onsuccess = (event) => {
  const db = event.target.result;
  
  const transaction = db.transaction('data', 'readwrite');
  const store = transaction.objectStore('data');
  
  store.add({ id: 1, value: 'example' });
};
```

#### Cache API

```javascript
// worker.js
async function cacheData(key, data) {
  const cache = await caches.open('worker-cache');
  const response = new Response(JSON.stringify(data));
  await cache.put(key, response);
}

async function retrieveData(key) {
  const cache = await caches.open('worker-cache');
  const response = await cache.match(key);
  return response ? await response.json() : null;
}
```

#### Main Thread Proxying

For localStorage-like behavior, proxy through the main thread:

```javascript
// main.js
worker.onmessage = (event) => {
  const { type, key, value, id } = event.data;
  
  if (type === 'LOCALSTORAGE_GET') {
    const result = localStorage.getItem(key);
    worker.postMessage({ type: 'LOCALSTORAGE_RESPONSE', id, result });
  } else if (type === 'LOCALSTORAGE_SET') {
    localStorage.setItem(key, value);
    worker.postMessage({ type: 'LOCALSTORAGE_RESPONSE', id, success: true });
  }
};

// worker.js
class LocalStorageProxy {
  constructor() {
    this.pendingRequests = new Map();
    this.requestId = 0;
  }
  
  async getItem(key) {
    const id = this.requestId++;
    
    return new Promise((resolve) => {
      this.pendingRequests.set(id, resolve);
      self.postMessage({ type: 'LOCALSTORAGE_GET', key, id });
    });
  }
  
  handleResponse(data) {
    const { id, result } = data;
    const resolve = this.pendingRequests.get(id);
    if (resolve) {
      resolve(result);
      this.pendingRequests.delete(id);
    }
  }
}

const storage = new LocalStorageProxy();

self.onmessage = (event) => {
  if (event.data.type === 'LOCALSTORAGE_RESPONSE') {
    storage.handleResponse(event.data);
  }
};

// Usage
const value = await storage.getItem('myKey');
```

### Event Handling Limitations

Workers cannot directly attach to DOM events since they lack access to elements:

```javascript
// worker.js
// This fails - no document object
document.addEventListener('click', handler); // ReferenceError
```

The main thread must capture events and relay them:

```javascript
// main.js
document.addEventListener('mousemove', (event) => {
  worker.postMessage({
    type: 'MOUSE_MOVE',
    x: event.clientX,
    y: event.clientY,
    timestamp: performance.now()
  });
});

// worker.js
const mousePositions = [];

self.onmessage = (event) => {
  if (event.data.type === 'MOUSE_MOVE') {
    mousePositions.push({
      x: event.data.x,
      y: event.data.y,
      time: event.data.timestamp
    });
    
    // Compute mouse velocity, patterns, etc.
    analyzeMouseBehavior(mousePositions);
  }
};
```

For high-frequency events, throttle or batch:

```javascript
// main.js
let pendingMouseData = [];
let rafScheduled = false;

document.addEventListener('mousemove', (event) => {
  pendingMouseData.push({
    x: event.clientX,
    y: event.clientY,
    timestamp: performance.now()
  });
  
  if (!rafScheduled) {
    rafScheduled = true;
    requestAnimationFrame(() => {
      worker.postMessage({
        type: 'MOUSE_BATCH',
        events: pendingMouseData
      });
      pendingMouseData = [];
      rafScheduled = false;
    });
  }
});
```

### Network Requests and CORS

Workers can make network requests but inherit the page's origin and CORS restrictions:

```javascript
// worker.js
async function fetchData() {
  try {
    const response = await fetch('https://api.example.com/data', {
      credentials: 'include', // Sends cookies
      headers: {
        'Content-Type': 'application/json'
      }
    });
    
    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Fetch failed:', error);
  }
}
```

CORS policies apply identically to worker requests. Cookies and authentication credentials are sent based on `credentials` mode, using the main document's cookie jar.

Workers can use `XMLHttpRequest` with full feature parity to the main thread:

```javascript
// worker.js
function xhrRequest(url) {
  return new Promise((resolve, reject) => {
    const xhr = new XMLHttpRequest();
    xhr.open('GET', url);
    
    xhr.onload = () => {
      if (xhr.status >= 200 && xhr.status < 300) {
        resolve(xhr.response);
      } else {
        reject(new Error(`HTTP ${xhr.status}`));
      }
    };
    
    xhr.onerror = () => reject(new Error('Network error'));
    xhr.send();
  });
}
```

### Import and Module Loading

Workers can load additional scripts synchronously via `importScripts`:

```javascript
// worker.js
importScripts('utils.js', 'math-lib.js');

// Now use functions from imported scripts
const result = utilFunction();
```

`importScripts` blocks execution until all scripts load and execute, following the order specified. Relative URLs resolve relative to the worker script location.

Module workers support ES6 imports:

```javascript
// main.js
const worker = new Worker('worker.js', { type: 'module' });

// worker.js
import { calculate } from './math-lib.js';
import lodash from 'https://cdn.example.com/lodash.js';

self.onmessage = (event) => {
  const result = calculate(event.data);
  self.postMessage(result);
};
```

Module workers enable:

- Static imports with proper dependency resolution
- Top-level await
- Better tree-shaking and optimization
- Standard ES module semantics

Classic workers vs. module workers differ in scope:

```javascript
// Classic worker - global scope pollution
// worker.js
var globalVar = 'accessible everywhere';

// Module worker - module scope
// worker.js
const moduleVar = 'not globally accessible';
export function publicAPI() {} // Explicit exports needed
```

### Accessing Worker-Specific APIs

Workers have unique APIs unavailable to the main thread:

```javascript
// worker.js

// Close the worker from inside
self.close(); // Worker terminates, cannot be restarted

// Global scope reference
console.log(self === globalThis); // true in workers

// Worker location info
console.log(self.location.href); // Worker script URL

// Import additional workers
const subWorker = new Worker('sub-worker.js');
```

The worker's global scope lacks:

- `window` object
- `document` object
- `parent`, `top` window references
- Any DOM-related constructors (HTMLElement, Node, etc.)
- Navigation APIs (history, location manipulation)
- Alert/confirm/prompt dialogs

### Communication Error Handling

Message passing can fail silently if data isn't clonable:

```javascript
// main.js
const worker = new Worker('worker.js');

worker.onerror = (error) => {
  console.error('Worker error:', error.message, error.filename, error.lineno);
};

worker.onmessageerror = (event) => {
  console.error('Message deserialization failed');
};

try {
  worker.postMessage({
    func: () => {} // Functions not clonable
  });
} catch (error) {
  console.error('PostMessage failed:', error);
}
```

Handling uncaught exceptions in workers:

```javascript
// worker.js
self.onerror = (event) => {
  console.error('Uncaught error in worker:', event.message);
  
  // Report to main thread
  self.postMessage({
    type: 'ERROR',
    message: event.message,
    filename: event.filename,
    lineno: event.lineno
  });
  
  // Prevent default (suppress console error)
  event.preventDefault();
};

self.onunhandledrejection = (event) => {
  console.error('Unhandled promise rejection:', event.reason);
  
  self.postMessage({
    type: 'UNHANDLED_REJECTION',
    reason: event.reason
  });
  
  event.preventDefault();
};
```

### Shared Workers and Multiple Contexts

Shared Workers introduce port-based messaging since multiple pages can connect:

```javascript
// main.js
const sharedWorker = new SharedWorker('shared-worker.js');

sharedWorker.port.onmessage = (event) => {
  console.log('Received:', event.data);
};

sharedWorker.port.postMessage('Hello from page');
sharedWorker.port.start(); // Required for shared workers

// shared-worker.js
const connections = [];

self.onconnect = (event) => {
  const port = event.ports[0];
  connections.push(port);
  
  port.onmessage = (event) => {
    // Broadcast to all connected pages
    connections.forEach(p => {
      if (p !== port) {
        p.postMessage(event.data);
      }
    });
  };
  
  port.start();
};
```

Shared workers lack DOM access identically to dedicated workers but enable cross-tab coordination without main thread involvement.

### WorkerNavigator and Environment Detection

Workers have a limited `navigator` object:

```javascript
// worker.js
console.log(navigator.userAgent);
console.log(navigator.language);
console.log(navigator.hardwareConcurrency); // CPU core count
console.log(navigator.onLine); // Network status

// Available but limited
console.log(navigator.cookieEnabled); // undefined - no cookies
console.log(navigator.geolocation); // undefined - no geolocation
```

Detect worker context:

```javascript
function isWorkerContext() {
  return typeof WorkerGlobalScope !== 'undefined' && 
         self instanceof WorkerGlobalScope;
}

function isMainThread() {
  return typeof window !== 'undefined';
}
```

### Blob URLs and Inline Workers

Create workers without separate files:

```javascript
// main.js
const workerCode = `
  self.onmessage = (event) => {
    const result = event.data * 2;
    self.postMessage(result);
  };
`;

const blob = new Blob([workerCode], { type: 'application/javascript' });
const workerUrl = URL.createObjectURL(blob);
const worker = new Worker(workerUrl);

worker.onmessage = (event) => {
  console.log('Result:', event.data);
};

worker.postMessage(5);

// Clean up when done
worker.terminate();
URL.revokeObjectURL(workerUrl);
```

This enables dynamic worker generation but sacrifices caching and debugging convenience. Source maps won't work naturally with blob workers.

### Service Workers and DOM Context

Service Workers operate identically to Web Workers regarding DOM restrictions but have additional APIs:

```javascript
// service-worker.js (no DOM access)

self.addEventListener('fetch', (event) => {
  // Cannot access document, but can intercept all network requests
  event.respondWith(
    caches.match(event.request).then(response => {
      return response || fetch(event.request);
    })
  );
});

self.addEventListener('message', (event) => {
  // Communication with pages via postMessage
  const { type, data } = event.data;
  
  if (type === 'CACHE_URLS') {
    caches.open('v1').then(cache => {
      cache.addAll(data.urls);
    });
  }
});

// Access clients (pages) but not their DOM
self.clients.matchAll().then(clients => {
  clients.forEach(client => {
    client.postMessage({ type: 'UPDATE_AVAILABLE' });
  });
});
```

Service workers gain network interception and push notifications but lose nothing regarding DOM—they never had access to begin with.

### Debugging Workers Without DOM

Without DOM inspection, debugging relies on:

```javascript
// worker.js

// Console API works fully
console.log('Simple log');
console.table([{ id: 1, name: 'test' }]);
console.time('operation');
// ... work ...
console.timeEnd('operation');

// Performance marks
performance.mark('start-computation');
// ... work ...
performance.mark('end-computation');
performance.measure('computation', 'start-computation', 'end-computation');

// Report to main thread for visualization
const entries = performance.getEntriesByType('measure');
self.postMessage({
  type: 'PERFORMANCE_DATA',
  measures: entries.map(e => ({
    name: e.name,
    duration: e.duration
  }))
});
```

Chrome DevTools shows workers in a separate thread panel with full debugging support: breakpoints, step execution, scope inspection, and console evaluation within worker context.

### Data URL Workers and CSP

Workers respect Content Security Policy, which may block blob or data URLs:

```javascript
// Blocked by strict CSP
const worker = new Worker('data:application/javascript,self.postMessage("test")');
```

With CSP `worker-src` directive, specify allowed sources:

```
Content-Security-Policy: worker-src 'self' blob:
```

When CSP blocks worker creation, the constructor throws:

```javascript
try {
  const worker = new Worker('data:...');
} catch (error) {
  console.error('Worker blocked by CSP:', error);
  // Fallback to main thread execution
}
```

### Practical Pattern: Virtual DOM Diffing

Since workers can't access DOM, they can compute virtual DOM changes:

```javascript
// main.js
const worker = new Worker('vdom-worker.js');
let currentVDOM = getInitialVDOM();

worker.postMessage({
  type: 'COMPUTE_DIFF',
  oldTree: currentVDOM,
  newTree: getNewVDOM()
});

worker.onmessage = (event) => {
  const { type, patches } = event.data;
  
  if (type === 'PATCHES') {
    applyPatchesToDOM(patches);
    currentVDOM = event.data.newTree;
  }
};

function applyPatchesToDOM(patches) {
  patches.forEach(patch => {
    const element = document.querySelector(patch.selector);
    switch (patch.type) {
      case 'UPDATE_TEXT':
        element.textContent = patch.value;
        break;
      case 'SET_ATTRIBUTE':
        element.setAttribute(patch.name, patch.value);
        break;
      case 'REMOVE_NODE':
        element.remove();
        break;
    }
  });
}

// vdom-worker.js
function computeDiff(oldTree, newTree) {
  const patches = [];
  // Diffing algorithm here
  return patches;
}

self.onmessage = (event) => {
  const { oldTree, newTree } = event.data;
  const patches = computeDiff(oldTree, newTree);
  
  self.postMessage({
    type: 'PATCHES',
    patches,
    newTree
  });
};
```

This offloads expensive diffing while keeping DOM manipulation on the main thread where it must occur.

---

