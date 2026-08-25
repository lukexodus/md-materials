## Preload Script


```javascript
// preload.js - Preload Script (Bridge)
const { contextBridge, ipcRenderer } = require('electron');

// Expose protected methods that allow the renderer process
// to use ipcRenderer without exposing the entire object
contextBridge.exposeInMainWorld('electronAPI', {
  // Two-way communication: renderer -> main -> renderer
  sendPing: (message) => ipcRenderer.invoke('ping', message),
  
  // One-way communication: renderer -> main
  sendAsync: (message) => ipcRenderer.send('async-message', message),
  
  // Listen for messages from main process
  onAsyncReply: (callback) => {
    ipcRenderer.on('async-reply', (event, message) => callback(message));
  }
});
```

