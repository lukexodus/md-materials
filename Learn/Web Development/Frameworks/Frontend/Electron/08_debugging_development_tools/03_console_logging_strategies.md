## Console Logging Strategies


Console logging in Electron requires understanding the dual-process architecture where main and renderer processes have separate console outputs and logging requirements. Strategic logging implementation ensures visibility in development while maintaining performance and security in production.[1][2][3][4]

### Process-Specific Console Output

The main process console output appears in the terminal where Electron was launched, while renderer process console output displays in DevTools. When `console.log()` is called in `main.js`, output goes to the terminal or command prompt. When called in renderer code, output appears in the browser DevTools console for that window.[5][1]

This separation means developers must check different locations depending on which process generated the log. Main process logs require running Electron from a terminal to capture output, while renderer logs require opening DevTools for the respective window.[6][1]

### Basic Console Methods

Standard console methods work identically in both processes, following the browser console API. The `console.log()` method outputs general information, `console.warn()` displays warnings with yellow highlighting, `console.error()` shows errors with red highlighting and stack traces, and `console.info()` provides informational messages. The `console.debug()` method outputs debug-level information that can be filtered in DevTools.[1]

Advanced methods include `console.table()` for formatting arrays and objects as tables, `console.group()` and `console.groupEnd()` for collapsible log groups, `console.time()` and `console.timeEnd()` for performance timing, and `console.trace()` for stack trace generation. These methods provide powerful debugging capabilities without additional libraries.[1]

### electron-log Package

The `electron-log` package provides unified logging across main and renderer processes with automatic file output, requiring no complex configuration. Installation via `npm install electron-log` adds comprehensive logging capabilities with sensible defaults.[2][4]

By default, electron-log writes logs to platform-specific locations: `~/.config/{app name}/logs/main.log` on Linux, `~/Library/Logs/{app name}/main.log` on macOS, and `%USERPROFILE%\AppData\Roaming\{app name}\logs\main.log` on Windows. This automatic file management eliminates manual path configuration for typical use cases.[4][2]

### Main Process Logging with electron-log

In the main process, import the logger from `electron-log/main` and initialize it to enable renderer process access. The `initialize()` method sets up IPC channels that allow renderers to send logs to the main process for file writing.[2][4]

```javascript
import log from 'electron-log/main';

log.initialize();

log.info('Log from the main process');
log.warn('Warning message');
log.error('Error message');
```

The logger supports multiple log levels: `error`, `warn`, `info`, `verbose`, `debug`, and `silly`. Each level can be independently controlled per transport, enabling fine-grained control over what gets logged where.[4][2]

### Renderer Process Logging with electron-log

In renderer processes with bundlers, import from `electron-log/renderer` to access the logger. Without bundlers, use the global `__electronLog` variable containing log functions like `info`, `warn`, and `error`.[2][4]

```javascript
import log from 'electron-log/renderer';
log.info('Log from the renderer process');
```

Renderer logs are automatically sent to the main process via IPC transport, where they're written to both the console and file system. This unified approach ensures all logs from all processes accumulate in a single file for comprehensive debugging.[4][2]

### Transport Configuration

Transports are functions that handle log messages, with console and file transports active by default. Each transport has independent `level` and `format` options that control what gets logged and how it appears.[2][4]

The console transport prints messages to the application console in the main process or DevTools in renderers. Its format defaults to `'%c{h}:{i}:{s}.{ms}%c › {text}'` in the main process and `'{h}:{i}:{s}.{ms} › {text}'` in renderers, with a `level` of `'silly'` (all messages). The `useStyles` option forces styling on or off.[4][2]

The file transport (main process only) writes messages to disk with a default format of `'[{y}-{m}-{d} {h}:{i}:{s}.{ms}] [{level}] {text}'`. The log file path is customized via `resolvePathFn`:[2][4]

```javascript
log.transports.file.resolvePathFn = () => path.join(APP_DATA, 'logs/main.log');
```

### IPC Transport Behavior

IPC transport enables cross-process logging visibility. In the main process, it displays logs in renderer DevTools consoles, defaulting to `'silly'` level in development and `false` (disabled) in production. In renderer processes, IPC transport sends logs to the main process for console and file output.[4][2]

Enabling IPC transport in production requires explicitly setting the level:

```javascript
log.transports.ipc.level = 'info';
```

This balances the need for production logging visibility against performance overhead from IPC communication.[2]

### Disabling Transports

Transports are disabled by setting their `level` property to `false`. This is useful for production builds where console output or file logging may be unnecessary or undesirable.[4][2]

```javascript
log.transports.file.level = false;
log.transports.console.level = false;
```

Selective transport disabling optimizes performance by eliminating unnecessary I/O operations.[2]

### Overriding console Methods

Redirecting standard `console.log()` calls to electron-log captures logs from third-party libraries and legacy code. The simplest approach replaces individual methods:[4][2]

```javascript
console.log = log.log;
```

For comprehensive override, assign all log functions:

```javascript
Object.assign(console, log.functions);
```

This ensures all console calls benefit from electron-log's file writing, formatting, and transport features.[7][2]

### Log Levels and Severity

Proper log level usage ensures meaningful logs without noise. The `error` level captures actionable failures requiring immediate attention, `warn` indicates potential issues that may escalate, `info` records significant application events, `verbose` provides detailed operational information, `debug` captures diagnostic data for development, and `silly` logs everything including trivial details.[3][2]

Production builds typically set levels to `info` or `warn`, filtering out verbose debug information that overwhelms log files. Development environments use `debug` or `silly` to maximize visibility.[3]

```javascript
if (app.isPackaged) {
  log.transports.file.level = 'info';
  log.transports.console.level = 'warn';
} else {
  log.transports.file.level = 'silly';
  log.transports.console.level = 'silly';
}
```

### Structured Logging with Formatting

Colors enhance console readability using CSS-style formatting. The syntax `%c` introduces color changes:[2][4]

```javascript
log.info('%cRed text. %cGreen text', 'color: red', 'color: green');
```

Available colors include unset, black, red, green, yellow, blue, magenta, cyan, white, and gray. DevTools consoles support additional CSS properties for advanced styling.[4][2]

Structured logging improves log parsing and analysis by using consistent formats. Instead of string concatenation, use format specifiers or object logging:[3]

```javascript
// Less structured
log.info('User ' + userId + ' logged in from ' + ipAddress);

// More structured
log.info('User login', { userId, ipAddress, timestamp: Date.now() });
```

### Scopes for Context

Logging scopes add context labels to messages, distinguishing logs from different subsystems. Creating scoped loggers with `log.scope('label')` prefixes all messages with the scope name:[2][4]

```javascript
const userLog = log.scope('user');
userLog.info('message with user scope');
// Prints: 12:12:21.962 (user) › message with user scope
```

By default, scope labels are padded for alignment, disabled via `log.scope.labelPadding = false`. Scopes enable filtering logs by subsystem in large applications.[4][2]

### Error Handling and Crash Logging

electron-log captures unhandled errors and rejected promises automatically. Calling `log.errorHandler.startCatching()` installs global handlers that log uncaught exceptions before the application crashes:[2][4]

```javascript
log.errorHandler.startCatching();
```

This ensures critical errors are recorded even when they would otherwise terminate the process silently. Options customize error handling behavior, such as preventing default error dialogs.[4][2]

### Event Logging

Critical Electron events can be automatically logged to track application health. The `log.eventLogger.startLogging()` method monitors events like `certificate-error`, `child-process-gone`, `render-process-gone` from the `app` module, `crashed` and `gpu-process-crashed` from `webContents`, and `did-fail-load`, `plugin-crashed`, `preload-error` from all WebContents instances.[2][4]

```javascript
log.eventLogger.startLogging();
```

Event logging provides visibility into crashes, load failures, and security issues without manual event listener registration.[4][2]

### Conditional and Buffered Logging

Buffering allows deferring the decision to write logs until after operations complete. This enables verbose logging of operations that only writes logs if the operation fails:[2][4]

```javascript
log.buffering.begin();
try {
  log.debug('Starting complex operation');
  // Perform operation
  log.debug('Operation step completed');
  
  log.buffering.reject(); // Operation succeeded, discard logs
} catch (e) {
  log.buffering.commit(); // Operation failed, write buffered logs
  log.error('Operation failed', e);
}
```

This pattern keeps log files concise while preserving detailed traces when debugging failures.[4][2]

### Custom File Paths

Custom log file paths support scenarios like per-user logs or temporary diagnostic files. The `resolvePathFn` property on the file transport determines the log file location:[8][9]

```javascript
const path = require('path');
log.transports.file.resolvePathFn = () => path.join(__dirname, 'logs', 'main.log');
```

Renderer process logs can be directed to separate files by configuring the main process to distinguish log sources. However, renderer logs pass through IPC to the main process, which controls final file writing.[8][2]

### Production Logging Considerations

Production builds require careful logging configuration to balance diagnostic value against performance and privacy. Asynchronous logging prevents main thread blocking—electron-log handles this automatically. Rate limiting or sampling prevents high-frequency loops from flooding logs.[9][3]

Sensitive data must be filtered from logs to comply with privacy regulations and security best practices. Implement log sanitization functions that redact passwords, tokens, and personal information before logging.[3]

File size management prevents unbounded log growth. While electron-log doesn't provide built-in rotation, external log rotation tools or custom code can archive old logs periodically.[9]

### Alternative Logging Libraries

Winston provides enterprise-grade logging with advanced features like log rotation, multiple transports, and custom formatters. Creating a Winston logger requires invoking `winston.createLogger()` with transport configurations:[10][11]

```javascript
const winston = require('winston');

const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [
    new winston.transports.File({ filename: 'error.log', level: 'error' }),
    new winston.transports.File({ filename: 'app.log' })
  ]
});

logger.info('Application started');
```

Winston supports custom log levels, dynamic metadata, query interfaces, and streaming. It integrates with Electron applications but requires more configuration than electron-log.[11][10]

### Remote Logging

Remote transport sends logs to external servers for centralized monitoring. Configuring the remote transport with a URL enables JSON POST requests containing log messages:[2][4]

```javascript
log.transports.remote.level = 'warn';
log.transports.remote.url = 'https://logging-service.example.com/logs';
```

This enables real-time error monitoring in production without accessing user machines. Remote logging should respect user privacy and comply with data protection regulations.[3][2]

Sources
[1] Using console.log() in Electron app https://stackoverflow.com/questions/31759367/using-console-log-in-electron-app
[2] GitHub - megahertz/electron-log: Simple logging module Electron/Node.js/NW.js application. No dependencies. No complicated configuration. https://github.com/megahertz/electron-log
[3] 9 Logging Best Practices You Should Know https://www.dash0.com/guides/logging-best-practices
[4] Set BrowserWindow options defaults for child windows ? · Issue #2781 https://github.com/electron/electron/issues/2781
[5] Electron handle console.log messages in main process https://stackoverflow.com/questions/51360870/electron-handle-console-log-messages-in-main-process
[6] console.log not working in main process in electron https://www.reddit.com/r/node/comments/6f6ula/consolelog_not_working_in_main_process_in_electron/
[7] How to log console.log to file from renderer? · Issue #274 - GitHub https://github.com/SimulatedGREG/electron-vue/issues/274
[8] How to output renderer log to custom filePath · megahertz electron-log · Discussion #411 https://github.com/megahertz/electron-log/discussions/411
[9] Electron app - logging to file in production https://stackoverflow.com/questions/41522769/electron-app-logging-to-file-in-production
[10] 5 Best Node.js Logging Libraries https://www.highlight.io/blog/nodejs-logging-libraries
[11] electron updater.Class.RpmUpdater https://www.electron.build/electron-updater.Class.RpmUpdater.html

---

