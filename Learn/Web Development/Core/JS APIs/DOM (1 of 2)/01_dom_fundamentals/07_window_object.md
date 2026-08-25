## Window Object


### Core Properties and Identity

The `window` object represents the browser's window and serves as the global object in client-side JavaScript. All global variables, functions, and objects automatically become properties of `window`. The object implements the `Window` interface and provides access to the document, browser history, location, and various APIs.

`window.self`, `window.window`, and `window.frames` all reference the window itself. The `window.top` property references the topmost window in the hierarchy, while `window.parent` references the immediate parent frame. In a top-level browsing context, `window.top === window.self`.

### Dimensions and Viewport

`window.innerWidth` and `window.innerHeight` return the viewport dimensions in pixels, including scrollbars. These values update on resize and reflect the actual content area available for rendering.

`window.outerWidth` and `window.outerHeight` represent the entire browser window dimensions, including toolbars, borders, and browser chrome.

`window.screen` provides access to the `Screen` object with properties like `screen.width`, `screen.height`, `screen.availWidth`, `screen.availHeight`, `screen.colorDepth`, and `screen.pixelDepth`. The `avail` properties exclude taskbars and system UI elements.

`window.devicePixelRatio` returns the ratio between physical pixels and CSS pixels, crucial for high-DPI displays. A value of 2 means one CSS pixel equals four physical pixels (2×2).

`window.scrollX` (alias `pageXOffset`) and `window.scrollY` (alias `pageYOffset`) return the current scroll position in pixels. These are read-only; use `window.scrollTo()`, `window.scrollBy()`, or `window.scroll()` to programmatically scroll.

### Navigation and Location

`window.location` is a `Location` object providing URL manipulation:

- `location.href` - full URL (readable/writable)
- `location.protocol` - scheme (e.g., "https:")
- `location.host` - hostname with port
- `location.hostname` - hostname without port
- `location.port` - port number
- `location.pathname` - path portion
- `location.search` - query string including "?"
- `location.hash` - fragment identifier including "#"
- `location.origin` - protocol + host (read-only)

Methods include `location.assign(url)`, `location.replace(url)` (no history entry), `location.reload(forceReload)`, and `location.toString()`.

`window.history` provides access to the session history stack through the `History` interface:

- `history.length` - number of entries
- `history.state` - current state object
- `history.back()`, `history.forward()`, `history.go(delta)`
- `history.pushState(state, title, url)` - adds entry without navigation
- `history.replaceState(state, title, url)` - modifies current entry

The `popstate` event fires when active history entry changes via user navigation (not `pushState`/`replaceState`).

### Document and Frames

`window.document` references the DOM `Document` object. This is the primary interface for DOM manipulation and is equivalent to the global `document` variable.

`window.frames` returns a pseudo-array of frame/iframe windows. Access via index (`window.frames[0]`) or name (`window.frames['frameName']`). `window.length` returns the frame count.

`window.frameElement` returns the element (iframe/object) embedding the window, or `null` for top-level contexts. Cross-origin access restrictions apply.

`window.opener` references the window that opened the current window via `window.open()`. Returns `null` if no opener or if explicitly cleared for security (`window.opener = null`).

### Timers and Scheduling

`window.setTimeout(callback, delay, ...args)` executes callback once after delay in milliseconds. Returns a timeout ID for cancellation with `clearTimeout(id)`. Minimum delay is typically 4ms for nested timeouts after the fifth level.

`window.setInterval(callback, delay, ...args)` executes callback repeatedly at specified intervals. Returns an interval ID for `clearInterval(id)`. Actual execution timing may drift due to event loop congestion.

`window.requestAnimationFrame(callback)` schedules callback before next repaint, providing the timestamp as an argument. Returns a request ID for `cancelAnimationFrame(id)`. Preferred for animations as it synchronizes with display refresh rate (typically 60Hz) and pauses when tab is hidden.

`window.requestIdleCallback(callback, options)` schedules callback during idle periods. The callback receives an `IdleDeadline` object with `timeRemaining()` method and `didTimeout` property. Cancel with `cancelIdleCallback(id)`.

### Dialog Methods

`window.alert(message)` displays a modal alert dialog blocking execution until dismissed.

`window.confirm(message)` shows a modal dialog with OK/Cancel buttons, returning boolean based on user choice.

`window.prompt(message, default)` displays input dialog returning entered string or `null` if cancelled.

`window.print()` opens the print dialog for the current document.

These methods are synchronous and block the main thread. Modern applications typically implement custom modal interfaces.

### Window Management

`window.open(url, target, features)` opens a new browsing context. The `target` parameter specifies where (`_blank`, `_self`, `_parent`, `_top`, or named window). The `features` parameter is a comma-separated string of window features (e.g., `"width=500,height=400,resizable=yes"`).

Returns a `WindowProxy` reference or `null` if blocked. Popup blockers typically prevent `window.open()` calls not directly triggered by user interaction.

`window.close()` closes the window if opened via script. Can only close windows opened by `window.open()` from the same origin.

`window.focus()` attempts to bring window to front and give it focus. `window.blur()` removes focus. Browsers restrict these for security and usability.

`window.moveTo(x, y)` and `window.moveBy(deltaX, deltaY)` reposition the window. `window.resizeTo(width, height)` and `window.resizeBy(deltaWidth, deltaHeight)` change dimensions. These methods are heavily restricted in modern browsers and typically only work on windows opened by script.

### Events and Event Handling

The window fires numerous events:

- `load` - fires when entire page including resources loads
- `DOMContentLoaded` - fires when DOM parsing completes (fires on document, not window)
- `beforeunload` - fires before unload, allows cancellation (return value or `event.returnValue`)
- `unload` - fires during unload
- `resize` - fires when window resizes
- `scroll` - fires when document scrolls
- `focus` / `blur` - fires when window gains/loses focus
- `hashchange` - fires when URL fragment changes
- `popstate` - fires on history navigation
- `online` / `offline` - fires when network connectivity changes
- `error` - fires for uncaught errors (provides error details)
- `unhandledrejection` - fires for unhandled promise rejections

Event listeners attach via `window.addEventListener(type, listener, options)` or legacy `window.on<event>` properties.

### Storage APIs

`window.localStorage` provides persistent key-value storage (typically 5-10MB limit) that survives browser restarts. Data is origin-specific and synchronous.

`window.sessionStorage` provides session-scoped storage that clears when tab/window closes. Otherwise identical API to localStorage.

Both implement the `Storage` interface:

- `setItem(key, value)` - stores value as string
- `getItem(key)` - retrieves value or null
- `removeItem(key)` - deletes entry
- `clear()` - removes all entries
- `key(index)` - returns key at index
- `length` - number of stored items

The `storage` event fires on other windows when storage changes, providing `key`, `oldValue`, `newValue`, `url`, and `storageArea` properties.

`window.indexedDB` provides access to the IndexedDB API for structured data storage with much larger capacity and asynchronous operations.

### Console and Debugging

`window.console` provides the Console API for debugging output:

- `console.log()`, `console.info()`, `console.warn()`, `console.error()` - output messages
- `console.table()` - displays tabular data
- `console.group()` / `console.groupEnd()` - creates collapsible groups
- `console.time()` / `console.timeEnd()` - measures execution time
- `console.trace()` - outputs stack trace
- `console.assert()` - conditional error output
- `console.clear()` - clears console

### Performance and Timing

`window.performance` provides the Performance API with timing and metrics:

- `performance.now()` - high-resolution timestamp (microsecond precision)
- `performance.timing` - navigation timing data (deprecated, use PerformanceNavigationTiming)
- `performance.navigation` - navigation type data (deprecated)
- `performance.getEntries()` - returns performance entries
- `performance.mark()` / `performance.measure()` - custom performance marks

`performance.now()` returns time elapsed since `timeOrigin` and is monotonically increasing, unaffected by system clock adjustments.

### Navigator and Environment

`window.navigator` provides information about the browser and environment:

- `navigator.userAgent` - user agent string
- `navigator.platform` - operating system
- `navigator.language` / `navigator.languages` - preferred languages
- `navigator.onLine` - network connectivity status
- `navigator.cookieEnabled` - cookie support
- `navigator.maxTouchPoints` - touch input support
- `navigator.hardwareConcurrency` - logical processor count
- `navigator.geolocation` - Geolocation API access
- `navigator.mediaDevices` - MediaDevices API access
- `navigator.serviceWorker` - ServiceWorker API access
- `navigator.clipboard` - Clipboard API access

### Encoding and Decoding

`window.atob(encodedData)` decodes Base64-encoded string to binary string.

`window.btoa(stringToEncode)` encodes binary string to Base64.

`window.encodeURI(uri)` encodes URI, preserving special URI characters.

`window.encodeURIComponent(component)` encodes URI component, encoding all special characters except `- _ . ! ~ * ' ( )`.

`window.decodeURI(encodedURI)` and `window.decodeURIComponent(encodedComponent)` perform reverse operations.

These functions work with Unicode strings; use TextEncoder/TextDecoder for proper UTF-8 handling with atob/btoa.

### Selection and Clipboard

`window.getSelection()` returns a `Selection` object representing user's text selection or caret position. Provides methods like `toString()`, `getRangeAt()`, `addRange()`, `removeAllRanges()`, `collapse()`, and `extend()`.

`window.getComputedStyle(element, pseudoElement)` returns `CSSStyleDeclaration` with computed styles for the element, reflecting actual rendered values after CSS cascade and inheritance.

### Messaging and Communication

`window.postMessage(message, targetOrigin, transfer)` enables safe cross-origin communication. Messages fire the `message` event on the receiving window with properties:

- `data` - the message payload
- `origin` - sender's origin
- `source` - reference to sender window
- `ports` - MessagePort array for channel messaging

Always validate `event.origin` before processing messages. The `targetOrigin` parameter specifies allowed receiver origin ("*" allows any, but is insecure).

### Observers and Mutations

`window.MutationObserver` constructor creates observers for DOM mutations. Configure with options like `childList`, `attributes`, `characterData`, `subtree`, `attributeOldValue`, and `attributeFilter`.

`window.ResizeObserver` constructor creates observers for element size changes. More efficient than polling with resize events.

`window.IntersectionObserver` constructor creates observers for element visibility changes relative to viewport or ancestor elements. Provides intersection ratios and bounding rectangles.

`window.PerformanceObserver` constructor creates observers for performance entries as they're recorded.

### Fetch and Network

`window.fetch(resource, options)` performs HTTP requests returning a Promise resolving to Response object. Modern replacement for XMLHttpRequest with cleaner API and Promise-based interface.

`window.WebSocket` constructor creates WebSocket connections for full-duplex communication. Events include `open`, `message`, `error`, and `close`.

### Custom Elements and Web Components

`window.customElements` provides the CustomElementRegistry for defining custom HTML elements:

- `define(name, constructor, options)` - registers custom element
- `get(name)` - retrieves constructor
- `whenDefined(name)` - returns Promise resolving when defined
- `upgrade(root)` - upgrades custom elements in tree

### Crypto and Security

`window.crypto` provides cryptographic functionality:

- `crypto.getRandomValues(typedArray)` - generates cryptographically strong random values
- `crypto.randomUUID()` - generates RFC 4122 UUID
- `crypto.subtle` - SubtleCrypto interface for advanced operations (encrypt, decrypt, sign, verify, digest, etc.)

### Animation and Visual Updates

`window.matchMedia(mediaQueryString)` returns `MediaQueryList` object for evaluating and monitoring media queries. Listen for changes via the `change` event or deprecated `addListener()` method.

### Global Constructors and Objects

The window object exposes all standard JavaScript constructors and objects as properties: `Object`, `Array`, `String`, `Number`, `Boolean`, `Function`, `Date`, `RegExp`, `Error`, `Promise`, `Map`, `Set`, `WeakMap`, `WeakSet`, `Symbol`, `Proxy`, `Reflect`, etc.

Web API constructors are also available: `XMLHttpRequest`, `WebSocket`, `Worker`, `SharedWorker`, `MessageChannel`, `Blob`, `File`, `FileReader`, `FormData`, `URL`, `URLSearchParams`, `Headers`, `Request`, `Response`, `ReadableStream`, `WritableStream`, `TextEncoder`, `TextDecoder`, `AbortController`, `AbortSignal`, and many others.

### Cross-Origin Restrictions

[Inference] Cross-origin access to window properties is restricted by the Same-Origin Policy. Cross-origin windows can only access a limited set of properties (`window.closed`, `window.location` write-only, `window.postMessage`) and methods. Attempts to access restricted properties throw SecurityError exceptions.

The `document.domain` property can be set to enable cross-origin access between subdomains of the same parent domain, though this approach is deprecated. CORS (Cross-Origin Resource Sharing) and postMessage provide modern alternatives.

### Deprecated and Legacy Features

`window.showModalDialog()` is obsolete and removed from modern browsers. Use custom modal implementations with dialog elements or libraries.

`window.captureEvents()` and `window.releaseEvents()` are legacy Netscape methods no longer functional.

`window.name` is a writable property that persists across navigations within the same window, historically used for cross-page communication before modern storage APIs.

`window.status` for setting status bar text is no longer functional in modern browsers due to security and usability concerns.

### Structured Cloning

The structured clone algorithm is used by several APIs (postMessage, MessageChannel, History API, IndexedDB) to serialize/deserialize complex objects including nested objects, Arrays, Dates, RegExps, Maps, Sets, typed arrays, and more. It cannot clone functions, DOM nodes, or objects with non-enumerable properties.

`window.structuredClone(value, options)` provides direct access to this algorithm for deep cloning objects.

---

