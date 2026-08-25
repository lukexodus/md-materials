## EventEmitter


EventEmitter is a core pattern in Node.js (and by extension, Electron) for handling asynchronous events. It's part of Node.js's built-in `events` module and provides a fundamental way for objects to emit named events and for listeners to respond to them.

### What is EventEmitter?

EventEmitter is a class that allows objects to implement the observer pattern. Objects that extend or use EventEmitter can:

- Emit named events
- Register listener functions that execute when specific events occur
- Pass data along with events to listeners

### Basic Concepts

**Events and Listeners**

An event is simply a named occurrence in your program. A listener is a callback function that runs when that event is emitted. The relationship is many-to-many: one event can have multiple listeners, and one listener can respond to multiple events.

**How It Works**

When you call `.emit('eventName')`, all functions registered as listeners for that event name get called synchronously, in the order they were registered.

### Core Methods

**on(eventName, listener)**

Registers a listener function for a specific event. The listener will be called every time the event is emitted.

```javascript
const EventEmitter = require('events');
const emitter = new EventEmitter();

emitter.on('data', (message) => {
  console.log('Received:', message);
});
```

**emit(eventName, [args])**

Triggers an event, calling all registered listeners with the provided arguments.

```javascript
emitter.emit('data', 'Hello World');
// Output: Received: Hello World
```

**once(eventName, listener)**

Registers a listener that will be called at most one time. After the event fires once, the listener is automatically removed.

```javascript
emitter.once('start', () => {
  console.log('Started!');
});

emitter.emit('start'); // Output: Started!
emitter.emit('start'); // No output - listener removed after first call
```

**removeListener(eventName, listener)**

Removes a specific listener from an event. You need a reference to the original function.

```javascript
function handleData(msg) {
  console.log(msg);
}

emitter.on('data', handleData);
emitter.removeListener('data', handleData);
```

**removeAllListeners([eventName])**

Removes all listeners for a specific event, or all listeners for all events if no event name is provided.

### Practical Example

```javascript
const EventEmitter = require('events');

class DataProcessor extends EventEmitter {
  processFile(filename) {
    this.emit('start', filename);
    
    // Simulate processing
    setTimeout(() => {
      const data = { filename, lines: 100 };
      this.emit('progress', 50);
      
      setTimeout(() => {
        this.emit('progress', 100);
        this.emit('complete', data);
      }, 500);
    }, 500);
  }
}

const processor = new DataProcessor();

processor.on('start', (filename) => {
  console.log(`Processing ${filename}...`);
});

processor.on('progress', (percent) => {
  console.log(`${percent}% complete`);
});

processor.on('complete', (data) => {
  console.log(`Finished processing ${data.filename}: ${data.lines} lines`);
});

processor.processFile('data.txt');
```

### Error Handling

EventEmitter has special behavior for `'error'` events. If you emit an error event and there are no listeners registered for it, Node.js will throw an exception and potentially crash your program.

```javascript
// Bad - will crash if error is emitted
const emitter = new EventEmitter();
emitter.emit('error', new Error('Something went wrong'));

// Good - error is caught
emitter.on('error', (err) => {
  console.error('Error occurred:', err.message);
});
emitter.emit('error', new Error('Something went wrong'));
```

### Memory Considerations

By default, EventEmitter warns if you add more than 10 listeners to a single event, as this might indicate a memory leak. You can adjust this with `setMaxListeners()`.

```javascript
emitter.setMaxListeners(20); // Allow up to 20 listeners
```

### Common Patterns

**Chaining Events**

EventEmitters can listen to other EventEmitters, creating chains of event propagation.

```javascript
const source = new EventEmitter();
const processor = new EventEmitter();

source.on('data', (data) => {
  const processed = data.toUpperCase();
  processor.emit('processed', processed);
});

processor.on('processed', (result) => {
  console.log('Result:', result);
});

source.emit('data', 'hello'); // Output: Result: HELLO
```

**Promisifying Events**

You can convert event-based APIs to Promises using utilities like `events.once()` (available in newer Node.js versions).

```javascript
const { once } = require('events');

async function waitForEvent() {
  const emitter = new EventEmitter();
  
  setTimeout(() => emitter.emit('ready'), 1000);
  
  const [value] = await once(emitter, 'ready');
  console.log('Ready!');
}
```

### Why EventEmitter Matters

EventEmitter provides a clean, decoupled way to handle asynchronous operations. Instead of tightly coupling your code with callbacks or forcing everything through a single function, you can emit events that any part of your application can listen to. This makes code more modular, testable, and easier to extend.

In Electron specifically, many core objects like `BrowserWindow`, `app`, and `ipcMain`/`ipcRenderer` extend EventEmitter, allowing you to respond to lifecycle events, user interactions, and inter-process communication through this familiar event-based interface.

---

