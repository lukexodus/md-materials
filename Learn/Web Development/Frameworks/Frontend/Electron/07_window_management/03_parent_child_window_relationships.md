## Parent-Child Window Relationships


Electron provides robust mechanisms for establishing hierarchical relationships between windows, enabling developers to create child windows that maintain specific positional, lifecycle, and behavioral dependencies on their parent windows. These relationships are fundamental for building complex multi-window applications with modal dialogs, preference panels, and contextual sub-windows.[1]

### Creating Child Windows

Child windows are created by passing the `parent` option to the BrowserWindow constructor, referencing an existing parent window instance. When this relationship is established, the child window will always show on top of the parent window, maintaining its z-order position regardless of user interaction. This ensures child windows remain visible and accessible even when users interact with other parts of the application.[2][1]

The parent-child relationship automatically enforces lifecycle coupling—when the parent window closes, all child windows are automatically closed as well. This automatic cleanup prevents orphaned windows and ensures proper resource management without requiring manual tracking of window relationships.[3]

### Modal Windows

Modal windows are a specialized type of child window that disable interaction with the parent window until the modal is closed. Creating a modal requires setting both the `parent` and `modal` options to `true` in the BrowserWindow constructor. Modal windows appear as contextual dropdowns or overlays within the parent window's context, making them ideal for prompting user input or displaying critical information that requires immediate attention.[4][1][3]

Platform-specific behaviors differ significantly for modal windows, particularly regarding their visual presentation and interaction model. Developers should consult platform-specific documentation and test modal behavior on target operating systems to ensure consistent user experiences.[3]

### Window Positioning and Stacking

Child windows maintain a persistent z-order relationship with their parent, always appearing on top of the parent window. When the parent window is moved, child windows do not automatically follow the parent's position—they move independently but remain above the parent in the window stacking order. This behavior allows users to position child windows freely while maintaining visual hierarchy.[2][3]

### Communication Between Parent and Child Windows

Communication between parent and child windows can be achieved through multiple mechanisms depending on the window creation method. For same-origin content created via `window.open()`, the new window is created within the same process, enabling direct access between parent and child windows. The parent can access the child window directly through the returned window object and even render to the sub-window as if it were a `div` element in the parent.[5][1]

When using `window.open()` from the renderer, the parent window can access the child via the returned reference, while the child can access the parent using `window.opener`. The `postMessage()` API enables bidirectional message passing—parents send messages using `childWindow.postMessage(message)`, while children use `window.opener.postMessage(message)` to communicate back to the parent. Both windows listen for messages using `window.addEventListener('message', handler)`.[6]

For windows created in the main process, Inter-Process Communication (IPC) provides a structured communication channel. The main process can send messages to specific windows using `webContents.send()`, while renderers communicate back using `ipcRenderer.send()`. This approach enables centralized coordination of window relationships and data flow through the main process.[7]

### Window Creation from the Renderer

Windows opened from the renderer process using `window.open()` or links with `target="_blank"` are automatically paired with BrowserWindow instances created under the hood. The `webContents.setWindowOpenHandler()` method in the main process provides control over renderer-initiated window creation, allowing customization of BrowserWindow constructor options or denial of window creation altogether.[1]

#### Basic Handler Setup

```javascript
const { BrowserWindow } = require('electron');

const mainWindow = new BrowserWindow({
  webPreferences: {
    nodeIntegration: false,
    contextIsolation: true
  }
});

mainWindow.webContents.setWindowOpenHandler(({ url }) => {
  // Deny window creation for external URLs
  if (!url.startsWith('https://myapp.com')) {
    return { action: 'deny' };
  }
  
  // Allow window creation with custom options
  return {
    action: 'allow',
    overrideBrowserWindowOptions: {
      width: 800,
      height: 600,
      backgroundColor: '#ffffff'
    }
  };
});
```

The handler receives information about the requested window and returns an action object—`{ action: 'deny' }` cancels window creation, while `{ action: 'allow', overrideBrowserWindowOptions: { ... } }` permits creation with specified options.

#### Controlling Window Options

```javascript
// In renderer process
window.open('https://myapp.com/popup', '_blank', 'width=400,height=300');

// In main process handler
mainWindow.webContents.setWindowOpenHandler(({ url, features }) => {
  return {
    action: 'allow',
    overrideBrowserWindowOptions: {
      // These options override renderer's features string
      width: 1000,  // Overrides width=400 from renderer
      height: 800,  // Overrides height=300 from renderer
      frame: false,
      titleBarStyle: 'hidden'
    }
  };
});
```

This mechanism has final authority over window creation because it executes in the main process with full privileges, overriding any options specified in the renderer’s `window.open()` features string.[1]

#### Managing Window Lifecycle

```javascript
mainWindow.webContents.setWindowOpenHandler(({ url }) => {
  if (url.includes('/standalone')) {
    // Window survives even if parent closes
    return {
      action: 'allow',
      outlivesOpener: true,
      overrideBrowserWindowOptions: {
        width: 600,
        height: 400
      }
    };
  }
  
  // Default behavior: window closes with parent
  return {
    action: 'allow',
    outlivesOpener: false  // Automatic cleanup
  };
});
```

The `outlivesOpener` option controls whether child windows persist after their opener closes. Setting `{ action: 'allow', outlivesOpener: true }` creates windows that remain open even when their parent closes, defaulting to `false` for automatic cleanup.[1]

#### Event Handling for New Windows

When a new window is created through `window.open()`, several events fire in sequence to track the window creation lifecycle. The `webContents` object emits a `'did-create-window'` event after the window has been successfully created, providing access to the new window instance.[Inference]

```javascript
mainWindow.webContents.on('did-create-window', (childWindow, details) => {
  console.log('New window created:', details.url);
  console.log('Window options:', details.options);
  
  // Access the child window
  childWindow.on('ready-to-show', () => {
    childWindow.show();
  });
});
```

The `details` object passed to the event handler contains information about how the window was created, including the target URL, referrer, and the disposition (whether it was opened as a new window, popup, or other type).[Inference]

#### Denying Window Creation

To prevent certain windows from opening, return `{ action: 'deny' }` from the `setWindowOpenHandler()` callback. This is useful for blocking popups or restricting navigation to specific domains.

```javascript
mainWindow.webContents.setWindowOpenHandler(({ url }) => {
  // Block all external links
  if (!url.startsWith('https://myapp.com')) {
    return { action: 'deny' };
  }
  
  return { action: 'allow' };
});
```

#### Customizing Window Options

The `overrideBrowserWindowOptions` property allows complete customization of the child window's appearance and behavior, overriding any features specified in the renderer's `window.open()` call.

```javascript
mainWindow.webContents.setWindowOpenHandler(({ url, frameName }) => {
  return {
    action: 'allow',
    overrideBrowserWindowOptions: {
      width: 800,
      height: 600,
      frame: true,
      webPreferences: {
        preload: path.join(__dirname, 'preload.js'),
        contextIsolation: true,
        nodeIntegration: false
      }
    }
  };
});
```

#### Handling Different Window Types

Different window dispositions require different handling strategies. The `details.disposition` property indicates how the window should be opened.[Inference]

```javascript
mainWindow.webContents.setWindowOpenHandler(({ url, disposition }) => {
  if (disposition === 'foreground-tab') {
    // Handle links meant to open in new tab
    shell.openExternal(url);
    return { action: 'deny' };
  }
  
  if (disposition === 'new-window') {
    // Allow popup windows with custom settings
    return {
      action: 'allow',
      overrideBrowserWindowOptions: {
        modal: true,
        parent: mainWindow,
        width: 400,
        height: 300
      }
    };
  }
  
  return { action: 'allow' };
});
```

#### Child Window Lifecycle Management

The `outlivesOpener` option determines whether child windows should close automatically when their parent closes. This is particularly important for modal dialogs or dependent windows.

```javascript
mainWindow.webContents.setWindowOpenHandler(({ url }) => {
  if (url.includes('/dialog')) {
    // Dialog should close with parent
    return {
      action: 'allow',
      outlivesOpener: false,
      overrideBrowserWindowOptions: {
        modal: true,
        parent: mainWindow
      }
    };
  }
  
  // Independent windows survive parent closure
  return {
    action: 'allow',
    outlivesOpener: true
  };
});
```

#### Security Considerations

[Inference] Window creation handlers should validate URLs and apply security restrictions to prevent malicious sites from opening arbitrary windows or accessing sensitive resources.

```javascript
const ALLOWED_DOMAINS = ['myapp.com', 'trusted-partner.com'];

mainWindow.webContents.setWindowOpenHandler(({ url }) => {
  const urlObj = new URL(url);
  
  if (!ALLOWED_DOMAINS.includes(urlObj.hostname)) {
    console.warn('Blocked window creation for untrusted domain:', url);
    return { action: 'deny' };
  }
  
  return {
    action: 'allow',
    overrideBrowserWindowOptions: {
      webPreferences: {
        nodeIntegration: false,
        contextIsolation: true,
        sandbox: true
      }
    }
  };
});
```

### Security and Inheritance

Child windows inherit certain security-related settings from their parent windows. Node integration is always disabled in child windows if disabled in the parent, context isolation is always enabled in children if enabled in the parent, and JavaScript is always disabled in children if disabled in the parent. This inheritance ensures that child windows cannot bypass security restrictions established at the parent level.[1]

### `about:blank` Window Behavior

In Chromium (and therefore Electron), `about:blank` is treated as a *special internal URL*. It is not loaded through the normal browser-side navigation pipeline. Instead, the renderer creates an empty document locally. Because no browser-side navigation occurs, Chromium does not get an opportunity to re-evaluate or override security and process-level settings for the new page.

Electron’s `WebPreferences` (such as `nodeIntegration`, `contextIsolation`, `sandbox`, and `preload`) are bound to the *renderer process* at creation time. Normally, a navigation can trigger logic that decides whether a new renderer process is needed, with different preferences. That logic is skipped for `about:blank`.

An analogy: think of a renderer process as a sealed room whose rules are fixed when the door is built. A normal navigation is like deciding to move into a different room with different rules. `about:blank` is like repainting the walls of the same room—you never leave it, so the rules remain unchanged.

---

#### What “copied from the parent window” actually means

More precisely, when a child window is created and initially loads `about:blank`, Chromium reuses the same renderer process configuration as the opener (parent). Electron has no hook to apply different `WebPreferences` because:

1. No browser-side navigation occurs.
2. No new renderer process is created.
3. The existing process already has its preferences locked in.

So the child window *inherits* the effective preferences of the parent renderer, regardless of what you specified when creating the child `BrowserWindow`.

---

#### Demonstration in Electron

##### Parent window

```js
const parent = new BrowserWindow({
  webPreferences: {
    nodeIntegration: true,
    contextIsolation: false,
  }
});

parent.loadURL('about:blank');
```

##### Child window (attempting override)

```js
const child = new BrowserWindow({
  parent,
  webPreferences: {
    nodeIntegration: false,       // attempt to disable
    contextIsolation: true,        // attempt to enable
    preload: path.join(__dirname, 'preload.js')
  }
});

child.loadURL('about:blank');
```

##### Observation

Inside the child window’s DevTools console:

```js
typeof require
```

**Output:**

```
"function"
```

This confirms `nodeIntegration` is still enabled, even though the child window explicitly requested it to be disabled. The parent’s preferences remain in effect.

---

#### Why Electron cannot “fix” this

Electron sits above Chromium. The decision to skip browser-side navigation for `about:blank` is made inside Chromium itself. Electron does not receive a navigation event where it could:

* Recompute `WebPreferences`
* Swap renderer processes
* Apply a new preload or isolation model

From Electron’s perspective, nothing “navigated.”

---

#### How to force preferences to apply

To ensure that the child window gets its own `WebPreferences`, you must trigger a real navigation that Chromium treats as browser-side.

##### Correct approach

```js
child.loadURL('data:text/html,<html></html>');
```

or

```js
child.loadFile('empty.html');
```

In these cases, Chromium performs a full navigation, allowing Electron to:

* Create a new renderer process if needed
* Apply the child window’s `WebPreferences` correctly

Analogy: instead of repainting the room, you are moving into a new one, so the house rules can change.

---

#### Key takeaways

1. `about:blank` does not trigger browser-side navigation.
2. Renderer process preferences are immutable after creation.
3. Child windows loading `about:blank` effectively inherit the parent’s renderer configuration.
4. Use `data:` URLs or real files if you need different `WebPreferences`.

If you want, I can also explain how this interacts with `window.open`, `nativeWindowOpen`, or site-instance isolation in Chromium.

---

Sources
[1] BrowserWindow | Electron https://electronjs.org/docs/latest/api/browser-window
[2] BaseWindow https://www.electronjs.org/docs/latest/api/base-window
[3] Master Electron: BrowserWindow - Parent & Child Windows - YouTube https://www.youtube.com/watch?v=l75UxvoRyI4
[4] Electron browser window - Stack Overflow https://stackoverflow.com/questions/47673817/electron-browser-window
[5] Opening windows from the renderer | Electron https://electronjs.org/docs/latest/api/window-open
[6] 初心者向き！Electronで親ウィンドウ↔子ウィンドウのデータ ... https://blog.capilano-fw.com/?p=2593
[7] How to Login Electron Application with Child Windows - Steemit https://steemit.com/utopianio/@pckurdu/how-to-login-electron-application-with-child-windows
[8] Access parent window's 'window' object from child window - Electron https://stackoverflow.com/questions/56220640/access-parent-windows-window-object-from-child-window-electron
[9] Set BrowserWindow options defaults for child windows ? · Issue #2781 https://github.com/electron/electron/issues/2781
[10] Creating multi-window Electron apps using React portals https://pietrasiak.com/creating-multi-window-electron-apps-using-react-portals

---

