## Performance Monitoring (DOM/JS)


### Performance APIs

#### Navigation Timing API

The Navigation Timing API exposes timing information for document navigation through `performance.timing` (deprecated) and `performance.getEntriesByType('navigation')`.

```javascript
const [navEntry] = performance.getEntriesByType('navigation');

// Critical metrics
const dnsTime = navEntry.domainLookupEnd - navEntry.domainLookupStart;
const tcpTime = navEntry.connectEnd - navEntry.connectStart;
const ttfb = navEntry.responseStart - navEntry.requestStart;
const domInteractive = navEntry.domInteractive - navEntry.fetchStart;
const domComplete = navEntry.domComplete - navEntry.fetchStart;
const loadComplete = navEntry.loadEventEnd - navEntry.fetchStart;
```

Key timestamps include: `fetchStart`, `domainLookupStart`, `domainLookupEnd`, `connectStart`, `secureConnectionStart`, `connectEnd`, `requestStart`, `responseStart`, `responseEnd`, `domInteractive`, `domContentLoadedEventStart`, `domContentLoadedEventEnd`, `domComplete`, `loadEventStart`, `loadEventEnd`.

#### Resource Timing API

Tracks loading performance for individual resources (scripts, stylesheets, images, XHR, fetch).

```javascript
const resources = performance.getEntriesByType('resource');

resources.forEach(resource => {
  const duration = resource.duration;
  const transferSize = resource.transferSize; // Bytes transferred
  const encodedSize = resource.encodedBodySize; // Compressed size
  const decodedSize = resource.decodedBodySize; // Uncompressed size
  
  // Check for cache hits
  if (transferSize === 0) {
    console.log(`${resource.name} served from cache`);
  }
  
  // Resource timing breakdown
  const dns = resource.domainLookupEnd - resource.domainLookupStart;
  const tcp = resource.connectEnd - resource.connectStart;
  const ttfb = resource.responseStart - resource.requestStart;
  const download = resource.responseEnd - resource.responseStart;
});
```

#### User Timing API

Creates custom performance markers and measures for application-specific timing.

```javascript
// Mark specific points
performance.mark('component-render-start');
// ... rendering logic
performance.mark('component-render-end');

// Measure duration between marks
performance.measure(
  'component-render',
  'component-render-start',
  'component-render-end'
);

const measures = performance.getEntriesByName('component-render');
console.log(`Render took ${measures[0].duration}ms`);

// Clear marks and measures
performance.clearMarks();
performance.clearMeasures();
```

#### PerformanceObserver API

Monitors performance entries asynchronously without polling, reducing overhead.

```javascript
// Observe specific entry types
const observer = new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    // Process entries
    if (entry.entryType === 'largest-contentful-paint') {
      console.log('LCP:', entry.renderTime || entry.loadTime);
    }
  }
});

observer.observe({ 
  entryTypes: ['navigation', 'resource', 'paint', 'measure'],
  buffered: true // Get entries that occurred before observation
});

// Observe multiple types with different configs
observer.observe({ type: 'largest-contentful-paint', buffered: true });
observer.observe({ type: 'layout-shift', buffered: true });
```

### Core Web Vitals

#### Largest Contentful Paint (LCP)

Measures loading performance by tracking when the largest content element becomes visible.

```javascript
let lcp = 0;

const observer = new PerformanceObserver((list) => {
  const entries = list.getEntries();
  const lastEntry = entries[entries.length - 1];
  lcp = lastEntry.renderTime || lastEntry.loadTime;
  
  // Send to analytics
  sendToAnalytics({ metric: 'LCP', value: lcp });
});

observer.observe({ type: 'largest-contentful-paint', buffered: true });
```

Target: < 2.5s (good), 2.5s-4s (needs improvement), > 4s (poor)

Elements considered: `<img>`, `<image>` inside `<svg>`, `<video>`, elements with background images via CSS, block-level elements containing text.

#### First Input Delay (FID)

Measures interactivity by tracking the delay between user interaction and browser response.

```javascript
const observer = new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    const fid = entry.processingStart - entry.startTime;
    console.log('FID:', fid);
    
    // Additional context
    console.log('Event type:', entry.name);
    console.log('Target:', entry.target);
  }
});

observer.observe({ type: 'first-input', buffered: true });
```

Target: < 100ms (good), 100ms-300ms (needs improvement), > 300ms (poor)

Only measures discrete events: clicks, taps, key presses (not scrolling or zooming).

#### Cumulative Layout Shift (CLS)

Tracks visual stability by measuring unexpected layout shifts.

```javascript
let clsScore = 0;

const observer = new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    // Only count shifts not caused by user interaction
    if (!entry.hadRecentInput) {
      clsScore += entry.value;
      
      // Identify shifting elements
      console.log('Shifted elements:', entry.sources);
    }
  }
});

observer.observe({ type: 'layout-shift', buffered: true });
```

Target: < 0.1 (good), 0.1-0.25 (needs improvement), > 0.25 (poor)

Score = impact fraction × distance fraction. Impact fraction measures viewport area affected; distance fraction measures movement distance.

#### Interaction to Next Paint (INP)

Successor to FID, measuring overall responsiveness by tracking all interactions.

```javascript
const observer = new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    const duration = entry.duration;
    const interactionType = entry.name; // 'click', 'keydown', etc.
    
    console.log(`${interactionType} took ${duration}ms`);
    
    // Break down into phases
    const inputDelay = entry.processingStart - entry.startTime;
    const processingTime = entry.processingEnd - entry.processingStart;
    const presentationDelay = entry.startTime + entry.duration - entry.processingEnd;
  }
});

observer.observe({ type: 'event', buffered: true, durationThreshold: 16 });
```

Target: < 200ms (good), 200ms-500ms (needs improvement), > 500ms (poor)

### DOM Performance Monitoring

#### Mutation Observer

Monitors DOM changes efficiently without polling.

```javascript
const observer = new MutationObserver((mutations) => {
  const startTime = performance.now();
  
  mutations.forEach((mutation) => {
    if (mutation.type === 'childList') {
      console.log('Nodes added:', mutation.addedNodes.length);
      console.log('Nodes removed:', mutation.removedNodes.length);
    } else if (mutation.type === 'attributes') {
      console.log('Attribute changed:', mutation.attributeName);
    }
  });
  
  const endTime = performance.now();
  console.log(`Processing took ${endTime - startTime}ms`);
});

observer.observe(document.body, {
  childList: true,
  subtree: true,
  attributes: true,
  attributeOldValue: true,
  characterData: true
});
```

[Inference] Large numbers of mutations processed synchronously can cause performance issues; batching or debouncing may be necessary.

#### Intersection Observer

Efficiently tracks element visibility without scroll event listeners.

```javascript
const observer = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      console.log('Element visible:', entry.intersectionRatio);
      console.log('Bounding rect:', entry.boundingClientRect);
      
      // Lazy load images
      if (entry.target.dataset.src) {
        entry.target.src = entry.target.dataset.src;
        observer.unobserve(entry.target);
      }
    }
  });
}, {
  root: null, // viewport
  rootMargin: '50px',
  threshold: [0, 0.25, 0.5, 0.75, 1]
});

document.querySelectorAll('img[data-src]').forEach(img => {
  observer.observe(img);
});
```

#### Resize Observer

Monitors element size changes without polling or resize event listeners.

```javascript
const observer = new ResizeObserver((entries) => {
  for (const entry of entries) {
    const { width, height } = entry.contentRect;
    console.log(`Element resized to ${width}x${height}`);
    
    // Access different box models
    const borderBox = entry.borderBoxSize[0];
    const contentBox = entry.contentBoxSize[0];
    
    // Respond to size changes
    if (width < 600) {
      entry.target.classList.add('compact');
    }
  }
});

observer.observe(document.querySelector('.container'));
```

### JavaScript Execution Monitoring

#### Long Tasks API

Identifies tasks blocking the main thread for > 50ms.

```javascript
const observer = new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    console.log('Long task detected:', entry.duration);
    console.log('Started at:', entry.startTime);
    
    // Attribution data (limited for privacy)
    if (entry.attribution) {
      console.log('Container type:', entry.attribution[0].containerType);
      console.log('Container name:', entry.attribution[0].containerName);
    }
  }
});

observer.observe({ type: 'longtask', buffered: true });
```

Breaking up long tasks:

```javascript
// Using setTimeout to yield to browser
function processLargeArray(items) {
  let index = 0;
  const chunkSize = 100;
  
  function processChunk() {
    const end = Math.min(index + chunkSize, items.length);
    
    for (; index < end; index++) {
      // Process item
      heavyOperation(items[index]);
    }
    
    if (index < items.length) {
      setTimeout(processChunk, 0);
    }
  }
  
  processChunk();
}

// Using requestIdleCallback
function deferredWork(items) {
  function process(deadline) {
    while (deadline.timeRemaining() > 0 && items.length > 0) {
      const item = items.shift();
      heavyOperation(item);
    }
    
    if (items.length > 0) {
      requestIdleCallback(process);
    }
  }
  
  requestIdleCallback(process);
}
```

#### Frame Timing

Monitor frame rate and identify janky frames.

```javascript
let lastFrameTime = performance.now();
let frameCount = 0;
let droppedFrames = 0;

function measureFrame(currentTime) {
  const delta = currentTime - lastFrameTime;
  
  // 60 FPS = ~16.67ms per frame
  if (delta > 16.67 * 2) {
    droppedFrames++;
    console.warn(`Dropped frame: ${delta.toFixed(2)}ms`);
  }
  
  frameCount++;
  lastFrameTime = currentTime;
  
  requestAnimationFrame(measureFrame);
}

requestAnimationFrame(measureFrame);

// Calculate average FPS
setInterval(() => {
  const fps = frameCount;
  frameCount = 0;
  console.log(`FPS: ${fps}, Dropped: ${droppedFrames}`);
  droppedFrames = 0;
}, 1000);
```

#### Memory Monitoring

```javascript
// Non-standard, Chrome only
if (performance.memory) {
  console.log('Used JS heap:', performance.memory.usedJSHeapSize / 1048576, 'MB');
  console.log('Total JS heap:', performance.memory.totalJSHeapSize / 1048576, 'MB');
  console.log('Heap limit:', performance.memory.jsHeapSizeLimit / 1048576, 'MB');
}

// Detect memory leaks
let baseline = performance.memory?.usedJSHeapSize;

setInterval(() => {
  if (performance.memory) {
    const current = performance.memory.usedJSHeapSize;
    const increase = ((current - baseline) / baseline) * 100;
    
    if (increase > 50) {
      console.warn('Potential memory leak detected');
    }
  }
}, 60000);
```

[Unverified] The `performance.memory` API is non-standard and may not be available in all browsers or environments.

### Paint Timing

#### First Paint (FP) and First Contentful Paint (FCP)

```javascript
const observer = new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    if (entry.name === 'first-paint') {
      console.log('FP:', entry.startTime);
    }
    if (entry.name === 'first-contentful-paint') {
      console.log('FCP:', entry.startTime);
    }
  }
});

observer.observe({ type: 'paint', buffered: true });
```

FCP Target: < 1.8s (good), 1.8s-3s (needs improvement), > 3s (poor)

#### Time to Interactive (TTI)

[Inference] TTI typically requires calculation based on multiple metrics:

```javascript
function calculateTTI() {
  const navEntry = performance.getEntriesByType('navigation')[0];
  const longTasks = performance.getEntriesByType('longtask');
  
  // Simplified: find first 5s window with no long tasks after FCP
  const fcp = performance.getEntriesByName('first-contentful-paint')[0]?.startTime || 0;
  
  let tti = fcp;
  const windowSize = 5000;
  
  for (let time = fcp; time < navEntry.loadEventEnd; time += 100) {
    const hasLongTask = longTasks.some(task => 
      task.startTime >= time && task.startTime < time + windowSize
    );
    
    if (!hasLongTask) {
      tti = time;
      break;
    }
  }
  
  return tti;
}
```

### Network Performance

#### Resource Prioritization

```javascript
// Check resource priority (Chrome DevTools Protocol)
const resources = performance.getEntriesByType('resource');

resources.forEach(resource => {
  // Server timing
  if (resource.serverTiming) {
    resource.serverTiming.forEach(timing => {
      console.log(`${timing.name}: ${timing.duration}ms`);
    });
  }
  
  // Protocol and connection info
  console.log('Protocol:', resource.nextHopProtocol); // 'h2', 'h3', etc.
  console.log('Render blocking:', resource.renderBlockingStatus);
});
```

#### Connection Timing

```javascript
const navEntry = performance.getEntriesByType('navigation')[0];

// Connection establishment
const dnsTime = navEntry.domainLookupEnd - navEntry.domainLookupStart;
const tcpTime = navEntry.connectEnd - navEntry.connectStart;
const tlsTime = navEntry.connectEnd - navEntry.secureConnectionStart;

// Request/response
const requestTime = navEntry.responseStart - navEntry.requestStart;
const responseTime = navEntry.responseEnd - navEntry.responseStart;
const totalTime = navEntry.responseEnd - navEntry.fetchStart;

console.log(`DNS: ${dnsTime}ms, TCP: ${tcpTime}ms, TLS: ${tlsTime}ms`);
console.log(`Request: ${requestTime}ms, Response: ${responseTime}ms`);
```

### Real User Monitoring (RUM)

#### Web Vitals Library Integration

```javascript
import {onCLS, onFID, onLCP, onFCP, onTTFB, onINP} from 'web-vitals';

function sendToAnalytics(metric) {
  const body = JSON.stringify({
    name: metric.name,
    value: metric.value,
    rating: metric.rating,
    delta: metric.delta,
    id: metric.id,
    navigationType: metric.navigationType
  });
  
  // Use sendBeacon for reliability
  navigator.sendBeacon('/analytics', body);
}

onCLS(sendToAnalytics);
onFID(sendToAnalytics);
onLCP(sendToAnalytics);
onFCP(sendToAnalytics);
onTTFB(sendToAnalytics);
onINP(sendToAnalytics);
```

#### Custom Metrics Collection

```javascript
class PerformanceMonitor {
  constructor() {
    this.metrics = {};
    this.observers = new Map();
    this.init();
  }
  
  init() {
    this.observeNavigation();
    this.observeResources();
    this.observeLongTasks();
    this.observeLayoutShifts();
    this.setupCustomMarks();
  }
  
  observeNavigation() {
    const observer = new PerformanceObserver((list) => {
      const [entry] = list.getEntries();
      this.metrics.navigation = {
        dns: entry.domainLookupEnd - entry.domainLookupStart,
        tcp: entry.connectEnd - entry.connectStart,
        ttfb: entry.responseStart - entry.requestStart,
        domInteractive: entry.domInteractive,
        domComplete: entry.domComplete,
        loadComplete: entry.loadEventEnd
      };
    });
    
    observer.observe({ type: 'navigation', buffered: true });
    this.observers.set('navigation', observer);
  }
  
  observeResources() {
    const observer = new PerformanceObserver((list) => {
      list.getEntries().forEach(entry => {
        const type = this.getResourceType(entry.name);
        
        if (!this.metrics.resources) {
          this.metrics.resources = {};
        }
        
        if (!this.metrics.resources[type]) {
          this.metrics.resources[type] = {
            count: 0,
            totalSize: 0,
            totalDuration: 0
          };
        }
        
        this.metrics.resources[type].count++;
        this.metrics.resources[type].totalSize += entry.transferSize;
        this.metrics.resources[type].totalDuration += entry.duration;
      });
    });
    
    observer.observe({ type: 'resource', buffered: true });
    this.observers.set('resources', observer);
  }
  
  observeLongTasks() {
    const observer = new PerformanceObserver((list) => {
      if (!this.metrics.longTasks) {
        this.metrics.longTasks = {
          count: 0,
          totalDuration: 0,
          maxDuration: 0
        };
      }
      
      list.getEntries().forEach(entry => {
        this.metrics.longTasks.count++;
        this.metrics.longTasks.totalDuration += entry.duration;
        this.metrics.longTasks.maxDuration = Math.max(
          this.metrics.longTasks.maxDuration,
          entry.duration
        );
      });
    });
    
    observer.observe({ type: 'longtask', buffered: true });
    this.observers.set('longtasks', observer);
  }
  
  observeLayoutShifts() {
    let cls = 0;
    const observer = new PerformanceObserver((list) => {
      list.getEntries().forEach(entry => {
        if (!entry.hadRecentInput) {
          cls += entry.value;
        }
      });
      this.metrics.cls = cls;
    });
    
    observer.observe({ type: 'layout-shift', buffered: true });
    this.observers.set('layout-shift', observer);
  }
  
  setupCustomMarks() {
    // Framework-specific marks
    window.addEventListener('load', () => {
      performance.mark('page-fully-loaded');
    });
  }
  
  getResourceType(url) {
    if (url.match(/\.(js)$/)) return 'script';
    if (url.match(/\.(css)$/)) return 'stylesheet';
    if (url.match(/\.(png|jpg|jpeg|gif|webp|svg)$/)) return 'image';
    if (url.match(/\.(woff|woff2|ttf|otf)$/)) return 'font';
    return 'other';
  }
  
  getReport() {
    return {
      timestamp: Date.now(),
      url: window.location.href,
      userAgent: navigator.userAgent,
      connection: navigator.connection?.effectiveType,
      metrics: this.metrics
    };
  }
  
  sendReport(endpoint) {
    const report = this.getReport();
    navigator.sendBeacon(endpoint, JSON.stringify(report));
  }
  
  disconnect() {
    this.observers.forEach(observer => observer.disconnect());
    this.observers.clear();
  }
}

// Usage
const monitor = new PerformanceMonitor();

// Send on page visibility change
document.addEventListener('visibilitychange', () => {
  if (document.visibilityState === 'hidden') {
    monitor.sendReport('/api/performance');
  }
});
```

### Advanced Techniques

#### Element Timing API

Track rendering performance of specific elements.

```javascript
// Add elementtiming attribute to elements
// <img elementtiming="hero-image" src="hero.jpg" />

const observer = new PerformanceObserver((list) => {
  list.getEntries().forEach(entry => {
    console.log(`Element ${entry.identifier} rendered at ${entry.renderTime}ms`);
    console.log('Load time:', entry.loadTime);
    console.log('Size:', entry.naturalWidth, 'x', entry.naturalHeight);
  });
});

observer.observe({ type: 'element', buffered: true });
```

#### Server Timing API

Receive backend performance data.

```javascript
// Server sends header:
// Server-Timing: db;dur=53, cache;dur=2.4, app;dur=47.2

const resources = performance.getEntriesByType('resource');

resources.forEach(resource => {
  if (resource.serverTiming) {
    resource.serverTiming.forEach(timing => {
      console.log(`${timing.name}: ${timing.duration}ms`);
      if (timing.description) {
        console.log('Description:', timing.description);
      }
    });
  }
});
```

#### Performance Budget Monitoring

```javascript
class PerformanceBudget {
  constructor(budgets) {
    this.budgets = budgets;
    this.violations = [];
  }
  
  check() {
    const metrics = this.collectMetrics();
    
    Object.keys(this.budgets).forEach(metric => {
      const actual = metrics[metric];
      const budget = this.budgets[metric];
      
      if (actual > budget) {
        this.violations.push({
          metric,
          budget,
          actual,
          overage: actual - budget,
          percentage: ((actual - budget) / budget) * 100
        });
      }
    });
    
    return this.violations;
  }
  
  collectMetrics() {
    const [navEntry] = performance.getEntriesByType('navigation');
    const resources = performance.getEntriesByType('resource');
    const lcp = performance.getEntriesByType('largest-contentful-paint').slice(-1)[0];
    
    return {
      'total-page-size': resources.reduce((sum, r) => sum + r.transferSize, 0),
      'script-size': resources
        .filter(r => r.initiatorType === 'script')
        .reduce((sum, r) => sum + r.transferSize, 0),
      'image-size': resources
        .filter(r => r.initiatorType === 'img')
        .reduce((sum, r) => sum + r.transferSize, 0),
      'css-size': resources
        .filter(r => r.initiatorType === 'css')
        .reduce((sum, r) => sum + r.transferSize, 0),
      'lcp': lcp?.renderTime || lcp?.loadTime || 0,
      'dom-size': document.querySelectorAll('*').length,
      'ttfb': navEntry.responseStart - navEntry.requestStart
    };
  }
  
  report() {
    if (this.violations.length === 0) {
      console.log('✓ All performance budgets met');
      return;
    }
    
    console.warn('⚠ Performance budget violations:');
    this.violations.forEach(v => {
      console.warn(
        `${v.metric}: ${v.actual} (budget: ${v.budget}) +${v.percentage.toFixed(1)}%`
      );
    });
  }
}

// Usage
const budget = new PerformanceBudget({
  'total-page-size': 2000000, // 2MB
  'script-size': 500000, // 500KB
  'image-size': 1000000, // 1MB
  'lcp': 2500, // 2.5s
  'dom-size': 1500,
  'ttfb': 600
});

window.addEventListener('load', () => {
  setTimeout(() => {
    budget.check();
    budget.report();
  }, 0);
});
```

#### Synthetic Testing Integration

```javascript
// Lighthouse CI integration point
window.__lighthouse = {
  marks: [],
  measures: [],
  
  addMark(name) {
    const time = performance.now();
    performance.mark(name);
    this.marks.push({ name, time });
  },
  
  addMeasure(name, start, end) {
    performance.measure(name, start, end);
    const entry = performance.getEntriesByName(name, 'measure')[0];
    this.measures.push({
      name,
      duration: entry.duration,
      start: entry.startTime
    });
  },
  
  getResults() {
    return {
      marks: this.marks,
      measures: this.measures,
      vitals: this.collectVitals()
    };
  },
  
  collectVitals() {
    const lcp = performance.getEntriesByType('largest-contentful-paint').slice(-1)[0];
    const fcp = performance.getEntriesByName('first-contentful-paint')[0];
    const cls = performance.getEntriesByType('layout-shift')
      .filter(e => !e.hadRecentInput)
      .reduce((sum, e) => sum + e.value, 0);
    
    return { lcp: lcp?.renderTime, fcp: fcp?.startTime, cls };
  }
};
```

### Debugging and Profiling

#### Console Performance Marks

```javascript
console.time('operation');
// ... code
console.timeEnd('operation');

console.time('nested');
console.time('inner');
// ... code
console.timeEnd('inner');
console.timeEnd('nested');
```

#### Performance Profiling

```javascript
// Start CPU profile (Chrome DevTools only)
console.profile('myProfile');

// Code to profile
for (let i = 0; i < 1000000; i++) {
  // Heavy operation
}

console.profileEnd('myProfile');

// Memory snapshots
console.takeHeapSnapshot?.();
```

#### React DevTools Profiler

```javascript
import { Profiler } from 'react';

function onRenderCallback(
  id, // component identifier
  phase, // "mount" or "update"
  actualDuration, // time spent rendering
  baseDuration, // estimated time without memoization
  startTime,
  commitTime,
  interactions
) {
  console.log(`${id} ${phase} phase took ${actualDuration}ms`);
  
  if (actualDuration > 16) {
    console.warn('Slow render detected');
  }
}

function App() {
  return (
    <Profiler id="App" onRender={onRenderCallback}>
      <YourComponents />
    </Profiler>
  );
}
```

### Performance Optimization Patterns

#### Debouncing Performance Events

```javascript
function debounce(func, wait) {
  let timeout;
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout);
      func(...args);
    };
    clearTimeout(timeout);
    timeout = setTimeout(later, wait);
  };
}

// Debounce resize observations
const debouncedResize = debounce(() => {
  console.log('Resize complete');
  // Perform expensive calculations
}, 250);

window.addEventListener('resize', debouncedResize);
```

#### Request Idle Callback Pattern

```javascript
const tasks = [];

function scheduleLowPriorityWork(task) {
  tasks.push(task);
  scheduleWork();
}

function scheduleWork() {
  if (tasks.length === 0) return;
  
  requestIdleCallback((deadline) => {
    while (deadline.timeRemaining() > 0 && tasks.length > 0) {
      const task = tasks.shift();
      task();
    }
    
    if (tasks.length > 0) {
      scheduleWork();
    }
  }, { timeout: 2000 });
}
```

#### Passive Event Listeners

```javascript
// Improves scroll performance
document.addEventListener('scroll', handleScroll, { passive: true });
document.addEventListener('touchstart', handleTouch, { passive: true });

// Cannot call preventDefault() in passive listeners
// Good for read-only event handlers
```

This covers the comprehensive landscape of DOM/JS performance monitoring, from foundational APIs to advanced real-world implementation patterns.

---

