## Electron.js Core Modules


Electron provides a comprehensive set of built-in modules and APIs for building cross-platform desktop applications. The framework runs in two primary processes: the main process (Node.js environment) and renderer processes (Chromium-based web pages).[1][2]

### Main Process Modules

The main process serves as the application's entry point and provides access to native desktop functionality:[2]

- **app** - Controls the application lifecycle, handling events like ready, active, quit, and other application-level operations[3][4]
- **BrowserWindow** - Creates and controls browser windows, managing window behavior, appearance, and events like focus, blur, show, hide, maximize, and minimize[5][6]
- **ipcMain** - Handles asynchronous and synchronous inter-process communication (IPC) messages sent from renderer processes using event emitters[7][8]
- **Menu** - Builds and manages application menus and context menus[7]
- **dialog** - Provides native system dialogs for file operations and alerts[2]
- **Tray** - Creates and manages system tray icons[2]

### Renderer Process Modules

- **ipcRenderer** - Enables renderer processes to communicate with the main process by sending messages through developer-defined channels[7]
- **webContents** - Renders and controls web pages, accessible from the main process to interact with renderer content[9]

### Utility Process

- **UtilityProcess API** - Spawns child processes from the main process in a Node.js environment, useful for hosting untrusted services or isolating operations[2]

### Preload Scripts

Preload scripts bridge the main and renderer processes, exposing specific APIs to the window global object while maintaining security by running in an isolated context.[1][2]

