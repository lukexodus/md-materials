## Process vs Frame


In Electron, the terms **“process”** and **“frame”** refer to different levels of execution and rendering. Understanding the distinction is key to grasping Electron’s architecture.

---

### 1. Process

Electron separates its runtime into multiple **processes**, similar to Chrome:
- **Main process**
    - Single process for the entire app.
    - Has full Node.js and Electron API access.
    - Controls windows, menus, file system, native modules, etc.
    - Runs your main script (e.g., `main.js`).
- **Renderer process**
    - Each `BrowserWindow` gets its own renderer process.
    - Runs HTML/CSS/JS for that window.
    - By default, **does not have Node.js access** if `nodeIntegration: false`.
    - Multiple tabs/windows = multiple renderer processes.
- **Utility processes**
    - Electron may spawn additional hidden processes for GPU, extensions, or sandboxing.
        

**Key point:** “Process” is a **running instance of Node.js/V8 with memory isolation**.

---

### 2. Frame

- A **frame** is a **subsection of a renderer process**, usually corresponding to an HTML `<iframe>` or web frame.
- A single renderer process can have **multiple frames**:
    

```html
<iframe src="https://example.com"></iframe>
```
- Each frame has:
    - Its own JavaScript context (`window`, `document`)
    - Its own isolated world if `contextIsolation` is used
    - Its own `window.postMessage` messaging scope
- In Electron terms:
    - `webContents` generally represents a **top-level frame** of a window.
    - You can access sub-frames via `webContents.mainFrame.frames` or `frame.frames`.
    - `executeJavaScriptInIsolatedWorld` can target specific frames.

---

### 3. How they relate

|Term|Scope|Notes|
|---|---|---|
|Process|OS-level isolated memory space|Main vs renderer; renderer per window; multiple renderers possible|
|Frame|Browser context inside renderer|Top frame or iframe; multiple frames per renderer; can have isolated JS contexts|

**Analogy:**
- **Process** = the entire building.
- **Frame** = a room inside the building.
- You can have multiple rooms (frames) in a building (process), and multiple buildings (renderer processes) in the city (Electron app).

---

### 4. Practical Electron implications

- `event.sender` (in `ipcMain`) → refers to **the renderer process’s webContents**, i.e., the whole process hosting the frame that sent the IPC.
- `frame` objects allow you to:
    - Target a specific iframe in `executeJavaScriptInIsolatedWorld`
    - Inspect or inject scripts into sub-frames
    - Send messages specifically to a frame without touching the whole renderer process

---

