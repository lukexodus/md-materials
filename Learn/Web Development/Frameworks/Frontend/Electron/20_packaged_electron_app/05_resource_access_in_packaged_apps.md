## Resource Access in Packaged Apps


### File Paths

In development:

```javascript
// This works in development
const filePath = path.join(__dirname, 'data.json');
```

In production (packaged):

```javascript
// Use app.getAppPath() for ASAR files
const { app } = require('electron');
const filePath = path.join(app.getAppPath(), 'data.json');

// For unpacked files
const unpackedPath = path.join(
  process.resourcesPath,
  'app.asar.unpacked',
  'native-module.node'
);
```

### User Data Directory

Never write to the app installation directory. Use:

```javascript
const { app } = require('electron');
const userDataPath = app.getPath('userData');
// ~/Library/Application Support/MyApp (macOS)
// %APPDATA%/MyApp (Windows)
// ~/.config/MyApp (Linux)
```

