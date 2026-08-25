## `webContents`


### **What is webContents?**

webContents is an EventEmitter responsible for rendering and controlling a web page and is a property of the BrowserWindow object.

**Basic access example:**
```javascript
const { BrowserWindow } = require('electron')

const win = new BrowserWindow({ width: 800, height: 1500 })
win.loadURL('https://github.com')

const contents = win.webContents
console.log(contents)
```

---

### **Core Concepts**

#### **1. Module-Level Methods**

These methods can be accessed from the webContents module directly:

```javascript
const { webContents } = require('electron')

// Get all WebContents instances
webContents.getAllWebContents()

// Get focused WebContents
webContents.getFocusedWebContents()

// Get WebContents by ID
webContents.fromId(id)
```

---

### **Navigation Events**

Several events can be used to monitor navigations as they occur within a webContents.

#### **Document Navigation Events** (in order):
1. `did-start-navigation`
2. `will-frame-navigate`
3. `will-navigate` (main frame only)
4. `will-redirect` (if redirect occurs)
5. `did-redirect-navigation` (if redirect occurs)
6. `did-frame-navigate`
7. `did-navigate` (main frame only)

#### **In-Page Navigation Events**:
1. `did-start-navigation`
2. `did-navigate-in-page`

In-page navigations don't cause the page to reload, but instead navigate to a location within the current page, such as when anchor links are clicked or when the DOM hashchange event is triggered.

---

### **Key Instance Events**

#### **Loading Events**
- `did-finish-load` - Navigation completed
- `did-fail-load` - Load failed
- `did-start-loading` - Tab spinner starts
- `did-stop-loading` - Tab spinner stops
- `dom-ready` - Document loaded

#### **User Interaction Events**
- `before-input-event` - Before keyboard events
- `context-menu` - Right-click menu
- `found-in-page` - Search results available

#### **Window Events**
- `did-create-window` - New window created via window.open
- `will-prevent-unload` - beforeunload handler attempting to cancel

#### **Process Events**
- `render-process-gone` - Renderer crashed or killed
- `unresponsive` - Page becomes unresponsive
- `responsive` - Page becomes responsive again

#### **DevTools Events**
- `devtools-opened`
- `devtools-closed`
- `devtools-focused`

#### **Media Events**
- `media-started-playing`
- `media-paused`
- `audio-state-changed`

---

### **Essential Instance Methods**

#### **Page Loading**

```javascript
// Load URL
await contents.loadURL('https://example.com', {
  httpReferrer: 'https://referrer.com',
  userAgent: 'Custom UA',
  extraHeaders: 'pragma: no-cache\n'
})

// Load local file
await contents.loadFile('src/index.html')

// Download file
contents.downloadURL('https://example.com/file.zip')

// Get current URL
const url = contents.getURL()

// Get page title
const title = contents.getTitle()
```

#### **Navigation**

```javascript
// Navigation history (deprecated - use navigationHistory API instead)
contents.canGoBack()
contents.canGoForward()
contents.goBack()
contents.goForward()

// Reload
contents.reload()
contents.reloadIgnoringCache()

// Stop loading
contents.stop()
```

#### **Code Execution**

```javascript
// Execute JavaScript
const result = await contents.executeJavaScript('1 + 1')

// Execute in isolated world
await contents.executeJavaScriptInIsolatedWorld(999, [
  { code: 'console.log("hello")' }
])
```

#### **CSS Injection**

```javascript
// Insert CSS
const key = await contents.insertCSS('body { background: red; }', {
  cssOrigin: 'user' // or 'author'
})

// Remove CSS
await contents.removeInsertedCSS(key)
```

#### **IPC Communication**

```javascript
// Send to renderer
contents.send('channel-name', data)

// Send to specific frame
contents.sendToFrame(frameId, 'channel-name', data)

// Post message with MessagePort
const { port1, port2 } = new MessageChannelMain()
contents.postMessage('port', { message: 'hello' }, [port1])
```

#### **Page Capture**

```javascript
// Capture screenshot
const image = await contents.capturePage({
  x: 0, y: 0, width: 800, height: 600
})

// Save page
await contents.savePage('/tmp/page.html', 'HTMLComplete')
// Save types: 'HTMLOnly', 'HTMLComplete', 'MHTML'
```

#### **Printing**

```javascript
// Print to printer
contents.print({
  silent: false,
  printBackground: true,
  deviceName: 'My-Printer',
  color: true,
  margins: { marginType: 'default' },
  landscape: false,
  scaleFactor: 1,
  pagesPerSheet: 1
}, (success, failureReason) => {
  console.log(success ? 'Printed!' : failureReason)
})

// Print to PDF
const pdfData = await contents.printToPDF({
  landscape: false,
  displayHeaderFooter: false,
  printBackground: false,
  scale: 1,
  pageSize: 'A4',
  margins: { top: 0, bottom: 0, left: 0, right: 0 },
  pageRanges: '1-5',
  preferCSSPageSize: false
})
```

#### **Search**

```javascript
// Find in page
const requestId = contents.findInPage('search term', {
  forward: true,
  findNext: false,
  matchCase: false
})

// Listen for results
contents.on('found-in-page', (event, result) => {
  if (result.finalUpdate) {
    contents.stopFindInPage('clearSelection')
  }
})
```

#### **Zoom**

```javascript
// Set zoom factor (1.0 = 100%)
contents.setZoomFactor(1.5)

// Get zoom factor
const factor = contents.getZoomFactor()

// Set zoom level (0 = 100%, each increment = 20%)
contents.setZoomLevel(2) // 140%

// Get zoom level
const level = contents.getZoomLevel()

// Set visual zoom limits
await contents.setVisualZoomLevelLimits(1, 3)
```

#### **DevTools**

```javascript
// Open DevTools
contents.openDevTools({ mode: 'detach', activate: true })

// Close DevTools
contents.closeDevTools()

// Toggle DevTools
contents.toggleDevTools()

// Check if open
const isOpen = contents.isDevToolsOpened()

// Inspect element
contents.inspectElement(x, y)

// Add workspace
contents.addWorkSpace(__dirname)
```

#### **Editing Commands**

```javascript
contents.undo()
contents.redo()
contents.cut()
contents.copy()
contents.paste()
contents.pasteAndMatchStyle()
contents.delete()
contents.selectAll()
contents.unselect()
```

#### **Focus & State**

```javascript
// Focus
contents.focus()
const isFocused = contents.isFocused()

// Loading state
const isLoading = contents.isLoading()
const isLoadingMainFrame = contents.isLoadingMainFrame()
const isWaitingForResponse = contents.isWaitingForResponse()

// Check if destroyed
const isDestroyed = contents.isDestroyed()

// Check if crashed
const isCrashed = contents.isCrashed()

// Force crash (for recovery)
contents.forcefullyCrashRenderer()
```

#### **Audio Control**

```javascript
// Mute
contents.setAudioMuted(true)

// Check mute state
const isMuted = contents.isAudioMuted()

// Check if playing audio
const isAudible = contents.isCurrentlyAudible()
```

#### **Advanced Features**

```javascript
// Device emulation
contents.enableDeviceEmulation({
  screenPosition: 'mobile',
  screenSize: { width: 375, height: 667 },
  deviceScaleFactor: 2
})
contents.disableDeviceEmulation()

// Send input events
contents.sendInputEvent({
  type: 'mouseDown',
  x: 100,
  y: 100,
  button: 'left'
})

// Set user agent
contents.setUserAgent('Custom User Agent')

// WebRTC IP handling
contents.setWebRTCIPHandlingPolicy('default_public_interface_only')
```

#### **Offscreen Rendering**

```javascript
// Check offscreen state
const isOffscreen = contents.isOffscreen()

// Control painting
contents.startPainting()
contents.stopPainting()
const isPainting = contents.isPainting()

// Set frame rate
contents.setFrameRate(60)
const fps = contents.getFrameRate()

// Listen for frames
contents.on('paint', (event, dirty, image) => {
  // image is a NativeImage
  // dirty is a Rectangle with repainted area
})
```

---

### **Instance Properties**

Key properties of WebContents include:

- **`id`** - Integer - Unique ID of this WebContents
- **`session`** - Session used by this webContents
- **`navigationHistory`** - NavigationHistory instance
- **`hostWebContents`** - WebContents that might own this WebContents
- **`devToolsWebContents`** - WebContents for DevTools (may be null)
- **`debugger`** - Debugger instance
- **`backgroundThrottling`** - boolean - Whether to throttle animations when backgrounded
- **`mainFrame`** - WebFrameMain - Top frame of page's frame hierarchy
- **`opener`** - WebFrameMain | null - Frame that opened this WebContents
- **`ipc`** - IpcMain-like interface for this specific WebContents

---

### **Common Use Cases**

#### **1. Handling New Windows**

```javascript
contents.setWindowOpenHandler(({ url, frameName, features }) => {
  if (url.startsWith('https://trusted-domain.com')) {
    return { action: 'allow' }
  }
  return { action: 'deny' }
})

contents.on('did-create-window', (window, details) => {
  console.log('New window created:', details.url)
})
```

#### **2. Secure IPC**

```javascript
// Main process
contents.send('update-data', { value: 42 })

// Listen to specific WebContents
contents.ipc.on('channel', (event, data) => {
  console.log('Received from this WebContents:', data)
})
```

#### **3. Certificate Errors**

```javascript
contents.on('certificate-error', (event, url, error, certificate, callback) => {
  event.preventDefault()
  // Perform custom validation
  callback(isValid)
})
```

#### **4. Page Recovery**

```javascript
contents.on('unresponsive', async () => {
  const { response } = await dialog.showMessageBox({
    message: 'Page is unresponsive',
    buttons: ['Reload', 'Wait']
  })
  
  if (response === 0) {
    contents.forcefullyCrashRenderer()
    contents.reload()
  }
})
```

---

### **Important Notes**

1. **Context Isolation**: When using executeJavaScriptInIsolatedWorld, world ID 999 is used by Electron's contextIsolation feature

2. **Event Prevention**: Calling event.preventDefault() on cancellable navigation events will prevent the navigation

3. **Frame vs Main Frame**: will-navigate and did-navigate only fire when the mainFrame navigates. For iframe navigation, use will-frame-navigate and did-frame-navigate

4. **Zoom Policy**: The zoom policy at the Chromium level is same-origin, meaning zoom level propagates across all instances of windows with the same domain

5. **Printing**: Calling window.print() in web page is equivalent to calling webContents.print with default settings

---

