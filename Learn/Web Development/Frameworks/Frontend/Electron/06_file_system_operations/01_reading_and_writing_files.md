## Reading and Writing Files


Electron applications can read and write files using Node.js's built-in `fs` (File System) module. The `fs` module is available in both Main and Renderer processes, though modern Electron requires careful handling in sandboxed renderers.[1][2][3]

### Reading Files

The `fs` module provides both synchronous and asynchronous methods for reading files. Asynchronous operations are recommended to avoid blocking the UI thread.[3][1]

**Asynchronous Reading (Callback)**
```javascript
const fs = require('fs')

fs.readFile('path/to/file.txt', 'utf8', (err, data) => {
  if (err) {
    console.error('Error reading file:', err)
    return
  }
  console.log('File content:', data)
})
```

The encoding parameter (`'utf8'`) interprets the file as text. Omitting it returns a Buffer object for binary data.[4][1]

**Promise-Based Reading**
```javascript
const fs = require('fs').promises

async function readFileAsync() {
  try {
    const data = await fs.readFile('path/to/file.txt', 'utf8')
    console.log('File content:', data)
  } catch (err) {
    console.error('Error reading file:', err)
  }
}

readFileAsync()
```

The `fs.promises` API provides modern async/await syntax.[5]

**Synchronous Reading**
```javascript
const fs = require('fs')

try {
  const data = fs.readFileSync('path/to/file.txt', 'utf8')
  console.log(data)
} catch (err) {
  console.error('Error reading file:', err)
}
```

Synchronous methods block execution until complete and should be used sparingly.[1][4]

### Writing Files

The `fs.writeFile()` method creates new files or overwrites existing ones.[6][1]

**Asynchronous Writing (Callback)**
```javascript
const fs = require('fs')

const content = 'This is the content I want to save.'

fs.writeFile('path/to/output.txt', content, 'utf8', (err) => {
  if (err) {
    console.error('Error writing file:', err)
    return
  }
  console.log('File has been written successfully!')
})
```

The encoding parameter defaults to `'utf8'` for text files.[6][1]

**Promise-Based Writing**
```javascript
const fs = require('fs').promises

async function writeFileAsync() {
  try {
    await fs.writeFile('path/to/output.txt', 'Hello, World!', 'utf8')
    console.log('File written successfully')
  } catch (err) {
    console.error('Error writing file:', err)
  }
}

writeFileAsync()
```

**Synchronous Writing**
```javascript
const fs = require('fs')

try {
  fs.writeFileSync('path/to/output.txt', 'Data to write', 'utf8')
  console.log('File written')
} catch (err) {
  console.error('Error writing file:', err)
}
```

### Appending to Files

Use `fs.appendFile()` to add content without overwriting existing data.[4]

```javascript
const fs = require('fs')

fs.appendFile('path/to/file.txt', '\nNew line of text', 'utf8', (err) => {
  if (err) {
    console.error('Error appending to file:', err)
    return
  }
  console.log('Content appended successfully')
})
```

This adds data to the end of the file or creates a new file if it doesn't exist.[4]

### Working with JSON Files

JSON files are commonly used for configuration and data storage.[7][6]

**Reading JSON**
```javascript
const fs = require('fs')

fs.readFile('./config.json', 'utf8', (err, data) => {
  if (err) {
    console.error('Error reading JSON:', err)
    return
  }
  
  const jsonData = JSON.parse(data)
  console.log(jsonData)
})
```

**Writing JSON**
```javascript
const fs = require('fs')

const dataToSave = {
  name: 'My App',
  version: '1.0.0',
  settings: { theme: 'dark' }
}

const jsonString = JSON.stringify(dataToSave, null, 2)

fs.writeFile('./config.json', jsonString, 'utf8', (err) => {
  if (err) {
    console.error('Error writing JSON:', err)
    return
  }
  console.log('JSON file saved')
})
```

The `JSON.stringify()` second parameter is a replacer function (null means no filtering), and the third parameter controls indentation for readability.[7][6]

### Reading Binary Files

Binary files like images require omitting the encoding parameter.[7]

```javascript
const fs = require('fs')

fs.readFile('path/to/image.jpg', (err, data) => {
  if (err) {
    console.error('Error reading image:', err)
    return
  }
  
  // data is a Buffer object containing raw binary data
  console.log('Image size:', data.length, 'bytes')
  
  // Can be converted to base64 for embedding
  const base64 = data.toString('base64')
})
```

### File Paths

Use the `path` module to construct cross-platform file paths.[8][6]

```javascript
const path = require('path')
const fs = require('fs')

// Join path segments
const filePath = path.join(__dirname, 'data', 'config.json')

// Get app data directory (user-specific storage)
const { app } = require('electron')
const userDataPath = app.getPath('userData')
const configPath = path.join(userDataPath, 'settings.json')

fs.writeFile(configPath, '{}', (err) => {
  if (err) console.error(err)
})
```

The `path.join()` method handles platform-specific separators automatically.[8]

### Using fs in Renderer Process (Modern Electron)

In Electron v20+, renderer processes are sandboxed by default and cannot directly access Node.js modules. File operations must go through IPC communication.[2]

**Main Process**
```javascript
const { ipcMain } = require('electron')
const fs = require('fs').promises

ipcMain.handle('read-file', async (event, filePath) => {
  try {
    const data = await fs.readFile(filePath, 'utf8')
    return { success: true, data }
  } catch (err) {
    return { success: false, error: err.message }
  }
})

ipcMain.handle('write-file', async (event, filePath, content) => {
  try {
    await fs.writeFile(filePath, content, 'utf8')
    return { success: true }
  } catch (err) {
    return { success: false, error: err.message }
  }
})
```

**Preload Script**
```javascript
const { contextBridge, ipcRenderer } = require('electron')

contextBridge.exposeInMainWorld('fileSystem', {
  readFile: (filePath) => ipcRenderer.invoke('read-file', filePath),
  writeFile: (filePath, content) => ipcRenderer.invoke('write-file', filePath, content)
})
```

**Renderer Process**
```javascript
// Read file
window.fileSystem.readFile('/path/to/file.txt').then(result => {
  if (result.success) {
    console.log('File content:', result.data)
  } else {
    console.error('Error:', result.error)
  }
})

// Write file
window.fileSystem.writeFile('/path/to/file.txt', 'New content').then(result => {
  if (result.success) {
    console.log('File written successfully')
  } else {
    console.error('Error:', result.error)
  }
})
```

This approach maintains security while allowing controlled file system access.[2]

### Packaged Application Considerations

When packaging Electron apps with tools like electron-builder, include necessary files in the build configuration.[6]

**package.json**
```json
{
  "build": {
    "files": [
      "dist/**/*",
      "file.json"
    ]
  }
}
```

This ensures files are copied into the packaged application. Use `app.getPath('userData')` for user-specific files that should persist outside the installation directory.[8][6]

Sources
[1] Reading and Writing Files in Your Electron App | Chapter 5 https://seino-prince.com/book/2b3b4ab5-d136-81fb-8232-c0df9dc6329f/chapter/2b3b4ab5-d136-8177-b4be-ff54485dad44/section/2b3b4ab5-d136-81d4-9367-c84d0ad04bbe
[2] Electron: Executing Main Process Code from Renderer https://ncoughlin.com/posts/electron-executing-main-process-code-from-renderer
[3] Distinction between the renderer and main processes in Electron https://stackoverflow.com/questions/37669727/distinction-between-the-renderer-and-main-processes-in-electron
[4] How to Read and Write Files Using the fs Module in Node Js https://www.almabetter.com/bytes/tutorials/nodejs/fs-module-in-nodejs
[5] File system | Node.js v25.3.0 Documentation https://nodejs.org/api/fs.html
[6] Electron package - how to write/read files https://stackoverflow.com/questions/46027816/electron-package-how-to-write-read-files
[7] Accessing Local Files In Electron App : r/node https://www.reddit.com/r/node/comments/1bneas0/accessing_local_files_in_electron_app/
[8] Reading & Writing Files in Electron JS - Electron Tutorial https://www.youtube.com/watch?v=1rDvNDvZrnA
[9] Meteor + Electron - filesystem (fs) - help https://forums.meteor.com/t/meteor-electron-filesystem-fs/26262
[10] How to use writeFile and readFile together in node js https://stackoverflow.com/questions/46621069/how-to-use-writefile-and-readfile-together-in-node-js/46621124

---

