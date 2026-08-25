## Memory Leak Detection in DOM and JavaScript


### Types of Memory Leaks in Web Applications

#### Detached DOM Trees

Detached DOM nodes are removed from the document but remain in memory because JavaScript still holds references to them. When you remove a parent node but maintain references to its children, the entire subtree remains allocated.

```javascript
let detachedNodes = [];
function createLeak() {
  const parent = document.createElement('div');
  for (let i = 0; i < 1000; i++) {
    const child = document.createElement('div');
    child.textContent = `Item ${i}`;
    parent.appendChild(child);
  }
  document.body.appendChild(parent);
  detachedNodes.push(parent.firstChild); // Keep reference to child
  document.body.removeChild(parent); // Parent removed, but child reference keeps tree alive
}
```

#### Event Listener Leaks

Event listeners that aren't removed when elements are destroyed continue to hold references to both the callback function and the element, preventing garbage collection.

```javascript
class Component {
  constructor(element) {
    this.element = element;
    this.data = new Array(100000).fill('data');
    
    // Arrow function creates closure over 'this'
    this.element.addEventListener('click', () => {
      console.log(this.data);
    });
    // Listener never removed - 'this' stays in memory
  }
}
```

#### Closure Leaks

Closures capture their entire scope chain. When closures outlive their intended lifecycle, they retain references to variables that should be garbage collected.

```javascript
function createLeak() {
  const largeData = new Array(1000000).fill('x');
  const element = document.getElementById('target');
  
  // This closure captures largeData even if it doesn't use it
  element.addEventListener('click', function() {
    console.log('clicked'); // largeData still in closure scope
  });
}
```

#### Timers and Intervals

Uncleared timers and intervals hold references to their callbacks and any captured scope, preventing garbage collection of referenced objects.

```javascript
class Widget {
  constructor() {
    this.data = new Array(100000);
    this.intervalId = setInterval(() => {
      this.update(); // Keeps 'this' and this.data alive
    }, 1000);
    // If clearInterval never called, memory never freed
  }
}
```

#### Global Variable Accumulation

Variables attached to the global scope (window) never get garbage collected, and accidentally created globals compound the issue.

```javascript
function accidentalGlobal() {
  leakedVar = 'This is now global'; // Missing 'const/let/var'
  this.alsoGlobal = 'Also leaked'; // In non-strict mode
}
```

#### Cache Without Eviction

Caches that grow unbounded without size limits or TTL policies accumulate references indefinitely.

```javascript
const cache = new Map();

function cacheData(key, value) {
  cache.set(key, value); // Never removed, grows forever
}
```

### Detection Tools and Techniques

#### Chrome DevTools Memory Profiler

**Heap Snapshots** Heap snapshots capture the complete state of JavaScript memory at a specific moment, showing all allocated objects, their sizes, and retention paths.

To take snapshots:

1. Open DevTools → Memory tab
2. Select "Heap snapshot"
3. Click "Take snapshot"
4. Perform actions that might leak memory
5. Take another snapshot
6. Compare snapshots to find retained objects

Key metrics in snapshots:

- **Shallow Size**: Memory held by the object itself
- **Retained Size**: Total memory that would be freed if the object were garbage collected (includes referenced objects)
- **Distance**: Number of steps from GC root

**Comparison View** Compare two heap snapshots to identify objects that increased between snapshots:

```javascript
// Example workflow:
// 1. Take snapshot (baseline)
// 2. Execute suspected leaking code multiple times
for (let i = 0; i < 10; i++) {
  createComponent();
  destroyComponent();
}
// 3. Force garbage collection (DevTools → Performance monitor → garbage icon)
// 4. Take second snapshot
// 5. Switch to "Comparison" view
// Look for objects with positive delta that shouldn't be retained
```

**Allocation Timeline** Records memory allocations over time, showing when objects are created and whether they're still retained.

1. Memory tab → Allocation instrumentation on timeline
2. Click "Start"
3. Perform actions
4. Stop recording
5. Blue bars = allocated and retained
6. Gray bars = allocated and freed

#### Allocation Sampling

Lower overhead than allocation timeline, samples allocations to identify functions that allocate the most memory.

```javascript
// Functions appearing frequently in allocation sampling indicate high allocation
function processLargeDataset() {
  return Array(10000).fill(0).map(x => ({
    data: new Array(100),
    timestamp: Date.now()
  }));
}
```

#### Memory Timeline (Performance Tab)

Shows memory usage over time alongside other performance metrics, useful for identifying when leaks occur during specific user interactions.

The JS Heap line should show sawtooth pattern (allocation then GC). If it continuously increases without dropping, memory is leaking.

### Detection Patterns

#### The Three-Snapshot Technique

Most reliable method for confirming leaks:

1. **Baseline snapshot**: Take initial heap snapshot
2. **Action phase**: Perform the action suspected of leaking (e.g., open/close modal 10 times)
3. **First check snapshot**: Force GC, take second snapshot
4. **Repeat action**: Perform same action 10 more times
5. **Confirmation snapshot**: Force GC, take third snapshot

**[Inference]** If objects increase proportionally to the number of action repetitions between snapshots 2 and 3, those objects are likely leaking. The repetition distinguishes leaks from legitimate cached data.

#### Detached DOM Node Detection

In heap snapshot, filter by "Detached":

- Objects marked as "Detached HTMLDivElement" (or other elements) are DOM nodes removed from the document but still in memory
- Follow retainer path to see what's keeping them alive

```javascript
// Detective work example:
// Heap snapshot shows: Detached HTMLDivElement
// Retainer path: Window → myComponents (Array) → Component → element
// Conclusion: myComponents array is keeping removed elements
```

#### Event Listener Pattern

Search heap snapshot for "EventListener" objects:

- Count should decrease when components are destroyed
- Filter by specific event types: "click", "scroll", "resize"
- Check retainers to find which code registered them

#### Closure Scope Inspection

In heap snapshot, search for function contexts and examine their captured variables:

- Look for "(closure)" in the object list
- Check captured variables for unexpected large objects
- **[Inference]** If a closure captures variables it doesn't use, refactor to limit scope

### Automated Detection

#### Performance.measureUserAgentSpecificMemory()

API for programmatically measuring memory usage (origin trial / limited browser support):

```javascript
async function checkMemory() {
  if (performance.measureUserAgentSpecificMemory) {
    const measurement = await performance.measureUserAgentSpecificMemory();
    console.log('Memory bytes:', measurement.bytes);
    return measurement.bytes;
  }
}

// Memory leak test pattern
async function testForLeak() {
  const baseline = await checkMemory();
  
  for (let i = 0; i < 100; i++) {
    createAndDestroyComponent();
  }
  
  // Force GC if possible (not available in production)
  await new Promise(resolve => setTimeout(resolve, 1000));
  
  const afterTest = await checkMemory();
  const increase = afterTest - baseline;
  
  console.log(`Memory increased by ${increase} bytes`);
  // [Inference] Significant increase suggests leak
}
```

**[Unverified]** The API's availability and behavior varies by browser and may require specific flags or origin trials.

#### Performance.memory (Chrome-specific, deprecated)

```javascript
// Non-standard, Chrome only, increasingly restricted
if (performance.memory) {
  console.log('Used JS Heap:', performance.memory.usedJSHeapSize);
  console.log('Total JS Heap:', performance.memory.totalJSHeapSize);
  console.log('Heap Limit:', performance.memory.jsHeapSizeLimit);
}
```

**[Unverified]** This API is deprecated and may be removed. Results are intentionally imprecise for security reasons.

#### Custom Memory Tracking

Track object creation/destruction manually in development:

```javascript
class MemoryTracker {
  constructor() {
    this.trackedObjects = new Map();
    this.idCounter = 0;
  }
  
  track(object, label) {
    const id = ++this.idCounter;
    this.trackedObjects.set(id, {
      label,
      ref: new WeakRef(object),
      created: Date.now()
    });
    return id;
  }
  
  checkLeaks() {
    const leaked = [];
    for (const [id, tracked] of this.trackedObjects) {
      if (tracked.ref.deref() !== undefined) {
        leaked.push({
          id,
          label: tracked.label,
          age: Date.now() - tracked.created
        });
      }
    }
    return leaked;
  }
}

// Usage
const tracker = new MemoryTracker();

class Component {
  constructor() {
    this.trackerId = tracker.track(this, 'Component');
    this.element = document.createElement('div');
  }
  
  destroy() {
    this.element.remove();
    this.element = null;
  }
}

// After components should be destroyed
setTimeout(() => {
  console.log('Leaked objects:', tracker.checkLeaks());
}, 5000);
```

### Analysis Techniques

#### Retainer Path Analysis

The retainer path shows the chain of references keeping an object alive. Reading from bottom to top shows why an object can't be garbage collected.

Example retainer path:

```
Window (global root)
  → applicationCache (object)
    → components (Array)
      → [5] (array element)
        → element (HTMLDivElement)
          → listeners (Object)
            → click (Array)
              → [0] (function)
                → [[context]] (closure)
                  → largeData (Array) ← TARGET OBJECT
```

**[Inference]** This indicates `largeData` is retained because it's captured in a click event listener closure on an element stored in a components array.

#### Distance Metric Interpretation

Distance from GC root indicates how "deep" an object is in the reference chain:

- Distance 1: Directly referenced by a GC root (global variable, window, etc.)
- Distance 2+: Referenced through intermediate objects

Objects with high distance but high retained size **[Inference]** might indicate intermediate objects accidentally keeping large structures alive.

#### Constructor Grouping

Group objects by constructor name to identify which types are accumulating:

```javascript
// In heap snapshot summary view:
// Constructor | Objects | Shallow Size | Retained Size
// HTMLDivElement | 1,547 | 247KB | 2.1MB
// Array | 8,932 | 523KB | 8.7MB
// Object | 15,421 | 1.2MB | 4.3MB
```

Compare snapshots by constructor to see which types are growing.

#### String Duplication Analysis

Duplicate strings in heap snapshots indicate potential optimization opportunities:

- Multiple copies of same string value
- Consider string interning or constants

```javascript
// In heap snapshot, strings are deduplicated by content
// High count of identical strings suggests repeated creation
```

### Prevention Patterns

#### WeakMap and WeakSet

Use weak references for metadata storage that shouldn't prevent garbage collection:

```javascript
// Strong reference - prevents GC
const elementData = new Map();
function attachData(element, data) {
  elementData.set(element, data); // Element never freed if map lives
}

// Weak reference - allows GC
const elementData = new WeakMap();
function attachData(element, data) {
  elementData.set(element, data); // Element can be GCed, entry auto-removed
}
```

**[Unverified]** The exact timing of WeakMap entry removal is implementation-dependent and not guaranteed to be immediate after garbage collection.

#### Proper Event Listener Cleanup

Always remove event listeners when components are destroyed:

```javascript
class Component {
  constructor(element) {
    this.element = element;
    this.handleClick = this.handleClick.bind(this);
    this.element.addEventListener('click', this.handleClick);
  }
  
  handleClick(event) {
    // Handle click
  }
  
  destroy() {
    this.element.removeEventListener('click', this.handleClick);
    this.element = null;
  }
}
```

#### AbortController for Multiple Listeners

Use AbortController to remove multiple listeners simultaneously:

```javascript
class Component {
  constructor(element) {
    this.element = element;
    this.abortController = new AbortController();
    const { signal } = this.abortController;
    
    element.addEventListener('click', this.onClick, { signal });
    element.addEventListener('mouseover', this.onHover, { signal });
    window.addEventListener('resize', this.onResize, { signal });
  }
  
  destroy() {
    this.abortController.abort(); // Removes all listeners at once
    this.element = null;
  }
}
```

#### Timer Management

Always clear timers and intervals:

```javascript
class Widget {
  constructor() {
    this.timers = new Set();
  }
  
  addTimer(callback, delay) {
    const id = setTimeout(() => {
      callback();
      this.timers.delete(id);
    }, delay);
    this.timers.add(id);
    return id;
  }
  
  addInterval(callback, delay) {
    const id = setInterval(callback, delay);
    this.timers.add(id);
    return id;
  }
  
  destroy() {
    for (const id of this.timers) {
      clearTimeout(id); // Works for both setTimeout and setInterval
      clearInterval(id);
    }
    this.timers.clear();
  }
}
```

#### Proper Closure Scope

Limit what closures capture by using block scope and explicit parameters:

```javascript
// Bad - captures entire scope
function setupHandler(element, userData) {
  const largeArray = new Array(100000);
  const config = { /* ... */ };
  
  element.addEventListener('click', function() {
    console.log(userData.name); // Captures everything including largeArray
  });
}

// Good - limits scope
function setupHandler(element, userData) {
  const userName = userData.name; // Extract only what's needed
  
  {
    const largeArray = new Array(100000);
    const config = { /* ... */ };
    // Process data...
  } // largeArray out of scope
  
  element.addEventListener('click', function() {
    console.log(userName); // Only captures userName
  });
}
```

#### Cache Size Management

Implement bounded caches with LRU or TTL eviction:

```javascript
class LRUCache {
  constructor(maxSize) {
    this.maxSize = maxSize;
    this.cache = new Map();
  }
  
  get(key) {
    if (!this.cache.has(key)) return undefined;
    
    // Move to end (most recently used)
    const value = this.cache.get(key);
    this.cache.delete(key);
    this.cache.set(key, value);
    return value;
  }
  
  set(key, value) {
    if (this.cache.has(key)) {
      this.cache.delete(key);
    } else if (this.cache.size >= this.maxSize) {
      // Remove least recently used (first item)
      const firstKey = this.cache.keys().next().value;
      this.cache.delete(firstKey);
    }
    this.cache.set(key, value);
  }
}
```

#### DOM Reference Cleanup

Nullify DOM references when elements are removed:

```javascript
class Component {
  constructor() {
    this.container = document.createElement('div');
    this.button = document.createElement('button');
    this.input = document.createElement('input');
    this.container.appendChild(this.button);
    this.container.appendChild(this.input);
  }
  
  destroy() {
    // Remove from DOM
    this.container.remove();
    
    // Nullify references
    this.container = null;
    this.button = null;
    this.input = null;
  }
}
```

### Framework-Specific Considerations

#### React Memory Leaks

**useEffect Cleanup**

```javascript
function Component() {
  useEffect(() => {
    const handleResize = () => {
      console.log('resize');
    };
    
    window.addEventListener('resize', handleResize);
    
    // Cleanup function runs on unmount
    return () => {
      window.removeEventListener('resize', handleResize);
    };
  }, []);
}
```

**Async Operations After Unmount**

```javascript
function Component() {
  useEffect(() => {
    let cancelled = false;
    
    async function fetchData() {
      const data = await fetch('/api/data');
      if (!cancelled) {
        setData(data); // Only update if still mounted
      }
    }
    
    fetchData();
    
    return () => {
      cancelled = true; // Prevent state update after unmount
    };
  }, []);
}
```

**Closure Stale Props**

```javascript
function Component({ userId }) {
  useEffect(() => {
    // This creates a new subscription each time userId changes
    const subscription = subscribeToUser(userId, (data) => {
      // This closure captures the current userId
      console.log('Update for', userId);
    });
    
    return () => {
      subscription.unsubscribe(); // Clean up old subscription
    };
  }, [userId]); // Dependencies ensure cleanup runs when userId changes
}
```

#### Vue Memory Leaks

**Component Cleanup**

```javascript
export default {
  mounted() {
    this.handleScroll = () => {
      // Handle scroll
    };
    window.addEventListener('scroll', this.handleScroll);
  },
  
  beforeUnmount() {
    window.removeEventListener('scroll', this.handleScroll);
    this.handleScroll = null;
  }
}
```

**Event Bus Leaks**

```javascript
// Potential leak
export default {
  mounted() {
    this.$bus.$on('event', this.handleEvent);
  }
  // Missing cleanup
}

// Fixed
export default {
  mounted() {
    this.$bus.$on('event', this.handleEvent);
  },
  
  beforeUnmount() {
    this.$bus.$off('event', this.handleEvent);
  }
}
```

#### Angular Memory Leaks

**Observable Subscriptions**

```javascript
export class Component implements OnInit, OnDestroy {
  private destroy$ = new Subject<void>();
  
  ngOnInit() {
    this.dataService.getData()
      .pipe(takeUntil(this.destroy$))
      .subscribe(data => {
        this.data = data;
      });
  }
  
  ngOnDestroy() {
    this.destroy$.next();
    this.destroy$.complete();
  }
}
```

### Testing for Memory Leaks

#### Automated Leak Detection Tests

```javascript
// Puppeteer example
const puppeteer = require('puppeteer');

async function testMemoryLeak() {
  const browser = await puppeteer.launch();
  const page = await browser.newPage();
  
  await page.goto('http://localhost:3000');
  
  // Get initial metrics
  const initialMetrics = await page.metrics();
  const initialJSHeap = initialMetrics.JSHeapUsedSize;
  
  // Perform actions that might leak
  for (let i = 0; i < 50; i++) {
    await page.click('#open-modal');
    await page.waitForSelector('.modal');
    await page.click('#close-modal');
    await page.waitForSelector('.modal', { hidden: true });
  }
  
  // Force garbage collection (requires --expose-gc flag)
  await page.evaluate(() => {
    if (window.gc) window.gc();
  });
  
  // Get final metrics
  const finalMetrics = await page.metrics();
  const finalJSHeap = finalMetrics.JSHeapUsedSize;
  
  const increase = finalJSHeap - initialJSHeap;
  const increasePercent = (increase / initialJSHeap) * 100;
  
  console.log(`Memory increased by ${increase} bytes (${increasePercent.toFixed(2)}%)`);
  
  // [Inference] Threshold-based detection
  if (increasePercent > 20) {
    console.warn('Potential memory leak detected');
  }
  
  await browser.close();
}
```

#### Jest Memory Leak Tests

```javascript
describe('Component memory leaks', () => {
  it('should not leak memory when mounting/unmounting', async () => {
    const iterations = 100;
    const components = [];
    
    // Create references
    for (let i = 0; i < iterations; i++) {
      const wrapper = mount(Component);
      components.push(new WeakRef(wrapper));
      wrapper.unmount();
    }
    
    // Force GC (requires --expose-gc)
    if (global.gc) {
      global.gc();
    }
    
    // Wait for GC to complete
    await new Promise(resolve => setTimeout(resolve, 100));
    
    // Check if components were collected
    const alive = components.filter(ref => ref.deref() !== undefined).length;
    
    // [Inference] Most components should be garbage collected
    expect(alive).toBeLessThan(iterations * 0.1);
  });
});
```

### Production Monitoring

#### Memory Usage Metrics

```javascript
// Track memory usage over time
class MemoryMonitor {
  constructor(reportInterval = 60000) {
    this.measurements = [];
    this.maxMeasurements = 100;
    
    if (performance.memory) {
      this.intervalId = setInterval(() => {
        this.recordMeasurement();
      }, reportInterval);
    }
  }
  
  recordMeasurement() {
    if (!performance.memory) return;
    
    const measurement = {
      timestamp: Date.now(),
      used: performance.memory.usedJSHeapSize,
      total: performance.memory.totalJSHeapSize,
      limit: performance.memory.jsHeapSizeLimit
    };
    
    this.measurements.push(measurement);
    
    if (this.measurements.length > this.maxMeasurements) {
      this.measurements.shift();
    }
    
    this.checkForAnomaly();
  }
  
  checkForAnomaly() {
    if (this.measurements.length < 10) return;
    
    const recent = this.measurements.slice(-10);
    const older = this.measurements.slice(0, -10);
    
    const recentAvg = recent.reduce((sum, m) => sum + m.used, 0) / recent.length;
    const olderAvg = older.reduce((sum, m) => sum + m.used, 0) / older.length;
    
    const increase = ((recentAvg - olderAvg) / olderAvg) * 100;
    
    // [Inference] Sustained growth might indicate leak
    if (increase > 50) {
      this.reportAnomaly(increase);
    }
  }
  
  reportAnomaly(increase) {
    // Send to monitoring service
    console.warn(`Memory anomaly detected: ${increase.toFixed(2)}% increase`);
  }
  
  stop() {
    if (this.intervalId) {
      clearInterval(this.intervalId);
    }
  }
}
```

#### Long-Running Page Detection

```javascript
// Track page lifetime and correlate with memory
class PageLifetimeTracker {
  constructor() {
    this.startTime = Date.now();
    this.checkInterval = setInterval(() => {
      this.checkLifetime();
    }, 300000); // Every 5 minutes
  }
  
  checkLifetime() {
    const lifetime = Date.now() - this.startTime;
    const hours = lifetime / (1000 * 60 * 60);
    
    if (hours > 4 && performance.memory) {
      const usage = performance.memory.usedJSHeapSize;
      const limit = performance.memory.jsHeapSizeLimit;
      const percent = (usage / limit) * 100;
      
      // [Inference] High memory after long runtime suggests leak
      if (percent > 80) {
        this.reportHighMemory(hours, percent);
      }
    }
  }
  
  reportHighMemory(hours, percent) {
    console.warn(`High memory usage after ${hours.toFixed(1)} hours: ${percent.toFixed(1)}%`);
    // Report to monitoring service
  }
}
```

This comprehensive overview covers the main techniques for detecting, analyzing, and preventing memory leaks in DOM and JavaScript environments. The actual effectiveness of detection methods **[Inference]** varies based on browser implementation, application complexity, and the specific types of leaks present.

---

