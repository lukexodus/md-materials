## Modal Windows


Modal windows in Electron are specialized child windows that disable interaction with their parent window until closed, forcing users to complete or dismiss the modal before continuing with the parent application. This pattern is essential for critical dialogs, confirmations, preference panels, and workflows requiring focused user attention.[1][2][3]

### Creating Custom Modal Windows

Custom modal windows are created by setting both the `parent` and `modal` options to `true` in the BrowserWindow constructor. The `parent` option receives a reference to the parent BrowserWindow instance, establishing the hierarchical relationship. When `modal: true` is set, the parent window becomes non-interactive while the modal is open, preventing users from clicking or typing in the parent until the modal closes.[2][3][4][1]

```javascript
const { BrowserWindow } = require('electron')

const parent = new BrowserWindow()
const modal = new BrowserWindow({ 
  parent: parent, 
  modal: true, 
  show: false 
})

modal.loadURL('https://github.com')
modal.once('ready-to-show', () => {
  modal.show()
})
```

The best practice is to create modals with `show: false`, load content, then display them after the `ready-to-show` event fires. This prevents visual flashes and ensures the modal appears fully rendered when shown to users.[1]

### Platform-Specific Behaviors

Modal window behavior differs significantly across operating systems, requiring platform-specific testing and potentially conditional code. On macOS, modals appear as sheets attached to their parent window, creating a contextual dropdown effect within the parent window's frame. On Windows and Linux, modals appear as separate windows but maintain the parent-child relationship that prevents parent interaction.[3][4]

Developers should consult platform-specific documentation when implementing modals to understand these behavioral differences and design accordingly. The visual presentation and interaction model may require adjustments to create consistent user experiences across platforms.[3]

### Modal Window Lifecycle

Modal windows maintain a tight coupling with their parent windows through automatic lifecycle management. When the parent window closes, all child windows including modals are automatically closed, ensuring proper cleanup without manual tracking. This prevents orphaned modal windows from remaining open after their parent context no longer exists.[3]

The `isModal()` method returns a boolean indicating whether the current window is a modal window, enabling conditional logic based on modal state. This is useful for implementing different behaviors in code that handles both modal and non-modal windows.[2]

### Modal Window Positioning

Modal windows always appear on top of their parent window, maintaining z-order supremacy regardless of user interactions. When the parent window moves, modal windows do not automatically follow the parent's position on Windows and Linux—they remain at their original screen coordinates while maintaining the on-top relationship. On macOS, sheet-style modals remain attached to the parent window and move with it.[2][3]

The modal window can move freely within the constraints of being above its parent, allowing users to reposition modals for better visibility or workflow organization. However, users cannot interact with the parent window to move it while the modal is open, as the modal blocks all parent input.[4][3]

### Native System Dialogs

Electron provides the `dialog` module for creating native operating system modals for common tasks like file selection, message boxes, and error displays. These native dialogs automatically handle platform-specific styling and behavior, ensuring consistent user experiences with OS conventions.[5][6][7]

The `dialog.showMessageBox()` method displays a customizable message box that can be made modal by passing a BrowserWindow instance as the first parameter. This attaches the dialog to the parent window, making it modal and blocking parent interaction. If no BrowserWindow is provided, the dialog appears as an independent window that doesn't block other windows.[6][7][8]

```javascript
const { dialog, BrowserWindow } = require('electron')

dialog.showMessageBox(mainWindow, {
  type: 'info',
  title: 'Confirmation',
  message: 'Are you sure you want to continue?',
  buttons: ['Yes', 'No']
}).then(result => {
  console.log(result.response) // Index of clicked button
})
```

The method returns a Promise that resolves with an object containing the `response` property (the index of the clicked button) and `checkboxChecked` (the state of an optional checkbox). For synchronous modal behavior, use `dialog.showMessageBoxSync()`, which blocks the process until the dialog closes and returns the button index directly.[7][8]

### Dialog Types and Options

The `type` option in `showMessageBox()` specifies the dialog's appearance, accepting values `none`, `info`, `error`, `question`, and `warning`. Each type displays a corresponding icon and may play platform-specific sounds. On Windows, `question` displays the same icon as `info` unless an explicit icon is set, while on macOS, both `warning` and `error` display the same warning icon.[6]

The `buttons` array specifies button labels, with the first button typically representing the primary action. The `defaultId` option sets which button is selected by default, while `cancelId` specifies which button is triggered when users press Escape or close the dialog. Custom icons can be provided via the `icon` option, accepting NativeImage instances.[8][7]

### File and Directory Dialogs

The `dialog.showOpenDialog()` method displays native file and directory picker dialogs that can be made modal by passing a parent window reference. The `window` argument attaches the dialog to the parent window as a modal, blocking parent interaction until the dialog closes. The method returns a Promise resolving with an object containing `canceled` (boolean), `filePaths` (array of selected paths), and `bookmarks` (security-scoped bookmark data on macOS MAS builds).[7]

```javascript
dialog.showOpenDialog(mainWindow, {
  properties: ['openFile', 'multiSelections'],
  filters: [
    { name: 'Images', extensions: ['jpg', 'png', 'gif'] },
    { name: 'All Files', extensions: ['*'] }
  ]
}).then(result => {
  if (!result.canceled) {
    console.log(result.filePaths)
  }
})
```

The `properties` array controls dialog behavior, accepting values like `openFile`, `openDirectory`, `multiSelections`, `createDirectory`, and `showHiddenFiles`. Note that on Windows and Linux, a dialog cannot be both a file and directory selector—if both `openFile` and `openDirectory` are specified, a directory selector is shown.[7]

The `dialog.showSaveDialog()` method presents a save file dialog with similar modal capabilities. It returns a Promise with `canceled`, `filePath`, and `bookmark` properties. On macOS, the asynchronous version is recommended to avoid issues when expanding and collapsing the dialog.[7]

#### MacOS `bookmark` Option

In Electron, the `bookmarks` option of `dialog.showOpenDialog` is specific to **macOS sandboxed (MAS) builds** and is tied to Apple’s **security-scoped bookmarks** mechanism.

Background first.  
On macOS, a sandboxed app is not allowed to freely access arbitrary files. Even if the user selects a file or folder once, that permission normally lasts only for that session. Apple introduced _security-scoped bookmarks_ to let an app persist user-granted access across launches, without breaking sandbox rules.

Think of it like this analogy:  
Selecting a file in an open dialog is like being handed a temporary visitor pass to a building. A security-scoped bookmark is a notarized ID card created from that pass, which you can store and present later to regain access—without asking the guard again.

Now how this appears in Electron.

When you call:

```js
const result = await dialog.showOpenDialog({
  properties: ['openFile'],
  bookmarks: true
});
```

on **macOS MAS builds only**, Electron asks the OS to generate **bookmark data** for each selected path.

The returned result includes:

- `filePaths`: normal file system paths
- `bookmarks`: an array of opaque strings (base64-encoded bookmark data)

Those bookmark strings are what matter for long-term access.

What you do with the bookmarks:

1. Persist them somewhere safe (for example, app config or secure storage).
2. On a future app launch, resolve the bookmark back into a usable path.
3. Start a _security scope_ before accessing the file.
4. Stop the scope when done.

Conceptually:

- `filePaths` → “Where the file is”
- `bookmarks` → “Proof the user allowed access”

Why this is necessary.  
Without bookmarks, a sandboxed MAS app may:

- Fail to reopen previously selected files
- Get permission errors after restart
- Be rejected during App Store review if it works around sandbox rules

Important constraints and clarifications:

- This only works on **macOS App Store (MAS)** builds.
- On non-MAS macOS builds, `bookmarks` is ignored.
- On Windows and Linux, the option does nothing.
- The bookmark data is opaque; you must never parse or modify it.
- Access must always be user-initiated at least once (via dialog).

Common use cases:
- Remembering a user-selected workspace folder
- Persistent access to media libraries
- Reopening project files across app restarts

Mental model summary.  
`dialog.showOpenDialog` gives you permission _once_.  
`bookmarks: true` lets you save that permission in a reusable, sandbox-approved form.

### Synchronous vs Asynchronous Dialogs

In Electron, most dialog APIs are available in both asynchronous and synchronous forms. The difference is primarily about whether the main process waits (blocks) for the user to close the dialog before continuing execution.

An analogy: think of the main process as a cashier.
An asynchronous dialog is like asking a customer a question and continuing to prepare the receipt while waiting for their answer.
A synchronous dialog is like stopping everything at the counter until the customer answers.

#### Asynchronous dialogs (non-blocking)

Asynchronous dialog methods return a Promise. The main process remains responsive while the dialog is open, and the result is delivered later.

Common methods:

* `dialog.showMessageBox()`
* `dialog.showOpenDialog()`
* `dialog.showSaveDialog()`

Example: asynchronous message box.

```js
const { dialog } = require('electron');

async function showAsyncMessageBox() {
  const result = await dialog.showMessageBox({
    type: 'question',
    buttons: ['Yes', 'No'],
    title: 'Confirm',
    message: 'Do you want to continue?',
  });

  console.log(result.response); // index of the clicked button
}

showAsyncMessageBox();
```

Output (example):

```text
0
```

Here, `0` corresponds to the `"Yes"` button. While the dialog is open, the main process can still handle other events.

Asynchronous dialogs are generally preferred because they avoid freezing the app and scale better in complex applications.

#### Synchronous dialogs (blocking)

Synchronous dialog methods block the entire main process until the dialog is closed. Instead of returning a Promise, they return the result immediately.

Common methods:

* `dialog.showMessageBoxSync()`
* `dialog.showOpenDialogSync()`
* `dialog.showSaveDialogSync()`

Example: synchronous message box.

```js
const { dialog } = require('electron');

function showSyncMessageBox() {
  const response = dialog.showMessageBoxSync({
    type: 'question',
    buttons: ['Yes', 'No'],
    title: 'Confirm',
    message: 'Do you want to continue?',
  });

  console.log(response);
}

showSyncMessageBox();
```

Output (example):

```text
1
```

Here, `1` corresponds to the `"No"` button. Execution pauses at `showMessageBoxSync()` until the user responds.

Because the main process is blocked, excessive use of synchronous dialogs can degrade performance and make the app feel unresponsive.

#### When synchronous behavior is necessary

Some browser APIs, such as `alert()` and `confirm()`, are synchronous by design. They require an immediate return value to the caller.

When replacing these APIs in Electron (for example, via `setWindowOpenHandler` or custom preload logic), synchronous dialogs may be required to preserve the expected behavior.

Example: replacing `confirm()` behavior.

```js
const { dialog } = require('electron');

function confirmReplacement(message) {
  const response = dialog.showMessageBoxSync({
    type: 'question',
    buttons: ['OK', 'Cancel'],
    defaultId: 0,
    cancelId: 1,
    message,
  });

  return response === 0;
}

const confirmed = confirmReplacement('Are you sure?');
console.log(confirmed);
```

Output (example):

```text
true
```

In this case, synchronous blocking is intentional and appropriate because the caller expects a boolean result immediately.

### Error Dialogs

Electron provides a dedicated API for reporting fatal or early-stage errors: `dialog.showErrorBox(title, content)`. This method displays a modal error dialog and is intentionally simple.

An analogy: think of `showErrorBox()` as an emergency siren. It is designed to work even before the rest of the building’s systems are fully powered on.

#### Basic usage

`showErrorBox()` takes only two string arguments: a title and the message content.

```js
const { dialog } = require('electron');

dialog.showErrorBox(
  'Startup Error',
  'Failed to load configuration file.'
);
```

There is no return value, and the call is synchronous in behavior from the caller’s perspective.

#### Use before the `ready` event

Unlike most dialog APIs, `showErrorBox()` can be called safely before `app.whenReady()` or the `ready` event. This makes it suitable for reporting errors during very early startup, such as configuration parsing failures or missing critical files.

Example: early startup error handling.

```js
const { app, dialog } = require('electron');
const fs = require('fs');

try {
  fs.readFileSync('/path/to/required/config.json', 'utf8');
} catch (err) {
  dialog.showErrorBox(
    'Fatal Error',
    'The application cannot start because the configuration file is missing.'
  );
  app.exit(1);
}
```

On most platforms, this will show a native error dialog even though no windows have been created yet.

#### Platform-specific behavior on Linux

On Linux, there is an important limitation. If `showErrorBox()` is called before the app is ready, no GUI dialog is shown. Instead, the message is written to `stderr`.

Example behavior on Linux before `ready`:

```text
Fatal Error: The application cannot start because the configuration file is missing.
```

This behavior is intentional and reflects the lack of a guaranteed graphical environment at that stage of startup.

#### No parent window support

Unlike methods such as `showMessageBox()` or `showOpenDialog()`, `showErrorBox()` does not accept a `BrowserWindow` as a parent. The dialog is always independent and modal at the system level.

Example (note the absence of a window argument):

```js
dialog.showErrorBox(
  'Database Error',
  'Unable to connect to the database service.'
);
```

This design reinforces its role as a last-resort error notifier rather than a UI-integrated dialog.

#### When to use `showErrorBox()`

`showErrorBox()` is best used for:

* Fatal startup errors
* Configuration or environment issues detected before windows exist
* Situations where the app cannot continue running

For recoverable errors or user-driven flows, other dialog APIs (such as `showMessageBox()` or `showMessageBoxSync()`) are more appropriate because they provide richer options and better integration with application windows.

### Custom Modal Communication

For custom modal windows created with BrowserWindow, communication between parent and modal typically uses IPC mechanisms. The `electron-modal-window` module provides a simplified API for bidirectional messaging—parents send messages using `m.send(name, args, callback)` and listen with `m.on(name, callback)`, while modals use the same API from within their window context.[9]

#### Sending Messages from Parent to Modal

```javascript
// In parent window
const modal = new Modal('file://modal.html');

modal.send('user-data', { name: 'Alice', id: 123 }, (error, response) => {
  if (error) {
    console.error('Modal closed before responding');
  } else {
    console.log('Modal responded:', response);
  }
});
```

#### Listening for Messages in Modal

```javascript
// In modal window (modal.html)
const ipcRenderer = require('electron').ipcRenderer;

modal.on('user-data', (data, callback) => {
  console.log('Received from parent:', data);
  // Process the data
  const result = processUserData(data);
  // Send response back
  callback(null, result);
});
```

#### Bidirectional Communication

```javascript
// Parent listens for modal events
modal.on('validation-request', (data, callback) => {
  const isValid = validateInput(data);
  callback(null, { valid: isValid });
});

// Modal sends request to parent
modal.send('validation-request', { input: 'test@example.com' }, (error, response) => {
  if (!error && response.valid) {
    console.log('Validation passed');
  }
});
```

The modal's `window` property provides access to the underlying BrowserWindow instance, enabling direct manipulation of window properties and methods:

```javascript
// Access the BrowserWindow instance
modal.window.setSize(800, 600);
modal.window.center();
modal.window.on('close', () => {
  console.log('Modal is closing');
});
```

When the modal closes, any pending callbacks receive errors, allowing parent code to handle modal closure gracefully:

```javascript
modal.send('long-operation', { data: 'processing' }, (error, result) => {
  if (error) {
    console.log('Modal closed before operation completed');
    // Handle cleanup or retry logic
  } else {
    console.log('Operation completed:', result);
  }
});
```

In Electron, a “modal window” is just a child `BrowserWindow` that disables interaction with its parent until it closes. You can build this yourself with core Electron APIs or use a helper library like `electron-modal-window` for extra conveniences.[1][3]

#### Basic core‑Electron modal

In modern Electron, you create a modal window by setting both `parent` and `modal: true` when constructing a window.[3]

```js
const { BrowserWindow } = require('electron');

function openModal(parent) {
  const modal = new BrowserWindow({
    width: 400,
    height: 300,
    parent,          // parent BrowserWindow
    modal: true,     // makes it modal (disables parent)
    resizable: false,
    minimizable: false,
    maximizable: false,
    webPreferences: {
      nodeIntegration: true,
      contextIsolation: false,
    },
  });

  modal.loadFile('modal.html');
}
```

Key points:[3]
- `parent`: reference to the main/owner window.  
- `modal: true`: disables the parent while the child is open.  
- `win.isModal()` lets you check whether a window is modal.[3]

### Minimal example flow

1. In your main process, keep a reference to `mainWindow`.  
2. From a menu item or IPC call, invoke `openModal(mainWindow)`.  
3. `modal.html` contains your form/UI and sends data back via `ipcRenderer` or closes itself.

#### Using `electron-modal-window` (hyperdivision)

The `electron-modal-window` package wraps this pattern and provides a simple event‑based interface.[1]

Install:

```bash
npm install electron-modal-window
```

In the window that spawns the modal (renderer or preload, depending on your setup):[1]

```js
const modal = require('electron-modal-window');

const m = modal.createModal(`file://${__dirname}/modal.html`, {
  width: 300,
  height: 300,   // any BrowserWindow options
});

m.window;        // underlying BrowserWindow instance[web:1]

m.on('hello', (cb) => {
  // Fired when the modal sends 'hello'
  cb(null, 'world');  // reply to the modal
});
```

Inside `modal.html` JS:[1]

```js
const modal = require('electron-modal-window');

modal.send('hello', (err, val) => {
  if (!err) {
    console.log('they said', val); // 'world'
  }
});

// modal.window is the current BrowserWindow
console.log(modal.window.isModal()); // true (if created as modal)
```

API surface:[1]

- `modal.createModal(url, browserWindowOptions)` → returns `m`.  
  - `m.window`: underlying `BrowserWindow`.[1]
  - `m.on(name, ...args, cb)`: listen for messages from the modal.[1]
  - `m.send(name, ...args, [cb])`: send messages to the modal.[1]
- In the modal:  
  - `modal.on(name, ...args, cb)`: listen for messages from creator.[1]
  - `modal.send(name, ...args, [cb])`: message the creator.[1]
  - `modal.window`: the modal’s own `BrowserWindow`.[1]

#### Alternative: `electron-modal` (balena)

`electron-modal` is another small helper focused on opening modals from the renderer using child windows with promises and an instance interface.[7]

Example from renderer:[7]

```js
const modal = require('electron-modal');
const path = require('path');

modal.open(path.join(__dirname, 'modal.html'), {
  width: 400,
  height: 300,      // any BrowserWindow options
}, {
  title: 'electron-modal example', // arbitrary data passed to modal
}).then((instance) => {
  instance.on('increment', () => {
    console.log('Increment event received!');
  });

  instance.on('decrement', () => {
    console.log('Decrement event received!');
  });
});
```

On the modal side you can:[7]

- Call `modal.show()` / `modal.hide()` / `modal.isVisible()` to control visibility.  
- Use `modal.getData()` to access the data object passed to `open`.[7]

#### Quick comparison

| Aspect                | Core Electron modal                         | `electron-modal-window`                         | `electron-modal`                                  |
|-----------------------|---------------------------------------------|-------------------------------------------------|---------------------------------------------------|
| How it’s created      | `new BrowserWindow({ parent, modal: true })`[3] | `modal.createModal(url, options)`[1]        | `modal.open(html, options, data)`[7]          |
| Transport             | Your own `ipcMain` / `ipcRenderer` wiring   | Built‑in `on` / `send` request‑reply interface[1] | Promise that resolves to modal instance with events[7] |
| Control from modal    | Manual (IPC and `remote`/preload)           | `modal.send`, `modal.on`, `modal.window`[1] | `modal.show`, `modal.hide`, `modal.getData`[7] |
| Extra features        | Full control, but verbose                   | Simple event bridge between parent and modal[1] | Promise‑based opening, structured instance API[7] |


### Sheet Offset (macOS)

On macOS, dialogs presented as sheets attached to windows can have their vertical offset adjusted using `BaseWindow.getCurrentWindow().setSheetOffset(offset)`. This controls the distance from the window frame where sheets appear, enabling fine-tuned positioning of modal dialogs. Sheets provide a more integrated visual experience on macOS compared to separate modal windows.[7]

Sources
[1] BrowserWindow | Electron https://electronjs.org/docs/latest/api/browser-window
[2] BaseWindow https://www.electronjs.org/docs/latest/api/base-window
[3] Master Electron: BrowserWindow - Parent & Child Windows - YouTube https://www.youtube.com/watch?v=l75UxvoRyI4
[4] Electron browser window - Stack Overflow https://stackoverflow.com/questions/47673817/electron-browser-window
[5] How to Create Native OS Specific Popup Windows with Electron ... https://www.youtube.com/watch?v=q8DRUgSlwGc
[6] Custom Messages in ElectronJS https://www.geeksforgeeks.org/javascript/custom-messages-in-electronjs/
[7] app | FAQ - GitHub Pages https://imfly.github.io/electron-docs-gitbook/en/api/app.html
[8] Allow customization of default dialogs · Issue #2522 https://github.com/electron/electron/issues/2522
[9] Easily make electron modal windows - GitHub https://github.com/hyperdivision/electron-modal-window
[10] How do you create a modal in electron js? (javascript, html, css) https://stackoverflow.com/questions/60388871/how-do-you-create-a-modal-in-electron-js-javascript-html-css
[11] Creating multi-window Electron apps using React portals https://pietrasiak.com/creating-multi-window-electron-apps-using-react-portals

---

