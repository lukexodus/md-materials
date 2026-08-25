## Polyfills in JavaScript and DOM APIs


### What Polyfills Are

Polyfills are code implementations that provide modern functionality in older environments that lack native support. They detect missing features and implement equivalent behavior using available primitives, allowing developers to use newer APIs while maintaining backward compatibility.

### Detection Pattern

Polyfills follow a standard detection-before-implementation pattern:

```javascript
if (!Array.prototype.includes) {
  Array.prototype.includes = function(searchElement, fromIndex) {
    // Implementation
  };
}
```

This prevents overwriting native implementations and ensures polyfills only run when necessary.

### Core JavaScript Polyfills

#### Array Methods

**Array.prototype.includes**

Searches for an element using SameValueZero comparison:

```javascript
if (!Array.prototype.includes) {
  Array.prototype.includes = function(searchElement, fromIndex) {
    var O = Object(this);
    var len = parseInt(O.length) || 0;
    if (len === 0) return false;
    
    var n = parseInt(fromIndex) || 0;
    var k = Math.max(n >= 0 ? n : len - Math.abs(n), 0);
    
    while (k < len) {
      if (sameValueZero(O[k], searchElement)) return true;
      k++;
    }
    return false;
    
    function sameValueZero(x, y) {
      return x === y || (typeof x === 'number' && typeof y === 'number' && isNaN(x) && isNaN(y));
    }
  };
}
```

**Array.prototype.find / findIndex**

Locate elements matching predicates:

```javascript
if (!Array.prototype.find) {
  Array.prototype.find = function(predicate, thisArg) {
    var list = Object(this);
    var length = list.length >>> 0;
    var value;
    
    for (var i = 0; i < length; i++) {
      value = list[i];
      if (predicate.call(thisArg, value, i, list)) {
        return value;
      }
    }
    return undefined;
  };
}
```

**Array.from**

Creates arrays from array-like or iterable objects:

```javascript
if (!Array.from) {
  Array.from = function(arrayLike, mapFn, thisArg) {
    var C = this;
    var items = Object(arrayLike);
    
    if (arrayLike == null) {
      throw new TypeError('Array.from requires an array-like object');
    }
    
    var mapFunction = arguments.length > 1 ? mapFn : undefined;
    var T;
    if (typeof mapFunction !== 'undefined') {
      if (typeof mapFunction !== 'function') {
        throw new TypeError('Array.from: when provided, the second argument must be a function');
      }
      if (arguments.length > 2) {
        T = thisArg;
      }
    }
    
    var len = parseInt(items.length) || 0;
    var A = typeof C === 'function' ? Object(new C(len)) : new Array(len);
    var k = 0;
    var kValue;
    
    while (k < len) {
      kValue = items[k];
      if (mapFunction) {
        A[k] = typeof T === 'undefined' ? mapFunction(kValue, k) : mapFunction.call(T, kValue, k);
      } else {
        A[k] = kValue;
      }
      k++;
    }
    A.length = len;
    return A;
  };
}
```

#### Object Methods

**Object.assign**

Shallow-copies enumerable own properties:

```javascript
if (typeof Object.assign !== 'function') {
  Object.assign = function(target) {
    if (target == null) {
      throw new TypeError('Cannot convert undefined or null to object');
    }
    
    var to = Object(target);
    
    for (var i = 1; i < arguments.length; i++) {
      var nextSource = arguments[i];
      
      if (nextSource != null) {
        for (var nextKey in nextSource) {
          if (Object.prototype.hasOwnProperty.call(nextSource, nextKey)) {
            to[nextKey] = nextSource[nextKey];
          }
        }
      }
    }
    return to;
  };
}
```

**Object.keys / values / entries**

Extract object properties:

```javascript
if (!Object.keys) {
  Object.keys = function(obj) {
    var keys = [];
    for (var key in obj) {
      if (Object.prototype.hasOwnProperty.call(obj, key)) {
        keys.push(key);
      }
    }
    return keys;
  };
}

if (!Object.values) {
  Object.values = function(obj) {
    var values = [];
    for (var key in obj) {
      if (Object.prototype.hasOwnProperty.call(obj, key)) {
        values.push(obj[key]);
      }
    }
    return values;
  };
}

if (!Object.entries) {
  Object.entries = function(obj) {
    var entries = [];
    for (var key in obj) {
      if (Object.prototype.hasOwnProperty.call(obj, key)) {
        entries.push([key, obj[key]]);
      }
    }
    return entries;
  };
}
```

#### String Methods

**String.prototype.startsWith / endsWith / includes**

```javascript
if (!String.prototype.startsWith) {
  String.prototype.startsWith = function(search, pos) {
    pos = !pos || pos < 0 ? 0 : +pos;
    return this.substring(pos, pos + search.length) === search;
  };
}

if (!String.prototype.endsWith) {
  String.prototype.endsWith = function(search, this_len) {
    if (this_len === undefined || this_len > this.length) {
      this_len = this.length;
    }
    return this.substring(this_len - search.length, this_len) === search;
  };
}

if (!String.prototype.includes) {
  String.prototype.includes = function(search, start) {
    if (typeof start !== 'number') {
      start = 0;
    }
    if (start + search.length > this.length) {
      return false;
    }
    return this.indexOf(search, start) !== -1;
  };
}
```

**String.prototype.repeat**

```javascript
if (!String.prototype.repeat) {
  String.prototype.repeat = function(count) {
    if (this == null) throw new TypeError();
    var str = '' + this;
    count = +count;
    if (count != count) count = 0;
    if (count < 0) throw new RangeError();
    if (count == Infinity) throw new RangeError();
    count = Math.floor(count);
    if (str.length == 0 || count == 0) return '';
    
    if (str.length * count >= 1 << 28) {
      throw new RangeError();
    }
    
    var result = '';
    while (true) {
      if ((count & 1) == 1) result += str;
      count >>>= 1;
      if (count == 0) break;
      str += str;
    }
    return result;
  };
}
```

#### Promise

Full Promise/A+ implementation:

```javascript
if (typeof Promise === 'undefined') {
  (function() {
    var PENDING = 0;
    var FULFILLED = 1;
    var REJECTED = 2;
    
    function Promise(executor) {
      if (typeof this !== 'object') {
        throw new TypeError('Promises must be constructed via new');
      }
      if (typeof executor !== 'function') {
        throw new TypeError('Promise resolver is not a function');
      }
      
      this._state = PENDING;
      this._value = undefined;
      this._deferreds = [];
      
      doResolve(executor, this);
    }
    
    function handle(self, deferred) {
      while (self._state === 3) {
        self = self._value;
      }
      
      if (self._state === PENDING) {
        self._deferreds.push(deferred);
        return;
      }
      
      var cb = self._state === FULFILLED ? deferred.onFulfilled : deferred.onRejected;
      
      if (cb === null) {
        (self._state === FULFILLED ? resolve : reject)(deferred.promise, self._value);
        return;
      }
      
      var ret;
      try {
        ret = cb(self._value);
      } catch (e) {
        reject(deferred.promise, e);
        return;
      }
      resolve(deferred.promise, ret);
    }
    
    function resolve(self, newValue) {
      try {
        if (newValue === self) {
          throw new TypeError('A promise cannot be resolved with itself.');
        }
        if (newValue && (typeof newValue === 'object' || typeof newValue === 'function')) {
          var then = newValue.then;
          if (newValue instanceof Promise) {
            self._state = 3;
            self._value = newValue;
            finale(self);
            return;
          } else if (typeof then === 'function') {
            doResolve(then.bind(newValue), self);
            return;
          }
        }
        self._state = FULFILLED;
        self._value = newValue;
        finale(self);
      } catch (e) {
        reject(self, e);
      }
    }
    
    function reject(self, newValue) {
      self._state = REJECTED;
      self._value = newValue;
      finale(self);
    }
    
    function finale(self) {
      for (var i = 0; i < self._deferreds.length; i++) {
        handle(self, self._deferreds[i]);
      }
      self._deferreds = null;
    }
    
    function Handler(onFulfilled, onRejected, promise) {
      this.onFulfilled = typeof onFulfilled === 'function' ? onFulfilled : null;
      this.onRejected = typeof onRejected === 'function' ? onRejected : null;
      this.promise = promise;
    }
    
    function doResolve(fn, self) {
      var done = false;
      try {
        fn(function(value) {
          if (done) return;
          done = true;
          resolve(self, value);
        }, function(reason) {
          if (done) return;
          done = true;
          reject(self, reason);
        });
      } catch (ex) {
        if (done) return;
        done = true;
        reject(self, ex);
      }
    }
    
    Promise.prototype.then = function(onFulfilled, onRejected) {
      var prom = new Promise(function() {});
      handle(this, new Handler(onFulfilled, onRejected, prom));
      return prom;
    };
    
    Promise.prototype.catch = function(onRejected) {
      return this.then(null, onRejected);
    };
    
    Promise.all = function(arr) {
      return new Promise(function(resolve, reject) {
        if (!Array.isArray(arr)) {
          return reject(new TypeError('Promise.all accepts an array'));
        }
        
        var args = Array.prototype.slice.call(arr);
        if (args.length === 0) return resolve([]);
        var remaining = args.length;
        
        function res(i, val) {
          try {
            if (val && (typeof val === 'object' || typeof val === 'function')) {
              var then = val.then;
              if (typeof then === 'function') {
                then.call(val, function(val) {
                  res(i, val);
                }, reject);
                return;
              }
            }
            args[i] = val;
            if (--remaining === 0) {
              resolve(args);
            }
          } catch (ex) {
            reject(ex);
          }
        }
        
        for (var i = 0; i < args.length; i++) {
          res(i, args[i]);
        }
      });
    };
    
    Promise.resolve = function(value) {
      if (value && typeof value === 'object' && value.constructor === Promise) {
        return value;
      }
      return new Promise(function(resolve) {
        resolve(value);
      });
    };
    
    Promise.reject = function(value) {
      return new Promise(function(resolve, reject) {
        reject(value);
      });
    };
    
    Promise.race = function(values) {
      return new Promise(function(resolve, reject) {
        for (var i = 0; i < values.length; i++) {
          values[i].then(resolve, reject);
        }
      });
    };
    
    window.Promise = Promise;
  })();
}
```

### DOM API Polyfills

#### Element.classList

Manipulates CSS classes on elements:

```javascript
if (!('classList' in document.documentElement)) {
  Object.defineProperty(Element.prototype, 'classList', {
    get: function() {
      var element = this;
      var classNames = (element.className || '').replace(/^\s+|\s+$/g, '').split(/\s+/);
      if (classNames[0] === '') classNames.shift();
      
      function update() {
        element.className = classNames.join(' ');
      }
      
      var classList = {
        length: classNames.length,
        item: function(i) {
          return classNames[i] || null;
        },
        contains: function(className) {
          return classNames.indexOf(className) !== -1;
        },
        add: function() {
          for (var i = 0; i < arguments.length; i++) {
            var className = arguments[i];
            if (classNames.indexOf(className) === -1) {
              classNames.push(className);
            }
          }
          update();
        },
        remove: function() {
          for (var i = 0; i < arguments.length; i++) {
            var className = arguments[i];
            var index = classNames.indexOf(className);
            if (index !== -1) {
              classNames.splice(index, 1);
            }
          }
          update();
        },
        toggle: function(className, force) {
          var hasClass = classNames.indexOf(className) !== -1;
          if (force !== undefined) {
            if (force) {
              if (!hasClass) classNames.push(className);
            } else {
              if (hasClass) classNames.splice(classNames.indexOf(className), 1);
            }
          } else {
            if (hasClass) {
              classNames.splice(classNames.indexOf(className), 1);
            } else {
              classNames.push(className);
            }
          }
          update();
          return classNames.indexOf(className) !== -1;
        }
      };
      
      return classList;
    }
  });
}
```

#### Element.closest

Traverses ancestors to find matching selector:

```javascript
if (!Element.prototype.closest) {
  Element.prototype.closest = function(selector) {
    var el = this;
    if (!document.documentElement.contains(el)) return null;
    
    do {
      if (el.matches(selector)) return el;
      el = el.parentElement || el.parentNode;
    } while (el !== null && el.nodeType === 1);
    
    return null;
  };
}
```

#### Element.matches

Tests if element matches selector:

```javascript
if (!Element.prototype.matches) {
  Element.prototype.matches = 
    Element.prototype.matchesSelector ||
    Element.prototype.mozMatchesSelector ||
    Element.prototype.msMatchesSelector ||
    Element.prototype.oMatchesSelector ||
    Element.prototype.webkitMatchesSelector ||
    function(s) {
      var matches = (this.document || this.ownerDocument).querySelectorAll(s);
      var i = matches.length;
      while (--i >= 0 && matches.item(i) !== this) {}
      return i > -1;
    };
}
```

#### CustomEvent

Creates custom events with detail data:

```javascript
if (typeof window.CustomEvent !== 'function') {
  function CustomEvent(event, params) {
    params = params || { bubbles: false, cancelable: false, detail: null };
    var evt = document.createEvent('CustomEvent');
    evt.initCustomEvent(event, params.bubbles, params.cancelable, params.detail);
    return evt;
  }
  
  CustomEvent.prototype = window.Event.prototype;
  window.CustomEvent = CustomEvent;
}
```

#### Element.remove

Removes element from DOM:

```javascript
if (!('remove' in Element.prototype)) {
  Element.prototype.remove = function() {
    if (this.parentNode) {
      this.parentNode.removeChild(this);
    }
  };
}
```

#### Element.append / prepend

Adds nodes or strings to element:

```javascript
if (!Element.prototype.append) {
  Element.prototype.append = function() {
    var argArr = Array.prototype.slice.call(arguments);
    var docFrag = document.createDocumentFragment();
    
    argArr.forEach(function(argItem) {
      var isNode = argItem instanceof Node;
      docFrag.appendChild(isNode ? argItem : document.createTextNode(String(argItem)));
    });
    
    this.appendChild(docFrag);
  };
}

if (!Element.prototype.prepend) {
  Element.prototype.prepend = function() {
    var argArr = Array.prototype.slice.call(arguments);
    var docFrag = document.createDocumentFragment();
    
    argArr.forEach(function(argItem) {
      var isNode = argItem instanceof Node;
      docFrag.appendChild(isNode ? argItem : document.createTextNode(String(argItem)));
    });
    
    this.insertBefore(docFrag, this.firstChild);
  };
}
```

#### NodeList.forEach

Iterates over NodeList:

```javascript
if (window.NodeList && !NodeList.prototype.forEach) {
  NodeList.prototype.forEach = Array.prototype.forEach;
}
```

#### requestAnimationFrame

Frame-based animation timing:

```javascript
(function() {
  var lastTime = 0;
  var vendors = ['ms', 'moz', 'webkit', 'o'];
  
  for (var x = 0; x < vendors.length && !window.requestAnimationFrame; ++x) {
    window.requestAnimationFrame = window[vendors[x] + 'RequestAnimationFrame'];
    window.cancelAnimationFrame = window[vendors[x] + 'CancelAnimationFrame'] ||
                                   window[vendors[x] + 'CancelRequestAnimationFrame'];
  }
  
  if (!window.requestAnimationFrame) {
    window.requestAnimationFrame = function(callback) {
      var currTime = new Date().getTime();
      var timeToCall = Math.max(0, 16 - (currTime - lastTime));
      var id = window.setTimeout(function() {
        callback(currTime + timeToCall);
      }, timeToCall);
      lastTime = currTime + timeToCall;
      return id;
    };
  }
  
  if (!window.cancelAnimationFrame) {
    window.cancelAnimationFrame = function(id) {
      clearTimeout(id);
    };
  }
})();
```

#### window.fetch

Network requests with Promise-based API:

```javascript
if (!window.fetch) {
  window.fetch = function(url, options) {
    return new Promise(function(resolve, reject) {
      var xhr = new XMLHttpRequest();
      options = options || {};
      
      xhr.open(options.method || 'GET', url, true);
      
      if (options.headers) {
        Object.keys(options.headers).forEach(function(key) {
          xhr.setRequestHeader(key, options.headers[key]);
        });
      }
      
      xhr.onload = function() {
        var response = {
          ok: xhr.status >= 200 && xhr.status < 300,
          status: xhr.status,
          statusText: xhr.statusText,
          url: xhr.responseURL,
          text: function() {
            return Promise.resolve(xhr.responseText);
          },
          json: function() {
            return Promise.resolve(JSON.parse(xhr.responseText));
          },
          blob: function() {
            return Promise.resolve(new Blob([xhr.response]));
          },
          arrayBuffer: function() {
            return Promise.resolve(xhr.response);
          }
        };
        resolve(response);
      };
      
      xhr.onerror = function() {
        reject(new TypeError('Network request failed'));
      };
      
      xhr.ontimeout = function() {
        reject(new TypeError('Network request timed out'));
      };
      
      xhr.send(options.body || null);
    });
  };
}
```

### Modern API Polyfills

#### Intersection Observer

Detects element visibility in viewport:

```javascript
if (!('IntersectionObserver' in window)) {
  window.IntersectionObserver = function(callback, options) {
    options = options || {};
    this.callback = callback;
    this.root = options.root || null;
    this.rootMargin = options.rootMargin || '0px';
    this.thresholds = options.threshold || [0];
    this.observedElements = [];
    
    this.checkIntersections = function() {
      var entries = [];
      this.observedElements.forEach(function(el) {
        var rect = el.getBoundingClientRect();
        var rootRect = this.root ? this.root.getBoundingClientRect() : {
          top: 0,
          left: 0,
          bottom: window.innerHeight,
          right: window.innerWidth
        };
        
        var isIntersecting = !(
          rect.bottom < rootRect.top ||
          rect.top > rootRect.bottom ||
          rect.right < rootRect.left ||
          rect.left > rootRect.right
        );
        
        entries.push({
          target: el,
          isIntersecting: isIntersecting,
          intersectionRatio: isIntersecting ? 1 : 0,
          boundingClientRect: rect,
          rootBounds: rootRect,
          time: Date.now()
        });
      }.bind(this));
      
      if (entries.length > 0) {
        this.callback(entries, this);
      }
    }.bind(this);
    
    this.intervalId = setInterval(this.checkIntersections, 100);
  };
  
  window.IntersectionObserver.prototype.observe = function(element) {
    if (this.observedElements.indexOf(element) === -1) {
      this.observedElements.push(element);
    }
  };
  
  window.IntersectionObserver.prototype.unobserve = function(element) {
    var index = this.observedElements.indexOf(element);
    if (index !== -1) {
      this.observedElements.splice(index, 1);
    }
  };
  
  window.IntersectionObserver.prototype.disconnect = function() {
    clearInterval(this.intervalId);
    this.observedElements = [];
  };
}
```

#### ResizeObserver

Monitors element size changes:

```javascript
if (!window.ResizeObserver) {
  window.ResizeObserver = function(callback) {
    this.callback = callback;
    this.observedElements = new Map();
    
    this.checkSizes = function() {
      var entries = [];
      this.observedElements.forEach(function(lastSize, element) {
        var rect = element.getBoundingClientRect();
        var currentSize = { width: rect.width, height: rect.height };
        
        if (lastSize.width !== currentSize.width || lastSize.height !== currentSize.height) {
          entries.push({
            target: element,
            contentRect: rect
          });
          this.observedElements.set(element, currentSize);
        }
      }.bind(this));
      
      if (entries.length > 0) {
        this.callback(entries, this);
      }
    }.bind(this);
    
    this.intervalId = setInterval(this.checkSizes, 100);
  };
  
  window.ResizeObserver.prototype.observe = function(element) {
    var rect = element.getBoundingClientRect();
    this.observedElements.set(element, { width: rect.width, height: rect.height });
  };
  
  window.ResizeObserver.prototype.unobserve = function(element) {
    this.observedElements.delete(element);
  };
  
  window.ResizeObserver.prototype.disconnect = function() {
    clearInterval(this.intervalId);
    this.observedElements.clear();
  };
}
```

### Polyfill Loading Strategies

#### Conditional Loading

Load polyfills only when needed:

```javascript
function loadPolyfill(test, url, callback) {
  if (test) {
    callback();
  } else {
    var script = document.createElement('script');
    script.src = url;
    script.onload = callback;
    document.head.appendChild(script);
  }
}

// Usage
loadPolyfill(
  'Promise' in window,
  'https://cdn.example.com/promise-polyfill.js',
  function() {
    // Continue app initialization
  }
);
```

#### Feature Detection Bundle

```javascript
var features = {
  promise: 'Promise' in window,
  fetch: 'fetch' in window,
  assign: typeof Object.assign === 'function',
  includes: Array.prototype.includes !== undefined,
  classList: 'classList' in document.createElement('div')
};

var polyfillsNeeded = [];
if (!features.promise) polyfillsNeeded.push('promise');
if (!features.fetch) polyfillsNeeded.push('fetch');
if (!features.assign) polyfillsNeeded.push('object-assign');

if (polyfillsNeeded.length > 0) {
  loadPolyfills(polyfillsNeeded, function() {
    initApp();
  });
} else {
  initApp();
}
```

#### Polyfill Service Pattern

```javascript
// Dynamic polyfill loading based on UA
(function() {
  var polyfillUrl = 'https://polyfill.io/v3/polyfill.min.js?features=';
  var features = [];
  
  if (!window.Promise) features.push('Promise');
  if (!window.fetch) features.push('fetch');
  if (!Array.from) features.push('Array.from');
  if (!Object.assign) features.push('Object.assign');
  
  if (features.length > 0) {
    var script = document.createElement('script');
    script.src = polyfillUrl + features.join(',');
    script.async = false;
    document.head.appendChild(script);
  }
})();
```

### Polyfill Best Practices

#### Spec Compliance

Polyfills should match specification behavior exactly, including edge cases:

```javascript
// Incorrect - doesn't handle negative indices
Array.prototype.at = function(index) {
  return this[index];
};

// Correct - handles negative indices per spec
if (!Array.prototype.at) {
  Array.prototype.at = function(index) {
    var n = parseInt(index) || 0;
    if (n < 0) n += this.length;
    if (n < 0 || n >= this.length) return undefined;
    return this[n];
  };
}
```

#### Performance Considerations

Polyfills can be slower than native implementations:

```javascript
// Native forEach is typically 5-10x faster than polyfilled version
// Consider performance impact for tight loops

// Bad for performance-critical code
if (!Array.prototype.forEach) {
  Array.prototype.forEach = function(callback, thisArg) {
    // Implementation...
  };
}

// Better: detect and use native when available
var forEach = Array.prototype.forEach || function(callback, thisArg) {
  // Polyfill implementation
};
```

#### Avoiding Prototype Pollution

```javascript
// Bad - pollutes global namespace
Array.prototype.customMethod = function() { /* ... */ };

// Better - only polyfill standard APIs
if (!Array.prototype.includes) {
  // Standard polyfill
}

// For custom methods, use utilities instead
var arrayUtils = {
  customMethod: function(arr) { /* ... */ }
};
```

### Testing Polyfills

#### Cross-Browser Testing

```javascript
// Test suite for polyfill validation
function testArrayIncludes() {
  var arr = [1, 2, 3, NaN, undefined];
  
  console.assert(arr.includes(1) === true, 'Should find existing element');
  console.assert(arr.includes(4) === false, 'Should not find missing element');
  console.assert(arr.includes(NaN) === true, 'Should find NaN');
  console.assert(arr.includes(undefined) === true, 'Should find undefined');
  console.assert(arr.includes(2, 2) === false, 'Should respect fromIndex');
  console.assert(arr.includes(2, -3) === true, 'Should handle negative fromIndex');
}
```

#### Regression Testing

```javascript
// Store reference to native implementation if exists
var nativeIncludes = Array.prototype.includes;

// After polyfill loads, compare behaviors
function validatePolyfill() {
  if (nativeIncludes) {
    var testCases = [
      [[1, 2, 3], [2]],
      [[1, 2, 3], [4]],
      [[NaN], [NaN]],
      [[1, 2, 3], [2, 2]]
    ];
    
    testCases.forEach(function(test) {
      var arr = test[0];
      var args = test[1];
      var nativeResult = nativeIncludes.apply(arr, args);
      var polyfillResult = Array.prototype.includes.apply(arr, args);
      
      if (nativeResult !== polyfillResult) {
        console.error('Polyfill behavior differs from native', test);
      }
    });
  }
}
```

### Transpilation vs Polyfilling

Transpilers (Babel) handle syntax, polyfills handle APIs:

```javascript
// Syntax - requires transpilation
const arrow = () => {};
class MyClass {}
const { a, b } = obj;

// APIs - require polyfills
Promise.resolve();
Array.from();
Object.assign();
```

Babel with `@babel/preset-env` and `useBuiltIns: 'usage'`:

```javascript
// Automatically includes only needed polyfills based on target browsers
// Input:
const p = Promise.resolve();
const arr = Array.from([1, 2, 3]);

// Output (with polyfills injected):
import "core-js/modules/es.promise";
import "core-js/modules/es.array.from";

var p = Promise.resolve();
var arr = Array.from([1, 2, 3]);
```

### Core-js Integration

Core-js provides comprehensive polyfills:

```javascript
// Import all polyfills
import 'core-js';

// Import specific features
import 'core-js/features/promise';
import 'core-js/features/array/from';
import 'core-js/features/object/assign';

// Import stable features only
import 'core-js/stable';

// Import by proposal stage
import 'core-js/stage/4';
```

### Polyfill Gotchas

#### Impossible to Polyfill Perfectly

Some features cannot be fully polyfilled:

```javascript
// Proxy — no polyfill possible
// WeakMap / WeakSet — limited polyfills (risk of memory leaks)
// Private fields (#field) — syntax-level feature
// Async / await — requires transpilation

// Proxies require native support
if (typeof Proxy === 'undefined') {
    // Cannot create true proxy behavior
    // Best effort: limited traps only
}
````

#### Performance Traps

```javascript
// Object.observe (deprecated) - used polling
// MutationObserver polyfill - uses polling (slow)
// Intersection Observer polyfill - uses polling

// These polyfills have significant performance costs
// [Inference] - Native implementations use browser internals
// for better performance than JavaScript polling can achieve
````

#### Spec Evolution

```javascript
// Early polyfills may differ from final spec
// Example: Promise.prototype.finally changed during standardization

// Always use well-maintained polyfills from:
// - core-js
// - MDN polyfills
// - polyfill.io
// - Official proposals (when stable)
```

---

