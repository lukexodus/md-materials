## Main Process


```javascript
// main.js - Main Process
const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');

let mainWindow;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 800,
    height: 600,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false
    }
  });

  mainWindow.loadFile('index.html');
}

// Handle messages from renderer via preload
ipcMain.handle('ping', async (event, message) => {
  console.log('Main received:', message);
  return `Main process received: ${message}`;
});

ipcMain.on('async-message', (event, message) => {
  console.log('Main received async:', message);
  event.reply('async-reply', `Main replies: ${message}`);
});

app.whenReady().then(createWindow);

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (BrowserWindow.getAllWindows().length === 0) {
    createWindow();
  }
});
```

