## Feature Detection (DOM)


### Detection Methods

#### Property Existence Checking

Direct property access represents the most straightforward detection approach. Check whether a property exists on the relevant DOM object:

```javascript
if ('geolocation' in navigator) {
  // Geolocation API available
}

if ('serviceWorker' in navigator) {
  // Service Worker support present
}

if (document.createElement('canvas').getContext) {
  // Canvas support available
}
```

Property checking works for APIs exposed as properties but fails when implementation details matter beyond mere presence.

#### Method Invocation Testing

Some features require testing whether methods execute without errors:

```javascript
function supportsLocalStorage() {
  try {
    const test = '__storage_test__';
    localStorage.setItem(test, test);
    localStorage.removeItem(test);
    return true;
  } catch(e) {
    return false;
  }
}
```

Private browsing modes and security policies may block storage APIs despite their presence, making invocation tests more reliable than property checks.

#### Element Feature Detection

HTML5 elements and attributes need element-based detection:

```javascript
const input = document.createElement('input');
input.setAttribute('type', 'date');

if (input.type === 'date') {
  // Date input supported
}

// Or for specific attributes
if ('required' in input) {
  // Required attribute supported
}
```

Browsers that don't recognize input types fall back to `type="text"`, enabling comparison-based detection.

#### CSS Feature Queries

The `CSS.supports()` method tests CSS feature availability:

```javascript
if (CSS.supports('display', 'grid')) {
  // CSS Grid supported
}

if (CSS.supports('(display: flex) and (not (display: inline-grid))')) {
  // Complex queries possible
}
```

This JavaScript API mirrors CSS `@supports` rules, providing programmatic access to CSS capability detection.

### Advanced Detection Patterns

#### Feature Object Construction

Create instances to verify full implementation:

```javascript
function supportsWebGL() {
  const canvas = document.createElement('canvas');
  const gl = canvas.getContext('webgl') || canvas.getContext('experimental-webgl');
  return !!(gl && gl instanceof WebGLRenderingContext);
}
```

Context creation confirms not just API presence but functional rendering capability.

#### Event Support Detection

Test whether specific events can be registered:

```javascript
function supportsEvent(eventName, element) {
  element = element || document.createElement('div');
  const eventNameWithPrefix = 'on' + eventName;
  let isSupported = (eventNameWithPrefix in element);
  
  if (!isSupported) {
    element.setAttribute(eventNameWithPrefix, 'return;');
    isSupported = typeof element[eventNameWithPrefix] === 'function';
  }
  
  return isSupported;
}

if (supportsEvent('touchstart')) {
  // Touch events supported
}
```

#### Media Query Matching

Detect viewport and device capabilities:

```javascript
if (window.matchMedia('(pointer: coarse)').matches) {
  // Touch-primary device
}

if (window.matchMedia('(hover: none)').matches) {
  // No hover capability
}

if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
  // User prefers reduced motion
}
```

Media queries expose hardware characteristics and user preferences beyond traditional feature detection.

### Specific Feature Detection Examples

#### Intersection Observer

```javascript
if ('IntersectionObserver' in window &&
    'IntersectionObserverEntry' in window &&
    'intersectionRatio' in IntersectionObserverEntry.prototype) {
  // Full Intersection Observer support
}
```

Multiple checks catch partial implementations during specification evolution.

#### Web Components

```javascript
function supportsWebComponents() {
  return 'customElements' in window &&
         'attachShadow' in Element.prototype &&
         'getRootNode' in Element.prototype &&
         'content' in document.createElement('template');
}
```

Web Components require several interdependent features working together.

#### Passive Event Listeners

```javascript
let passiveSupported = false;

try {
  const options = Object.defineProperty({}, 'passive', {
    get: function() {
      passiveSupported = true;
      return false;
    }
  });
  
  window.addEventListener('test', null, options);
  window.removeEventListener('test', null, options);
} catch(err) {
  passiveSupported = false;
}
```

Passive listener detection requires triggering the getter through addEventListener's options object.

#### ResizeObserver

```javascript
if ('ResizeObserver' in window) {
  const observer = new ResizeObserver(entries => {
    // Handle resize
  });
  observer.observe(element);
}
```

Constructor availability suffices since ResizeObserver has consistent implementation across supporting browsers.

### Detection Libraries vs. Manual Detection

#### Modernizr Integration

Modernizr provides comprehensive feature detection:

```javascript
if (Modernizr.flexbox) {
  // Flexbox available
}

if (Modernizr.webgl) {
  // WebGL available
}
```

The library runs tests at page load and adds classes to the `<html>` element, enabling CSS-based progressive enhancement:

```css
.no-flexbox .container {
  float: left;
}

.flexbox .container {
  display: flex;
}
```

#### Manual Detection Advantages

Direct detection offers:

- Zero external dependencies
- Smaller bundle sizes
- Precise control over test timing
- Ability to test emerging APIs not yet in libraries

#### Hybrid Approaches

Combine library detection for established features with manual checks for cutting-edge APIs:

```javascript
// Use Modernizr for standard features
if (Modernizr.webworkers) {
  // Stable API
}

// Manual detection for new APIs
if ('scheduling' in navigator && 'isInputPending' in navigator.scheduling) {
  // Emerging API not yet in Modernizr
}
```

### Performance Considerations

#### Lazy Detection

Defer detection until feature use:

```javascript
let webGLSupport = null;

function getWebGLSupport() {
  if (webGLSupport === null) {
    webGLSupport = checkWebGL();
  }
  return webGLSupport;
}

function initializeGraphics() {
  if (getWebGLSupport()) {
    // Use WebGL
  }
}
```

Caching prevents redundant tests while avoiding upfront detection cost.

#### Detection Bundling

Group related detections:

```javascript
const capabilities = {
  touch: null,
  pointer: null,
  hover: null
};

function detectInputCapabilities() {
  capabilities.touch = 'ontouchstart' in window;
  capabilities.pointer = window.matchMedia('(pointer: fine)').matches;
  capabilities.hover = window.matchMedia('(hover: hover)').matches;
  return capabilities;
}
```

Single-pass detection reduces overhead when multiple related features need checking.

#### Async Detection

Move expensive tests off the main thread:

```javascript
async function detectVideoCodecs() {
  const video = document.createElement('video');
  
  const codecs = {
    h264: video.canPlayType('video/mp4; codecs="avc1.42E01E"'),
    h265: video.canPlayType('video/mp4; codecs="hev1.1.6.L93.B0"'),
    vp9: video.canPlayType('video/webm; codecs="vp9"'),
    av1: video.canPlayType('video/mp4; codecs="av01.0.05M.08"')
  };
  
  return codecs;
}
```

### Polyfill Loading Strategies

#### Conditional Loading

Load polyfills only when needed:

```javascript
async function loadPolyfills() {
  const polyfills = [];
  
  if (!('IntersectionObserver' in window)) {
    polyfills.push(import('intersection-observer'));
  }
  
  if (!window.fetch) {
    polyfills.push(import('whatwg-fetch'));
  }
  
  await Promise.all(polyfills);
}

loadPolyfills().then(() => {
  // Initialize application
});
```

#### Dynamic Script Injection

```javascript
function loadPolyfill(url) {
  return new Promise((resolve, reject) => {
    const script = document.createElement('script');
    script.src = url;
    script.onload = resolve;
    script.onerror = reject;
    document.head.appendChild(script);
  });
}

if (!('IntersectionObserver' in window)) {
  loadPolyfill('/polyfills/intersection-observer.js').then(init);
} else {
  init();
}
```

#### Service-Based Polyfilling

Polyfill.io serves browser-specific bundles:

```html
<script src="https://polyfill.io/v3/polyfill.min.js?features=IntersectionObserver,fetch"></script>
```

The service detects the requesting browser and returns only necessary polyfills, reducing payload size.

### Common Pitfalls

#### False Positives

Browsers may expose APIs that don't fully work:

```javascript
// Insufficient - property exists but may not work
if ('requestIdleCallback' in window) {
  // May not behave correctly in all browsers
}

// Better - test actual behavior
function supportsIdleCallback() {
  if (!('requestIdleCallback' in window)) return false;
  
  try {
    let supported = false;
    requestIdleCallback(() => { supported = true; }, { timeout: 0 });
    return supported;
  } catch(e) {
    return false;
  }
}
```

[Inference] Testing execution behavior provides more reliable detection than property checks alone, though this adds complexity.

#### Vendor Prefixes

Older APIs require prefix checking:

```javascript
function getRequestAnimationFrame() {
  return window.requestAnimationFrame ||
         window.webkitRequestAnimationFrame ||
         window.mozRequestAnimationFrame ||
         window.oRequestAnimationFrame ||
         window.msRequestAnimationFrame ||
         function(callback) {
           window.setTimeout(callback, 1000 / 60);
         };
}

const raf = getRequestAnimationFrame();
```

Modern APIs typically avoid prefixes, but legacy prefix handling remains necessary for older browser support.

#### Privacy-Impacting Features

Feature detection can reveal user characteristics:

```javascript
// Battery status removed from many browsers due to fingerprinting
if ('getBattery' in navigator) {
  // Available but privacy-sensitive
}

// Canvas fingerprinting possible through feature support patterns
const canvas = document.createElement('canvas');
const gl = canvas.getContext('webgl');
// Analyzing available extensions reveals GPU info
```

[Unverified] Privacy concerns have led browsers to remove or restrict some detection mechanisms.

### Detection Timing

#### DOMContentLoaded vs. Load

```javascript
// Early detection - DOM ready
document.addEventListener('DOMContentLoaded', () => {
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('/sw.js');
  }
});

// Later detection - all resources loaded
window.addEventListener('load', () => {
  // More expensive tests after initial render
  detectVideoCodecs();
});
```

#### Immediate Execution

Some detection must run synchronously:

```javascript
(function() {
  // Detect before any DOM interaction
  const hasTouch = 'ontouchstart' in window;
  
  if (hasTouch) {
    document.documentElement.classList.add('touch');
  } else {
    document.documentElement.classList.add('no-touch');
  }
})();
```

Immediate detection prevents layout shifts when applying CSS based on capabilities.

### Testing Detection Logic

#### Unit Testing

```javascript
describe('Feature Detection', () => {
  it('should detect IntersectionObserver', () => {
    if ('IntersectionObserver' in window) {
      expect(detectIntersectionObserver()).toBe(true);
    } else {
      expect(detectIntersectionObserver()).toBe(false);
    }
  });
  
  it('should handle missing features gracefully', () => {
    const originalIO = window.IntersectionObserver;
    delete window.IntersectionObserver;
    
    expect(detectIntersectionObserver()).toBe(false);
    
    window.IntersectionObserver = originalIO;
  });
});
```

#### Cross-Browser Testing

Automated testing across browsers validates detection accuracy:

```javascript
// BrowserStack, Sauce Labs, or similar
const browsers = [
  'chrome_latest',
  'firefox_latest',
  'safari_latest',
  'edge_latest',
  'ie_11'
];

browsers.forEach(browser => {
  test(`Feature detection works in ${browser}`, async () => {
    const result = await runInBrowser(browser, detectFeatures);
    expect(result).toMatchSnapshot();
  });
});
```

### Progressive Enhancement Patterns

#### Layered Enhancement

```javascript
class ImageGallery {
  constructor(element) {
    this.element = element;
    this.initBasic();
    
    if ('IntersectionObserver' in window) {
      this.initLazyLoading();
    }
    
    if ('loading' in HTMLImageElement.prototype) {
      this.initNativeLazyLoading();
    }
    
    if (window.matchMedia('(hover: hover)').matches) {
      this.initHoverEffects();
    }
  }
  
  initBasic() {
    // Core functionality works everywhere
  }
  
  initLazyLoading() {
    // Enhanced loading with IntersectionObserver
  }
  
  initNativeLazyLoading() {
    // Use native lazy loading when available
  }
  
  initHoverEffects() {
    // Only add hover effects on hover-capable devices
  }
}
```

#### Graceful Degradation

```javascript
function setupVideoPlayer(element) {
  const video = element.querySelector('video');
  
  // Basic HTML5 video
  video.controls = true;
  
  // Enhanced controls if APIs available
  if ('pictureInPictureEnabled' in document) {
    addPiPButton(video);
  }
  
  if ('mediaSession' in navigator) {
    setupMediaSession(video);
  }
  
  // Fullscreen with vendor prefixes
  if (video.requestFullscreen) {
    addFullscreenButton(video);
  } else if (video.webkitRequestFullscreen) {
    addFullscreenButton(video, 'webkit');
  } else if (video.mozRequestFullScreen) {
    addFullscreenButton(video, 'moz');
  }
}
```

Each enhancement layer adds functionality without breaking core features in less-capable browsers.

---

