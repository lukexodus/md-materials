## Multiple Window Creation


Electron applications can create and manage multiple BrowserWindow instances simultaneously. Each window runs independently with its own renderer process, requiring proper management and communication patterns.[1][2]

### Creating Multiple Windows

The basic approach involves instantiating new BrowserWindow objects and tracking them in a collection.[2]

**Using a Set to Track Windows**
```javascript
const { app, BrowserWindow } = require('electron')

const windows = new Set()

function createWindow() {
  const newWindow = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js')
    }
  })
  
  windows.add(newWindow)
  newWindow.loadFile('index.html')
  
  // Remove window from set when closed
  newWindow.on('closed', () => {
    windows.delete(newWindow)
  })
  
  return newWindow
}

app.on('ready', createWindow)

// Prevent creating new window if windows already exist
app.on('activate', () => {
  if (windows.size === 0) {
    createWindow()
  }
})
```

This pattern prevents memory leaks by removing closed windows from the tracking set.[2]

**Using an Array to Track Windows**
```javascript
const { app, BrowserWindow } = require('electron')

let windows = []

function createWindow() {
  const newWindow = new BrowserWindow({
    width: 1000,
    height: 800
  })
  
  windows.push(newWindow)
  newWindow.loadFile('app.html')
  
  newWindow.on('closed', () => {
    windows = windows.filter(w => w !== newWindow)
  })
}

app.on('ready', () => {
  // Create multiple windows on startup
  for (let i = 0; i < 3; i++) {
    createWindow()
  }
})
```

Arrays allow indexed access to specific windows but require filtering on close.[1]

### Parent-Child Window Relationships

Child windows can be created with a parent reference, making them modal or attached.[3]

**Creating Child Windows**
```javascript
const { BrowserWindow } = require('electron')

let mainWindow
let childWindow

function createMainWindow() {
  mainWindow = new BrowserWindow({
    width: 800,
    height: 600
  })
  
  mainWindow.loadFile('index.html')
}

function createChildWindow() {
  childWindow = new BrowserWindow({
    width: 400,
    height: 300,
    parent: mainWindow,      // Set parent window
    modal: true,             // Make it modal
    show: false              // Don't show until ready
  })
  
  childWindow.loadFile('child.html')
  
  childWindow.once('ready-to-show', () => {
    childWindow.show()
  })
  
  childWindow.on('closed', () => {
    childWindow = null
  })
}
```

Setting `parent` makes the child window always appear on top of the parent. The `modal` property blocks interaction with the parent while the child is open.[3]

### Window Communication via IPC

Windows communicate through the Main process using IPC.[4][3]

**Main Process**
```javascript
const { ipcMain, BrowserWindow } = require('electron')

let mainWindow
let childWindow

ipcMain.on('open-child-window', (event, data) => {
  childWindow = new BrowserWindow({
    width: 500,
    height: 400,
    parent: mainWindow,
    modal: true,
    show: false,
    webPreferences: {
      contextIsolation: true,
      preload: path.join(__dirname, 'preload.js')
    }
  })
  
  childWindow.loadFile('child.html')
  
  // Send data to child when ready
  childWindow.once('ready-to-show', () => {
    childWindow.webContents.send('data-from-parent', data)
    childWindow.show()
  })
})

// Receive data from child and send to parent
ipcMain.on('send-to-parent', (event, data) => {
  if (mainWindow && !mainWindow.isDestroyed()) {
    mainWindow.webContents.send('data-from-child', data)
  }
})
```

The `ready-to-show` event ensures the child window's renderer is ready before sending data.[3]

**Preload Script**
```javascript
const { contextBridge, ipcRenderer } = require('electron')

contextBridge.exposeInMainWorld('windowAPI', {
  openChildWindow: (data) => ipcRenderer.send('open-child-window', data),
  sendToParent: (data) => ipcRenderer.send('send-to-parent', data),
  onDataFromParent: (callback) => ipcRenderer.on('data-from-parent', (event, data) => callback(data)),
  onDataFromChild: (callback) => ipcRenderer.on('data-from-child', (event, data) => callback(data))
})
```

**Parent Renderer**
```javascript
// Open child window with data
document.getElementById('open-child').onclick = () => {
  const data = { message: 'Hello from parent', timestamp: Date.now() }
  window.windowAPI.openChildWindow(data)
}

// Receive data from child
window.windowAPI.onDataFromChild((data) => {
  console.log('Received from child:', data)
})
```

**Child Renderer**
```javascript
// Receive data from parent
window.windowAPI.onDataFromParent((data) => {
  console.log('Received from parent:', data)
  document.getElementById('message').textContent = data.message
})

// Send data to parent
document.getElementById('send-to-parent').onclick = () => {
  const data = { response: 'Hello from child', value: 42 }
  window.windowAPI.sendToParent(data)
}
```

This pattern maintains security through context isolation while enabling bidirectional communication.[3]

### Using window.opener for Direct Communication

Child windows opened with `window.open()` have access to `window.opener` for direct parent communication.[5]

**Parent Window**
```javascript
// Open child window
let childWindow = window.open('child.html', 'Child Window', 'width=400,height=300')

// Send message to child
function sendToChild() {
  const message = 'Data from parent'
  childWindow.postMessage(message, '*')
}

// Receive message from child
window.addEventListener('message', (event) => {
  console.log('Received from child:', event.data)
})
```

**Child Window**
```javascript
// Receive message from parent
window.addEventListener('message', (event) => {
  console.log('Received from parent:', event.data)
})

// Send message to parent
function sendToParent() {
  const message = 'Data from child'
  window.opener.postMessage(message, '*')
}
```

This approach uses the standard `postMessage` API but requires `nodeIntegration` or careful security configuration.[5]

### Managing Window State

Track window properties to restore state or coordinate behavior.[2]

```javascript
const { app, BrowserWindow } = require('electron')

class WindowManager {
  constructor() {
    this.windows = new Map()
    this.nextId = 1
  }
  
  createWindow(options = {}) {
    const id = this.nextId++
    
    const window = new BrowserWindow({
      width: 800,
      height: 600,
      ...options
    })
    
    this.windows.set(id, {
      window: window,
      id: id,
      created: Date.now()
    })
    
    window.on('closed', () => {
      this.windows.delete(id)
    })
    
    return { id, window }
  }
  
  getWindow(id) {
    return this.windows.get(id)?.window
  }
  
  getAllWindows() {
    return Array.from(this.windows.values()).map(w => w.window)
  }
  
  closeAll() {
    this.windows.forEach(({ window }) => {
      if (!window.isDestroyed()) {
        window.close()
      }
    })
  }
  
  getCount() {
    return this.windows.size
  }
}

const windowManager = new WindowManager()

app.on('ready', () => {
  windowManager.createWindow()
})
```

This class-based approach provides centralized window management with methods for creation, retrieval, and cleanup.[2]

### Using electron-window-manager Package

The `electron-window-manager` npm package simplifies multi-window management.[6][1]

**Installation**
```bash
npm install electron-window-manager --save
```

**Usage**
```javascript
const { app } = require('electron')
const windowManager = require('electron-window-manager')

app.on('ready', () => {
  // Initialize window manager
  windowManager.init()
  
  // Open windows by name
  windowManager.open('home', 'Home Window', '/home.html', null, {
    width: 800,
    height: 600
  })
  
  windowManager.open('settings', 'Settings', '/settings.html', null, {
    width: 600,
    height: 400
  })
})

// In renderer process
const windowManager = require('electron').remote.require('electron-window-manager')

// Create new window from renderer
const newWin = windowManager.createNew('details', 'Details Window')
newWin.loadURL('/details.html')
newWin.open()
```

The package provides event-based communication between windows and centralized configuration.[6][1]

### Broadcasting to All Windows

Send messages to all open windows simultaneously.[4]

```javascript
const { BrowserWindow } = require('electron')

function broadcastToAllWindows(channel, data) {
  const windows = BrowserWindow.getAllWindows()
  
  windows.forEach(window => {
    if (!window.isDestroyed()) {
      window.webContents.send(channel, data)
    }
  })
}

// Usage
ipcMain.on('broadcast-message', (event, message) => {
  broadcastToAllWindows('message-received', message)
})
```

The `BrowserWindow.getAllWindows()` method returns an array of all existing window instances.[4]

### Limiting Maximum Windows

Prevent creating too many windows with a maximum limit.[2]

```javascript
const MAX_WINDOWS = 5
const windows = new Set()

function createWindow() {
  if (windows.size >= MAX_WINDOWS) {
    console.log('Maximum window limit reached')
    return null
  }
  
  const newWindow = new BrowserWindow({
    width: 800,
    height: 600
  })
  
  windows.add(newWindow)
  newWindow.loadFile('index.html')
  
  newWindow.on('closed', () => {
    windows.delete(newWindow)
  })
  
  return newWindow
}
```

This prevents resource exhaustion from excessive window creation.[2]

Sources
[1] Electron best way for multiple windows https://stackoverflow.com/questions/39077295/electron-best-way-for-multiple-windows
[2] How to Handle Multiple Windows in an Electron App - Atomic Spin https://spin.atomicobject.com/multiple-windows-electron-app/
[3] How to send data between parent and child window in Electron https://stackoverflow.com/questions/51789711/how-to-send-data-between-parent-and-child-window-in-electron
[4] getting multiple windows in electronJS which has the same browserwindow instance to display different results https://stackoverflow.com/questions/72391588/getting-multiple-windows-in-electronjs-which-has-the-same-browserwindow-instance
[5] 初心者向き！Electronで親ウィンドウ↔子ウィンドウのデータ ... https://blog.capilano-fw.com/?p=2593
[6] electron-window-manager https://www.npmjs.com/package/electron-window-manager
[7] Creating multi-window Electron apps using React portals https://pietrasiak.com/creating-multi-window-electron-apps-using-react-portals
[8] Electron Tutorial 6: BrowserWindow https://www.youtube.com/watch?v=UG9lka9mOwM
[9] Multiple Windows https://www.reddit.com/r/electronjs/comments/mbn2u7/multiple_windows/
[10] Multiple Windows in Electron https://stackoverflow.com/questions/66947675/multiple-windows-in-electron

---

