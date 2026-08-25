## Overview


### IPC Renderer Fundamentals

The `ipcRenderer` module enables asynchronous communication from renderer processes to the main process in Electron applications. It's an EventEmitter that provides methods for sending messages, receiving responses, and listening to events from the main process.[1][2][3]

#### Core Concept

**What It Is**
- Part of Electron's Inter-Process Communication (IPC) system[4][1]
- Available only in renderer processes (not main process)[2][1]
- Works in conjunction with `ipcMain` module in the main process[2][4]
- Must be exposed through preload scripts when context isolation is enabled[3][5]

**Security Requirement**
- Never expose `ipcRenderer` directly to the renderer[5][3]
- Always use preload scripts with Context Bridge to expose whitelisted methods[3][5]
- This prevents malicious code from accessing all IPC channels[5]

#### Primary Methods

**ipcRenderer.send(channel, ...args)**
- Sends a one-way asynchronous message to the main process[1][4][2]
- Does not expect a return value[6][4]
- Main process listens with `ipcMain.on()`[4][6]
- Arguments are serialized with Structured Clone Algorithm[1]

**Example - One-Way Communication:**
```javascript
// Preload script
contextBridge.exposeInMainWorld('electronAPI', {
  setTitle: (title) => ipcRenderer.send('set-title', title)
})

// Renderer
window.electronAPI.setTitle('New Title')

// Main process
ipcMain.on('set-title', (event, title) => {
  const webContents = event.sender
  const win = BrowserWindow.fromWebContents(webContents)
  win.setTitle(title)
})
```


**ipcRenderer.invoke(channel, ...args)**
- Sends a message and expects an asynchronous result[7][3][1]
- Returns a Promise that resolves with the response from main process[3][1]
- Main process handles with `ipcMain.handle()`[4][3]
- Recommended for request-response patterns[7][3]

**Example - Two-Way Communication:**
```javascript
// Preload script
contextBridge.exposeInMainWorld('electronAPI', {
  openFile: () => ipcRenderer.invoke('dialog:openFile')
})

// Renderer
const filePath = await window.electronAPI.openFile()

// Main process
ipcMain.handle('dialog:openFile', async () => {
  const { canceled, filePaths } = await dialog.showOpenDialog()
  if (!canceled) {
    return filePaths[0]
  }
})
```


**ipcRenderer.on(channel, listener)**
- Listens for messages from the main process[2][7][1]
- The listener callback receives `(event, ...args)` parameters[2]
- Can be called multiple times for continuous updates[7]
- Used for receiving broadcasts or continuous data streams from main process[7]

**Example - Receiving from Main:**
```javascript
// Preload script
contextBridge.exposeInMainWorld('electronAPI', {
  onUpdateCounter: (callback) => ipcRenderer.on('update-counter', (_event, value) => callback(value))
})

// Renderer
window.electronAPI.onUpdateCounter((value) => {
  console.log(`Counter: ${value}`)
})

// Main process
setInterval(() => {
  mainWindow.webContents.send('update-counter', counter++)
}, 1000)
```


**ipcRenderer.once(channel, listener)**
- Adds a one-time listener for an event[1][2]
- Listener is automatically removed after being invoked once[1][2]
- Useful for single-response scenarios[2]

#### Additional Methods

**ipcRenderer.removeListener(channel, listener)**
- Removes the specified listener from the listener array[1][2]

**ipcRenderer.removeAllListeners(channel)**
- Removes all listeners for the specified channel[2]

**ipcRenderer.sendSync(channel, ...args)** (Deprecated)
- Sends a synchronous message to the main process and blocks until reply[2]
- **Not recommended** - blocks the renderer process[7]
- Use `invoke()` instead for better performance[7]

**ipcRenderer.postMessage(channel, message, [transfer])**
- Sends a message with optional MessagePort transfer[1]
- Used for advanced scenarios involving MessageChannel[1]

#### Communication Patterns

**Pattern 1: One-Way (send + on)**
Use when you don't need a response:[6][4]
- Renderer sends: `ipcRenderer.send()`
- Main receives: `ipcMain.on()`
- Use cases: Triggering actions, sending notifications, updating state[6]

**Pattern 2: Two-Way (invoke + handle)**
Use when you need a response:[4][7]
- Renderer sends: `ipcRenderer.invoke()`
- Main handles: `ipcMain.handle()`
- Returns Promise with result
- Use cases: File dialogs, database queries, API calls[5][7]

**Pattern 3: Main to Renderer (webContents.send + on)**
Main process broadcasts to renderer:[4][7]
- Main sends: `win.webContents.send()`
- Renderer receives: `ipcRenderer.on()`
- Use cases: Progress updates, real-time data, notifications[7]

#### send() vs invoke()

**Key Differences**:[7]

| Feature | send() + on() | invoke() + handle() |
|---------|--------------|---------------------|
| Response | No direct return | Returns Promise |
| Main handler | ipcMain.on() | ipcMain.handle() |
| Multiple calls | Can receive multiple times | One request, one response |
| Use case | Continuous updates | Single request-response |
| Examples | Progress bar, live data | File operations, queries |

#### Security Best Practices

**Secure Exposure Pattern:**
```javascript
// ❌ INSECURE - Don't do this
contextBridge.exposeInMainWorld('electron', {
  ipcRenderer: require('electron').ipcRenderer
})

// ✅ SECURE - Whitelist specific channels
contextBridge.exposeInMainWorld('electronAPI', {
  openFile: () => ipcRenderer.invoke('dialog:openFile'),
  saveFile: (data) => ipcRenderer.invoke('dialog:saveFile', data)
})
```


**Prevent Callback Leakage:**
```javascript
// Don't pass event to callback - it contains ipcRenderer reference
contextBridge.exposeInMainWorld('electronAPI', {
  onUpdate: (callback) => ipcRenderer.on('update', (_event, value) => callback(value))
})
```


#### Accessing ipcRenderer

**Modern Approach (Context Isolation Enabled):**
Must be exposed via preload script using Context Bridge.[8][3][5]

**Legacy Approach (Not Recommended):**
Direct access in renderer if `nodeIntegration: true` (security risk).[8]

The ipcRenderer module is the foundation for secure, efficient communication between isolated renderer processes and the privileged main process in Electron applications.[4][1]

Sources
[1] ipcRenderer https://www.electronjs.org/docs/latest/api/ipc-renderer
[2] ipcRenderer | electron https://freesoftwaredevlopment.github.io/electron/docs/api/ipc-renderer.html
[3] electron/docs/api/ipc-renderer.md at main · electron/electron https://github.com/electron/electron/blob/main/docs/api/ipc-renderer.md
[4] Inter-Process Communication https://www.electronjs.org/docs/latest/tutorial/ipc
[5] Electron – 3 Methods for Inter Process Communications (IPC) https://www.intertech.com/electron-3-methods-for-inter-process-communications-ipc/
[6] Electron: Communicate from Renderer to Main Process https://fyfirman.com/blog/communicate-from-renderer-to-main-process
[7] What is the difference between IPC send / on and invoke / handle in electron? https://stackoverflow.com/questions/59889729/what-is-the-difference-between-ipc-send-on-and-invoke-handle-in-electron/59889863
[8] Using the electron ipcRenderer from a front-end javascript file https://stackoverflow.com/questions/62433323/using-the-electron-ipcrenderer-from-a-front-end-javascript-file
[9] [Electron] IPC には新しい ipcRenderer.invoke() メソッドを ... https://qiita.com/jrsyo/items/abe19dff2d950132d9cd
[10] Bridging the Gap: Communicating Between the "Browser ... https://scott.willeke.com/bridging-the-gap-communicating-between-the-browser-renderer-and-the-main-process-in-an-electron-app/

---

### IPC Main Fundamentals

The `ipcMain` module handles asynchronous and synchronous communication from renderer processes to the main process in Electron applications. It's an Event Emitter that runs exclusively in the main process and provides methods for receiving messages and sending responses.[1][2][3]

#### Core Concept

**What It Is**
- IPC (Inter-Process Communication) module for the main process[2][3][1]
- Works in conjunction with `ipcRenderer` in renderer processes[4][5]
- Acts as a messaging bridge between isolated processes[5]
- Extends Node.js EventEmitter class[3][6]

**Purpose**
- Receives messages sent from renderer processes[2][3]
- Handles requests for main process operations (file system, native APIs, etc.)[4]
- Sends responses back to renderer processes[5][4]
- Broadcasts updates to one or more renderer processes[5]

#### Primary Methods

**ipcMain.on(channel, listener)**
- Listens for one-way messages from renderer processes[7][1][4]
- Used with `ipcRenderer.send()` from the renderer[4]
- Does not return a value to the renderer[4]
- Listener receives `(event, ...args)` parameters[1]
- Can respond using `event.sender.send()`[8]

**Example - One-Way Communication:**
```javascript
// Main process
const { ipcMain } = require('electron')

ipcMain.on('set-title', (event, title) => {
  const webContents = event.sender
  const win = BrowserWindow.fromWebContents(webContents)
  win.setTitle(title)
})
```


**ipcMain.handle(channel, listener)**
- Handles invoke-able IPC requests that expect a response[3][1]
- Used with `ipcRenderer.invoke()` from the renderer[1][4]
- Listener must return a value or Promise[3][1]
- Returns result automatically to the calling renderer[1]
- Recommended for request-response patterns[4]

**Example - Two-Way Communication:**
```javascript
// Main process
const { ipcMain, dialog } = require('electron')

ipcMain.handle('dialog:openFile', async () => {
  const { canceled, filePaths } = await dialog.showOpenDialog()
  if (!canceled) {
    return filePaths[0]
  }
})
```


**ipcMain.handleOnce(channel, listener)**
- Handles a single invoke-able IPC message, then removes the listener[3]
- Similar to `ipcMain.handle()` but automatically unregisters after first call[3]
- Useful for one-time operations[3]

**ipcMain.removeHandler(channel)**
- Removes any handler for the specified channel[1][3]
- Important for cleanup when handlers are no longer needed[3]

**ipcMain.removeListener(channel, listener)**
- Removes the specified listener from the listener array[1]

**ipcMain.removeAllListeners([channel])**
- Removes all listeners for the specified channel, or all listeners if no channel specified[1]

#### Event Object Properties

When handlers receive events, the event object contains useful properties:[1]

**event.processId**
- Internal ID of the renderer process that sent the message[1]

**event.frameId**
- ID of the renderer frame that sent the message[1]

**event.sender**
- Returns the `webContents` that sent the message[8][1]
- Use to send replies: `event.sender.send('reply-channel', data)`[8]

**event.senderFrame**
- The frame that sent the message[1]

**event.ports** (for postMessage)
- Array of MessagePorts sent with the message[1]

**event.returnValue** (synchronous only)
- Set this to send synchronous reply[8]

#### Communication Patterns

**Pattern 1: One-Way (send → on)**
Renderer sends message without expecting a response:[7][4]

```javascript
// Renderer (via preload)
ipcRenderer.send('set-title', 'New Title')

// Main
ipcMain.on('set-title', (event, title) => {
  // Process the message
  console.log(title)
})
```


**Pattern 2: Two-Way (invoke → handle)**
Renderer sends request and awaits response:[4]

```javascript
// Renderer (via preload)
const result = await ipcRenderer.invoke('perform-action', data)

// Main
ipcMain.handle('perform-action', async (event, data) => {
  // Process and return result
  return { success: true, result: processedData }
})
```


**Pattern 3: Main to Renderer**
Main process broadcasts to renderer:[5][8]

```javascript
// Main process
mainWindow.webContents.send('update-counter', newValue)

// Renderer listens with ipcRenderer.on('update-counter', callback)
```


#### Synchronous vs Asynchronous

**Asynchronous (Recommended)**
- Use `ipcMain.on()` for one-way async messages[2]
- Use `ipcMain.handle()` for request-response async messages[1]
- Non-blocking, better performance[2]

**Synchronous (Deprecated)**
- Use `ipcMain.on()` with `event.returnValue`[8]
- Blocks the renderer process until response is received[2]
- Not recommended - use `invoke/handle` pattern instead[4]

**Example - Synchronous (Legacy):**
```javascript
// Main
ipcMain.on('synchronous-message', (event, arg) => {
  console.log(arg) // prints "ping"
  event.returnValue = 'pong'
})

// Renderer
const result = ipcRenderer.sendSync('synchronous-message', 'ping')
```


#### Error Handling

**handle() Error Behavior**
- Errors thrown in `handle()` are serialized and sent to renderer[3]
- Only the `message` property from the original error is provided[3]
- Stack traces and other error properties are not transmitted[3]
- Renderer receives the error in rejected Promise[3]

**Example:**
```javascript
// Main
ipcMain.handle('risky-operation', async () => {
  throw new Error('Something went wrong')
})

// Renderer
try {
  await ipcRenderer.invoke('risky-operation')
} catch (error) {
  console.error(error.message) // "Something went wrong"
  // Stack trace not available
}
```

#### Best Practices

**Channel Naming**
- Use descriptive, namespaced channel names[4]
- Examples: `'dialog:openFile'`, `'window:minimize'`, `'data:fetch'`[4]
- Prevents channel name collisions[4]

**Security**
- Validate all data received from renderer processes[3]
- Don't trust renderer input - it could be compromised[3]
- Whitelist allowed channels in preload scripts[4]

**Memory Management**
- Remove listeners when no longer needed[1][3]
- Use `handleOnce()` for one-time operations[3]
- Clean up handlers when windows are closed[3]

The `ipcMain` module is the foundation for secure, bidirectional communication between the main process and renderer processes in Electron applications.[5][2][1]

Sources
[1] ipcMain https://www.electronjs.org/docs/latest/api/ipc-main
[2] Electron - Inter Process Communication https://www.tutorialspoint.com/electron/electron_inter_process_communication.htm
[3] ipcMain - Electron https://electronjs.org/docs/latest/api/ipc-main
[4] Inter-Process Communication https://www.electronjs.org/docs/latest/tutorial/ipc
[5] IPC in Electron - Ray https://myray.app/blog/ipc-in-electron
[6] Communicating Between The... https://www.nickolinger.com/blog/electron-interprocess-communication/
[7] Inter-Process Communication | Electron http://electronproject.org/ipc.html
[8] ipcMain | Electron - GitHub Pages https://zeke.github.io/electron.atom.io/docs/api/ipc-main/
[9] ipcMain - Electron https://docs.w3cub.com/electron/api/ipc-main
[10] electron/docs/api/ipc-main.md at main · electron/electron https://github.com/electron/electron/blob/main/docs/api/ipc-main.md


---

### ipcRenderer.send() vs ipcRenderer.invoke()

The key difference between `ipcRenderer.send()` and `ipcRenderer.invoke()` is that `send()` returns void (no return value) while `invoke()` returns a Promise that resolves with the response from the main process.[1][7]

#### ipcRenderer.send()

**Characteristics**
- Sends one-way asynchronous messages to the main process[2][6]
- Returns `void` - does not expect or wait for a response[1]
- Used with `ipcMain.on()` in the main process[4][2]
- Non-blocking fire-and-forget communication[2]

**When to Use**
- Triggering actions that don't need a return value[1]
- Sending notifications or updates to main process[1]
- Starting operations where you don't need confirmation[2]
- Async updates over time (countdown, progress bar, data updates)[1]

**Example:**
```javascript
// Renderer (via preload)
ipcRenderer.send('set-title', 'New Title')

// Main process
ipcMain.on('set-title', (event, title) => {
  const webContents = event.sender
  const win = BrowserWindow.fromWebContents(webContents)
  win.setTitle(title)
})
```


**Getting a Response (Manual Pattern)**
If you need a response with `send()`, you must manually set up a return channel:[2]

```javascript
// Renderer
ipcRenderer.send('asynchronous-message', 'ping')
ipcRenderer.on('asynchronous-reply', (_event, arg) => {
  console.log(arg) // prints "pong"
})

// Main
ipcMain.on('asynchronous-message', (event, arg) => {
  event.sender.send('asynchronous-reply', 'pong')
})
```


**Downsides of Manual Response Pattern:**
- No obvious way to pair the reply message to the original message[2]
- For frequent messages, requires additional code to track each call and response[2]
- More complex and error-prone than `invoke()`[2]

#### ipcRenderer.invoke()

**Characteristics**
- Sends message and expects an asynchronous result[6][7]
- Returns `Promise<any>` that resolves with the main process response[6][1]
- Used with `ipcMain.handle()` in the main process[4][2]
- Supports async/await syntax[8][1]
- Throws error if handler doesn't exist[1]

**When to Use**
- Request-response patterns where you need a return value[7][1]
- Getting data from main process (file paths, settings, database queries)[1]
- Operations that need confirmation or results[2]
- Single request-response interactions[1]

**Example:**
```javascript
// Renderer (via preload)
const filePath = await ipcRenderer.invoke('dialog:openFile')

// Main process
ipcMain.handle('dialog:openFile', async () => {
  const { canceled, filePaths } = await dialog.showOpenDialog()
  if (!canceled) {
    return filePaths[0]
  }
})
```


**Benefits:**
- Cleaner, more ergonomic API for request-response[1]
- Response value returned directly as Promise[2][1]
- Works seamlessly with async/await[8][1]
- Automatic error handling - errors thrown in handler reject the Promise[6]

#### Comparison Table

| Feature | send() + on() | invoke() + handle() |
|---------|---------------|---------------------|
| Return value | void (none) | Promise<any> |
| Main handler | ipcMain.on() | ipcMain.handle() |
| Response | Manual via event.sender.send() | Automatic return value |
| Communication type | One-way (or manual two-way) | Two-way built-in |
| Use async/await | No | Yes |
| Error handling | Manual | Automatic via Promise rejection |
| Error when missing handler | No | Yes, throws error |
| Best for | Fire-and-forget, continuous updates | Request-response, single operations |

[7][1][2]

#### send() with Multiple Responses

**Unique Capability of send()/on()**
The renderer can receive data multiple times from the same channel using `send()` + `on()` as long as the main process is running:[1]

```javascript
// Renderer
ipcRenderer.on('progress-update', (_event, percent) => {
  console.log(`Progress: ${percent}%`)
})

// Main - sends multiple updates
for (let i = 0; i <= 100; i += 10) {
  mainWindow.webContents.send('progress-update', i)
  await delay(500)
}
```


This pattern is ideal for:
- Progress bars and loading indicators[1]
- Real-time data updates[1]
- Countdown timers[1]
- Live streaming data[1]

#### invoke() Limitations

**Single Response Only**
`invoke()` is designed for one request, one response. It cannot handle continuous updates like `send()` can.[1]

**No Main-to-Renderer invoke()**
There's no equivalent for `ipcRenderer.invoke()` for main-to-renderer IPC. If the main process needs a response from the renderer, use `send()` + `on()` pattern manually.[2]

#### Which to Choose?

**Use send():**
- When you don't need a response[2][1]
- For continuous/repeated updates from main to renderer[1]
- When implementing custom timeout logic[1]

**Use invoke():**
- When you need a single response value[2][1]
- For cleaner async/await code[8][1]
- When you want automatic error handling[6]
- For most request-response scenarios[2]

The `invoke()`/`handle()` API was introduced to improve ergonomics around the existing `send()`/`on()` pattern for returning values to the sender. Both approaches are functionally capable of the same things, but `invoke()` provides better developer experience for request-response patterns.[1]

Sources
[1] What is the difference between IPC send / on and invoke / handle in ... https://stackoverflow.com/questions/59889729/what-is-the-difference-between-ipc-send-on-and-invoke-handle-in-electron
[2] Inter-Process Communication - Electron https://electronjs.org/docs/latest/tutorial/ipc
[3] what's the difference with invoke handle in Electron v7 #25 - GitHub https://github.com/sindresorhus/electron-better-ipc/issues/25
[4] Electron – 3 Methods for Inter Process Communications (IPC) https://www.intertech.com/electron-3-methods-for-inter-process-communications-ipc/
[5] What is the difference between IPC send / on and invoke / handle in electron? https://stackoverflow.com/questions/59889729/what-is-the-difference-between-ipc-send-on-and-invoke-handle-in-electron/59889863
[6] ipcRenderer - Electron https://electronjs.org/docs/latest/api/ipc-renderer
[7] IPC in Electron - Ray https://myray.app/blog/ipc-in-electron
[8] Electron JS Tutorial: ipcRenderer - All communication methods of ... https://www.youtube.com/watch?v=W7X177Af8Ls
[9] invoke - imodeljs-common - iTwin.js https://www.itwinjs.org/v2/reference/imodeljs-common/ipcsocket/ipcsocketfrontend/invoke/
[10] Best way to deal with ipc : r/electronjs - Reddit https://www.reddit.com/r/electronjs/comments/19adtpv/best_way_to_deal_with_ipc/


---

### ipcMain.on() vs ipcMain.handle()

The main difference between `ipcMain.on()` and `ipcMain.handle()` is how they return values: `on()` requires manually sending responses back through the event object, while `handle()` automatically returns values via Promise resolution.[1][5]

#### ipcMain.on()

**Characteristics**
- Listens for messages sent via `ipcRenderer.send()`[2][3]
- Does not automatically return values to the renderer[2]
- Can be used for both one-way and two-way communication[5]
- Supports synchronous communication via `event.returnValue`[5]
- Part of the traditional send/on IPC pattern[1]

**One-Way Communication (No Response):**
```javascript
// Main process
ipcMain.on('set-title', (event, title) => {
  const win = BrowserWindow.fromWebContents(event.sender)
  win.setTitle(title)
  // No response sent back
})
```


**Two-Way Asynchronous (Manual Response):**
```javascript
// Main process
ipcMain.on('asyncPing', (event, args) => {
  console.log("asyncPing received")
  // Manually send response back
  event.sender.send('asyncPong', 'response data')
})
```


**Synchronous Communication (Deprecated):**
```javascript
// Main process
ipcMain.on('syncPing', (event, args) => {
  console.log('syncPing received')
  // Set return value for synchronous communication
  event.returnValue = 'syncPong'
})
```


**Downsides:**
- Manual response requires setting up separate channels[1]
- No obvious way to pair reply messages with original requests[3]
- More code and complexity for request-response patterns[3]
- No built-in error handling[2]

#### ipcMain.handle()

**Characteristics**
- Handles requests sent via `ipcRenderer.invoke()`[3][2]
- Returns values automatically through Promise resolution[2]
- Always asynchronous, supports async/await[5][2]
- Throws error if handler doesn't exist when invoked[1]
- Part of the modern invoke/handle IPC pattern[1]

**Basic Usage:**
```javascript
// Main process
ipcMain.handle('handlePing', (event, args) => {
  console.log('handlePing received')
  // Simply return the value
  return 'handlePong'
})

// Renderer (via preload)
const response = await ipcRenderer.invoke('handlePing')
console.log(response) // 'handlePong'
```


**Async Operations:**
```javascript
// Main process
ipcMain.handle('dialog:openFile', async () => {
  const { canceled, filePaths } = await dialog.showOpenDialog()
  if (!canceled) {
    return filePaths[0]
  }
})

// Renderer (via preload)
const filePath = await ipcRenderer.invoke('dialog:openFile')
```


**Error Handling:**
```javascript
// Main process
ipcMain.handle('handlePingWithError', () => {
  throw new Error("Something Went Wrong")
})

// Renderer (via preload)
try {
  await ipcRenderer.invoke('handlePingWithError')
} catch (error) {
  console.error(error.message) // "Something Went Wrong"
}
```


**Note:** Errors are serialized - only the `message` property is sent to renderer, not the full stack trace.[2]

**Benefits:**
- Cleaner API similar to Express.js route handlers[5]
- Automatic Promise-based return mechanism[2]
- Works seamlessly with async/await[5][1]
- Built-in error handling via Promise rejection[5]
- Easier to reason about request-response flow[1]

#### Comparison Table

| Feature | ipcMain.on() | ipcMain.handle() |
|---------|--------------|------------------|
| Triggered by | ipcRenderer.send() | ipcRenderer.invoke() |
| Return value | Manual via event.sender.send() | Automatic via return statement |
| Response type | void (manual response) | Promise<any> |
| Async support | Manual async handling | Built-in async/await |
| Error handling | Manual | Automatic via Promise rejection |
| Synchronous support | Yes (event.returnValue) | No (always async) |
| Use case | Fire-and-forget, continuous updates | Request-response, single operations |
| Channel isolation | Shares EventEmitter namespace | Separate _invokeHandlers map |

[4][1][2][5]

#### Channel Name Isolation

You can safely register the same channel name for both `ipcMain.on()` and `ipcMain.handle()`:[4]

```javascript
// Both can coexist with the same channel name
ipcMain.handle('test', async (event, args) => {
  let result = await somePromise()
  return result
})

ipcMain.on('test', async (event, args) => {
  event.returnValue = await somePromise()
})
```


They maintain separate internal storage:
- `ipcMain.on()` uses Node.js EventEmitter's internal event structure[4]
- `ipcMain.handle()` stores handlers in a separate `_invokeHandlers` Map[4]
- Triggered by different renderer methods: `send/sendSync` vs `invoke`[4]

#### When to Use Each

**Use ipcMain.on():**
- One-way communication (no response needed)[3]
- Multiple responses over time from main to renderer[1]
- Custom timeout logic[1]
- Broadcasting updates to renderer processes[1]
- Legacy codebases using send/on pattern[1]

**Use ipcMain.handle():**
- Request-response patterns requiring a return value[3][5]
- Single operation that returns data[1]
- Cleaner async/await code[5][1]
- Automatic error handling needs[5]
- Modern Electron applications (recommended approach)[1]

#### Purpose and Evolution

The `invoke()`/`handle()` API was introduced as a new ergonomic improvement over the existing `send()`/`on()` pattern specifically for returning values to the sender. While both approaches are functionally capable of achieving the same results, `handle()` provides significantly better developer experience for request-response scenarios through automatic Promise handling and cleaner syntax.[5][1]

Sources
[1] What is the difference between IPC send / on and invoke / handle in electron? https://stackoverflow.com/questions/59889729/what-is-the-difference-between-ipc-send-on-and-invoke-handle-in-electron/59889863
[2] ipcMain https://www.electronjs.org/docs/latest/api/ipc-main
[3] Inter-Process Communication https://www.electronjs.org/docs/latest/tutorial/ipc
[4] Electron: Can same channel name use for ipcMain.on and ipcMain.handle? https://stackoverflow.com/questions/64881837/electron-can-same-channel-name-use-for-ipcmain-on-and-ipcmain-handle
[5] Electron – 3 Methods for Inter Process Communications (IPC) https://www.intertech.com/electron-3-methods-for-inter-process-communications-ipc/
[6] Inter-Process Communication (IPC) in ElectronJS https://www.geeksforgeeks.org/node-js/inter-process-communication-ipc-in-electronjs/
[7] Best way to deal with ipc https://www.reddit.com/r/electronjs/comments/19adtpv/best_way_to_deal_with_ipc/
[8] Simplifying IPC in Electron https://texts.blog/2022/04/20/simplifying-ipc-in-electron/
[9] main -> renderer communication - Help me understand the syntax, please. https://www.reddit.com/r/electronjs/comments/13mcc3v/main_renderer_communication_help_me_understand/
[10] ipcMain - Electron http://electronproject.org/ipc-main.html

---

### Sending Data from Renderer to Main

Sending data from renderer to main process in Electron requires using the IPC (Inter-Process Communication) system through preload scripts and the Context Bridge API. The renderer cannot directly access main process functionality due to security isolation.[1][2]

#### Setup Requirements

**1. Configure BrowserWindow with Preload Script**
```javascript
// main.js
const mainWindow = new BrowserWindow({
  webPreferences: {
    preload: path.join(__dirname, 'preload.js'),
    contextIsolation: true,
    nodeIntegration: false
  }
});
```


**2. Create Preload Script to Expose IPC**
```javascript
// preload.js
const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  sendData: (data) => ipcRenderer.send('data-from-renderer', data),
  invokeAction: (data) => ipcRenderer.invoke('action-from-renderer', data)
});
```


#### Method 1: One-Way Communication (send/on)

**Use Case:** Sending data without expecting a return value.[1]

**Renderer Process:**
```javascript
// renderer.js
const start = () => {
  window.electronAPI.sendData({
    active: true,
    startedAt: new Date()
  });
};
```


**Main Process:**
```javascript
// main.js
const { ipcMain } = require('electron');

ipcMain.on('data-from-renderer', (event, data) => {
  console.log('Received from renderer:', data);
  // Process the data
  // No automatic response
});
```


#### Method 2: Request-Response Communication (invoke/handle)

**Use Case:** Sending data and expecting a response.[2]

**Preload Script:**
```javascript
// preload.js
contextBridge.exposeInMainWorld('api', {
  getData: (key) => ipcRenderer.invoke('get-data', key),
  setData: (key, value) => ipcRenderer.invoke('set-data', key, value)
});
```


**Renderer Process:**
```javascript
// renderer.js
async function saveData() {
  const result = await window.api.setData('username', 'John Doe');
  console.log(result); // Response from main
}

async function loadData() {
  const value = await window.api.getData('username');
  console.log(value); // 'John Doe'
}
```


**Main Process:**
```javascript
// main.js
ipcMain.handle('get-data', (event, key) => {
  return store.get(key); // Return data
});

ipcMain.handle('set-data', (event, key, value) => {
  store.set(key, value);
  return { success: true };
});
```


#### Data Serialization

**Supported Data Types**
Electron's IPC uses the HTML standard **Structured Clone Algorithm** to serialize objects. Only certain types can be passed through IPC channels:[3]

**✅ Serializable Types:**
- Primitives: string, number, boolean, null, undefined
- Arrays (containing serializable types)
- Plain objects (with serializable properties)
- Date objects
- RegExp objects
- Blob, File, FileList
- ArrayBuffer, TypedArray
- Map, Set
- Buffers[4]

**❌ Not Serializable:**
- DOM objects (Element, Location, DOMMatrix)
- Node.js objects backed by C++ classes (process.env, Stream members)
- Electron objects backed by C++ classes (WebContents, BrowserWindow, WebFrame)
- Functions
- Symbols
- Custom class instances with prototypes[3]

#### Passing Complex Data Structures

**Arrays of Objects:**
```javascript
// Renderer
const postDetails = [
  { id: 1, score: 100, title: 'Post 1' },
  { id: 2, score: 200, title: 'Post 2' }
];

window.electronAPI.sendData(postDetails);
```


**Note:** Arrays of objects are serializable, but if serialization errors occur, you can manually stringify:[4]
```javascript
// If automatic serialization fails
const serialized = JSON.stringify(postDetails);
window.electronAPI.sendData(serialized);

// Main process
ipcMain.on('data-from-renderer', (event, data) => {
  const parsed = JSON.parse(data);
});
```


#### Multiple Arguments

You can send multiple arguments in a single IPC call:[5]

**Renderer:**
```javascript
ipcRenderer.send('hello', ['one', 'two', 'three']);
```

**Main:**
```javascript
ipcMain.on('hello', (e, data) => {
  console.log(data); // ['one', 'two', 'three']
  e.reply('nice', data);
});
```


#### Complete Example: Productivity Tracker

**Preload Script:**
```javascript
const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('productivity', {
  start: (data) => ipcRenderer.send('productivity-changed', data),
  stop: (data) => ipcRenderer.send('productivity-changed', data)
});
```


**Renderer:**
```javascript
const start = () => {
  window.productivity.start({
    active: true,
    startedAt: new Date()
  });
};

const stop = () => {
  window.productivity.stop({
    active: false
  });
};
```


**Main Process:**
```javascript
ipcMain.on('productivity-changed', (event, data) => {
  if (data.active) {
    tray.setImage(activeIcon);
  } else {
    tray.setImage(inactiveIcon);
  }
});
```


#### Best Practices

**1. Never Expose Full IPC Modules**
```javascript
// ❌ INSECURE
contextBridge.exposeInMainWorld('electron', {
  ipcRenderer: require('electron').ipcRenderer
});

// ✅ SECURE - Whitelist specific functions
contextBridge.exposeInMainWorld('api', {
  sendData: (data) => ipcRenderer.send('channel', data)
});
```

**2. Validate Data in Main Process**
Always validate and sanitize data received from renderer:[2]
```javascript
ipcMain.handle('set-data', (event, key, value) => {
  if (typeof key !== 'string' || !value) {
    throw new Error('Invalid parameters');
  }
  store.set(key, value);
  return { success: true };
});
```

**3. Use Descriptive Channel Names**
Use namespaced channel names to avoid collisions:[2]
```javascript
// Good examples
'data:fetch'
'user:update'
'file:save'
```

**4. Handle Errors Gracefully**
```javascript
// Renderer
try {
  const result = await window.api.saveData(data);
} catch (error) {
  console.error('Failed to save:', error.message);
}
```

The key to secure data transfer from renderer to main is using the preload script with Context Bridge to create a controlled, whitelisted API surface.[1][2]

Sources
[1] Electron: Communicate from Renderer to Main Process https://fyfirman.com/blog/communicate-from-renderer-to-main-process
[2] Electron: Executing Main Process Code from Renderer https://ncoughlin.com/posts/electron-executing-main-process-code-from-renderer
[3] Inter-Process Communication - Electron https://electronjs.org/docs/latest/tutorial/ipc
[4] Can Electron IPC Handle Arrays of Objects? Encountering ... - Reddit https://www.reddit.com/r/electronjs/comments/1ag3dub/can_electron_ipc_handle_arrays_of_objects/
[5] How can we send messages from the main process to renderer process in Electron https://stackoverflow.com/questions/52124675/how-can-we-send-messages-from-the-main-process-to-renderer-process-in-electron
[6] main -> renderer communication - Help me understand the syntax, please. https://www.reddit.com/r/electronjs/comments/13mcc3v/main_renderer_communication_help_me_understand/
[7] Inter-Process Communication https://www.electronjs.org/docs/latest/tutorial/ipc
[8] ipcRenderer https://www.electronjs.org/docs/latest/api/ipc-renderer
[9] Passing data from main to renderer (electron-js) - Stack Overflow https://stackoverflow.com/questions/73128159/passing-data-from-main-to-renderer-electron-js
[10] How to send information from one window to another in Electron ... https://ourcodeworld.com/articles/read/536/how-to-send-information-from-one-window-to-another-in-electron-framework

---

### Sending Data from Main to Renderer

The main process sends data to renderer processes using the `webContents.send()` method, which is part of the webContents object associated with each BrowserWindow. The renderer receives messages through listeners set up in preload scripts.[1][2][3][4]

#### Using webContents.send()

**Basic Syntax**
`webContents.send(channel, ...args)` sends an asynchronous message to the renderer process via a specified channel.[3][4]

**Main Process - Sending:**
```javascript
const { BrowserWindow } = require('electron');

const mainWindow = new BrowserWindow({ width: 800, height: 600 });

// Send data to renderer
mainWindow.webContents.send('update-counter', 42);
```


**Preload Script - Setting Up Receiver:**
```javascript
const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('electronAPI', {
  onUpdateCounter: (callback) => {
    ipcRenderer.on('update-counter', (_event, value) => callback(value));
  }
});
```


**Renderer Process - Receiving:**
```javascript
window.electronAPI.onUpdateCounter((value) => {
  console.log(`Counter value: ${value}`);
  document.getElementById('counter').textContent = value;
});
```

#### Complete Example: Settings Configuration

**Main Process:**
```javascript
const { app, BrowserWindow } = require('electron');

let mainWindow;

app.whenReady().then(() => {
  mainWindow = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true
    }
  });

  mainWindow.loadFile('index.html');

  // Send settings after page loads
  mainWindow.webContents.on('did-finish-load', () => {
    const settings = {
      theme: 'dark',
      language: 'en',
      fontSize: 14
    };
    mainWindow.webContents.send('sendSettings', settings);
  });
});
```


**Preload Script:**
```javascript
const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('bridge', {
  receiveSettings: (callback) => {
    ipcRenderer.on('sendSettings', (_event, settings) => {
      callback(settings);
    });
  }
});
```


**Renderer:**
```javascript
window.bridge.receiveSettings((settings) => {
  console.log('Received settings:', settings);
  applySettings(settings);
});
```


#### Timing Considerations

**Wait for Page Load**
Always send data after the page has finished loading to ensure the renderer is ready to receive:[3]

```javascript
mainWindow.webContents.on('did-finish-load', () => {
  mainWindow.webContents.send('ping', 'whoooooooh!');
});
```


**Common Events for Timing:**
- `did-finish-load` - Page and resources finished loading
- `dom-ready` - DOM is ready but resources may still be loading
- `ready-to-show` - Window is ready to be displayed

#### Broadcasting to Multiple Windows

**Sending to Specific Window:**
```javascript
const win1 = new BrowserWindow({ /*...*/ });
const win2 = new BrowserWindow({ /*...*/ });

// Send only to win1
win1.webContents.send('message', 'Hello Window 1');

// Send only to win2
win2.webContents.send('message', 'Hello Window 2');
```


**Sending to All Windows:**
```javascript
const { BrowserWindow } = require('electron');

function broadcastToAll(channel, data) {
  BrowserWindow.getAllWindows().forEach((window) => {
    window.webContents.send(channel, data);
  });
}

broadcastToAll('update-data', { value: 100 });
```


#### Two-Way Communication Pattern

**Main Initiates, Renderer Responds:**
```javascript
// Main process
ipcMain.on('request-data', (event) => {
  // Send data back to the specific renderer that requested it
  event.sender.send('data-response', { result: 'some data' });
});

// Or use event.reply() as a shorthand
ipcMain.on('request-data', (event) => {
  event.reply('data-response', { result: 'some data' });
});
```


**Preload:**
```javascript
contextBridge.exposeInMainWorld('api', {
  requestData: () => ipcRenderer.send('request-data'),
  onDataResponse: (callback) => {
    ipcRenderer.on('data-response', (_event, data) => callback(data));
  }
});
```

**Renderer:**
```javascript
// Request data
window.api.requestData();

// Listen for response
window.api.onDataResponse((data) => {
  console.log('Received:', data);
});
```

#### Alternative: executeJavaScript()

**Direct Code Execution**
You can execute JavaScript directly in the renderer context:[2]

```javascript
win.webContents.on('did-finish-load', () => {
  win.webContents.executeJavaScript("console.log('hello from main');");
  
  // Set variables
  win.webContents.executeJavaScript(`
    window.mySettings = ${JSON.stringify(settings)};
  `);
});
```


**Note:** This approach is less secure than IPC and should be used cautiously. It directly executes code in the renderer without going through the preload security layer.

#### Continuous Updates Pattern

**Real-Time Data Stream:**
```javascript
// Main process - send periodic updates
let counter = 0;
setInterval(() => {
  mainWindow.webContents.send('update-counter', counter++);
}, 1000);
```


**Use Cases:**
- Progress bars
- Real-time notifications
- Live data feeds
- Status updates
- Timer/countdown displays

#### Best Practices

**1. Use Descriptive Channel Names**
```javascript
// Good - namespaced and descriptive
mainWindow.webContents.send('settings:updated', data);
mainWindow.webContents.send('download:progress', percentage);
mainWindow.webContents.send('user:login-status', status);
```

**2. Always Use Preload Scripts**
Never expose `ipcRenderer` directly to the renderer:[2]
```javascript
// ✅ SECURE - Whitelist in preload
contextBridge.exposeInMainWorld('api', {
  onUpdate: (callback) => ipcRenderer.on('update', (_event, data) => callback(data))
});
```

**3. Remove Event Listeners**
Clean up listeners when components unmount or windows close:
```javascript
// Renderer cleanup
const unsubscribe = () => {
  window.removeEventListener('beforeunload', cleanup);
};
```

**4. Validate Data**
Even data from main process should be validated in the renderer to prevent bugs:
```javascript
window.api.onSettings((settings) => {
  if (!settings || typeof settings !== 'object') {
    console.error('Invalid settings received');
    return;
  }
  applySettings(settings);
});
```

The key to main-to-renderer communication is using `webContents.send()` from the main process and setting up secure listeners through preload scripts using Context Bridge.[1][2][3]

Sources
[1] How can we send messages from the main process to renderer process in Electron https://stackoverflow.com/questions/52124675/how-can-we-send-messages-from-the-main-process-to-renderer-process-in-electron
[2] Passing data from main to renderer (electron-js) https://stackoverflow.com/questions/73128159/passing-data-from-main-to-renderer-electron-js
[3] webContents | electron - GitHub Pages https://freesoftwaredevlopment.github.io/electron/docs/api/web-contents.html
[4] webContents | Electron https://www.electronjs.org/docs/latest/api/web-contents
[5] Send data from main.js of electronjs app to the client system ... https://dustinpfister.github.io/2022/03/21/electronjs-webcontents-send/
[6] How to send data to an renderer and then get a return value? · Issue #3642 · electron/electron https://github.com/electron/electron/issues/3642
[7] IPC in Electron - Ray https://myray.app/blog/ipc-in-electron
[8] webContents · GitBook http://electron.ebookchain.org/en/api/web-contents.html
[9] Inter-Process Communication (IPC) in ElectronJS https://www.geeksforgeeks.org/node-js/inter-process-communication-ipc-in-electronjs/
[10] webContents | electron-gitbook - xwartz https://xwartz.gitbooks.io/electron-gitbook/content/en/api/web-contents.html

---

### Event Handling and Listeners

Event handling in Electron's IPC system uses the EventEmitter pattern, where listeners are attached to channels to receive messages. Proper management of event listeners is critical to prevent memory leaks and ensure application stability.[1][2][3][4]

#### Adding Event Listeners

**ipcRenderer.on(channel, listener)**
Listens for events on a specific channel:[2]
```javascript
// Preload script
contextBridge.exposeInMainWorld('api', {
  onUpdate: (callback) => {
    ipcRenderer.on('update-data', (_event, data) => {
      callback(data);
    });
  }
});
```

**ipcRenderer.once(channel, listener)**
Adds a one-time listener that automatically removes itself after being invoked:[5][2]
```javascript
// Listener is invoked only once, then removed
ipcRenderer.once('single-event', (_event, data) => {
  console.log('This will only execute once');
});
```

**ipcMain.on(channel, listener)**
Main process listens for events from renderer:[6][7]
```javascript
ipcMain.on('message-from-renderer', (event, data) => {
  console.log('Received:', data);
});
```

**ipcMain.once(channel, listener)**
Main process one-time listener:[7][6]
```javascript
ipcMain.once('init-message', (event, data) => {
  console.log('Initialization complete');
  // Automatically removed after first call
});
```

#### Removing Event Listeners

**removeListener() / off()**
Removes a specific listener from a channel:[1][2]
```javascript
// Store reference to the listener function
const handleUpdate = (event, data) => {
  console.log('Update received:', data);
};

// Add listener
ipcRenderer.on('update', handleUpdate);

// Remove specific listener later
ipcRenderer.removeListener('update', handleUpdate);
// Or use alias:
ipcRenderer.off('update', handleUpdate);
```


**removeAllListeners([channel])**
Removes all listeners from a channel, or all channels if no channel specified:[2][5]
```javascript
// Remove all listeners from specific channel
ipcRenderer.removeAllListeners('update-data');

// Remove all listeners from all channels
ipcRenderer.removeAllListeners();
```


**ipcMain.removeHandler(channel)**
Removes invoke handler from main process:[7]
```javascript
ipcMain.removeHandler('get-data');
```

#### Memory Leak Prevention

**The Problem**
IPC listeners that aren't properly cleaned up cause memory leaks:[3][4][8]
- Each component re-render can add a new listener without removing the old one[8]
- Unregistered listeners accumulate over time[3]
- Memory usage grows indefinitely, especially with frequent IPC calls[4]
- RSS (memory) increases even if heap doesn't show leaks[3]

**Common Memory Leak Pattern:**
```javascript
// ❌ BAD: Creates new listener on each render
function Component() {
  ipcRenderer.on('data-update', handler);
  // Never removed - memory leak!
}
```


**Correct Pattern with Cleanup:**
```javascript
// ✅ GOOD: Remove listener on unmount
function Component() {
  const handler = (event, data) => {
    console.log(data);
  };
  
  ipcRenderer.on('data-update', handler);
  
  // Cleanup function
  return () => {
    ipcRenderer.removeListener('data-update', handler);
  };
}
```


#### React/Framework Integration

**Using useEffect in React:**
```javascript
import { useEffect } from 'react';

function MyComponent() {
  useEffect(() => {
    const handleUpdate = (event, data) => {
      console.log('Received:', data);
    };
    
    // Add listener when component mounts
    ipcRenderer.on('update-data', handleUpdate);
    
    // Remove listener when component unmounts
    return () => {
      ipcRenderer.removeListener('update-data', handleUpdate);
    };
  }, []); // Empty dependency array = runs once on mount
  
  return <div>My Component</div>;
}
```


**Via Context Bridge:**
```javascript
// Preload script
contextBridge.exposeInMainWorld('api', {
  onUpdate: (callback) => {
    ipcRenderer.on('update', (_event, data) => callback(data));
  },
  removeUpdateListener: (callback) => {
    ipcRenderer.removeListener('update', callback);
  }
});

// React component
useEffect(() => {
  const handleUpdate = (data) => {
    setData(data);
  };
  
  window.api.onUpdate(handleUpdate);
  
  return () => {
    window.api.removeUpdateListener(handleUpdate);
  };
}, []);
```

#### Debugging Listener Issues

**Check Listener Count:**
```javascript
// Monitor number of listeners on a channel
const count = ipcRenderer.listenerCount('event-name');
console.log(`Active listeners: ${count}`);
```


**Warning Signs:**
- Increasing listener count on same channel[3]
- Growing RSS memory without heap growth[3]
- Duplicate event handling[1]
- Events firing multiple times per action[1]

#### Common Issues and Solutions

**Issue: Multiple Listeners on Same Channel**
```javascript
// Problem: Listener added multiple times
componentDidMount() {
  ipcRenderer.on('data-bridge', handler); // Added every mount
}
```


**Solution 1: Remove Before Adding:**
```javascript
componentDidMount() {
  // Remove any existing listeners first
  ipcRenderer.removeAllListeners('data-bridge');
  // Then add the listener
  ipcRenderer.on('data-bridge', handler);
}
```


**Solution 2: Use once() for Single Execution:**
```javascript
// Automatically removes after first invocation
ipcRenderer.once('data-bridge', handler);
```

**Issue: removeListener() Not Working**
The listener reference must be exactly the same:[9][1]
```javascript
// ❌ Won't work - different function references
ipcRenderer.on('event', (e, d) => console.log(d));
ipcRenderer.removeListener('event', (e, d) => console.log(d));

// ✅ Works - same reference
const handler = (e, d) => console.log(d);
ipcRenderer.on('event', handler);
ipcRenderer.removeListener('event', handler);
```


**Issue: Memory Leak with webContents.send**
Frequent `webContents.send()` calls with active `ipcRenderer.on()` listeners can cause memory leaks:[4]
```javascript
// Problem occurs when calling send() very frequently (e.g., every 100ms)
mainWindow.webContents.send('update', data);
```

**Solution:** Throttle or debounce frequent updates, and ensure listeners are properly cleaned up.[4]

#### Best Practices

**1. Always Clean Up Listeners**
```javascript
// Store reference for cleanup
const listeners = [];

function addListener(channel, handler) {
  ipcRenderer.on(channel, handler);
  listeners.push({ channel, handler });
}

function cleanup() {
  listeners.forEach(({ channel, handler }) => {
    ipcRenderer.removeListener(channel, handler);
  });
}
```


**2. Use once() for Single Events**
If you only need to handle an event once, use `once()` to avoid manual cleanup:[2]
```javascript
ipcRenderer.once('init-complete', (event, data) => {
  // Automatically removed after execution
});
```

**3. Monitor Memory Usage**
Track RSS and listener counts in development:[3]
```javascript
setInterval(() => {
  console.log('RSS:', process.memoryUsage().rss);
  console.log('Listeners:', ipcRenderer.listenerCount('channel-name'));
}, 5000);
```

**4. Implement Lifecycle Cleanup**
Remove listeners when windows close or components unmount:[3]
```javascript
window.addEventListener('beforeunload', () => {
  ipcRenderer.removeAllListeners();
});
```

Proper event listener management is essential for building stable, memory-efficient Electron applications. Always pair listener registration with cleanup to prevent resource leaks.[4][3]

Sources
[1] How to unregister from ipcRenderer.on event listener? https://stackoverflow.com/questions/57418499/how-to-unregister-from-ipcrenderer-on-event-listener
[2] ipcRenderer - Electron https://electronjs.org/docs/latest/api/ipc-renderer
[3] Debugging and Troubleshooting Common Electron Issues https://blog.openreplay.com/debugging-troubleshooting-electron-issues/
[4] Memory leak when passing IPC events over contextBridge https://github.com/electron/electron/issues/27039
[5] ipcRenderer | electron - GitHub Pages https://freesoftwaredevlopment.github.io/electron/docs/api/ipc-renderer.html
[6] ipcMain · Electron documentation https://tinydew4.gitbooks.io/electron/api/ipc-main.html
[7] ipcMain - Electron https://electronjs.org/docs/latest/api/ipc-main
[8] How to Prevent Event Emitter Memory Leaks in Your ReactJS Application https://www.youtube.com/watch?v=dRToKpcS4Ho
[9] `ipcRenderer.off` does not remove the listener · Issue #45224 - GitHub https://github.com/electron/electron/issues/45224
[10] What best practices for cleaning up event handler references? https://stackoverflow.com/questions/3258064/what-best-practices-for-cleaning-up-event-handler-references


---

### Async/Await Patterns with IPC

Electron's `invoke()`/`handle()` API is specifically designed for async/await patterns, making asynchronous request-response communication ergonomic and Promise-based. This modern approach simplifies handling asynchronous operations between processes.[1][2][3]

#### Basic invoke/handle Pattern

**The invoke() Method**
`ipcRenderer.invoke()` returns a Promise that resolves with the response from the main process:[3][4]
- Must be used inside an async function or with `.then()`[3]
- Waits for response from main process[3]
- Supports async/await syntax natively[2]

**The handle() Method**
`ipcMain.handle()` can be an async function that returns a value:[5][1]
- Automatically handles Promise resolution[1]
- Return value is sent back to renderer[1]
- Errors are automatically caught and rejected[6]

#### Complete Example

**Preload Script:**
```javascript
const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('api', {
  doInvoke: (channel, data) => {
    const validChannels = ['some-channel'];
    if (validChannels.includes(channel)) {
      return ipcRenderer.invoke(channel, data);
    }
  }
});
```


**Main Process:**
```javascript
const { ipcMain } = require('electron');

ipcMain.handle('some-channel', async (event, data) => {
  const result = await doSomeWork(data);
  return result;
});

async function doSomeWork(data) {
  console.log(data); // logs 'test-string'
  // Simulate async operation
  await new Promise(resolve => setTimeout(resolve, 1000));
  return data + 's';
}
```


**Renderer Process (with async/await):**
```javascript
async function handleKeyup() {
  try {
    const response = await window.api.doInvoke('some-channel', 'test-string');
    console.log(response); // logs 'test-strings'
  } catch (error) {
    console.error('Error:', error.message);
  }
}
```


**Renderer Process (with .then()):**
```javascript
window.api.doInvoke('some-channel', 'test-string')
  .then(result => {
    console.log(result); // logs 'test-strings'
  })
  .catch(error => {
    console.error('Error:', error.message);
  });
```


#### Common Pattern: Database Operations

**Main Process:**
```javascript
ipcMain.handle('db:get-user', async (event, userId) => {
  const user = await database.users.findById(userId);
  return user;
});

ipcMain.handle('db:save-user', async (event, userData) => {
  const savedUser = await database.users.create(userData);
  return { success: true, user: savedUser };
});
```

**Renderer:**
```javascript
async function loadUser(userId) {
  const user = await window.api.getUser(userId);
  displayUser(user);
}

async function saveUser(userData) {
  const result = await window.api.saveUser(userData);
  if (result.success) {
    console.log('User saved:', result.user);
  }
}
```

#### Error Handling

**Errors in handle() are Serialized**
Errors thrown in `ipcMain.handle()` are automatically caught and sent to the renderer as rejected Promises:[6]

**Main Process:**
```javascript
ipcMain.handle('risky-operation', async (event, data) => {
  if (!data.valid) {
    throw new Error('Invalid data provided');
  }
  return await performOperation(data);
});
```

**Renderer:**
```javascript
try {
  const result = await window.api.riskyOperation({ valid: false });
} catch (error) {
  console.error(error.message); // 'Invalid data provided'
  // Note: Only error.message is transmitted, not the full stack
}
```


#### Advanced Pattern: Request/Response Architecture

**Type-Safe IPC with Promises:**
```javascript
// Preload script
contextBridge.exposeInMainWorld('api', {
  send: (channel, data) => {
    return new Promise((resolve, reject) => {
      const responseChannel = `${channel}-response`;
      
      // Listen for response once
      ipcRenderer.once(responseChannel, (_event, response) => {
        if (response.error) {
          reject(new Error(response.error));
        } else {
          resolve(response.data);
        }
      });
      
      // Send request
      ipcRenderer.send(channel, data);
    });
  }
});
```


This pattern allows async/await with the traditional `send()`/`on()` pattern.[7]

#### Multiple Async Operations

**Sequential Execution:**
```javascript
async function processMultiple() {
  const user = await window.api.getUser(1);
  const posts = await window.api.getUserPosts(user.id);
  const comments = await window.api.getPostComments(posts[0].id);
  
  return { user, posts, comments };
}
```

**Parallel Execution:**
```javascript
async function loadDashboard() {
  const [user, settings, notifications] = await Promise.all([
    window.api.getUser(),
    window.api.getSettings(),
    window.api.getNotifications()
  ]);
  
  return { user, settings, notifications };
}
```

#### Why invoke/handle Over send/on for Async?

**Benefits of invoke/handle**:[2][1]
1. Built-in Promise support - works seamlessly with async/await
2. Automatic response pairing - no need to manage separate response channels
3. Error handling via Promise rejection
4. Cleaner, more maintainable code
5. Throws error if handler doesn't exist

**send/on limitations for async**:[1]
- No built-in way to pair responses with requests
- Manual channel management for responses
- More complex code for simple request-response
- No automatic error handling

#### When to Use send/on Instead

Use `send()`/`on()` when you need:[2]
- Fire-and-forget messages (no response needed)
- Multiple responses over time (progress updates, streaming data)
- Custom timeout logic
- Broadcasting from main to multiple renderers

#### Timeout Pattern with invoke

**Adding Timeout to invoke:**
```javascript
async function invokeWithTimeout(channel, data, timeoutMs = 5000) {
  return Promise.race([
    window.api.invoke(channel, data),
    new Promise((_, reject) => 
      setTimeout(() => reject(new Error('Request timeout')), timeoutMs)
    )
  ]);
}

// Usage
try {
  const result = await invokeWithTimeout('slow-operation', data, 3000);
} catch (error) {
  console.error('Operation failed or timed out:', error.message);
}
```

#### Best Practices

**1. Always Handle Errors**
```javascript
// ✅ Good
try {
  const result = await window.api.getData();
  processResult(result);
} catch (error) {
  handleError(error);
}

// ❌ Bad - unhandled promise rejection
const result = await window.api.getData();
```

**2. Use Descriptive Channel Names**
```javascript
// Clear intent
await window.api.invoke('user:fetch', userId);
await window.api.invoke('settings:save', settings);
await window.api.invoke('file:read', filePath);
```

**3. Return Structured Responses**
```javascript
ipcMain.handle('operation', async (event, data) => {
  try {
    const result = await performOperation(data);
    return { success: true,  result };
  } catch (error) {
    return { success: false, error: error.message };
  }
});
```

**4. Validate Input in Main Process**
```javascript
ipcMain.handle('save-data', async (event, data) => {
  if (!data || typeof data !== 'object') {
    throw new Error('Invalid data format');
  }
  return await saveToDatabase(data);
});
```

The `invoke()`/`handle()` pattern with async/await is the recommended modern approach for request-response IPC in Electron, providing cleaner syntax and better error handling than traditional methods.[2][3][1]

Sources
[1] Inter-Process Communication - Electron https://electronjs.org/docs/latest/tutorial/ipc
[2] What is the difference between IPC send / on and invoke / handle in electron? https://stackoverflow.com/questions/59889729/what-is-the-difference-between-ipc-send-on-and-invoke-handle-in-electron/59889863
[3] IPC in Electron - Ray https://myray.app/blog/ipc-in-electron
[4] useIpcRendererInvoke | VueUse https://v9-13-0.vueuse.org/electron/useipcrendererinvoke/
[5] IpcMain : add support for async callbacks · Issue #386 - GitHub https://github.com/ElectronNET/Electron.NET/issues/386
[6] How to pass exceptions in Electron.js from main process to renderer ... https://dev.to/oryaacov/how-to-pass-exceptions-in-electronjs-from-main-process-to-rendered-and-other-way-around-1b69
[7] Electron IPC Response/Request architecture with TypeScript https://blog.logrocket.com/electron-ipc-response-request-architecture-with-typescript/
[8] Await Promise in Electron ipcRenderer.invoke via context bridge https://stackoverflow.com/questions/75791003/await-promise-in-electron-ipcrenderer-invoke-via-context-bridge
[9] Electron – 3 Methods for Inter Process Communications (IPC) https://www.intertech.com/electron-3-methods-for-inter-process-communications-ipc/
[10] Advanced Inter-Process Communication Patterns | Chapter 7 https://seino-prince.com/book/2b3b4ab5-d136-81fb-8232-c0df9dc6329f/chapter/2b3b4ab5-d136-81cd-aa15-e1545aff73bd/section/2b3b4ab5-d136-81e2-bda2-c3b31cb70e35

---

### Data Serialization Constraints

Electron's IPC uses the **HTML standard Structured Clone Algorithm** to serialize objects passed between processes, which imposes strict limitations on what types of data can be transmitted.[1][2][3]

#### Serialization Algorithm

**Structured Clone Algorithm**
- Same serialization used by `window.postMessage` in browsers[3]
- Automatically handles serialization and deserialization[4][5]
- Creates deep copies, not references[6]
- Prototype chains are not preserved[5][3]

#### Serializable Data Types

**✅ Supported Types:**
- **Primitives**: `string`, `number`, `boolean`, `null`, `undefined`, `BigInt`
- **Objects**: Plain objects (Object literals)
- **Arrays**: Arrays containing serializable types
- **Dates**: `Date` objects
- **RegExp**: Regular expressions
- **Typed Arrays**: `Int8Array`, `Uint8Array`, `Float32Array`, etc.
- **ArrayBuffer**: Binary data buffers
- **Map**: Map objects
- **Set**: Set objects
- **Blob**: Binary large objects[3]
- **Buffer**: Node.js buffers[4]

[1][3]

**Example - Valid Data:**
```javascript
// All of these can be sent via IPC
ipcRenderer.send('channel', {
  string: 'hello',
  number: 42,
  boolean: true,
  array: [1, 2, 3],
  nested: { key: 'value' },
  date: new Date(),
  regexp: /test/,
  map: new Map([['key', 'value']]),
  set: new Set([1, 2, 3]),
  buffer: Buffer.from('data')
});
```

#### Non-Serializable Types

**❌ Not Supported:**

**DOM Objects:**
- `Element` (HTML elements)
- `Location`
- `DOMMatrix`
- `ImageBitmap`
- `File` (DOM File objects)
- `DOMRect`

[1][3]

**Node.js Objects Backed by C++ Classes:**
- `process.env`
- Some members of `Stream`
- Native C++ addon objects

[2][1]

**Electron Objects Backed by C++ Classes:**
- `WebContents`
- `BrowserWindow`
- `WebFrame`
- Other Electron API objects

[2][3][1]

**JavaScript Objects with Special Behavior:**
- **Functions**: Cannot be serialized[7][5]
- **Symbols**: Not serializable[7]
- **Classes/Prototypes**: Prototype chains are lost[3]
- **Circular references**: May cause issues

[5][7]

#### Common Serialization Errors

**Error: "An object could not be cloned"**
This error occurs when trying to send non-serializable [7]

```javascript
// ❌ This will fail
const data = {
  callback: () => console.log('test'), // Functions not allowed
  element: document.getElementById('myDiv'), // DOM objects not allowed
  window: browserWindow // Electron objects not allowed
};

ipcRenderer.send('channel', data);
// Error: An object could not be cloned
```


**Error: "Failed to serialize arguments"**
Indicates the data structure contains non-serializable elements:[4]

```javascript
// ❌ Array containing non-serializable objects
const posts = [
  { id: 1, callback: someFunction }, // Function not allowed
  { id: 2, element: domNode } // DOM object not allowed
];

ipcRenderer.send('posts', posts);
// Error: Failed to serialize arguments
```


#### Workarounds for Unsupported Types

**1. Functions - Use Channels Instead**
Instead of passing functions, define callback channels:[7]

```javascript
// ❌ Bad - trying to pass function
ipcRenderer.send('process', { callback: myFunction });

// ✅ Good - use channel for callback
ipcRenderer.send('process', { callbackChannel: 'my-callback' });
ipcRenderer.on('my-callback', (event, result) => {
  myFunction(result);
});
```

**2. Complex Objects - Serialize Manually**
Use `JSON.stringify()` for objects that fail automatic serialization:[4]

```javascript
// If automatic serialization fails
const complexData = [/* complex array of objects */];

// Manually serialize
ipcRenderer.send('data', JSON.stringify(complexData));

// Main process - deserialize
ipcMain.on('data', (event, jsonString) => {
  const data = JSON.parse(jsonString);
});
```


**3. Class Instances - Send Plain Objects**
Convert class instances to plain objects before sending:

```javascript
class User {
  constructor(name, age) {
    this.name = name;
    this.age = age;
  }
  
  greet() { return `Hello, ${this.name}`; }
}

const user = new User('John', 30);

// ❌ Bad - sends class instance (methods lost)
ipcRenderer.send('user', user);

// ✅ Good - send plain object
ipcRenderer.send('user', {
  name: user.name,
  age: user.age
});
```

**4. Buffers for Binary Data**
Use Node.js Buffers for binary data transfer:[4]

```javascript
// Reading file as buffer
const fileBuffer = fs.readFileSync('/path/to/file');

// Send buffer via IPC (supported)
ipcRenderer.send('file-data', fileBuffer);
```


#### Arrays of Objects

Arrays of serializable objects **are supported**:[4]

```javascript
// ✅ This works fine
const posts = [
  { id: 1, title: 'Post 1', score: 100 },
  { id: 2, title: 'Post 2', score: 200 }
];

ipcRenderer.send('posts', posts);
```


If you get serialization errors with arrays, check that:
- All objects in the array contain only serializable types
- No functions, DOM objects, or Electron objects are present
- No circular references exist

#### Important Limitations

**1. Prototype Chains Not Preserved**
Objects lose their prototype chain when serialized:[5][3]

```javascript
class MyClass {
  method() { return 'test'; }
}

const instance = new MyClass();

// After sending via IPC, the object becomes a plain object
// instance.method() will not exist on the receiving side
```

**2. No Reference Passing**
IPC creates deep copies, not references:[6]

```javascript
// Changes to original won't affect sent data
const obj = { count: 0 };
ipcRenderer.send('data', obj);
obj.count = 100; // Doesn't affect the copy sent via IPC
```

**3. Main Process Limitations**
The main process doesn't have DOM support, so DOM-specific objects cannot be decoded even if they could be serialized.[3]

#### Best Practices

**1. Send Plain Data Structures**
```javascript
// ✅ Good - plain data
const data = {
  id: 123,
  values: [1, 2, 3],
  meta { type: 'user' }
};
```

**2. Validate Before Sending**
```javascript
function isSerialized(obj) {
  try {
    structuredClone(obj); // Test if object can be cloned
    return true;
  } catch {
    return false;
  }
}

if (isSerialized(data)) {
  ipcRenderer.send('channel', data);
} else {
  console.error('Data not serializable');
}
```

**3. Handle Serialization Errors**
```javascript
try {
  ipcRenderer.send('channel', data);
} catch (error) {
  console.error('Serialization failed:', error.message);
  // Fallback: send JSON string
  ipcRenderer.send('channel', JSON.stringify(data));
}
```

Understanding serialization constraints is crucial for reliable IPC communication in Electron applications. Always ensure your data structures contain only supported types to avoid runtime errors.[2][1][3]

Sources
[1] Inter-Process Communication https://electronjs.org/docs/latest/tutorial/ipc
[2] Inter-Process Communication - Electron https://www.electronjs.org/docs/latest/tutorial/ipc
[3] ipcRenderer https://electronjs.org/docs/latest/api/ipc-renderer
[4] Can Electron IPC Handle Arrays of Objects? Encountering ... https://www.reddit.com/r/electronjs/comments/1ag3dub/can_electron_ipc_handle_arrays_of_objects/
[5] Electron interprocess communication https://www.nickolinger.com/blog/electron-interprocess-communication/
[6] Architecture / IPC Question (Newb) https://www.reddit.com/r/electronjs/comments/17rdpwi/architecture_ipc_question_newb/
[7] Electron reply error: An object could not be cloned https://stackoverflow.com/questions/70839472/electron-reply-error-an-object-could-not-be-cloned
[8] Limitations of executeJavaScript Should Be Documented #9288 https://github.com/electron/electron/issues/9288
[9] sindresorhus/electron-better-ipc - GitHub https://github.com/sindresorhus/electron-better-ipc
[10] Electron IPC and nodeIntegration - javascript - Stack Overflow https://stackoverflow.com/questions/52236641/electron-ipc-and-nodeintegration


---

