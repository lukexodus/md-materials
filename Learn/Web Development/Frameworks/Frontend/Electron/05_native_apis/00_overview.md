## Overview


### Dialog Module

The Electron.js dialog module provides access to native system dialogs for file operations, alerts, and other interactions. It runs in the Main process and enables cross-platform file selection, saving, message boxes, and error dialogs.[1]

#### File Opening Dialogs

The module offers both synchronous and asynchronous methods for opening files.[1]

**Asynchronous (Recommended)**
```javascript
const { dialog } = require('electron')

dialog.showOpenDialog(mainWindow, {
  properties: ['openFile', 'multiSelections']
}).then(result => {
  console.log(result.canceled)
  console.log(result.filePaths)
}).catch(err => {
  console.log(err)
})
```

This returns a Promise resolving to an object with `canceled` (boolean) and `filePaths` (string array) properties.[1]

**Synchronous**
```javascript
const filePaths = dialog.showOpenDialogSync({
  properties: ['openFile', 'multiSelections']
})
```

Returns `string[] | undefined` - the selected file paths, or `undefined` if cancelled [1].

#### Save Dialogs

Save dialogs follow the same pattern with async/sync variants.[1]

**Asynchronous**
```javascript
dialog.showSaveDialog(mainWindow, options).then(result => {
  console.log(result.filePath)
})
```

Returns a Promise with `canceled` (boolean) and `filePath` (string) properties. On macOS, the asynchronous version is recommended to avoid issues when expanding/collapsing the dialog.[1]

**Synchronous**
```javascript
const filePath = dialog.showSaveDialogSync(options)
```

Returns a string containing the chosen path, or empty string if cancelled.[1]

#### File Filters

Both open and save dialogs support file type filtering through the `filters` option:[1]

```javascript
{
  filters: [
    { name: 'Images', extensions: ['jpg', 'png', 'gif'] },
    { name: 'Movies', extensions: ['mkv', 'avi', 'mp4'] },
    { name: 'All Files', extensions: ['*'] }
  ]
}
```

Extensions should be specified without wildcards or dots - `'png'` is correct, but `'.png'` and `'*.png'` are invalid.[1]

#### Dialog Properties

The `properties` array controls dialog behavior:[1]

- `openFile` - Allow files to be selected
- `openDirectory` - Allow directories to be selected
- `multiSelections` - Allow multiple paths to be selected
- `showHiddenFiles` - Show hidden files in dialog
- `createDirectory` (macOS) - Allow creating new directories
- `promptToCreate` (Windows) - Prompt for creation if entered path doesn't exist

On Windows and Linux, dialogs cannot be both file and directory selectors simultaneously - setting `['openFile', 'openDirectory']` will show a directory selector.[1]

#### Modal Windows

The optional `window` parameter attaches the dialog to a parent window, making it modal:[1]

```javascript
dialog.showOpenDialog(mainWindow, options)
```

On macOS, dialogs are presented as sheets attached to the window if a `BaseWindow` reference is provided, or as modals if no window is specified.[1]

Sources
[1] dialog https://www.electronjs.org/docs/latest/api/dialog
[2] dialog | Electron https://www.electronjs.org/de/docs/latest/api/dialog
[3] dialog · Electron documentation https://tinydew4.gitbooks.io/electron/content/api/dialog.html
[4] dialog | Electron 中文网 https://electron.nodejs.cn/docs/latest/api/dialog/
[5] electron/docs/api/dialog.md at main · electron/electron https://github.com/electron/electron/blob/main/docs/api/dialog.md
[6] eightnineight/electron-dialog https://www.npmjs.com/package/@eightnineight/electron-dialog?activeTab=readme
[7] How to show an open file native dialog with Electron? https://stackoverflow.com/questions/45849190/how-to-show-an-open-file-native-dialog-with-electron
[8] dialog · GitBook http://electron.ebookchain.org/en/api/dialog.html
[9] showOpenDialog / showSaveDialog opens _behind_ the ... https://github.com/electron/electron/issues/32857
[10] Dialog · ElectronNET/Electron.NET Wiki https://github.com/ElectronNET/Electron.NET/wiki/Dialog


---

### Menu Creation and Customization

Electron's Menu class provides a cross-platform API for creating native application menus, context menus, tray menus, and dock menus. The Menu class operates in the Main process and consists of multiple MenuItem instances that can be nested.[1][2]

#### Building Menus

Electron offers two approaches to construct menus.[1]

**Template Helper (Recommended)**
```javascript
const { Menu } = require('electron')

const menu = Menu.buildFromTemplate([{
  label: 'Menu',
  submenu: [
    { label: 'Hello' },
    { type: 'separator' },
    { label: 'Electron', type: 'checkbox', checked: true }
  ]
}])

Menu.setApplicationMenu(menu)
```

**Manual Construction**
```javascript
const submenu = new Menu()
submenu.append(new MenuItem({ label: 'Hello' }))
submenu.append(new MenuItem({ type: 'separator' }))
submenu.append(new MenuItem({ label: 'Electron', type: 'checkbox', checked: true }))

const menu = new Menu()
menu.append(new MenuItem({ label: 'Menu', submenu }))
Menu.setApplicationMenu(menu)
```

The template helper reduces boilerplate by passing MenuItem constructor options in a single array rather than appending each item individually.[1]

#### Menu Item Types

Menu items can have different types that grant specific appearance and functionality.[1]

- `normal` - Default type for standard menu items
- `checkbox` - Toggles the `checked` property when clicked
- `radio` - Toggles `checked` and turns off adjacent radio items at the same submenu level
- `separator` - Visual divider between menu sections (does not require a label)
- `submenu` - Automatically assigned when the `submenu` property is present
- `palette` - Creates horizontal item alignment (macOS 14+)
- `header` - Section header for grouping items (macOS 14+)

Adjacent radio items are determined by being at the same submenu level without a separator between them.[1]

#### Roles

Roles provide predefined behaviors for common menu actions, offering the best native experience across platforms.[1]

**Common Roles**
- Edit: `undo`, `redo`, `cut`, `copy`, `paste`, `pasteAndMatchStyle`, `selectAll`, `delete`
- Window: `minimize`, `close`, `quit`, `reload`, `forceReload`, `toggleDevTools`, `togglefullscreen`, `resetZoom`, `zoomIn`, `zoomOut`
- Default menus: `fileMenu`, `editMenu`, `viewMenu`, `windowMenu`

Role strings are case-insensitive (`toggleDevTools`, `toggledevtools`, and `TOGGLEDEVTOOLS` are equivalent). When using a role, the `label` and `accelerator` properties are optional and will default to platform-appropriate values.[1]

#### Accelerators

Keyboard shortcuts can be assigned using the `accelerator` property:[1]

```javascript
{
  label: 'Reload',
  accelerator: 'CmdOrCtrl+R',
  click: (item, focusedWindow) => {
    if (focusedWindow) focusedWindow.reload()
  }
}
```

Platform-specific accelerators use `CmdOrCtrl` for cross-platform compatibility (Command on macOS, Control on Windows/Linux).[3]

#### Advanced Customization

**Programmatic Positioning**

Control item placement using `id`, `before`, `after`, `beforeGroupContaining`, and `afterGroupContaining` attributes:[1]

```javascript
[
  { id: '1', label: 'one', after: ['3'] },
  { id: '2', label: 'two', before: ['1'] },
  { id: '3', label: 'three' }
]
// Results in: three, two, one
```

**Icons**

Assign images to menu items using the `icon` property with NativeImage instances:[1]

```javascript
const { nativeImage, MenuItem } = require('electron')
const icon = nativeImage.createFromPath('path/to/image.png')

const item = new MenuItem({
  label: 'Custom Icon',
  icon: icon
})
```

**Sublabels (macOS 14.4+)**

Add descriptive subtitles below menu item labels:[1]

```javascript
{
  label: 'Log Message',
  sublabel: 'This will use the console.log utility',
  click: () => { console.log('Logging via menu...') }
}
```

**Tooltips (macOS)**

Display hover information using the `toolTip` property:[1]

```javascript
{
  label: 'Hover Over Me',
  toolTip: 'This is additional info that appears on hover'
}
```

#### Setting Menus

**Application Menu**

Set the top-level application menu using `Menu.setApplicationMenu()`:[2]

```javascript
app.on('ready', () => {
  const menu = Menu.buildFromTemplate(template)
  Menu.setApplicationMenu(menu)
})
```

On Windows and Linux, use `&` in top-level item names to create Alt-key accelerators (e.g., `&File` creates Alt-F). Passing `null` removes the menu entirely.[2]

**Context Menus**

Display context menus using the `popup()` method:[2]

```javascript
menu.popup({ window: mainWindow })
```

Context menus are typically triggered on right-click events and appear at the cursor position.[3]

Sources
[1] dialog · Electron documentation https://tinydew4.gitbooks.io/electron/content/api/dialog.html
[2] dialog | Electron 中文网 https://electron.nodejs.cn/docs/latest/api/dialog/
[3] Menu · Electron documentation https://tinydew4.gitbooks.io/electron/content/api/menu.html
[4] Menu | Electron https://electronjs.org/docs/latest/api/menu
[5] Menus | Electron https://electronjs.org/docs/latest/tutorial/menus
[6] Application Menu | Electron https://electronjs.org/ru/docs/latest/tutorial/application-menu
[7] Electron Application Menu Working Example - Stack Overflow https://stackoverflow.com/questions/41258906/electron-application-menu-working-example
[8] The Complete Electron JS Menu Tutorial (Top Menus, Context ... https://www.youtube.com/watch?v=4aIanHYViOM
[9] Menus https://www.electronjs.org/docs/latest/tutorial/menus
[10] How to Create Custom Desktop Menus in Electron : r/electronjs https://www.reddit.com/r/electronjs/comments/1fpalmw/how_to_create_custom_desktop_menus_in_electron/
[11] Create Electron Menu in TypeScript? - Stack Overflow https://stackoverflow.com/questions/45811603/create-electron-menu-in-typescript
[12] Menu - Electron http://electronproject.org/menu.html

---

### Context Menus Implementation

Context menus are right-click pop-up menus that appear when users trigger specific events in Electron applications. Electron doesn't provide default context menus, but they can be created using the `menu.popup()` function and event listeners.[1]

#### Implementation Approaches

Context menus can be implemented through two primary methods in Electron.[1]

##### Using the `context-menu` Event (WebContents)

The Main process can listen to the `context-menu` event on WebContents, which provides detailed context information:[2][1]

**Main Process**
```javascript
const { app, BrowserWindow, Menu } = require('electron')

let mainWindow

app.whenReady().then(() => {
  mainWindow = new BrowserWindow({
    webPreferences: {
      contextIsolation: true
    }
  })

  mainWindow.webContents.on('context-menu', (event, params) => {
    const template = buildMenuTemplate(params)
    const contextMenu = Menu.buildFromTemplate(template)
    contextMenu.popup({ window: mainWindow })
  })
})

function buildMenuTemplate(params) {
  return [
    { label: 'Copy', role: 'copy', enabled: params.editFlags.canCopy },
    { label: 'Paste', role: 'paste', enabled: params.editFlags.canPaste },
    { type: 'separator' },
    { label: 'Inspect', click: () => { 
      mainWindow.webContents.inspectElement(params.x, params.y) 
    }}
  ]
}
```

The `params` object contains rich context information including clicked element type (`mediaType`, `linkURL`, `srcURL`), selection status, and edit flags.[3][2]

##### Using the DOM `contextmenu` Event (Renderer)

The Renderer process can listen to the DOM `contextmenu` event and communicate with Main via IPC:[4][1]

**Renderer Process (Preload/Renderer)**
```javascript
const { ipcRenderer } = require('electron/renderer')

window.addEventListener('contextmenu', (e) => {
  e.preventDefault()
  ipcRenderer.send('show-context-menu')
})

ipcRenderer.on('context-menu-command', (e, command) => {
  // Handle menu command
  console.log(`Command received: ${command}`)
})
```

**Main Process**
```javascript
const { ipcMain, Menu, BrowserWindow } = require('electron')

ipcMain.on('show-context-menu', (event) => {
  const template = [
    {
      label: 'Menu Item 1',
      click: () => { event.sender.send('context-menu-command', 'menu-item-1') }
    },
    { type: 'separator' },
    { label: 'Menu Item 2', type: 'checkbox', checked: true }
  ]
  
  const menu = Menu.buildFromTemplate(template)
  menu.popup({ window: BrowserWindow.fromWebContents(event.sender) })
})
```

This approach requires manual event prevention and IPC setup but provides more control over when context menus appear.[4][1]

#### Dynamic Context Menus

Context menus can be dynamically configured based on the clicked element by passing element-specific data through IPC:[5]

**Renderer Process**
```javascript
window.addEventListener('contextmenu', (e) => {
  e.preventDefault()
  
  const elementData = {
    id: e.target.id,
    tagName: e.target.tagName,
    classList: Array.from(e.target.classList)
  }
  
  ipcRenderer.send('show-context-menu', elementData)
})
```

**Main Process**
```javascript
ipcMain.on('show-context-menu', (event, elementData) => {
  const template = [
    {
      label: `Edit ${elementData.tagName}`,
      enabled: elementData.id === 'p1' // Enable only for specific element
    },
    {
      label: 'Delete',
      visible: elementData.classList.includes('deletable')
    }
  ]
  
  const menu = Menu.buildFromTemplate(template)
  menu.popup({ window: BrowserWindow.fromWebContents(event.sender) })
})
```

Menu items can be conditionally enabled or hidden using the `enabled` and `visible` properties based on element properties.[3][5]

#### Context-Specific Menu Items

The `params` object from the `context-menu` event enables media-specific menus:[3]

```javascript
mainWindow.webContents.on('context-menu', (event, params) => {
  const template = []
  
  if (params.mediaType === 'image') {
    template.push({
      label: 'Save Image',
      click: () => { /* save image logic */ }
    })
  }
  
  if (params.linkURL) {
    template.push({
      label: 'Open Link',
      click: () => { require('electron').shell.openExternal(params.linkURL) }
    })
  }
  
  if (params.selectionText) {
    template.push({
      label: `Search for "${params.selectionText}"`,
      click: () => { /* search logic */ }
    })
  }
  
  const menu = Menu.buildFromTemplate(template)
  menu.popup()
})
```

This allows menus to adapt based on images, links, selected text, or video elements.[2][3]

#### Third-Party Libraries

The `electron-context-menu` package simplifies context menu implementation with pre-built actions:[6][7]

```javascript
const { app } = require('electron')
const contextMenu = require('electron-context-menu')

contextMenu({
  prepend: (actions, params, browserWindow) => [
    {
      label: 'Custom Action',
      visible: params.mediaType === 'image'
    },
    actions.separator(),
    actions.copyLink({
      transform: content => `modified_link_${content}`
    })
  ],
  showInspectElement: true
})
```

This library provides built-in actions like `copy`, `paste`, `copyLink`, `saveImage`, and `inspect` with customizable transforms.[7][6][3]

Sources
[1] Context Menu https://electronjs.org/docs/latest/tutorial/context-menu
[2] How to Display Context Menus in Electron Applications https://developer.mamezou-tech.com/en/blogs/2025/01/07/build-context-menu-in-electron-app/
[3] How to implement a native context menu (with inspect element) in ... https://ourcodeworld.com/articles/read/874/how-to-implement-a-native-context-menu-with-inspect-element-in-electron-framework
[4] Menu | Electron https://electrondelta.com/menu.html
[5] Electron: Dynamic context menu - javascript - Stack Overflow https://stackoverflow.com/questions/62745948/electron-dynamic-context-menu
[6] sindresorhus/electron-context-menu https://github.com/sindresorhus/electron-context-menu
[7] electron-context-menu https://www.npmjs.com/package/electron-context-menu
[8] The Complete Electron JS Menu Tutorial (Top Menus, Context Menus & Accelerators) https://www.youtube.com/watch?v=4aIanHYViOM
[9] Top 10 Examples of electron-context-menu code in ... https://www.clouddefense.ai/code/javascript/example/electron-context-menu
[10] An Example of how to show context-menu in Electron - GitHub Gist https://gist.github.com/0ecaf45852ad7e3cd7c4bae077798c48

---

### Application Menus and Menu Bars

Application menus are the top-level menus in Electron apps that display differently based on platform. On macOS, the menu appears in the system menu bar, while on Windows and Linux, it appears at the top of each BaseWindow.[1]

#### Creating Application Menus

Application menus are set using `Menu.setApplicationMenu()` and must be called after the `ready` event.[2][1]

**Basic Setup**
```javascript
const { app, Menu } = require('electron/main')

app.on('ready', () => {
  const template = [
    {
      label: 'File',
      submenu: [
        { role: 'quit' }
      ]
    }
  ]
  
  const menu = Menu.buildFromTemplate(template)
  Menu.setApplicationMenu(menu)
})
```

Each top-level menu item **must be a submenu** in Electron's application menu structure. If `setApplicationMenu()` is never called, Electron provides a default menu automatically.[3][4][1]

#### Cross-Platform Menu Templates

Application menus require platform-specific handling, especially for macOS.[5][1]

**Full Cross-Platform Template**
```javascript
const { app, Menu, shell } = require('electron/main')
const isMac = process.platform === 'darwin'

const template = [
  // App Menu (macOS only)
  ...(isMac ? [{
    label: app.name,
    submenu: [
      { role: 'about' },
      { type: 'separator' },
      { role: 'services' },
      { type: 'separator' },
      { role: 'hide' },
      { role: 'hideOthers' },
      { role: 'unhide' },
      { type: 'separator' },
      { role: 'quit' }
    ]
  }] : []),
  
  // File Menu
  {
    label: 'File',
    submenu: [
      isMac ? { role: 'close' } : { role: 'quit' }
    ]
  },
  
  // Edit Menu
  {
    label: 'Edit',
    submenu: [
      { role: 'undo' },
      { role: 'redo' },
      { type: 'separator' },
      { role: 'cut' },
      { role: 'copy' },
      { role: 'paste' },
      ...(isMac ? [
        { role: 'pasteAndMatchStyle' },
        { role: 'delete' },
        { role: 'selectAll' },
        { type: 'separator' },
        {
          label: 'Speech',
          submenu: [
            { role: 'startSpeaking' },
            { role: 'stopSpeaking' }
          ]
        }
      ] : [
        { role: 'delete' },
        { type: 'separator' },
        { role: 'selectAll' }
      ])
    ]
  },
  
  // View Menu
  {
    label: 'View',
    submenu: [
      { role: 'reload' },
      { role: 'forceReload' },
      { role: 'toggleDevTools' },
      { type: 'separator' },
      { role: 'resetZoom' },
      { role: 'zoomIn' },
      { role: 'zoomOut' },
      { type: 'separator' },
      { role: 'togglefullscreen' }
    ]
  },
  
  // Window Menu
  {
    label: 'Window',
    submenu: [
      { role: 'minimize' },
      { role: 'zoom' },
      ...(isMac ? [
        { type: 'separator' },
        { role: 'front' },
        { type: 'separator' },
        { role: 'window' }
      ] : [
        { role: 'close' }
      ])
    ]
  },
  
  // Help Menu
  {
    role: 'help',
    submenu: [
      {
        label: 'Learn More',
        click: async () => {
          await shell.openExternal('https://electronjs.org')
        }
      }
    ]
  }
]

const menu = Menu.buildFromTemplate(template)
Menu.setApplicationMenu(menu)
```

The conditional spread operator (`...`) enables platform-specific menu items without code duplication.[1]

#### Standard Menu Roles

Electron provides shorthand roles that create entire submenu structures automatically.[1]

**Using Default Submenus**
```javascript
const template = [
  ...(process.platform === 'darwin' ? [{ role: 'appMenu' }] : []),
  { role: 'fileMenu' },
  { role: 'editMenu' },
  { role: 'viewMenu' },
  { role: 'windowMenu' },
  {
    role: 'help',
    submenu: [
      {
        label: 'Learn More',
        click: async () => {
          await shell.openExternal('https://electronjs.org')
        }
      }
    ]
  }
]
```

The default submenu roles (`fileMenu`, `editMenu`, `viewMenu`, `windowMenu`) automatically include platform-appropriate menu items. The `appMenu` role creates the macOS-specific app menu with the application name.[6][1]

#### macOS-Specific Behavior

macOS menus have unique characteristics compared to Windows and Linux.[5][1]

- The first submenu **always** displays the application name as its label, regardless of the specified `label` property[2][1]
- Standard menus like Services and Windows are recognized via roles (`services`, `window`, `help`)[5]
- The `help` role creates a top-level Help submenu with a built-in search bar that searches all menu items[1]
- The `appMenu` role should be used conditionally to populate the app-name menu[1]

#### Window-Specific Menus

On Windows and Linux, individual windows can have their own application menus.[3][1]

**Setting Per-Window Menus**
```javascript
const { BrowserWindow, Menu } = require('electron/main')

const win = new BrowserWindow()

const menu = Menu.buildFromTemplate([
  {
    label: 'my custom menu',
    submenu: [
      { role: 'copy' },
      { role: 'paste' }
    ]
  }
])

win.setMenu(menu)
```

This allows different windows to have different menu configurations. On macOS, `setApplicationMenu()` controls the global menu bar, while Windows and Linux set menus per-window.[7][3][1]

**Removing Window Menus**
```javascript
win.removeMenu()
```

This removes the application menu from a specific window on Windows and Linux.[1]

#### Keyboard Accelerators

On Windows and Linux, the `&` character in top-level menu labels creates Alt-key shortcuts.[8]

```javascript
{
  label: '&File',  // Creates Alt+F shortcut
  submenu: [...]
}
```

The underlined letter after `&` becomes the accelerator key when combined with Alt.[8]

#### Removing the Application Menu

Passing `null` to `setApplicationMenu()` removes the entire application menu:[7]

```javascript
Menu.setApplicationMenu(null)
```

This completely hides the menu bar, giving applications a cleaner, borderless appearance.[7]

Sources
[1] eightnineight/electron-dialog https://www.npmjs.com/package/@eightnineight/electron-dialog?activeTab=readme
[2] Electron Application Menu Working Example https://stackoverflow.com/questions/41258906/electron-application-menu-working-example
[3] Application Menu - Electron https://www.electronjs.org/docs/latest/tutorial/application-menu
[4] electron-default-menu - NPM https://www.npmjs.com/package/electron-default-menu
[5] Menu | Electron https://electrondelta.com/menu.html
[6] Menus | Electron https://electronjs.org/docs/latest/tutorial/menus
[7] Menu - Electron http://electronproject.org/menu.html
[8] How to add custom menu in menubar in mac with electron? https://stackoverflow.com/questions/37784164/how-to-add-custom-menu-in-menubar-in-mac-with-electron
[9] Application Menu https://www.electronjs.org/de/docs/latest/tutorial/application-menu
[10] How to Create Custom Desktop Menus in Electron | DoltHub Blog https://www.dolthub.com/blog/2024-09-25-how-to-create-custom-menus-in-electron/
[11] Building Cross-Platform Desktop Apps with Electron.NET - mescius https://developer.mescius.com/blogs/building-cross-platform-desktop-apps-with-electron-dot-net


---

### System Tray Integration

The Tray class adds icons and context menus to the system's notification area, running in the Main process. On macOS, the icon appears in the top-right menu bar extras area, on Windows in the taskbar notification area, and on Linux in locations that vary by desktop environment.[1][2]

#### Creating a Tray Icon

Tray icons are created using the Tray class constructor with either a NativeImage instance or a file path.[2][1]

**Basic Setup**
```javascript
const { app, Tray, Menu, nativeImage } = require('electron')

let tray = null

app.whenReady().then(() => {
  tray = new Tray('/path/to/icon.png')
  
  const contextMenu = Menu.buildFromTemplate([
    { label: 'Item1', type: 'radio' },
    { label: 'Item2', type: 'radio' },
    { label: 'Item3', type: 'radio', checked: true }
  ])
  
  tray.setToolTip('My Application')
  tray.setContextMenu(contextMenu)
})
```

The tray reference must be saved globally to prevent garbage collection. The Tray can only be instantiated after the `ready` event fires.[3][1][2]

#### Platform-Specific Icon Guidelines

Icon requirements differ across operating systems.[1]

**macOS**
- Use Template Images (filenames ending in "Template") for automatic color inversion[1]
- Recommended sizes: 16x16 (72dpi) and 32x32@2x (144dpi)[1]
- Retina displays require @2x images at 144dpi to avoid graininess[1]
- When bundling, ensure filenames aren't mangled or hashed by build tools[1]

**Windows**
- ICO format recommended for best visual effects[1]
- Supports optional GUID parameter for persistent tray positioning[1]

**Linux**
- Uses StatusNotifierItem by default, falls back to GtkStatusIcon when unavailable[1]
- Click event behavior varies by desktop environment (single vs double click)[1]

#### Attaching Context Menus

Tray context menus are set using `setContextMenu()` and automatically handle click events without requiring manual `popup()` calls.[2]

```javascript
const contextMenu = Menu.buildFromTemplate([
  {
    label: 'Show App',
    click: () => {
      mainWindow.show()
    }
  },
  { type: 'separator' },
  { role: 'quit' }
])

tray.setContextMenu(contextMenu)
```

On Linux, `setContextMenu()` must be called again after modifying individual MenuItem properties for changes to take effect:[1]

```javascript
contextMenu.items[1].checked = false
tray.setContextMenu(contextMenu) // Required on Linux
```

The `enabled` and `visible` properties are not available for top-level menu items in macOS tray menus.[2]

#### Dynamic Icon and Title Updates

The Tray API provides methods to update appearance dynamically.[2][1]

```javascript
const red = nativeImage.createFromDataURL('image/...')
const green = nativeImage.createFromDataURL('image/...')

const contextMenu = Menu.buildFromTemplate([
  {
    label: 'Set Green Icon',
    type: 'checkbox',
    click: ({ checked }) => {
      checked ? tray.setImage(green) : tray.setImage(red)
    }
  },
  {
    label: 'Set Title',
    type: 'checkbox',
    click: ({ checked }) => {
      checked ? tray.setTitle('Title') : tray.setTitle('')
    }
  }
])
```

The `setTitle()` method displays text next to the tray icon on macOS and supports ANSI colors. On macOS, use `setPressedImage()` to specify an image displayed when the icon is clicked.[1]

#### Minimizing to Tray

To keep the app running when all windows close, prevent the default quit behavior:[3][2]

```javascript
app.on('window-all-closed', () => {
  // Prevent app from quitting - keeps tray icon alive
})
```

The tray icon can restore windows through menu items:

```javascript
{
  label: 'Open App',
  click: () => {
    const wins = BrowserWindow.getAllWindows()
    if (wins.length === 0) {
      createWindow()
    } else {
      wins[0].focus()
    }
  }
}
```

This pattern allows apps to run in the background with tray access.[3][2]

#### Tray Events

The Tray class emits various interaction events.[1]

**Common Events**
- `click` - Tray icon clicked (behavior varies on Linux)
- `right-click` (macOS, Windows) - Right mouse button clicked
- `double-click` (macOS, Windows) - Icon double-clicked
- `mouse-enter` (macOS, Windows) - Mouse enters icon area
- `mouse-leave` (macOS, Windows) - Mouse exits icon area

**macOS-Specific Events**
- `drop-files` - Files dragged onto tray icon
- `drop-text` - Text dragged onto tray icon
- `drag-enter` / `drag-leave` - Drag operation events

**Windows-Specific Events**
- `balloon-show` / `balloon-click` / `balloon-closed` - Balloon notification events
- `middle-click` - Middle mouse button clicked

```javascript
tray.on('click', (event, bounds) => {
  console.log('Tray clicked at', bounds)
})
```

The `mouse-up` and `mouse-down` events on macOS won't fire if a context menu is set.[1]

In this context, `bounds` is a **geometry object** that describes **where the tray icon is located on the screen at the moment of the click**.

Brief background.  
Electron’s `Tray` integrates with the operating system’s system tray (menu bar on macOS, notification area on Windows/Linux). When the tray icon is clicked, Electron passes positional information so you can align UI elements—most commonly a popup window or menu—relative to the tray icon.

What `bounds` contains.  
`bounds` is an object with the following shape:

```js
{
  x: number,
  y: number,
  width: number,
  height: number
}
```

Meaning of each field.  
• `x`, `y`: The screen coordinates (in **device-independent pixels**) of the tray icon’s top-left corner.  
• `width`, `height`: The size of the tray icon’s clickable area.

Conceptual analogy.  
Think of `bounds` as the **bounding box drawn around the tray icon** on your monitor. It tells you where that box sits and how big it is, so you can place something next to it accurately.

Why Electron provides this.  
The tray location is:  
• Different across platforms.  
• Different depending on taskbar position (bottom, top, left, right).  
• Dynamic (can move between displays or change with DPI).

By giving you `bounds`, Electron saves you from guessing or hardcoding positions.

Typical use case.

```js
tray.on('click', (event, bounds) => {
  popupWindow.setPosition(
    Math.round(bounds.x),
    Math.round(bounds.y + bounds.height),
    false
  )
  popupWindow.show()
})
```

Here, the popup is positioned just below the tray icon.

Platform-specific notes.  
• macOS: `bounds` corresponds to the menu bar icon’s rect. This is the most reliable platform for tray positioning.  
• Windows: `bounds` maps to the notification area icon, but values can vary depending on taskbar settings and DPI scaling.  
• Linux: Support depends on the desktop environment; some provide less precise bounds.

Important cautions.

1. `bounds` should be treated as **advisory**, not absolute truth.
2. Always account for multi-monitor setups.
3. Avoid assuming the tray is always at the bottom or top of the screen.

In summary.  
`bounds` tells you **where the tray icon is and how big it is** at click time. It exists primarily to help you anchor windows or menus relative to the tray icon in a platform-safe way.

#### Advanced Methods

**Manual Context Menu Display**
```javascript
tray.popUpContextMenu(menu, { x: 100, y: 100 })
```

This displays a custom menu at specified coordinates (Windows only for position parameter).[1]

**Windows Balloon Notifications**
```javascript
tray.displayBalloon({
  icon: nativeImage.createFromPath('/path/to/icon.png'),
  title: 'Notification Title',
  content: 'Notification message content'
})
```

Balloon notifications are Windows-specific with events for show, click, and close.[4][1]

**GUID for Persistent Positioning**

On Windows and macOS, pass a GUID string to the constructor to maintain tray icon position between app relaunches:[1]

```javascript
const tray = new Tray('/path/to/icon', 'your-unique-guid-here')
```

The GUID must adhere to UUID format and becomes permanently associated with code-signed executables.[1]

Sources
[1] How to show an open file native dialog with Electron? https://stackoverflow.com/questions/45849190/how-to-show-an-open-file-native-dialog-with-electron
[2] dialog · GitBook http://electron.ebookchain.org/en/api/dialog.html
[3] how to show the app electronjs in the systemTray - DEV Community https://dev.to/fwldom/how-to-show-the-app-electronjs-in-the-systemtray-4250
[4] Tray · Electron documentation https://tinydew4.gitbooks.io/electron/content/api/tray.html
[5] Tray | Electron https://electronjs.org/docs/latest/api/tray
[6] Tray Menu - Electron https://electronjs.org/docs/latest/tutorial/tray
[7] Build an Electron Application with System Tray access - YouTube https://www.youtube.com/watch?v=g6RAttYljPE
[8] Tray · ElectronNET/Electron.NET Wiki - GitHub https://github.com/ElectronNET/Electron.NET/wiki/Tray
[9] Notifications (Windows, Linux, macOS) - Electron http://docs3.w3cub.com/electron/tutorial/notifications/
[10] Tray Menu https://www.electronjs.org/docs/latest/tutorial/tray
[11] Electron: Creating Tray Menu - DEV Community https://dev.to/franamorim/tutorial-alarm-widget-with-electron-react-2-34dd
[12] Desktop Environment Integration · Electron docs gitbook - imfly https://imfly.gitbooks.io/electron-docs-gitbook/content/en/tutorial/desktop-environment-integration.html

---

### Notifications API

Electron provides cross-platform notification APIs that differ based on process type. Main process notifications use the `Notification` module, while renderer process notifications use the standard HTML5 Notification API.[1]

#### Main Process Notifications

The Electron Notification class creates native OS desktop notifications with custom options.[2]

**Basic Implementation**
```javascript
const { Notification } = require('electron')

const notification = new Notification({
  title: 'Basic Notification',
  body: 'Notification from the Main process'
})

notification.show()
```

Unlike the HTML5 API, Electron's Notification objects **must call `show()`** explicitly to display. Simply instantiating them does not trigger display.[1][2]

**Checking Support**
```javascript
if (Notification.isSupported()) {
  // Notifications are supported on this system
  new Notification({ title: 'Hello', body: 'World' }).show()
}
```

The static `isSupported()` method verifies whether desktop notifications are available on the current system.[3][2]

#### Renderer Process Notifications

The renderer process uses the standard HTML5 Notification API available in web browsers.[4][1]

```javascript
const NOTIFICATION_TITLE = 'Title'
const NOTIFICATION_BODY = 'Notification from the Renderer process'

const notification = new Notification(NOTIFICATION_TITLE, { 
  body: NOTIFICATION_BODY,
  icon: '/path/to/icon.png'
})

notification.onclick = () => {
  console.log('Notification clicked')
}
```

HTML5 notifications display immediately upon instantiation without requiring an explicit `show()` call. The API is only available in the renderer process.[5][6][4]

#### Notification Options

Both APIs support various configuration options.[2]

**Common Options**
- `title` - Notification heading
- `subtitle` (macOS) - Secondary heading below title
- `body` - Main notification message text
- `icon` - Image displayed with notification
- `silent` - Boolean to suppress notification sound
- `sound` (macOS) - Name of sound file to play
- `timeoutType` (Linux, Windows) - Can be `'default'` or `'never'` for persistent notifications
- `urgency` (Linux) - Can be `'normal'`, `'critical'`, or `'low'`
- `actions` - Array of NotificationAction objects
- `closeButtonText` - Custom text for close button

```javascript
const notification = new Notification({
  title: 'Advanced Notification',
  subtitle: 'With extra features',
  body: 'This notification has custom settings',
  icon: nativeImage.createFromPath('/path/to/icon.png'),
  silent: false,
  sound: 'Ping',
  timeoutType: 'never',
  actions: [
    { type: 'button', text: 'Action 1' },
    { type: 'button', text: 'Action 2' }
  ]
})
```

#### Notification Events

The Main process Notification class emits several events for handling user interactions.[2]

**Available Events**
- `show` - Fired when notification appears (can fire multiple times if `show()` called repeatedly)
- `click` - User clicked the notification
- `close` - Notification dismissed manually or via timeout
- `reply` (macOS) - User submitted inline reply text
- `action` (macOS) - Action button clicked, provides action index
- `failed` (Windows) - Error occurred during `show()` execution

```javascript
notification.on('show', () => {
  console.log('Notification displayed')
})

notification.on('click', () => {
  console.log('User clicked notification')
  mainWindow.show()
})

notification.on('close', () => {
  console.log('Notification dismissed')
})

notification.on('reply', (event, reply) => {
  console.log('User replied:', reply)
})

notification.on('action', (event, index) => {
  console.log('Action clicked:', index)
})
```

The `close` event is not guaranteed to fire in all dismissal scenarios. On Windows, notifications remaining in the Action Center after the initial close event will not emit `close` again when removed via `notification.close()`.[2]

#### macOS-Specific Features

macOS supports additional notification capabilities.[1][2]

**Inline Replies**
```javascript
const notification = new Notification({
  title: 'Message Received',
  body: 'You have a new message',
  hasReply: true,
  replyPlaceholder: 'Type your response...'
})

notification.on('reply', (event, reply) => {
  console.log('User replied:', reply)
})

notification.show()
```

The `hasReply` option adds an inline text field for quick responses.[2]

**Custom Sounds**

Specify sound names from System Preferences > Sound or custom sound files located in specific directories:[2]

```javascript
const notification = new Notification({
  title: 'Custom Sound',
  body: 'Playing custom notification sound',
  sound: 'Ping' // or 'custom-sound.aiff'
})
```

Sound files must be in `~/Library/Sounds`, `/Library/Sounds`, `/Network/Library/Sounds`, `/System/Library/Sounds`, or the app bundle's Resources folder.[2]

**Size Limitations**

Notifications are limited to 256 bytes on macOS and will be truncated if exceeded.[4][1]

#### Windows-Specific Requirements

Windows requires additional setup for notifications to function properly.[6][1]

**Start Menu Shortcut**

Applications need a Start Menu shortcut with an AppUserModelID and ToastActivatorCLSID. During development, pin `node_modules\electron\dist\electron.exe` to the Start Menu and call:[6][1]

```javascript
app.setAppUserModelId(process.execPath)
```

In production using Squirrel.Windows or electron-winstaller, Electron handles this automatically.[1]

**Advanced Notifications**

For custom templates, images, and interactive elements, use third-party modules like `electron-windows-notifications` or `electron-windows-interactive-notifications`.[1]

**Querying Permission State**

The `windows-notification-state` module detects whether Windows will display notifications or silently discard them.[4][1]

#### Linux Implementation

Linux notifications use `libnotify` and work across desktop environments supporting the Desktop Notifications Specification (GNOME, KDE, Unity, Cinnamon, etc.).[1]

**Urgency Levels**
```javascript
const notification = new Notification({
  title: 'Critical Alert',
  body: 'This is an urgent notification',
  urgency: 'critical' // 'low', 'normal', or 'critical'
})
```

The `urgency` property controls notification priority and persistence.[2]

#### Permission Handling

The HTML5 Notification API includes permission methods, though Electron's implementation has known issues where `Notification.permission` may always return `'granted'`:[7]

```javascript
// Standard HTML5 permission request
Notification.requestPermission().then(permission => {
  if (permission === 'granted') {
    new Notification('Permission granted!')
  }
})
```

For production apps requiring accurate permission state detection, use platform-specific modules like `windows-notification-state` or `macos-notification-state`.[1]

Sources
[1] Dialog · ElectronNET/Electron.NET Wiki https://github.com/ElectronNET/Electron.NET/wiki/Dialog
[2] showOpenDialog / showSaveDialog opens _behind_ the ... https://github.com/electron/electron/issues/32857
[3] Notification | Electron https://electronjs.org/docs/latest/api/notification
[4] Notifications (Windows, Linux, macOS) | Electron - GitHub Pages https://zeke.github.io/electron.atom.io/docs/tutorial/notifications/
[5] Using native desktop notification with Electron Framework https://ourcodeworld.com/articles/read/204/using-native-desktop-notification-with-electron-framework
[6] Using Notification API for Electron App - Stack Overflow https://stackoverflow.com/questions/31606454/using-notification-api-for-electron-app
[7] Notification.permission always shows "granted" · Issue #11221 https://github.com/electron/electron/issues/11221
[8] Notification · ElectronNET/Electron.NET Wiki - GitHub https://github.com/ElectronNET/Electron.NET/wiki/Notification
[9] Notifications | Electron https://electronjs.org/docs/latest/tutorial/notifications
[10] Electron - Notifications - Tutorials Point https://www.tutorialspoint.com/electron/electron_notifications.htm
[11] How to do desktop notifications? · Issue #2421 · electron ... - GitHub https://github.com/electron/electron/issues/2421
[12] HTML5 notifications in electron apps with Angular https://thorsten-hans.com/html5-notifications-in-electron-apps-with-angular/


---

