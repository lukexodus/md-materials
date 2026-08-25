## Directory Operations


Electron applications can perform directory operations using Node.js's `fs` module, with support for both synchronous and asynchronous methods. Modern Node.js provides promise-based alternatives through `fs.promises` for cleaner async code.[1][2]

### Creating Directories

The `fs.mkdir()` method creates new directories with optional recursive capabilities.[2][3]

**Asynchronous Creation (Callback)**
```javascript
const fs = require('fs')

fs.mkdir('./new-directory', (err) => {
  if (err) {
    console.error('Error creating directory:', err)
    return
  }
  console.log('Directory created successfully')
})
```

**Promise-Based Creation**
```javascript
const fs = require('fs').promises

async function createDirectory() {
  try {
    await fs.mkdir('./new-directory')
    console.log('Directory created successfully')
  } catch (err) {
    console.error('Error creating directory:', err)
  }
}

createDirectory()
```

**Synchronous Creation**
```javascript
const fs = require('fs')

try {
  fs.mkdirSync('./new-directory')
  console.log('Directory created successfully')
} catch (err) {
  console.error('Error creating directory:', err)
}
```

### Recursive Directory Creation

The `recursive` option creates parent directories automatically if they don't exist.[1][2]

```javascript
const fs = require('fs').promises

async function createNestedDirectories() {
  try {
    // Creates project/, project/data/, and project/data/logs/
    await fs.mkdir('./project/data/logs', { recursive: true })
    console.log('Nested directories created successfully')
  } catch (err) {
    console.error('Error creating directories:', err)
  }
}

createNestedDirectories()
```

Without the `recursive` option, attempting to create nested paths fails if parent directories don't exist. Setting `recursive: true` prevents errors when directories already exist.[2][1]

### Reading Directory Contents

The `fs.readdir()` method retrieves an array of filenames in a directory.[4][5]

**Asynchronous Reading (Callback)**
```javascript
const fs = require('fs')

fs.readdir('./my-directory', (err, files) => {
  if (err) {
    console.error('Error reading directory:', err)
    return
  }
  console.log('Directory contents:', files)
  files.forEach(file => {
    console.log(file)
  })
})
```

**Promise-Based Reading**
```javascript
const fs = require('fs').promises

async function readDirectory() {
  try {
    const files = await fs.readdir('./my-directory')
    console.log('Files:', files)
  } catch (err) {
    console.error('Error reading directory:', err)
  }
}

readDirectory()
```

**Synchronous Reading**
```javascript
const fs = require('fs')

try {
  const files = fs.readdirSync('./my-directory')
  console.log('Files:', files)
} catch (err) {
  console.error('Error reading directory:', err)
}
```

### Getting File Type Information

The `withFileTypes` option returns `Dirent` objects with file type information.[5][4]

```javascript
const fs = require('fs').promises

async function listDirectoryContents() {
  try {
    const entries = await fs.readdir('./my-directory', { withFileTypes: true })
    
    entries.forEach(entry => {
      if (entry.isDirectory()) {
        console.log(`[DIR]  ${entry.name}`)
      } else if (entry.isFile()) {
        console.log(`[FILE] ${entry.name}`)
      }
    })
  } catch (err) {
    console.error('Error reading directory:', err)
  }
}

listDirectoryContents()
```

The `Dirent` object provides methods like `isFile()`, `isDirectory()`, `isSymbolicLink()`, `isBlockDevice()`, `isCharacterDevice()`, `isFIFO()`, and `isSocket()`.[4]

### Recursive Directory Reading

Reading directories recursively requires manual implementation.[6]

```javascript
const fs = require('fs').promises
const path = require('path')

async function readDirRecursive(dirPath) {
  const entries = await fs.readdir(dirPath, { withFileTypes: true })
  const files = []
  
  for (const entry of entries) {
    const fullPath = path.join(dirPath, entry.name)
    
    if (entry.isDirectory()) {
      const subFiles = await readDirRecursive(fullPath)
      files.push(...subFiles)
    } else {
      files.push(fullPath)
    }
  }
  
  return files
}

// Usage
readDirRecursive('./project').then(files => {
  console.log('All files:', files)
}).catch(err => {
  console.error('Error:', err)
})
```

This traverses all subdirectories and returns an array of all file paths.[6]

### Deleting Directories

The `fs.rm()` method removes directories and their contents.[7]

**Deleting Non-Empty Directories**
```javascript
const fs = require('fs').promises

async function deleteDirectory() {
  try {
    await fs.rm('./temp-folder', { recursive: true, force: true })
    console.log('Directory deleted successfully')
  } catch (err) {
    console.error('Error deleting directory:', err)
  }
}

deleteDirectory()
```

The `recursive: true` option enables deletion of non-empty directories, while `force: true` prevents errors if the directory doesn't exist. This method replaces the deprecated `fs.rmdir()`.[7]

**Callback-Based Deletion**
```javascript
const fs = require('fs')

fs.rm('./temp-folder', { recursive: true, force: true }, (err) => {
  if (err) {
    console.error('Error deleting directory:', err)
    return
  }
  console.log('Directory deleted successfully')
})
```

**Synchronous Deletion**
```javascript
const fs = require('fs')

try {
  fs.rmSync('./temp-folder', { recursive: true, force: true })
  console.log('Directory deleted successfully')
} catch (err) {
  console.error('Error deleting directory:', err)
}
```

### Deleting Empty Directories

For empty directories, use `fs.rmdir()` (still supported for empty directories) or `fs.rm()` without recursive.[1]

```javascript
const fs = require('fs').promises

async function deleteEmptyDirectory() {
  try {
    await fs.rmdir('./empty-folder')
    console.log('Empty directory deleted')
  } catch (err) {
    console.error('Error deleting directory:', err)
  }
}

deleteEmptyDirectory()
```

### Checking Directory Existence

Use `fs.stat()` or `fs.access()` to verify directory existence.[2][1]

```javascript
const fs = require('fs').promises

async function directoryExists(path) {
  try {
    const stats = await fs.stat(path)
    return stats.isDirectory()
  } catch (err) {
    return false
  }
}

// Usage
const exists = await directoryExists('./my-directory')
console.log('Directory exists:', exists)
```

**Alternative with fs.access()**
```javascript
const fs = require('fs').promises

async function checkDirectory(path) {
  try {
    await fs.access(path)
    const stats = await fs.stat(path)
    return stats.isDirectory()
  } catch (err) {
    return false
  }
}
```

### Creating Directories with Error Handling

Comprehensive error handling ensures directories are created only when needed.[2]

```javascript
const fs = require('fs').promises

async function ensureDirectory(dirPath) {
  try {
    // Try to read directory stats
    const stats = await fs.stat(dirPath)
    
    if (stats.isDirectory()) {
      console.log('Directory already exists')
      return
    } else {
      throw new Error('Path exists but is not a directory')
    }
  } catch (err) {
    if (err.code === 'ENOENT') {
      // Directory doesn't exist, create it
      await fs.mkdir(dirPath, { recursive: true })
      console.log('Directory created successfully')
    } else {
      throw err
    }
  }
}

ensureDirectory('./project/data')
```

### Renaming/Moving Directories

The `fs.rename()` method moves or renames directories.[1]

```javascript
const fs = require('fs').promises

async function renameDirectory() {
  try {
    await fs.rename('./old-name', './new-name')
    console.log('Directory renamed successfully')
  } catch (err) {
    console.error('Error renaming directory:', err)
  }
}

renameDirectory()
```

This works for both moving and renaming operations.[1]

### Electron Integration Example

Combining directory operations with Electron's app paths.[1]

```javascript
const { app } = require('electron')
const fs = require('fs').promises
const path = require('path')

app.whenReady().then(async () => {
  const userDataPath = app.getPath('userData')
  const dataDir = path.join(userDataPath, 'data')
  const logsDir = path.join(dataDir, 'logs')
  
  try {
    // Ensure directory structure exists
    await fs.mkdir(logsDir, { recursive: true })
    
    // List contents
    const files = await fs.readdir(dataDir)
    console.log('Data directory contents:', files)
    
  } catch (err) {
    console.error('Error managing directories:', err)
  }
})
```

This creates and manages application-specific directories in the user data location.[1]

Sources
[1] Working with folders in Node.js https://nodejs.org/en/learn/manipulating-files/working-with-folders-in-nodejs
[2] Optimizing Directory Creation in Node.js with fsPromises.mkdir() https://runebook.dev/en/articles/node/fs/fspromisesmkdirpath-options
[3] Node fs.mkdir() Method https://www.geeksforgeeks.org/node-js/node-js-fs-mkdir-method/
[4] Node.js fs.readdir() Method https://www.geeksforgeeks.org/node-js/node-js-fs-readdir-method/
[5] How to Use fs.readdir in Node.js? https://www.browserstack.com/guide/fs-readdir-in-node-js
[6] Node.js fs.readdir recursive directory search https://stackoverflow.com/questions/5827612/node-js-fs-readdir-recursive-directory-search/42441762
[7] How to delete directories in Node.js https://coreui.io/answers/how-to-delete-directories-in-nodejs/
[8] File system | Node.js v25.3.0 Documentation https://nodejs.org/api/fs.html
[9] Delete a Non-Empty Directory Using the rm Command https://www.eukhost.com/kb/how-to-delete-a-non-empty-directory-using-the-rm-command/
[10] Node.js fs.promise.readdir() Method - GeeksforGeeks https://www.geeksforgeeks.org/node-js/node-js-fs-promise-readdir-method/


---

