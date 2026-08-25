## requestAnimationFrame


### Execution Timing and the Browser Event Loop

`requestAnimationFrame` operates within the browser's rendering pipeline, scheduled to execute before the next repaint. The callback fires approximately 60 times per second on 60Hz displays, but crucially adapts to the display's refresh rate—120Hz on high-refresh monitors, or throttled to lower rates when the tab is inactive or the device is resource-constrained.

The callback receives a single `DOMHighResTimeStamp` parameter representing the time the callback queue began processing. This timestamp originates from `performance.now()` and represents milliseconds elapsed since time origin, providing sub-millisecond precision for accurate frame timing calculations.

```javascript
let lastTime = 0;
function animate(currentTime) {
  const deltaTime = currentTime - lastTime;
  lastTime = currentTime;
  
  console.log(`Frame took ${deltaTime}ms`);
  requestAnimationFrame(animate);
}
requestAnimationFrame(animate);
```

The browser automatically batches all `requestAnimationFrame` callbacks scheduled for the same frame, executing them sequentially before layout and paint. This batching ensures multiple animations can synchronize without triggering layout thrashing.

### Cancellation and Lifecycle Management

`requestAnimationFrame` returns a unique non-zero integer identifier that enables cancellation via `cancelAnimationFrame(id)`. This becomes critical for component unmounting, conditional animations, or cleanup operations.

```javascript
let animationId;

function startAnimation() {
  function loop(time) {
    // animation logic
    animationId = requestAnimationFrame(loop);
  }
  animationId = requestAnimationFrame(loop);
}

function stopAnimation() {
  if (animationId) {
    cancelAnimationFrame(animationId);
    animationId = null;
  }
}
```

Multiple calls to `requestAnimationFrame` before the next frame all receive the same timestamp parameter, ensuring temporal consistency across animation logic. Canceling an already-executed or non-existent ID has no effect and throws no errors.

### Frame Budget and Performance Optimization

Each frame has approximately 16.67ms at 60fps to complete all JavaScript execution, style calculation, layout, paint, and composite operations. `requestAnimationFrame` callbacks should target 10-12ms execution time maximum, leaving headroom for browser operations.

#### Measuring Frame Performance

```javascript
function animate(time) {
  const frameStart = performance.now();
  
  // Your animation work
  updatePositions();
  renderScene();
  
  const frameDuration = performance.now() - frameStart;
  
  if (frameDuration > 16) {
    console.warn(`Long frame: ${frameDuration.toFixed(2)}ms`);
  }
  
  requestAnimationFrame(animate);
}
```

Heavy computational work should be deferred using techniques like time-slicing, where work is distributed across multiple frames:

```javascript
function processLargeDataset(data, callback) {
  let index = 0;
  const chunkSize = 100;
  
  function processChunk(time) {
    const chunkEnd = Math.min(index + chunkSize, data.length);
    
    while (index < chunkEnd) {
      // Process data[index]
      index++;
    }
    
    if (index < data.length) {
      requestAnimationFrame(processChunk);
    } else {
      callback();
    }
  }
  
  requestAnimationFrame(processChunk);
}
```

### Throttling and Tab Visibility

Browsers aggressively throttle `requestAnimationFrame` in background tabs, often reducing execution to 1-2fps or pausing entirely. The Page Visibility API provides explicit control:

```javascript
let isAnimating = false;
let animationId;

function animate(time) {
  // animation logic
  if (isAnimating) {
    animationId = requestAnimationFrame(animate);
  }
}

document.addEventListener('visibilitychange', () => {
  if (document.hidden) {
    isAnimating = false;
    if (animationId) {
      cancelAnimationFrame(animationId);
    }
  } else {
    isAnimating = true;
    requestAnimationFrame(animate);
  }
});
```

This prevents unnecessary CPU usage and battery drain when animations aren't visible. Some browsers also throttle based on device battery state or thermal conditions.

### Delta Time and Frame-Rate Independence

Using the timestamp parameter to calculate delta time ensures animations run at consistent speeds regardless of frame rate variations:

```javascript
const velocity = 100; // pixels per second
let position = 0;
let lastTime = null;

function animate(currentTime) {
  if (lastTime !== null) {
    const deltaTime = (currentTime - lastTime) / 1000; // convert to seconds
    position += velocity * deltaTime;
  }
  lastTime = currentTime;
  
  element.style.transform = `translateX(${position}px)`;
  requestAnimationFrame(animate);
}
```

Without delta time, animations would run faster on high-refresh displays and slower when frames are dropped. This approach maintains consistent animation speeds across varying performance conditions.

### Recursive vs. Continuous Scheduling

The standard pattern involves recursive scheduling where each callback schedules the next:

```javascript
function loop(time) {
  // work
  requestAnimationFrame(loop);
}
requestAnimationFrame(loop);
```

However, scheduling can be conditional based on animation state:

```javascript
class Animation {
  constructor() {
    this.isRunning = false;
    this.animationId = null;
  }
  
  start() {
    if (!this.isRunning) {
      this.isRunning = true;
      this.loop(performance.now());
    }
  }
  
  loop(time) {
    // animation work
    
    if (this.isRunning) {
      this.animationId = requestAnimationFrame(t => this.loop(t));
    }
  }
  
  stop() {
    this.isRunning = false;
    if (this.animationId) {
      cancelAnimationFrame(this.animationId);
    }
  }
}
```

### Interaction with Layout and Paint

`requestAnimationFrame` callbacks execute after the previous frame's composite but before style recalculation and layout for the current frame. This timing means:

- Reading layout properties (offsetWidth, getBoundingClientRect) triggers immediate layout if styles changed
- Writing DOM or CSSOM properties doesn't immediately trigger layout
- The actual paint occurs after all rAF callbacks complete

#### Avoiding Layout Thrashing

```javascript
// BAD: Causes layout thrashing
function animateBad() {
  elements.forEach(el => {
    const width = el.offsetWidth; // Read (forces layout)
    el.style.width = width + 10 + 'px'; // Write
  });
  requestAnimationFrame(animateBad);
}

// GOOD: Batch reads and writes
function animateGood() {
  // Batch all reads first
  const widths = elements.map(el => el.offsetWidth);
  
  // Then batch all writes
  elements.forEach((el, i) => {
    el.style.width = widths[i] + 10 + 'px';
  });
  
  requestAnimationFrame(animateGood);
}
```

For complex scenarios, libraries like FastDOM provide automatic read/write batching.

### Canvas and WebGL Rendering

For canvas-based animations, `requestAnimationFrame` coordinates with the canvas's rendering context:

```javascript
const canvas = document.querySelector('canvas');
const ctx = canvas.getContext('2d');

function draw(time) {
  // Clear canvas
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  
  // Drawing operations
  ctx.fillStyle = `hsl(${time * 0.1 % 360}, 70%, 50%)`;
  ctx.fillRect(50, 50, 100, 100);
  
  requestAnimationFrame(draw);
}
requestAnimationFrame(draw);
```

WebGL rendering follows similar patterns but benefits more significantly from rAF's synchronization with vsync, eliminating tearing:

```javascript
function render(time) {
  gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
  
  // Update uniforms
  gl.uniform1f(timeUniformLocation, time * 0.001);
  
  // Draw calls
  gl.drawArrays(gl.TRIANGLES, 0, vertexCount);
  
  requestAnimationFrame(render);
}
```

### Timestamp Precision and Timing Attacks

The DOMHighResTimeStamp provides microsecond precision on most platforms, but browsers may reduce precision to mitigate timing attacks (Spectre variants). Firefox and Safari round timestamps to 100μs or 1ms in certain contexts.

This affects timing-sensitive applications:

```javascript
function measurePrecision() {
  const samples = [];
  let count = 0;
  
  function collect(time) {
    samples.push(time);
    if (++count < 100) {
      requestAnimationFrame(collect);
    } else {
      const deltas = samples.slice(1).map((t, i) => t - samples[i]);
      const minDelta = Math.min(...deltas.filter(d => d > 0));
      console.log(`Timestamp precision: ${minDelta}ms`);
    }
  }
  
  requestAnimationFrame(collect);
}
```

Applications requiring precise timing measurements should account for this variability or use performance marks for higher-precision profiling.

### Comparison with setTimeout and setInterval

`setTimeout` and `setInterval` operate independently of the rendering pipeline and provide no vsync synchronization:

```javascript
// Non-synchronized, can cause tearing
setInterval(() => {
  element.style.left = position++ + 'px';
}, 16); // Approximately 60fps, but not aligned with frames

// Synchronized with rendering
function animate() {
  element.style.left = position++ + 'px';
  requestAnimationFrame(animate);
}
```

Key differences:

- **Timing drift**: `setInterval` accumulates drift; rAF stays synchronized with display refresh
- **Background throttling**: `setInterval` may run at full speed in background tabs; rAF throttles appropriately
- **Rendering coordination**: rAF callbacks batch with browser paint cycles; timers do not
- **Energy efficiency**: rAF pauses when invisible; timers continue consuming resources

`setTimeout` remains appropriate for non-visual timing needs or delays that shouldn't sync with frames.

### Multiple Animation Systems

When coordinating multiple independent animations, consider whether they should share a single rAF loop or maintain separate loops:

```javascript
// Shared loop - better performance
const animations = new Set();

function masterLoop(time) {
  animations.forEach(anim => anim.update(time));
  requestAnimationFrame(masterLoop);
}

function registerAnimation(animationFunc) {
  animations.add(animationFunc);
  if (animations.size === 1) {
    requestAnimationFrame(masterLoop);
  }
}

function unregisterAnimation(animationFunc) {
  animations.delete(animationFunc);
}
```

Separate loops make sense for animations with different lifecycles or performance requirements but increase overhead from multiple rAF callbacks per frame.

### Integration with CSS Animations and Transitions

JavaScript animations via rAF can coexist with CSS animations but require coordination to avoid conflicts:

```javascript
// Wait for CSS transition to complete
element.style.transition = 'transform 0.3s';
element.style.transform = 'translateX(100px)';

element.addEventListener('transitionend', () => {
  // Now safe to start JS animation
  function animate(time) {
    // JS animation logic
    requestAnimationFrame(animate);
  }
  requestAnimationFrame(animate);
}, { once: true });
```

Reading computed styles during CSS animations can provide current values:

```javascript
function animate() {
  const currentTransform = getComputedStyle(element).transform;
  // Use current transform matrix for calculations
  
  requestAnimationFrame(animate);
}
```

For optimal performance, prefer CSS animations for simple property transitions and reserve rAF for complex, stateful, or game-like animations requiring per-frame logic.

### Polyfills and Fallbacks

Legacy support requires polyfilling with setTimeout:

```javascript
window.requestAnimationFrame = window.requestAnimationFrame ||
  window.mozRequestAnimationFrame ||
  window.webkitRequestAnimationFrame ||
  function(callback) {
    return window.setTimeout(callback, 1000 / 60);
  };

window.cancelAnimationFrame = window.cancelAnimationFrame ||
  window.mozCancelAnimationFrame ||
  window.webkitCancelAnimationFrame ||
  function(id) {
    clearTimeout(id);
  };
```

This loses vsync benefits but maintains functional compatibility. Modern development typically requires rAF support as a baseline.

### Advanced Patterns: Animation Managers

Production applications benefit from centralized animation management:

```javascript
class AnimationManager {
  constructor() {
    this.animations = new Map();
    this.isRunning = false;
    this.rafId = null;
  }
  
  add(id, callback, priority = 0) {
    this.animations.set(id, { callback, priority });
    if (!this.isRunning) {
      this.start();
    }
  }
  
  remove(id) {
    this.animations.delete(id);
    if (this.animations.size === 0) {
      this.stop();
    }
  }
  
  start() {
    this.isRunning = true;
    this.loop(performance.now());
  }
  
  loop(time) {
    // Sort by priority
    const sorted = Array.from(this.animations.entries())
      .sort((a, b) => b[1].priority - a[1].priority);
    
    for (const [id, { callback }] of sorted) {
      try {
        callback(time);
      } catch (error) {
        console.error(`Animation ${id} error:`, error);
      }
    }
    
    if (this.isRunning) {
      this.rafId = requestAnimationFrame(t => this.loop(t));
    }
  }
  
  stop() {
    this.isRunning = false;
    if (this.rafId) {
      cancelAnimationFrame(this.rafId);
      this.rafId = null;
    }
  }
}

const manager = new AnimationManager();
manager.add('player', (time) => updatePlayer(time), 10);
manager.add('enemies', (time) => updateEnemies(time), 5);
```

This pattern provides error isolation, priority-based execution, and centralized lifecycle control while maintaining a single rAF callback per frame.

---

