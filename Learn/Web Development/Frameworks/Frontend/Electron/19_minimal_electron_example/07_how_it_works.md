## How It Works:


1. **Main Process** (main.js):
    
    - Creates the window with preload script
    - Listens for IPC messages using `ipcMain.handle()` and `ipcMain.on()`
2. **Preload Script** (preload.js):
    
    - Acts as a secure bridge
    - Exposes safe APIs to renderer via `contextBridge`
    - Prevents direct Node.js access from renderer
3. **Renderer Process** (renderer.js):
    
    - Uses APIs exposed by preload script
    - Cannot directly access Node.js or Electron APIs

