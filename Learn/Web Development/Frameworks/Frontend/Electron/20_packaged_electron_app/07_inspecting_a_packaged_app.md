## Inspecting a Packaged App


### Extract ASAR Contents

```bash
# Install asar globally
npm install -g asar

# Extract ASAR file
asar extract app.asar extracted/

# List ASAR contents
asar list app.asar
```

### Debug Packaged App

```javascript
// In main.js, enable DevTools for packaged app
if (!app.isPackaged) {
  // Development
  mainWindow.webContents.openDevTools();
} else {
  // Production - enable if needed for debugging
  // mainWindow.webContents.openDevTools();
}
```

