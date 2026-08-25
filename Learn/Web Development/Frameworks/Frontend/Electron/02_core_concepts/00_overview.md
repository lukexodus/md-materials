## Overview


### Main Process vs Renderer Process

Electron uses a multi-process architecture inherited from Chromium that separates application logic into two distinct types of processes: main and renderer. This architectural design improves performance, stability, and security by isolating processes.[1][7]

#### Main Process

**Role and Responsibilities**
- Runs the entry point script specified in package.json (typically main.js)[4]
- Controls the entire application lifecycle and manages all BrowserWindow instances[5][1]
- Creates web pages by instantiating BrowserWindow objects[7][5]
- Accesses native operating system APIs for menus, dialogs, notifications, system tray, and global shortcuts[6][1]
- Manages platform infrastructure code and system-level operations[1]
- Only one main process exists per Electron application[3][1]

**Process Type**
- When you call `process.type` in the main process, it returns "browser"[4]
- Console logs from the main process appear in the terminal running the app[6][4]
- All files required from main.js run in the main process[4]

#### Renderer Process

**Role and Responsibilities**
- Each BrowserWindow instance spawns its own separate renderer process[5][7]
- Responsible for rendering web content (HTML, CSS, JavaScript) using Chromium[7]
- Runs application-specific code (what your app actually does)[1]
- Behaves according to web standards and has access to web APIs[7]
- JavaScript files included from index.html or other HTML documents run in the renderer process[4]

**Process Type**
- When you call `process.type` in a renderer process, it returns "renderer"[4]
- Console logs from renderer processes appear in Chromium's DevTools, not the terminal[6][4]

**Process Isolation**
- Multiple renderer processes can run simultaneously, one for each window[3][5]
- Each renderer process is isolated and doesn't interfere with other renderer processes[3][5]
- A crash in one renderer process does not affect other renderer processes or the main process[5]
- Renderer processes are independent—they don't share resources or state[1]

#### Key Differences

**Separation of Concerns**
- Main process: Platform infrastructure (window creation, native APIs, system integration)[1]
- Renderer process: Application logic and UI rendering[2][1]
- This is a "hard" separation—processes run independently and don't share state by default[1]

**Resource Access**
- Node.js modules are available in both processes, but state isn't shared between them[1]
- If you set state in a module in the main process, requiring that same module in a renderer creates an entirely different instance without that state[1]
- Calling native GUI-related APIs directly from renderer processes is restricted for security reasons[5]

**Performance Considerations**
- CPU-intensive work shouldn't run in the main process as it will block all renderer processes[1]
- Heavy processing shouldn't run in the UI renderer either as it locks up the interface[1]
- For intensive tasks, use invisible renderer windows or worker processes[1]

#### Inter-Process Communication (IPC)

Since processes are isolated, Electron provides IPC mechanisms (ipcMain and ipcRenderer) to enable communication between main and renderer processes. This allows renderer processes to request that the main process perform privileged operations like creating new windows, accessing native APIs, or using Node.js modules securely.[5][4]

Sources
[1] Distinction between the renderer and main processes in Electron https://stackoverflow.com/questions/37669727/distinction-between-the-renderer-and-main-processes-in-electron
[2] Main vs Renderer Process | Tuui https://www.tuui.com/electron-how-to/main-and-renderer-process
[3] Electron js Tutorial - 3 - Main and Renderer Process https://www.youtube.com/watch?v=yeYiuUONO9I
[4] Main process and Renderer process in Electron https://www.christianengvall.se/main-and-renderer-process-in-electron/
[5] Electron - Why do we need to communicate between the main process and the renderer processes? https://stackoverflow.com/questions/67344365/electron-why-do-we-need-to-communicate-between-the-main-process-and-the-render
[6] Electron js tutorial for beginners  #3 Main and Render Process https://www.youtube.com/watch?v=Z2IzeYiN310
[7] Process Model https://www.electronjs.org/docs/latest/tutorial/process-model
[8] Any reason not to put all logic in the renderer and use Electron only to launch window? https://www.reddit.com/r/electronjs/comments/10m92uo/any_reason_not_to_put_all_logic_in_the_renderer/
[9] main -> renderer communication - Help me understand the syntax, please. https://www.reddit.com/r/electronjs/comments/13mcc3v/main_renderer_communication_help_me_understand/
[10] Main Process & Renderer Overview - Electron, v3 https://frontendmasters.com/courses/electron-v3/main-process-renderer-overview/

---

### Chromium and Node.js Integration

Electron combines Chromium (the open-source rendering engine behind Google Chrome) and Node.js runtime into a single binary, enabling web technologies to build native desktop applications. This integration merges web platform capabilities with operating system-level access in one unified environment.[1][2][3]

#### How the Integration Works

**Embedding Architecture**
- Electron embeds both Chromium and Node.js into its binary distribution[4][1]
- Chromium handles the rendering of HTML, CSS, and JavaScript for the user interface[2][3]
- Node.js provides backend runtime capabilities and access to system-level APIs[5][2]
- The integration creates a "single context" where both technologies work together without requiring tools like Browserify[6]

**Process Model**
- The main process is essentially a Node.js process that runs on startup[7]
- Chromium's browser process executes a Node.js module at initialization[7]
- Renderer processes (running Chromium) can access Node.js modules by calling `require()`[7]
- This architecture inherits Chromium's multi-process model with added Node.js integration[8][7]

#### Benefits of Integration

**Unified Development Environment**
- Write both frontend UI and backend logic using JavaScript[3][2]
- Access web APIs and HTML5 features through Chromium[4]
- Access file system, operating system features, and native modules through Node.js[2][5]
- Use any package from the npm ecosystem or write custom native add-ons[1]

**Cross-Platform Consistency**
- Chromium provides a stable, consistent rendering target across all platforms[1][4]
- Eliminates browser compatibility issues and heterogeneous UI landscapes[4]
- Apps run identically on macOS, Windows, and Linux without platform-specific code[1]

**Modern Web Platform Features**
- Bundled Chromium ensures access to the newest web platform features[1]
- Regular updates synchronized with Chromium releases provide security fixes immediately[1]
- Developers can build for a single browser target (Chromium) instead of multiple browsers[3][4]

#### How Chromium and Node.js Communicate

**Shared JavaScript Context**
- Both Chromium and Node.js share the same JavaScript runtime environment in renderer processes[6]
- Node.js modules can be required directly from renderer process code[7]
- No need for separate bundling or transformation tools to bridge the two environments[6]

**Separation in Main Process**
- The main process runs pure Node.js code for application lifecycle management[8][7]
- Renderer processes run Chromium with Node.js integration for UI and logic[8][7]

#### Technical Components

Electron's framework consists of three core components: Chromium's rendering library (Libchromiumcontent), the Node.js JavaScript runtime, and a JavaScript engine written in C++. These components work together to execute application code without requiring a web server—files are prepackaged with the app and interpreted locally by Node.js and Chromium.[2][3]

#### Trade-offs

While this integration provides powerful capabilities, Electron apps consume more resources than native implementations because they embed entire Chromium and Node.js environments. However, continuous improvements are working to mitigate these concerns and enhance performance efficiency.[4]

Sources
[1] Electron: Build cross-platform desktop apps with JavaScript ... https://electronjs.org
[2] What is Electron.js? | How Does Electron Work https://www.axon.dev/blog/what-is-electron-js-how-does-electron-work
[3] ElectronJS - User Guide to Build Cross-Platform Applications https://www.ideas2it.com/blogs/introduction-to-building-cross-platform-applications-with-electron
[4] Advanced Electron.js architecture https://blog.logrocket.com/advanced-electron-js-architecture/
[5] How to Use Electron.js to Create Cross-Platform Desktop ... https://dev.to/abdulrafaykhan_dev/how-to-use-electronjs-to-create-cross-platform-desktop-applications-7ol
[6] What does it mean for Electron to combine Node.js and ... https://stackoverflow.com/questions/38166617/what-does-it-mean-for-electron-to-combine-node-js-and-chromium-contexts
[7] The Electron process architecture is the Chromium process ... https://jameshfisher.com/2020/10/14/the-electron-process-architecture-is-the-chromium-process-architecture/
[8] Electron vs Node.js: Best Pick for 2025 Cross-Platform ... https://www.index.dev/blog/electron-vs-nodejs
[9] Loading Nodejs Module at runtime in electron app https://stackoverflow.com/questions/62405815/loading-nodejs-module-at-runtime-in-electron-app
[10] What does it mean for Electron to combine Node.js and Chromium contexts? https://stackoverflow.com/questions/38166617/what-does-it-mean-for-electron-to-combine-node-js-and-chromium-contexts/38166865


---

### Application Lifecycle Management

The main process controls your application's lifecycle through Electron's `app` module, which provides events and methods to manage application startup, window behavior, and shutdown. The app module is a core component that runs exclusively in the main process.[1][2][3][4][5]

#### Key Lifecycle Events

**ready**
- Emitted when Electron has finished initialization[2][5]
- BrowserWindows can only be created after this event fires[2]
- Use `app.whenReady()` to get a Promise that fulfills when Electron is initialized[6][2]
- Alternative: `app.on('ready', callback)` or check `app.isReady()`[6][2]
- The ready event fires only after the main process finishes running the first tick of the event loop[2][6]

**window-all-closed**
- Emitted when all windows have been closed[7][6][2]
- Default behavior: quit the app if you don't subscribe to this event[5][7][2]
- By subscribing to this event, you control whether the app quits or stays open[7][2]
- Platform-specific handling: macOS apps typically remain active until the user explicitly quits (Cmd + Q)[8]
- Not emitted if the user pressed Cmd + Q or developer called `app.quit()`[5][7][2]

**activate** (macOS-specific)
- Emitted when the application is activated from the dock[8]
- Used to recreate windows when the dock icon is clicked but no windows are open[8]

**did-become-active** (macOS-specific)
- Emitted every time the app becomes active[6][2]
- Different from `activate`: fires on all activations, not just dock icon clicks[2][6]
- Also emitted when switching to the app via macOS App Switcher[6][2]

**before-quit**
- Emitted before the application starts closing its windows[7][2][6]
- Call `event.preventDefault()` to prevent application termination[7][2][6]
- If quit was initiated by `autoUpdater.quitAndInstall()`, `before-quit` is emitted after closing all windows[2][6]
- Not emitted on Windows if the app is closed due to system shutdown/restart or user logout[6][2]

**will-quit**
- Emitted when all windows have been closed and the application will quit[7][2][6]
- Call `event.preventDefault()` to prevent default termination behavior[2][6][7]
- Not emitted on Windows if the app is closed due to system shutdown/restart or user logout[6][2]

**quit**
- Emitted when the application is quitting[9]
- Final event in the lifecycle sequence[9]

#### Lifecycle Methods

**app.quit()**
- Attempts to close all windows[10][2][6]
- Emits `before-quit` event first, then closes windows[10]
- If all windows successfully close, emits `will-quit` event and terminates the app by default[10][7]
- Guarantees that `beforeunload` and `unload` event handlers execute correctly[10][7]
- A window can cancel quitting by returning false in the `beforeunload` handler[7]

**app.relaunch()**
- Relaunches the app when current instance exits[2][6]
- Does not automatically quit the app—you must call `app.quit()` or `app.exit()` manually[6][2]
- Calling multiple times creates multiple instances[2][6]

#### Platform-Specific Behavior

**macOS Edge Cases**
- Keep the app open without windows: listen to `window-all-closed` without calling `app.quit()`[8]
- Open new window when activated from dock: listen to `activate` event and call `createWindow()` if no windows exist[8]

#### Example Lifecycle Management

A typical lifecycle implementation listens for `ready` to create windows, handles `window-all-closed` to quit on Windows/Linux but stay active on macOS, and responds to `activate` on macOS to recreate windows.[3][8][2]

Sources
[1] Process Model https://electronjs.org/docs/latest/tutorial/process-model
[2] app https://electronjs.org/docs/latest/api/app
[3] Building your First App https://electronjs.org/docs/latest/tutorial/tutorial-first-app
[4] Electron js tutorial for beginners # Important App life cycle ... https://www.youtube.com/watch?v=ECq-mMdKepc
[5] app | FAQ https://imfly.github.io/electron-docs-gitbook/en/api/app.html
[6] app | Electron https://www.electronjs.org/docs/latest/api/app
[7] app · Electron documentation https://tinydew4.gitbooks.io/electron/api/app.html
[8] Create a Todo List app with Electron, JavaScript and AG Grid https://blog.ag-grid.com/using-ag-grid-in-electron-applications/
[9] Managing Application Lifecycle — Electron | Bsmarted https://bsmarted.com/en/topics/electron/managing-application-lifecycle
[10] Closing all app windows when using Electron - Stack Overflow https://stackoverflow.com/questions/44589278/closing-all-app-windows-when-using-electron


---

### BrowserWindow Creation and Configuration

BrowserWindow is Electron's class for creating and controlling browser windows, available only in the main process. Each BrowserWindow instance creates a new window with properties defined through constructor options.[1][2][3][4]

#### Creating a BrowserWindow

**Basic Syntax**
- Import the BrowserWindow class: `const { BrowserWindow } = require('electron')`[2][3][5]
- Instantiate with `new BrowserWindow([options])` where options is an optional configuration object[1][2]
- Must be created in the main process, not renderer processes[6]
- Can only be created after the `app.whenReady()` event fires[7][8]

**Simple Example**
```javascript
const win = new BrowserWindow({ width: 800, height: 600 })
```


#### Window Configuration Options

**Dimension Options**
- `width` (Integer): Window's width in pixels (default: 800)[6][1]
- `height` (Integer): Window's height in pixels (default: 600)[1][6]
- `minWidth` / `minHeight`: Minimum window dimensions[1]
- `maxWidth` / `maxHeight`: Maximum window dimensions[1]

**Display Options**
- `show` (Boolean): Whether window should be shown when created (default: true)[3][1]
- Setting `show: false` allows you to control when the window appears using `win.show()`[3]
- Useful to prevent visual flash during window initialization[3]

**Frame and Chrome Options**
- `frame` (Boolean): Whether to show window frame (default: true)[1]
- Setting `frame: false` creates a frameless window without chrome[3][1]
- Frameless windows allow custom window controls[3]

**Parent-Child Relationships**
- `parent` (BrowserWindow): Specify a parent window to create child windows[1]
- Child windows always show on top of their parent[1]

#### webPreferences Configuration

The `webPreferences` object is the most critical configuration section for security and functionality.[9][7]

**Context Isolation**
- `contextIsolation` (Boolean): Should be set to `true` for security best practices[7]
- Isolates Electron APIs from web content loaded in the window[7]
- Required by some plugins and security-conscious applications[7]

**Preload Scripts**
- `preload` (String): Path to a script that runs before the renderer process loads[7]
- Provides a secure way to expose APIs to the renderer[7]
- Example: `webPreferences: { preload: path.join(__dirname, 'preload.js') }`[7]

**Node Integration**
- `nodeIntegration` (Boolean): Whether to enable Node.js APIs in the renderer (default: false)[1]
- Should generally remain `false` for security reasons[1]

**Multiple webPreferences**
When setting multiple webPreferences options, pass them as properties of the webPreferences object:[7]
```javascript
new BrowserWindow({
  webPreferences: {
    contextIsolation: true,
    preload: './my-preload.js',
    additionalArguments: '--my-argument'
  }
})
```


#### Loading Content

**Load Local Files**
- `win.loadFile('index.html')` for local HTML files[7]
- `win.loadURL(\`file://${__dirname}/app/index.html\`)` using file:// protocol[5]

**Load Remote URLs**
- `win.loadURL('https://github.com')` for web content[5][3]

#### Opening Windows from Renderer

Windows can be created from renderer processes using `window.open()`, but customization requires `webContents.setWindowOpenHandler()` in the main process. BrowserWindow constructor options for renderer-created windows are set through this handler with increasing precedence.[9]

#### Inheritance

BrowserWindow extends BaseWindow, which provides fundamental window creation and control capabilities. Built-in Electron classes like BrowserWindow cannot be subclassed in user code.[4][2]

Sources
[1] BrowserWindow | FAQ - GitHub Pages https://imfly.github.io/electron-docs-gitbook/en/api/browser-window.html
[2] BrowserWindow https://www.electronjs.org/docs/latest/api/browser-window
[3] BrowserWindow | electron-gitbook - xwartz https://xwartz.gitbooks.io/electron-gitbook/content/en/api/browser-window.html
[4] BaseWindow | Electron https://www.electronjs.org/docs/latest/api/base-window
[5] BrowserWindow | Electron https://docset.yxpai.com/Electron/docs/api/browser-window.html
[6] How to fix BrowserWindow is not a constructor error when creating child window in Electron renderer process https://stackoverflow.com/questions/45639628/how-to-fix-browserwindow-is-not-a-constructor-error-when-creating-child-window-i
[7] Electron Plugin - App Config https://app-config.dev/guide/electron.html
[8] Electron BrowserWindow & WebContents Objects https://www.youtube.com/watch?v=0CJY-IHoNto
[9] Opening windows from the renderer https://www.electronjs.org/docs/latest/api/window-open
[10] Electron Platform Guide - Apache Cordova https://cordova.apache.org/docs/en/11.x/guide/platforms/electron/


---

### Window Properties (width, height, webPreferences)

BrowserWindow accepts numerous configuration properties in its constructor that control window dimensions, appearance, behavior, and security settings. These properties are passed as an options object when creating a new window instance.[1][2]

#### Dimension Properties

**Basic Size Options**
- `width` (Integer): Window's width in pixels (default: 800)[2][5][1]
- `height` (Integer): Window's height in pixels (default: 600)[5][1][2]
- Example: `new BrowserWindow({ width: 800, height: 600 })`[9][2]

**Size Constraints**
- `minWidth` / `minHeight` (Integer): Minimum window dimensions[1]
- `maxWidth` / `maxHeight` (Integer): Maximum window dimensions that restrict resizing[7][1]
- Example: `{ maxWidth: 600, maxHeight: 400 }` limits the window even if users try to resize[7]

**Resizing Behavior**
- `resizable` (Boolean): Whether the window can be manually resized by the user (default: true)[2][5][1]
- Setting `resizable: false` prevents users from changing window dimensions[8][5]

#### Position Properties

**Window Location**
- `x` (Integer): Horizontal position from screen left edge in pixels[5]
- `y` (Integer): Vertical position from screen top edge in pixels[5]
- Default behavior: Window appears centered on screen[5]
- Example: `{ x: 0, y: 0 }` positions window at top-left corner[5]

#### Display and Visibility Properties

**Appearance Control**
- `show` (Boolean): Whether window should be visible when created (default: true)[1][2]
- Setting `show: false` with `ready-to-show` event prevents visual flicker[2]
- `backgroundColor` (String): Window background color as hexadecimal, RGB, HSL, or CSS color name[2]
- Example values: `'#2e2c29'`, `'rgb(255, 145, 145)'`, `'hsl(230, 100%, 50%)'`, `'blueviolet'`[2]

**Frame and Chrome**
- `frame` (Boolean): Whether to show window frame/chrome (default: true)[1]
- `title` (String): Default window title; overridden by HTML `<title>` tag if present[5]
- `alwaysOnTop` (Boolean): Whether window should stay on top of other windows (default: false)[1]

**Window Capabilities**
- `minimizable` (Boolean): Whether window has minimize button (default: true)[5]
- `maximizable` (Boolean): Whether window has maximize button (default: true)[5]
- `closable` (Boolean): Whether window is closable; not implemented on Linux (default: true)[1]
- `fullscreen` (Boolean): Whether window should show in fullscreen (default: false)[1]

#### webPreferences Configuration

The `webPreferences` object is crucial for security and functionality configuration.[1]

**Security Settings**
- `nodeIntegration` (Boolean): Whether to enable Node.js integration in the renderer (default: false)
- `contextIsolation` (Boolean): Whether to run Electron APIs in separate context from web content (recommended: true)
- `sandbox` (Boolean): Whether to enable Chromium OS-level sandbox

**Preload Scripts**
- `preload` (String): Path to script that runs before renderer process loads
- Has access to both Node.js APIs and DOM
- Used to safely expose APIs to the renderer via Context Bridge
- Example: `webPreferences: { preload: path.join(__dirname, 'preload.js') }`

**Additional Preferences**
- `devTools` (Boolean): Whether to enable DevTools (default: true)
- `additionalArguments` (String[]): Additional command-line arguments passed to the renderer process

#### Modal Windows

**Parent-Child Relationships**
- `parent` (BrowserWindow): Specifies a parent window for creating child windows[2][1]
- `modal` (Boolean): Creates a modal window that disables the parent[7][2]
- Both `parent` and `modal` properties must be set together for modal behavior[7][2]
- Example: `new BrowserWindow({ parent: top, modal: true, show: false })`[2]

#### Instance Properties

After creating a BrowserWindow, you can access instance properties like `win.webContents` (the WebContents object for web page operations) and `win.id` (unique window identifier).[2][1]

Sources
[1] BrowserWindow | FAQ - GitHub Pages https://imfly.github.io/electron-docs-gitbook/en/api/browser-window.html
[2] BrowserWindow https://www.electronjs.org/docs/latest/api/browser-window
[3] Electron js tutorial for beginners #4 Browser Window Properties https://www.youtube.com/watch?v=rFJ44zdbpvo
[4] Electron Tutorial 6: BrowserWindow https://www.youtube.com/watch?v=UG9lka9mOwM
[5] Electron – チュートリアルその3 BrowserWindow のプロパティ https://pystyle.info/electron-tutorial-browser-window-properties/
[6] GitHub - ungoldman/electron-browser-window-options: Reference for default Electron BrowserWindow options. https://github.com/ungoldman/electron-browser-window-options
[7] Electron js Tutorial - 4 - BrowserWindow https://www.youtube.com/watch?v=zq7GrAym-KI
[8] Getting Started w/ Electron #2 - BrowserWindow Class https://www.youtube.com/watch?v=94kNEMbiZeo
[9] Electron BrowserWindow & WebContents Objects - Electron Basics Tutorial https://www.youtube.com/watch?v=0CJY-IHoNto
[10] Window Customization | Electronelectronjs.org › docs › latest › tutorial › window-customization https://www.electronjs.org/docs/latest/tutorial/window-customization


---

### Loading Local Files vs Remote URLs

Electron provides two primary methods for loading content into BrowserWindow: `loadFile()` for local HTML files and `loadURL()` for remote addresses or local server resources. Understanding when and how to use each method is essential for proper application development.[1][2][3]

#### loadFile() - Local Files

**Purpose and Usage**
- Specifically designed for loading local HTML files from the file system[2]
- Syntax: `win.loadFile(filePath[, options])`[3]
- Example: `mainWindow.loadFile('index.html')`[2]
- Path can be absolute or relative to the application root directory[2]
- Returns a Promise that resolves when the page finishes loading[3]

**Benefits**
- Better performance since it directly reads local files without network latency[2]
- No CORS (Cross-Origin Resource Sharing) restrictions[2]
- Simpler syntax for local resources[2]
- Recommended approach for loading local files[2]

#### loadURL() - Remote URLs and Servers

**Purpose and Usage**
- Used for loading remote network resources via HTTP/HTTPS protocols[1][2]
- Also works for local development servers[4][5]
- Syntax: `win.loadURL(url[, options])`[1][3]
- Example: `mainWindow.loadURL('http://localhost:3000')`[4]
- Can accept remote addresses like `'https://example.com'`[2]

**Advanced Features**
- Supports POST requests with URL-encoded data[3]
- Can include custom headers via `extraHeaders` option[3]
- Can send `postData` with request body[3]
- Example with POST:
```javascript
win.loadURL('http://localhost:8000/post', {
  postData: [{ type: 'rawData', bytes: Buffer.from('hello=world') }],
  extraHeaders: 'Content-Type: application/x-www-form-urlencoded'
})
```


**Considerations**
- Subject to CORS policies when loading remote resources[2]
- Must ensure target server's CORS configuration allows access[2]
- Performance affected by network latency[2]

#### Development vs Production Patterns

**Conditional Loading**
- Common pattern: Use `loadURL()` for development server and `loadFile()` for production build[4]
- Example:
```javascript
const isDev = require('electron-is-dev')
mainWindow.loadURL(
  isDev 
    ? 'http://localhost:3000' 
    : `file://${path.join(__dirname, '../build/index.html')}`
)
```


**Loading Local Files with loadURL()**
- You can use `loadURL()` with `file://` protocol for local files[2]
- Example: `loadURL('file://path/to/index.html')`[2]
- However, `loadFile()` is recommended as it simplifies the operation[2]

#### Security Considerations

**file:// Protocol Risks**
- The `file://` protocol has elevated privileges in Electron compared to web browsers[6]
- Pages running on `file://` have unilateral access to every file on the machine[6]
- XSS vulnerabilities can exploit this to load arbitrary files from user's system[6]
- Consider using custom protocols to limit file access to specific directories[6]

**Node.js Integration Warnings**
- When using `http://` or `https://` with Node integration enabled, Electron warns about security risks[7]
- Every JavaScript loaded by the page may contain Node.js code with file system access[7]
- This could potentially execute harmful operations[7]
- Best practice: Disable `nodeIntegration` and use preload scripts with context isolation[7]

#### Method Availability

Both `loadFile()` and `loadURL()` are available on both the BrowserWindow class and the WebContents class, providing flexibility in how you load content into windows.[8]

#### Common Issues

**Path Errors**
- Ensure path format is correct to avoid loading failures[2]
- Mixing up when to use `loadFile()` vs `loadURL()` often causes path-related errors[2]

**Best Practice**
- For remote resources → use `loadURL()`[2]
- For local files → use `loadFile()`[2]
- Always load external resources using secure protocols (HTTPS) rather than HTTP[6]

Sources
[1] BrowserWindow https://electronjs.org/docs/latest/api/browser-window
[2] Electron中loadURL和loadFile的区别是什么？如何正确使用它们加载页面？ https://ask.csdn.net/questions/8400176
[3] BrowserWindow https://www.electronjs.org/docs/latest/api/browser-window
[4] How can I use loadUrl or loadFile in production with ... https://stackoverflow.com/questions/67356048/how-can-i-use-loadurl-or-loadfile-in-production-with-electron-and-cra
[5] Cross-Platform Desktop App with Electron/React/Typescript https://javascript.plainenglish.io/cross-platform-desktop-app-with-electron-react-typescript-3a85eaba909a
[6] Security https://electronjs.org/docs/latest/tutorial/security
[7] Security issues in Electron using http:// protocol instead of file https://stackoverflow.com/questions/52423993/security-issues-in-electron-using-http-protocol-instead-of-file
[8] Electron BrowserWindow & WebContents Objects - Electron Basics Tutorial https://www.youtube.com/watch?v=0CJY-IHoNto
[9] win.loadFile (local file) is stuck if application is called by ... https://github.com/electron/electron/issues/32044
[10] Electron Breaks Brain https://maxwellforbes.com/garage/electron-breaks-brain/

---

### Platform-Specific Operations (Windows, macOS, Linux)

Electron applications run on multiple operating systems, each with unique behaviors and conventions that require platform-specific handling. Developers can detect and implement platform-specific code using Node.js's `process.platform` property.[1][2]

#### Platform Detection

**process.platform Values**
- `win32` - Windows (all versions, including 64-bit)[2][3][1]
- `darwin` - macOS (formerly OS X)[3][1][2]
- `linux` - Linux distributions[1][2][3]
- `freebsd` - FreeBSD[2]
- `openbsd` - OpenBSD[3][2]
- `sunos` - SunOS/Solaris[3]
- `aix` - AIX[3]

**Implementation Pattern**
```javascript
const os = require('os');

const platforms = {
  WINDOWS: 'WINDOWS',
  MAC: 'MAC',
  LINUX: 'LINUX'
};

const platformsNames = {
  win32: platforms.WINDOWS,
  darwin: platforms.MAC,
  linux: platforms.LINUX
};
```


#### Common Platform-Specific Behaviors

**Window Management**
- macOS apps typically stay running when all windows are closed[2]
- Windows/Linux apps quit when all windows are closed[2]
- Example implementation:
```javascript
app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit(); // Only quit on Windows/Linux
  }
});
```


**Application Activation (macOS)**
- macOS users expect apps to reopen windows when clicking the dock icon[2]
- Use the `activate` event to recreate windows on macOS[2]
- Not needed on Windows/Linux as apps quit completely when windows close[2]

#### Version Detection

**Windows Version Checking**
You can use `os.release()` to detect specific Windows versions:[3]
- Windows 10: version 10.0
- Windows 8.1: version 6.3
- Windows 8: version 6.2
- Windows 7: version 6.1

Example:
```javascript
const releaseTest = {
  [platforms.WINDOWS]: (version) => {
    const [majorVersion, minorVersion] = version.split('.');
    if (majorVersion === '10') return 'WIN10';
    if (majorVersion === '6' && minorVersion === '3') return 'WIN8';
    return 'WIN7';
  }
};
```


#### Platform-Specific Dependencies

**Handling Native Modules**
- Some npm packages have platform-specific binaries or dependencies[4]
- Native addons must be rebuilt for each target platform[5]
- Use conditional requires or dependency checks for platform-specific libraries[4]
- Example: Different database drivers for Windows vs Linux[4]

**Binary Installation**
- When building on a different platform, specify the target: `npm install --platform=win32`[6]
- This ensures correct prebuilt binaries are downloaded[6]

#### Packaging for Multiple Platforms

**Electron Packager**
Specify target platforms when packaging:[1][6]
```bash
npx electron-packager . appname --platform=darwin,linux,win32 --arch=ia32,x64
```


**Electron Forge**
Add platform-specific make commands to package.json:[2]
```json
{
  "make-mac": "npx @electron-forge/cli make --platform darwin",
  "make-win": "npx @electron-forge/cli make --platform win32",
  "make-linux": "npx @electron-forge/cli make --platform linux"
}
```


**Output Formats by Platform**
- macOS: `.app` bundle or `.dmg` disk image[7][2]
- Windows: `.exe` executable or `.msi` installer[7][2]
- Linux: `.rpm`, `.deb`, or AppImage packages[7][2]

#### Platform-Specific UI Considerations

**Native Look and Feel**
- Electron uses web technologies which may not provide fully native UI by default[8]
- Libraries like Photon and Spectron provide native-like components[8]
- Custom styling may be needed to match each platform's design guidelines[8]

**Accessibility Features**
- Electron doesn't provide built-in platform-specific accessibility APIs[8]
- Developers must manually implement accessibility features for each platform[8]
- Native frameworks typically have better accessibility integration[8]

#### Testing Platform-Specific Code

**Cross-Platform Testing**
- Test on all target platforms to ensure consistent behavior[8]
- Pay attention to platform-specific nuances: file system differences, font rendering, UI scaling[8]
- Use automated testing tools to streamline multi-platform testing[8]

**Build Requirements**
- macOS builds generally require a Mac (for code signing)[1]
- Windows and Linux builds can be generated from most host platforms[1]
- Consider CI/CD pipelines with platform-specific runners for automated builds[8]

Sources
[1] Electron Packager https://github.com/electron/packager
[2] How to Package Your Multi-platform Electron App - Turtle-Techies https://www.turtle-techies.com/how-to-package-your-multiplatform-electron-app/
[3] Writing OS-specific code in Electron https://www.freecodecamp.org/news/how-to-write-os-specific-code-in-electron-bf6379c62ff6/
[4] Handling platform-specific dependencies in electron app https://stackoverflow.com/questions/65383546/handling-platform-specific-dependencies-in-electron-app
[5] Native Code and Electron https://electronjs.org/docs/latest/tutorial/native-code-and-electron
[6] A Comprehensive Guide to Building and Packaging an Electron App https://stevenklambert.com/writing/comprehensive-guide-building-packaging-electron-app/
[7] Electron: Build cross-platform desktop apps with JavaScript ... https://electronjs.org
[8] ElectronJS For Cross-Platform Software Development - Intuji https://intuji.com/electronjs-for-cross-platform-development/
[9] How to build desktop applications with Electron JS and ... https://www.facebook.com/groups/ReactJsDevelopersGroup/posts/2954107651430117/
[10] Electron vs. Tauri: Which cross-platform framework is for you? https://www.infoworld.com/article/3547072/electron-vs-tauri-which-cross-platform-framework-is-for-you.html


---

### Process Platform Detection

Platform detection in Electron uses Node.js's `process.platform` property, which returns a string identifying the operating system where the application is running. This is essential for implementing platform-specific behavior and logic.[1][2][3]

#### Accessing process.platform

**Basic Usage**
- Access via `process.platform` (no require needed, it's a global)[4][1]
- Returns a string value representing the OS platform[2][3]
- Value is set at compile time when Node.js binary is built[3][2]
- Example: `console.log(process.platform);`[5][2]

#### Platform Values

**Common Platform Identifiers**
- `'win32'` - Windows (all versions, including 64-bit)[6][1][2]
- `'darwin'` - macOS/iOS and Darwin-based systems[1][2][3]
- `'linux'` - Linux distributions[2][3][5]
- `'aix'` - IBM AIX platform[3][2]
- `'freebsd'` - FreeBSD[2][3]
- `'openbsd'` - OpenBSD[3][2]
- `'sunos'` - SunOS/Solaris[2]
- `'android'` - Android (in some Node.js implementations)[2]

#### Important Notes

**Windows Detection Caveat**
- Windows always returns `'win32'` even on 64-bit systems[7][6][1]
- This is because `'win32'` refers to the Windows API name, not the architecture[8]
- `'win32'` contrasts with the older 16-bit Windows API from the mid-90s[8]
- To detect 64-bit vs 32-bit architecture, use `process.arch` instead[7][8]

**Architecture vs Platform**
- `process.platform` - Operating system type (Windows, macOS, Linux)[4][2]
- `process.arch` - CPU architecture (x64, ia32, arm, etc.)[7][8]
- Example: 32-bit Electron on 64-bit Windows still reports `process.platform === 'win32'`[7]

#### Implementation Patterns

**Switch Statement Pattern**
```javascript
const process = require('process');

var platform = process.platform;
switch(platform) {
  case 'aix':
    console.log("IBM AIX platform");
    break;
  case 'darwin':
    console.log("Darwin platform (MacOS, iOS etc)");
    break;
  case 'freebsd':
    console.log("FreeBSD Platform");
    break;
  case 'linux':
    console.log("Linux Platform");
    break;
  case 'openbsd':
    console.log("OpenBSD platform");
    break;
  case 'sunos':
    console.log("SunOS platform");
    break;
  case 'win32':
    console.log("Windows platform");
    break;
  default:
    console.log("Unknown platform");
}
```


**Conditional Check Pattern**
```javascript
if (process.platform === 'darwin') {
  // macOS-specific code
} else if (process.platform === 'win32') {
  // Windows-specific code
} else if (process.platform === 'linux') {
  // Linux-specific code
}
```


**Regex Pattern for Windows**
```javascript
if (/^win/i.test(process.platform)) {
  // Windows detected
} else {
  // Linux, Mac, or other
}
```


**Warning**: Don't use substring matching with "win" as "darwin" also contains "win"[8]

#### Alternative: os.platform()

**Using os Module**
- Can also use `os.platform()` from Node.js os module[5]
- Syntax: `const os = require('os'); console.log(os.platform());`[5]
- Returns the same value as `process.platform`[6][5]
- Both methods are equivalent for platform detection[5]

#### Electron-Specific Considerations

**Process Object Availability**
- The process object is available in both Main Process and Renderer Process[9]
- Access is identical in both contexts[9]
- Additional Electron-specific methods are available on the process object[9]

**Electron Process Methods**
- `process.getSystemVersion()` - Returns actual OS version (not kernel version on macOS)[9]
- `process.getSystemMemoryInfo()` - System memory information[9]
- These complement standard Node.js process properties[9]

#### Practical Use Cases

Platform detection is commonly used for:
- Conditional window management (quit behavior on macOS vs Windows/Linux)[1]
- Platform-specific file paths and directory structures[2]
- Native module loading based on OS[2]
- UI/UX adjustments for platform conventions[2]
- Choosing appropriate system commands or APIs[4]

Sources
[1] How do I determine the current operating system with Node.js https://stackoverflow.com/questions/8683895/how-do-i-determine-the-current-operating-system-with-node-js
[2] Node.js process.platform Property - GeeksforGeeks https://www.geeksforgeeks.org/node-js/node-js-process-platform-property/
[3] Process.platform - Node documentation - Deno Docs https://docs.deno.com/api/node/process/~/Process.platform
[4] Node.js Process Management - W3Schools https://www.w3schools.com/nodejs/nodejs_process_management.asp
[5] Node.js - os.platform() Method - Tutorials Point https://www.tutorialspoint.com/nodejs/nodejs_os_platform_method.htm
[6] How do I determine the current operating system with Node.js https://stackoverflow.com/questions/8683895/how-do-i-determine-the-current-operating-system-with-node-js/8684009
[7] Detect os platform version x64 vs. ia32 [Linux, Win] · Issue #6044 https://github.com/electron/electron/issues/6044
[8] os.platform() includes win32...what about win64? https://www.reddit.com/r/node/comments/7xx4u7/osplatform_includes_win32what_about_win64/
[9] Process Object in ElectronJS - GeeksforGeeks https://www.geeksforgeeks.org/javascript/process-object-in-electronjs/
[10] Process | Node.js v25.3.0 Documentation https://nodejs.org/api/process.html


---

