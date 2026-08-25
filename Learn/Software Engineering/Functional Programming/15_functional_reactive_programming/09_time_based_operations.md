## Time-Based Operations


Time-based operations in functional reactive programming deal with temporal aspects of event streams, including delaying, scheduling, windowing, and coordinating events based on time.

### Delay Operations

**Simple Delay:**

```javascript
EventStream.prototype.delay = function(ms) {
  return new EventStream((observer) => {
    return this.subscribe({
      next: (value) => {
        setTimeout(() => observer.next(value), ms);
      },
      error: (err) => observer.error(err),
      complete: () => {
        setTimeout(() => observer.complete(), ms);
      }
    });
  });
};

// Usage
const delayed = clicks.delay(1000); // Events appear 1s later
```

**Delay with Scheduler:**

```javascript
class Scheduler {
  schedule(action, delay = 0) {
    const id = setTimeout(action, delay);
    return () => clearTimeout(id);
  }
  
  scheduleInterval(action, period) {
    const id = setInterval(action, period);
    return () => clearInterval(id);
  }
  
  now() {
    return Date.now();
  }
}

EventStream.prototype.delayWithScheduler = function(ms, scheduler = new Scheduler()) {
  return new EventStream((observer) => {
    const cancellations = [];
    
    const subscription = this.subscribe({
      next: (value) => {
        const cancel = scheduler.schedule(() => {
          observer.next(value);
        }, ms);
        cancellations.push(cancel);
      },
      error: (err) => observer.error(err),
      complete: () => {
        const cancel = scheduler.schedule(() => {
          observer.complete();
        }, ms);
        cancellations.push(cancel);
      }
    });
    
    return () => {
      subscription();
      cancellations.forEach(cancel => cancel());
    };
  });
};
```

### Throttling and Debouncing

**Throttle (Leading Edge):**

```javascript
EventStream.prototype.throttle = function(ms) {
  return new EventStream((observer) => {
    let lastEmit = 0;
    
    return this.subscribe({
      next: (value) => {
        const now = Date.now();
        if (now - lastEmit >= ms) {
          lastEmit = now;
          observer.next(value);
        }
      },
      error: (err) => observer.error(err),
      complete: () => observer.complete()
    });
  });
};

// Usage - scroll events 
const throttledScroll = EventStream 
  .fromEvent(window, 'scroll')
  .throttle(100);
````

**Throttle Time (With Trailing):**
```javascript
EventStream.prototype.throttleTime = function(ms, { leading = true, trailing = false } = {}) {
  return new EventStream((observer) => {
    let lastEmit = 0;
    let trailingValue = null;
    let trailingTimeout = null;
    let hasTrailing = false;
    
    return this.subscribe({
      next: (value) => {
        const now = Date.now();
        const timeSinceLastEmit = now - lastEmit;
        
        if (timeSinceLastEmit >= ms) {
          if (leading) {
            lastEmit = now;
            observer.next(value);
            hasTrailing = false;
          }
        } else if (trailing) {
          hasTrailing = true;
          trailingValue = value;
          
          clearTimeout(trailingTimeout);
          trailingTimeout = setTimeout(() => {
            if (hasTrailing) {
              lastEmit = Date.now();
              observer.next(trailingValue);
              hasTrailing = false;
            }
          }, ms - timeSinceLastEmit);
        }
      },
      error: (err) => observer.error(err),
      complete: () => {
        clearTimeout(trailingTimeout);
        observer.complete();
      }
    });
  });
};
````

**Debounce (Wait for Silence):**

```javascript
EventStream.prototype.debounce = function(ms) {
  return new EventStream((observer) => {
    let timeoutId = null;
    
    return this.subscribe({
      next: (value) => {
        clearTimeout(timeoutId);
        timeoutId = setTimeout(() => {
          observer.next(value);
        }, ms);
      },
      error: (err) => {
        clearTimeout(timeoutId);
        observer.error(err);
      },
      complete: () => {
        clearTimeout(timeoutId);
        observer.complete();
      }
    });
  });
};

// Usage - search input
const searchQuery = EventStream
  .fromEvent(searchInput, 'input')
  .map(e => e.target.value)
  .debounce(300);
```

**Audit (Emit After Silence, Then Wait):**

```javascript
EventStream.prototype.audit = function(ms) {
  return new EventStream((observer) => {
    let timeoutId = null;
    let lastValue = null;
    let hasValue = false;
    
    return this.subscribe({
      next: (value) => {
        lastValue = value;
        hasValue = true;
        
        if (!timeoutId) {
          timeoutId = setTimeout(() => {
            if (hasValue) {
              observer.next(lastValue);
              hasValue = false;
            }
            timeoutId = null;
          }, ms);
        }
      },
      error: (err) => {
        clearTimeout(timeoutId);
        observer.error(err);
      },
      complete: () => {
        clearTimeout(timeoutId);
        if (hasValue) {
          observer.next(lastValue);
        }
        observer.complete();
      }
    });
  });
};
```

### Sampling and Buffering

**Sample (Take Latest at Intervals):**

```javascript
EventStream.prototype.sample = function(notifier) {
  return new EventStream((observer) => {
    let hasValue = false;
    let lastValue = null;
    
    const sourceSub = this.subscribe({
      next: (value) => {
        hasValue = true;
        lastValue = value;
      },
      error: (err) => observer.error(err),
      complete: () => {
        notifierSub();
        observer.complete();
      }
    });
    
    const notifierSub = notifier.subscribe({
      next: () => {
        if (hasValue) {
          observer.next(lastValue);
          hasValue = false;
        }
      },
      error: (err) => observer.error(err)
    });
    
    return () => {
      sourceSub();
      notifierSub();
    };
  });
};

// Usage
const sampled = mouseMove.sample(EventStream.fromInterval(100));
```

**SampleTime (Sample at Fixed Intervals):**

```javascript
EventStream.prototype.sampleTime = function(period) {
  return this.sample(EventStream.fromInterval(period));
};
```

**Buffer (Collect Until Signal):**

```javascript
EventStream.prototype.buffer = function(notifier) {
  return new EventStream((observer) => {
    let buffer = [];
    
    const sourceSub = this.subscribe({
      next: (value) => {
        buffer.push(value);
      },
      error: (err) => observer.error(err),
      complete: () => {
        if (buffer.length > 0) {
          observer.next(buffer);
        }
        notifierSub();
        observer.complete();
      }
    });
    
    const notifierSub = notifier.subscribe({
      next: () => {
        if (buffer.length > 0) {
          observer.next(buffer);
          buffer = [];
        }
      },
      error: (err) => observer.error(err)
    });
    
    return () => {
      sourceSub();
      notifierSub();
    };
  });
};
```

**BufferTime (Collect for Duration):**

```javascript
EventStream.prototype.bufferTime = function(timeSpan) {
  return new EventStream((observer) => {
    let buffer = [];
    
    const flushBuffer = () => {
      if (buffer.length > 0) {
        observer.next(buffer);
        buffer = [];
      }
    };
    
    const intervalId = setInterval(flushBuffer, timeSpan);
    
    const subscription = this.subscribe({
      next: (value) => {
        buffer.push(value);
      },
      error: (err) => {
        clearInterval(intervalId);
        observer.error(err);
      },
      complete: () => {
        clearInterval(intervalId);
        flushBuffer();
        observer.complete();
      }
    });
    
    return () => {
      clearInterval(intervalId);
      subscription();
    };
  });
};

// Usage - batch events every 500ms
const batched = clicks.bufferTime(500);
```

**BufferCount (Collect N Items):**

```javascript
EventStream.prototype.bufferCount = function(count, startEvery = count) {
  return new EventStream((observer) => {
    const buffers = [];
    let emitCount = 0;
    
    return this.subscribe({
      next: (value) => {
        if (emitCount % startEvery === 0) {
          buffers.push([]);
        }
        
        buffers.forEach(buffer => buffer.push(value));
        emitCount++;
        
        if (buffers[0] && buffers[0].length === count) {
          observer.next(buffers.shift());
        }
      },
      error: (err) => observer.error(err),
      complete: () => {
        buffers.forEach(buffer => {
          if (buffer.length > 0) {
            observer.next(buffer);
          }
        });
        observer.complete();
      }
    });
  });
};
```

### Time Window Operations

**Window (Create Nested Streams):**

```javascript
EventStream.prototype.window = function(notifier) {
  return new EventStream((observer) => {
    let windowStream = new Subject();
    observer.next(windowStream.asObservable());
    
    const sourceSub = this.subscribe({
      next: (value) => {
        windowStream.next(value);
      },
      error: (err) => {
        windowStream.error(err);
        observer.error(err);
      },
      complete: () => {
        windowStream.complete();
        notifierSub();
        observer.complete();
      }
    });
    
    const notifierSub = notifier.subscribe({
      next: () => {
        windowStream.complete();
        windowStream = new Subject();
        observer.next(windowStream.asObservable());
      },
      error: (err) => observer.error(err)
    });
    
    return () => {
      sourceSub();
      notifierSub();
    };
  });
};
```

**WindowTime (Time-Based Windows):**

```javascript
EventStream.prototype.windowTime = function(timeSpan) {
  return new EventStream((observer) => {
    let windowSubject = new Subject();
    observer.next(windowSubject.asObservable());
    
    const intervalId = setInterval(() => {
      windowSubject.complete();
      windowSubject = new Subject();
      observer.next(windowSubject.asObservable());
    }, timeSpan);
    
    const subscription = this.subscribe({
      next: (value) => windowSubject.next(value),
      error: (err) => {
        clearInterval(intervalId);
        windowSubject.error(err);
        observer.error(err);
      },
      complete: () => {
        clearInterval(intervalId);
        windowSubject.complete();
        observer.complete();
      }
    });
    
    return () => {
      clearInterval(intervalId);
      subscription();
    };
  });
};
```

### Timeout Operations

**Timeout (Error on Delay):**

```javascript
EventStream.prototype.timeout = function(ms) {
  return new EventStream((observer) => {
    let timeoutId = setTimeout(() => {
      observer.error(new Error('Timeout'));
      subscription();
    }, ms);
    
    const resetTimeout = () => {
      clearTimeout(timeoutId);
      timeoutId = setTimeout(() => {
        observer.error(new Error('Timeout'));
        subscription();
      }, ms);
    };
    
    const subscription = this.subscribe({
      next: (value) => {
        resetTimeout();
        observer.next(value);
      },
      error: (err) => {
        clearTimeout(timeoutId);
        observer.error(err);
      },
      complete: () => {
        clearTimeout(timeoutId);
        observer.complete();
      }
    });
    
    return () => {
      clearTimeout(timeoutId);
      subscription();
    };
  });
};
```

**TimeoutWith (Fallback Stream):**

```javascript
EventStream.prototype.timeoutWith = function(ms, fallbackStream) {
  return new EventStream((observer) => {
    let timeoutId;
    let switched = false;
    let sourceSub;
    let fallbackSub;
    
    const resetTimeout = () => {
      clearTimeout(timeoutId);
      timeoutId = setTimeout(() => {
        if (!switched) {
          switched = true;
          sourceSub();
          fallbackSub = fallbackStream.subscribe({
            next: (value) => observer.next(value),
            error: (err) => observer.error(err),
            complete: () => observer.complete()
          });
        }
      }, ms);
    };
    
    resetTimeout();
    
    sourceSub = this.subscribe({
      next: (value) => {
        if (!switched) {
          resetTimeout();
          observer.next(value);
        }
      },
      error: (err) => {
        clearTimeout(timeoutId);
        observer.error(err);
      },
      complete: () => {
        clearTimeout(timeoutId);
        if (!switched) {
          observer.complete();
        }
      }
    });
    
    return () => {
      clearTimeout(timeoutId);
      sourceSub();
      if (fallbackSub) fallbackSub();
    };
  });
};
```

### Temporal Coordination

**CombineLatest with Time:**

```javascript
EventStream.combineLatestWithTime = function(windowMs, ...streams) {
  return new EventStream((observer) => {
    const values = new Array(streams.length);
    const timestamps = new Array(streams.length).fill(0);
    const hasValue = new Array(streams.length).fill(false);
    
    const tryEmit = () => {
      const now = Date.now();
      if (hasValue.every(Boolean)) {
        const allRecent = timestamps.every(ts => now - ts <= windowMs);
        if (allRecent) {
          observer.next([...values]);
        }
      }
    };
    
    const subscriptions = streams.map((stream, index) =>
      stream.subscribe({
        next: (value) => {
          values[index] = value;
          timestamps[index] = Date.now();
          hasValue[index] = true;
          tryEmit();
        },
        error: (err) => observer.error(err),
        complete: () => observer.complete()
      })
    );
    
    return () => subscriptions.forEach(sub => sub());
  });
};
```

**Repeat with Delay:**

```javascript
EventStream.prototype.repeat = function(count = -1, delayMs = 0) {
  return new EventStream((observer) => {
    let currentCount = 0;
    let subscription;
    
    const subscribeToSource = () => {
      subscription = this.subscribe({
        next: (value) => observer.next(value),
        error: (err) => observer.error(err),
        complete: () => {
          currentCount++;
          if (count === -1 || currentCount < count) {
            if (delayMs > 0) {
              setTimeout(subscribeToSource, delayMs);
            } else {
              subscribeToSource();
            }
          } else {
            observer.complete();
          }
        }
      });
    };
    
    subscribeToSource();
    
    return () => subscription && subscription();
  });
};
```

**Key Points:**

- Time-based operations manage temporal aspects of event streams
- Delay operations shift events forward in time
- Throttle limits event rate by enforcing minimum intervals
- Debounce waits for silence before emitting
- Sampling captures periodic snapshots of stream state
- Buffering collects events into batches based on time or count
- Window operations create nested streams for grouped processing
- Timeout operations detect and handle stream inactivity
- Schedulers enable testable and controllable timing
- Essential for managing high-frequency events and async coordination

---

