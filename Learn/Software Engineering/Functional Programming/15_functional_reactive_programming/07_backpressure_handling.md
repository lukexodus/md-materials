## Backpressure Handling


Backpressure occurs when a data producer generates values faster than a consumer can process them. In functional reactive programming, backpressure handling is critical for maintaining system stability and preventing memory exhaustion when dealing with asynchronous data streams.

### Understanding Backpressure

**The Problem:**

```javascript
// Producer generates data rapidly
const fastProducer = {
  subscribe(observer) {
    let count = 0;
    const interval = setInterval(() => {
      observer.next(count++);
    }, 1); // Every 1ms
    
    return () => clearInterval(interval);
  }
};

// Consumer processes slowly
const slowConsumer = {
  next(value) {
    // Simulates slow processing (100ms per item)
    setTimeout(() => {
      console.log('Processed:', value);
    }, 100);
  }
};

// fastProducer.subscribe(slowConsumer);
// This would queue thousands of items in memory
```

### Backpressure Strategies

**1. Drop Strategy (Skip Overflow):**

```javascript
class DropBackpressure {
  constructor(source, maxBuffer = 10) {
    this.source = source;
    this.maxBuffer = maxBuffer;
    this.buffer = [];
    this.processing = false;
  }
  
  subscribe(observer) {
    const wrappedObserver = {
      next: (value) => {
        if (this.buffer.length < this.maxBuffer) {
          this.buffer.push(value);
        } else {
          console.log('Dropped:', value);
        }
        this.process(observer);
      },
      error: (err) => observer.error(err),
      complete: () => observer.complete()
    };
    
    return this.source.subscribe(wrappedObserver);
  }
  
  async process(observer) {
    if (this.processing || this.buffer.length === 0) return;
    
    this.processing = true;
    const value = this.buffer.shift();
    
    try {
      await observer.next(value);
    } finally {
      this.processing = false;
      if (this.buffer.length > 0) {
        this.process(observer);
      }
    }
  }
}
```

**2. Buffer Strategy (Queue Until Limit):**

```javascript
class BufferBackpressure {
  constructor(source, maxBuffer = 100) {
    this.source = source;
    this.maxBuffer = maxBuffer;
    this.buffer = [];
    this.processing = false;
    this.paused = false;
  }
  
  subscribe(observer) {
    let subscription;
    
    const wrappedObserver = {
      next: (value) => {
        this.buffer.push(value);
        
        if (this.buffer.length >= this.maxBuffer && !this.paused) {
          this.paused = true;
          console.log('Buffer full, pausing producer');
          // Signal to slow down
        }
        
        this.process(observer);
      },
      error: (err) => observer.error(err),
      complete: () => {
        this.flush(observer).then(() => observer.complete());
      }
    };
    
    subscription = this.source.subscribe(wrappedObserver);
    return subscription;
  }
  
  async process(observer) {
    if (this.processing || this.buffer.length === 0) return;
    
    this.processing = true;
    const value = this.buffer.shift();
    
    try {
      await observer.next(value);
    } finally {
      this.processing = false;
      
      if (this.paused && this.buffer.length < this.maxBuffer / 2) {
        this.paused = false;
        console.log('Buffer drained, resuming producer');
      }
      
      if (this.buffer.length > 0) {
        this.process(observer);
      }
    }
  }
  
  async flush(observer) {
    while (this.buffer.length > 0) {
      await this.process(observer);
    }
  }
}
```

**3. Sample Strategy (Take Latest):**

```javascript
class SampleBackpressure {
  constructor(source, sampleRate = 100) {
    this.source = source;
    this.sampleRate = sampleRate;
    this.latest = null;
    this.hasValue = false;
  }
  
  subscribe(observer) {
    const wrappedObserver = {
      next: (value) => {
        this.latest = value;
        this.hasValue = true;
      },
      error: (err) => observer.error(err),
      complete: () => observer.complete()
    };
    
    const interval = setInterval(() => {
      if (this.hasValue) {
        observer.next(this.latest);
        this.hasValue = false;
      }
    }, this.sampleRate);
    
    const subscription = this.source.subscribe(wrappedObserver);
    
    return () => {
      clearInterval(interval);
      subscription();
    };
  }
}
```

**4. Throttle Strategy (Rate Limiting):**

```javascript
class ThrottleBackpressure {
  constructor(source, interval = 100) {
    this.source = source;
    this.interval = interval;
    this.lastEmit = 0;
  }
  
  subscribe(observer) {
    const wrappedObserver = {
      next: (value) => {
        const now = Date.now();
        if (now - this.lastEmit >= this.interval) {
          this.lastEmit = now;
          observer.next(value);
        }
      },
      error: (err) => observer.error(err),
      complete: () => observer.complete()
    };
    
    return this.source.subscribe(wrappedObserver);
  }
}
```

**5. Debounce Strategy (Wait for Silence):**

```javascript
class DebounceBackpressure {
  constructor(source, delay = 100) {
    this.source = source;
    this.delay = delay;
    this.timeoutId = null;
  }
  
  subscribe(observer) {
    const wrappedObserver = {
      next: (value) => {
        clearTimeout(this.timeoutId);
        this.timeoutId = setTimeout(() => {
          observer.next(value);
        }, this.delay);
      },
      error: (err) => observer.error(err),
      complete: () => {
        clearTimeout(this.timeoutId);
        observer.complete();
      }
    };
    
    return this.source.subscribe(wrappedObserver);
  }
}
```

### Pull-Based Backpressure

**Iterator Pattern with Backpressure:**

```javascript
class PullStream {
  constructor(generator) {
    this.iterator = generator();
  }
  
  async pull() {
    const { value, done } = this.iterator.next();
    return { value, done };
  }
  
  async *[Symbol.asyncIterator]() {
    while (true) {
      const { value, done } = await this.pull();
      if (done) break;
      yield value;
    }
  }
}

// Consumer controls the pace
async function* dataGenerator() {
  let i = 0;
  while (i < 100) {
    await new Promise(resolve => setTimeout(resolve, 10));
    yield i++;
  }
}

const stream = new PullStream(dataGenerator);

// Consumer pulls at its own pace
(async () => {
  for await (const value of stream) {
    // Process slowly
    await new Promise(resolve => setTimeout(resolve, 100));
    console.log('Processed:', value);
  }
})();
```

### Reactive Streams Specification

**Simple Implementation:**

```javascript
class ReactiveStream {
  constructor() {
    this.subscribers = [];
  }
  
  subscribe(subscriber) {
    const subscription = {
      cancelled: false,
      requested: 0,
      
      request(n) {
        this.requested += n;
        subscriber.onSubscribe(this);
      },
      
      cancel() {
        this.cancelled = true;
        const index = this.subscribers.indexOf(subscription);
        if (index > -1) {
          this.subscribers.splice(index, 1);
        }
      }
    };
    
    this.subscribers.push(subscription);
    subscriber.onSubscribe(subscription);
    return subscription;
  }
  
  emit(value) {
    this.subscribers.forEach(sub => {
      if (!sub.cancelled && sub.requested > 0) {
        sub.requested--;
        sub.subscriber.onNext(value);
      }
    });
  }
  
  error(err) {
    this.subscribers.forEach(sub => {
      if (!sub.cancelled) {
        sub.subscriber.onError(err);
      }
    });
  }
  
  complete() {
    this.subscribers.forEach(sub => {
      if (!sub.cancelled) {
        sub.subscriber.onComplete();
      }
    });
  }
}

// Usage with demand signaling
const stream = new ReactiveStream();

const subscriber = {
  subscription: null,
  
  onSubscribe(subscription) {
    this.subscription = subscription;
    subscription.request(1); // Request one item
  },
  
  onNext(value) {
    console.log('Received:', value);
    // Process and request next
    setTimeout(() => {
      this.subscription.request(1);
    }, 100);
  },
  
  onError(err) {
    console.error('Error:', err);
  },
  
  onComplete() {
    console.log('Complete');
  }
};

stream.subscribe(subscriber);
```

### Windowing Strategies

**Tumbling Window (Fixed Size):**

```javascript
class TumblingWindow {
  constructor(source, size) {
    this.source = source;
    this.size = size;
    this.window = [];
  }
  
  subscribe(observer) {
    const wrappedObserver = {
      next: (value) => {
        this.window.push(value);
        
        if (this.window.length >= this.size) {
          observer.next([...this.window]);
          this.window = [];
        }
      },
      error: (err) => observer.error(err),
      complete: () => {
        if (this.window.length > 0) {
          observer.next([...this.window]);
        }
        observer.complete();
      }
    };
    
    return this.source.subscribe(wrappedObserver);
  }
}
```

**Sliding Window (Overlapping):**

```javascript
class SlidingWindow {
  constructor(source, size, step = 1) {
    this.source = source;
    this.size = size;
    this.step = step;
    this.window = [];
    this.count = 0;
  }
  
  subscribe(observer) {
    const wrappedObserver = {
      next: (value) => {
        this.window.push(value);
        
        if (this.window.length > this.size) {
          this.window.shift();
        }
        
        if (this.window.length === this.size) {
          this.count++;
          if (this.count % this.step === 0) {
            observer.next([...this.window]);
          }
        }
      },
      error: (err) => observer.error(err),
      complete: () => observer.complete()
    };
    
    return this.source.subscribe(wrappedObserver);
  }
}
```

### Adaptive Backpressure

**Dynamic Buffer Sizing:**

```javascript
class AdaptiveBackpressure {
  constructor(source, initialBuffer = 10) {
    this.source = source;
    this.maxBuffer = initialBuffer;
    this.buffer = [];
    this.processing = false;
    this.dropCount = 0;
    this.processTime = [];
  }
  
  subscribe(observer) {
    const wrappedObserver = {
      next: (value) => {
        if (this.buffer.length < this.maxBuffer) {
          this.buffer.push(value);
        } else {
          this.dropCount++;
          if (this.dropCount > 10) {
            // Increase buffer size if dropping too much
            this.maxBuffer = Math.min(this.maxBuffer * 2, 1000);
            this.dropCount = 0;
            console.log('Increased buffer to:', this.maxBuffer);
          }
        }
        this.process(observer);
      },
      error: (err) => observer.error(err),
      complete: () => observer.complete()
    };
    
    return this.source.subscribe(wrappedObserver);
  }
  
  async process(observer) {
    if (this.processing || this.buffer.length === 0) return;
    
    this.processing = true;
    const value = this.buffer.shift();
    const startTime = Date.now();
    
    try {
      await observer.next(value);
      
      const processTime = Date.now() - startTime;
      this.processTime.push(processTime);
      
      if (this.processTime.length > 100) {
        this.processTime.shift();
      }
      
      // Adjust buffer based on processing speed
      const avgTime = this.processTime.reduce((a, b) => a + b, 0) / this.processTime.length;
      if (avgTime < 10 && this.maxBuffer > 5) {
        // Processing fast, can reduce buffer
        this.maxBuffer = Math.max(Math.floor(this.maxBuffer / 2), 5);
      }
    } finally {
      this.processing = false;
      if (this.buffer.length > 0) {
        this.process(observer);
      }
    }
  }
}
```

**Key Points:**

- Backpressure prevents memory exhaustion in fast producer/slow consumer scenarios
- Drop strategy discards overflow data (suitable for real-time metrics)
- Buffer strategy queues data up to a limit (suitable for important events)
- Sample/throttle strategies reduce data rate (suitable for UI updates)
- Debounce strategy waits for silence (suitable for search input)
- Pull-based backpressure gives control to the consumer
- Reactive Streams specification provides demand signaling
- Windowing strategies batch data for efficient processing
- Adaptive backpressure adjusts dynamically to system conditions
- Choose strategy based on data importance and system constraints

