## IpcRendererEvent in Electron


`IpcRendererEvent` is an event object passed to listener callbacks in Electron's renderer process when using IPC (Inter-Process Communication).

### Basic Usage

When you set up an IPC listener in the renderer process, the callback receives an `IpcRendererEvent` as its first parameter:

```javascript
const { ipcRenderer } = require('electron');

ipcRenderer.on('channel-name', (event, ...args) => {
  // event is an IpcRendererEvent object
  // args are the additional arguments sent with the message
});
```

### Key Properties

The `IpcRendererEvent` object includes:

- **`sender`** - A reference to the `ipcRenderer` that sent the message (allows you to send messages back)
- **`senderId`** - The webContents ID that sent the message
- **`ports`** - An array of MessagePorts transferred with the message (for advanced IPC patterns)

### Common Patterns

**Replying to messages:**

```javascript
ipcRenderer.on('request', (event, data) => {
  // Process data
  event.sender.send('response', result);
});
```

**Using with invoke/handle pattern:**

```javascript
// Main process
ipcMain.handle('get-data', async (event, arg) => {
  // event is IpcMainInvokeEvent here
  return someData;
});

// Renderer process
const data = await ipcRenderer.invoke('get-data', arg);
```

This is part of Electron's security model for controlled communication between the main and renderer processes.

---

