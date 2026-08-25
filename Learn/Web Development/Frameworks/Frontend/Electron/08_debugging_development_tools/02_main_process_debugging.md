## Main Process Debugging


The main process in Electron cannot be debugged using DevTools in BrowserWindows, as those tools only debug JavaScript executed within renderer windows. Debugging main process code requires external debuggers that connect via the V8 Inspector Protocol, launched using specific command line switches.[1][2]

### Command Line Switches for Debugging

The `--inspect` flag enables debugging by making Electron listen for V8 inspector protocol messages on a specified port. The default port is 9229, though this can be customized by appending the port number to the flag.[2][3]

```bash
electron --inspect=9229 your/app
```

This command starts Electron with debugging enabled, allowing external debuggers to connect on port 9229. The application runs normally while the debugger waits for connections.[2]

The `--inspect-brk` flag works identically to `--inspect` but pauses execution on the first line of JavaScript code before running the application. This enables developers to set breakpoints before application initialization, ensuring early-stage code can be debugged effectively.[3][2]

```bash
electron --inspect-brk=9229 your/app
```

This pause-on-start behavior is essential for debugging issues that occur during app startup, window creation, or the `ready` event handler.[2]

### Chrome DevTools for Main Process

Chrome's built-in debugger can connect to Electron's main process through the `chrome://inspect` interface. After launching Electron with `--inspect`, opening `chrome://inspect` in Chrome displays all available Node.js debugging targets, including the running Electron app. Clicking "inspect" on the Electron target opens a dedicated DevTools window connected to the main process.[1][2]

This DevTools instance provides full debugging capabilities including breakpoints, stepping through code, variable inspection, console access, and profiling. The interface is identical to standard Chrome DevTools but targets the main process instead of a web page.[2]

### Visual Studio Code Debugging

VS Code provides integrated main process debugging through its built-in Node.js debugger. Configuration requires creating a `.vscode/launch.json` file with settings that specify Electron as the runtime executable.[4][5][2]

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Debug Main Process",
      "runtimeExecutable": "${workspaceFolder}/node_modules/.bin/electron",
      "program": "${workspaceFolder}/main.js",
      "outputCapture": "std"
    }
  ]
}
```

The `runtimeExecutable` property points to the local Electron binary installed via npm, while `program` specifies the main process entry point. The `outputCapture: "std"` setting captures stdout and stderr, displaying native module errors and console output in the VS Code debug console.[5][4]

On Windows, the `runtimeExecutable` path should reference `electron.cmd` instead of the Unix-style binary.[5]

```json
{
  "runtimeExecutable": "${workspaceFolder}/node_modules/.bin/electron.cmd"
}
```

After configuring launch.json, developers can start debugging by selecting "Debug Main Process" from the Run and Debug panel or pressing F5. VS Code attaches to the main process, enabling breakpoint placement in main.js and related files.[6][4][5][2]

### Debugging Both Main and Renderer Processes

Simultaneous debugging of both main and renderer processes requires multiple debugger configurations. The main process debugger launches Electron with the `--remote-debugging-port=9222` argument, enabling renderer process attachment.[5]

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Debug Main Process",
      "runtimeExecutable": "${workspaceFolder}/node_modules/.bin/electron",
      "program": "${workspaceFolder}/index.js",
      "runtimeArgs": [
        ".",
        "--remote-debugging-port=9222"
      ]
    },
    {
      "type": "chrome",
      "request": "attach",
      "name": "Attach to Renderer Process",
      "port": 9222,
      "webRoot": "${workspaceFolder}/html"
    }
  ]
}
```

The workflow involves first launching the "Debug Main Process" configuration, then starting the "Attach to Renderer Process" configuration to connect to the renderer. This provides simultaneous debugging access to both processes through VS Code's unified interface.[5]

### Troubleshooting VS Code Debugging

Main process debugging in VS Code can encounter configuration issues, particularly with Electron version compatibility. If the application hangs indefinitely during debugging or fails to start, check that the `runtimeExecutable` path correctly points to the Electron binary.[7][4]

The `outputCapture: "std"` setting is critical for diagnosing startup issues—without it, native module errors and early console output may not appear in the debug console. Setting breakpoints in lifecycle events like `app.on('ready')` or `app.on('before-quit')` helps identify where execution stops during problematic startups.[4]

Some Electron versions require the `"protocol": "legacy"` setting in launch.json for proper debugging attachment. This compatibility flag adjusts how VS Code communicates with the V8 debugger protocol.[5]

### Production Environment Debugging

Debugging main process issues in production builds requires special consideration since packaged applications typically don't include development tools. Running packaged executables with the `--inspect` or `--remote-debugging-port` flags enables debugging of deployed applications.[8]

```bash
./MyApp.exe --remote-debugging-port=8315
```

This command launches the packaged app with debugging enabled on port 8315, allowing Chrome DevTools to connect for remote inspection. Security concerns arise with production debugging—ensure debugging ports are never exposed publicly and are only used in controlled environments.[8]

### Logging and Early Error Detection

When main process crashes occur before debuggers can attach, enabling comprehensive logging is essential. The `--enable-logging` command line flag or the `ELECTRON_ENABLE_LOGGING` environment variable captures Chromium logs that reveal early initialization errors.[9][4]

Adding `console.log` statements at the beginning of the main process file verifies that execution reaches expected code paths. These logs appear in the terminal when running Electron from the command line or in the VS Code debug console when `outputCapture: "std"` is configured.[4]

### Monitoring Main Process Memory

Memory issues in the main process manifest differently than renderer process leaks, often involving native modules rather than JavaScript objects. Tracking both RSS (Resident Set Size) and heap memory distinguishes native memory issues from JavaScript memory leaks.[4]

If RSS grows while heap memory remains stable, native modules or buffers are likely the cause. IPC listener leaks are common in main process memory issues—unregistered listeners accumulate over application lifetime, consuming memory and potentially causing crashes. The process module provides memory usage information through `process.memoryUsage()`, enabling periodic memory monitoring.[4]

### electron-inspector Package

The `electron-inspector` package wraps `node-inspector` to simplify main process debugging setup. This tool automatically configures `node-inspector` for the specific Electron version, reducing setup complexity.[10]

Installation adds an `inspect-main` script to package.json that launches `electron-inspector`.[10]

```json
{
  "scripts": {
    "inspect-main": "electron-inspector"
  }
}
```

Running `npm run inspect-main` starts Electron in debug mode and prints a URL like `http://127.0.0.1:8080/?port=5858` for browser-based debugging. This approach provides a node-inspector UI for main process debugging without manual configuration.[10]

The `--debug-port` flag specifies which port Electron's debug interface is running on, defaulting to 5858. The `--electron` flag specifies the Electron executable path when using non-standard installations.[10]

### electron-debug Package Integration

The `electron-debug` package simplifies development by automatically configuring debugging conveniences. Installing it with `npm install electron-debug --save-dev` and requiring it in main.js with `require('electron-debug')()` enables features like keyboard shortcuts and automatic DevTools opening.[11][4]

While primarily focused on renderer debugging, this package provides context menu inspection and error handling that assists with diagnosing main process issues indirectly through renderer feedback.[11][4]

### Breakpoint Strategies

Effective main process debugging relies on strategic breakpoint placement. Setting breakpoints in application lifecycle events captures critical transitions: `app.on('ready')` for initialization, `app.on('window-all-closed')` for shutdown, `app.on('before-quit')` for cleanup, and IPC event handlers for inter-process communication.[4]

Breaking on uncaught exceptions using debugger configuration or try-catch blocks reveals error sources that would otherwise crash silently. Conditional breakpoints filter high-frequency events, only pausing when specific conditions are met.[4]

### Minimal Reproduction for Issue Reporting

When main process bugs cannot be resolved locally, creating minimal reproductions isolates the problem for issue reporting. Remove all non-essential code to create the smallest possible application that demonstrates the issue. Test with vanilla Electron by creating a minimal-repro application without frameworks or libraries, verifying whether the issue is Electron-specific or related to application code.[4]

Documentation should include exact RSS and heap measurements, Electron version, Node.js version, operating system details, and crash dumps if available. This information enables maintainers to reproduce and diagnose issues efficiently.[4]

Sources
[1] Debugging the Main Process | Electron https://electronjs.org/docs/latest/tutorial/debugging-main-process
[2] Access parent window's 'window' object from child window - Electron https://stackoverflow.com/questions/56220640/access-parent-windows-window-object-from-child-window-electron
[3] Debugging the Main Process | Electronelectronjs.org › docs › latest › tutorial › debugging-main-process https://www.electronjs.org/docs/latest/tutorial/debugging-main-process
[4] Debugging and Troubleshooting Common Electron Issues https://blog.openreplay.com/debugging-troubleshooting-electron-issues/
[5] How to Debug Electron JavaScript and TypeScript with VS Code https://vscode-debug-specs.github.io/javascript_electron/
[6] How to debug the Electron main process? - Stack Overflow https://stackoverflow.com/questions/71997741/how-to-debug-the-electron-main-process
[7] Unable to debug main process in VS Code as of Electron 9. #24918 https://github.com/electron/electron/issues/24918
[8] How to debug main process in production? : r/electronjs - Reddit https://www.reddit.com/r/electronjs/comments/r3zs1h/how_to_debug_main_process_in_production/
[9] Electron - Close initial window but keep child open - Stack Overflow https://stackoverflow.com/questions/48224116/electron-close-initial-window-but-keep-child-open
[10] enlight/electron-inspector: Debugger UI for the main Electron process https://github.com/enlight/electron-inspector
[11] Tips and Tricks for Debugging Electron Applications - SitePoint https://www.sitepoint.com/debugging-electron-application/
[12] A guide on how to debug an Electron app. - GitHub https://github.com/DrifterAtSea/debugging-electron

---

