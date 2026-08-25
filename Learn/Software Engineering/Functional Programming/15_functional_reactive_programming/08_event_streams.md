## Event Streams


Event streams represent sequences of events occurring over time. In functional reactive programming, event streams are treated as first-class values that can be transformed, combined, and composed using functional operators.

### Creating Event Streams

**From DOM Events:**

```javascript
class EventStream {
  constructor(subscribe) {
    this.subscribe = subscribe;
  }
  
  static fromEvent(target, eventName) {
    return new EventStream((observer) => {
      const handler = (event) => observer.next(event);
      target.addEventListener(eventName, handler);
      
      return () => {
        target.removeEventListener(eventName, handler);
      };
    });
  }
  
  static fromInterval(interval) {
    return new EventStream((observer) => {
      let count = 0;
      const id = setInterval(() => {
        observer.next(count++);
      }, interval);
      
      return () => clearInterval(id);
    });
  }
  
  static fromPromise(promise) {
    return new EventStream((observer) => {
      promise
        .then(value => {
          observer.next(value);
          observer.complete();
        })
        .catch(err => observer.error(err));
      
      return () => {};
    });
  }
  
  static fromArray(array) {
    return new EventStream((observer) => {
      array.forEach(item => observer.next(item));
      observer.complete();
      return () => {};
    });
  }
}

// Usage
const clicks = EventStream.fromEvent(document, 'click');
const ticks = EventStream.fromInterval(1000);
```

**From Async Iterables:**

```javascript
EventStream.fromAsyncIterable = function(asyncIterable) {
  return new EventStream((observer) => {
    let cancelled = false;
    
    (async () => {
      try {
        for await (const value of asyncIterable) {
          if (cancelled) break;
          observer.next(value);
        }
        if (!cancelled) observer.complete();
      } catch (error) {
        if (!cancelled) observer.error(error);
      }
    })();
    
    return () => {
      cancelled = true;
    };
  });
};
```

### Stream Transformation Operators

**Map:**

```javascript
EventStream.prototype.map = function(fn) {
  return new EventStream((observer) => {
    return this.subscribe({
      next: (value) => observer.next(fn(value)),
      error: (err) => observer.error(err),
      complete: () => observer.complete()
    });
  });
};

// Usage
const positions = clicks.map(event => ({ x: event.clientX, y: event.clientY }));
```

**Filter:**

```javascript
EventStream.prototype.filter = function(predicate) {
  return new EventStream((observer) => {
    return this.subscribe({
      next: (value) => {
        if (predicate(value)) {
          observer.next(value);
        }
      },
      error: (err) => observer.error(err),
      complete: () => observer.complete()
    });
  });
};

// Usage
const rightClicks = clicks.filter(event => event.button === 2);
```

**Scan (Running Accumulation):**

```javascript
EventStream.prototype.scan = function(accumulator, seed) {
  return new EventStream((observer) => {
    let acc = seed;
    
    return this.subscribe({
      next: (value) => {
        acc = accumulator(acc, value);
        observer.next(acc);
      },
      error: (err) => observer.error(err),
      complete: () => observer.complete()
    });
  });
};

// Usage - click counter
const clickCount = clicks.scan((count, event) => count + 1, 0);
```

**Reduce (Single Final Value):**

```javascript
EventStream.prototype.reduce = function(accumulator, seed) {
  return new EventStream((observer) => {
    let acc = seed;
    
    return this.subscribe({
      next: (value) => {
        acc = accumulator(acc, value);
      },
      error: (err) => observer.error(err),
      complete: () => {
        observer.next(acc);
        observer.complete();
      }
    });
  });
};
```

**FlatMap (Merge Inner Streams):**

```javascript
EventStream.prototype.flatMap = function(fn) {
  return new EventStream((observer) => {
    const subscriptions = [];
    let completed = false;
    let activeInner = 0;
    
    const checkComplete = () => {
      if (completed && activeInner === 0) {
        observer.complete();
      }
    };
    
    const outerSubscription = this.subscribe({
      next: (value) => {
        activeInner++;
        const innerStream = fn(value);
        
        const innerSub = innerStream.subscribe({
          next: (innerValue) => observer.next(innerValue),
          error: (err) => observer.error(err),
          complete: () => {
            activeInner--;
            checkComplete();
          }
        });
        
        subscriptions.push(innerSub);
      },
      error: (err) => observer.error(err),
      complete: () => {
        completed = true;
        checkComplete();
      }
    });
    
    return () => {
      outerSubscription();
      subscriptions.forEach(sub => sub());
    };
  });
};

// Usage - search requests
const searchInput = EventStream.fromEvent(input, 'input');
const searchResults = searchInput
  .map(e => e.target.value)
  .flatMap(query => EventStream.fromPromise(fetch(`/search?q=${query}`)));
```

### Combining Streams

**Merge (Interleave Events):**

```javascript
EventStream.merge = function(...streams) {
  return new EventStream((observer) => {
    let completed = 0;
    const subscriptions = streams.map(stream => 
      stream.subscribe({
        next: (value) => observer.next(value),
        error: (err) => observer.error(err),
        complete: () => {
          completed++;
          if (completed === streams.length) {
            observer.complete();
          }
        }
      })
    );
    
    return () => subscriptions.forEach(sub => sub());
  });
};

// Usage
const allClicks = EventStream.merge(
  EventStream.fromEvent(button1, 'click'),
  EventStream.fromEvent(button2, 'click')
);
```

**Combine (Emit When Any Updates):**

```javascript
EventStream.combine = function(combiner, ...streams) {
  return new EventStream((observer) => {
    const values = new Array(streams.length);
    const hasValue = new Array(streams.length).fill(false);
    let completed = 0;
    
    const tryEmit = () => {
      if (hasValue.every(Boolean)) {
        observer.next(combiner(...values));
      }
    };
    
    const subscriptions = streams.map((stream, index) =>
      stream.subscribe({
        next: (value) => {
          values[index] = value;
          hasValue[index] = true;
          tryEmit();
        },
        error: (err) => observer.error(err),
        complete: () => {
          completed++;
          if (completed === streams.length) {
            observer.complete();
          }
        }
      })
    );
    
    return () => subscriptions.forEach(sub => sub());
  });
};

// Usage - combine mouse and keyboard
const state = EventStream.combine(
  (mouse, key) => ({ mouse, key }),
  mousePosition,
  keyPress
);
```

**Zip (Pair Corresponding Events):**

```javascript
EventStream.zip = function(...streams) {
  return new EventStream((observer) => {
    const buffers = streams.map(() => []);
    const completed = new Array(streams.length).fill(false);
    
    const tryEmit = () => {
      if (buffers.every(buf => buf.length > 0)) {
        const values = buffers.map(buf => buf.shift());
        observer.next(values);
        tryEmit(); // Check if more complete tuples
      } else if (completed.some((c, i) => c && buffers[i].length === 0)) {
        observer.complete();
      }
    };
    
    const subscriptions = streams.map((stream, index) =>
      stream.subscribe({
        next: (value) => {
          buffers[index].push(value);
          tryEmit();
        },
        error: (err) => observer.error(err),
        complete: () => {
          completed[index] = true;
          tryEmit();
        }
      })
    );
    
    return () => subscriptions.forEach(sub => sub());
  });
};

// Usage
const paired = EventStream.zip(
  EventStream.fromArray([1, 2, 3]),
  EventStream.fromArray(['a', 'b', 'c'])
);
// Emits: [1, 'a'], [2, 'b'], [3, 'c']
```

### Stream Control Operators

**Take (First N Events):**

```javascript
EventStream.prototype.take = function(n) {
  return new EventStream((observer) => {
    let count = 0;
    
    const subscription = this.subscribe({
      next: (value) => {
        if (count < n) {
          observer.next(value);
          count++;
          if (count === n) {
            observer.complete();
            subscription();
          }
        }
      },
      error: (err) => observer.error(err),
      complete: () => observer.complete()
    });
    
    return subscription;
  });
};

// Usage - first 5 clicks
const firstFive = clicks.take(5);
```

**Skip (Ignore First N Events):**

```javascript
EventStream.prototype.skip = function(n) {
  return new EventStream((observer) => {
    let count = 0;
    
    return this.subscribe({
      next: (value) => {
        if (count >= n) {
          observer.next(value);
        }
        count++;
      },
      error: (err) => observer.error(err),
      complete: () => observer.complete()
    });
  });
};
```

**TakeUntil (Stop at Signal):**

```javascript
EventStream.prototype.takeUntil = function(notifier) {
  return new EventStream((observer) => {
    let notifierFired = false;
    
    const notifierSub = notifier.subscribe({
      next: () => {
        notifierFired = true;
        observer.complete();
        sourceSub();
        notifierSub();
      }
    });
    
    const sourceSub = this.subscribe({
      next: (value) => {
        if (!notifierFired) {
          observer.next(value);
        }
      },
      error: (err) => observer.error(err),
      complete: () => {
        if (!notifierFired) {
          observer.complete();
          notifierSub();
        }
      }
    });
    
    return () => {
      sourceSub();
      notifierSub();
    };
  });
};

// Usage - drag until mouse up
const dragStream = mouseMove.takeUntil(mouseUp);
```

**Distinct (Remove Duplicates):**

```javascript
EventStream.prototype.distinct = function(keySelector = x => x) {
  return new EventStream((observer) => {
    const seen = new Set();
    
    return this.subscribe({
      next: (value) => {
        const key = keySelector(value);
        if (!seen.has(key)) {
          seen.add(key);
          observer.next(value);
        }
      },
      error: (err) => observer.error(err),
      complete: () => observer.complete()
    });
  });
};
```

**DistinctUntilChanged (Remove Consecutive Duplicates):**

```javascript
EventStream.prototype.distinctUntilChanged = function(comparator = (a, b) => a === b) {
  return new EventStream((observer) => {
    let hasLast = false;
    let last;
    
    return this.subscribe({
      next: (value) => {
        if (!hasLast || !comparator(value, last)) {
          hasLast = true;
          last = value;
          observer.next(value);
        }
      },
      error: (err) => observer.error(err),
      complete: () => observer.complete()
    });
  });
};
```

### Practical Event Stream Patterns

**Drag and Drop:**

```javascript
const mouseDown = EventStream.fromEvent(element, 'mousedown');
const mouseMove = EventStream.fromEvent(document, 'mousemove');
const mouseUp = EventStream.fromEvent(document, 'mouseup');

const drag = mouseDown.flatMap(startEvent => {
  const startX = startEvent.clientX;
  const startY = startEvent.clientY;
  
  return mouseMove
    .takeUntil(mouseUp)
    .map(moveEvent => ({
      dx: moveEvent.clientX - startX,
      dy: moveEvent.clientY - startY
    }));
});

drag.subscribe({
  next: ({ dx, dy }) => {
    element.style.transform = `translate(${dx}px, ${dy}px)`;
  }
});
```

**Autocomplete:**

```javascript
const input = EventStream.fromEvent(searchBox, 'input')
  .map(e => e.target.value)
  .distinctUntilChanged()
  .debounce(300) // Wait for typing pause
  .filter(query => query.length >= 3)
  .flatMap(query => 
    EventStream.fromPromise(
      fetch(`/autocomplete?q=${query}`)
        .then(r => r.json())
    )
  );

input.subscribe({
  next: (suggestions) => {
    displaySuggestions(suggestions);
  }
});
```

**Double Click Detection:**

```javascript
const doubleClick = clicks
  .scan((acc, event) => {
    const now = Date.now();
    return {
      count: now - acc.timestamp < 300 ? acc.count + 1 : 1,
      timestamp: now,
      event
    };
  }, { count: 0, timestamp: 0, event: null })
  .filter(state => state.count === 2)
  .map(state => state.event);

doubleClick.subscribe({
  next: (event) => console.log('Double clicked!', event)
});
```

**Key Points:**

- Event streams represent sequences of events over time as first-class values
- Streams can be created from DOM events, intervals, promises, and iterables
- Transformation operators (map, filter, scan) create derived streams
- Combination operators (merge, combine, zip) coordinate multiple streams
- Control operators (take, skip, takeUntil) manage stream lifecycle
- FlatMap enables handling of async operations within streams
- Streams compose naturally to express complex event-driven logic
- Subscription returns a cleanup function for resource management
- Operators are lazy - they only execute when subscribed
- Essential for building reactive user interfaces and real-time applications

