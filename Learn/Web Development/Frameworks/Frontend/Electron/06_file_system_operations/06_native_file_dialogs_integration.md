## Native File Dialogs Integration


Electron's dialog module provides access to native system dialogs for opening and saving files. These dialogs are modal and run in the Main process, requiring IPC communication when triggered from renderer processes.[1][2][3][4]

### Opening Files with showOpenDialog()

The `showOpenDialog()` method displays the native file picker dialog and returns selected file paths.[4][1]

**Promise-Based (Recommended)**
```javascript
const { dialog } = require('electron')

dialog.showOpenDialog({
  properties: ['openFile', 'multiSelections']
}).then(result => {
  console.log('Cancelled:', result.canceled)
  console.log('File paths:', result.filePaths)
}).catch(err => {
  console.error('Dialog error:', err)
})
```

The method returns a Promise that resolves to an object with `canceled` (boolean) and `filePaths` (array of strings) properties.[1][4]

**With Parent Window**
```javascript
const { dialog, BrowserWindow } = require('electron')

const mainWindow = BrowserWindow.getFocusedWindow()

dialog.showOpenDialog(mainWindow, {
  title: 'Choose Files',
  buttonLabel: 'Select',
  defaultPath: app.getPath('documents'),
  properties: ['openFile', 'multiSelections']
}).then(result => {
  if (!result.canceled) {
    console.log('Selected files:', result.filePaths)
  }
})
```

Passing a `BrowserWindow` reference makes the dialog modal and attached to that window.[5][4]

### File Filters

The `filters` option restricts file types displayed in the dialog.[6][4][1]

```javascript
dialog.showOpenDialog({
  filters: [
    { name: 'Images', extensions: ['jpg', 'png', 'gif'] },
    { name: 'Movies', extensions: ['mkv', 'avi', 'mp4'] },
    { name: 'Documents', extensions: ['pdf', 'doc', 'docx'] },
    { name: 'All Files', extensions: ['*'] }
  ],
  properties: ['openFile']
})
```

Extensions should be specified **without wildcards or dots** - use `'png'` instead of `'*.png'` or `'.png'`. The `All Files` filter with `['*']` allows selecting any file type.[3][4][6]

**Adding Filters Dynamically**
```javascript
const dialogOptions = {
  defaultPath: 'c:/',
  filters: [
    { name: 'All Files', extensions: ['*'] },
    { name: 'Images', extensions: ['jpg', 'png', 'gif'] }
  ],
  properties: ['openFile']
}

// Check if filter already exists before adding
const customFilter = dialogOptions.filters.find(item => item.name === 'Custom')

if (!customFilter) {
  dialogOptions.filters.push({
    name: 'Custom',
    extensions: ['custom', 'ext']
  })
}

dialog.showOpenDialog(dialogOptions)
```

Electron doesn't check for duplicate filters, so manual verification is needed.[3]

### Dialog Properties

The `properties` array controls dialog behavior.[4][5][1]

```javascript
dialog.showOpenDialog({
  properties: [
    'openFile',          // Allow file selection
    'openDirectory',     // Allow directory selection
    'multiSelections',   // Allow multiple selections
    'showHiddenFiles',   // Show hidden files
    'createDirectory',   // macOS: Allow creating directories
    'promptToCreate',    // Windows: Prompt if path doesn't exist
    'noResolveAliases',  // macOS: Disable alias resolution
    'treatPackageAsDirectory' // macOS: Treat packages as directories
  ]
})
```

**Platform Limitation**: On Windows and Linux, a dialog cannot be both a file selector and directory selector simultaneously. Setting `['openFile', 'openDirectory']` will show a directory selector on these platforms.[5][1][4]

### Saving Files with showSaveDialog()

The `showSaveDialog()` method displays the native save dialog.[7][4]

**Promise-Based**
```javascript
const { dialog } = require('electron')

dialog.showSaveDialog({
  title: 'Save File',
  defaultPath: 'untitled.txt',
  buttonLabel: 'Save',
  filters: [
    { name: 'Text Files', extensions: ['txt'] },
    { name: 'All Files', extensions: ['*'] }
  ]
}).then(result => {
  console.log('Cancelled:', result.canceled)
  console.log('File path:', result.filePath)
  
  if (!result.canceled && result.filePath) {
    // Write file using fs module
    fs.writeFileSync(result.filePath, 'File content')
  }
}).catch(err => {
  console.error('Dialog error:', err)
})
```

The method returns a Promise resolving to an object with `canceled` (boolean) and `filePath` (string) properties.[7][4]

**Synchronous Version**
```javascript
const filePath = dialog.showSaveDialogSync({
  title: 'Save File',
  defaultPath: 'document.pdf',
  filters: [
    { name: 'PDF Files', extensions: ['pdf'] },
    { name: 'All Files', extensions: ['*'] }
  ]
})

if (filePath) {
  console.log('Save to:', filePath)
  // File writing logic
}
```

Returns a string containing the chosen path, or `undefined` if cancelled.[4]

### IPC Integration for Renderer Process

File dialogs run in the Main process, requiring IPC for renderer access.[2][3]

**Main Process**
```javascript
const { ipcMain, dialog } = require('electron')

ipcMain.handle('show-open-dialog', async (event, options) => {
  const result = await dialog.showOpenDialog(options)
  return result
})

ipcMain.handle('show-save-dialog', async (event, options) => {
  const result = await dialog.showSaveDialog(options)
  return result
})
```

**Preload Script**
```javascript
const { contextBridge, ipcRenderer } = require('electron')

contextBridge.exposeInMainWorld('fileDialog', {
  showOpenDialog: (options) => ipcRenderer.invoke('show-open-dialog', options),
  showSaveDialog: (options) => ipcRenderer.invoke('show-save-dialog', options)
})
```

**Renderer Process**
```javascript
// Open file dialog
const openOptions = {
  properties: ['openFile', 'multiSelections'],
  filters: [
    { name: 'Images', extensions: ['jpg', 'png', 'gif'] },
    { name: 'All Files', extensions: ['*'] }
  ]
}

window.fileDialog.showOpenDialog(openOptions).then(result => {
  if (!result.canceled) {
    console.log('Selected files:', result.filePaths)
  }
})

// Save file dialog
const saveOptions = {
  defaultPath: 'document.txt',
  filters: [
    { name: 'Text Files', extensions: ['txt'] },
    { name: 'All Files', extensions: ['*'] }
  ]
}

window.fileDialog.showSaveDialog(saveOptions).then(result => {
  if (!result.canceled) {
    console.log('Save path:', result.filePath)
  }
})
```

This pattern maintains context isolation while enabling dialog access.[2]

### Complete File Operation Example

Combining dialogs with file system operations.[3][7]

**Main Process**
```javascript
const { app, ipcMain, dialog } = require('electron')
const fs = require('fs').promises

ipcMain.handle('open-file', async () => {
  const result = await dialog.showOpenDialog({
    properties: ['openFile'],
    filters: [
      { name: 'Text Files', extensions: ['txt'] },
      { name: 'All Files', extensions: ['*'] }
    ]
  })
  
  if (result.canceled) {
    return { canceled: true }
  }
  
  try {
    const content = await fs.readFile(result.filePaths[0], 'utf8')
    return { 
      canceled: false, 
      filePath: result.filePaths[0],
      content: content 
    }
  } catch (err) {
    return { canceled: false, error: err.message }
  }
})

ipcMain.handle('save-file', async (event, content) => {
  const result = await dialog.showSaveDialog({
    defaultPath: 'untitled.txt',
    filters: [
      { name: 'Text Files', extensions: ['txt'] },
      { name: 'All Files', extensions: ['*'] }
    ]
  })
  
  if (result.canceled) {
    return { canceled: true }
  }
  
  try {
    await fs.writeFile(result.filePath, content, 'utf8')
    return { 
      canceled: false, 
      filePath: result.filePath 
    }
  } catch (err) {
    return { canceled: false, error: err.message }
  }
})
```

**Preload Script**
```javascript
const { contextBridge, ipcRenderer } = require('electron')

contextBridge.exposeInMainWorld('fileOps', {
  openFile: () => ipcRenderer.invoke('open-file'),
  saveFile: (content) => ipcRenderer.invoke('save-file', content)
})
```

**Renderer Process**
```javascript
// Open and read file
document.getElementById('open-btn').onclick = async () => {
  const result = await window.fileOps.openFile()
  
  if (!result.canceled && !result.error) {
    document.getElementById('editor').value = result.content
    console.log('Opened:', result.filePath)
  } else if (result.error) {
    alert('Error opening file: ' + result.error)
  }
}

// Save file
document.getElementById('save-btn').onclick = async () => {
  const content = document.getElementById('editor').value
  const result = await window.fileOps.saveFile(content)
  
  if (!result.canceled && !result.error) {
    console.log('Saved to:', result.filePath)
  } else if (result.error) {
    alert('Error saving file: ' + result.error)
  }
}
```

### Additional Dialog Options

Both `showOpenDialog()` and `showSaveDialog()` support additional options.[5][4]

```javascript
dialog.showOpenDialog({
  title: 'Custom Dialog Title',
  defaultPath: app.getPath('documents'),
  buttonLabel: 'Choose This',
  message: 'Select files to import', // macOS only
  securityScopedBookmarks: true,     // macOS MAS only
  properties: ['openFile', 'multiSelections']
})
```

The `message` option displays additional text on macOS dialogs. The `securityScopedBookmarks` option is required for Mac App Store sandboxed applications.[4]

Sources
[1] dialog https://electronjs.org/docs/latest/api/dialog
[2] What's the best way to open a file dialog in a React/ ... https://www.reddit.com/r/electronjs/comments/s85pic/whats_the_best_way_to_open_a_file_dialog_in_a/
[3] Filter by extension in Electron file dialog - javascript - Stack Overflow https://stackoverflow.com/questions/48453065/filter-by-extension-in-electron-file-dialog
[4] dialog https://www.electronjs.org/docs/latest/api/dialog
[5] How to select folder or files using electron dialog? https://stackoverflow.com/questions/57867302/how-to-select-folder-or-files-using-electron-dialog
[6] dialog · Electron documentation https://tinydew4.gitbooks.io/electron/api/dialog.html
[7] Electron.NET: Save Dialog & File Writing | by Eric Anderson | ITNEXT https://itnext.io/electron-net-save-dialog-file-writing-6afa20d76c96
[8] dialog.showOpenDialog with openDirectory property ... https://github.com/electron/electron/issues/48217
[9] How to Use Dialog Windows to Save and Open Files ... https://www.youtube.com/watch?v=ItOyqhpp4K0
[10] Dialog · ElectronNET/Electron.NET Wiki - GitHub https://github.com/ElectronNET/Electron.NET/wiki/Dialog
[11] How can I display a Save As dialog in an Electron App? https://stackoverflow.com/questions/32979630/how-can-i-display-a-save-as-dialog-in-an-electron-app

---

