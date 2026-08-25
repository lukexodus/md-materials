## File Path Management


Electron applications require robust file path management to handle cross-platform differences and locate system directories. The `path` module and `app.getPath()` method provide essential tools for constructing and accessing file paths.[1][2]

### Standard System Paths

The `app.getPath(name)` method returns platform-specific directories where applications should store data.[2][1]

**Common Path Types**
```javascript
const { app } = require('electron')

// User data directory - recommended for app configuration and data
const userDataPath = app.getPath('userData')
// Windows: C:\Users\{username}\AppData\Roaming\{app name}
// macOS: ~/Library/Application Support/{app name}
// Linux: ~/.config/{app name}

// Application data directory
const appDataPath = app.getPath('appData')
// Windows: C:\Users\{username}\AppData\Roaming
// macOS: ~/Library/Application Support
// Linux: ~/.config

// Temporary files directory
const tempPath = app.getPath('temp')

// User's home directory
const homePath = app.getPath('home')

// Desktop directory
const desktopPath = app.getPath('desktop')

// Documents directory
const documentsPath = app.getPath('documents')

// Downloads directory
const downloadsPath = app.getPath('downloads')

// User's pictures directory
const picturesPath = app.getPath('pictures')

// User's videos directory
const videosPath = app.getPath('videos')

// User's music directory
const musicPath = app.getPath('music')
```

The `userData` path is automatically created by Electron and is the recommended location for storing application-specific data.[1][2]

### Setting Custom Paths

Override default paths using `app.setPath()` before the `ready` event fires.[3]

```javascript
const { app } = require('electron')
const path = require('path')

// Must be called before 'ready' event
app.setPath('userData', path.join(app.getPath('appData'), 'MyCustomFolder'))

app.on('ready', () => {
  console.log(app.getPath('userData'))
  // Now points to custom location
})
```

This allows custom storage locations, though the default directory may still be created initially.[3]

### Path Module for Cross-Platform Compatibility

Node.js's `path` module ensures file paths work across operating systems.[4]

**Joining Path Segments**
```javascript
const path = require('path')

// Automatically uses correct separator (/ or \)
const configPath = path.join(__dirname, 'config', 'settings.json')
// Windows: C:\app\config\settings.json
// Unix: /app/config/settings.json
```

The `path.join()` method handles platform-specific separators and normalizes the resulting path.[4]

**Other Useful Methods**
```javascript
const path = require('path')

// Get directory name from path
const dir = path.dirname('/path/to/file.txt')
// Returns: /path/to

// Get file name with extension
const file = path.basename('/path/to/file.txt')
// Returns: file.txt

// Get file extension
const ext = path.extname('/path/to/file.txt')
// Returns: .txt

// Normalize path (resolve .. and .)
const normalized = path.normalize('/path/to/../file.txt')
// Returns: /path/file.txt

// Resolve to absolute path
const absolute = path.resolve('relative/path.txt')
// Returns absolute path based on current working directory
```

### Using __dirname

The `__dirname` global variable contains the absolute path to the directory containing the current file.[4]

```javascript
const path = require('path')
const fs = require('fs')

// Read file relative to current script location
const filePath = path.join(__dirname, 'data', 'config.json')
const config = JSON.parse(fs.readFileSync(filePath, 'utf8'))
```

This ensures file operations work regardless of the current working directory.[4]

**ES Modules Equivalent**
```javascript
import { fileURLToPath } from 'url'
import path from 'path'

const __filename = fileURLToPath(import.meta.url)
const __dirname = path.dirname(__filename)

const configPath = path.join(__dirname, 'config', 'app.json')
```

ES modules require reconstructing `__dirname` from `import.meta.url`.[4]

### Packaged Application Paths

Packaged Electron apps have different path requirements than development mode.[5]

**Development vs Production**
```javascript
const { app } = require('electron')
const path = require('path')

const isDev = !app.isPackaged

const resourcesPath = isDev
  ? __dirname
  : process.resourcesPath

const iconPath = path.join(resourcesPath, 'assets', 'icon.png')
```

In production, `process.resourcesPath` points to the `app.asar` or `resources` directory inside the packaged application.[5]

**App Path**
```javascript
const appPath = app.getAppPath()
// Development: Project directory
// Production: Path to .asar file or unpacked app directory
```

### Storing User Configuration

Best practice for user configuration files uses `userData` directory.[6][1]

```javascript
const { app } = require('electron')
const path = require('path')
const fs = require('fs')

class Store {
  constructor(configName) {
    const userDataPath = app.getPath('userData')
    this.path = path.join(userDataPath, `${configName}.json`)
    
    // Create directory if it doesn't exist
    if (!fs.existsSync(userDataPath)) {
      fs.mkdirSync(userDataPath, { recursive: true })
    }
    
    // Initialize with empty object if file doesn't exist
    if (!fs.existsSync(this.path)) {
      this.data = {}
      this.save()
    } else {
      this.data = JSON.parse(fs.readFileSync(this.path, 'utf8'))
    }
  }
  
  get(key) {
    return this.data[key]
  }
  
  set(key, value) {
    this.data[key] = value
    this.save()
  }
  
  save() {
    fs.writeFileSync(this.path, JSON.stringify(this.data, null, 2))
  }
}

// Usage
const store = new Store('config')
store.set('windowBounds', { width: 800, height: 600 })
console.log(store.get('windowBounds'))
```

This pattern persists data between application launches.[6]

### Platform-Specific Path Differences

Understanding platform conventions helps with debugging and testing.[2][1]

| Path Type  | Windows                 | macOS                                 | Linux             |
| ---------- | ----------------------- | ------------------------------------- | ----------------- |
| `appData`  | `%APPDATA%`             | `~/Library/Application Support`       | `~/.config`       |
| `userData` | `%APPDATA%\{app}`       | `~/Library/Application Support/{app}` | `~/.config/{app}` |
| `temp`     | `%TEMP%`                | `/var/folders/...`                    | `/tmp`            |
| `home`     | `C:\Users\{user}`       | `/Users/{user}`                       | `/home/{user}`    |
| `desktop`  | `%USERPROFILE%\Desktop` | `~/Desktop`                           | `~/Desktop`       |

### App Name in Paths

The `userData` path uses the app name from `package.json`.[7]

**package.json**
```json
{
  "name": "my-electron-app",
  "productName": "My Electron App"
}
```

During development, `app.getPath('userData')` may return `Electron` instead of the app name. Setting a proper entry point in `package.json` fixes this:[7]

```json
{
  "name": "my-electron-app",
  "main": "src/main.js"
}
```

For packaged applications, `productName` determines the final directory name.[7]

### Cross-Platform Development

Never commit `node_modules` when sharing projects between operating systems.[8]

```gitignore
node_modules/
dist/
out/
*.log
```

Each platform requires its own `npm install` to compile native dependencies correctly. Electron binaries are platform-specific and cannot be shared between Windows, macOS, and Linux.[8]

Sources
[1] Electron store my app datas in 'userData' path https://stackoverflow.com/questions/61039792/electron-store-my-app-datas-in-userdata-path
[2] Electron Local Data Storage Solutions - Kelen https://en.kelen.cc/posts/electron-local-data-storage-solutions
[3] userData directory is created in the default location when ... https://github.com/electron/electron/issues/2668
[4] How To Use __dirname in Node.js - DigitalOcean https://www.digitalocean.com/community/tutorials/nodejs-how-to-use__dirname
[5] __dirname paths do not resolve correctly when electron ... - GitHub https://github.com/webpack/webpack/issues/5424
[6] Example "store" for user data in an Electron app https://gist.github.com/ccnokes/95cb454860dbf8577e88d734c3f31e08
[7] App.getPath("userData") seems to give the wrong path https://stackoverflow.com/questions/35630934/app-getpathuserdata-seems-to-give-the-wrong-path/35643478
[8] Sharing the same project folder between macOS and Windows https://stackoverflow.com/questions/63916585/electron-sharing-the-same-project-folder-between-macos-and-windows
[9] [Bug]: function app.getPath("userData") returns a wrong path in ... https://github.com/electron/electron/issues/39636
[10] Building Cross-Platform Desktop Apps with Electron.NET - mescius https://developer.mescius.com/blogs/building-cross-platform-desktop-apps-with-electron-dot-net


---

