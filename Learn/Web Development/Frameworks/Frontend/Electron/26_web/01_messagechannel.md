## **`MessageChannel`**


### **What is MessageChannel?**

MessagePorts are a web feature that allow passing messages between different contexts. It's like window.postMessage, but on different channels.

#### **Basic Concept**

MessagePorts are created in pairs. A connected pair of message ports is called a channel:

```javascript
// MessagePorts are created in pairs
const channel = new MessageChannel()

// Messages sent to port1 will be received by port2 and vice-versa
const port1 = channel.port1
const port2 = channel.port2

// It's OK to send a message before the other end has a listener
// Messages will be queued until a listener is registered
port2.postMessage({ answer: 42 })
```

---

### **MessageChannel in Different Processes**

#### **In the Renderer Process**

In the renderer, the MessagePort class behaves exactly as it does on the web:

```javascript
// Renderer process - uses standard web API
const channel = new MessageChannel()
const port1 = channel.port1
const port2 = channel.port2

port1.onmessage = (event) => {
  console.log(event.data)
}

port2.postMessage('hello')
```

#### **In the Main Process**

The main process is not a web page and has no Blink integration, so it does not have the MessagePort or MessageChannel classes. Electron adds two new classes: MessagePortMain and MessageChannelMain:

```javascript
// Main process - uses Electron-specific classes
const { MessageChannelMain } = require('electron')

const { port1, port2 } = new MessageChannelMain()

// MessagePortMain uses Node.js-style events API
port1.on('message', (event) => {
  console.log(event.data)
})

// MessagePortMain queues messages until .start() is called
port1.start()

port2.postMessage({ answer: 42 })
```

---

### **Key Differences: Main vs Renderer**

| Aspect | Renderer Process | Main Process |
|--------|------------------|--------------|
| **Class Name** | `MessageChannel` | `MessageChannelMain` |
| **Port Class** | `MessagePort` | `MessagePortMain` |
| **Event Handling** | Web-style (`onmessage`, `addEventListener`) | Node.js-style (`.on('message', ...)`) |
| **Message Queue** | Auto-started | Must call `.start()` |

---

### **Transferring MessagePorts**

MessagePort objects can be created in either the renderer or the main process, and passed back and forth using the ipcRenderer.postMessage and WebContents.postMessage methods. Note that the usual IPC methods like send and invoke cannot be used to transfer MessagePorts, only the postMessage methods can transfer MessagePorts.

#### **CRITICAL: Use postMessage, NOT send or invoke**

```javascript
// ✓ CORRECT - Use postMessage
ipcRenderer.postMessage('port', null, [port1])
webContents.postMessage('port', null, [port2])

// ✗ WRONG - Cannot use send or invoke
ipcRenderer.send('port', port1)  // Won't work!
ipcMain.handle('port', () => port1)  // Won't work!
```

---

### **The `close` Event (Electron Extension)**

Electron adds one feature to MessagePort that isn't present on the web: the close event, which is emitted when the other end of the channel is closed. Ports can also be implicitly closed by being garbage-collected.

#### **Listening for Close**

```javascript
// In renderer
port.onclose = () => {
  console.log('Port closed')
}
// OR
port.addEventListener('close', () => {
  console.log('Port closed')
})

// In main process
port.on('close', () => {
  console.log('Port closed')
})
```

---

### **Common Use Cases**

#### **1. Direct Renderer-to-Renderer Communication**

By passing MessagePorts via the main process, you can connect two pages that might not otherwise be able to communicate, allowing renderers to send messages to each other without needing to use the main process as an in-between.

**Main Process:**
```javascript
const { BrowserWindow, app, MessageChannelMain } = require('electron')

app.whenReady().then(async () => {
  const mainWindow = new BrowserWindow({
    show: false,
    webPreferences: {
      contextIsolation: false,
      preload: 'preloadMain.js'
    }
  })
  
  const secondaryWindow = new BrowserWindow({
    show: false,
    webPreferences: {
      contextIsolation: false,
      preload: 'preloadSecondary.js'
    }
  })
  
  // Set up the channel
  const { port1, port2 } = new MessageChannelMain()
  
  // Send one port to each window
  mainWindow.once('ready-to-show', () => {
    mainWindow.webContents.postMessage('port', null, [port1])
  })
  
  secondaryWindow.once('ready-to-show', () => {
    secondaryWindow.webContents.postMessage('port', null, [port2])
  })
})
```

**Preload Scripts (both windows):**
```javascript
const { ipcRenderer } = require('electron')

ipcRenderer.on('port', e => {
  // Port received, make it globally available
  window.electronMessagePort = e.ports[0]
  
  window.electronMessagePort.onmessage = messageEvent => {
    console.log('Received:', messageEvent.data)
  }
})
```

**Renderer (any window):**
```javascript
// Send message to the other renderer
window.electronMessagePort.postMessage('ping')
```

---

#### **2. Worker Process Pattern**

Create a hidden worker window for CPU-intensive tasks:

**Main Process:**
```javascript
const { BrowserWindow, app, MessageChannelMain } = require('electron')

app.whenReady().then(async () => {
  // Hidden worker window
  const worker = new BrowserWindow({
    show: false,
    webPreferences: { nodeIntegration: true }
  })
  await worker.loadFile('worker.html')
  
  // Main app window
  const mainWindow = new BrowserWindow({
    webPreferences: { nodeIntegration: true }
  })
  mainWindow.loadFile('app.html')
  
  // Listen for channel request from main window
  mainWindow.webContents.mainFrame.ipc.on('request-worker-channel', (event) => {
    // Create a new channel
    const { port1, port2 } = new MessageChannelMain()
    
    // Send one end to the worker
    worker.webContents.postMessage('new-client', null, [port1])
    
    // Send the other end to the main window
    event.senderFrame.postMessage('provide-worker-channel', null, [port2])
    
    // Now they can communicate directly!
  })
})
```

**Worker (worker.html):**
```javascript
const { ipcRenderer } = require('electron')

const doWork = (input) => {
  // CPU-intensive operation
  return input * 2
}

// Handle multiple clients
ipcRenderer.on('new-client', (event) => {
  const [ port ] = event.ports
  
  port.onmessage = (event) => {
    const result = doWork(event.data)
    port.postMessage(result)
  }
})
```

**Main App (app.html):**
```javascript
const { ipcRenderer } = require('electron')

// Request a worker channel
ipcRenderer.send('request-worker-channel')

ipcRenderer.once('provide-worker-channel', (event) => {
  const [ port ] = event.ports
  
  // Register result handler
  port.onmessage = (event) => {
    console.log('received result:', event.data)
  }
  
  // Send work to worker
  port.postMessage(21)
})
```

---

#### **3. Response Streams (Multiple Responses)**

Electron's built-in IPC methods only support two modes: fire-and-forget (e.g. send), or request-response (e.g. invoke). Using MessageChannels, you can implement a "response stream", where a single request responds with a stream of data.

**Renderer:**
```javascript
const makeStreamingRequest = (element, callback) => {
  // Create a new channel for this request
  const { port1, port2 } = new MessageChannel()
  
  // Send one end to main process
  ipcRenderer.postMessage(
    'give-me-a-stream',
    { element, count: 10 },
    [port2]
  )
  
  // Receive multiple messages on our end
  port1.onmessage = (event) => {
    callback(event.data)
  }
  
  port1.onclose = () => {
    console.log('stream ended')
  }
}

makeStreamingRequest(42, (data) => {
  console.log('got response data:', data)
})
// Will see "got response data: 42" 10 times
```

**Main Process:**
```javascript
ipcMain.on('give-me-a-stream', (event, msg) => {
  const [replyPort] = event.ports
  
  // Send multiple messages
  for (let i = 0; i < msg.count; i++) {
    replyPort.postMessage(msg.element)
  }
  
  // Close when done
  replyPort.close()
})
```

---

#### **4. Context-Isolated Communication**

When context isolation is enabled, IPC messages from the main process to the renderer are delivered to the isolated world, rather than to the main world. Sometimes you want to deliver messages to the main world directly, without having to step through the isolated world.

**Main Process:**
```javascript
const { BrowserWindow, app, MessageChannelMain } = require('electron')
const path = require('node:path')

app.whenReady().then(async () => {
  const bw = new BrowserWindow({
    webPreferences: {
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js')
    }
  })
  bw.loadURL('index.html')
  
  const { port1, port2 } = new MessageChannelMain()
  
  // Send message before listener is registered (will be queued)
  port2.postMessage({ test: 21 })
  
  // Receive messages from renderer
  port2.on('message', (event) => {
    console.log('from renderer main world:', event.data)
  })
  port2.start()
  
  // Send port to preload
  bw.webContents.postMessage('main-world-port', null, [port1])
})
```

**Preload Script:**
```javascript
const { ipcRenderer } = require('electron')

// Wait for window to load
const windowLoaded = new Promise(resolve => {
  window.onload = resolve
})

ipcRenderer.on('main-world-port', async (event) => {
  await windowLoaded
  
  // Transfer port from isolated world to main world
  window.postMessage('main-world-port', '*', event.ports)
})
```

**Renderer (index.html):**
```javascript
window.onmessage = (event) => {
  // Ensure message is from preload, not iframe
  if (event.source === window && event.data === 'main-world-port') {
    const [ port ] = event.ports
    
    // Now we can communicate directly with main process
    port.onmessage = (event) => {
      console.log('from main process:', event.data)
      port.postMessage(event.data.test * 2)
    }
  }
}
```

---

### **MessagePortMain API Reference**

#### **Methods**

```javascript
const { MessageChannelMain } = require('electron')
const { port1, port2 } = new MessageChannelMain()

// Send message
port1.postMessage(value, [transferList])

// Start receiving messages (required in main process)
port1.start()

// Close the port
port1.close()
```

#### **Events**

```javascript
// Message received
port1.on('message', (event) => {
  console.log(event.data)
})

// Port closed
port1.on('close', () => {
  console.log('Port closed')
})
```

---

### **MessagePort API Reference (Renderer)**

#### **Properties & Methods**

```javascript
const channel = new MessageChannel()
const port = channel.port1

// Send message
port.postMessage(value, [transferList])

// Close port
port.close()

// Start receiving (called automatically in renderer)
port.start()
```

#### **Event Handling**

```javascript
// Option 1: onmessage property
port.onmessage = (event) => {
  console.log(event.data)
}

// Option 2: addEventListener
port.addEventListener('message', (event) => {
  console.log(event.data)
})

// Close event
port.onclose = () => {
  console.log('Port closed')
}
```

---

### **Best Practices**

#### **1. Always Use postMessage for Transfer**

```javascript
// ✓ CORRECT
webContents.postMessage('channel', null, [port])
ipcRenderer.postMessage('channel', null, [port])

// ✗ WRONG
webContents.send('channel', port)  // Won't transfer!
ipcRenderer.send('channel', port)   // Won't transfer!
```

#### **2. Call start() in Main Process**

```javascript
// Main process
port.on('message', (event) => {
  console.log(event.data)
})
port.start()  // Required! Messages are queued until this is called
```

#### **3. Handle Port Cleanup**

```javascript
// Listen for close to clean up resources
port.on('close', () => {
  // Clean up any resources
  clearInterval(someInterval)
  removeEventListeners()
})

// Explicitly close when done
port.close()
```

#### **4. Create New Channels for Each Request**

```javascript
// MessageChannels are lightweight - create new ones as needed
const makeRequest = (data) => {
  const { port1, port2 } = new MessageChannel()
  
  ipcRenderer.postMessage('request', data, [port2])
  
  port1.onmessage = (event) => {
    console.log('Response:', event.data)
  }
}
```

#### **5. Use Context Isolation Safely**

```javascript
// Preload script with contextBridge
const { contextBridge, ipcRenderer } = require('electron')

contextBridge.exposeInMainWorld('api', {
  connectToWorker: (callback) => {
    ipcRenderer.send('request-worker')
    
    ipcRenderer.once('worker-port', (event) => {
      const [port] = event.ports
      
      port.onmessage = (e) => {
        // Only pass data, not the entire event
        callback(e.data)
      }
    })
  }
})
```

---

### **Common Pitfalls**

#### **1. Forgetting to Call start() in Main Process**

```javascript
// BAD - Messages won't be received
port.on('message', handler)
// port.start() is missing!

// GOOD
port.on('message', handler)
port.start()
```

#### **2. Using send() Instead of postMessage()**

```javascript
// BAD - Port won't transfer
event.sender.send('port', port)

// GOOD
event.sender.postMessage('port', null, [port])
```

#### **3. Not Handling Port Closure**

```javascript
// GOOD - Handle closure
port.on('close', () => {
  console.log('Connection closed')
  // Clean up resources
})
```

---

### **Summary**

**MessageChannel enables:**
- Direct renderer-to-renderer communication
- Worker process patterns
- Streaming responses
- Context-isolated communication
- Avoiding main process as middleman

**Key Points:**
- Use `MessageChannelMain` in main process
- Use `MessageChannel` in renderer
- **Only** `postMessage()` can transfer ports
- Main process ports require `.start()`
- Ports can be closed explicitly or by garbage collection
- Electron adds `close` event not present in web standard

---

