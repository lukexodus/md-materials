## Using Submenus in Electron Menu


### Basic Submenu Structure

The `submenu` property automatically creates a nested menu when present. You don’t need to explicitly set a `type` - Electron handles this automatically.

```javascript
const { Menu } = require('electron');

const template = [
  {
    label: 'File',
    submenu: [
      {
        label: 'New File',
        click: () => { console.log('New file'); }
      },
      {
        label: 'Open',
        click: () => { console.log('Open'); }
      },
      { type: 'separator' },
      {
        label: 'Exit',
        click: () => { app.quit(); }
      }
    ]
  },
  {
    label: 'Edit',
    submenu: [
      { role: 'undo' },
      { role: 'redo' },
      { type: 'separator' },
      { role: 'cut' },
      { role: 'copy' },
      { role: 'paste' }
    ]
  }
];

const menu = Menu.buildFromTemplate(template);
Menu.setApplicationMenu(menu);
```

### Nested Submenus (Multi-Level)

Submenus can contain other submenus for deeper nesting.

```javascript
const template = [
  {
    label: 'File',
    submenu: [
      {
        label: 'Recent Files',
        submenu: [  // Second level submenu
          { label: 'document1.txt' },
          { label: 'document2.txt' },
          { label: 'document3.txt' }
        ]
      },
      {
        label: 'Export',
        submenu: [  // Another second level submenu
          { label: 'Export as PDF' },
          { label: 'Export as HTML' },
          {
            label: 'Export as Image',
            submenu: [  // Third level submenu
              { label: 'PNG' },
              { label: 'JPEG' },
              { label: 'SVG' }
            ]
          }
        ]
      }
    ]
  }
];
```

### Dynamic Submenu Creation

```javascript
function createRecentFilesSubmenu(files) {
  return files.map(file => ({
    label: file,
    click: () => { openFile(file); }
  }));
}

const recentFiles = ['file1.txt', 'file2.txt', 'file3.txt'];

const template = [
  {
    label: 'File',
    submenu: [
      {
        label: 'Recent Files',
        submenu: createRecentFilesSubmenu(recentFiles)
      }
    ]
  }
];
```

### Context Menu with Submenu

```javascript
const { Menu } = require('electron');

function showContextMenu() {
  const contextMenu = Menu.buildFromTemplate([
    {
      label: 'Format',
      submenu: [
        { label: 'Bold', accelerator: 'CmdOrCtrl+B' },
        { label: 'Italic', accelerator: 'CmdOrCtrl+I' },
        { label: 'Underline', accelerator: 'CmdOrCtrl+U' }
      ]
    },
    { type: 'separator' },
    {
      label: 'Align',
      submenu: [
        { label: 'Left' },
        { label: 'Center' },
        { label: 'Right' }
      ]
    }
  ]);

  contextMenu.popup();
}

// In renderer or when handling right-click
window.addEventListener('contextmenu', (e) => {
  e.preventDefault();
  showContextMenu();
});
```

### Updating Submenu Dynamically

```javascript
const { Menu } = require('electron');

let mainMenu;

function updateRecentFiles(newFiles) {
  const template = [
    {
      label: 'File',
      submenu: [
        {
          label: 'Recent Files',
          submenu: newFiles.map(file => ({
            label: file,
            click: () => { openFile(file); }
          }))
        },
        { type: 'separator' },
        { label: 'Exit', role: 'quit' }
      ]
    }
  ];

  mainMenu = Menu.buildFromTemplate(template);
  Menu.setApplicationMenu(mainMenu);
}

// Update the menu when files change
updateRecentFiles(['newfile1.txt', 'newfile2.txt']);
```

### Submenu with Mixed Item Types

```javascript
const template = [
  {
    label: 'View',
    submenu: [
      { 
        label: 'Reload', 
        accelerator: 'CmdOrCtrl+R',
        click: (item, focusedWindow) => {
          if (focusedWindow) focusedWindow.reload();
        }
      },
      { type: 'separator' },
      { 
        label: 'Toggle Developer Tools',
        accelerator: 'Alt+CmdOrCtrl+I',
        click: (item, focusedWindow) => {
          if (focusedWindow) focusedWindow.toggleDevTools();
        }
      },
      { type: 'separator' },
      {
        label: 'Zoom',
        submenu: [
          { label: 'Zoom In', accelerator: 'CmdOrCtrl+Plus' },
          { label: 'Zoom Out', accelerator: 'CmdOrCtrl+-' },
          { label: 'Reset Zoom', accelerator: 'CmdOrCtrl+0' }
        ]
      }
    ]
  }
];
```

### Complete Application Menu Example

```javascript
const { app, Menu, BrowserWindow } = require('electron');

function createMenu() {
  const isMac = process.platform === 'darwin';

  const template = [
    // App menu (macOS only)
    ...(isMac ? [{
      label: app.name,
      submenu: [
        { role: 'about' },
        { type: 'separator' },
        { role: 'services' },
        { type: 'separator' },
        { role: 'hide' },
        { role: 'hideOthers' },
        { role: 'unhide' },
        { type: 'separator' },
        { role: 'quit' }
      ]
    }] : []),

    // File menu
    {
      label: 'File',
      submenu: [
        {
          label: 'New',
          submenu: [
            { label: 'New Window', accelerator: 'CmdOrCtrl+N' },
            { label: 'New Tab', accelerator: 'CmdOrCtrl+T' }
          ]
        },
        { type: 'separator' },
        isMac ? { role: 'close' } : { role: 'quit' }
      ]
    },

    // Edit menu
    {
      label: 'Edit',
      submenu: [
        { role: 'undo' },
        { role: 'redo' },
        { type: 'separator' },
        { role: 'cut' },
        { role: 'copy' },
        { role: 'paste' }
      ]
    }
  ];

  const menu = Menu.buildFromTemplate(template);
  Menu.setApplicationMenu(menu);
}

app.whenReady().then(() => {
  createMenu();
  // Create window, etc.
});
```

The `submenu` property accepts an array of menu items, and Electron automatically handles the visual presentation and behavior of nested menus across different platforms.​​​​​​​​​​​​​​​​

---

