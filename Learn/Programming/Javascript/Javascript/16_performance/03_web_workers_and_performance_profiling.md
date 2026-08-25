## Web Workers and Performance Profiling


### Understanding Web Workers

Web Workers provide a way to execute JavaScript code in background threads, separate from the main browser thread. This allows CPU-intensive operations to run without blocking the user interface, resulting in a more responsive application.

**Key Points**:

- Web Workers run in an isolated context with no direct access to the DOM
- Communication between workers and the main thread happens via message passing
- Workers enable true parallelism in JavaScript, which is otherwise single-threaded
- They're ideal for computationally expensive tasks that would otherwise freeze the UI
- Web Workers have limited access to browser APIs compared to the main thread

### Types of Web Workers

### Dedicated Workers

Dedicated Workers are the standard type of Web Worker that can only be accessed by the script that created them.

```javascript
// main.js
const worker = new Worker('worker.js');

worker.onmessage = function(event) {
  console.log('Result received from worker:', event.data);
};

worker.postMessage({
  action: 'compute',
  data: [1, 2, 3, 4, 5]
});

// worker.js
self.onmessage = function(event) {
  if (event.data.action === 'compute') {
    const result = performExpensiveOperation(event.data.data);
    self.postMessage(result);
  }
};

function performExpensiveOperation(data) {
  // CPU-intensive work
  return data.map(x => x * x).reduce((a, b) => a + b, 0);
}
```

### Shared Workers

Shared Workers can be accessed by multiple scripts or windows from the same origin.

```javascript
// main.js in tab/frame 1
const sharedWorker = new SharedWorker('shared-worker.js');

sharedWorker.port.onmessage = function(event) {
  console.log('Tab 1 received:', event.data);
};

sharedWorker.port.start();
sharedWorker.port.postMessage('Hello from Tab 1');

// main.js in tab/frame 2
const sharedWorker = new SharedWorker('shared-worker.js');

sharedWorker.port.onmessage = function(event) {
  console.log('Tab 2 received:', event.data);
};

sharedWorker.port.start();
sharedWorker.port.postMessage('Hello from Tab 2');

// shared-worker.js
const connections = [];

self.onconnect = function(event) {
  const port = event.ports[0];
  connections.push(port);
  
  port.onmessage = function(event) {
    // Broadcast message to all connected ports
    connections.forEach(connection => {
      connection.postMessage('Broadcast: ' + event.data);
    });
  };
  
  port.start();
};
```

### Service Workers

Service Workers act as proxy servers that sit between web applications, the browser, and the network. They're primarily used for caching and offline functionality.

```javascript
// Register service worker
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/service-worker.js')
    .then(registration => {
      console.log('Service Worker registered with scope:', registration.scope);
    })
    .catch(error => {
      console.error('Service Worker registration failed:', error);
    });
}

// service-worker.js
const CACHE_NAME = 'my-site-cache-v1';
const urlsToCache = [
  '/',
  '/styles/main.css',
  '/scripts/main.js',
  '/images/logo.png'
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => {
        return cache.addAll(urlsToCache);
      })
  );
});

self.addEventListener('fetch', event => {
  event.respondWith(
    caches.match(event.request)
      .then(response => {
        // Cache hit - return response
        if (response) {
          return response;
        }
        return fetch(event.request);
      }
    )
  );
});
```

### Web Worker Capabilities and Limitations

### Available APIs in Web Workers

Web Workers have access to a subset of JavaScript features and APIs:

```javascript
// Available in workers
self.importScripts('script1.js', 'script2.js'); // Load external scripts

// Timers
setTimeout(() => console.log('Delayed operation'), 1000);
setInterval(() => console.log('Repeated operation'), 5000);

// XHR and Fetch
fetch('https://api.example.com/data')
  .then(response => response.json())
  .then(data => self.postMessage(data));

// IndexedDB for storage
const dbRequest = indexedDB.open('WorkerDB', 1);
dbRequest.onupgradeneeded = function(event) {
  const db = event.target.result;
  db.createObjectStore('data', { keyPath: 'id' });
};

// Web Crypto for cryptographic operations
crypto.subtle.digest('SHA-256', data).then(hash => {
  self.postMessage({ hash: new Uint8Array(hash) });
});

// Promises, async/await
async function processData(data) {
  const result = await complexCalculation(data);
  return result;
}
```

### Limitations of Web Workers

```javascript
// NOT available in workers (these would cause errors)

// DOM Access
// document.querySelector('div'); // Error!

// Window Object
// window.localStorage.setItem('key', 'value'); // Error!

// Direct parent manipulation
// parent.document.body.style.background = 'red'; // Error!

// Some global objects like localStorage, sessionStorage
// localStorage.getItem('key'); // Error!
```

### Practical Use Cases for Web Workers

### Complex Calculations

```javascript
// main.js
const calculateBtn = document.getElementById('calculate');
const resultElement = document.getElementById('result');
const statusElement = document.getElementById('status');

const worker = new Worker('calc-worker.js');

worker.onmessage = function(event) {
  resultElement.textContent = `Result: ${event.data.result}`;
  statusElement.textContent = 'Calculation completed';
  calculateBtn.disabled = false;
};

calculateBtn.addEventListener('click', function() {
  const size = parseInt(document.getElementById('size').value);
  statusElement.textContent = 'Calculating...';
  calculateBtn.disabled = true;
  worker.postMessage({ action: 'calculate', size: size });
});

// calc-worker.js
self.onmessage = function(event) {
  if (event.data.action === 'calculate') {
    const result = calculatePrimes(event.data.size);
    self.postMessage({ result: result });
  }
};

function calculatePrimes(max) {
  const sieve = new Array(max).fill(true);
  sieve[0] = false;
  sieve[1] = false;
  
  for (let i = 2; i <= Math.sqrt(max); i++) {
    if (sieve[i]) {
      for (let j = i * i; j < max; j += i) {
        sieve[j] = false;
      }
    }
  }
  
  return sieve.filter(Boolean).length;
}
```

### Image Processing

```javascript
// main.js
const fileInput = document.getElementById('imageInput');
const canvas = document.getElementById('outputCanvas');
const ctx = canvas.getContext('2d');
const worker = new Worker('image-worker.js');

worker.onmessage = function(event) {
  const imageData = event.data.imageData;
  canvas.width = imageData.width;
  canvas.height = imageData.height;
  ctx.putImageData(imageData, 0, 0);
};

fileInput.addEventListener('change', function(e) {
  const file = e.target.files[0];
  if (file) {
    const reader = new FileReader();
    reader.onload = function(e) {
      const img = new Image();
      img.onload = function() {
        canvas.width = img.width;
        canvas.height = img.height;
        ctx.drawImage(img, 0, 0);
        const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height);
        worker.postMessage({ 
          action: 'grayscale', 
          imageData: imageData,
          // Transfer the buffer to avoid copying
        }, [imageData.data.buffer]);
      };
      img.src = e.target.result;
    };
    reader.readAsDataURL(file);
  }
});

// image-worker.js
self.onmessage = function(event) {
  if (event.data.action === 'grayscale') {
    const imageData = event.data.imageData;
    const data = imageData.data;
    
    for (let i = 0; i < data.length; i += 4) {
      const avg = (data[i] + data[i + 1] + data[i + 2]) / 3;
      data[i] = avg;     // Red
      data[i + 1] = avg; // Green
      data[i + 2] = avg; // Blue
      // Alpha remains unchanged
    }
    
    self.postMessage({ imageData: imageData }, [imageData.data.buffer]);
  }
};
```

### Data Processing and Parsing

```javascript
// main.js
const fileInput = document.getElementById('csvInput');
const resultDiv = document.getElementById('results');
const worker = new Worker('csv-worker.js');

worker.onmessage = function(event) {
  if (event.data.status === 'progress') {
    document.getElementById('progress').textContent = `Processed ${event.data.processed}%`;
  } else if (event.data.status === 'complete') {
    // Display results
    resultDiv.innerHTML = `
      <h3>CSV Analysis</h3>
      <p>Total Rows: ${event.data.totalRows}</p>
      <p>Average Value: ${event.data.average.toFixed(2)}</p>
      <p>Max Value: ${event.data.max}</p>
      <p>Min Value: ${event.data.min}</p>
    `;
  }
};

fileInput.addEventListener('change', function(e) {
  const file = e.target.files[0];
  if (file) {
    resultDiv.textContent = 'Processing...';
    const reader = new FileReader();
    reader.onload = function(e) {
      worker.postMessage({
        action: 'parseCSV',
        data: e.target.result
      });
    };
    reader.readAsText(file);
  }
});

// csv-worker.js
self.importScripts('https://cdnjs.cloudflare.com/ajax/libs/PapaParse/5.3.0/papaparse.min.js');

self.onmessage = function(event) {
  if (event.data.action === 'parseCSV') {
    const results = {
      totalRows: 0,
      sum: 0,
      max: -Infinity,
      min: Infinity,
      average: 0
    };
    
    Papa.parse(event.data.data, {
      header: true,
      dynamicTyping: true,
      step: function(row, parser) {
        results.totalRows++;
        
        // Assuming we're analyzing a numeric column named "value"
        if (row.data.value) {
          results.sum += row.data.value;
          results.max = Math.max(results.max, row.data.value);
          results.min = Math.min(results.min, row.data.value);
        }
        
        if (results.totalRows % 1000 === 0) {
          self.postMessage({
            status: 'progress',
            processed: Math.round((parser.streamer._input.indexOf(parser.streamer._nextChunk) / 
                                  parser.streamer._input.length) * 100)
          });
        }
      },
      complete: function() {
        results.average = results.sum / results.totalRows;
        self.postMessage({
          status: 'complete',
          ...results
        });
      }
    });
  }
};
```

### Advanced Web Worker Patterns

### Worker Pools

Creating a pool of workers to handle multiple tasks in parallel:

```javascript
// worker-pool.js
class WorkerPool {
  constructor(size, workerScript) {
    this.size = size;
    this.workerScript = workerScript;
    this.workers = [];
    this.queue = [];
    this.activeWorkers = 0;
    
    this.init();
  }
  
  init() {
    for (let i = 0; i < this.size; i++) {
      const worker = new Worker(this.workerScript);
      
      worker.onmessage = (event) => {
        this.activeWorkers--;
        const callback = this.workers[i].callback;
        if (callback) {
          callback(null, event.data);
          this.workers[i].callback = null;
        }
        this.processQueue();
      };
      
      worker.onerror = (error) => {
        this.activeWorkers--;
        const callback = this.workers[i].callback;
        if (callback) {
          callback(error, null);
          this.workers[i].callback = null;
        }
        this.processQueue();
      };
      
      this.workers.push({
        worker: worker,
        callback: null
      });
    }
  }
  
  processQueue() {
    if (this.queue.length > 0 && this.activeWorkers < this.size) {
      const task = this.queue.shift();
      this.runTask(task.data, task.callback);
    }
  }
  
  runTask(data, callback) {
    for (let i = 0; i < this.size; i++) {
      if (!this.workers[i].callback) {
        this.workers[i].callback = callback;
        this.workers[i].worker.postMessage(data);
        this.activeWorkers++;
        return;
      }
    }
    
    // All workers busy, queue the task
    this.queue.push({ data, callback });
  }
  
  terminate() {
    this.workers.forEach(w => w.worker.terminate());
    this.workers = [];
  }
}

// Usage
const pool = new WorkerPool(4, 'task-worker.js');

for (let i = 0; i < 100; i++) {
  pool.runTask({ id: i, work: 'someTask' }, (error, result) => {
    if (error) {
      console.error(`Task ${i} failed:`, error);
    } else {
      console.log(`Task ${i} completed:`, result);
    }
  });
}
```

### Transferable Objects

Efficiently transferring large data between the main thread and workers:

```javascript
// main.js
const buffer = new ArrayBuffer(32 * 1024 * 1024); // 32MB buffer
const view = new Uint8Array(buffer);

// Fill with data
for (let i = 0; i < view.length; i++) {
  view[i] = i % 256;
}

console.log('Buffer size before transfer:', buffer.byteLength);

const worker = new Worker('transfer-worker.js');

// Transfer ownership of the buffer to the worker
worker.postMessage({ buffer }, [buffer]);

console.log('Buffer size after transfer:', buffer.byteLength); // Will be 0

worker.onmessage = function(event) {
  const receivedBuffer = event.data.processedBuffer;
  console.log('Received buffer size:', receivedBuffer.byteLength);
  
  // Do something with the returned buffer
  const newView = new Uint8Array(receivedBuffer);
  console.log('First few values:', newView.slice(0, 10));
};

// transfer-worker.js
self.onmessage = function(event) {
  const receivedBuffer = event.data.buffer;
  console.log('Received buffer in worker:', receivedBuffer.byteLength);
  
  // Process the buffer
  const view = new Uint8Array(receivedBuffer);
  for (let i = 0; i < view.length; i++) {
    view[i] = view[i] * 2; // Double each value
  }
  
  // Transfer the buffer back to main thread
  self.postMessage({ processedBuffer: receivedBuffer }, [receivedBuffer]);
};
```

### Inline Workers with Blob URLs

Creating workers dynamically without separate files:

```javascript
// Create a worker from a string
function createInlineWorker(workerFunction) {
  // Convert the function to a string and wrap it
  const workerCode = `
    (${workerFunction.toString()})();
  `;
  
  const blob = new Blob([workerCode], { type: 'application/javascript' });
  const workerUrl = URL.createObjectURL(blob);
  const worker = new Worker(workerUrl);
  
  // Clean up when the worker is no longer needed
  worker.terminate = (function(terminate) {
    return function() {
      terminate.call(this);
      URL.revokeObjectURL(workerUrl);
    };
  })(worker.terminate);
  
  return worker;
}

// Example usage
const worker = createInlineWorker(function() {
  self.onmessage = function(event) {
    const result = event.data.x * event.data.y;
    self.postMessage({ result });
  };
});

worker.onmessage = function(event) {
  console.log('Calculation result:', event.data.result);
};

worker.postMessage({ x: 10, y: 20 });

// Later, when done
worker.terminate();
```

### Performance Profiling

### Understanding Performance Profiling

Performance profiling is the process of measuring and analyzing the runtime behavior of your application to identify bottlenecks and optimization opportunities.

**Key Points**:

- Profiling helps identify where time is spent in your application
- It helps pinpoint memory leaks and excessive DOM operations
- Modern browsers provide built-in developer tools for profiling
- Profiling should be done in production-like environments
- Both synthetic benchmarks and real user monitoring provide valuable insights

### Browser Developer Tools

### Chrome Performance Panel

The Chrome Performance panel (formerly Timeline) is a comprehensive tool for recording and analyzing runtime performance.

```javascript
// Programmatically start and stop performance recording
// This can be useful for automating performance tests

// Start recording
console.time('performanceTest');
performance.mark('testStart');

// Run the code you want to profile
complexOperation();

// Stop recording
performance.mark('testEnd');
performance.measure('Test Duration', 'testStart', 'testEnd');
console.timeEnd('performanceTest');

// Log the measurements
const measures = performance.getEntriesByType('measure');
console.table(measures);
```

Key areas to analyze in the Performance panel:

1. **FPS Chart**: Shows frames per second; drops indicate jank
2. **CPU Chart**: Shows CPU utilization across different categories
3. **Main Thread Flame Chart**: Shows call stacks and execution time
4. **Network Requests**: Shows when resources are requested and loaded
5. **Frames Section**: Shows individual frame timings
6. **Interactions**: User input events like clicks and scrolls

### Memory Panel

The Memory panel helps identify memory leaks and excessive memory usage.

```javascript
// Example of code that might cause memory leaks
let leakyData = [];

function addData() {
  // Appends objects but never cleans them up
  for (let i = 0; i < 10000; i++) {
    leakyData.push({
      id: Math.random(),
      data: new Array(1000).fill('x'),
      timestamp: Date.now()
    });
  }
  
  // Schedule next addition
  setTimeout(addData, 5000);
}

addData();

// Better version that limits size
let betterData = [];
const MAX_ITEMS = 100;

function addDataWithLimit() {
  // Add new items
  for (let i = 0; i < 10; i++) {
    betterData.push({
      id: Math.random(),
      data: new Array(1000).fill('x'),
      timestamp: Date.now()
    });
  }
  
  // Trim if too large
  if (betterData.length > MAX_ITEMS) {
    betterData = betterData.slice(-MAX_ITEMS);
  }
  
  setTimeout(addDataWithLimit, 5000);
}
```

### JavaScript Profiler

The JavaScript Profiler shows where execution time is spent in your JavaScript code.

```javascript
// Code with potential performance issues
function inefficientSort(array) {
  console.profile('Sorting'); // Start profiling (Chrome only)
  
  // Bubble sort (inefficient for large arrays)
  for (let i = 0; i < array.length; i++) {
    for (let j = 0; j < array.length - 1; j++) {
      if (array[j] > array[j + 1]) {
        const temp = array[j];
        array[j] = array[j + 1];
        array[j + 1] = temp;
      }
    }
  }
  
  console.profileEnd(); // End profiling (Chrome only)
  return array;
}

// Generate large array
const largeArray = Array.from({ length: 5000 }, () => Math.random());
inefficientSort(largeArray);
```

### Lighthouse

Lighthouse is an automated tool for improving web page quality, including performance.

```javascript
// Example of applying Lighthouse recommendations

// Problem: Large images
<img src="large-image.jpg" width="300" height="200">

// Solution: Properly sized and optimized images
<img 
  srcset="image-300w.jpg 300w, image-600w.jpg 600w, image-1200w.jpg 1200w"
  sizes="(max-width: 600px) 300px, (max-width: 1200px) 600px, 1200px"
  src="image-fallback.jpg"
  loading="lazy"
  width="300"
  height="200"
  alt="Optimized image"
>

// Problem: Render-blocking resources
<link rel="stylesheet" href="styles.css">
<script src="script.js"></script>

// Solution: Critical CSS inline and deferred JS
<style>
  /* Critical CSS for above-the-fold content */
</style>
<link rel="preload" href="styles.css" as="style" onload="this.rel='stylesheet'">
<script src="script.js" defer></script>
```

### Custom Performance Metrics

### User Timing API

The User Timing API provides methods for creating custom performance measurements.

```javascript
// Measuring specific operations
function processData(data) {
  performance.mark('processStart');
  
  // Step 1: Parse the data
  performance.mark('parseStart');
  const parsed = JSON.parse(data);
  performance.mark('parseEnd');
  performance.measure('Parsing', 'parseStart', 'parseEnd');
  
  // Step 2: Transform the data
  performance.mark('transformStart');
  const transformed = parsed.map(item => transformItem(item));
  performance.mark('transformEnd');
  performance.measure('Transformation', 'transformStart', 'transformEnd');
  
  // Step 3: Calculate results
  performance.mark('calculateStart');
  const result = calculateResults(transformed);
  performance.mark('calculateEnd');
  performance.measure('Calculation', 'calculateStart', 'calculateEnd');
  
  performance.mark('processEnd');
  performance.measure('Total Processing', 'processStart', 'processEnd');
  
  // Log all measures
  const measures = performance.getEntriesByType('measure');
  console.table(measures);
  
  return result;
}

function transformItem(item) {
  // Some expensive transformation
  return { ...item, processed: true };
}

function calculateResults(items) {
  // Some expensive calculation
  return items.reduce((sum, item) => sum + (item.value || 0), 0);
}
```

### Long Tasks API

The Long Tasks API helps identify tasks that take more than 50ms to execute, which may cause jank.

```javascript
// Detecting long tasks
const observer = new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    console.log('Long task detected:', entry.duration, 'ms');
    console.log('Attribution:', entry.attribution);
  }
});

observer.observe({ entryTypes: ['longtask'] });

// Example of a long task
function simulateLongTask() {
  const start = Date.now();
  while (Date.now() - start < 100) {
    // Blocking the main thread for 100ms
  }
}

// Trigger long tasks periodically
setInterval(simulateLongTask, 2000);
```

### Web Vitals

Web Vitals are a set of quality signals that are essential to delivering a great user experience on the web.

```javascript
// Using the web-vitals library
import { getCLS, getFID, getLCP } from 'web-vitals';

function sendToAnalytics(metric) {
  // Send the metric to your analytics service
  const body = JSON.stringify(metric);
  navigator.sendBeacon('/analytics', body);
}

getCLS(sendToAnalytics);  // Cumulative Layout Shift
getFID(sendToAnalytics);  // First Input Delay
getLCP(sendToAnalytics);  // Largest Contentful Paint

// Example of addressing poor CLS
// Problem: Layout shifts when images load
<div class="image-container">
  <img src="image.jpg" alt="Description">
</div>

// Solution: Reserve space for the image
<div class="image-container" style="aspect-ratio: 16/9;">
  <img src="image.jpg" alt="Description" width="800" height="450">
</div>
```

### Common Performance Issues and Profiling Solutions

### Detecting Jank (Frame Rate Drops)

```javascript
// Detecting frame rate issues
let lastFrameTime = performance.now();
let frameCount = 0;
let lowFpsCount = 0;

function checkFrameRate() {
  const now = performance.now();
  const deltaTime = now - lastFrameTime;
  lastFrameTime = now;
  
  // Calculate FPS (with smoothing)
  const fps = 1000 / deltaTime;
  
  // Log when FPS drops below 30
  if (fps < 30) {
    console.warn(`Low FPS detected: ${fps.toFixed(1)}`);
    lowFpsCount++;
    
    // If we detect multiple low FPS frames, log a warning
    if (lowFpsCount > 5) {
      console.warn('Significant performance issue detected!');
      // Could trigger more detailed profiling here
    }
  } else {
    lowFpsCount = Math.max(0, lowFpsCount - 1);
  }
  
  frameCount++;
  requestAnimationFrame(checkFrameRate);
}

requestAnimationFrame(checkFrameRate);

// Periodically log average FPS
setInterval(() => {
  const fps = frameCount / (performance.now() - lastFrameTime) * 1000;
  console.log(`Average FPS: ${fps.toFixed(1)}`);
  frameCount = 0;
  lastFrameTime = performance.now();
}, 5000);
```

### Identifying Memory Leaks

```javascript
// Setup memory leak detection
let memoryUsage = [];
const MAX_SAMPLES = 10;

function checkMemory() {
  if (performance.memory) {
    const memory = performance.memory.usedJSHeapSize;
    memoryUsage.push(memory);
    
    if (memoryUsage.length > MAX_SAMPLES) {
      memoryUsage.shift();
      
      // Check if memory consistently increases
      let increasing = true;
      for (let i = 1; i < memoryUsage.length; i++) {
        if (memoryUsage[i] <= memoryUsage[i - 1]) {
          increasing = false;
          break;
        }
      }
      
      if (increasing) {
        console.warn('Possible memory leak detected!');
        console.log('Memory usage pattern:', memoryUsage);
      }
    }
  }
}

// Check memory every 5 seconds
setInterval(checkMemory, 5000);

// Example of a component with a memory leak
class LeakyComponent {
  constructor() {
    this.data = [];
    this.eventHandler = this.handleEvent.bind(this);
    window.addEventListener('resize', this.eventHandler);
    
    // Start accumulating data
    this.startDataCollection();
  }
  
  handleEvent() {
    console.log('Window resized');
  }
  
  startDataCollection() {
    setInterval(() => {
      this.data.push(new Array(10000).fill(Math.random()));
    }, 1000);
  }
  
  // Missing cleanup method
  // Should have:
  // dispose() {
  //   window.removeEventListener('resize', this.eventHandler);
  //   this.data = null;
  // }
}

// Create and later discard component without proper cleanup
let component = new LeakyComponent();
setTimeout(() => {
  component = null; // Event listener still attached, data collection continues
}, 10000);
```

### Profiling Network Bottlenecks

```javascript
// Monitor fetch performance
const originalFetch = window.fetch;
window.fetch = async function monitoredFetch(url, options) {
  const startTime = performance.now();
  try {
    const response = await originalFetch(url, options);
    const endTime = performance.now();
    
    console.log(`Fetch to ${url} took ${(endTime - startTime).toFixed(2)}ms`);
    
    // Analyze response size
    const clone = response.clone();
    const size = await clone.blob().then(blob => blob.size);
    console.log(`Response size: ${(size / 1024).toFixed(2)} KB`);
    
    // Check if size is excessive
    if (size > 1000000) { // 1MB
      console.warn(`Large response detected from ${url}`);
    }
    
    // Check if time is excessive
    if (endTime - startTime > 3000) { // 3 seconds
      console.warn(`Slow response from ${url}`);
    }
    
    return response;
  } catch (error) {
    const endTime = performance.now();
    console.error(`Fetch to ${url} failed after ${(endTime - startTime).toFixed(2)}ms:`, error);
    throw error;
  }
};

// Example fetch that might be slow
fetch('https://api.example.com/large-data')
  .then(response => response.json())
  .then(data => console.log('Data loaded'))
  .catch(error => console.error('Error:', error));
```

### React Performance Profiling

```jsx
// Using React Profiler component
import { Profiler } from 'react';

function onRenderCallback(
  id,          // the "id" prop of the Profiler tree
  phase,       // "mount" or "update"
  actualDuration, // time spent rendering
  baseDuration,   // estimated time to render entire subtree
  startTime,    // when rendering started
  commitTime,   // when rendering was committed
  interactions  // Set of "interactions" tracked for this render
) {
  // Log render performance
  console.log(`Component ${id} ${phase}:`);
  console.log(`Actual time: ${actualDuration.toFixed(2)}ms`);
  console.log(`Base time: ${baseDuration.toFixed(2)}ms`);
  
  // Report slow renders
  if (actualDuration > 16) { // 60fps threshold
    console.warn(`⚠️ Slow render detected in ${id} (${actualDuration.toFixed(2)}ms)`);
  }
}

function MyApp() {
  return (
    <Profiler id="MyApp" onRender={onRenderCallback}>
      <MainComponent />
    </Profiler>
  );
}
```

---

