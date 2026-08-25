## Window Communication


Electron provides multiple communication mechanisms to enable data exchange between the main process, renderer processes, and different windows. Inter-Process Communication (IPC) forms the foundation of this system, allowing processes with different responsibilities to coordinate effectively while maintaining security boundaries.[1]

### IPC Channel Architecture

IPC in Electron operates through developer-defined "channels" using the `ipcMain` and `ipcRenderer` modules. These channels are arbitrary—developers can name them anything—and bidirectional, allowing the same channel name to be used by both modules. The channel-based approach provides a flexible messaging system where processes communicate by passing messages through these named conduits.[2][3][4][1]

The `ipcMain` module runs exclusively in the main process and listens for events from renderer processes, while `ipcRenderer` operates in renderer processes to send events to the main process. This asymmetric design reflects Electron's process model, where the main process controls application lifecycle and native APIs, while renderers handle UI rendering and user interaction.[3][4]

### Renderer to Main Communication (One-Way)

One-way messages from renderer to main use `ipcRenderer.send()` to transmit data that is received by `ipcMain.on()`. This pattern is commonly used to call main process APIs from web contents, such as changing a window title or triggering file system operations. The renderer sends messages through a preload script that exposes a safe API via `contextBridge`, preventing direct access to IPC modules for security reasons.[1][2]

In the main process, `ipcMain.on()` registers a listener on a specific channel, receiving an `IpcMainEvent` object and any passed arguments. The event object includes a `sender` property containing the `WebContents` instance that sent the message, enabling the main process to identify which window triggered the event and respond accordingly.[1]

### Renderer to Main Communication (Two-Way)

Two-way communication uses `ipcRenderer.invoke()` paired with `ipcMain.handle()` to call main process functions and receive return values. This pattern is ideal for requesting data from the main process, such as opening native dialogs or querying system information. The `invoke()` method returns a Promise that resolves with the handler's return value, enabling seamless asynchronous communication.[2][1]

The `ipcMain.handle()` method registers an async handler function that processes requests and returns values to the renderer. Handlers can be async functions, allowing them to perform long-running operations without blocking the main process. Note that errors thrown in handlers are serialized, with only the error's `message` property transmitted to the renderer—full error objects are not preserved across the IPC boundary.[1]

Legacy alternatives exist but are discouraged—`ipcRenderer.send()` with `event.reply()` requires managing separate response channels and pairing requests with responses manually. The `ipcRenderer.sendSync()` API blocks the renderer process until a response is received, causing severe performance degradation and should be avoided entirely.[1]

### Main to Renderer Communication

Messages from the main process to renderers are sent via the `WebContents.send()` method, which targets a specific renderer process. Each BrowserWindow contains a `webContents` instance that provides the `send()` API for transmitting messages to that window's renderer. This pattern is useful for triggering UI updates from the main process, such as updating counters from menu clicks or notifying renderers of background events.[5][2][1]

In the preload script, `ipcRenderer.on()` sets up listeners for messages from the main process. The preload exposes a callback-based API through `contextBridge` that allows the renderer to register handlers without direct access to `ipcRenderer`. When exposing `ipcRenderer.on()`, developers must wrap the callback to prevent leaking the `ipcRenderer` instance through `event.sender`. The wrapper should invoke the callback with only the desired arguments, maintaining security boundaries.[1]

There is no direct equivalent to `ipcRenderer.invoke()` for main-to-renderer communication, but replies can be sent back to the main process from within `ipcRenderer.on()` callbacks using `ipcRenderer.send()`. This establishes a request-response pattern where the main process initiates communication and the renderer optionally responds.[1]

### Renderer to Renderer Communication

Direct renderer-to-renderer communication is not supported through the standard `ipcMain` and `ipcRenderer` modules. Electron provides two approaches to enable inter-renderer messaging.

The first approach uses the main process as a message broker—one renderer sends a message to the main process, which forwards it to other renderers using `webContents.send()`. This method centralizes message routing and allows the main process to filter, transform, or broadcast messages.

**Example: Main process as message broker**

```javascript
// Renderer 1 (sender)
ipcRenderer.send('message-to-other-renderer', { data: 'Hello' });

// Main process
ipcMain.on('message-to-other-renderer', (event, message) => {
  // Forward to all renderer windows or specific window
  BrowserWindow.getAllWindows().forEach(win => {
    win.webContents.send('renderer-message', message);
  });
});

// Renderer 2 (receiver)
ipcRenderer.on('renderer-message', (event, message) => {
  console.log('Received:', message.data); // "Hello"
});
```

The second approach passes `MessagePort` objects from the main process to both renderers, enabling direct communication after initial setup. This eliminates the main process bottleneck for high-frequency renderer-to-renderer messaging and supports direct peer-to-peer data transfer.

**Example: MessagePort-based direct communication**

```javascript
// Main process - create and transfer ports
const { port1, port2 } = new MessageChannelMain();
renderer1.postMessage('port', null, [port1]);
renderer2.postMessage('port', null, [port2]);

// Renderer 1
ipcRenderer.on('port', (event) => {
  const port = event.ports[0];
  port.postMessage({ data: 'Direct message' });
});

// Renderer 2
ipcRenderer.on('port', (event) => {
  const port = event.ports[0];
  port.onmessage = (event) => {
    console.log('Received directly:', event.data); // { data: 'Direct message' }
  };
});
```

For parent-child windows created via `window.open()` with same-origin content, the parent can access the child window directly through the returned reference, and the child accesses the parent via `window.opener`. The `postMessage()` API enables bidirectional messaging—parents send messages using `childWindow.postMessage(message)`, while children use `window.opener.postMessage(message)`. Both windows listen for messages using `window.addEventListener('message', handler)`.[9]

### MessagePort Communication

MessagePorts provide an alternative IPC mechanism based on the Web Channel Messaging API. Conceptually, a `MessageChannel` is like a private telephone line: it creates two endpoints (`port1` and `port2`), and anything spoken into one is heard only by the other. This allows isolated, bidirectional communication without broadcasting through global IPC channels.

A `MessageChannel` can be created in either the main process or a renderer process. Its ports can then be transferred between processes using `ipcRenderer.postMessage()` and `WebContents.postMessage()`.

#### Basic MessageChannel in a renderer

```js
// renderer.js
const channel = new MessageChannel();
const { port1, port2 } = channel;

port1.onmessage = (event) => {
  console.log('Renderer received:', event.data);
};

port2.postMessage('Hello from port2');
```

Output:

```
Renderer received: Hello from port2
```

This works entirely within one context, but the real value appears when ports are transferred across processes.

---

### Transferring MessagePorts (why `postMessage` matters)

Standard Electron IPC methods like `ipcRenderer.send()` and `ipcRenderer.invoke()` cannot transfer `MessagePort` objects. Only `postMessage()` supports transferring ownership of ports.

Think of it like sending a physical key: `send()` and `invoke()` can send copies of information, but only `postMessage()` can hand over the actual key that unlocks a private channel.

#### Renderer → Main: transferring a port

```js
// renderer.js
const channel = new MessageChannel();

channel.port1.onmessage = (e) => {
  console.log('Renderer got reply:', e.data);
};

ipcRenderer.postMessage('init-port', null, [channel.port2]);

channel.port1.postMessage('Hello main');
```

Main process:

```js
// main.js
ipcMain.on('init-port', (event) => {
  const [port] = event.ports;

  port.on('message', (e) => {
    console.log('Main received:', e.data);
    port.postMessage('Hello renderer');
  });

  port.start();
});
```

Output:

```
Main received: Hello main
Renderer got reply: Hello renderer
```

Notice that the port is transferred only once. After transfer, the sender no longer owns that port.

---

### Connecting two renderers via the main process

This is a key pattern enabled by MessagePorts. Two renderer processes that cannot directly communicate (for example, due to origin isolation) can still talk through a private channel established by the main process.

Analogy: the main process acts like a switchboard operator. It introduces two callers, hands each one the other’s phone line, and then steps away.

Main process:

```js
// main.js
ipcMain.on('connect-renderers', (event) => {
  const channel = new MessageChannelMain();

  const sender = event.sender;
  const otherWindow = getOtherWindowWebContents(); // assume this exists

  sender.postMessage('port', null, [channel.port1]);
  otherWindow.postMessage('port', null, [channel.port2]);
});
```

Renderer A:

```js
ipcRenderer.on('port', (event) => {
  const [port] = event.ports;

  port.onmessage = (e) => {
    console.log('Renderer A got:', e.data);
  };

  port.postMessage('Hello from A');
});
```

Renderer B:

```js
ipcRenderer.on('port', (event) => {
  const [port] = event.ports;

  port.onmessage = (e) => {
    console.log('Renderer B got:', e.data);
  };
});
```

Output:

```
Renderer B got: Hello from A
```

After setup, Renderer A and Renderer B communicate directly. The main process is no longer involved.

---

### MessagePortMain behavior in the main process

When a MessagePort is transferred to the main process, it becomes a `MessagePortMain`. Unlike browser MessagePorts, it uses Node.js-style events.

Instead of:

```js
port.onmessage = ...
```

You use:

```js
port.on('message', handler);
```

Another important difference is buffering. `MessagePortMain` queues messages until `start()` is called. This prevents message loss if messages arrive before listeners are registered.

```js
port.on('message', (e) => {
  console.log('Received:', e.data);
});

port.start();
```

Without `start()`, messages remain queued and are never delivered.

---

### Port closing and lifecycle

Electron extends the standard MessagePort API with a `close` event. This allows each side to detect when the other end has been closed.

Renderer:

```js
port.onclose = () => {
  console.log('Port closed');
};
```

or

```js
port.addEventListener('close', () => {
  console.log('Port closed');
});
```

Main process:

```js
port.on('close', () => {
  console.log('Port closed in main');
});
```

Ports can close explicitly or implicitly. Implicit closure can happen if a port is garbage-collected, which is similar to losing a phone line because the handset was destroyed.

### Advanced MessagePort Patterns

MessageChannels enable sophisticated communication patterns beyond basic IPC. For setting up direct renderer-to-renderer channels, the main process creates a `MessageChannelMain`, then sends each port to different renderers using `webContents.postMessage()`. After setup, renderers communicate directly via their respective ports without main process mediation.[8]

Worker processes can be implemented as hidden BrowserWindows that receive work requests via MessagePorts. The main window requests a worker channel from the main process, which creates a MessageChannel and sends one port to the worker and the other to the main window. This architecture allows CPU-intensive work to execute in a separate Blink context with full access to web APIs while maintaining direct communication with the main window.[8]

Response streams demonstrate MessagePort versatility—instead of single request-response pairs, a renderer can send a request with an attached MessagePort and receive multiple streaming responses. The main process sends multiple messages through the port and closes it when finished, signaling stream completion. This pattern enables progress updates, partial results, and event streams without creating separate IPC channels for each response.[8]

### Context Isolation and Security

When context isolation is enabled, IPC messages from the main process are delivered to the isolated world, not the main world. To communicate directly with the main world, developers can transfer a MessagePort from the main process to the isolated world via preload script, then forward it to the main world using `window.postMessage()`. The main world receives the port and can communicate directly with the main process without stepping through the isolated preload context.[8]

Security best practices mandate never exposing the full `ipcRenderer` API directly to the renderer—instead, use `contextBridge` to expose specific, validated functions. This limits the renderer's access to Electron APIs and prevents malicious code from accessing privileged functionality. When wrapping `ipcRenderer.on()`, avoid passing callbacks directly, as this leaks `ipcRenderer` through `event.sender`.[1]

### Object Serialization

Electron's IPC implementation uses the HTML Structured Clone Algorithm to serialize objects passed between processes. Only certain object types can be transferred through IPC channels—DOM objects (Element, Location, DOMMatrix), Node.js objects backed by C++ classes (process.env, Stream members), and Electron objects backed by C++ classes (WebContents, BrowserWindow, WebFrame) are not serializable with Structured Clone and cannot be sent via IPC.[1]

Sources
[1] Electron - How to know when renderer window is ready https://stackoverflow.com/questions/42284627/electron-how-to-know-when-renderer-window-is-ready
[2] Inter-Process Communication https://electronjs.org/docs/latest/tutorial/ipc
[3] Inter-Process Communication (IPC) in ElectronJS https://www.geeksforgeeks.org/node-js/inter-process-communication-ipc-in-electronjs/
[4] IPC in Electron - Ray https://myray.app/blog/ipc-in-electron
[5] webContents | Electron https://electronjs.org/docs/latest/api/web-contents
[6] communication between 2 browser windows in electron https://stackoverflow.com/questions/40251411/communication-between-2-browser-windows-in-electron
[7] How to Send Messages Between Electron Windows https://javascript.plainenglish.io/messaging-between-electron-windows-a646b0af7d8d
[8] app https://www.electronjs.org/docs/latest/api/app
[9] 初心者向き！Electronで親ウィンドウ↔子ウィンドウのデータ ... https://blog.capilano-fw.com/?p=2593
[10] MessagePorts in Electron https://electronjs.org/docs/latest/tutorial/message-ports
[11] Electron JS Inter Process Communication ( IPC ) Explained https://www.youtube.com/watch?v=J60XrXk0J1o
[12] sindresorhus/electron-better-ipc https://github.com/sindresorhus/electron-better-ipc
[13] Why is my ipcMain not sending to ipcRenderer in Electron? https://stackoverflow.com/questions/55266463/why-is-my-ipcmain-not-sending-to-ipcrenderer-in-electron


---

