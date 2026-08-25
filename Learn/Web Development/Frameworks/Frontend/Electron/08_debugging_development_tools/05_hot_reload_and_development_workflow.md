## Hot Reload and Development Workflow


Hot reload capability accelerates Electron development by automatically reflecting source code changes in the running application without manual restarts. This eliminates the repetitive stop-start cycle during development, enabling faster iteration and more efficient workflows.[1][2][3]

### Understanding Hot Reload vs Live Reload

Hot reload preserves application state while applying code changes, allowing developers to continue from their current position in the application without losing context. Live reload (or hot restart) completely restarts the application, losing all current state but ensuring a fresh execution environment. Most Electron development workflows combine both approaches—reloading renderer processes for UI changes and restarting the main process for backend logic changes.[2][3][4][5][1]

The distinction matters because renderer process reloads are nearly instantaneous (10-20ms with modern tools), while main process restarts take longer due to complete application reinitialization. Optimizing development workflows requires understanding which changes require which reload strategy.[4][5]

### electron-reload Package

The `electron-reload` package provides automatic reloading by watching source file changes and refreshing BrowserWindow instances when files are modified. Installation via `npm install electron-reload --save-dev` adds the package as a development dependency.[6][1][2]

```javascript
const path = require('path')
const env = process.env.NODE_ENV || 'development';

// If development environment
if (env === 'development') {
  require('electron-reload')(__dirname, {
    electron: path.join(__dirname, 'node_modules', '.bin', 'electron'),
    hardResetMethod: 'exit'
  });
}
```

The first parameter specifies the directory to watch, typically `__dirname` for the project root. The `electron` option points to the Electron binary path, enabling the package to restart the application when main process files change. The `hardResetMethod: 'exit'` option completely exits the process before restarting, ensuring clean restarts.[1][2][6]

By default, electron-reload watches for changes in `.js`, `.html`, `.css`, and other web-related files. Custom file extensions can be configured through additional options.[1]

### electron-reloader Package

The `electron-reloader` package (requiring Electron 5+) provides more sophisticated reload behavior, distinguishing between main process and renderer process changes. Main process changes trigger full application restarts, while renderer changes only reload the affected BrowserWindow.[1]

```javascript
try {
  require('electron-reloader')(module);
} catch (_) {}
```

This approach wraps the require in a try-catch because electron-reloader should only be installed as a development dependency, and production builds won't have it available. The package automatically detects which files belong to which process and applies appropriate reload strategies.[1]

### electronmon Utility

The `electronmon` package simplifies development workflows by replacing the `electron` command with automatic restart and reload capabilities. It requires no application code changes or configuration, making it the easiest entry point for hot reload functionality.[3][7]

```bash
npx electronmon .
```

This command launches the Electron application with file watching enabled. Changes to main process files trigger complete application restarts, while renderer process file changes reload only the affected windows.[7][3]

Configuration is optional but available through the `electronmon` object in `package.json`. The `patterns` array adds custom glob patterns to watch or ignore:[3]

```json
{
  "electronmon": {
    "patterns": ["!test/**", "!docs/**"]
  }
}
```

Patterns starting with `!` exclude files from watching. The default patterns are `['**/*', '!node_modules', '!node_modules/**/*', '!.*', '!**/*.map']`, ignoring node_modules, hidden files, and source maps.[7][3]

### nodemon Integration

The standard Node.js tool `nodemon` can monitor Electron applications with appropriate configuration. Installing nodemon globally via `npm install -g nodemon` makes it available across all projects.[8]

A `nodemon.json` configuration file in the project root customizes watching behavior:[8]

```json
{
  "ignore": ["assets/*"],
  "ext": "js,html,css",
  "exec": "electron ."
}
```

The `ignore` array excludes directories from monitoring, `ext` specifies watched file extensions, and `exec` defines the command to run. Launching with `nodemon --exec electron .` starts the application with automatic restart on file changes.[8]

Adding a script to `package.json` simplifies repeated commands:[8]

```json
{
  "scripts": {
    "watch": "nodemon --exec electron ."
  }
}
```

Running `npm run watch` launches the application with nodemon monitoring.[8]

### Webpack with Hot Module Replacement

Webpack-based Electron projects achieve hot module replacement (HMR) through webpack-dev-server, enabling component-level updates without full page reloads. Electron Forge's Webpack plugin enables HMR by default for all renderer processes in development mode.[5][9]

HMR updates occur in 10-20ms compared to Webpack's traditional 500-1600ms reload times, maintaining application state while applying code changes. However, HMR cannot function in preload scripts—webpack watches and recompiles them, but full window reloads are required to apply preload changes.[9][5]

Main process updates require manual restart by typing `rs` in the console where Electron Forge was launched. This signals Forge to restart the application with updated main process code.[9]

### Vite and electron-vite

Vite provides extremely fast development servers with native ES module support and sub-200ms cold starts. The `electron-vite` build tool integrates Vite with Electron, providing hot reloading for all processes.[10][4][5]

Hot reloading in electron-vite watches main process and preload script changes via Rollup watcher. Main process changes trigger rebuilds and application restarts, while preload changes rebuild and trigger renderer reloads.[4][10]

Enabling hot reload uses the CLI option `--watch` or `-w`:

```bash
electron-vite dev --watch
```

Alternatively, set `build.watch: {}` in the configuration file for persistent hot reload. The CLI approach is preferred for flexibility.[10][4]

Hot reloading is only available during development and cannot be used in production builds. The uncontrollable timing of reloads means it isn't always beneficial—electron-vite recommends using the CLI flag to enable it selectively.[4][10]

### TypeScript Development Workflow

TypeScript projects require compilation before Electron execution, complicating hot reload. The `concurrently` package runs multiple commands simultaneously, enabling TypeScript watch compilation alongside Electron execution.[6]

Installing dependencies:

```bash
npm install --save-dev concurrently
npm install electron-reload
```

Package.json scripts coordinate compilation and execution:[6]

```json
{
  "scripts": {
    "build": "tsc",
    "start": "npm run build && electron .",
    "dev": "concurrently \"tsc -w\" \"electron .\""
  }
}
```

The `dev` script runs `tsc -w` (TypeScript watch mode) and `electron .` concurrently. Adding electron-reload to the TypeScript entry point enables automatic reloading when compiled JavaScript changes:[6]

```typescript
import electronReload from "electron-reload";
electronReload(__dirname, {});
```

Running `npm run dev` starts both TypeScript compilation and Electron with automatic reloads on save.[6]

### Framework-Specific Considerations

Vue.js applications with Electron require careful configuration to enable HMR in both the Vue components and Electron shell. Vue CLI's development server provides HMR for components, while electron-reload or electron-reloader handles Electron-specific reloading.[11]

The typical approach loads the Vue development server URL in BrowserWindow during development rather than loading built files:

```javascript
if (process.env.NODE_ENV === 'development') {
  win.loadURL('http://localhost:8080');
} else {
  win.loadFile('dist/index.html');
}
```

This enables Vue's HMR while the Vue development server runs, and electron-reload handles main process changes.[11]

### Development vs Production Conditionals

Hot reload should only activate in development environments to avoid performance overhead and unexpected behavior in production. Checking `process.env.NODE_ENV` conditionally loads reload packages:[1][6]

```javascript
if (process.env.NODE_ENV !== 'production') {
  require('electron-reload')(__dirname);
}
```

Setting `NODE_ENV=production` before packaging prevents reload code from executing in distributed applications. Package managers like electron-builder and electron-packager automatically exclude devDependencies from production builds, but environment checks provide additional safety.[1]

### Performance Optimization

Watch patterns should exclude large directories like `node_modules`, `dist`, and build artifacts to minimize file system overhead. Overly broad watching degrades performance and causes spurious reloads.[3][8]

Debouncing file change events prevents rapid successive reloads when multiple files change simultaneously. Most reload tools implement debouncing automatically, but custom implementations should include delays between detecting changes and triggering reloads.[8]

Browser caching during development can interfere with hot reload, making changes appear not to apply. Disabling cache in DevTools (Network tab → "Disable cache") ensures fresh resources load on every reload.[2]

### API-Based Reload Control

electronmon exposes a programmatic API for advanced reload control beyond automatic file watching. The API allows manual triggering of reloads, restarts, and app closure:[7][3]

```javascript
const electronmon = require('electronmon');

(async () => {
  const app = await electronmon({ cwd: __dirname });
  
  // Programmatic control
  await app.reload();   // Reload renderers
  await app.restart();  // Restart entire app
  await app.close();    // Close and wait for changes
  await app.destroy();  // Stop monitoring
})();
```

The `reload()` method reloads all open BrowserWindows without restarting the main process. The `restart()` method restarts the entire Electron process. The `close()` method closes Electron and waits for file changes before restarting. The `destroy()` method stops monitoring entirely.[3][7]

### Debug Output and Logging

Most reload tools provide logging levels to diagnose file watching issues. electronmon supports `verbose`, `info`, `error`, and `quiet` log levels via the `logLevel` option:[3]

```javascript
electronmon({ logLevel: 'verbose' });
```

Verbose mode displays every file change detected and the resulting reload action, helping debug configuration issues.[3]

### Multi-Window Applications

Applications with multiple BrowserWindows require careful reload coordination to avoid inconsistent states. electron-reload and similar tools reload all open windows simultaneously when renderer files change.[2][1]

For applications where windows have different codebases, configure separate watch patterns for each window's files. Custom reload implementations can selectively reload specific windows based on which files changed.[1]

Sources
[1] Hot Reload in ElectronJS https://www.geeksforgeeks.org/javascript/hot-reload-in-electronjs/
[2] Hot Reload in ElectronJs - Tutorials Point https://www.tutorialspoint.com/hot-reload-in-electronjs
[3] BaseWindow https://www.electronjs.org/docs/latest/api/base-window
[4] Hot Reloading | electron-vite https://electron-vite.org/guide/hot-reloading
[5] What Is Vite? - Improve Your Front-End Workflow - Strapi https://strapi.io/blog/vite-es-modules-hmr-front-end-workflow
[6] HOT RELOADING w/Electron & TypeScript Tutorial in 4 Minutes https://www.youtube.com/watch?v=cNWpbm3MNDQ
[7] catdad/electronmon: run, watch, and restart electron apps using magic https://github.com/catdad/electronmon
[8] How to auto-reload Electron JS projects on file modification https://www.youtube.com/watch?v=nB4ulB8efck
[9] Webpack Plugin | Electron Forge https://www.electronforge.io/config/plugins/webpack
[10] Electron browser window - Stack Overflow https://stackoverflow.com/questions/47673817/electron-browser-window
[11] How does one get Hot Reload to work with an Electron / Vue.js app? https://www.reddit.com/r/electronjs/comments/gdzl86/how_does_one_get_hot_reload_to_work_with_an/
[12] electron main process hot reload or live reload https://stackoverflow.com/questions/54323531/electron-main-process-hot-reload-or-live-reload


---

