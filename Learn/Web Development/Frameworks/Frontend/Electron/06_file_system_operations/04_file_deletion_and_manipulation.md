## File Deletion and Manipulation


Node.js's `fs` module provides comprehensive methods for deleting, renaming, moving, and inspecting files in Electron applications. These operations support both synchronous and asynchronous patterns.[1][2][3][4]

### Deleting Files

The `fs.unlink()` method removes files or symbolic links from the file system.[2][1]

**Asynchronous Deletion (Callback)**
```javascript
const fs = require('fs')

fs.unlink('path/to/file.txt', (err) => {
  if (err) {
    console.error('Error deleting file:', err)
    return
  }
  console.log('File deleted successfully')
})
```

**Promise-Based Deletion**
```javascript
const fs = require('fs').promises

async function deleteFile() {
  try {
    await fs.unlink('path/to/file.txt')
    console.log('File deleted successfully')
  } catch (err) {
    console.error('Error deleting file:', err)
  }
}

deleteFile()
```

**Synchronous Deletion**
```javascript
const fs = require('fs')

try {
  fs.unlinkSync('path/to/file.txt')
  console.log('File deleted successfully')
} catch (err) {
  console.error('Error deleting file:', err)
}
```

The `unlink()` method only works for files and symbolic links, not directories. For directories, use `fs.rmdir()` or `fs.rm()`.[5][2]

### Checking File Existence Before Deletion

Verify file existence to prevent errors when deleting.[1][5]

```javascript
const fs = require('fs').promises

async function deleteFileIfExists(filePath) {
  try {
    await fs.access(filePath)
    await fs.unlink(filePath)
    console.log('File deleted successfully')
  } catch (err) {
    if (err.code === 'ENOENT') {
      console.log('File does not exist')
    } else {
      console.error('Error deleting file:', err)
    }
  }
}

deleteFileIfExists('path/to/file.txt')
```

Using `fs.access()` checks if the file exists before attempting deletion.[1]

### Renaming and Moving Files

The `fs.rename()` method handles both renaming and moving files.[4][6]

**Renaming Files**
```javascript
const fs = require('fs')

fs.rename('old-name.txt', 'new-name.txt', (err) => {
  if (err) {
    console.error('Error renaming file:', err)
    return
  }
  console.log('File renamed successfully')
})
```

**Moving Files**
```javascript
const fs = require('fs').promises
const path = require('path')

async function moveFile(oldPath, newPath) {
  try {
    await fs.rename(oldPath, newPath)
    console.log('File moved successfully')
  } catch (err) {
    console.error('Error moving file:', err)
  }
}

moveFile('path/to/file.txt', 'new-folder/file.txt')
```

If a file already exists at the destination path, `rename()` overwrites it.[6]

### Cross-Device File Moving

The `rename()` method fails when moving files across different devices or partitions (error code `EXDEV`). In this case, copy the file and delete the original:[4]

```javascript
const fs = require('fs')

function moveFile(oldPath, newPath, callback) {
  fs.rename(oldPath, newPath, (err) => {
    if (err) {
      if (err.code === 'EXDEV') {
        // Cross-device move - copy then delete
        copyFile(oldPath, newPath, (copyErr) => {
          if (copyErr) {
            callback(copyErr)
            return
          }
          
          fs.unlink(oldPath, (unlinkErr) => {
            callback(unlinkErr)
          })
        })
      } else {
        callback(err)
      }
    } else {
      callback(null)
    }
  })
}

function copyFile(source, target, callback) {
  const readStream = fs.createReadStream(source)
  const writeStream = fs.createWriteStream(target)
  
  readStream.on('error', callback)
  writeStream.on('error', callback)
  writeStream.on('finish', callback)
  
  readStream.pipe(writeStream)
}

// Usage
moveFile('/source/path/file.txt', '/destination/path/file.txt', (err) => {
  if (err) {
    console.error('Error moving file:', err)
  } else {
    console.log('File moved successfully')
  }
})
```

### Copying Files

Node.js provides `fs.copyFile()` for efficient file copying.[4]

**Asynchronous Copy**
```javascript
const fs = require('fs')

fs.copyFile('source.txt', 'destination.txt', (err) => {
  if (err) {
    console.error('Error copying file:', err)
    return
  }
  console.log('File copied successfully')
})
```

**Promise-Based Copy**
```javascript
const fs = require('fs').promises

async function copyFile(source, destination) {
  try {
    await fs.copyFile(source, destination)
    console.log('File copied successfully')
  } catch (err) {
    console.error('Error copying file:', err)
  }
}

copyFile('source.txt', 'destination.txt')
```

**Synchronous Copy**
```javascript
const fs = require('fs')

try {
  fs.copyFileSync('source.txt', 'destination.txt')
  console.log('File copied successfully')
} catch (err) {
  console.error('Error copying file:', err)
}
```

### Retrieving File Metadata

The `fs.stat()` method returns detailed file information.[7][8]

```javascript
const fs = require('fs')

fs.stat('myFile.txt', (err, stats) => {
  if (err) {
    console.error('Error accessing file:', err)
    return
  }
  
  console.log('File size:', stats.size, 'bytes')
  console.log('Created:', stats.birthtime)
  console.log('Modified:', stats.mtime)
  console.log('Accessed:', stats.atime)
  console.log('Changed:', stats.ctime)
  console.log('Is file:', stats.isFile())
  console.log('Is directory:', stats.isDirectory())
  console.log('Is symbolic link:', stats.isSymbolicLink())
})
```

**Promise-Based Stats**
```javascript
const fs = require('fs').promises

async function getFileStats(filePath) {
  try {
    const stats = await fs.stat(filePath)
    
    return {
      size: stats.size,
      created: stats.birthtime,
      modified: stats.mtime,
      isFile: stats.isFile(),
      isDirectory: stats.isDirectory()
    }
  } catch (err) {
    console.error('Error getting file stats:', err)
  }
}

// Usage
const fileInfo = await getFileStats('myFile.txt')
console.log(fileInfo)
```

### Stats Object Properties

The `Stats` object provides comprehensive file metadata.[8]

| Property | Description |
|----------|-------------|
| `stats.size` | File size in bytes (0 for directories) |
| `stats.birthtime` | File creation time |
| `stats.mtime` | Last modification time |
| `stats.atime` | Last access time |
| `stats.ctime` | Last metadata change time |
| `stats.isFile()` | Returns true if path is a file |
| `stats.isDirectory()` | Returns true if path is a directory |
| `stats.isSymbolicLink()` | Returns true if path is a symbolic link |
| `stats.isBlockDevice()` | Returns true if block device |
| `stats.isCharacterDevice()` | Returns true if character device |
| `stats.isFIFO()` | Returns true if FIFO pipe |
| `stats.isSocket()` | Returns true if socket |

### Checking File Existence

Use `fs.stat()` to verify file existence.[7]

```javascript
const fs = require('fs')

fs.stat('myFile.txt', (err, stats) => {
  if (err && err.code === 'ENOENT') {
    console.log('File does not exist')
  } else if (err) {
    console.error('Error accessing file:', err)
  } else {
    console.log('File exists')
  }
})
```

**Promise-Based Existence Check**
```javascript
const fs = require('fs').promises

async function fileExists(filePath) {
  try {
    await fs.stat(filePath)
    return true
  } catch (err) {
    if (err.code === 'ENOENT') {
      return false
    }
    throw err
  }
}

// Usage
const exists = await fileExists('myFile.txt')
console.log('File exists:', exists)
```

### Using BigInt for Large Files

For files larger than 2GB, use the `bigint` option to avoid integer overflow.[8]

```javascript
const fs = require('fs')

fs.stat('large-file.bin', { bigint: true }, (err, stats) => {
  if (err) {
    console.error('Error:', err)
    return
  }
  
  console.log('File size:', stats.size) // Returns BigInt
})
```

### Electron Integration Example

Combining file operations in an Electron app with IPC.[1][4]

**Main Process**
```javascript
const { ipcMain } = require('electron')
const fs = require('fs').promises

ipcMain.handle('delete-file', async (event, filePath) => {
  try {
    await fs.unlink(filePath)
    return { success: true }
  } catch (err) {
    return { success: false, error: err.message }
  }
})

ipcMain.handle('move-file', async (event, oldPath, newPath) => {
  try {
    await fs.rename(oldPath, newPath)
    return { success: true }
  } catch (err) {
    return { success: false, error: err.message }
  }
})

ipcMain.handle('get-file-stats', async (event, filePath) => {
  try {
    const stats = await fs.stat(filePath)
    return {
      success: true,
      stats: {
        size: stats.size,
        created: stats.birthtime,
        modified: stats.mtime,
        isFile: stats.isFile()
      }
    }
  } catch (err) {
    return { success: false, error: err.message }
  }
})
```

**Preload Script**
```javascript
const { contextBridge, ipcRenderer } = require('electron')

contextBridge.exposeInMainWorld('fileOps', {
  deleteFile: (filePath) => ipcRenderer.invoke('delete-file', filePath),
  moveFile: (oldPath, newPath) => ipcRenderer.invoke('move-file', oldPath, newPath),
  getFileStats: (filePath) => ipcRenderer.invoke('get-file-stats', filePath)
})
```

**Renderer Process**
```javascript
// Delete file
window.fileOps.deleteFile('/path/to/file.txt').then(result => {
  if (result.success) {
    console.log('File deleted')
  } else {
    console.error('Error:', result.error)
  }
})

// Move file
window.fileOps.moveFile('/old/path.txt', '/new/path.txt').then(result => {
  if (result.success) {
    console.log('File moved')
  }
})

// Get file stats
window.fileOps.getFileStats('/path/to/file.txt').then(result => {
  if (result.success) {
    console.log('File size:', result.stats.size, 'bytes')
  }
})
```

Sources
[1] node.js remove file https://stackoverflow.com/questions/5315138/node-js-remove-file
[2] Node fs.unlink() Method https://www.geeksforgeeks.org/node-js/node-js-fs-unlink-method/
[3] Node.js File System – Utilizing unlink() and unlinkSync() for ... https://dev.to/mccallum91/nodejs-file-system-utilizing-unlink-and-unlinksync-for-file-deletion-595e
[4] How do I move files in node.js? https://stackoverflow.com/questions/8579055/how-do-i-move-files-in-node-js
[5] How to Remove File in Node.js Using fs Module https://www.bacancytechnology.com/qanda/node/remove-file-in-node-js-using-fs-module
[6] Node fs.rename() Method https://www.geeksforgeeks.org/javascript/node-js-fs-rename-method/
[7] Mastering Node.js fs.stat(): Retrieving File Metadata https://runebook.dev/en/articles/node/fs/fsstatpath-options-callback
[8] Node.js fs.stat() Method - GeeksforGeeks https://www.geeksforgeeks.org/node-js/node-js-fs-stat-method/
[9] Trying to delete a file using Node.js. Should I use asynchronously fs.unlink(path, callback) or synchronous fs.unlinkSync(path)? https://stackoverflow.com/questions/66456409/trying-to-delete-a-file-using-node-js-should-i-use-asynchronously-fs-unlinkpat
[10] 7. How to Delete Files and Directories in Node.js | unlink vs rm vs rmdir Explained https://www.youtube.com/watch?v=pWRcazOOf-g


---

