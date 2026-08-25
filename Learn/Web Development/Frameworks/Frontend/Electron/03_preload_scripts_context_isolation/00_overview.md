## Overview


### Preload Script Purpose and Architecture

A preload script contains code that runs before a web page loads into the browser window, serving as a secure bridge between Electron's main process and renderer process. It operates in a unique context with access to both DOM APIs and a limited Node.js environment.[1][4][6]

#### Purpose

**Security Bridge**
- Allows secure exposure of privileged APIs to the renderer process without full Node.js access[3][1]
- Solves the security problem: renderer processes don't run Node.js by default for safety[1]
- Prevents malicious web content from accessing operating system-level functionality directly[4][1]
- Acts as a controlled gateway for communication between isolated processes[1]

**Key Use Cases**
- Exposing whitelisted Node.js functionality to the renderer[3][4]
- Setting up inter-process communication (IPC) interfaces[3][1]
- Augmenting the renderer with privileged features that require OS access[1]
- Injecting global objects and functions into the renderer's window object[6][1]

#### Architecture

**Execution Context**
- Runs in a special context that has access to both HTML DOM and Node.js APIs[5][1]
- Executes before any DOM content or other JavaScript files load[5][6]
- Injected similar to a Chrome extension's content scripts[1]
- From Electron 20 onwards, preload scripts are sandboxed by default with limited Node.js access[1]

**Process Isolation**
- Preload scripts are isolated from the renderer's main world through Context Isolation[2][10]
- This prevents leaking privileged APIs into web content's code[2]
- Without context isolation, malicious JavaScript could alter exposed functions[10]
- Isolation ensures that renderer code cannot directly access the preload script's scope[2]

#### Implementation Architecture

**Configuration**
Specify the preload script in BrowserWindow's webPreferences:[4][1]
```javascript
const mainWindow = new BrowserWindow({
  webPreferences: {
    preload: path.join(__dirname, 'preload.js'),
    contextIsolation: true // recommended for security
  }
});
```


**Using contextBridge**
The contextBridge API is the secure method to expose functionality:[3][1]
```javascript
// preload.js
const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('api', {
  send: (channel, data) => {
    // whitelist channels
    let validChannels = ['toMain'];
    if (validChannels.includes(channel)) {
      ipcRenderer.send(channel, data);
    }
  }
});
```


**Renderer Access**
The exposed API becomes available in the renderer:[4][3]
```javascript
// renderer.js
window.api.send('toMain', { message: 'Hello' });
```


#### Security Best Practices

**Never Expose Entire Modules**
- Never directly expose the entire `ipcRenderer` module[3][1]
- This would give the renderer ability to send arbitrary IPC messages[1]
- Creates a powerful attack vector for malicious code[1]
- Always expose whitelisted wrappers around specific functionality[3]

**Whitelist Channels**
- Only allow specific, validated channels for IPC communication[3]
- Validate and sanitize data passed through exposed functions[3]
- Limit exposed functionality to the minimum required[4]

**Enable Context Isolation**
- Always set `contextIsolation: true` in webPreferences[4][3]
- This is the default since Electron 12 and recommended for all apps[2]
- Prevents renderer JavaScript from accessing preload script variables[2]

#### Code Organization

**Separation of Concerns**
Preload scripts enable proper separation between processes:[3]
- **Main process**: Event handling, OS-level operations, file system access
- **Preload process**: Expose user-defined endpoints, bridge IPC communication
- **Renderer process**: UI logic, DOM manipulation, user interactions

**Example Structure**
```javascript
// preload.js - expose wrapper functions
const { contextBridge } = require('electron');
const crypto = require('crypto');

contextBridge.exposeInMainWorld('nodeCrypto', {
  sha256sum(data) {
    const hash = crypto.createHash('sha256');
    hash.update(data);
    return hash.digest('hex');
  }
});
```


#### File Location

Preload scripts are typically located at `/src-electron/electron-preload.js` or in the project root. The path is specified relative to the main process file.[4][1]

#### Execution Timing

Preload scripts run before the renderer process loads, giving them the ability to set up the environment and inject APIs before any user code executes. This timing is critical for establishing secure communication channels and exposing controlled functionality.[6][1]

Sources
[1] Using Preload Scripts https://electronjs.org/docs/latest/tutorial/tutorial-preload
[2] Process Model https://electronjs.org/docs/latest/tutorial/process-model
[3] How to use preload.js properly in Electron https://stackoverflow.com/questions/57807459/how-to-use-preload-js-properly-in-electron
[4] Electron Preload Script https://quasar.dev/quasar-cli-vite/developing-electron-apps/electron-preload-script/
[5] Getting Started w/ Electron #3 - Preload Scripts https://www.youtube.com/watch?v=RuNnmDwgXCQ
[6] Development https://electron-vite.org/guide/dev
[7] s Service Worker Preload Scripts | Mamezou Developer Portal https://developer.mamezou-tech.com/en/blogs/2025/03/31/electron-v35-service-worker-preload-scripts/
[8] Define preload script inline in main.js webPreferences https://github.com/electron/electron/issues/28981
[9] How to use preload script in Electron Webview with React https://dev.to/dani/how-to-use-preload-script-in-electron-webview-with-react-2h2f
[10] Preloading Insecurity In Your Electron https://doyensec.com/resources/Asia-19-Carettoni-Preloading-Insecurity-In-Your-Electron.pdf


---

### Context Bridge API

The Context Bridge is Electron's module that creates a safe, bi-directional, synchronous bridge across isolated contexts, allowing preload scripts to securely expose APIs to the renderer process. It runs in the renderer process and is the recommended method for exposing privileged functionality to web pages.[1][5][6]

#### Core Methods

**exposeInMainWorld(apiKey, api)**
- The primary method for exposing APIs to the renderer's main world[5][1]
- `apiKey` (string): The name under which the API will be accessible on `window`[1]
- `api` (any): The API object containing methods and properties to expose[1]
- Accessed in renderer as `window[apiKey]`[5][1]

**Basic Example**
```javascript
// Preload (Isolated World)
const { contextBridge, ipcRenderer } = require('electron')

contextBridge.exposeInMainWorld(
  'electron',
  {
    doThing: () => ipcRenderer.send('do-a-thing')
  }
)

// Renderer (Main World)
window.electron.doThing()
```


**exposeInIsolatedWorld(worldId, apiKey, api)**
- Exposes API to a specific isolated world by ID[5][1]
- `worldId` (Integer): The ID of the world (0 = default, 999 = Electron's contextIsolation, 1000+ recommended for custom worlds)[1][5]
- Useful for advanced isolation scenarios and custom contexts[1]

**executeInMainWorld(executionScript)**
- Executes JavaScript code in the main world context[1]
- Allows running code in the renderer's context from preload[1]

#### Why Context Bridge Matters

**Security Enhancement**
- Prevents direct exposure of powerful APIs like `ipcRenderer` to the renderer[2][4]
- Protects against malicious web content accessing Node.js or Electron APIs[2]
- Allows selective, whitelisted API exposure instead of full module access[4][2]
- Functions are proxied while data values are copied and frozen for immutability[2][5][1]

**Context Isolation**
- Works with Context Isolation feature to separate Electron APIs from web content[6]
- When `contextIsolation` is enabled, preload scripts run in isolated context[6]
- Context Bridge safely bridges the gap between isolated preload and main renderer contexts[6]
- Without it, APIs cannot be exposed when context isolation is enabled[6]

#### Supported Data Types

**Type Support Table**
The bridge supports specific types for parameters and return values:[5][1]

- ✅ Primitives: `string`, `number`, `boolean`
- ✅ `Function` (proxied to other context)
- ✅ `Promise` (resolved or rejected)
- ✅ `Array` (containing supported types)
- ✅ Plain objects (with supported property types)
- ✅ Nested objects (with supported types)
- ❌ Custom prototypes
- ❌ Symbols
- ❌ `ipcRenderer` directly (as of recent Electron versions)[5]

#### Value Handling

**Copying vs Proxying**
- Function values are **proxied** to the other context[2][5][1]
- All other values are **copied and frozen**[2][5][1]
- Data/primitives sent via the API become immutable[2][1]
- Updates on either side of the bridge do not result in updates on the other side[5][1]

#### Complex API Example

```javascript
const { contextBridge, ipcRenderer } = require('electron')

contextBridge.exposeInMainWorld(
  'electron',
  {
    doThing: () => ipcRenderer.send('do-a-thing'),
    myPromises: [Promise.resolve(), Promise.reject(new Error('whoops'))],
    anAsyncFunction: async () => 123,
    data: {
      myFlags: ['a', 'b', 'c'],
      bootTime: 1234
    },
    nestedAPI: {
      evenDeeper: {
        youCanDoThisAsMuchAsYouWant: {
          fn: () => ({ returnData: 123 })
        }
      }
    }
  }
)
```


#### Real-World Usage Pattern

**Preload Script**
```javascript
const { contextBridge } = require('electron')
const crypto = require('node:crypto')

contextBridge.exposeInMainWorld('nodeCrypto', {
  sha256sum(data) {
    const hash = crypto.createHash('sha256')
    hash.update(data)
    return hash.digest('hex')
  }
})
```


**Renderer Access**
```javascript
const hashed = window.nodeCrypto.sha256sum('my data')
```


#### Context Detection Pattern

```javascript
import { contextBridge } from 'electron'
import { electronAPI } from '@electron-toolkit/preload'

if (process.contextIsolated) {
  try {
    contextBridge.exposeInMainWorld('electron', electronAPI)
  } catch (error) {
    console.error(error)
  }
} else {
  window.electron = electronAPI
}
```


#### Limitations

- Cannot send custom prototypes or symbols over the bridge[6]
- `ipcRenderer` can no longer be sent directly over contextBridge (breaking change in recent versions)[5]
- Must wrap IPC functionality in custom functions instead of exposing entire modules[2]
- All non-function values are immutable after crossing the bridge[1][5]

#### Best Practices

Always use Context Bridge instead of the deprecated approach of directly modifying `window` in preload scripts. This ensures security and compatibility with context isolation enabled.[6][2]

Sources
[1] contextBridge https://electronjs.org/docs/latest/api/context-bridge
[2] Electron 'contextBridge' - javascript https://stackoverflow.com/questions/59993468/electron-contextbridge
[3] electron/lib/renderer/api/context-bridge.ts at main https://github.com/electron/electron/blob/master/lib/renderer/api/context-bridge.ts
[4] 04 - Electronjs contextBridge and how to use main process ... https://www.youtube.com/watch?v=NkQxyW5mlZI
[5] contextBridge https://www.electronjs.org/docs/latest/api/context-bridge
[6] Context Isolation https://electronjs.org/docs/latest/tutorial/context-isolation
[7] Development https://electron-vite.org/guide/dev
[8] The Context Bridge class in electronjs - Dustin Pfister https://dustinpfister.github.io/2022/02/21/electronjs-context-bridge/
[9] Can't seem to get ipcRenderer / contextBridge working and ... https://www.reddit.com/r/electronjs/comments/17xd549/cant_seem_to_get_ipcrenderer_contextbridge/
[10] here - GitHub https://raw.githubusercontent.com/electron/electron/main/docs/breaking-changes.md


---

### Exposing APIs to Renderer Process

Exposing APIs to the renderer process in Electron requires careful implementation to maintain security while providing necessary functionality. The recommended approach uses preload scripts with the Context Bridge API to selectively expose whitelisted methods.[1][2][3]

#### The Security Problem

**Why Direct Access Is Disabled**
- Renderer processes have no Node.js or Electron module access by default[2][3]
- This protects against malicious web content accessing privileged system APIs[4]
- Enabling `nodeIntegration` in the renderer exposes your app to serious vulnerabilities[4]
- Attackers could run arbitrary scripts with full system access if Node.js is exposed[4]

#### The Secure Solution: Preload Scripts + Context Bridge

**Step 1: Configure BrowserWindow**
Set up proper security options in your window configuration:[5][6]
```javascript
mainWindow = new BrowserWindow({
  width: 800,
  height: 600,
  webPreferences: {
    nodeIntegration: false, // Keep disabled for security
    contextIsolation: true, // Isolate preload from renderer
    enableRemoteModule: false, // Disable remote module
    preload: path.join(__dirname, 'preload.js')
  }
})
```


**Step 2: Create Preload Script with Exposed APIs**
Define which APIs the renderer can access:[6][1][2]
```javascript
// preload.js
const { contextBridge, ipcRenderer } = require('electron')

contextBridge.exposeInMainWorld('electronAPI', {
  openFile: () => ipcRenderer.invoke('dialog:openFile'),
  ping: () => ipcRenderer.invoke('ping'),
  onUpdateCounter: (callback) => ipcRenderer.on('update-counter', callback)
})
```


**Step 3: Use Exposed API in Renderer**
Access the API through the global window object:[2][6]
```javascript
// renderer.js
const btn = document.getElementById('btn')
btn.addEventListener('click', async () => {
  const filePath = await window.electronAPI.openFile()
})
```


#### Best Practices for Exposing APIs

**Never Expose Entire Modules**
- Don't directly expose `ipcRenderer.invoke` or other complete APIs[2]
- Limit renderer's access to Electron APIs as much as possible[2]
- Only expose specific, whitelisted functionality[2]

**Example - Wrong Approach:**
```javascript
// ❌ INSECURE - Don't do this
contextBridge.exposeInMainWorld('electron', {
  ipcRenderer: require('electron').ipcRenderer
})
```


**Example - Correct Approach:**
```javascript
// ✅ SECURE - Expose specific functions only
contextBridge.exposeInMainWorld('electronAPI', {
  openFile: () => ipcRenderer.invoke('dialog:openFile')
})
```


**Avoid Callback Leakage**
- Don't pass callbacks directly to `ipcRenderer.on`[2]
- This would leak `ipcRenderer` via `event.sender`[2]
- Use custom handlers that invoke callbacks safely[2]

**Example - Secure Callback Pattern:**
```javascript
contextBridge.exposeInMainWorld('electronAPI', {
  onUpdateCounter: (callback) => {
    ipcRenderer.on('update-counter', (_event, value) => callback(value))
  }
})
```


#### Development Efficiency Tool

**Using @electron-toolkit/preload**
For faster development, use the official toolkit:[1]
```javascript
import { contextBridge } from 'electron'
import { electronAPI } from '@electron-toolkit/preload'

if (process.contextIsolated) {
  try {
    contextBridge.exposeInMainWorld('electron', electronAPI)
  } catch (error) {
    console.error(error)
  }
} else {
  window.electron = electronAPI
}
```


This provides easy access to `ipcRenderer`, `webFrame`, and `process` in the renderer.[1]

#### Real-World Example: Authentication & API Calls

**Preload API Definition**
```javascript
// main/preload.js
const { contextBridge, ipcRenderer } = require("electron");

const electronAPI = {
  getProfile: () => ipcRenderer.invoke('auth:get-profile'),
  logOut: () => ipcRenderer.send('auth:log-out'),
  getPrivateData: () => ipcRenderer.invoke('api:get-private-data')
};

process.once("loaded", () => {
  contextBridge.exposeInMainWorld('electronAPI', electronAPI);
});
```


**Renderer Usage**
```javascript
// renderer process
const profile = await window.electronAPI.getProfile()
const privateData = await window.electronAPI.getPrivateData()
```


#### Context Isolation Requirement

Context isolation creates a clear separation between the renderer and main process. When enabled (default in modern Electron):[6]
- Preload scripts run in an isolated context[6]
- Renderer cannot access preload variables directly[6]
- Must use Context Bridge to expose APIs[6]
- Ensures security even if malicious code runs in renderer[6]

#### Common Patterns

**Two-Way IPC (Invoke Pattern)**
Use `ipcRenderer.invoke()` for request-response communication:[2]
```javascript
// Preload
contextBridge.exposeInMainWorld('electronAPI', {
  openFile: () => ipcRenderer.invoke('dialog:openFile')
})

// Renderer
const result = await window.electronAPI.openFile()
```


**One-Way IPC (Send Pattern)**
Use `ipcRenderer.send()` for fire-and-forget messages:[6][2]
```javascript
// Preload
contextBridge.exposeInMainWorld('electronAPI', {
  logOut: () => ipcRenderer.send('auth:log-out')
})

// Renderer
window.electronAPI.logOut()
```


#### Security Checklist

When exposing APIs to the renderer process:[7][4][2]
- ✅ Keep `nodeIntegration: false`
- ✅ Enable `contextIsolation: true`
- ✅ Use preload scripts with Context Bridge
- ✅ Whitelist specific functions only
- ✅ Validate all data from renderer
- ✅ Never expose complete modules
- ✅ Disable `enableRemoteModule`
- ❌ Never enable Node integration in renderer
- ❌ Never expose `ipcRenderer` directly

Sources
[1] Development | electron-vite https://electron-vite.org/guide/dev
[2] Inter-Process Communication - Electron https://electronjs.org/docs/latest/tutorial/ipc
[3] Using Preload Scripts https://www.electronjs.org/docs/latest/tutorial/tutorial-preload
[4] Best approach to make API calls to server for Electron app [closed] https://stackoverflow.com/questions/79081625/best-approach-to-make-api-calls-to-server-for-electron-app
[5] electron - expose api using contextBridge.exposeInMainWorld - not working in embedded html renderer - window.api undefined https://www.reddit.com/r/node/comments/klghgm/electron_expose_api_using/
[6] Build and Secure an Electron App - OpenID, OAuth, Node.js ... - Auth0 https://auth0.com/blog/securing-electron-applications-with-openid-connect-and-oauth-2/
[7] Security | Electron https://electronjs.org/docs/latest/tutorial/security
[8] Process Model | Electron https://electronjs.org/docs/latest/tutorial/process-model
[9] Penetration Testing of Electron-based Applications - DeepStrike https://deepstrike.io/blog/penetration-testing-of-electron-based-applications
[10] Electron 'contextBridge' https://stackoverflow.com/questions/59993468/electron-contextbridge


---

### Security Considerations and Isolation

Electron applications require careful security configuration because they combine web content with access to Node.js and system-level APIs, creating potential attack vectors if not properly isolated. The framework provides multiple security layers that must be correctly enabled.[1][2]

#### Context Isolation

**What It Is**
- Ensures preload scripts and Electron's internal logic run in a separate JavaScript context from loaded web content[3][4]
- Creates different `window` objects for preload scripts versus the website[3]
- Prevents websites from accessing Electron internals or preload script APIs directly[5][3]

**Why It's Critical**
- Protects against prototype pollution attacks where malicious code modifies JavaScript globals like `Array.prototype.push` or `JSON.parse`[1][5]
- Prevents web content from accessing powerful APIs exposed in preload scripts[4][3]
- Even with `nodeIntegration: false`, context isolation is required for true security[4]
- XSS vulnerabilities become far more dangerous without context isolation[2]

**Configuration**
- Enabled by default since Electron 12[6][1][3]
- Recommended security setting for all applications[3][4]
- Set in webPreferences: `contextIsolation: true`[1][4]
- Never disable context isolation: `contextIsolation: false` is a critical vulnerability[4]

#### Node Integration

**Default Behavior**
- `nodeIntegration: false` by default since Electron 5[7]
- Prevents renderer processes from using Node.js APIs like `require()`[7]
- Disabling node integration also disables process sandboxing for that process[1]

**Security Implications**
- Enabling `nodeIntegration: true` is extremely dangerous[8]
- Allows arbitrary code execution if combined with XSS vulnerabilities[2][8]
- Past CVEs like CVE-2018-1000136 involved nodeIntegration bypass leading to remote code execution[8]
- Client-side attacks in Electron are HIGH severity because of native OS API access[2]

#### Process Sandboxing

**Sandbox Configuration**
- The sandbox should be enabled by default: `sandbox: true`[7]
- Provides OS-level isolation for renderer processes[7]
- Proposed as default in modern Electron versions[7]

**How It Works**
- If `nodeIntegration` is off, there's no way to `require()` native modules or perform filesystem actions[7]
- Adding sandbox doesn't impose additional restrictions when Node integration is disabled[7]
- If `nodeIntegration: true`, sandbox won't activate unless explicitly requested[7]
- Note: `nodeIntegration: true` has no effect when `sandbox: true`[7]

**Recommended Configuration**
```javascript
const mainWindow = new BrowserWindow({
  webPreferences: {
    nodeIntegration: false,
    contextIsolation: true,
    sandbox: true
  }
});
```


#### Additional Security Settings

**Complete Security Configuration**
The following webPreferences should be set for maximum security:[9]
- `nodeIntegration: false` - Disable Node.js in renderer
- `contextIsolation: true` - Isolate preload context
- `sandbox: true` - Enable OS-level sandboxing
- `webSecurity: true` - Enable same-origin policy
- `allowRunningInsecureContent: false` - Block mixed content

#### Common Vulnerabilities

**Injection-Based Attacks**
- XSS vulnerabilities in Electron apps are HIGH severity[2]
- Can allow attackers to invoke OS commands through native API calls[2]
- Over 55+ CVEs registered against Electron apps due to misconfigurations[2]
- Always sanitize user input and validate data from external sources[2]

**nodeIntegration Bypass**
- Historical vulnerability (CVE-2018-1000136) allowed re-enabling nodeIntegration[8]
- Affected Electron versions < 1.7.13, < 1.8.4, or < 2.0.0-beta.3[8]
- Could achieve remote code execution via XSS + webview tag[8]
- Applications using `webviewTag: false` were protected[8]

**Navigation and New Window Vulnerabilities**
- Creation of new browser windows or navigation to untrusted origins can lead to severe vulnerabilities[10]
- Middle-click causes Electron to open links in new windows, potentially executing arbitrary JavaScript[10]
- Limit navigation flows to trusted origins only[10]

**Sandbox Bypass Risks**
- Preload scripts can bypass sandbox using remote module or internal IPC[10]
- Example: `require('electron').remote.app` or `ipcRenderer.sendSync('ELECTRON_BROWSER_GET_BUILTIN', 'app')`[10]
- Always audit preload script code for sandbox escape attempts[10]

#### Security Best Practices

**Enable All Isolation Features**
1. Keep `nodeIntegration: false`[4][1][7]
2. Enable `contextIsolation: true`[3][1][4]
3. Enable `sandbox: true`[9][7]
4. Use preload scripts with Context Bridge for API exposure[1]
5. Never expose complete modules like `ipcRenderer`[10]

**Additional Hardening**
- Disable debugging features in production[10]
- Review all `appendArgument` and `appendSwitch` calls[10]
- Set `webviewTag: false` if not needed[8]
- Implement Content Security Policy (CSP)[2]
- Validate and sanitize all user input[2]

**Data Security**
- Use platform secure storage (Keychain, DPAPI, libsecret, or keytar)[9]
- Encrypt sensitive data at rest[9]
- Enforce owner-only file permissions[9]
- Require authentication for IPC or HTTP endpoints[9]

#### Why Isolation Matters

Without proper isolation, a single XSS vulnerability can escalate to complete system compromise because the attacker gains access to Node.js APIs and native system calls. Modern Electron security assumes defense-in-depth: multiple layers (no Node integration + context isolation + sandboxing) work together to protect applications even when individual components fail.[4][2][7]

Sources
[1] Security https://electronjs.org/docs/latest/tutorial/security
[2] Hunting Common Misconfigurations in Electron Apps - Part 1 https://www.cobalt.io/blog/common-misconfigurations-electron-apps-part-1
[3] Context Isolation https://electronjs.org/docs/latest/tutorial/context-isolation
[4] Context isolation is disabled in Electron - JS-S1020 https://deepsource.com/directory/javascript/issues/JS-S1020
[5] electron/docs/tutorial/security.md at master https://github.com/lecoursen/electron/blob/master/docs/tutorial/security.md
[6] Should I use Context Isolation with my Electron App https://stackoverflow.com/questions/63826089/should-i-use-context-isolation-with-my-electron-app
[7] Enable `sandbox: true` by default for `BrowserWindow` · Issue #28466 https://github.com/electron/electron/issues/28466
[8] CVE-2018-1000136 - Electron nodeIntegration Bypass - LevelBlue https://levelblue.com/blogs/spiderlabs-blog/cve-2018-1000136-electron-nodeintegration-bypass
[9] Penetration Testing of Electron-based Applications https://deepstrike.io/blog/penetration-testing-of-electron-based-applications
[10] Electron Security Checklist https://doyensec.com/resources/us-17-Carettoni-Electronegativity-A-Study-Of-Electron-Security-wp.pdf


---

### Node.js Modules in Preload Scripts

Preload scripts have special access to Node.js modules that renderer processes don't, but this access is limited and has changed significantly in recent Electron versions. Understanding what's available is critical for secure application development.[1][2][3]

#### Node.js Access in Preload Scripts

**What Preload Scripts Can Access**
- Preload scripts run in a privileged environment with access to Node.js built-in modules[4][1]
- Can use `require()` to import Node.js modules and npm packages[3][1]
- Have access to Electron's renderer process modules[3]
- Can bridge Node.js functionality to the renderer via Context Bridge[5][6]

**Why This Matters**
- Renderer processes don't have Node.js access by default for security reasons[1][4][3]
- Preload scripts serve as the secure bridge to expose needed Node.js functionality[7][1]
- This separation prevents untrusted web content from accessing system-level APIs directly[7]

#### Sandboxed Preload Scripts (Electron 20+)

**Breaking Change**
Since Electron 20, preload scripts are sandboxed by default, severely limiting Node.js module access.[2][8][9]

**Limited API Access in Sandbox**
When sandboxing is enabled, preload scripts have a `require` function with access to only a limited set of APIs:[9][3]

| Category | Available APIs |
|----------|----------------|
| Electron modules | Renderer process modules only |
| Node.js modules | `events`, `timers`, `url` |
| Polyfilled globals | `Buffer`, `process`, `clearImmediate`, `setImmediate` |

[3]

**What You Cannot Access**
- Full Node.js modules like `fs` (file system), `path`, `crypto`, etc. are NOT available by default[8][9]
- Third-party npm packages like `inversify` cannot be loaded in sandboxed preload[2]
- Any module requiring full Node.js environment will fail to load[9][2]

#### Working with Sandboxed Preload Scripts

**Option 1: Disable Sandbox (Not Recommended)**
Temporarily disable sandboxing to access full Node.js modules:[8][2]
```javascript
const mainWindow = new BrowserWindow({
  webPreferences: {
    preload: path.join(__dirname, 'preload.js'),
    sandbox: false // Allows full Node.js access
  }
});
```


**Warning**: This reduces security and is not recommended for production[2]

**Option 2: Move Node.js Logic to Main Process (Recommended)**
- Keep preload scripts minimal and sandboxed[9][2]
- Move all Node.js module usage to the main process[2][9]
- Use IPC to communicate between main and renderer processes[9]
- Expose only specific functionality via Context Bridge[2]

#### Proper Usage Pattern

**Example: Using Node.js Modules Securely**

**Main Process** (full Node.js access):
```javascript
// main.js
const { ipcMain } = require('electron');
const fs = require('fs');

ipcMain.handle('read-file', async (event, filePath) => {
  return fs.readFileSync(filePath, 'utf-8');
});
```


**Preload Script** (expose IPC wrapper):
```javascript
// preload.js
const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('fileAPI', {
  readFile: (filePath) => ipcRenderer.invoke('read-file', filePath)
});
```


**Renderer Process** (use exposed API):
```javascript
// renderer.js
const content = await window.fileAPI.readFile('/path/to/file.txt');
```


#### Available Node.js Modules (Non-Sandboxed)

When `sandbox: false`, preload scripts can access:[5][1]
- Core Node.js modules: `fs`, `path`, `crypto`, `os`, `child_process`, etc.
- Electron modules: `ipcRenderer`, `webFrame`, `clipboard`, etc.
- Any npm package installed in node_modules
- Custom Node.js modules from your project

**Example with File System Module**:
```javascript
// preload.js (sandbox: false required)
const { contextBridge } = require('electron');
const fs = require('fs');
const path = require('path');

contextBridge.exposeInMainWorld('nodeCrypto', {
  sha256sum(data) {
    const crypto = require('crypto');
    const hash = crypto.createHash('sha256');
    hash.update(data);
    return hash.digest('hex');
  }
});
```


#### Best Practices

**Security-First Approach**
1. Keep sandbox enabled (`sandbox: true`)[9][2]
2. Use only the limited Node.js APIs available in sandboxed preload[3]
3. Move complex Node.js operations to the main process[2][9]
4. Communicate via IPC with whitelisted channels[9]
5. Never expose entire modules to renderer[5]

**Migration from Legacy Code**
If you have existing preload scripts using full Node.js modules:[2]
- Identify which Node.js modules are being used
- Refactor logic to main process
- Create IPC handlers for each operation
- Update preload to expose IPC wrappers only
- Test with sandbox enabled

#### Common Errors

**Module Not Found Error**
```
Error: module not found: fs
```
This occurs when trying to `require('fs')` in a sandboxed preload script. Solution: Either disable sandbox or move the logic to main process.[8][9]

**Preload Script Load Failure**
If your preload script fails to load after enabling sandbox, it's likely using Node.js modules not available in the sandbox. Check which modules are being required and refactor accordingly.[2]

Sources
[1] Using Preload Scripts https://www.electronjs.org/docs/latest/tutorial/tutorial-preload
[2] [Bug]: Unable to load preload script due enable sandbox ... https://github.com/electron/electron/issues/36437
[3] Using Preload Scripts | Electron http://electronproject.org/tutorial-preload.html
[4] Using Preload Scripts | Electron https://www.electrondelta.com/tutorial-preload.html
[5] How to use preload.js properly in Electron https://stackoverflow.com/questions/57807459/how-to-use-preload-js-properly-in-electron
[6] How to use preload.js properly in Electron https://stackoverflow.com/questions/57807459/how-to-use-preload-js-properly-in-electron/59814127
[7] Preload Script | electron/electron-quick-start | DeepWiki https://deepwiki.com/electron/electron-quick-start/6-preload-script
[8] Unable to require path and fs modules in preload script https://www.reddit.com/r/electronjs/comments/wydus6/unable_to_require_path_and_fs_modules_in_preload/
[9] electron preload cannot load https://stackoverflow.com/questions/79593680/electron-preload-cannot-load
[10] Deutsch https://www.electronjs.org/de/docs/latest/tutorial/tutorial-preload


---

### Path Resolution and File Linking

Path resolution in Electron requires understanding the different contexts where code executes and using appropriate Node.js path utilities to ensure cross-platform compatibility. Proper path handling is essential for loading files, resources, and linking scripts across main, preload, and renderer processes.[1][2]

#### Core Path Concepts

**__dirname and __filename**
- `__dirname` - Path to the directory containing the currently executing script[2][1]
- `__filename` - Full path to the currently executing script file[2]
- Available in main process and non-sandboxed preload scripts[3][4]
- **Not available** in renderer processes by default (context isolation)[3]
- **Not available** in sandboxed preload scripts (Electron 20+)[4][5]

**Production Build Considerations**
- When using bundlers (webpack, esbuild), `__dirname` and `__filename` may not provide expected values[2]
- Built files are often placed in `dist/electron-*` folders, changing the directory structure[2]
- In packaged apps, files are typically inside `resources/app.asar` archive[6]

#### Path Resolution Methods

**Using path.join() for Cross-Platform Compatibility**
```javascript
const path = require('path');
const { app, BrowserWindow } = require('electron');

// Combine path segments properly
const preloadPath = path.join(__dirname, 'preload.js');
```


- `path.join()` combines multiple path segments into a single path string[1]
- Automatically handles platform-specific path separators (\ on Windows, / on Unix)[1]
- Recommended for all file path construction[1]

**Preload Script Path Resolution**
```javascript
const mainWindow = new BrowserWindow({
  webPreferences: {
    preload: path.join(__dirname, 'preload.js')
  }
});
```


This pattern ensures the preload script path is resolved relative to the main process file location.[1]

#### Electron App Paths

**app.getAppPath()**
- Returns the current application directory[7][6]
- Points to the folder containing your app's entry point[6]
- In development: Returns project root directory[6]
- In production: Returns `resources/app.asar` path[6]

**Example Usage:**
```javascript
const { app } = require('electron');
console.log(app.getAppPath());
// Development: /home/user/projects/myapp
// Production: /opt/MyApp/resources/app.asar
```


**app.getPath(name)**
Returns paths to special directories:[7]
- `home` - User's home directory
- `appData` - Per-user application data directory
- `userData` - Directory for storing app's configuration files
- `temp` - Temporary file directory
- `exe` - Current executable file
- `module` - libchromiumcontent library
- `desktop` - User's Desktop directory
- `documents` - User's Documents directory
- `downloads` - User's Downloads directory
- `music` - User's Music directory
- `pictures` - User's Pictures directory
- `videos` - User's Videos directory

#### Accessing Resources and Assets

**Development vs Production Paths**
When linking to assets from HTML or loading resources, paths differ between environments:[8]

**Development:**
```javascript
// Relative paths work in development
<link rel="stylesheet" href="assets/style.css">
```

**Production (Packaged App):**
```javascript
// Need to resolve paths relative to app resources
const resourcePath = path.join(process.resourcesPath, 'assets', 'style.css');
```


**Using extraResources for Assets**
Configure electron-builder to include assets in the resources folder:[8]
```json
{
  "build": {
    "files": [
      "node_modules/",
      "index.html",
      "main.js"
    ],
    "extraResources": [
      {
        "from": "../assets/",
        "to": "assets/"
      }
    ]
  }
}
```


#### Renderer Process Path Access

**The Problem**
Renderer processes don't have access to `__dirname` by default due to context isolation.[3]

**Solution: Expose Paths via Preload**
```javascript
// preload.js
const { contextBridge } = require('electron');
const path = require('path');

contextBridge.exposeInMainWorld('paths', {
  appPath: __dirname,
  join: (...args) => path.join(...args)
});
```


**Renderer Usage:**
```javascript
// renderer.js
const filePath = window.paths.join(window.paths.appPath, 'data', 'file.txt');
```

#### Workarounds for Missing __dirname

**In Sandboxed Preload Scripts**
Since `__dirname` is not available in sandboxed preload, use alternatives:[5][4]

**Option 1: Use import.meta.url (ES modules)**
```javascript
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
```


**Option 2: Use path.dirname**
```javascript
import path from 'path';

webPreferences: {
  preload: path.dirname + "/preload.js"
}
```


**Note:** The best approach is to keep preload scripts in predictable locations and use hardcoded relative paths or move path-dependent logic to the main process.

#### Best Practices

**1. Always Use path.join()**
Never concatenate paths with string operators:[1]
```javascript
// ❌ Bad - breaks on different platforms
const filePath = __dirname + '/data/file.txt';

// ✅ Good - cross-platform compatible
const filePath = path.join(__dirname, 'data', 'file.txt');
```

**2. Resolve Paths at Build Time**
For bundled applications, resolve critical paths during build configuration rather than runtime.[2]

**3. Use app.getPath() for User Directories**
Store user data in appropriate OS-specific locations:[7]
```javascript
const userDataPath = app.getPath('userData');
const configPath = path.join(userDataPath, 'config.json');
```

**4. Handle Development vs Production**
Create path helpers that work in both environments:[6]
```javascript
const isDev = !app.isPackaged;
const resourcesPath = isDev 
  ? path.join(__dirname, 'assets')
  : path.join(process.resourcesPath, 'assets');
```

Sources
[1] Using Preload Scripts - Electron https://electronjs.org/docs/latest/tutorial/tutorial-preload
[2] Electron Accessing Files - Quasar Framework https://quasar.dev/quasar-cli-vite/developing-electron-apps/electron-accessing-files/
[3] Unable to access __dirname variable in Renderer Process, in an ... https://stackoverflow.com/questions/63628494/unable-to-access-dirname-variable-in-renderer-process-in-an-electronjs-app
[4] Target: electron-preload outputs non-working js #16617 - GitHub https://github.com/webpack/webpack/issues/16617
[5] Unable to load preload script · Issue #2931 · electron/forge - GitHub https://github.com/electron/forge/issues/2931
[6] Where is Electron's app.getAppPath() pointing to? https://stackoverflow.com/questions/40511744/where-is-electrons-app-getapppath-pointing-to
[7] app https://electronjs.org/docs/latest/api/app
[8] Build with relative paths · Issue #5725 · electron-userland ... https://github.com/electron-userland/electron-builder/issues/5725
[9] Development | electron-vite https://electron-vite.org/guide/dev
[10] How can I get the path that the application is running with typescript? https://stackoverflow.com/questions/37213696/how-can-i-get-the-path-that-the-application-is-running-with-typescript/37215237


---

