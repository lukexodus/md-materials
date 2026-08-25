## Shell Module for External Resources


The shell module provides functions for desktop integration, allowing interaction with files and URLs using default applications. It runs in both Main and Renderer processes (non-sandboxed only).[1][2]

### Opening External URLs

The `openExternal()` method opens URLs in the system's default application.[2][1]

```javascript
const { shell } = require('electron')

shell.openExternal('https://github.com')
```

This opens URLs in the default browser for HTTP/HTTPS, or in the appropriate application for protocol handlers like `mailto:`, `tel:`, or custom schemes. Windows URLs are limited to 2081 characters.[3][2]

**With Options**
```javascript
shell.openExternal('https://example.com', {
  activate: true,
  workingDirectory: '/path/to/dir'
}).then(() => {
  console.log('URL opened successfully')
}).catch(err => {
  console.error('Failed to open URL:', err)
})
```

The method returns a `Promise<void>` that resolves when the operation completes. The `activate` option (macOS) determines whether to bring the opened application to the foreground.[2][3]

### Opening Local Files and Folders

The `openPath()` method opens files or folders with the default system application.[1][2]

```javascript
const { shell } = require('electron')

// Open a file with its default application
shell.openPath('/path/to/document.pdf').then((error) => {
  if (error) {
    console.error('Failed to open path:', error)
  }
})

// Open a folder in file explorer
shell.openPath('/path/to/folder')
```

This replaces the deprecated `openItem()` method and returns a `Promise<string>` that resolves with an error message if the operation fails, or an empty string on success.[4][5][2]

### Showing Items in File Manager

The `showItemInFolder()` method reveals a file in its containing folder and selects it if possible.[5][2]

```javascript
const { shell } = require('electron')

shell.showItemInFolder('/path/to/file.txt')
```

This opens the file manager (Explorer on Windows, Finder on macOS, file manager on Linux) and highlights the specified file. On Linux, the implementation uses XDGOpen to show the parent directory.[6][7][5]

### Moving Items to Trash

The `trashItem()` method moves files or folders to the OS-specific trash location.[3][2]

```javascript
const { shell } = require('electron')

shell.trashItem('/path/to/file').then(() => {
  console.log('Item moved to trash')
}).catch(err => {
  console.error('Failed to trash item:', err)
})
```

This returns a `Promise<void>` that rejects if an error occurs. The destination varies by platform: Trash on macOS, Recycle Bin on Windows, and desktop-environment-specific locations on Linux.[2][3]

### Playing System Beep

The `beep()` method plays the system's default beep sound.[7][8]

```javascript
const { shell } = require('electron')

shell.beep()
```

This provides audio feedback using the native system sound.[8][7]

### Windows Shortcut Management

Windows-specific methods create and manage desktop shortcuts.[2]

**Writing Shortcuts**
```javascript
const { shell } = require('electron')

shell.writeShortcutLink('C:\\Users\\Username\\Desktop\\MyApp.lnk', {
  target: 'C:\\path\\to\\app.exe',
  cwd: 'C:\\path\\to',
  args: '--flag',
  description: 'My Application',
  icon: 'C:\\path\\to\\icon.ico',
  iconIndex: 0,
  appUserModelId: 'com.mycompany.myapp'
})
```

The optional `operation` parameter can be `'create'`, `'update'`, or `'replace'` (defaults to `'create'`).[7][2]

**Reading Shortcuts**
```javascript
const shortcutDetails = shell.readShortcutLink('C:\\Users\\Username\\Desktop\\MyApp.lnk')

console.log(shortcutDetails.target)
console.log(shortcutDetails.args)
```

Returns an object containing shortcut properties including `target`, `cwd`, `args`, `description`, `icon`, `iconIndex`, and `appUserModelId`.[2]

### Security Considerations

Shell methods can be exploited if user-controlled input is passed without validation.[9][6]

**Unsafe Usage**
```javascript
// VULNERABLE: User input passed directly
shell.openExternal(userProvidedURL)
```

This allows attackers to inject malicious URLs with dangerous protocols like `javascript:` or `file:`.[6][9]

**Safe Usage with Allowlist**
```javascript
function openExternalSafely(url) {
  try {
    const parsed = new URL(url)
    
    // Allowlist safe protocols
    if (!['http:', 'https:'].includes(parsed.protocol)) {
      console.error('Blocked unsafe protocol:', parsed.protocol)
      return
    }
    
    shell.openExternal(url)
  } catch (err) {
    console.error('Invalid URL:', err)
  }
}

openExternalSafely(userProvidedURL)
```

Always validate and sanitize URLs before passing them to `openExternal()` or `openPath()`.[9][6]

### Usage in Renderer Process

When using the shell module in sandboxed renderer processes, expose methods through the preload script.[10]

**Main Process**
```javascript
const { ipcMain, shell } = require('electron')

ipcMain.handle('showItemInFolder', (event, fullPath) => {
  shell.showItemInFolder(fullPath)
})

ipcMain.handle('openPath', (event, path) => {
  return shell.openPath(path)
})
```

**Preload Script**
```javascript
const { contextBridge, ipcRenderer } = require('electron')

contextBridge.exposeInMainWorld('electronAPI', {
  showItemInFolder: (fullPath) => ipcRenderer.invoke('showItemInFolder', fullPath),
  openPath: (path) => ipcRenderer.invoke('openPath', path)
})
```

**Renderer Process**
```javascript
window.electronAPI.showItemInFolder('/path/to/file')
window.electronAPI.openPath('/path/to/folder')
```

This approach ensures secure IPC communication between processes while maintaining shell functionality.[10]

Sources
[1] shell - Electron https://www.electronjs.org/docs/latest/api/shell
[2] Menu | Electron https://electronjs.org/docs/latest/api/menu
[3] shell https://electronjs.org/docs/latest/api/shell
[4] javascript - Open external application with electron https://stackoverflow.com/questions/74814215/open-external-application-with-electron
[5] Electron open file/directory in specific application https://stackoverflow.com/questions/43991267/electron-open-file-directory-in-specific-application
[6] Electron APIs Misuse: An Attacker's First Choice https://blog.doyensec.com/2021/02/16/electron-apis-misuse.html
[7] shell | Electron https://zeke.github.io/electron.atom.io/docs/api/shell/
[8] shell | FAQ https://imfly.github.io/electron-docs-gitbook/en/api/shell.html
[9] Penetration Testing of Electron-based Applications https://deepstrike.io/blog/penetration-testing-of-electron-based-applications
[10] [Bug]: shell.openPath open windows explorer in the ... https://github.com/electron/electron/issues/36765
[11] shell.showItemInFolder in MAC OS opens Finder very slow https://github.com/electron/electron/issues/17835


---

