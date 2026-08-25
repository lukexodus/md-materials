## Renderer Process Debugging (DevTools)


Chromium Developer Tools (DevTools) provide comprehensive debugging capabilities for Electron's renderer processes, offering the same powerful debugging environment available in Chrome for web development. DevTools can inspect and debug all renderer process instances including BrowserWindow, BrowserView, and WebView.[1][2][3]

### Opening DevTools Programmatically

DevTools are accessed programmatically by calling the `openDevTools()` method on the `webContents` property of BrowserWindow instances. This method can be invoked at any point during the window lifecycle, typically in the main process after window creation.[2][3]

```javascript
const { BrowserWindow } = require('electron')

const win = new BrowserWindow()
win.webContents.openDevTools()
```

The `openDevTools()` method opens DevTools in their default configuration, attaching them to the BrowserWindow. For applications that need DevTools available during development but hidden in production, call this method conditionally based on environment checks.[3][2]

### DevTools Configuration Options

The `openDevTools()` method accepts an options object that controls DevTools presentation and behavior. The `mode` option determines how DevTools appear, accepting values `right`, `bottom`, `undocked`, and `detach`. The `right` value docks DevTools to the right side of the window, `bottom` docks them below the content, `undocked` opens them in a separate window, and `detach` opens them in a detachable window.[4][5]

The `activate` option controls whether DevTools receive focus when opened, defaulting to `true`. Setting it to `false` opens DevTools without shifting focus from the main window content, useful for debugging scenarios where focus state affects behavior. The `title` option sets a custom DevTools window title when opened in detached mode.[5]

```javascript
win.webContents.openDevTools({ 
  mode: 'detach',
  activate: false,
  title: 'Debugging Main Window'
})
```

### Keyboard Shortcuts and User Access

DevTools can be opened through keyboard shortcuts in addition to programmatic control. The standard shortcuts are F12, Ctrl+Shift+I (Windows/Linux), or Cmd+Option+I (macOS). These shortcuts work automatically in development builds but can be disabled in production by preventing the corresponding menu items or key events.[6]

Custom keyboard shortcuts can be implemented by listening for key events in the renderer and calling `openDevTools()` through IPC communication with the main process. Right-clicking in the renderer also provides a context menu option to "Inspect" or "Inspect Element," opening DevTools focused on the selected element.[2][6]

```javascript
document.addEventListener('keyup', ({ key, ctrlKey, shiftKey }) => {
  if ((key === 'F12') || (ctrlKey && shiftKey && key === 'I')) {
    require('electron').remote.getCurrentWebContents().openDevTools()
  }
})
```

### Closing and Controlling DevTools

DevTools can be closed programmatically using `webContents.closeDevTools()`, which removes the DevTools panel from view. The `isDevToolsOpened()` method returns a boolean indicating whether DevTools are currently open for a given webContents instance. The `isDevToolsFocused()` method checks whether DevTools have keyboard focus.[5]

The `toggleDevTools()` method provides a convenient way to open or close DevTools based on their current state. This method is ideal for implementing toggle shortcuts that switch DevTools visibility with a single key press.[5]

### DevTools Events

#### DevTools lifecycle events

These events tell you _when DevTools change state_.

##### `devtools-opened`

Emitted when DevTools are opened.

Common uses:  
• Resize or reposition windows  
• Disable certain UI features  
• Log debugging activity

Example:

```js
mainWindow.webContents.on('devtools-opened', () => {
  console.log('DevTools opened');
});
```

Output:

```
DevTools opened
```

---

##### `devtools-closed`

Emitted when DevTools are closed.

Example:

```js
mainWindow.webContents.on('devtools-closed', () => {
  console.log('DevTools closed');
});
```

Output:

```
DevTools closed
```

---

##### `devtools-focused`

Emitted when DevTools gain focus (for example, when the user clicks inside them).

This is useful if you want to know whether keyboard input is going to the page or to DevTools.

Example:

```js
mainWindow.webContents.on('devtools-focused', () => {
  console.log('DevTools focused');
});
```

Output:

```
DevTools focused
```

---

#### DevTools interaction events

These events fire when the user performs actions _inside_ DevTools.

##### `devtools-reload-page`

Emitted when the reload button in DevTools is pressed.

Important distinction:  
This is **not** the same as `did-navigate` or a normal page reload. It specifically means the reload came from DevTools.

Example:

```js
mainWindow.webContents.on('devtools-reload-page', () => {
  console.log('Page reloaded from DevTools');
});
```

Output:

```
Page reloaded from DevTools
```

---

##### `devtools-open-url`

Emitted when a link inside DevTools is opened (for example, “Open in new tab”).

Electron passes the URL as an argument.

Example:

```js
mainWindow.webContents.on('devtools-open-url', (event, url) => {
  console.log('DevTools opened URL:', url);
});
```

Output:

```
DevTools opened URL: https://example.com/script.js
```

This is often used to:  
• Open links in an external browser  
• Prevent navigation to certain URLs  
• Log inspection activity

Example with external browser:

```js
const { shell } = require('electron');

mainWindow.webContents.on('devtools-open-url', (event, url) => {
  event.preventDefault();
  shell.openExternal(url);
});
```

---

##### `devtools-search-query`

Emitted when “Search” is used from the DevTools context menu.

Electron passes the selected search query.

Example:

```js
mainWindow.webContents.on('devtools-search-query', (event, query) => {
  console.log('DevTools search query:', query);
});
```

Output:

```
DevTools search query: ipcRenderer.send
```

This is useful for:  
• Auditing debugging behavior  
• Teaching tools or tutorials  
• Custom analytics in internal apps

---

#### Practical summary

Think of DevTools events as **signals from the debugger itself**.

• Lifecycle events (`opened`, `closed`, `focused`) tell you _state changes_  
• Interaction events (`reload-page`, `open-url`, `search-query`) tell you _what the developer is doing_

Together, they allow you to adapt UI behavior, enforce policies, or observe debugging sessions without modifying the page code itself.

### Disabling DevTools

DevTools access can be completely disabled by setting `webPreferences.devTools: false` in the BrowserWindow constructor options. When disabled, `openDevTools()` has no effect and keyboard shortcuts do not open DevTools. This security measure prevents users from inspecting production application code and is recommended for deployed applications.[8][7]

Production builds should disable DevTools using the `app.isPackaged` flag to differentiate between development and production environments. This ensures DevTools remain available during development while being inaccessible in distributed applications.[7]

```javascript
const win = new BrowserWindow({
  webPreferences: {
    devTools: !app.isPackaged // Disable in packaged/production builds
  }
})
```

### Chrome DevTools Protocol Integration

Advanced debugging scenarios can leverage the Chrome DevTools Protocol (CDP) for programmatic control over debugging capabilities. The `webContents.debugger` API provides access to CDP commands across various domains like Runtime, DOM, Network, and Performance.

#### Attaching the Debugger

The debugger must be attached before sending commands using `webContents.debugger.attach(protocolVersion)`. The protocol version string (like `'1.3'`) specifies which CDP version to use.

```javascript
const { BrowserWindow } = require('electron');

const win = new BrowserWindow({ width: 800, height: 600 });

try {
  win.webContents.debugger.attach('1.3');
  console.log('Debugger attached successfully');
} catch (err) {
  console.log('Debugger attach failed:', err);
}
```

**[Inference]** Attaching may fail if another debugger is already attached or if the webContents is not ready.

#### Sending CDP Commands

Commands are sent via `debugger.sendCommand(method, commandParams)`, which returns a Promise resolving with the command response. The method string follows CDP naming conventions (Domain.method).

```javascript
// Enable network monitoring
win.webContents.debugger.sendCommand('Network.enable');

// Get cookies for a URL
win.webContents.debugger.sendCommand('Network.getCookies', {
  urls: ['https://example.com']
}).then(({ cookies }) => {
  console.log('Cookies:', cookies);
});

// Take a screenshot
win.webContents.debugger.sendCommand('Page.captureScreenshot', {
  format: 'png'
}).then(({ data }) => {
  require('fs').writeFileSync('screenshot.png', data, 'base64');
});
```

#### Listening to Debugger Events

The debugger emits events when messages are received or when it detaches. You can monitor specific CDP events to track browser activity.

```javascript
// Listen for detach events
win.webContents.debugger.on('detach', (event, reason) => {
  console.log('Debugger detached due to:', reason);
});

// Listen for CDP protocol messages
win.webContents.debugger.on('message', (event, method, params) => {
  if (method === 'Network.requestWillBeSent') {
    console.log('Network request:', params.request.url);
  }
  
  if (method === 'Console.messageAdded') {
    console.log('Console message:', params.message.text);
  }
});

// Enable console domain to receive console messages
win.webContents.debugger.sendCommand('Console.enable');
```

#### Common CDP Domains and Use Cases

##### Network Domain

Monitor and control network activity:

```javascript
// Enable network tracking
await win.webContents.debugger.sendCommand('Network.enable');

// Set custom headers
await win.webContents.debugger.sendCommand('Network.setExtraHTTPHeaders', {
  headers: {
    'X-Custom-Header': 'value'
  }
});

// Emulate network conditions
await win.webContents.debugger.sendCommand('Network.emulateNetworkConditions', {
  offline: false,
  latency: 100, // ms
  downloadThroughput: 750 * 1024 / 8, // 750kb/s
  uploadThroughput: 250 * 1024 / 8
});
```

##### Runtime Domain

Execute JavaScript and interact with the runtime:

```javascript
// Evaluate JavaScript expression
const result = await win.webContents.debugger.sendCommand('Runtime.evaluate', {
  expression: 'document.title',
  returnByValue: true
});
console.log('Page title:', result.result.value);

// Call a function with arguments
await win.webContents.debugger.sendCommand('Runtime.callFunctionOn', {
  functionDeclaration: 'function(x, y) { return x + y; }',
  arguments: [{ value: 5 }, { value: 3 }],
  returnByValue: true
});
```

##### Page Domain

Control page behavior and capture screenshots:

```javascript
// Navigate to a URL
await win.webContents.debugger.sendCommand('Page.navigate', {
  url: 'https://example.com'
});

// Get page layout metrics
const metrics = await win.webContents.debugger.sendCommand('Page.getLayoutMetrics');
console.log('Page dimensions:', metrics.contentSize);

// Print to PDF
const { data } = await win.webContents.debugger.sendCommand('Page.printToPDF', {
  landscape: false,
  displayHeaderFooter: false,
  printBackground: true
});
require('fs').writeFileSync('page.pdf', data, 'base64');
```

##### Performance Domain

Monitor performance metrics:

```javascript
// Enable performance monitoring
await win.webContents.debugger.sendCommand('Performance.enable');

// Get performance metrics
const { metrics } = await win.webContents.debugger.sendCommand('Performance.getMetrics');
metrics.forEach(metric => {
  console.log(`${metric.name}: ${metric.value}`);
});
```

#### Target-Specific Debugging

The `webContents.fromDevToolsTargetId(targetId)` method retrieves a WebContents instance associated with a specific Chrome DevTools Protocol target. This enables debugging of specific targets when multiple debugging sessions are active.

```javascript
const { webContents } = require('electron');

// Get all targets
win.webContents.debugger.sendCommand('Target.getTargets').then(({ targetInfos }) => {
  targetInfos.forEach(target => {
    console.log('Target:', target.targetId, target.type, target.url);
    
    // Get WebContents for a specific target
    const targetWebContents = webContents.fromDevToolsTargetId(target.targetId);
    if (targetWebContents) {
      console.log('Found WebContents for target:', target.targetId);
    }
  });
});
```

#### Complete Debugging Example

```javascript
const { app, BrowserWindow } = require('electron');

app.whenReady().then(() => {
  const win = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      nodeIntegration: false,
      contextIsolation: true
    }
  });

  // Attach debugger
  try {
    win.webContents.debugger.attach('1.3');
  } catch (err) {
    console.error('Failed to attach debugger:', err);
    return;
  }

  // Handle detach
  win.webContents.debugger.on('detach', (event, reason) => {
    console.log('Debugger detached:', reason);
  });

  // Monitor network requests
  win.webContents.debugger.on('message', (event, method, params) => {
    if (method === 'Network.responseReceived') {
      console.log('Response:', params.response.status, params.response.url);
    }
  });

  // Enable monitoring domains
  async function setupDebugging() {
    await win.webContents.debugger.sendCommand('Network.enable');
    await win.webContents.debugger.sendCommand('Console.enable');
    await win.webContents.debugger.sendCommand('Performance.enable');
  }

  setupDebugging().then(() => {
    win.loadURL('https://example.com');
  });

  // Detach when window closes
  win.on('closed', () => {
    if (win.webContents.debugger.isAttached()) {
      win.webContents.debugger.detach();
    }
  });
});
```

#### Error Handling

```javascript
try {
  await win.webContents.debugger.sendCommand('Network.enable');
} catch (error) {
  console.error('CDP command failed:', error.message);
}

// Check if debugger is attached before sending commands
if (win.webContents.debugger.isAttached()) {
  await win.webContents.debugger.sendCommand('Console.enable');
}
```

**Note:** The Chrome DevTools Protocol documentation provides the full list of available domains and commands. **[Unverified]** The specific CDP version support may vary between Electron versions.

### Development Tools Packages

The `electron-debug` npm package simplifies DevTools integration during development. Installing it with `npm install electron-debug --save-dev` and requiring it in the main process with `require('electron-debug')()` automatically adds DevTools keyboard shortcuts and other debugging conveniences.[2][7]

This package enables features like right-click context menu inspection, automatic DevTools opening on errors, and enhanced debugging shortcuts with minimal configuration. It's particularly useful for rapid development workflows where consistent DevTools access across all windows is desired.[7]

### Debugging Renderer Crashes

When renderer processes crash, DevTools can help diagnose the root cause through crash event handlers. Listening for the `crashed` event on webContents captures crash occurrences and enables logging or automated error reporting.[7]

```javascript
win.webContents.on('crashed', (event, killed) => {
  console.log('Renderer crashed:', { killed })
  // Log crash details, restart renderer, or notify user
})
```

Memory leaks and performance issues are identified using DevTools' Memory and Performance panels. Taking heap snapshots in the Memory tab reveals leaking objects, while the Performance panel profiles CPU usage and identifies bottlenecks. These tools are identical to those in Chrome, with extensive documentation from Google available for reference.[3][7]

### V8 Crash Debugging

If the V8 JavaScript engine crashes, DevTools display the message "DevTools was disconnected from the page. Once page is reloaded, DevTools will automatically reconnect.". Chromium logs can be enabled via the `ELECTRON_ENABLE_LOGGING` environment variable or the `--enable-logging` command line flag to capture detailed crash information.[3]

These logs provide insights into V8 crashes, memory corruption, and other low-level issues that may not be visible through standard DevTools inspection. Analyzing Chromium logs helps diagnose crashes that occur during JavaScript execution or garbage collection.[3]

### Remote Debugging

For debugging renderer processes in production or remote environments, Electron supports remote debugging through CDP. Starting Electron with debugging flags enables remote DevTools connections from Chrome or other CDP-compatible tools. This allows developers to debug deployed applications without modifying the application code.[9]

The `electron://` protocol scheme can be used to list debugging targets and inspect specific processes via CDP. This advanced technique enables monitoring and controlling multiple Electron processes simultaneously through standardized debugging APIs.[9]

### Visual Studio Code Integration

VS Code provides integrated debugging for Electron renderer processes through its built-in debugger. Creating a `.vscode/launch.json` configuration with appropriate settings enables breakpoint debugging directly in the editor. The configuration should specify Node.js as the runtime type and point to the Electron executable.[10][11][7]

```json
{
  "type": "node",
  "request": "launch",
  "name": "Debug Renderer Process",
  "runtimeExecutable": "${workspaceFolder}/node_modules/.bin/electron",
  "program": "${workspaceFolder}/main.js",
  "outputCapture": "std"
}
```

This integration combines DevTools functionality with VS Code's debugging interface, providing features like variable inspection, call stack navigation, and inline value display during debugging sessions.[11][10]

Sources
[1] Application Debugging | Electron https://electronjs.org/docs/latest/tutorial/application-debugging
[2] Tips and Tricks for Debugging Electron Applications - SitePoint https://www.sitepoint.com/debugging-electron-application/
[3] Electron - Close initial window but keep child open - Stack Overflow https://stackoverflow.com/questions/48224116/electron-close-initial-window-but-keep-child-open
[4] webContents https://electronjs.org/docs/latest/api/web-contents
[5] Master Electron: BrowserWindow - Parent & Child Windows - YouTube https://www.youtube.com/watch?v=l75UxvoRyI4
[6] How to include Chrome DevTools in Electron? https://stackoverflow.com/questions/30294600/how-to-include-chrome-devtools-in-electron
[7] Debugging and Troubleshooting Common Electron Issues https://blog.openreplay.com/debugging-troubleshooting-electron-issues/
[8] BrowserWindow · GitBook http://electron.ebookchain.org/en/api/browser-window.html
[9] Electron Debug MCP Server https://github.com/amafjarkasi/electron-mcp-server
[10] Debugging Electron renderer process with VSCode - Stack Overflow https://stackoverflow.com/questions/52844870/debugging-electron-renderer-process-with-vscode
[11] A guide on how to debug an Electron app. - GitHub https://github.com/DrifterAtSea/debugging-electron
[12] Debugging the Main Process | Electron https://electronjs.org/docs/latest/tutorial/debugging-main-process
[13] Debugging Magic with Vue Devtools https://vueschool.io/articles/vuejs-tutorials/debugging-magic-with-vue-devtools/

---

