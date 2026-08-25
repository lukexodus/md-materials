## Error Handling


Error handling in Electron spans both main and renderer processes, each requiring distinct approaches to catch and manage exceptions effectively. Proper error handling prevents silent failures, provides user feedback for crashes, and enables diagnostic logging for troubleshooting.[1][2][3][4]

### Uncaught Exceptions in Main Process

The main process catches uncaught exceptions using Node.js's standard `process.on('uncaughtException')` event handler. When registered, this handler receives all errors that would otherwise crash the application, allowing custom error processing.[5][1]

```javascript
process.on('uncaughtException', (error) => {
  console.error('Uncaught exception in main process:', error);
  // Log to file, display error dialog, or send to error tracking service
});
```

By default, Electron displays an error dialog when uncaught exceptions occur, but registering an `uncaughtException` handler overrides this behavior. The handler must implement its own error reporting mechanisms, such as logging to files, displaying custom dialogs, or sending reports to remote services.[6][1][5]

Note that continuing execution after uncaught exceptions is generally unsafe—the application state may be corrupted. Best practice is to log the error and gracefully shut down the application.[1]

### Unhandled Promise Rejections in Main Process

Unhandled promise rejections require a separate event handler beyond `uncaughtException`. The `process.on('unhandledRejection')` event captures promise rejections that lack `.catch()` handlers.[3][4]

```javascript
process.on('unhandledRejection', (reason, promise) => {
  console.error('Unhandled promise rejection:', reason);
  console.error('Promise:', promise);
});
```

This handler receives two arguments: `reason` (the rejection value, typically an Error object) and `promise` (the Promise that was rejected). Without this handler, unhandled rejections may go unnoticed, causing silent failures that are difficult to diagnose.[3]

### Renderer Process Error Handling

Renderer processes handle errors using standard browser error handling mechanisms. The `window.onerror` global handler catches uncaught exceptions in renderer JavaScript:[2][3]

```javascript
window.onerror = (message, source, lineno, colno, error) => {
  console.error('Renderer error:', { message, source, lineno, colno, error });
  return true; // Prevents default error dialog
};
```

The handler receives the error message, source file, line number, column number, and Error object. Returning `true` from the handler prevents the browser's default error reporting.[2]

Unhandled promise rejections in renderers are caught using `window.addEventListener('unhandledrejection')`:

```javascript
window.addEventListener('unhandledrejection', (event) => {
  console.error('Unhandled promise rejection in renderer:', event.reason);
  event.preventDefault(); // Prevents default browser handling
});
```

### electron-unhandled Package

The `electron-unhandled` package simplifies error handling across both main and renderer processes with unified configuration. Installing via `npm install electron-unhandled` and calling `unhandled()` in both processes catches all uncaught errors and promise rejections.[4][2][3]

```javascript
import unhandled from 'electron-unhandled';

unhandled();
```

This single function call sets up handlers for `uncaughtException`, `unhandledRejection` in the main process, and `error`, `unhandledrejection` events in renderer processes. The package must be called at minimum in the main process, though calling it in all processes ensures comprehensive error coverage.[4][3]

### Error Dialog Configuration

electron-unhandled displays error dialogs to users when errors occur, configurable through options. The `showDialog` option controls dialog presentation, defaulting to `true` in production and `false` in development.[3][4]

```javascript
unhandled({
  showDialog: true,
  logger: console.error
});
```

The `logger` option specifies a custom logging function that receives errors, defaulting to `console.error`. This enables integration with logging libraries like electron-log or remote error tracking services.[4][3]

### Error Reporting Button

The `reportButton` option adds a "Report…" button to error dialogs, executing a custom function when clicked. This function receives the error as its first argument, enabling automated issue creation or error submission.[3][4]

```javascript
import unhandled from 'electron-unhandled';
import { openNewGitHubIssue } from 'electron-util';
import { debugInfo } from 'electron-util/main';

unhandled({
  reportButton: (error) => {
    openNewGitHubIssue({
      user: 'your-username',
      repo: 'your-repo',
      body: `
## Error Stack

\`\`\`
${error.stack}
\`\`\`

## System Info

${debugInfo()}`
    });
  }
});
```

This creates a seamless error reporting workflow where users can submit bug reports with a single click. The `electron-util` package provides helper functions for opening GitHub issues with pre-populated content.[4][3]

### Manual Error Logging

The `logError(error, options)` function manually logs errors using the same configuration as automatic error handling. This is useful for logging caught errors that require user notification or special handling.[3][4]

```javascript
import { logError } from 'electron-unhandled';

try {
  // Risky operation
} catch (error) {
  logError(error, { title: 'Operation Failed' });
}
```

The `title` option customizes the error dialog title, overriding the default `${appName} encountered an error`.[4][3]

### WebContents Error Events

The webContents instance emits events for renderer-specific errors that occur during page loading and navigation. The `did-fail-load` event fires when navigation fails, providing an `errorCode`, `errorDescription`, and `validatedURL`. The `did-fail-provisional-load` event fires when provisional navigation fails.[7][8]

```javascript
win.webContents.on('did-fail-load', (event, errorCode, errorDescription, validatedURL) => {
  console.error(`Failed to load ${validatedURL}: ${errorDescription} (${errorCode})`);
});
```

These events enable custom error pages or retry logic when resources fail to load.[8]

### Crash Detection Events

Renderer process crashes trigger the `crashed` event on webContents, receiving a boolean `killed` parameter indicating whether the process was killed by the OS or exited normally. This event enables crash recovery logic, such as reloading the renderer or notifying users.[9][7]

```javascript
win.webContents.on('crashed', (event, killed) => {
  console.error('Renderer process crashed', { killed });
  
  // Reload the renderer or show error page
  if (killed) {
    win.webContents.reload();
  }
});
```

The `render-process-gone` event (app module) fires when any renderer process crashes, disappears, or is killed, providing detailed exit information through the `details` parameter. This event is more comprehensive than the webContents `crashed` event.[7][9] For instance:

```javascript
app.on('render-process-gone', (event, webContents, details) => {
  console.log('Renderer process gone:', details.reason)
  // details.reason could be 'clean-exit', 'abnormal-exit', 'killed', 'crashed', 'oom', 'launch-failed', 'integrity-failure'
  console.log('Exit code:', details.exitCode)
})
```

[Inference] The reason values likely indicate: `clean-exit` - process exited normally (exit code 0), `abnormal-exit` - process exited with non-zero code, `killed` - process was forcefully terminated (by user or system), `crashed` - process crashed due to an exception or error, `oom` - process terminated due to out-of-memory condition, `launch-failed` - process failed to start, `integrity-failure` - process failed code integrity checks.

Another example showing how to handle specific crash reasons:

```javascript
app.on('render-process-gone', (event, webContents, details) => {
  if (details.reason === 'oom') {
    console.error('Renderer ran out of memory')
  } else if (details.reason === 'crashed') {
    console.error('Renderer crashed unexpectedly')
    webContents.reload() // attempt recovery
  }
})
```

The `child-process-gone` event fires when child processes created by Electron crash or are killed, useful for monitoring utility processes.[7] For example:

```javascript
app.on('child-process-gone', (event, details) => {
  console.log('Child process type:', details.type) // 'GPU', 'Utility', etc.
  console.log('Reason:', details.reason)
  console.log('Exit code:', details.exitCode)
  console.log('Service name:', details.name) // if it's a utility process
})
```

### Main Process Crash Handling

Main process crashes cannot be caught by Node.js error handlers since they represent catastrophic failures. The Electron `crashReporter` module sends crash reports to remote servers when the main or renderer processes crash.[9][7]

```javascript
const { crashReporter } = require('electron');

crashReporter.start({
  productName: 'YourAppName',
  companyName: 'YourCompany',
  submitURL: 'https://your-domain.com/crash-reports',
  autoSubmit: true
});
```

The `submitURL` receives POST requests containing crash dumps, process type, app version, OS information, and custom parameters. This enables post-mortem debugging of crashes that occur in production.[7]

### Orphaned Processes Issue

Main process crashes can leave renderer and crash reporter processes running in the background, consuming resources indefinitely. This issue occurs particularly when using the `remote` module or when crashes happen during specific window lifecycle operations.[9]

Manually killing orphaned processes via task manager is the only remedy, highlighting the importance of main process stability and crash prevention. Using process monitoring tools to detect orphaned Electron processes enables automated cleanup.[9]

### IPC Error Handling

IPC communication errors require special handling since they span process boundaries. When throwing errors in `ipcMain.handle()` handlers, only the error's `message` property is transmitted to the renderer—the full error object is not preserved.[10][5]

```javascript
// Main process
ipcMain.handle('risky-operation', async (event, data) => {
  try {
    return await performOperation(data);
  } catch (error) {
    console.error('IPC handler error:', error);
    throw new Error(error.message); // Only message crosses IPC boundary
  }
});

// Renderer process
try {
  await ipcRenderer.invoke('risky-operation', data);
} catch (error) {
  console.error('Operation failed:', error.message);
}
```

For more comprehensive error transmission, serialize error details into a structured object and return it as a regular value rather than throwing.[5]

### Console Message Errors

The `console-message` event on webContents captures all console output from renderers, including errors. The event provides `level` (string: 'info', 'warning', 'error', 'debug'), `message`, `lineNumber`, `sourceId`, and `frame`.[11][8]

```javascript
win.webContents.on('console-message', ({ level, message, lineNumber, sourceId }) => {
  if (level === 'error') {
    console.error(`Renderer console error at ${sourceId}:${lineNumber}: ${message}`);
  }
});
```

This enables centralized error logging that captures renderer console errors in the main process.[8][11]

### Error Recovery Strategies

Graceful degradation handles errors by providing reduced functionality rather than complete failure. When critical features fail, display informative error messages and offer alternative workflows.[2]

Automatic renderer reload recovers from renderer crashes by calling `webContents.reload()` after the `crashed` event fires. This approach works for transient errors but may cause infinite reload loops if the crash is determ9inistic.[7]

Safe mode or fallback configurations disable problematic features after repeated crashes, allowing users to access the application in a limited state. Tracking crash frequency and triggering safe mode after a threshold prevents crash loops.[2]

### Testing Error Handling

Deliberately triggering errors verifies error handling implementations. Calling `process.crash()` in either the main or renderer process forces an immediate crash for testing crash reporters and recovery logic.[9][7]

```javascript
// Trigger main process crash for testing
process.crash();
```

Throwing unhandled errors and unhandled promise rejections tests error handlers:

```javascript
// Test uncaught exception handler
throw new Error('Test error');

// Test unhandled rejection handler
Promise.reject(new Error('Test rejection'));
```

These tests verify that error handlers correctly log errors, display dialogs, and execute recovery procedures.[2][3]

### Production Error Considerations

Production error handling balances user experience against debugging information. Error dialogs should be user-friendly without exposing technical details that confuse non-technical users. Detailed error information should be logged to files or remote services for developer access.[2][3]

Privacy considerations require sanitizing error messages and stack traces before sending to remote servers, ensuring sensitive data isn't inadvertently transmitted. Rate limiting prevents error storms from overwhelming logging services or crash reporting endpoints.[2]

Sources
[1] How to catch errors occured in the main process? #2479 https://github.com/electron/electron/issues/2479
[2] Error Handling in ElectronJS - GeeksforGeeks https://www.geeksforgeeks.org/javascript/error-handling-in-electronjs/
[3] GitHub - sindresorhus/electron-unhandled: Catch unhandled errors and promise rejections in your Electron app https://github.com/sindresorhus/electron-unhandled
[4] Creating multi-window Electron apps using React portals https://pietrasiak.com/creating-multi-window-electron-apps-using-react-portals
[5] Electron ipcMain how to gracefully handle throwing an error https://stackoverflow.com/questions/66341659/electron-ipcmain-how-to-gracefully-handle-throwing-an-error
[6] It should crash on uncaughtException · Issue #1536 · electron/electron https://github.com/electron/electron/issues/1536
[7] Serverless crash reporting for Electron apps - Teamwork.com https://engineroom.teamwork.com/serverless-crash-reporting-for-electron-apps-fe6e62e5982a
[8] webContents | Electron https://electronjs.org/docs/latest/api/web-contents
[9] Some processes remain alive in the background after main ... - GitHub https://github.com/electron/electron/issues/21681
[10] Electron - How to know when renderer window is ready https://stackoverflow.com/questions/42284627/electron-how-to-know-when-renderer-window-is-ready
[11] Breaking Changes | Electron https://electronjs.org/docs/latest/breaking-changes
[12] Handling uncaught exceptions on browser (node) side · Issue #1012 · electron/electron https://github.com/electron/electron/issues/1012

---

