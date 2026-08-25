## Debouncing and Throttling


### Core Mechanisms

**Debouncing** delays function execution until after a specified time period has elapsed since the last invocation attempt. Each new call resets the timer. The function executes only when the event stream stops for the designated duration.

**Throttling** limits function execution to once per specified time interval. Once executed, subsequent calls are ignored until the interval expires, regardless of how many times the event fires.

### Implementation Patterns

#### Debounce Implementation

```javascript
function debounce(func, delay) {
  let timeoutId;
  
  return function(...args) {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => {
      func.apply(this, args);
    }, delay);
  };
}
```

The closure preserves the timeout ID across invocations. Each call clears the previous timer before setting a new one. The `apply` method preserves the correct `this` context and passes through all arguments.

#### Throttle Implementation

```javascript
function throttle(func, interval) {
  let lastCall = 0;
  
  return function(...args) {
    const now = Date.now();
    if (now - lastCall >= interval) {
      lastCall = now;
      func.apply(this, args);
    }
  };
}
```

This timestamp-based approach tracks the last execution time. The function only executes when sufficient time has elapsed since the previous call.

#### Alternative Throttle with Leading/Trailing Options

```javascript
function throttle(func, interval, options = {}) {
  let timeoutId;
  let lastCall = 0;
  const { leading = true, trailing = true } = options;
  
  return function(...args) {
    const now = Date.now();
    const timeSinceLastCall = now - lastCall;
    
    if (!lastCall && !leading) {
      lastCall = now;
    }
    
    if (timeSinceLastCall >= interval) {
      if (timeoutId) {
        clearTimeout(timeoutId);
        timeoutId = null;
      }
      lastCall = now;
      func.apply(this, args);
    } else if (!timeoutId && trailing) {
      timeoutId = setTimeout(() => {
        lastCall = leading ? Date.now() : 0;
        timeoutId = null;
        func.apply(this, args);
      }, interval - timeSinceLastCall);
    }
  };
}
```

### Execution Timing Characteristics

#### Debounce Timing

- **Delay initiation**: Timer starts on first event
- **Delay reset**: Each subsequent event resets the timer completely
- **Execution point**: Only after silence period completes
- **Rapid events**: Zero executions until events stop

For a 300ms debounce with events at 0ms, 100ms, 200ms, 250ms, then stopping:

- Timer resets at each event
- Execution occurs at 550ms (250ms + 300ms delay)
- Total executions: 1

#### Throttle Timing

- **First call**: Executes immediately (with leading edge)
- **Subsequent calls**: Blocked until interval expires
- **Execution frequency**: Maximum of once per interval
- **Continuous events**: Regular executions at interval boundaries

For 300ms throttle with continuous events every 50ms:

- Executions at 0ms, 300ms, 600ms, 900ms...
- Events between executions are discarded
- Maintains consistent execution rate

### Use Case Selection

#### When to Use Debouncing

**Search input autocomplete**: Wait for user to finish typing before querying API. Prevents excessive requests while user is actively typing.

**Window resize handlers**: Execute layout recalculations only after resizing completes. Avoids expensive DOM operations during the resize drag.

**Form validation**: Validate input after user pauses typing. Provides feedback without interrupting typing flow.

**Text editor autosave**: Save content after user stops editing. Prevents saving on every keystroke.

#### When to Use Throttling

**Scroll event handlers**: Process scroll position at regular intervals. Maintains responsiveness while limiting computation frequency.

**Mouse move tracking**: Sample mouse position periodically. Prevents overwhelming event processing for high-frequency mouse events.

**API rate limiting**: Ensure requests don't exceed service quotas. Enforces maximum request frequency.

**Game loop updates**: Maintain consistent frame rate. Executes game logic at fixed intervals regardless of event frequency.

**Progress indicators**: Update UI at human-perceivable intervals. Prevents excessive repaints while maintaining smooth appearance.

### Edge Cases and Considerations

#### Context Preservation

Both patterns must preserve function context (`this`) and arguments. Using arrow functions in the implementation would break method binding:

```javascript
// Incorrect - loses this context
const debounced = debounce(() => this.method(), 300);

// Correct - preserves this context
const debounced = debounce(function() { this.method(); }, 300);
```

#### Memory Leaks

Debounced/throttled functions hold references to timers and closures. For frequently created instances (like in React components), cleanup is essential:

```javascript
const debouncedFn = debounce(handler, 300);

// Later, when component unmounts or function is no longer needed
if (debouncedFn.cancel) {
  debouncedFn.cancel();
}
```

#### Leading vs Trailing Edge

**Leading edge execution**: Function runs immediately on first call, then blocks subsequent calls.

**Trailing edge execution**: Function runs after the quiet period (debounce) or at interval end (throttle).

Some implementations support both simultaneously, executing once at the start and once at the end of the event burst.

#### Immediate Invocation Option

Debounce variants may include an `immediate` parameter:

```javascript
function debounce(func, delay, immediate = false) {
  let timeoutId;
  
  return function(...args) {
    const callNow = immediate && !timeoutId;
    
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => {
      timeoutId = null;
      if (!immediate) {
        func.apply(this, args);
      }
    }, delay);
    
    if (callNow) {
      func.apply(this, args);
    }
  };
}
```

This executes immediately on the leading edge, then enforces the delay before allowing another execution.

### Performance Impact

#### Computational Overhead

Both techniques add minimal overhead:

- Timer management: O(1) operations
- Closure creation: One-time cost per wrapped function
- Memory: Single timeout ID and timestamp storage

The performance benefit comes from reducing expensive operations (DOM manipulation, API calls, complex calculations) rather than the wrapper itself.

#### Event Queue Implications

Debouncing and throttling don't remove events from the browser's event queue. They only control when the handler executes. The original events still fire and occupy the event loop briefly before being discarded.

For extremely high-frequency events (thousands per second), consider passive event listeners or `requestAnimationFrame` instead of or in addition to throttling.

### Library Implementations

#### Lodash

```javascript
import { debounce, throttle } from 'lodash';

const debouncedFn = debounce(handler, 300, {
  leading: false,
  trailing: true,
  maxWait: 1000
});

const throttledFn = throttle(handler, 300, {
  leading: true,
  trailing: true
});

// Both provide cancel method
debouncedFn.cancel();
throttledFn.cancel();
```

Lodash's `debounce` includes a `maxWait` option, which combines debouncing with throttling—the function must execute if the maximum wait time is reached, even if events keep arriving.

#### RxJS

```javascript
import { fromEvent } from 'rxjs';
import { debounceTime, throttleTime } from 'rxjs/operators';

fromEvent(input, 'input')
  .pipe(debounceTime(300))
  .subscribe(handler);

fromEvent(window, 'scroll')
  .pipe(throttleTime(300, { leading: true, trailing: true }))
  .subscribe(handler);
```

RxJS treats debouncing and throttling as stream operators, integrating them into the reactive programming paradigm.

### RequestAnimationFrame Alternative

For visual updates synchronized with browser repaints, `requestAnimationFrame` provides superior timing:

```javascript
function rafThrottle(func) {
  let rafId = null;
  
  return function(...args) {
    if (rafId === null) {
      rafId = requestAnimationFrame(() => {
        func.apply(this, args);
        rafId = null;
      });
    }
  };
}
```

This executes at most once per frame (typically 60fps), aligning with the browser's rendering cycle. It's optimal for scroll handlers, animations, and visual updates.

### Testing Considerations

Testing debounced and throttled functions requires time manipulation:

```javascript
// Using Jest fake timers
jest.useFakeTimers();

const mockFn = jest.fn();
const debounced = debounce(mockFn, 300);

debounced();
debounced();
debounced();

jest.advanceTimersByTime(299);
expect(mockFn).not.toHaveBeenCalled();

jest.advanceTimersByTime(1);
expect(mockFn).toHaveBeenCalledTimes(1);
```

Real-time testing is unreliable due to JavaScript's single-threaded nature and timer resolution limitations.

### Common Pitfalls

**Creating new instances on each render**: In React, debounced functions created during render lose their timing state:

```javascript
// Wrong - creates new debounced function each render
function Component() {
  const handler = debounce(handleInput, 300);
  return <input onChange={handler} />;
}

// Correct - preserves debounced function across renders
function Component() {
  const handler = useMemo(() => debounce(handleInput, 300), []);
  return <input onChange={handler} />;
}
```

**Forgetting to cancel**: Unmounted components or removed event listeners should cancel pending executions to prevent updates on unmounted components.

**Incorrect delay values**:

- Too short (< 100ms): May not provide meaningful performance benefit
- Too long (> 1000ms): Creates noticeable lag in user experience
- Optimal range typically 150-500ms depending on use case

---

