## **Available Methods in `electronAPI`**


Based on the package documentation, the electronAPI includes these methods:

### **IPC Communication (from ipcRenderer)**

- `send` - Send asynchronous message
- `sendTo` - Send message to specific webContents
- `sendSync` - Send synchronous message
- `sendToHost` - Send message to host page (for webview)
- `invoke` - Invoke main process handler (returns Promise)
- `postMessage` - Post message with transferables

### **Event Listeners**

- `on` - Listen to channel
- `once` - Listen to channel once
- `removeListener` - Remove specific listener
- `removeAllListeners` - Remove all listeners

### **WebFrame Methods**

- `insertCSS` - Inject CSS into page
- `setZoomFactor` - Set zoom factor
- `setZoomLevel` - Set zoom level

### **WebUtils Methods**

- `getPathForFile` - Get path for File object

### **Process Properties**

- `platform` - Operating system platform
- `versions` - Electron/Node/Chrome versions
- `env` - Environment variables

