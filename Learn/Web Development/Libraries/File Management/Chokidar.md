## What is Chokidar?

Chokidar is a minimal and efficient cross-platform file watching library for Node.js. It was made for Brunch in 2012 and is now used in approximately 30 million repositories, having established reliability in production environments. The library wraps Node.js core file system modules to provide normalized, consistent file watching across different operating systems.

### Etymology

The name "chokidar" is a transliteration of a Hindi word meaning "watchman, gatekeeper" (चौकीदार), which comes from Sanskrit चतुष्क meaning crossway, quadrangle, or consisting-of-four. The word is also used in Urdu (چوکیدار) throughout Pakistan and India.

## Why Use Chokidar?

### Problems with Native Node.js File Watching

Node.js provides built-in file watching through `fs.watch` and `fs.watchFile`, but these methods have several limitations:

On macOS, fs.watch doesn't report filenames, doesn't report events at all when using editors like Sublime, often reports events twice, emits most changes as rename, and doesn't provide an easy way to recursively watch file trees. Additionally, recursive watching is not supported on Linux.

### Chokidar's Solutions

Chokidar normalizes the events it receives from fs.watch and fs.watchFile, often checking for truth by getting file stats and directory contents. The library provides:

- Proper event reporting with correct filenames on all platforms
- Support for atomic writes (used by many text editors)
- Support for chunked writes (common with large files)
- File and directory filtering capabilities
- Symbolic link support
- Consistent recursive watching across all platforms
- Configurable recursion depth limits

### Performance Characteristics

The fs.watch-based implementation is the default, which avoids polling and keeps CPU usage down. On macOS, Chokidar uses the native FSEvents API for very efficient recursive watching. The library will initiate watchers recursively for everything within scope of the specified paths, so users should be careful not to waste system resources by watching more than necessary.

## Installation and Basic Usage

### Installation

```bash
npm install chokidar
```

The current version is 5.0.0, which was published approximately 2 months ago. [Inference: This refers to November 2024 based on the current date of January 23, 2026]

### Simple Example

```javascript
import chokidar from 'chokidar';

// Watch current directory for all changes
chokidar.watch('.').on('all', (event, path) => {
  console.log(event, path);
});
```

### Comprehensive Example

```javascript
import chokidar from 'chokidar';

// Initialize watcher with options
const watcher = chokidar.watch('file, dir, or array', {
  ignored: (path, stats) => stats?.isFile() && !path.endsWith('.js'),
  persistent: true,
});

// Add event listeners
watcher
  .on('add', (path) => console.log(`File ${path} has been added`))
  .on('change', (path) => console.log(`File ${path} has been changed`))
  .on('unlink', (path) => console.log(`File ${path} has been removed`))
  .on('addDir', (path) => console.log(`Directory ${path} has been added`))
  .on('unlinkDir', (path) => console.log(`Directory ${path} has been removed`))
  .on('error', (error) => console.log(`Watcher error: ${error}`))
  .on('ready', () => console.log('Initial scan complete. Ready for changes'));
```

## API Reference

### Main Method

#### `chokidar.watch(paths, options)`

Initiates a watcher instance for the specified paths.

**Parameters:**

- `paths` (string or array of strings): Paths to files or directories to watch recursively
- `options` (object): Configuration options (see Options section below)

**Returns:** An instance of `FSWatcher`

### FSWatcher Methods

#### `.add(path / paths)`

Adds files or directories for tracking. Accepts an array of strings or a single string.

```javascript
watcher.add('new-file');
watcher.add(['new-file-2', 'new-file-3']);
```

#### `.unwatch(path / paths)`

Stops watching files or directories. Accepts an array of strings or a single string.

```javascript
await watcher.unwatch('new-file');
```

#### `.close()`

Removes all listeners from watched files. This method is asynchronous and returns a Promise.

```javascript
await watcher.close().then(() => console.log('closed'));
```

#### `.getWatched()`

Returns an object representing all paths being watched on the file system. Keys are directories (absolute paths unless `cwd` option was used), and values are arrays of item names within each directory.

```javascript
let watchedPaths = watcher.getWatched();
```

### Events

#### `.on(event, callback)`

Listens for file system events.

**Available events:**

- `add`: File has been added
- `addDir`: Directory has been added
- `change`: File has been changed
- `unlink`: File has been removed
- `unlinkDir`: Directory has been removed
- `ready`: Initial scan complete, ready for changes
- `raw`: Internal event with raw details
- `error`: Error occurred
- `all`: Emitted for every non-error event (except `ready`, `raw`, and `error`)

**Event Arguments:**

The add, addDir, and change events also receive fs.Stats results as a second argument when available.

```javascript
watcher.on('change', (path, stats) => {
  if (stats) console.log(`File ${path} changed size to ${stats.size}`);
});
```

## Configuration Options

### Persistence

#### `persistent`

**Default:** `true`

Indicates whether the process should continue to run as long as files are being watched.

### Path Filtering

#### `ignored`

**Type:** Function, regex, or string  
**Default:** undefined

Defines files or paths to be ignored. The entire relative or absolute path is tested, not just the filename.

When providing a function with two arguments, it gets called twice per path - once with a single argument (the path), and a second time with two arguments (the path and the fs.Stats object).

```javascript
// Ignore .txt files
ignored: (file) => file.endsWith('.txt')

// Watch only .txt files
ignored: (file, stats) => stats?.isFile() && !file.endsWith('.txt')
```

#### `ignoreInitial`

**Default:** `false`

If set to false, add and addDir events are also emitted for matching paths while instantiating the watching as chokidar discovers these file paths, before the ready event.

#### `followSymlinks`

**Default:** `true`

When false, only the symlinks themselves will be watched for changes instead of following the link references and bubbling events through the link's path.

#### `cwd`

**Default:** undefined

The base directory from which watch paths are derived. Paths emitted with events will be relative to this.

### Performance Options

#### `usePolling`

**Default:** `false`

Whether to use fs.watchFile (backed by polling) or fs.watch. If polling leads to high CPU utilization, consider keeping this as false. It is typically necessary to set this to true to successfully watch files over a network, and it may be necessary to successfully watch files in other non-standard situations.

You may also set the CHOKIDAR_USEPOLLING environment variable to true (1) or false (0) to override this option.

#### `interval`

**Default:** `100` (milliseconds)

Interval of file system polling in milliseconds, effective when usePolling is true. You may also set the CHOKIDAR_INTERVAL environment variable to override this option.

#### `binaryInterval`

**Default:** `300` (milliseconds)

Interval of file system polling for binary files, effective when usePolling is true.

#### `alwaysStat`

**Default:** `false`

If relying upon the fs.Stats object that may get passed with add, addDir, and change events, set this to true to ensure it is provided even in cases where it wasn't already available from the underlying watch events.

#### `depth`

**Default:** `undefined`

If set, limits how many levels of subdirectories will be traversed.

#### `awaitWriteFinish`

**Default:** `false`

By default, the add event will fire when a file first appears on disk, before the entire file has been written. Furthermore, some change events may be emitted while the file is being written.

Setting awaitWriteFinish to true will poll file size, holding its add and change events until the size does not change for a configurable amount of time. [Unverified: The exact behavior depends on the specific timing and system conditions]

Can be set to an object to adjust timing parameters:

- `awaitWriteFinish.stabilityThreshold` (default: 2000): Time in milliseconds for file size to remain constant before emitting event
- `awaitWriteFinish.pollInterval` (default: 100): File size polling interval in milliseconds

```javascript
awaitWriteFinish: {
  stabilityThreshold: 2000,
  pollInterval: 100
}
```

### Error Handling

#### `ignorePermissionErrors`

**Default:** `false`

Indicates whether to watch files that don't have read permissions if possible. If watching fails due to EPERM or EACCES with this set to true, the errors will be suppressed silently.

#### `atomic`

**Default:** `true` (when `useFsEvents` and `usePolling` are both `false`)

Automatically filters out artifacts that occur when using editors that use "atomic writes" instead of writing directly to the source file. If a file is re-added within 100 ms of being deleted, Chokidar emits a change event rather than unlink then add.

Can be set to a custom value in milliseconds:

```javascript
atomic: 100  // Custom atomicity delay
```

## Advanced Usage Patterns

### Watching Multiple Patterns

```javascript
const watcher = chokidar.watch(['src/**/*.js', 'test/**/*.js'], {
  ignored: /(^|[\/\\])\../,  // ignore dotfiles
  persistent: true
});
```

### Handling Large Files

For large files that are written in chunks:

```javascript
const watcher = chokidar.watch('large-files/', {
  awaitWriteFinish: {
    stabilityThreshold: 2000,
    pollInterval: 100
  }
});
```

### Network File Watching

To successfully watch files over a network, it is typically necessary to set usePolling to true:

```javascript
const watcher = chokidar.watch('network-path/', {
  usePolling: true,
  interval: 100
});
```

### Dynamic Path Management

```javascript
const watcher = chokidar.watch([], {
  persistent: true
});

// Add paths dynamically
watcher.add('file1.js');
watcher.add(['file2.js', 'file3.js']);

// Remove paths dynamically
await watcher.unwatch('file1.js');

// Get currently watched paths
const watched = watcher.getWatched();
```

## Command Line Interface

A third-party chokidar-cli package is available, which allows executing a command on each change or getting a stdio stream of change events.

### Installation

```bash
npm install chokidar-cli
```

### Basic Usage

By default, chokidar streams changes for all patterns to stdout with format event:relativepath:

```bash
chokidar "**/*.js" "**/*.less"
```

Output format: `event:relativepath`

Possible events are: add, unlink, addDir, unlinkDir, and change.

### Command Execution

The -c option allows running a command after each change, with {path} and {event} placeholders available:

```bash
chokidar "**/*.js" -c "npm test"
```

### CLI Options

Key options include -d for debounce timeout (default 400ms), -t for throttle timeout (default 0), -s for following symlinks, -i for ignoring patterns, --initial to run command initially, and -p for polling mode.

```bash
chokidar "**/*.js" -c "npm test" -d 1000 --initial
```

## Version History and Changes

### Version 5.0 (November 2024)

Version 5 makes the package ESM-only and increases the minimum Node.js requirement to version 20.

### Version 4.0 (September 2024)

Version 4 decreased dependency count from 13 to 1, removed support for globs, added support for ESM and CommonJS modules, and bumped the minimum Node.js version from v8 to v14.

### Migrating from v3 to v4

If you used globs in version 3, you can replicate the functionality in version 4:

```javascript
// v3 approach
chok.watch('**/*.js');

// v4 approach with ignored option
chok.watch('.', {
  ignored: (path, stats) => stats?.isFile() && !path.endsWith('.js')
});

// v4 approach with node:fs/promises
import { glob } from 'node:fs/promises';
const watcher = watch(await Array.fromAsync(glob('**/*.js')));
```

### Version 3.0 (April 2019)

Version 3 brought massive CPU and RAM consumption improvements, reduced dependencies and package size by a factor of 17x, and bumped the Node.js requirement to v8.16+.

### Earlier Versions

- Version 2 (December 2017): Made globs POSIX-style-only with numerous bug fixes
- Version 1 (April 2015): Added glob support, symlink support, and many bug fixes (Node 0.8+ supported)
- Version 0.1 (April 2012): Initial release, extracted from Brunch

## Adoption and Real-World Usage

Chokidar is used in Microsoft's Visual Studio Code, gulp, karma, PM2, browserify, webpack, BrowserSync, and many other tools.

The library is used in approximately 30 million repositories and has proven itself in production environments over more than a decade.

## Troubleshooting

### File Handle Exhaustion

Chokidar can run out of file handles, causing EMFILE and ENOSP errors. This can be caused by two issues:

1. **Exhausted file handles for generic fs operations**

Can be addressed by using the graceful-fs package:

```javascript
let fs = require('fs');
let grfs = require('graceful-fs');
grfs.gracefulify(fs);
```

Or by adjusting OS settings:

```bash
echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p
```

2. **Exhausted file handles for fs.watch**

[Inference: This cannot be solved by graceful-fs or OS tuning based on the documentation]

The solution is to use polling mode:

```javascript
const watcher = chokidar.watch('path/', {
  usePolling: true
});
```

[Unverified: Note that this will increase resource usage]

### FSEvents Issues

All fsevents-related issues (such as "WARN optional dep failed" or "fsevents is not a constructor") are resolved by upgrading to v4+.

## Best Practices

### Resource Management

- Only watch directories that you need to monitor
- Use the `depth` option to limit recursive watching
- Use `ignored` patterns to exclude unnecessary files
- Always call `close()` when done watching to free resources

### Performance Optimization

- Keep `usePolling: false` unless necessary (network drives, specific edge cases)
- Use `awaitWriteFinish` only when dealing with large files that are written in chunks
- Consider using `ignoreInitial: true` if you don't need initial scan events
- Set appropriate `interval` and `binaryInterval` values based on your use case

### Error Handling

Always add an error handler to prevent unhandled exceptions:

```javascript
watcher.on('error', (error) => {
  console.error('Watcher error:', error);
});
```

### Cleanup

Always close watchers when they're no longer needed:

```javascript
// Use async/await
await watcher.close();

// Or use promises
watcher.close().then(() => {
  console.log('Watcher closed successfully');
});
```

## License

Chokidar is released under the MIT license and is maintained by Paul Miller.