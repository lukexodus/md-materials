## Safe Event Handling


### Race Conditions in Event Handlers

Race conditions occur when multiple event handlers access shared state simultaneously without proper coordination. The execution order becomes non-deterministic, leading to inconsistent state updates.

**Critical scenarios:**

- Rapid successive clicks triggering multiple async operations
- Concurrent form submissions before validation completes
- Multiple handlers modifying the same DOM element
- Parallel state updates in frameworks like React

**Mitigation strategies:**

- Disable interactive elements during async operations
- Implement debouncing/throttling for high-frequency events
- Use atomic state updates or transaction-like patterns
- Employ locks or semaphores for critical sections
- Leverage framework-specific state management (Redux, Zustand) with serialized updates

### Memory Leaks from Event Listeners

Unremoved event listeners prevent garbage collection of associated objects, causing memory accumulation over time.

**Common leak patterns:**

```javascript
// Leaked reference
element.addEventListener('click', () => {
  heavyObject.process(); // heavyObject cannot be GC'd
});

// Anonymous function cannot be removed
button.addEventListener('click', function() { });
// Later: button.removeEventListener('click', ???); // No reference
```

**Prevention techniques:**

- Store handler references for explicit removal
- Use `AbortController` for automatic cleanup
- Implement cleanup in component unmount/destroy hooks
- Prefer weak references where appropriate
- Use event delegation to minimize listener count

### Event Delegation Security

Event delegation attaches listeners to parent elements, but introduces security considerations:

**Risks:**

- **Event hijacking**: Malicious child elements triggering unintended handlers
- **XSS vulnerabilities**: Injected elements capturing sensitive events
- **Click-jacking**: Transparent overlays intercepting legitimate interactions

**Safeguards:**

- Validate `event.target` against expected elements
- Use strict selector matching in delegated handlers
- Implement Content Security Policy (CSP)
- Sanitize dynamic content before insertion
- Check `event.isTrusted` to filter synthetic events

### Input Validation and Sanitization

Event handlers receiving user input must validate and sanitize to prevent injection attacks and data corruption.

**Validation layers:**

1. **Client-side validation**: Immediate feedback, not security boundary
2. **Event handler validation**: Type checking, range validation
3. **Server-side validation**: Authoritative security layer

**Sanitization approaches:**

- Escape HTML entities before DOM insertion
- Use `textContent` instead of `innerHTML` when possible
- Validate input format (regex, schema validation)
- Implement allowlists over blocklists
- Encode data appropriate to context (HTML, URL, JavaScript)

### Preventing Event Handler Injection

Dynamic event handler creation from untrusted sources enables arbitrary code execution.

**Vulnerable patterns:**

```javascript
// DANGEROUS: eval-like behavior
element.setAttribute('onclick', userInput);
element.onclick = new Function(userInput);
```

**Safe alternatives:**

- Never construct handlers from user input
- Use data attributes with predefined handler mapping
- Implement command pattern with validated action names
- Employ CSP `unsafe-inline` restrictions
- Use framework templating with automatic escaping

### Error Boundary Implementation

Uncaught errors in event handlers can crash applications or expose sensitive information.

**Error handling strategies:**

**Synchronous handlers:**

```javascript
element.addEventListener('click', (e) => {
  try {
    riskyOperation();
  } catch (error) {
    logError(error);
    displayUserFriendlyMessage();
    // Prevent default if appropriate
  }
});
```

**Async handlers:**

```javascript
element.addEventListener('click', async (e) => {
  try {
    await asyncOperation();
  } catch (error) {
    // Handle rejection
  }
});
```

**Global safety nets:**

- `window.addEventListener('error')` for uncaught exceptions
- `window.addEventListener('unhandledrejection')` for unhandled promises
- Framework-level error boundaries (React, Vue)
- Centralized error logging and monitoring

### Throttling and Debouncing

High-frequency events (scroll, resize, mousemove) can overwhelm handlers, causing performance degradation.

**Throttling**: Executes handler at most once per time interval

```javascript
function throttle(func, delay) {
  let lastCall = 0;
  return function(...args) {
    const now = Date.now();
    if (now - lastCall >= delay) {
      lastCall = now;
      func.apply(this, args);
    }
  };
}
```

**Debouncing**: Delays execution until events stop for specified duration

```javascript
function debounce(func, delay) {
  let timeoutId;
  return function(...args) {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => func.apply(this, args), delay);
  };
}
```

**Selection criteria:**

- Throttle: Animation frames, progress tracking, analytics
- Debounce: Search autocomplete, form validation, window resize

### Event Capture vs Bubbling

Understanding event propagation prevents unintended handler execution and enables strategic listener placement.

**Phases:**

1. **Capture phase**: Event travels from window to target (top-down)
2. **Target phase**: Event reaches target element
3. **Bubble phase**: Event travels from target to window (bottom-up)

**Capture phase usage:**

```javascript
element.addEventListener('click', handler, { capture: true });
```

**Strategic applications:**

- Capture: Early intervention, global monitoring, security checks
- Bubble: Default behavior, event delegation, component encapsulation

**stopPropagation considerations:**

- Prevents further propagation in current phase
- May break event delegation patterns
- Can hide events from analytics or monitoring
- Use `stopImmediatePropagation()` to prevent same-element handlers

### Passive Event Listeners

Passive listeners improve scroll performance by preventing `preventDefault()` calls.

```javascript
element.addEventListener('touchstart', handler, { passive: true });
```

**Benefits:**

- Browser can optimize scrolling without waiting for handler
- Eliminates scroll jank on touch devices
- Automatic in modern browsers for `touchstart`, `touchmove`

**Limitations:**

- Cannot call `preventDefault()`
- Console warnings if attempted
- Not suitable for handlers requiring default prevention

### Custom Event Security

Custom events enable component communication but require validation to prevent abuse.

**Secure custom event pattern:**

```javascript
// Dispatch with validation
const validTypes = ['userAction', 'dataUpdate'];
function dispatchSecureEvent(type, detail) {
  if (!validTypes.includes(type)) {
    throw new Error('Invalid event type');
  }
  // Sanitize detail object
  const sanitized = sanitizeEventDetail(detail);
  element.dispatchEvent(new CustomEvent(type, { 
    detail: sanitized,
    bubbles: false, // Limit scope
    composed: false
  }));
}

// Listen with validation
element.addEventListener('userAction', (e) => {
  if (!e.isTrusted) return; // [Inference] May filter legitimate programmatic events
  validateEventDetail(e.detail);
  handleAction(e.detail);
});
```

### Once Option for Single-Use Handlers

The `once` option automatically removes listeners after first execution, preventing memory leaks and redundant processing.

```javascript
element.addEventListener('click', handler, { once: true });
```

**Use cases:**

- Initialization events
- One-time user interactions (splash screens, tutorials)
- Resource loading callbacks
- Modal dismiss handlers

### Signal-Based Cleanup

`AbortController` provides centralized cleanup for multiple event listeners.

```javascript
const controller = new AbortController();
const signal = controller.signal;

element1.addEventListener('click', handler1, { signal });
element2.addEventListener('mouseover', handler2, { signal });
document.addEventListener('keydown', handler3, { signal });

// Remove all listeners at once
controller.abort();
```

**Advantages:**

- Single cleanup call for multiple listeners
- Integration with fetch API and other abortable operations
- Prevents cleanup logic duplication
- Framework-agnostic pattern

### Trusted Events vs Synthetic Events

Browsers mark user-initiated events as trusted (`isTrusted: true`). Programmatically created events have `isTrusted: false`.

**Security implications:**

```javascript
element.addEventListener('click', (e) => {
  if (!e.isTrusted) {
    console.warn('Synthetic event detected');
    return; // Reject automated clicks
  }
  performSensitiveAction();
});
```

**Scenarios requiring trust validation:**

- Payment processing
- Account deletion
- Permission grants
- Security-sensitive state changes

**[Inference]** Some legitimate automation tools may trigger non-trusted events, potentially blocking valid use cases.

### Event Handler Context Binding

Incorrect `this` binding causes runtime errors or unintended behavior in event handlers.

**Context preservation methods:**

**Arrow functions:**

```javascript
class Component {
  constructor() {
    this.state = {};
    // Arrow function preserves this
    element.addEventListener('click', (e) => this.handleClick(e));
  }
}
```

**Explicit binding:**

```javascript
class Component {
  constructor() {
    this.handleClick = this.handleClick.bind(this);
    element.addEventListener('click', this.handleClick);
  }
}
```

**Removal requirements:**

- Store bound function reference for `removeEventListener`
- Arrow functions in constructor create new instances
- Class properties with arrow functions maintain instance reference

### Preventing Default Behavior Safely

`preventDefault()` blocks browser default actions, but misuse causes accessibility and UX issues.

**Safe usage guidelines:**

- Only prevent when replacing default with equivalent functionality
- Preserve keyboard navigation (Tab, Enter, Space, Arrows)
- Maintain focus management
- Provide visual feedback for prevented actions
- Document why default is prevented

**Common pitfalls:**

```javascript
// PROBLEMATIC: Breaks form submission
form.addEventListener('submit', (e) => {
  e.preventDefault();
  // If validation/handling fails, form is stuck
});

// BETTER: Conditional prevention
form.addEventListener('submit', (e) => {
  if (!validate(form)) {
    e.preventDefault();
    showErrors();
  }
  // Allow default submission if valid
});
```

### Async Event Handler Pitfalls

Async handlers introduce timing issues and error handling complexity.

**Problems:**

- Errors become unhandled rejections
- Multiple invocations before completion
- State changes during await periods
- Resource cleanup timing

**Safe async handler pattern:**

```javascript
let processing = false;

element.addEventListener('click', async (e) => {
  if (processing) return; // Prevent concurrent execution
  processing = true;
  
  try {
    e.target.disabled = true; // UI feedback
    await performAsyncOperation();
  } catch (error) {
    handleError(error);
  } finally {
    e.target.disabled = false;
    processing = false;
  }
});
```

### Event Timing Attacks

Malicious actors can infer sensitive information through event timing analysis.

**Vulnerability vectors:**

- Keystroke timing revealing passwords
- Network timing leaking data presence
- Computation time exposing cryptographic keys
- Animation timing indicating internal state

**Mitigation techniques:**

- Add random delays to timing-sensitive operations [Inference]
- Batch operations to obscure individual timings
- Use constant-time algorithms for sensitive comparisons
- Implement rate limiting on event handlers
- Monitor for unusual timing patterns

**[Unverified]** The effectiveness of timing obfuscation varies based on attacker capabilities and implementation details.

### Cross-Frame Event Security

Events crossing frame boundaries introduce security risks with `postMessage` and cross-origin contexts.

**Secure postMessage pattern:**

```javascript
// Sender
targetWindow.postMessage(data, 'https://trusted-origin.com');

// Receiver
window.addEventListener('message', (e) => {
  // Validate origin
  if (e.origin !== 'https://trusted-origin.com') {
    return;
  }
  
  // Validate message structure
  if (!isValidMessageFormat(e.data)) {
    return;
  }
  
  // Validate source
  if (e.source !== expectedWindow) {
    return;
  }
  
  processMessage(e.data);
});
```

**Security requirements:**

- Always validate `event.origin`
- Never use wildcard origin (`*`) for sensitive data
- Validate message structure and content
- Implement message signature/authentication for critical operations
- Use structured clone algorithm awareness for data types

### Framework-Specific Patterns

Modern frameworks provide safety mechanisms for event handling.

**React:**

- Synthetic event system normalizes browser differences
- Automatic event delegation to root
- Cleanup on component unmount
- `useEffect` cleanup functions for manual listeners

**Vue:**

- `@click.prevent` and `@click.stop` modifiers
- `v-on` directive automatic cleanup
- Event modifiers for common patterns (`.once`, `.capture`)

**Angular:**

- Template event binding with automatic unsubscription
- `HostListener` decorator for component events
- `Renderer2` for safe DOM manipulation

**[Inference]** Framework abstractions may introduce performance overhead compared to native event handling, but improve safety and maintainability in most applications.

---

