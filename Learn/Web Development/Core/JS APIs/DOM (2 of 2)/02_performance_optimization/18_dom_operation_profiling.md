## DOM Operation Profiling


### Performance Measurement APIs

#### Performance.mark() and Performance.measure()

The User Timing API provides precise performance measurements for DOM operations through marking and measuring intervals.

```javascript
// Mark the start of an operation
performance.mark('dom-start');

// Perform DOM operations
const container = document.getElementById('container');
for (let i = 0; i < 1000; i++) {
  const div = document.createElement('div');
  div.textContent = `Item ${i}`;
  container.appendChild(div);
}

// Mark the end
performance.mark('dom-end');

// Measure the duration
performance.measure('dom-operation', 'dom-start', 'dom-end');

// Retrieve the measurement
const measures = performance.getEntriesByName('dom-operation');
console.log(`Operation took: ${measures[0].duration}ms`);

// Clean up
performance.clearMarks();
performance.clearMeasures();
```

**High-Resolution Timestamps:**

`performance.now()` provides microsecond precision (limited by browser security policies) compared to `Date.now()`'s millisecond granularity:

```javascript
const start = performance.now();
document.body.appendChild(document.createElement('div'));
const end = performance.now();
console.log(`Precise duration: ${end - start}ms`);
```

#### Performance Observer

For continuous monitoring without polling, Performance Observer provides an event-driven approach:

```javascript
const observer = new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    if (entry.entryType === 'measure') {
      console.log(`${entry.name}: ${entry.duration}ms`);
    }
  }
});

observer.observe({ entryTypes: ['measure', 'mark'] });

// Operations are automatically captured
performance.mark('operation-start');
// ... DOM operations ...
performance.mark('operation-end');
performance.measure('operation', 'operation-start', 'operation-end');
```

### Browser DevTools Profiling

#### Chrome DevTools Performance Panel

**Recording Profiles:**

1. Open DevTools → Performance tab
2. Click record (or Ctrl+E)
3. Perform DOM operations
4. Stop recording

**Key Metrics in Timeline:**

- **Scripting** (yellow) - JavaScript execution time including DOM API calls
- **Rendering** (purple) - Style calculations and layout operations
- **Painting** (green) - Pixel rendering to screen
- **System** (gray) - Browser overhead

**Analyzing DOM Operations:**

```javascript
// Example operation to profile
function heavyDOMOperation() {
  const fragment = document.createDocumentFragment();
  
  for (let i = 0; i < 10000; i++) {
    const div = document.createElement('div');
    div.className = 'item';
    div.textContent = `Item ${i}`;
    fragment.appendChild(div);
  }
  
  document.body.appendChild(fragment);
}

// Call with profiling enabled
console.profile('Heavy DOM Operation');
heavyDOMOperation();
console.profileEnd('Heavy DOM Operation');
```

The flame chart visualization shows:

- Function call hierarchy
- Time spent in each function
- DOM API bottlenecks
- Forced synchronous layouts (layout thrashing)

#### Firefox DevTools Performance Tool

Firefox provides similar capabilities with additional markers for:

- Reflow/Layout events
- Style recalculation triggers
- Composite layer creation

```javascript
// Firefox-specific console timing API
console.time('DOM Operation');
// ... operations ...
console.timeEnd('DOM Operation');

// More detailed with timestamps
console.timeLog('DOM Operation', 'Checkpoint 1');
// ... more operations ...
console.timeLog('DOM Operation', 'Checkpoint 2');
console.timeEnd('DOM Operation');
```

### Identifying Layout Thrashing

Layout thrashing occurs when scripts repeatedly read layout properties and write DOM changes, forcing synchronous reflow calculations.

#### Detection Pattern

```javascript
// BAD: Causes layout thrashing
function thrashingExample() {
  const elements = document.querySelectorAll('.item');
  
  elements.forEach(el => {
    // Read (triggers layout)
    const height = el.offsetHeight;
    
    // Write (invalidates layout)
    el.style.height = (height + 10) + 'px';
    
    // Next read forces synchronous layout recalculation
  });
}

// GOOD: Batch reads and writes
function optimizedExample() {
  const elements = document.querySelectorAll('.item');
  
  // Read phase
  const heights = Array.from(elements).map(el => el.offsetHeight);
  
  // Write phase
  elements.forEach((el, i) => {
    el.style.height = (heights[i] + 10) + 'px';
  });
}
```

#### Properties That Trigger Layout

Reading these properties forces layout calculation:

- Offset properties: `offsetTop`, `offsetLeft`, `offsetWidth`, `offsetHeight`, `offsetParent`
- Client properties: `clientTop`, `clientLeft`, `clientWidth`, `clientHeight`
- Scroll properties: `scrollTop`, `scrollLeft`, `scrollWidth`, `scrollHeight`
- Computed styles: `getComputedStyle()`, `getBoundingClientRect()`
- Layout methods: `scrollIntoView()`, `scrollTo()`, `focus()`

**Profiling Layout Events:**

```javascript
const observer = new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    // [Inference] Different browsers may expose layout timing differently
    if (entry.entryType === 'measure') {
      console.log(`Layout measure: ${entry.duration}ms`);
    }
  }
});

// Monitor layout-related operations
performance.mark('layout-start');

const height = document.body.offsetHeight; // Triggers layout

performance.mark('layout-end');
performance.measure('layout-read', 'layout-start', 'layout-end');
```

### Memory Profiling for DOM Operations

#### Heap Snapshots

Chrome DevTools Memory panel captures DOM node retention:

```javascript
// Take snapshot before operation
// DevTools → Memory → Take heap snapshot

function createDetachedNodes() {
  const nodes = [];
  
  for (let i = 0; i < 10000; i++) {
    const div = document.createElement('div');
    div.textContent = `Detached ${i}`;
    nodes.push(div); // Keeps nodes in memory even if not attached
  }
  
  return nodes; // Memory leak if never cleaned up
}

const detached = createDetachedNodes();

// Take another snapshot and compare
// Look for "Detached DOM tree" entries
```

#### Allocation Timeline

Records memory allocations over time to identify leaks:

```javascript
// Start allocation profiling in DevTools
function addEventListeners() {
  const buttons = document.querySelectorAll('button');
  
  buttons.forEach(button => {
    // Potential memory leak: listener retains closure scope
    button.addEventListener('click', function handler() {
      console.log(this.dataset.value);
      // If button is removed without removeEventListener,
      // the handler and button remain in memory
    });
  });
}

// Proper cleanup
function addEventListenersClean() {
  const buttons = document.querySelectorAll('button');
  const handlers = new WeakMap();
  
  buttons.forEach(button => {
    const handler = () => console.log(button.dataset.value);
    handlers.set(button, handler);
    button.addEventListener('click', handler);
  });
  
  // Cleanup function
  return () => {
    buttons.forEach(button => {
      const handler = handlers.get(button);
      if (handler) {
        button.removeEventListener('click', handler);
      }
    });
  };
}
```

### Custom Performance Monitoring

#### Building a DOM Operation Profiler

```javascript
class DOMProfiler {
  constructor() {
    this.operations = new Map();
    this.observers = [];
  }
  
  start(operationName) {
    performance.mark(`${operationName}-start`);
    
    if (!this.operations.has(operationName)) {
      this.operations.set(operationName, {
        count: 0,
        totalDuration: 0,
        measurements: []
      });
    }
  }
  
  end(operationName) {
    const endMark = `${operationName}-end`;
    const measureName = `${operationName}-measure`;
    
    performance.mark(endMark);
    performance.measure(
      measureName,
      `${operationName}-start`,
      endMark
    );
    
    const measures = performance.getEntriesByName(measureName);
    const duration = measures[measures.length - 1].duration;
    
    const stats = this.operations.get(operationName);
    stats.count++;
    stats.totalDuration += duration;
    stats.measurements.push(duration);
    
    // Clean up marks
    performance.clearMarks(`${operationName}-start`);
    performance.clearMarks(endMark);
    performance.clearMeasures(measureName);
    
    return duration;
  }
  
  getStats(operationName) {
    const stats = this.operations.get(operationName);
    if (!stats || stats.count === 0) return null;
    
    const sorted = [...stats.measurements].sort((a, b) => a - b);
    const median = sorted[Math.floor(sorted.length / 2)];
    const min = sorted[0];
    const max = sorted[sorted.length - 1];
    const avg = stats.totalDuration / stats.count;
    
    return {
      count: stats.count,
      average: avg,
      median,
      min,
      max,
      total: stats.totalDuration
    };
  }
  
  report() {
    const report = {};
    
    for (const [name, stats] of this.operations) {
      report[name] = this.getStats(name);
    }
    
    return report;
  }
  
  clear() {
    this.operations.clear();
    performance.clearMarks();
    performance.clearMeasures();
  }
}

// Usage
const profiler = new DOMProfiler();

profiler.start('render-list');
const ul = document.createElement('ul');
for (let i = 0; i < 1000; i++) {
  const li = document.createElement('li');
  li.textContent = `Item ${i}`;
  ul.appendChild(li);
}
document.body.appendChild(ul);
profiler.end('render-list');

console.log(profiler.getStats('render-list'));
```

### Mutation Observer Performance Impact

MutationObserver itself adds overhead. Profile its impact:

```javascript
function profileMutationObserver() {
  const container = document.getElementById('container');
  
  // Baseline without observer
  performance.mark('baseline-start');
  for (let i = 0; i < 1000; i++) {
    container.appendChild(document.createElement('div'));
  }
  performance.mark('baseline-end');
  performance.measure('baseline', 'baseline-start', 'baseline-end');
  
  // Clear container
  container.innerHTML = '';
  
  // With observer
  const observer = new MutationObserver((mutations) => {
    // Processing overhead
    mutations.forEach(mutation => {
      mutation.addedNodes.forEach(node => {
        // Some processing
      });
    });
  });
  
  observer.observe(container, { childList: true });
  
  performance.mark('observed-start');
  for (let i = 0; i < 1000; i++) {
    container.appendChild(document.createElement('div'));
  }
  performance.mark('observed-end');
  performance.measure('observed', 'observed-start', 'observed-end');
  
  observer.disconnect();
  
  const baseline = performance.getEntriesByName('baseline')[0].duration;
  const observed = performance.getEntriesByName('observed')[0].duration;
  
  console.log(`Baseline: ${baseline}ms`);
  console.log(`With Observer: ${observed}ms`);
  console.log(`Overhead: ${observed - baseline}ms (${((observed / baseline - 1) * 100).toFixed(2)}%)`);
}
```

### Long Task API

Identifies operations blocking the main thread for extended periods:

```javascript
const observer = new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    // Long tasks are >= 50ms
    console.warn(`Long task detected: ${entry.duration}ms`, {
      name: entry.name,
      startTime: entry.startTime,
      attribution: entry.attribution
    });
  }
});

observer.observe({ entryTypes: ['longtask'] });

// Simulate long DOM operation
function longDOMOperation() {
  const container = document.createElement('div');
  
  // Intentionally blocking operation
  for (let i = 0; i < 100000; i++) {
    const div = document.createElement('div');
    div.textContent = `Item ${i}`;
    div.style.width = '100px';
    div.style.height = '50px';
    container.appendChild(div);
  }
  
  document.body.appendChild(container);
}

// This will likely trigger longtask entries
longDOMOperation();
```

### Real User Monitoring (RUM) Metrics

#### First Contentful Paint (FCP) and DOM Operations

```javascript
const observer = new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    if (entry.name === 'first-contentful-paint') {
      console.log(`FCP: ${entry.startTime}ms`);
      
      // Correlate with DOM ready time
      const domReady = performance.timing.domContentLoadedEventEnd - 
                      performance.timing.navigationStart;
      console.log(`DOM Ready: ${domReady}ms`);
      console.log(`FCP delay after DOM: ${entry.startTime - domReady}ms`);
    }
  }
});

observer.observe({ entryTypes: ['paint'] });
```

#### Cumulative Layout Shift (CLS) from DOM Operations

```javascript
let clsScore = 0;

const clsObserver = new PerformanceObserver((list) => {
  for (const entry of list.getEntries()) {
    if (!entry.hadRecentInput) {
      clsScore += entry.value;
      console.log('Layout shift:', {
        value: entry.value,
        cumulative: clsScore,
        sources: entry.sources
      });
    }
  }
});

clsObserver.observe({ entryTypes: ['layout-shift'] });

// DOM operation that causes layout shift
function causeLayoutShift() {
  const img = document.createElement('img');
  img.src = 'large-image.jpg';
  // No width/height specified - will shift layout when loaded
  document.body.insertBefore(img, document.body.firstChild);
}
```

### Comparative Profiling Techniques

#### Batch vs Individual Operations

```javascript
function compareDOMApproaches() {
  const iterations = 1000;
  
  // Approach 1: Individual appendChild
  performance.mark('individual-start');
  const container1 = document.createElement('div');
  for (let i = 0; i < iterations; i++) {
    const div = document.createElement('div');
    container1.appendChild(div);
  }
  document.body.appendChild(container1);
  performance.mark('individual-end');
  
  // Approach 2: DocumentFragment
  performance.mark('fragment-start');
  const container2 = document.createElement('div');
  const fragment = document.createDocumentFragment();
  for (let i = 0; i < iterations; i++) {
    const div = document.createElement('div');
    fragment.appendChild(div);
  }
  container2.appendChild(fragment);
  document.body.appendChild(container2);
  performance.mark('fragment-end');
  
  // Approach 3: innerHTML
  performance.mark('innerHTML-start');
  const container3 = document.createElement('div');
  let html = '';
  for (let i = 0; i < iterations; i++) {
    html += '<div></div>';
  }
  container3.innerHTML = html;
  document.body.appendChild(container3);
  performance.mark('innerHTML-end');
  
  // Measure
  performance.measure('individual', 'individual-start', 'individual-end');
  performance.measure('fragment', 'fragment-start', 'fragment-end');
  performance.measure('innerHTML', 'innerHTML-start', 'innerHTML-end');
  
  console.table({
    'Individual appendChild': performance.getEntriesByName('individual')[0].duration,
    'DocumentFragment': performance.getEntriesByName('fragment')[0].duration,
    'innerHTML': performance.getEntriesByName('innerHTML')[0].duration
  });
  
  // Cleanup
  container1.remove();
  container2.remove();
  container3.remove();
  performance.clearMarks();
  performance.clearMeasures();
}

compareDOMApproaches();
```

### Automated Performance Testing

#### Performance Budget Enforcement

```javascript
class PerformanceBudget {
  constructor(budgets) {
    this.budgets = budgets; // { operationName: maxDuration }
    this.violations = [];
  }
  
  check(operationName, duration) {
    const budget = this.budgets[operationName];
    
    if (budget && duration > budget) {
      const violation = {
        operation: operationName,
        budget,
        actual: duration,
        excess: duration - budget,
        timestamp: Date.now()
      };
      
      this.violations.push(violation);
      console.warn(`Performance budget exceeded:`, violation);
      
      return false;
    }
    
    return true;
  }
  
  getViolations() {
    return this.violations;
  }
  
  reset() {
    this.violations = [];
  }
}

// Usage
const budget = new PerformanceBudget({
  'render-list': 16.67, // One frame at 60fps
  'update-item': 5,
  'scroll-handler': 10
});

function monitoredOperation(name, fn) {
  const start = performance.now();
  const result = fn();
  const duration = performance.now() - start;
  
  budget.check(name, duration);
  
  return result;
}

monitoredOperation('render-list', () => {
  // DOM operation
  const ul = document.createElement('ul');
  for (let i = 0; i < 1000; i++) {
    ul.appendChild(document.createElement('li'));
  }
  document.body.appendChild(ul);
});
```

---

