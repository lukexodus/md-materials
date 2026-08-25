## Observer Pattern with Callbacks


The observer pattern in functional programming uses callback functions instead of observer objects, often implemented through event emitters or reactive streams. Subscribers are simply functions that get invoked when events occur.

**Basic Event Emitter**

Create a simple pub-sub system where observers are callback functions stored in a registry. The subject maintains a list of callbacks for each event type.

```javascript
const createEventEmitter = () => {
  const listeners = {};
  
  return {
    on(event, callback) {
      if (!listeners[event]) {
        listeners[event] = [];
      }
      listeners[event].push(callback);
      
      // Return unsubscribe function
      return () => {
        listeners[event] = listeners[event].filter(cb => cb !== callback);
      };
    },
    
    emit(event, data) {
      if (!listeners[event]) return;
      listeners[event].forEach(callback => callback(data));
    },
    
    once(event, callback) {
      const unsubscribe = this.on(event, (data) => {
        callback(data);
        unsubscribe();
      });
      return unsubscribe;
    }
  };
};

// Usage
const emitter = createEventEmitter();

const unsubscribe = emitter.on('userLogin', (user) => {
  console.log(`User logged in: ${user.name}`);
});

emitter.emit('userLogin', { name: 'Alice' });
unsubscribe(); // Stop listening
```

**Observer with State Management**

Combine observers with immutable state updates, where each state change triggers notifications to all registered observers.

```javascript
const createObservableState = (initialState) => {
  let state = initialState;
  const observers = [];
  
  return {
    getState() {
      return state;
    },
    
    setState(newState) {
      const prevState = state;
      state = newState;
      observers.forEach(observer => observer(state, prevState));
    },
    
    subscribe(observer) {
      observers.push(observer);
      observer(state, undefined); // Call immediately with current state
      
      return () => {
        const index = observers.indexOf(observer);
        if (index > -1) observers.splice(index, 1);
      };
    }
  };
};

// Usage
const userStore = createObservableState({ name: '', age: 0 });

userStore.subscribe((newState, prevState) => {
  console.log('State changed:', { prev: prevState, new: newState });
});

userStore.setState({ name: 'Bob', age: 30 });
```

**Filtered Observers**

Implement selective observation where callbacks only trigger for specific conditions or event types, reducing unnecessary notifications.

```javascript
const createFilteredEmitter = () => {
  const listeners = [];
  
  return {
    on(predicate, callback) {
      listeners.push({ predicate, callback });
      
      return () => {
        const index = listeners.findIndex(l => l.callback === callback);
        if (index > -1) listeners.splice(index, 1);
      };
    },
    
    emit(data) {
      listeners.forEach(({ predicate, callback }) => {
        if (predicate(data)) {
          callback(data);
        }
      });
    }
  };
};

// Usage
const stream = createFilteredEmitter();

stream.on(
  (data) => data.type === 'ERROR',
  (data) => console.error('Error occurred:', data)
);

stream.on(
  (data) => data.priority === 'high',
  (data) => sendAlert(data)
);

stream.emit({ type: 'ERROR', priority: 'high', message: 'Critical failure' });
```

**Async Observers**

Handle asynchronous observers that perform async operations in response to events, with optional error handling and completion tracking.

```javascript
const createAsyncEmitter = () => {
  const listeners = [];
  
  return {
    on(callback) {
      listeners.push(callback);
      return () => {
        const index = listeners.indexOf(callback);
        if (index > -1) listeners.splice(index, 1);
      };
    },
    
    async emit(data) {
      const results = await Promise.allSettled(
        listeners.map(callback => callback(data))
      );
      
      return results.map((result, index) => ({
        listener: listeners[index],
        status: result.status,
        value: result.status === 'fulfilled' ? result.value : undefined,
        error: result.status === 'rejected' ? result.reason : undefined
      }));
    }
  };
};

// Usage
const asyncEmitter = createAsyncEmitter();

asyncEmitter.on(async (data) => {
  await fetch('/api/log', { method: 'POST', body: JSON.stringify(data) });
});

asyncEmitter.on(async (data) => {
  await saveToDatabase(data);
});

await asyncEmitter.emit({ event: 'userAction', timestamp: Date.now() });
```

**Transformation Pipelines**

Create observable streams that transform data through a pipeline of operations before notifying observers, enabling reactive data flow.

```javascript
const createObservableStream = () => {
  const transformations = [];
  const observers = [];
  
  return {
    map(fn) {
      transformations.push((data) => fn(data));
      return this;
    },
    
    filter(predicate) {
      transformations.push((data) => predicate(data) ? data : null);
      return this;
    },
    
    subscribe(observer) {
      observers.push(observer);
      return () => {
        const index = observers.indexOf(observer);
        if (index > -1) observers.splice(index, 1);
      };
    },
    
    emit(data) {
      let transformedData = data;
      
      for (const transform of transformations) {
        transformedData = transform(transformedData);
        if (transformedData === null) return; // Filtered out
      }
      
      observers.forEach(observer => observer(transformedData));
    }
  };
};

// Usage
const dataStream = createObservableStream();

dataStream
  .filter(data => data.value > 10)
  .map(data => ({ ...data, doubled: data.value * 2 }))
  .subscribe(data => console.log('Processed:', data));

dataStream.emit({ value: 15 }); // Processed: { value: 15, doubled: 30 }
dataStream.emit({ value: 5 });  // Filtered out
```

**Debounced and Throttled Observers**

Control notification frequency with debouncing and throttling to prevent observer overload during rapid event sequences.

```javascript
const debounce = (fn, delay) => {
  let timeoutId;
  return (...args) => {
    clearTimeout(timeoutId);
    timeoutId = setTimeout(() => fn(...args), delay);
  };
};

const throttle = (fn, limit) => {
  let inThrottle;
  return (...args) => {
    if (!inThrottle) {
      fn(...args);
      inThrottle = true;
      setTimeout(() => inThrottle = false, limit);
    }
  };
};

// Usage with emitter
const emitter = createEventEmitter();

const debouncedHandler = debounce((data) => {
  console.log('Debounced:', data);
}, 300);

const throttledHandler = throttle((data) => {
  console.log('Throttled:', data);
}, 1000);

emitter.on('input', debouncedHandler);
emitter.on('scroll', throttledHandler);
```

**Multi-Subject Observer**

Observe multiple subjects simultaneously with a single callback, aggregating events from different sources.

```javascript
const createMultiObserver = () => {
  const subjects = new Map();
  
  return {
    addSubject(name, emitter) {
      subjects.set(name, emitter);
    },
    
    subscribeAll(callback) {
      const unsubscribers = [];
      
      subjects.forEach((emitter, name) => {
        const unsubscribe = emitter.on('*', (data) => {
          callback({ source: name, data });
        });
        unsubscribers.push(unsubscribe);
      });
      
      return () => unsubscribers.forEach(unsub => unsub());
    }
  };
};

// Usage
const userEmitter = createEventEmitter();
const systemEmitter = createEventEmitter();

const multiObserver = createMultiObserver();
multiObserver.addSubject('user', userEmitter);
multiObserver.addSubject('system', systemEmitter);

multiObserver.subscribeAll(({ source, data }) => {
  console.log(`Event from ${source}:`, data);
});
```

**Memory Leak Prevention**

Implement automatic cleanup and weak references to prevent memory leaks from forgotten subscriptions.

```javascript
const createSafeEmitter = () => {
  const listeners = new Map();
  let nextId = 0;
  
  return {
    on(event, callback) {
      if (!listeners.has(event)) {
        listeners.set(event, new Map());
      }
      
      const id = nextId++;
      listeners.get(event).set(id, callback);
      
      return () => {
        const eventListeners = listeners.get(event);
        if (eventListeners) {
          eventListeners.delete(id);
          if (eventListeners.size === 0) {
            listeners.delete(event);
          }
        }
      };
    },
    
    emit(event, data) {
      const eventListeners = listeners.get(event);
      if (!eventListeners) return;
      
      eventListeners.forEach(callback => callback(data));
    },
    
    clear() {
      listeners.clear();
    },
    
    listenerCount(event) {
      return listeners.get(event)?.size || 0;
    }
  };
};
```

