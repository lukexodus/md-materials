## Watching File System Changes


Node.js provides built-in methods for monitoring file and directory changes through the `fs` module. Electron applications can leverage these capabilities or use third-party libraries like `chokidar` for more robust file watching.[1][2]

### fs.watch() Method

The `fs.watch()` method monitors files or directories for changes using native OS capabilities.[3][1]

**Basic Usage**
```javascript
const fs = require('fs')

fs.watch('example.txt', (eventType, filename) => {
  console.log(`Event type: ${eventType}`)
  console.log(`File changed: ${filename}`)
})
```

The callback receives two parameters: `eventType` (either `'rename'` or `'change'`) and `filename` (the name of the file that triggered the event).[1][3]

**Watching Directories**
```javascript
const fs = require('fs')

fs.watch('./my-folder', (eventType, filename) => {
  if (filename) {
    console.log(`${filename} was modified`)
    console.log(`Event type: ${eventType}`)
  }
})
```

The method can watch both files and directories. When watching directories, the `filename` argument indicates which file in the directory changed.[4][3][1]

**With Options**
```javascript
const fs = require('fs')

const watcher = fs.watch('./my-folder', {
  persistent: true,     // Keep process running while watching
  recursive: true,      // Watch subdirectories (macOS/Windows only)
  encoding: 'utf8'      // Character encoding for filename
}, (eventType, filename) => {
  console.log(`${eventType} event on ${filename}`)
})

// Stop watching
watcher.close()
```

The `recursive` option enables watching of subdirectories but is only supported on macOS and Windows.[5][4]

### fs.watchFile() Method

The `fs.watchFile()` method polls files at regular intervals for changes.[4][1]

**Basic Usage**
```javascript
const fs = require('fs')

fs.watchFile('example.txt', (curr, prev) => {
  console.log('Current mtime:', curr.mtime)
  console.log('Previous mtime:', prev.mtime)
  
  if (curr.mtime !== prev.mtime) {
    console.log('File was modified')
  }
})
```

The callback receives two `fs.Stats` objects: current stats and previous stats.[4]

**With Options**
```javascript
const fs = require('fs')

fs.watchFile('example.txt', {
  persistent: true,    // Keep process running
  interval: 5000       // Poll every 5 seconds (default: 5007ms)
}, (curr, prev) => {
  console.log('File changed')
})

// Stop watching
fs.unwatchFile('example.txt')
```

The `interval` option specifies polling frequency in milliseconds.[5][4]

### fs.watch() vs fs.watchFile()

The methods have important differences that affect performance and compatibility.[3][5][4]

| Feature | fs.watch() | fs.watchFile() |
|---------|------------|----------------|
| Performance | Efficient (uses OS events) | Less efficient (constant polling) [4] |
| CPU Usage | Low | Higher due to polling [5] |
| Platform Support | Not all platforms (unstable on some) | Works everywhere [5] |
| Can Watch | Files and directories | Files only [1] |
| Recursive | Yes (macOS/Windows) | No [4] |
| Recommendation | Preferred when supported [4] | Use only if fs.watch() unavailable [3] |

The Node.js documentation recommends using `fs.watch()` instead of `fs.watchFile()` when possible due to better efficiency.[3][4]

### Known fs.watch() Issues

The native `fs.watch()` has several platform-specific limitations.[2]

**Common Problems**
- Doesn't report filenames on macOS in some cases[2]
- Doesn't report events when using certain editors like Sublime on macOS[2]
- Often reports events twice[2]
- Emits most changes as `'rename'` events[2]
- Not all platforms support recursive watching[4]

These issues make third-party solutions more reliable for production applications.[2]

### Using Chokidar Library

Chokidar provides a more robust file watching solution that resolves native `fs.watch()` limitations.[6][2]

**Installation**
```bash
npm install chokidar --save
```

**Basic Usage**
```javascript
const chokidar = require('chokidar')

const watcher = chokidar.watch('./my-folder', {
  ignored: /(^|[\/\\])\../, // Ignore dotfiles
  persistent: true
})

watcher
  .on('add', path => console.log(`File ${path} has been added`))
  .on('change', path => console.log(`File ${path} has been changed`))
  .on('unlink', path => console.log(`File ${path} has been removed`))
  .on('addDir', path => console.log(`Directory ${path} has been added`))
  .on('unlinkDir', path => console.log(`Directory ${path} has been removed`))
  .on('error', error => console.error(`Watcher error: ${error}`))
  .on('ready', () => console.log('Initial scan complete. Ready for changes'))
```

Chokidar provides granular events for different change types [].

**Waiting for Initial Scan**
```javascript
function startWatcher(path) {
  const chokidar = require('chokidar')
  
  const watcher = chokidar.watch(path, {
    ignored: /[\/\\]\./,
    persistent: true
  })
  
  watcher.on('ready', () => {
    console.log('Initial scan complete. Now watching for changes.')
    
    // Only watch for real changes after initial scan
    watcher
      .on('add', path => console.log(`File added: ${path}`))
      .on('change', path => console.log(`File changed: ${path}`))
      .on('unlink', path => console.log(`File removed: ${path}`))
  })
  
  return watcher
}

const watcher = startWatcher('./data')

// Stop watching
watcher.close()
```

The `ready` event fires when the initial scan completes, allowing you to distinguish between existing files and new additions.[2]

### Electron Integration

File watching in Electron typically runs in the Main process with IPC communication to renderers.[6]

**Main Process**
```javascript
const { app, ipcMain } = require('electron')
const chokidar = require('chokidar')

let watcher = null

ipcMain.on('start-watching', (event, folderPath) => {
  if (watcher) {
    watcher.close()
  }
  
  watcher = chokidar.watch(folderPath, {
    ignored: /(^|[\/\\])\../,
    persistent: true
  })
  
  watcher
    .on('add', path => {
      event.sender.send('file-added', path)
    })
    .on('change', path => {
      event.sender.send('file-changed', path)
    })
    .on('unlink', path => {
      event.sender.send('file-removed', path)
    })
    .on('error', error => {
      event.sender.send('watcher-error', error.message)
    })
})

ipcMain.on('stop-watching', () => {
  if (watcher) {
    watcher.close()
    watcher = null
  }
})

app.on('quit', () => {
  if (watcher) {
    watcher.close()
  }
})
```

**Preload Script**
```javascript
const { contextBridge, ipcRenderer } = require('electron')

contextBridge.exposeInMainWorld('fileWatcher', {
  startWatching: (path) => ipcRenderer.send('start-watching', path),
  stopWatching: () => ipcRenderer.send('stop-watching'),
  onFileAdded: (callback) => ipcRenderer.on('file-added', (event, path) => callback(path)),
  onFileChanged: (callback) => ipcRenderer.on('file-changed', (event, path) => callback(path)),
  onFileRemoved: (callback) => ipcRenderer.on('file-removed', (event, path) => callback(path)),
  onError: (callback) => ipcRenderer.on('watcher-error', (event, error) => callback(error))
})
```

**Renderer Process**
```javascript
// Start watching a folder
window.fileWatcher.startWatching('/path/to/watch')

// Listen for file events
window.fileWatcher.onFileAdded((path) => {
  console.log('New file:', path)
})

window.fileWatcher.onFileChanged((path) => {
  console.log('File changed:', path)
})

window.fileWatcher.onFileRemoved((path) => {
  console.log('File removed:', path)
})

window.fileWatcher.onError((error) => {
  console.error('Watcher error:', error)
})

// Stop watching
window.fileWatcher.stopWatching()
```

This pattern ensures file watching runs in the Main process while keeping renderers informed of changes [].

### Filtering Event Types

Handle specific event types to avoid processing unwanted changes [].

```javascript
const fs = require('fs')

fs.watch('example.txt', (eventType, filename) => {
  if (eventType === 'change') {
    console.log('File content was modified')
  } else if (eventType === 'rename') {
    console.log('File was renamed or deleted')
  }
})
```

The `eventType` can be `'change'` (file contents modified) or `'rename'` (file renamed/created/deleted) [].

Sources
[1] How to monitor a file for modifications in Node.js ? https://www.geeksforgeeks.org/node-js/how-to-monitor-a-file-for-modifications-in-node-js/
[2] Watch Files and Directories with Electron Framework | Our Code World https://ourcodeworld.com/articles/read/160/watch-files-and-directories-with-electron-framework
[3] How to Watch for File Changes in Node.js | thisDaveJ https://thisdavej.com/how-to-watch-for-file-changes-in-node-js/
[4] Understanding fs.watch() and fs.watchFile() in Node.js - Byte Box https://bhung6494.wordpress.com/2018/09/13/understanding-fs-watch-and-fs-watchfile-in-node-js/
[5] Difference between fs.watch() and fs.watchFile() - TECH-NI Blog https://tech.nitoyon.com/en/blog/2013/10/02/node-watch-impl/
[6] How to watch files in Electron App? - node.js - Stack Overflow https://stackoverflow.com/questions/30787590/how-to-watch-files-in-electron-app
[7] Observe file changes with node.js - Stack Overflow https://stackoverflow.com/questions/13698043/observe-file-changes-with-node-js
[8] fs.watchFile - Node.js https://nodejs.org/docs/latest/api/fs.html
[9] File system | Node.js v25.3.0 Documentation https://nodejs.org/api/fs.html
[10] How to Watch File Changes in Node.js - YouTube https://www.youtube.com/watch?v=YSkryJrMvOQ

---

