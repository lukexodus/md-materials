# Comprehensive Guide to Nodemon

Nodemon is a development utility for Node.js that automatically restarts your application when it detects file changes in the directory. It is a drop-in replacement for the `node` command during development, requiring no changes to your application code.

---

## Installation

### Local (recommended)

```bash
npm install --save-dev nodemon
```

Run via npm scripts or `npx`:

```bash
npx nodemon app.js
```

### Global

```bash
npm install -g nodemon
nodemon app.js
```

---

## Basic Usage

```bash
# Instead of: node app.js
nodemon app.js

# Nodemon infers the entry point from package.json "main" if no file is given
nodemon

# Pass arguments to your script
nodemon app.js --port 3000

# Specify a non-JS runtime
nodemon --exec "python3" script.py
nodemon --exec "ts-node" src/index.ts
```

---

## How It Works

Nodemon uses `fs.watch` / `fs.watchFile` / `inotify` (depending on the platform) to monitor files. When a change is detected in a watched file matching the configured extensions and paths, nodemon sends `SIGTERM` to the running process, waits for it to exit, then restarts it.

The watch is recursive by default within the current working directory.

---

## Configuration

Nodemon can be configured in three places, applied in this priority order (highest to lowest):

1. Command-line flags
2. `nodemon.json` (or `nodemon.local.json` for local overrides)
3. `"nodemonConfig"` key in `package.json`

### nodemon.json

Create a `nodemon.json` file in the project root:

```json
{
  "watch": ["src", "config"],
  "ext": "js,json,env",
  "ignore": ["src/**/*.test.js", "node_modules"],
  "exec": "node src/index.js",
  "env": {
    "NODE_ENV": "development",
    "PORT": "3000"
  },
  "delay": 500,
  "verbose": false,
  "restartable": "rs",
  "signal": "SIGTERM"
}
```

### package.json

```json
{
  "scripts": {
    "dev": "nodemon"
  },
  "nodemonConfig": {
    "watch": ["src"],
    "ext": "js,json",
    "ignore": ["**/*.test.js"],
    "exec": "node src/index.js",
    "delay": 300
  }
}
```

### nodemon.local.json

A `nodemon.local.json` file in the same directory as `nodemon.json` overrides it. Add `nodemon.local.json` to `.gitignore` for per-developer settings that should not be committed.

---

## Configuration Options

### watch

Directories or files to watch. Accepts glob patterns. Defaults to the current working directory.

```json
{
  "watch": ["src", "config", "*.env"]
}
```

```bash
nodemon --watch src --watch config app.js
```

### ext

Comma-separated list of file extensions to watch. Defaults to `js,mjs,cjs,json`.

```json
{
  "ext": "js,ts,json,graphql,env"
}
```

```bash
nodemon --ext js,ts,json
```

### ignore

Files, directories, or glob patterns to exclude from watching. `node_modules` is always ignored by default.

```json
{
  "ignore": [
    "**/*.test.js",
    "**/*.spec.js",
    "src/generated/**",
    "logs/**",
    ".git"
  ]
}
```

```bash
nodemon --ignore "**/*.test.js" --ignore logs/
```

### exec

The command to run instead of `node`. Useful for TypeScript, Python, Babel, or any other runtime.

```json
{
  "exec": "node --require dotenv/config src/index.js"
}
```

```bash
nodemon --exec "ts-node --transpile-only" src/index.ts
```

### delay

Milliseconds to wait after a file change before restarting. Useful when build tools write many files in sequence.

```json
{
  "delay": 1000
}
```

```bash
nodemon --delay 1000 app.js
# or with a time suffix
nodemon --delay 1s app.js
nodemon --delay 2500ms app.js
```

### signal

The signal sent to the process on restart. Defaults to `SIGTERM`. Use `SIGUSR2` for apps that handle custom restart logic (e.g., some cluster setups).

```json
{
  "signal": "SIGTERM"
}
```

### restartable

The keyboard string that triggers a manual restart when typed in the terminal. Defaults to `rs`.

```json
{
  "restartable": "rs"
}
```

### verbose

Logs detailed information about which files triggered a restart.

```json
{
  "verbose": true
}
```

```bash
nodemon --verbose app.js
```

### stdin

Set to `false` to prevent nodemon from reading stdin (useful in some CI or piped environments).

```json
{
  "stdin": false
}
```

### colours

Set to `false` to disable colored output.

```json
{
  "colours": false
}
```

### legacyWatch

Falls back to polling instead of native file system events. Useful inside Docker, WSL, or network file systems where native events may not fire.

```json
{
  "legacyWatch": true
}
```

```bash
nodemon --legacy-watch app.js
```

### pollingInterval

Interval in milliseconds for polling mode (used with `legacyWatch`).

```json
{
  "legacyWatch": true,
  "pollingInterval": 1000
}
```

---

## npm Scripts

The most common pattern is to define a `dev` script in `package.json`:

```json
{
  "scripts": {
    "start": "node src/index.js",
    "dev": "nodemon src/index.js",
    "dev:debug": "nodemon --inspect src/index.js"
  }
}
```

Run with:

```bash
npm run dev
```

---

## TypeScript

### With ts-node

```bash
npm install --save-dev ts-node typescript
```

```json
{
  "exec": "ts-node src/index.ts",
  "ext": "ts,json",
  "watch": ["src"]
}
```

```bash
nodemon --exec ts-node src/index.ts
```

### With ts-node and transpile-only (faster, skips type checking)

```json
{
  "exec": "ts-node --transpile-only src/index.ts",
  "ext": "ts,json"
}
```

### With tsx (modern ts-node alternative)

```bash
npm install --save-dev tsx
```

```json
{
  "exec": "tsx src/index.ts",
  "ext": "ts,json"
}
```

---

## Debugging

### Node.js Inspector

```bash
nodemon --inspect app.js
# or for breaking on the first line
nodemon --inspect-brk app.js
```

Then open `chrome://inspect` in Chrome, or attach VS Code's debugger.

### VS Code Launch Configuration

Add to `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "attach",
      "name": "Attach to Nodemon",
      "port": 9229,
      "restart": true,
      "protocol": "inspector"
    }
  ]
}
```

Start nodemon with `--inspect`, then use the "Attach to Nodemon" configuration in VS Code. The `"restart": true` setting causes VS Code to re-attach automatically after each restart.

---

## Environment Variables

### Via nodemon.json

```json
{
  "env": {
    "NODE_ENV": "development",
    "PORT": "3000",
    "DEBUG": "app:*"
  }
}
```

### Via dotenv

Load `.env` automatically by passing `--require` to the exec command:

```json
{
  "exec": "node --require dotenv/config src/index.js"
}
```

Or with `dotenv-cli`:

```bash
npm install --save-dev dotenv-cli
```

```json
{
  "exec": "dotenv -- node src/index.js"
}
```

---

## Watching Non-Default Extensions

### Watching GraphQL, YAML, and .env Files

```json
{
  "ext": "js,json,graphql,yml,yaml,env",
  "watch": ["src", "config", ".env"]
}
```

### Watching a Specific File

```json
{
  "watch": ["src", "config/settings.json"]
}
```

---

## Using with Docker

Inside Docker, `inotify` events from bind-mounted volumes may not propagate correctly, particularly on macOS and Windows hosts. Use polling mode:

```json
{
  "legacyWatch": true,
  "pollingInterval": 1000
}
```

Or pass the flag:

```bash
nodemon --legacy-watch app.js
```

A typical `docker-compose.yml` for a Node.js dev environment:

```yaml
services:
  app:
    build: .
    volumes:
      - .:/app
      - /app/node_modules
    ports:
      - "3000:3000"
    command: npx nodemon --legacy-watch src/index.js
    environment:
      - NODE_ENV=development
```

---

## Graceful Shutdown and Signal Handling

Nodemon sends `SIGTERM` before restarting. Applications should listen for it and clean up (close database connections, finish in-flight requests, etc.):

```javascript
process.on('SIGTERM', async () => {
  console.log('SIGTERM received, shutting down...');
  await db.close();
  server.close(() => {
    console.log('Server closed');
    process.exit(0);
  });
});
```

If your app uses `SIGUSR2` for its own restart logic (e.g., some PM2 or cluster setups), configure nodemon to use a different signal:

```json
{
  "signal": "SIGUSR2"
}
```

---

## Manual Restart

While nodemon is running, type `rs` (or the value of `restartable`) and press Enter to trigger a manual restart without changing any files:

```
nodemon> rs
```

---

## Trigger Restart on Demand (Programmatic)

You can trigger a restart by touching a watched file:

```bash
touch src/index.js
```

Or by sending the signal directly to nodemon's process:

```bash
kill -SIGUSR2 $(cat nodemon.pid)
```

---

## Programmatic API

Nodemon exposes a programmatic API for use inside Node.js scripts or build tools:

```javascript
const nodemon = require('nodemon');

nodemon({
  script: 'src/index.js',
  ext: 'js,json',
  watch: ['src'],
  ignore: ['**/*.test.js'],
  env: { NODE_ENV: 'development' },
});

nodemon
  .on('start', () => {
    console.log('App started');
  })
  .on('restart', (files) => {
    console.log('Restarted due to:', files);
  })
  .on('crash', () => {
    console.error('App crashed');
  })
  .on('exit', () => {
    console.log('App exited cleanly');
  })
  .on('quit', () => {
    console.log('Nodemon exited');
    process.exit(0);
  });

// Trigger a restart programmatically
nodemon.restart();

// Stop nodemon
nodemon.emit('quit');
```

### Programmatic Config from File

```javascript
nodemon({
  ...require('./nodemon.json'),
  script: 'src/index.js',
});
```

---

## Common Patterns

### Express App

```json
{
  "watch": ["src"],
  "ext": "js,json",
  "ignore": ["**/*.test.js"],
  "exec": "node src/app.js",
  "env": {
    "NODE_ENV": "development",
    "PORT": "3000"
  }
}
```

### NestJS

```json
{
  "watch": ["src"],
  "ext": "ts",
  "exec": "ts-node -r tsconfig-paths/register src/main.ts",
  "ignore": ["src/**/*.spec.ts"]
}
```

NestJS projects created with the CLI already configure nodemon (or its successor scripts) in the generated `package.json`. Check whether `@nestjs/cli` watch mode (`nest start --watch`) already handles your use case before adding nodemon separately.

### Next.js / Remix

These frameworks have their own file-watching dev servers (`next dev`, `remix dev`). Nodemon is generally not used for the frontend; it is only relevant for custom server files or API routes running outside the framework's dev server.

### Running Multiple Processes

Use `concurrently` or `npm-run-all` alongside nodemon:

```json
{
  "scripts": {
    "dev:server": "nodemon src/server.js",
    "dev:worker": "nodemon src/worker.js",
    "dev": "concurrently \"npm run dev:server\" \"npm run dev:worker\""
  }
}
```

---

## Troubleshooting

### Nodemon Does Not Restart on File Change

- Verify the changed file's extension is in `ext`.
- Verify the file's path is within a `watch` directory and not in `ignore`.
- On Docker/WSL/network drives, enable `legacyWatch`.
- Run with `--verbose` to see which files are being watched and which changes are detected.

### Too Many Restarts / Restart Loop

- The app may be writing to a watched file on startup (e.g., log files, generated files). Add those paths to `ignore`.
- Increase `delay` to debounce rapid successive writes.

### App Crashes Immediately and Nodemon Keeps Restarting

Nodemon restarts after a crash. If the app crashes due to a syntax error or misconfiguration, fix the underlying error. You can also limit restart attempts with a wrapper script, though nodemon itself does not have a built-in crash limit for development use.

### Port Already in Use After Restart

The previous process did not exit before the new one started. Check that your app handles `SIGTERM` and closes the server properly (see Graceful Shutdown above). You can also increase nodemon's kill timeout:

```bash
nodemon --signal SIGTERM app.js
```

### Watching .env File Changes

`.env` is not a default extension. Add it explicitly:

```json
{
  "ext": "js,json,env",
  "watch": ["src", ".env"]
}
```

---

## CLI Flags Reference

|Flag|Description|
|---|---|
|`--watch <path>`|Directory or file to watch (repeatable)|
|`--ext <list>`|Comma-separated file extensions|
|`--ignore <pattern>`|Files/dirs/globs to ignore (repeatable)|
|`--exec <cmd>`|Command to run instead of `node`|
|`--delay <ms>`|Delay before restart after a change|
|`--signal <signal>`|Signal sent on restart (`SIGTERM`, etc.)|
|`--inspect`|Enable Node.js inspector|
|`--inspect-brk`|Break on first line with inspector|
|`--verbose`|Log detailed watch information|
|`--quiet`|Minimize output|
|`--legacy-watch`|Use polling instead of native FS events|
|`--no-stdin`|Disable stdin reading|
|`--config <file>`|Path to a custom config file|
|`--no-colors`|Disable colored output|
|`--version`|Print nodemon version|
|`--help`|Print help|

---

## Quick Reference

### Minimal nodemon.json

```json
{
  "watch": ["src"],
  "ext": "js,json",
  "ignore": ["**/*.test.js"],
  "exec": "node src/index.js"
}
```

### TypeScript nodemon.json

```json
{
  "watch": ["src"],
  "ext": "ts,json",
  "ignore": ["**/*.spec.ts"],
  "exec": "ts-node --transpile-only src/index.ts"
}
```

### Docker nodemon.json

```json
{
  "watch": ["src"],
  "ext": "js,json",
  "legacyWatch": true,
  "pollingInterval": 1000,
  "exec": "node src/index.js"
}
```