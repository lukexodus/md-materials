## Vite: A Complete Production-Level Guide

---

### Part I: Foundations

---

#### What Vite Is

Vite (French for "fast", pronounced `/veet/`) is a **frontend build tool and development server**. It does two jobs:

1. **During development**: serves your source files directly to the browser with almost no pre-processing delay, using the browser's own native module system.
2. **During production builds**: bundles your code into optimized static assets using Rollup under the hood.

A "build tool" occupies a specific layer in web development infrastructure. Your source code — TypeScript, JSX, CSS modules, `.vue` files — cannot run directly in a browser without transformation. Something has to convert it. Vite is that something, but it approaches the job differently from every tool that came before it.

#### Why Vite Exists: The Problem It Solves

To understand Vite's value, you have to understand the problem that had gone unsolved since roughly 2015.

**The era of the JavaScript bundler** began when web applications became complex enough to need many files, modules, and third-party dependencies organized together. Webpack, Browserify, and later Rollup were built to solve this: they read your source files, trace every `import`, and stitch everything into one or a few output files the browser can execute.

This model worked well when applications were small. As applications grew to thousands of modules, however, a serious problem emerged: **every change required re-bundling the entire application** before you could see it in the browser. Developers on large React or Vue apps were routinely waiting 30–60 seconds or more just to see the result of changing one line of CSS. Cold starts — how long it took for the dev server to be ready after running `npm run dev` — stretched into minutes.

This is the specific pain Vite was designed to eliminate. Vite's creator, Evan You (also the creator of Vue), framed the goal clearly: the development experience should remain fast regardless of how large your application grows.

#### How the Web Got Here: A Brief History

Understanding the evolution of frontend tooling explains why each tradeoff Vite makes is the right one for today.

**2010–2014: The pre-module era.** JavaScript had no standard module system. Developers concatenated files manually or used AMD (Asynchronous Module Definition) with `require.js`. Build steps were minimal — maybe a concatenation and a minification pass with Grunt or Gulp.

**2015–2017: CommonJS and webpack.** Node.js had popularized `require()` and `module.exports` (CommonJS), and webpack brought that module model to the browser. Webpack could handle everything: JavaScript, CSS, images, fonts. It became the universal answer to frontend builds. The tradeoff was complexity and speed: webpack's configuration was notoriously difficult, and its development server rebuilt everything on every change.

**2017: Native ES Modules land in browsers.** The ECMAScript specification formalized a module system (`import`/`export`), and browsers started supporting it natively. Chrome shipped it in 2017. Firefox and Safari followed. This was the technical foundation Vite would eventually exploit — but at the time, the tooling ecosystem had not caught up.

**2019–2020: The snowpack moment.** Snowpack was the first tool to ask the question: *now that browsers support native modules, why are we still bundling during development?* Snowpack served files unbundled to the browser. It was fast. It proved the concept. But it had limitations: its production builds used different tools than its dev server, creating subtle inconsistency bugs, and its ecosystem was never as mature as webpack's.

**2020: Vite 1.0.** Evan You built on the Snowpack idea but solved its problems. He used esbuild (a Go-based bundler) for dependency pre-bundling to handle the edge cases native ESM alone couldn't, and Rollup for production builds (which the ecosystem already trusted). Vite unified these under one coherent, well-designed API.

**2021–present: Vite becomes the standard.** Framework after framework — Vue, React (via create-react-app replacements), Svelte, SolidJS, Qwik, Astro, Nuxt, Remix, SvelteKit — either adopted Vite or built on it. It is now the default recommendation for new projects across virtually every frontend framework.

#### How the Old Approach Worked (and Why It Was Slow)

Webpack's development workflow looks like this:

```
Source files (all of them)
    → webpack traverses every import in every file
    → transforms each file (Babel for JS, css-loader for CSS, etc.)
    → bundles everything into one or more in-memory JS files
    → serves the bundle to the browser
    → on any change: repeat from the beginning (or from a cache)
```

The key bottleneck: **the entire module graph must be processed before the browser receives anything**. With 3,000 modules and Babel transform overhead, that's inherently slow. Webpack Hot Module Replacement (HMR) improved things by only re-bundling changed files and their dependents, but the bundle graph walking and rebundling overhead remained. Large apps still had 5–15 second HMR times.

#### How Vite Thinks Differently

Vite separates the development problem into two distinct categories:

1. **Dependencies**: packages from `node_modules` that rarely change (React, lodash, etc.)
2. **Source code**: your own files that change constantly

For **dependencies**, Vite runs a one-time pre-bundling step using esbuild (extremely fast — 10–100x faster than Babel/webpack for this task). The output is cached. This step handles two things:
- CommonJS or UMD packages are converted to ESM so the browser can use them natively.
- Packages with many internal files (like lodash-es with 600+ modules) are consolidated into single files, preventing hundreds of individual HTTP requests.

For **source code**, Vite does almost nothing upfront. It starts a development server immediately and only transforms files **when the browser requests them**. This is called **on-demand transformation** or **just-in-time serving**.

```
Browser requests /src/App.tsx
    → Vite transforms only that file (esbuild handles JSX/TS)
    → Returns the result instantly
    → Browser sees an import, requests the next file
    → Vite transforms only that file
    → ... and so on
```

The browser itself becomes the module graph traversal engine. Vite's dev server is essentially a transformer middleware sitting between the browser and your filesystem.

This means **cold start time is near-constant regardless of app size**. Vite doesn't need to process files you haven't visited yet.

---

### Part II: Core Concepts

---

#### Native ES Modules (ESM)

**What they are**: A standardized module system built into browsers. Files declare their dependencies with `import` statements and their exports with `export` statements. The browser fetches each imported file via HTTP as a separate request.

**Why this matters for Vite**: Because ESM is built into browsers natively, Vite doesn't need to bundle your source files during development. The browser handles the dependency loading. Vite just needs to intercept requests, transform files as needed (TypeScript → JavaScript, JSX → JavaScript), and return them.

**What ESM looks like**:
```javascript
// utils.js
export function add(a, b) { return a + b; }

// main.js
import { add } from './utils.js';
console.log(add(2, 3));
```

With a `<script type="module" src="./main.js">` tag, a browser will:
1. Fetch `main.js`
2. Parse it, discover the import
3. Fetch `utils.js`
4. Execute both in the correct order

Vite intercepts step 1 and 2: when the browser requests `main.js`, Vite transforms it (e.g. strips TypeScript types, converts JSX) and returns valid JavaScript. The browser does the rest.

**ESM URL rewriting**: Source imports often look like:
```javascript
import React from 'react';
```

A bare specifier like `'react'` is not a valid browser URL. Vite rewrites it to something like:
```javascript
import React from '/node_modules/.vite/deps/react.js';
```
...pointing to the pre-bundled dependency in its cache. This rewriting happens transparently.

#### Dependency Pre-Bundling

**What it is**: A one-time processing step Vite runs when you first start the dev server (or when dependencies change). It uses **esbuild** to transform and consolidate packages from `node_modules`.

**Why it exists**:
1. Many npm packages are written in CommonJS (`require`/`module.exports`). Browsers understand ESM only. Pre-bundling converts them.
2. Some packages like `lodash-es` export hundreds of small files. If the browser had to fetch each separately, a single import could trigger 600 HTTP requests. Pre-bundling merges them into one file.

**Where the output goes**: `.vite/deps/` inside your project's cache directory (usually `node_modules/.vite/`). These files are served with strong cache headers so the browser doesn't re-request them on every page refresh.

**When it re-runs**: Vite detects changes to `package.json`, `package-lock.json`, `yarn.lock`, or `pnpm-lock.yaml`. It also re-runs if you add a new dependency import during development (Vite detects the new bare specifier and automatically re-bundles).

**esbuild's role here**: esbuild is written in Go and runs at native speed. For the pre-bundling task — which is pure transpilation and bundling with no HMR or watch logic — esbuild is 10–100x faster than JavaScript-based alternatives.

#### The Module Graph

**What it is**: An internal data structure Vite maintains mapping every module (file) to its imports and exports. It is essentially a directed graph where nodes are files and edges are `import` relationships.

**Why it matters**: The module graph is what makes HMR precise. When you change a file, Vite looks at the graph to determine:
- What imported that file (its "importers")
- Whether those importers can accept the update themselves or need to bubble it up further
- Whether the update boundary has been crossed (meaning a full page reload is needed)

During development, the module graph is built lazily — only files the browser has actually requested are in the graph. This is another reason Vite's cold start is fast: the graph starts empty.

#### Hot Module Replacement (HMR)

**What it is**: The ability to push updates to a running browser without a full page reload, preserving application state.

**How it works step by step**:
1. You change `Button.tsx` and save.
2. Vite's file watcher (using `chokidar` under the hood) detects the change.
3. Vite invalidates `Button.tsx` in the module graph — marks it as stale.
4. Vite sends a WebSocket message to the browser: "module `/src/Button.tsx` has been updated."
5. The browser receives the message and calls the HMR API to fetch the new version of `Button.tsx`.
6. The framework plugin's HMR handler (e.g. `@vitejs/plugin-react`) accepts the update and re-renders only the affected components without clearing React state.

**The HMR boundary**: This is a key concept. A module is an "HMR boundary" if it can accept an update to itself or its dependencies without that update needing to propagate further up the import chain. React and Vue components are typical HMR boundaries — when a component's code changes, its framework plugin handles the update locally. If Vite can't find a boundary (e.g. a utility function imported by many things), it falls back to a full page reload.

**Fast Refresh vs plain HMR**: React Fast Refresh (used by `@vitejs/plugin-react`) is a more sophisticated form of HMR that preserves component state more reliably than generic HMR. It hooks into React's reconciler to re-run only the changed component's render logic while keeping other state intact.

#### File Watching

Vite uses **chokidar**, a cross-platform filesystem watcher. On Linux, chokidar uses the native `inotify` API. On macOS, it uses `FSEvents`. On Windows, it uses `ReadDirectoryChangesW`.

By default, Vite watches everything in your project root except `node_modules` and `.git`. You can configure `server.watch` in `vite.config.*` to customize which paths are watched, ignore patterns, or use polling (for environments where filesystem events don't work, like Docker with bind mounts).

#### Browser and Server Interaction During Development

Here is the complete picture of what happens when you run `vite` and open your browser:

1. **Server starts**: Vite starts an HTTP server (default: `localhost:5173`) and a WebSocket server on the same port.
2. **Browser requests `index.html`**: Vite serves `index.html` directly. It injects a small client script (`/@vite/client`) that establishes the WebSocket connection and handles HMR messages.
3. **Browser parses `index.html`**: It finds a `<script type="module" src="/src/main.tsx">` tag and requests it.
4. **Vite transforms `main.tsx`**: Strips TypeScript types, transforms JSX, rewrites imports, and returns valid JavaScript.
5. **Browser processes imports**: For each import in `main.tsx`, the browser makes another HTTP request to Vite.
6. **Vite transforms each file on demand**: CSS files return JS that injects a style tag. Vue/Svelte single-file components are split into their JS and CSS parts. Each is transformed and returned.
7. **Dependency imports resolve from cache**: `import React from 'react'` resolves to the pre-bundled file in `.vite/deps/`.
8. **HMR connection stays open**: The WebSocket connection remains open. On file changes, Vite sends invalidation messages and the browser fetches new versions of changed modules only.

---

### Part III: Project Setup

---

#### Creating a Vite Project

The canonical way to scaffold a new Vite project:

```bash
npm create vite@latest my-app
# or
pnpm create vite my-app
# or
yarn create vite my-app
# or
bun create vite my-app
```

This runs the `create-vite` scaffolding tool, which prompts for:
- Framework (Vanilla, Vue, React, Preact, Lit, Svelte, Solid, Qwik, Angular, Others)
- Variant (JavaScript or TypeScript, often with SWC options)

You can also skip prompts with template flags:
```bash
npm create vite@latest my-app -- --template react-ts
```

Available template names: `vanilla`, `vanilla-ts`, `vue`, `vue-ts`, `react`, `react-ts`, `react-swc`, `react-swc-ts`, `preact`, `preact-ts`, `lit`, `lit-ts`, `svelte`, `svelte-ts`, `solid`, `solid-ts`, `qwik`, `qwik-ts`.

#### Project Structure

A scaffolded React + TypeScript project looks like:

```
my-app/
├── public/                  # Static assets (not processed by Vite)
│   └── vite.svg
├── src/                     # Your source code
│   ├── assets/              # Assets imported in source (processed by Vite)
│   │   └── react.svg
│   ├── App.css
│   ├── App.tsx
│   ├── index.css
│   ├── main.tsx             # Entry point
│   └── vite-env.d.ts        # TypeScript ambient type declarations for Vite
├── index.html               # Root HTML (not inside src/ — this is intentional)
├── package.json
├── tsconfig.json
├── tsconfig.node.json       # TypeScript config for the Vite config file itself
└── vite.config.ts
```

**Why `index.html` is at the root**: In Vite, `index.html` is the entry point. Unlike webpack where you specify a JS entry in config, Vite treats `index.html` as the document that imports your JS. The `<script type="module" src="/src/main.tsx">` in `index.html` is the actual entry. This means `index.html` is a first-class citizen of your project, not a generated artifact.

**`vite-env.d.ts`**: This file contains:
```typescript
/// <reference types="vite/client" />
```
This single line makes TypeScript aware of Vite-specific types:
- `import.meta.env` (environment variables with proper types)
- `import.meta.hot` (the HMR API)
- Static asset imports (e.g. `import logo from './logo.svg'` returning a `string`)

#### Package Manager Integration

Vite works with npm, yarn, pnpm, and bun. There is no meaningful difference in functionality between them. The most notable consideration is **workspace support**: if you're in a monorepo using pnpm workspaces or yarn workspaces, pnpm is often preferred because its strict symlinking behavior (packages cannot accidentally access undeclared dependencies) catches real bugs earlier.

**Scripts in `package.json`**:
```json
{
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "typecheck": "tsc --noEmit"
  }
}
```

- `vite`: starts the development server
- `vite build`: produces optimized production assets in `dist/`
- `vite preview`: serves the `dist/` folder locally to verify the production build
- `tsc --noEmit`: type-checks without emitting files (Vite handles transpilation; TypeScript just validates types)

#### TypeScript Integration

**The critical distinction**: Vite does **not** use the TypeScript compiler (`tsc`) to transform your code during development or build. It uses **esbuild** to strip TypeScript types — which is a purely mechanical operation (no type checking, just removal of `: string` annotations and similar syntax).

This means:
- Type errors do **not** stop your build or prevent hot reload. You can run code with type errors in development.
- Type checking must be done separately via `tsc --noEmit` or a plugin like `vite-plugin-checker`.

**Why this design**:
- esbuild's TypeScript stripping is ~20–100x faster than `tsc`'s full compilation pipeline.
- Type checking is CPU-intensive and doesn't need to block the development server. Most teams run `tsc` in a separate terminal or in CI.

**`tsconfig.json` for Vite projects**:
```json
{
  "compilerOptions": {
    "target": "ESNext",
    "useDefineForClassFields": true,
    "lib": ["DOM", "DOM.Iterable", "ESNext"],
    "module": "ESNext",
    "skipLibCheck": true,
    "moduleResolution": "bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    "jsx": "react-jsx",
    "strict": true
  },
  "include": ["src"],
  "references": [{ "path": "./tsconfig.node.json" }]
}
```

The key settings:
- `"module": "ESNext"` — keeps imports as-is for Vite to process
- `"moduleResolution": "bundler"` — uses bundler-specific resolution rules (available in TS 5.0+, matches how Vite resolves modules)
- `"isolatedModules": true` — ensures every file can be transpiled independently, which matches how esbuild works (it transforms files one at a time without cross-file type information)
- `"noEmit": true` — TypeScript only checks, never outputs files (Vite does the actual outputting)

**`tsconfig.node.json`** covers the `vite.config.ts` file itself, which runs in Node.js, not the browser. It typically uses `"module": "ESNext"` and `"moduleResolution": "bundler"` as well.

---

### Part IV: Vite Configuration

---

#### The Configuration File

Vite looks for a config file in this order:
- `vite.config.js`
- `vite.config.mjs`
- `vite.config.ts`
- `vite.config.cjs`

The config file is loaded by Vite's own Node.js process. With TypeScript, Vite can process the config file directly using esbuild, so `vite.config.ts` works without additional setup.

**Basic shape**:
```typescript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import path from 'path'

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
    },
  },
  server: {
    port: 3000,
    open: true,
  },
  build: {
    outDir: 'dist',
    sourcemap: true,
  },
})
```

`defineConfig` is a no-op identity function that provides TypeScript IntelliSense. You don't need it for the config to work, but without it, your editor won't autocomplete configuration options.

**Conditional configuration** (different behavior per mode):
```typescript
import { defineConfig, type ConfigEnv } from 'vite'

export default defineConfig(({ command, mode }: ConfigEnv) => {
  // command = 'serve' | 'build'
  // mode = 'development' | 'production' (or custom)
  if (command === 'serve') {
    return { /* dev-only config */ }
  } else {
    return { /* build-only config */ }
  }
})
```

#### Plugins

**What a plugin is**: A plain JavaScript object (with specific shape) that hooks into Vite's processing pipeline. Plugins can transform files, inject code, intercept requests, modify HTML, and more.

**Plugin shape**:
```typescript
{
  name: 'my-plugin',                    // required, for error messages
  // Vite-specific hooks
  config(config, env) {},               // modify resolved config
  configResolved(config) {},            // called with final resolved config
  configureServer(server) {},           // configure dev server
  transformIndexHtml(html) {},          // transform index.html
  handleHotUpdate(ctx) {},              // custom HMR handling
  // Rollup-compatible hooks (also work in Vite)
  resolveId(source, importer) {},       // custom module resolution
  load(id) {},                          // load a module
  transform(code, id) {},               // transform a module's code
}
```

Plugins are applied in array order. By default, they run on both dev and build. You can restrict with `apply`:
```typescript
{
  name: 'my-build-only-plugin',
  apply: 'build',
  // ...
}
```

#### Path Aliases

**Problem**: Deep relative imports like `import Button from '../../../../components/Button'` break when files move.

**Solution**:
```typescript
// vite.config.ts
import path from 'path'

export default defineConfig({
  resolve: {
    alias: {
      '@': path.resolve(__dirname, './src'),
      '@components': path.resolve(__dirname, './src/components'),
      '@utils': path.resolve(__dirname, './src/utils'),
    },
  },
})
```

```typescript
// Now you can write:
import Button from '@/components/Button'
import { formatDate } from '@utils/date'
```

**Critical**: You must also add these aliases to `tsconfig.json` so TypeScript resolves them:
```json
{
  "compilerOptions": {
    "paths": {
      "@/*": ["./src/*"],
      "@components/*": ["./src/components/*"],
      "@utils/*": ["./src/utils/*"]
    }
  }
}
```
If you only add them to `vite.config.ts`, Vite will resolve them correctly at runtime but TypeScript will report "cannot find module" errors.

#### Resolve Options

```typescript
resolve: {
  alias: { /* ... */ },
  extensions: ['.mjs', '.js', '.ts', '.jsx', '.tsx', '.json'],  // file extensions to try
  conditions: ['browser', 'module', 'import'],                  // package.json exports conditions
  mainFields: ['browser', 'module', 'main'],                    // package.json fields to check
  dedupe: ['react', 'react-dom'],                               // force single copy of these packages
}
```

`dedupe` is important in monorepos or when using `npm link`. Without it, multiple copies of React can exist, causing "invalid hook call" and similar errors.

#### Define Options

`define` performs **static text replacement** at build time. It is not a runtime mechanism.

```typescript
define: {
  __APP_VERSION__: JSON.stringify('1.0.0'),
  __DEV__: command === 'serve',
  'process.env.NODE_ENV': JSON.stringify(mode),
}
```

```javascript
// In your source code:
console.log(__APP_VERSION__); // replaced with '1.0.0' before execution
if (__DEV__) { debugLog(); }  // entire block removed in production by minifier
```

`define` values are replaced literally in source code before the bundler runs. Always use `JSON.stringify` for strings, since the replacement is textual: without it, `__APP_VERSION__: '1.0.0'` would replace the token with `1.0.0` (an invalid identifier), not `'1.0.0'` (a string literal).

#### Server Configuration

```typescript
server: {
  port: 3000,                   // default: 5173
  host: '0.0.0.0',             // listen on all interfaces (needed for Docker/LAN)
  open: true,                   // open browser on start
  https: true,                  // enable HTTPS (auto-generates cert via @vitejs/plugin-basic-ssl or similar)
  cors: true,                   // enable CORS for dev server
  strictPort: true,             // fail if port is taken (instead of trying next port)
  
  proxy: {
    // Proxy API requests to a backend during development
    '/api': {
      target: 'http://localhost:8080',
      changeOrigin: true,
      rewrite: (path) => path.replace(/^\/api/, ''),
    },
  },
  
  watch: {
    usePolling: true,           // for Docker/WSL2 environments
    interval: 100,
  },
  
  fs: {
    // Allow serving files outside the project root
    allow: ['..'],
    // Deny specific paths
    deny: ['.env', '.env.*', '*.{pem,crt}'],
  },
}
```

**The proxy is one of Vite's most practically useful features** in full-stack development. Your React app runs on `localhost:3000`, your Express API on `localhost:8080`. Without a proxy, browser CORS restrictions block frontend requests to the API. With the proxy above, a request to `/api/users` from your frontend is proxied transparently to `http://localhost:8080/users`, with the response returned to the browser as if it came from `localhost:3000`.

#### Build Configuration

```typescript
build: {
  outDir: 'dist',                          // output directory
  assetsDir: 'assets',                     // subdirectory for assets within outDir
  assetsInlineLimit: 4096,                 // inline assets smaller than 4KB as base64
  cssCodeSplit: true,                      // split CSS per chunk (disable for single CSS file)
  sourcemap: true,                         // true | false | 'inline' | 'hidden'
  minify: 'esbuild',                       // 'esbuild' | 'terser' | false
  target: 'es2015',                        // browser targets for transpilation
  lib: {                                   // library mode (see Advanced Topics)
    entry: 'src/index.ts',
    name: 'MyLib',
    formats: ['es', 'cjs', 'umd'],
  },
  rollupOptions: {
    // Full Rollup config passthrough
    output: {
      manualChunks: {
        vendor: ['react', 'react-dom'],
      },
    },
    external: ['react', 'react-dom'],      // for library mode: don't bundle these
  },
  reportCompressedSize: true,              // show gzip sizes in output
  chunkSizeWarningLimit: 500,             // warn when chunks exceed this (in KB)
}
```

**`target`**: Controls what JavaScript syntax the output can use. `'es2015'` ensures IE-unfriendly syntax like optional chaining and nullish coalescing are compiled away. For modern browsers only, `'esnext'` produces smaller output. This uses esbuild's transpilation. Common choices: `'es2015'`, `'es2017'`, `'es2019'`, `'esnext'`.

**`sourcemap: 'hidden'`**: Generates sourcemap files but does not include the `//# sourceMappingURL` comment in the output JS. Useful when you upload sourcemaps to an error monitoring tool (like Sentry) but don't want them accessible from the browser.

#### Environment Variables

Vite's environment variable system uses `.env` files and `import.meta.env`.

**File loading order** (later files override earlier ones):
```
.env                          # loaded always
.env.local                    # loaded always, git-ignored
.env.[mode]                   # loaded in that mode only
.env.[mode].local             # loaded in that mode only, git-ignored
```

`mode` is `development` when running `vite`, `production` when running `vite build`. You can pass a custom mode with `--mode staging`.

**The `VITE_` prefix requirement**: Only variables prefixed with `VITE_` are exposed to client-side code via `import.meta.env`. Variables without the prefix are available in the Vite config but not in your application source. This is a security boundary.

```
# .env
DATABASE_URL=postgres://...          # NOT exposed to client (no VITE_ prefix)
VITE_API_BASE_URL=https://api.example.com  # exposed to client
VITE_FEATURE_FLAG_ANALYTICS=true
```

```typescript
// In your source code:
const apiUrl = import.meta.env.VITE_API_BASE_URL;
const isDev = import.meta.env.DEV;        // boolean, built-in
const isProd = import.meta.env.PROD;      // boolean, built-in
const mode = import.meta.env.MODE;        // 'development' | 'production' | custom
const base = import.meta.env.BASE_URL;    // the base URL (from config.base)
```

**Typing custom env variables**:
```typescript
// src/env.d.ts (or vite-env.d.ts)
/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_API_BASE_URL: string;
  readonly VITE_FEATURE_FLAG_ANALYTICS: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
```

**Security warning**: Everything in `import.meta.env.VITE_*` is embedded directly in your JavaScript bundle as plaintext. Never put secrets (API keys, private tokens) in `VITE_*` variables. They will be visible to anyone who downloads your app.

#### Preview Configuration

`vite preview` serves the production build from `dist/`. It's not a full production server but is useful for smoke-testing builds locally.

```typescript
preview: {
  port: 8080,
  host: true,
  strictPort: true,
  proxy: { /* same as server.proxy */ },
}
```

---

### Part V: Development Workflow

---

#### How Vite Handles a Request

When a browser requests `/src/components/Button.tsx`:

1. **Vite intercepts the request** via its Koa-based middleware stack.
2. **Plugin pipeline — `resolveId` hooks**: Each plugin gets a chance to resolve the module ID to a file path. Default resolution uses Node.js module resolution + `resolve.alias`.
3. **Plugin pipeline — `load` hooks**: Each plugin gets a chance to provide the module's source code. Usually this reads the file from disk.
4. **Plugin pipeline — `transform` hooks**: Each plugin can transform the source code. The React plugin transforms JSX. The TypeScript handling is built into Vite (via esbuild). CSS modules plugin transforms CSS. Transforms run in plugin order.
5. **Import rewriting**: Vite rewrites bare specifier imports (`'react'`) to absolute paths (`'/node_modules/.vite/deps/react.js'`).
6. **Response**: The transformed JavaScript is sent back to the browser with appropriate cache headers.
7. **Module graph update**: Vite adds the module to its internal graph, recording what it imports.

#### How Code Changes Propagate

1. File saved → chokidar fires a change event.
2. Vite invalidates the module in its graph (marks it dirty) and all modules that imported it (recursively, up to an HMR boundary).
3. Vite sends a WebSocket message to the browser.
4. **If an HMR boundary handles the update**: The browser fetches only the changed modules, the framework plugin re-renders affected components, state is preserved.
5. **If no HMR boundary is found**: Vite sends a `full-reload` message, the browser does a hard refresh.

**What causes full reloads**:
- Changes to `index.html`
- Changes to `vite.config.*`
- Changes to a file that has no HMR boundary above it (e.g. a utility used by `main.tsx` directly, if `main.tsx` has no HMR handler)

#### Debugging Vite Applications

**Browser DevTools sourcemaps**: Vite generates sourcemaps for your source files during development automatically. The "Sources" tab in Chrome DevTools will show your original TypeScript/JSX files.

**Vite debug logging**:
```bash
DEBUG=vite:* vite
```
This prints the full plugin pipeline, module resolution steps, and HMR messages.

**`vite --debug`**: Shorthand for HMR debugging specifically.

**`vite-plugin-inspect`**: A plugin that opens a browser UI showing you exactly what each plugin does to each file — invaluable for debugging custom plugins or unexpected transforms.

**Common debugging scenarios**:
- **"Why is this import resolving incorrectly?"**: Check `resolve.alias` and the `moduleResolution` in `tsconfig.json`. Also check whether the package has correct `exports` in its `package.json`.
- **"Why isn't HMR working?"**: Use the browser console's HMR debug output or `DEBUG=vite:hmr vite` to see the HMR boundary traversal.
- **"My styles aren't updating"**: CSS HMR usually works well; if it doesn't, check whether you're using inline styles or CSS-in-JS (which follow JS HMR rules, not CSS HMR).

---

### Part VI: Production Build

---

#### The Build Process

Running `vite build` hands off to **Rollup** (not esbuild) for the actual bundling. This is a deliberate architectural choice: Rollup's production output is extremely well-optimized, with mature code splitting, tree shaking, and plugin ecosystems that have been production-tested for years. esbuild is faster but Rollup's output is more optimal for production.

The build pipeline:
1. **Entry discovery**: Vite starts from `index.html` and traces all `<script type="module">` sources.
2. **Module resolution**: All imports are resolved following the same rules as dev.
3. **Plugin `transform` hooks**: All plugins run their transforms on source files.
4. **Rollup bundling**: Rollup bundles everything, performing tree shaking (removing unused exports), scope hoisting (inlining modules to reduce function call overhead), and code splitting.
5. **Minification**: esbuild or Terser minifies JavaScript. esbuild handles CSS minification.
6. **Asset hashing**: Output filenames include a content hash: `Button-Bz3k8vd2.js`. This enables strong browser caching.
7. **Output**: Files are written to `dist/`.

#### Bundling and Tree Shaking

**Tree shaking** is the elimination of code that is exported by a module but never imported anywhere. For it to work, modules must use static `import`/`export` syntax (ESM). CommonJS `require()` is dynamic and cannot be tree-shaken.

```typescript
// utils.ts
export function usedFunction() { return 1; }
export function unusedFunction() { return 2; }  // will be removed if never imported

// main.ts
import { usedFunction } from './utils';
// unusedFunction is never referenced → removed from bundle
```

Tree shaking happens at the module graph level. If an entire module is never imported, it's removed entirely. If only some exports are used, only those remain. This is why packages like `lodash-es` are preferable to `lodash` in production — the ES module version can be tree-shaken per-function.

#### Code Splitting

**What it is**: The build output is split into multiple JavaScript files (chunks) instead of one large file. The browser only downloads the chunk it needs for the current route or interaction.

**Automatic code splitting**: Vite/Rollup automatically splits on:
- Dynamic imports: `const mod = await import('./heavy-module')`
- Async routes in React Router, Vue Router, etc.

**Manual chunk control**:
```typescript
build: {
  rollupOptions: {
    output: {
      manualChunks: {
        // Put react and react-dom in their own chunk
        'vendor-react': ['react', 'react-dom'],
        // Put all chart libraries together
        'vendor-charts': ['recharts', 'd3'],
      },
      // Or use a function for fine-grained control:
      manualChunks(id) {
        if (id.includes('node_modules')) {
          return 'vendor';
        }
      },
    },
  },
}
```

**Why manual chunks matter**: Without them, Rollup may create hundreds of tiny chunks (over-splitting) or put everything in one enormous chunk (under-splitting). The browser's HTTP/2 multiplexing handles many parallel requests well, but there's still overhead per request. A good rule of thumb is to keep chunk count in the tens, not hundreds.

#### Dynamic Imports

The standard mechanism for lazy-loading code on demand:

```typescript
// Eager (always loaded upfront)
import HeavyComponent from './HeavyComponent';

// Lazy (loaded only when this code runs)
const HeavyComponent = await import('./HeavyComponent');

// React pattern with Suspense
const HeavyComponent = React.lazy(() => import('./HeavyComponent'));
```

Vite handles dynamic imports by creating a separate chunk for the dynamically imported module and all its unique dependencies. The chunk is fetched only when the `import()` call executes.

#### Asset Hashing

Output filenames like `main-Bz3k8vd2.js` contain a **content hash**: a short fingerprint of the file's contents. If the file content changes, the hash changes and the new filename forces browsers to download the fresh version. If content doesn't change, the same filename is used and browsers serve from cache.

This enables **immutable caching**: you can tell CDNs and browsers to cache `*.js` and `*.css` files forever (Cache-Control: max-age=31536000, immutable), because the filename itself encodes the version. Only the unhashed `index.html` needs short-lived caching.

#### Static Deployment and Previewing

`vite build` produces a `dist/` folder containing static files. This folder can be served by any static hosting service: Nginx, Apache, Netlify, Vercel, Cloudflare Pages, GitHub Pages, AWS S3 + CloudFront.

**Previewing before deploy**:
```bash
vite build && vite preview
```
`vite preview` serves `dist/` on `localhost:4173` by default. It mimics a static server so you can catch issues (missing files, broken paths, SPA routing) before shipping.

---

### Part VII: Assets

---

#### Asset Importing in Vite

Vite gives you multiple ways to work with static assets (images, fonts, SVGs, etc.), and the mechanism differs meaningfully.

**Importing from `src/` (processed by Vite)**:
```typescript
import logo from './logo.png'
// logo is a string: the hashed URL, e.g. '/assets/logo-Bz3k8vd2.png'

const img = document.createElement('img')
img.src = logo
```

Vite processes this import:
- In development: serves the file from disk, returns a URL pointing to it.
- In production: copies the file to `dist/assets/`, hashes the filename, returns the hashed URL.

**The `public/` directory**:

Files in `public/` are served as-is, at the root URL, without processing or hashing.

```
public/
  favicon.ico    → served at /favicon.ico
  robots.txt     → served at /robots.txt
  og-image.png   → served at /og-image.png
```

Use `public/` for:
- Files that must have a **stable, predictable URL** (favicons, `robots.txt`, Open Graph images referenced in HTML `<meta>` tags)
- Files that are **not imported by your JS/CSS** (they're referenced only by URL)
- Large assets you don't want Vite to hash or inline

Do **not** use `public/` for assets imported in your components — those should live in `src/assets/` and benefit from hashing.

#### Asset Inlining

Assets smaller than `build.assetsInlineLimit` (default 4096 bytes, 4KB) are inlined as **base64 data URLs** in the JavaScript or CSS that imports them, rather than being emitted as separate files. This eliminates an HTTP request for small icons or tiny images.

```typescript
import tinyIcon from './icon.svg'  // 2KB — will be inlined as data:image/svg+xml;base64,...
import heroImage from './hero.jpg' // 200KB — will be emitted as a separate file
```

You can force inlining or URL emission with query suffixes:
```typescript
import svgUrl from './icon.svg?url'      // always a URL, never inlined
import svgRaw from './icon.svg?raw'      // returns the SVG source code as a string
import svgInline from './icon.svg?inline' // force inline as data URL
```

#### SVGs

SVGs have special treatment because they can be used either as image files or as React/Vue components (for inline SVG with dynamic coloring and accessibility attributes).

With `@vitejs/plugin-react` and `vite-plugin-svgr`:
```typescript
import Logo from './logo.svg?react'   // SVG as a React component
import logoUrl from './logo.svg'       // SVG as a URL string
```

Without svgr, the default Vite behavior returns the URL string. With svgr, you configure which query string (or default behavior) returns a component.

#### URL Handling

Vite transforms `url()` references in CSS:
```css
.hero {
  background-image: url('./hero.jpg');  /* transformed to hashed URL in production */
}
```

**`import.meta.url` pattern** for dynamic asset paths:
```typescript
// This works correctly in both dev and prod:
const imageUrl = new URL('./assets/hero.jpg', import.meta.url).href
```

`import.meta.url` is the URL of the current module. Constructing a URL relative to it gives a correct absolute URL in any environment. Vite processes these `new URL(...)` patterns during build and ensures the referenced file is included in the output.

---

### Part VIII: CSS Handling

---

#### How Vite Processes CSS

Vite has first-class CSS support with no additional configuration required for common patterns.

**During development**: Vite converts CSS imports into JavaScript that dynamically injects `<style>` tags into the document head. This enables HMR for CSS without page reloads.

**During production**: CSS imported in JS is extracted into separate `.css` files alongside the JS chunks. This enables parallel loading of JS and CSS.

**Direct import of CSS**:
```typescript
// main.tsx
import './index.css'  // styles are applied globally
```

**CSS as a string** (for shadow DOM, styled components, etc.):
```typescript
import styles from './component.css?inline'
// styles is the raw CSS string, not injected automatically
```

#### PostCSS

PostCSS is a CSS transformation pipeline. Vite automatically applies PostCSS if it finds `postcss.config.js` (or `postcss.config.cjs`) in your project root.

PostCSS is **not a CSS preprocessor**. It's a transformation system that transforms CSS using plugins. Common PostCSS plugins:
- `autoprefixer`: adds vendor prefixes automatically based on browserslist
- `postcss-preset-env`: lets you use future CSS features now (like native CSS nesting before it was universally supported)
- `cssnano`: minifies CSS (Vite handles this itself during build, but cssnano offers more control)

```javascript
// postcss.config.js
export default {
  plugins: {
    autoprefixer: {},
    'postcss-preset-env': { stage: 1 },
  },
}
```

You can also inline PostCSS config in `vite.config.ts`:
```typescript
css: {
  postcss: {
    plugins: [autoprefixer(), postcssPresetEnv()],
  },
}
```

#### CSS Modules

CSS Modules scope class names to their importing component, preventing style collisions between components.

**How they work**: A file named `*.module.css` is treated as a CSS Module.

```css
/* Button.module.css */
.button { background: blue; }
.primary { background: darkblue; }
```

```typescript
// Button.tsx
import styles from './Button.module.css'
// styles.button = 'Button_button__Bz3k8' (scoped class name)
// styles.primary = 'Button_primary__Qr8f' (scoped class name)

return <button className={styles.button}>Click</button>
```

Vite (via PostCSS modules) rewrites the class names to be globally unique. The generated CSS contains the mangled names, and the JS object maps original names to mangled names.

**Composition** with CSS Modules:
```css
.button { color: white; }
.primary { composes: button; background: darkblue; }
```

**Global within a CSS Module**:
```css
:global(.third-party-class) { color: red; }
```

#### CSS Preprocessors

Vite supports Sass, Less, and Stylus out of the box — just install the preprocessor:

```bash
npm install -D sass
```

Then use `.scss` or `.sass` files normally:
```typescript
import './App.scss'
```

No configuration required. Vite detects the file extension and uses the appropriate preprocessor.

**CSS Modules + Sass** work together: name files `*.module.scss`.

#### Tailwind CSS Integration

Tailwind is a PostCSS plugin. Integration requires:

```bash
npm install -D tailwindcss postcss autoprefixer
npx tailwindcss init -p  # creates tailwind.config.js and postcss.config.js
```

```javascript
// tailwind.config.js
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: { extend: {} },
  plugins: [],
}
```

```css
/* src/index.css */
@tailwind base;
@tailwind components;
@tailwind utilities;
```

Tailwind's PurgeCSS integration (the `content` array) removes unused utility classes in production, keeping CSS output minimal. During development, all utilities are available.

**With Tailwind v4 (2025+)**: Tailwind v4 uses a CSS-first configuration approach and has native Vite integration via `@tailwindcss/vite` plugin, replacing the PostCSS approach.

---

### Part IX: JavaScript and TypeScript

---

#### JSX and TSX

Vite handles JSX/TSX via two possible transforms:

**Option 1: esbuild (default for most templates)**:
```typescript
// vite.config.ts
export default defineConfig({
  esbuild: {
    jsxImportSource: 'react',  // for React 17+ automatic JSX runtime
    jsx: 'automatic',
  },
})
```

**Option 2: SWC** (via `@vitejs/plugin-react-swc`):
SWC (Speedy Web Compiler, written in Rust) is an alternative to esbuild for transforms. It's faster than Babel and more feature-compatible with the React ecosystem. The `react-swc` scaffolding template uses this. [Inference: SWC is generally faster than esbuild for React transforms due to its Rust implementation, but both are significantly faster than Babel. Benchmark your specific case to verify.]

**The JSX automatic runtime** (`react-jsx`) means you don't need `import React from 'react'` at the top of every file. The transform automatically imports the necessary JSX factory functions.

#### TypeScript Behavior in Vite

As covered in Project Setup: Vite uses esbuild to **strip** TypeScript types. It does not type-check.

**Implications**:
1. `tsc --noEmit` should run in CI to catch type errors before deploy.
2. Type errors in development do not break the dev server — this is a feature, not a bug, because it means a single type error doesn't block all work.
3. `const enum` — a TypeScript-only feature that works differently than regular enums — may not work correctly under esbuild's isolated-module transform. Prefer regular `enum` or `as const` objects.
4. Decorators — if used (common with class-based frameworks like Angular or older NestJS patterns) — require explicit configuration.

**`isolatedModules: true`** in `tsconfig.json` enforces compatibility with esbuild's per-file transform approach. It flags patterns that require cross-file type information to transform correctly. Always enable this in Vite projects.

#### Source Maps

Source maps are files that map minified/transpiled output back to original source lines. Without them, a stack trace showing `Button-Bz3k8vd2.js:1:4892` is unreadable.

**Development**: Vite generates inline source maps by default for dev server responses. These appear in the browser's Sources panel.

**Production**:
```typescript
build: {
  sourcemap: true,     // generates .map files alongside output
  sourcemap: 'inline', // embeds map in JS file (larger file, useful for debugging without separate map hosting)
  sourcemap: 'hidden', // generates .map files but doesn't reference them in output (for private upload to Sentry etc.)
}
```

For production monitoring, the recommended pattern is `sourcemap: 'hidden'` combined with uploading maps to Sentry or similar during your CI/CD pipeline.

---

### Part X: Framework Integration

---

#### React

```bash
npm create vite@latest my-app -- --template react-ts
# or with SWC:
npm create vite@latest my-app -- --template react-swc-ts
```

**Plugin**: `@vitejs/plugin-react` (Babel-based) or `@vitejs/plugin-react-swc` (SWC-based)

```typescript
import react from '@vitejs/plugin-react'
export default defineConfig({ plugins: [react()] })
```

The plugin provides:
- JSX transformation
- React Fast Refresh (HMR with state preservation)
- Automatic JSX runtime injection

**Key React + Vite considerations**:
- React Fast Refresh requires components to be in files that only export React components (not a mix of components and utility functions). If HMR isn't working for a component, check whether that file exports non-component things.
- `React.StrictMode` wraps your app by default in scaffolded templates. It causes double-invocation of certain lifecycle methods in development — this is expected React behavior, not a Vite issue.

#### Vue

Vue is Vite's original target framework; Evan You created both. The integration is the most seamless.

```bash
npm create vite@latest my-app -- --template vue-ts
```

**Plugin**: `@vitejs/plugin-vue`

Single File Components (`.vue` files with `<template>`, `<script>`, `<style>`) are transformed by the plugin — each section is processed appropriately (template → render function, script → JS module, style → CSS).

Vue also supports `<script setup>` syntax for the Composition API, which is efficiently processed by the plugin.

#### Svelte

```bash
npm create vite@latest my-app -- --template svelte-ts
```

**Plugin**: `@sveltejs/vite-plugin-svelte`

Svelte compiles `.svelte` files to optimized vanilla JS. The plugin handles this compilation within Vite's transform pipeline. SvelteKit (the full-stack Svelte framework) uses Vite as its underlying build tool with its own plugin on top.

#### Angular

Angular has its own build toolchain (`@angular/build` using esbuild internally since v17). The Angular team built their own Vite integration:

```bash
ng new my-app  # uses Vite/esbuild as of Angular 17+
```

Angular does not use `vite.config.ts` in the same way — configuration is in `angular.json`. The Vite integration in Angular is more of an internal implementation detail than a user-facing API.

#### Framework Differences Summary

The key difference between framework integrations is the **plugin's HMR strategy**. React Fast Refresh, Vue's HMR, and Svelte's HMR are each implemented differently to match their respective component models. The Vite dev server itself is framework-agnostic; frameworks hook into `handleHotUpdate` and the module graph to implement their own HMR semantics.

---

### Part XI: Plugins

---

#### What Plugins Are

Vite's plugin system is a superset of **Rollup's plugin API**. Rollup plugins work in Vite without modification (with minor caveats). Vite adds additional hooks specific to its dev server.

This design decision means: the ecosystem of Rollup plugins — which existed before Vite — largely works in Vite. Vite's plugin ecosystem benefits from years of Rollup plugin development.

#### Plugin Lifecycle Hooks

Hooks run at different stages. Understanding when each runs is essential for writing correct plugins.

**Build hooks (also used in dev for transforms)**:
```
build start
     ↓
options(inputOptions)          — modify Rollup input options
buildStart(inputOptions)       — build is starting
     ↓ for each module:
resolveId(source, importer)    — resolve a module path to an ID
load(id)                       — provide source code for an ID
transform(code, id)            — transform source code
     ↓
moduleParsed(moduleInfo)       — called after a module is parsed
     ↓
buildEnd()
generateBundle(options, bundle)  — modify/inspect output before write
writeBundle(options, bundle)     — output was written
closeBundle()
```

**Vite-specific hooks**:
```
config(config, env)            — modify config before resolving
configResolved(resolvedConfig) — called with final config
configureServer(server)        — configure dev server (add middleware)
configurePreviewServer(server) — configure preview server
transformIndexHtml(html)       — transform index.html
handleHotUpdate(ctx)           — custom HMR handling
```

#### Writing a Custom Plugin

A plugin that replaces `@BUILD_DATE@` with the current date in any JS/TS file:

```typescript
// vite.config.ts
import { Plugin, defineConfig } from 'vite'

function buildDatePlugin(): Plugin {
  return {
    name: 'build-date',
    // enforce: 'pre' | 'post' — run before or after other plugins
    transform(code, id) {
      // Only process JS/TS files
      if (!id.match(/\.(js|ts|jsx|tsx)$/)) return null
      
      if (code.includes('@BUILD_DATE@')) {
        return {
          code: code.replace(/@BUILD_DATE@/g, new Date().toISOString()),
          map: null, // or generate a sourcemap
        }
      }
      
      // Return null to indicate no transformation
      return null
    },
  }
}

export default defineConfig({
  plugins: [buildDatePlugin()],
})
```

A plugin that adds a custom middleware to the dev server:
```typescript
function myMiddlewarePlugin(): Plugin {
  return {
    name: 'my-middleware',
    configureServer(server) {
      // server is a Vite DevServer (a Koa-based HTTP server)
      server.middlewares.use('/api/health', (req, res) => {
        res.end(JSON.stringify({ status: 'ok' }))
      })
    },
  }
}
```

A plugin that modifies `index.html`:
```typescript
function injectMetaPlugin(): Plugin {
  return {
    name: 'inject-meta',
    transformIndexHtml(html) {
      return html.replace(
        '</head>',
        `<meta name="build-time" content="${Date.now()}" /></head>`,
      )
    },
  }
}
```

#### Plugin Execution Order

Plugins run in array order in `plugins: []`. However, `enforce` overrides order:
- `enforce: 'pre'` — runs before normal plugins
- (no enforce) — normal order
- `enforce: 'post'` — runs after normal plugins, before Vite internal post-plugins

Core Vite plugins run between `pre` and `post` user plugins.

#### Popular Plugins

- **`@vitejs/plugin-react`** / **`@vitejs/plugin-react-swc`**: React + Fast Refresh
- **`@vitejs/plugin-vue`**: Vue SFC support
- **`vite-plugin-svgr`**: Import SVGs as React components
- **`vite-tsconfig-paths`**: Automatically syncs `tsconfig.json` `paths` to Vite aliases
- **`vite-plugin-checker`**: Runs TypeScript, ESLint, or Stylelint checks in a separate worker during dev
- **`rollup-plugin-visualizer`** (works in Vite): Bundle analysis treemap
- **`@vitejs/plugin-legacy`**: Generates a polyfilled bundle for legacy browsers (IE11, old Safari) alongside the modern bundle
- **`vite-plugin-pwa`**: Progressive Web App support (service worker, manifest)
- **`unplugin-icons`**: Import thousands of icons from icon sets as components
- **`unplugin-vue-components`**: Auto-imports Vue components (no explicit import needed)
- **`vite-plugin-compression`**: Generates `.gz` / `.br` files for pre-compression

---

### Part XII: Advanced Internals

---

#### Vite's Two-Engine Architecture

Vite uses two distinct bundlers and assigns them different jobs based on their strengths.

**esbuild** (written in Go):
- Dependency pre-bundling (one-time, on dev server start)
- TypeScript/JSX transpilation (per-file, during dev and build)
- Minification during build
- JavaScript transpilation for `build.target`

**Rollup** (written in JavaScript):
- Production bundling (tree shaking, code splitting, chunk generation)
- Plugin ecosystem (Vite's plugin API is a superset of Rollup's)
- `lib` mode (building library outputs)

**Why not just esbuild for everything?**

esbuild is extremely fast but has limitations in its production bundling output (as of 2024–2025): its code splitting implementation is less mature, its plugin API is less flexible, and its output is less aggressively optimized for production scenarios than Rollup's. Rollup's output quality — particularly around tree shaking and chunk optimization — is battle-tested at scale.

[Inference: The two-engine design is a pragmatic tradeoff. esbuild where speed matters most (dev), Rollup where output quality matters most (prod). This may change as esbuild matures.]

#### The Plugin Pipeline in Detail

During development, when a file is requested:

```
incoming request for /src/App.tsx
         ↓
  [resolve phase]
  plugin resolveId hooks (in order, pre → normal → post)
  → default resolver (filesystem + node_modules)
         ↓
  [load phase]
  plugin load hooks
  → default: read file from disk
         ↓
  [transform phase]
  plugin transform hooks (in order, pre → normal → post)
  → esbuild plugin: strips TypeScript, transforms JSX
  → CSS module plugin (if .module.css)
  → user plugins
         ↓
  [import rewriting]
  bare specifiers → resolved paths
  dynamic import() → wrapped for HMR
         ↓
  response sent to browser
```

During production build, the same plugins run but Rollup orchestrates the bundling after all transforms are applied.

#### Module Resolution

Vite resolves modules in this order:
1. **Aliases** (`resolve.alias` in config)
2. **Explicit extensions**: if the import already has an extension, use it
3. **Try extensions**: try `resolve.extensions` list (`.ts`, `.tsx`, `.js`, etc.)
4. **`package.json` exports field**: modern packages define entry points per condition (browser, node, import, require). Vite follows the `browser`, `module`, `import` conditions by default.
5. **`package.json` `main` field**: fallback for older packages

**The `exports` field in package.json** is important to understand. A package like `some-library` might have:
```json
{
  "exports": {
    ".": {
      "import": "./dist/index.mjs",
      "require": "./dist/index.cjs"
    }
  }
}
```

Vite uses the `import` condition, getting the ESM version. This is correct behavior but occasionally causes issues with packages that have incorrect or missing `exports` maps. The fix: use `resolve.conditions` to add other conditions, or use `optimizeDeps.include` to force pre-bundling.

#### Dependency Optimization Internals

`optimizeDeps` controls the pre-bundling step:

```typescript
optimizeDeps: {
  include: ['some-dep', 'some-dep/sub-path'],  // force include in pre-bundle
  exclude: ['@my-local-package'],              // exclude from pre-bundle
  force: true,                                 // re-bundle even if cache is valid
  esbuildOptions: {
    // passed directly to esbuild for the pre-bundling step
    plugins: [],
  },
}
```

**`include`**: Vite scans your source files to discover what to pre-bundle, but dynamic imports (strings computed at runtime) may be missed. Manually add anything you know will be needed.

**`exclude`**: Local packages in a monorepo that you want to use in dev mode without pre-bundling (so they HMR correctly).

The pre-bundle cache key is based on file contents of lock files and the `optimizeDeps` config. Change either → cache invalidates → re-bundle runs.

---

### Part XIII: Backend and Full-Stack Usage

---

#### The Proxy Pattern (Vite + Backend)

The most common full-stack development setup: frontend (Vite) and backend (Express/Fastify/etc.) run as separate processes. The Vite proxy makes them appear as one origin to the browser.

```
Browser (localhost:5173)
     ↓ requests /api/users
Vite Dev Server
     ↓ proxies to
Backend (localhost:8080)
     ↓ responds
Vite Dev Server
     ↓ forwards response
Browser
```

```typescript
// vite.config.ts
server: {
  proxy: {
    '/api': {
      target: 'http://localhost:8080',
      changeOrigin: true,   // sets Host header to match target
      secure: false,        // allow self-signed certs in dev
    },
    '/ws': {
      target: 'ws://localhost:8080',
      ws: true,             // proxy WebSocket connections
    },
  },
}
```

#### Vite as Middleware in an Express/Fastify App

For tighter integration (SSR, shared configuration), you can use Vite as Express middleware:

```typescript
// server.ts (Node.js backend)
import express from 'express'
import { createServer as createViteServer } from 'vite'

async function createServer() {
  const app = express()
  
  const vite = await createViteServer({
    server: { middlewareMode: true },
    appType: 'custom',  // don't use Vite's HTML handling
  })
  
  // Vite handles asset serving and HMR
  app.use(vite.middlewares)
  
  // Your API routes
  app.get('/api/users', (req, res) => {
    res.json([{ id: 1, name: 'Alice' }])
  })
  
  // SSR handler
  app.use('*', async (req, res) => {
    const url = req.originalUrl
    const template = await vite.transformIndexHtml(url, fs.readFileSync('index.html', 'utf-8'))
    // ... render app to string and send
    res.end(template)
  })
  
  app.listen(3000)
}
```

This pattern is used by full-stack frameworks like SvelteKit and Nuxt internally.

#### Server-Side Rendering (SSR)

SSR is covered in depth in Advanced Topics. The essential Vite configuration for SSR:

```typescript
// vite.config.ts
export default defineConfig({
  build: {
    ssr: true,                          // enables SSR build mode
    rollupOptions: {
      input: 'src/entry-server.tsx',    // server entry point
    },
  },
})
```

You need two entry points:
- `src/entry-client.tsx`: hydrates the server-rendered HTML in the browser
- `src/entry-server.tsx`: renders the app to a string on the server

#### Monorepo Setup

In a monorepo (multiple packages in one repo), Vite applications need to be able to import local packages without them being published to npm first.

**Typical structure**:
```
my-monorepo/
├── packages/
│   ├── ui/           # shared component library
│   │   ├── src/
│   │   └── package.json  ("name": "@my-org/ui")
│   └── utils/        # shared utilities
├── apps/
│   └── web/          # Vite app
│       └── vite.config.ts
└── package.json      # workspace root
```

**Key configurations in the Vite app**:
```typescript
// apps/web/vite.config.ts
resolve: {
  dedupe: ['react', 'react-dom'],  // prevent multiple React copies
},
optimizeDeps: {
  include: ['@my-org/ui > react'],  // pre-bundle transitive deps from local packages
},
```

**Linked packages**: With pnpm workspaces, `@my-org/ui` is symlinked into `node_modules`. Vite watches symlinked directories if you configure:
```typescript
server: {
  watch: {
    // Watch the actual package source, not the symlink
    followSymlinks: true,
  },
  fs: {
    allow: ['../..'],  // allow serving files from above the app root
  },
}
```

#### Full-Stack Project Structure Example

```
my-fullstack-app/
├── client/                    # Vite frontend
│   ├── src/
│   │   ├── components/
│   │   ├── pages/
│   │   ├── api/               # API client (fetch wrappers)
│   │   └── main.tsx
│   ├── index.html
│   └── vite.config.ts         # with proxy to /api → localhost:8080
├── server/                    # Backend (Express/Fastify)
│   ├── src/
│   │   ├── routes/
│   │   ├── middleware/
│   │   └── index.ts
│   └── tsconfig.json
├── shared/                    # Shared types (no runtime deps)
│   └── types.ts
└── package.json               # workspace root or scripts for both
```

The `shared/` directory contains TypeScript types used by both client and server. Since TypeScript types are erased at runtime, there's no circular dependency or build-order problem — the client and server each reference the types, and `tsc` handles them during type checking.

---

### Part XIV: Deployment

---

#### Static Hosting

After `vite build`, the `dist/` folder is a self-contained static site. Any static host works:

- **Netlify**: `npm run build` as build command, `dist` as publish directory. No `_redirects` config needed if you add `netlify.toml` with redirect rules for SPA.
- **Vercel**: Auto-detects Vite. Zero configuration for most projects.
- **Cloudflare Pages**: Detects `vite build` and serves `dist/`.
- **GitHub Pages**: Use the `gh-pages` package or GitHub Actions to deploy `dist/`.
- **AWS S3 + CloudFront**: Upload `dist/` contents to S3. Configure CloudFront for SPA routing (forward all paths to `index.html` with a custom error response).
- **Nginx**:
  ```nginx
  server {
    root /var/www/my-app/dist;
    index index.html;
    location / {
      try_files $uri $uri/ /index.html;  # SPA routing: serve index.html for unknown paths
    }
    location /assets/ {
      expires 1y;
      add_header Cache-Control "public, immutable";
    }
  }
  ```

#### The SPA Routing Problem

SPAs use client-side routing: React Router or Vue Router manage URL changes in the browser without making server requests. When a user visits `myapp.com/dashboard` directly (or refreshes), the server receives a request for `/dashboard`. Without configuration, the server returns a 404 — there's no file at that path.

**Solution**: Configure the server to serve `index.html` for all paths that don't match static files. The SPA JavaScript then reads the URL and renders the correct page.

Every hosting platform has its own way of configuring this:
- Netlify: `public/_redirects` file: `/* /index.html 200`
- Vercel: `vercel.json` rewrites
- Nginx: `try_files $uri /index.html`
- Apache: `RewriteRule ^ /index.html [L]` in `.htaccess`

#### Base Path Configuration

If your app is deployed at a sub-path (e.g. `mysite.com/app/` instead of `mysite.com/`), configure:

```typescript
// vite.config.ts
export default defineConfig({
  base: '/app/',  // note: must have leading and trailing slash for sub-paths
})
```

This prefixes all generated asset URLs with `/app/`. Without this, assets like `<script src="/assets/main.js">` would fail when the app is at `/app/`.

For GitHub Pages projects deployed at `username.github.io/my-repo/`:
```typescript
base: '/my-repo/'
```

For dynamic base at runtime (rare):
```typescript
base: './'  // relative paths, works in any sub-path but limits PWA capabilities
```

#### Environment Variables in Production

During `vite build`, all `VITE_*` environment variables are statically replaced in the output. They come from:
- `.env.production` file (committed to repo — safe for non-secret config)
- `.env.production.local` file (not committed — for machine-local config)
- Shell environment at build time: `VITE_API_URL=https://prod.api.com vite build`

Most CI/CD platforms (GitHub Actions, Netlify, Vercel) have secure "Environment Variables" settings where you define build-time variables that are injected when the build runs.

**Runtime environment variables**: Because Vite replaces env vars at build time, there's no way to change them after build without rebuilding. For apps that need runtime configuration (the same Docker image deployed to staging and production), a common pattern is:
1. Serve a small `config.json` file from your server with runtime values.
2. Fetch it at app startup: `const config = await fetch('/config.json').then(r => r.json())`
3. Use those values instead of `import.meta.env`.

---

### Part XV: Security

---

#### Environment Variable Exposure

The most common security mistake with Vite: putting secrets in `VITE_*` variables.

All `VITE_*` variables are embedded verbatim in your JavaScript bundle. Anyone who visits your site can extract them by opening DevTools → Sources → searching for the variable value.

**Never put in `VITE_*`**:
- Database credentials
- Private API keys (Stripe secret key, AWS secret, etc.)
- JWT secrets
- Any value that grants privileged access

**Safe to put in `VITE_*`**:
- Public API keys (Stripe publishable key, Google Maps API key with domain restrictions)
- Feature flags
- Public API base URLs
- Application configuration that isn't security-sensitive

**Architecture for secrets**: If your frontend needs to call an API that requires a private key, the private key belongs on your **backend server**. The frontend calls your backend, which holds the secret and calls the third-party API on the frontend's behalf.

#### Development Server Security

By default, `vite` only listens on `localhost`. If you expose it to the network with `server.host: '0.0.0.0'` or `server.host: true`, it becomes accessible to anyone on the same network.

Vite's development server is not hardened for production use. Never run `vite` directly in production. Always use `vite build` + a proper static server.

**`server.fs.deny`** prevents Vite from serving sensitive files:
```typescript
server: {
  fs: {
    deny: ['.env', '.env.*', '*.{pem,crt,key}'],
  },
}
```

#### Dependency Risks

Dependencies are a surface area for supply chain attacks. A malicious npm package in your dependency tree could exfiltrate environment variables, modify build output, or inject malicious code.

Mitigations:
- Use lockfiles (`package-lock.json`, `pnpm-lock.yaml`) and commit them to version control.
- Run `npm audit` (or equivalent) regularly.
- Use tools like Snyk or GitHub Dependabot for automated vulnerability alerts.
- Review dependency updates carefully, especially for frequently-updated packages.
- Prefer packages with established maintenance history and clear ownership.

Vite does not add additional protection against malicious dependencies beyond what npm/Node provides. This is a general Node.js/npm ecosystem concern.

---

### Part XVI: Performance

---

#### Build Analysis

Before optimizing, measure. The standard tool:

```bash
npm install --save-dev rollup-plugin-visualizer
```

```typescript
// vite.config.ts
import { visualizer } from 'rollup-plugin-visualizer'

export default defineConfig({
  plugins: [
    visualizer({
      open: true,        // open browser automatically
      gzipSize: true,    // show gzip sizes
      brotliSize: true,  // show brotli sizes
      template: 'treemap', // 'treemap' | 'sunburst' | 'network'
    }),
  ],
})
```

After running `vite build`, this opens an interactive treemap showing exactly how much space each dependency and source file contributes to your bundle.

**Common findings**:
- A single large library dominates (moment.js, lodash full build, a full icon library)
- Duplicate packages (multiple versions of React, different versions of a utility)
- Unexpectedly large chunks that could be split

#### Reducing Bundle Size

**Replace heavy libraries**:
- `moment.js` → `date-fns` or `dayjs` (much smaller, tree-shakable)
- `lodash` → `lodash-es` (tree-shakable) or native JS equivalents
- Full icon library → `unplugin-icons` (import only used icons)
- `axios` → `ky` or native `fetch`

**Tree shaking gotchas**:
- Named imports tree-shake, namespace imports do not: prefer `import { useState } from 'react'` over `import * as React from 'react'` for anything except React itself.
- Side effects in modules prevent tree shaking. Check `"sideEffects"` in `package.json` for packages you maintain.

**Code splitting strategy**:
```typescript
build: {
  rollupOptions: {
    output: {
      manualChunks(id) {
        if (id.includes('node_modules')) {
          // Put each major library in its own chunk
          if (id.includes('react')) return 'vendor-react'
          if (id.includes('recharts') || id.includes('d3')) return 'vendor-charts'
          return 'vendor'
        }
      },
    },
  },
}
```

Splitting vendors from application code means users re-download vendor chunks only when dependencies change (which is less frequent than application code changes).

#### Lazy Loading Routes

In a React + React Router v6 app:
```typescript
import { lazy, Suspense } from 'react'
import { Routes, Route } from 'react-router-dom'

const Dashboard = lazy(() => import('./pages/Dashboard'))
const Settings = lazy(() => import('./pages/Settings'))
const Analytics = lazy(() => import('./pages/Analytics'))

function App() {
  return (
    <Suspense fallback={<PageSpinner />}>
      <Routes>
        <Route path="/dashboard" element={<Dashboard />} />
        <Route path="/settings" element={<Settings />} />
        <Route path="/analytics" element={<Analytics />} />
      </Routes>
    </Suspense>
  )
}
```

Each `lazy()` call creates a split point. Vite generates separate chunks for Dashboard, Settings, and Analytics. Users only download the code for pages they visit.

#### Dev Server Performance for Large Apps

If the dev server feels slow for very large projects:

1. **Check `optimizeDeps`**: Large apps with many third-party deps may need to be fully pre-bundled. Manually add frequently-used packages to `optimizeDeps.include`.

2. **Exclude irrelevant paths from watching**:
   ```typescript
   server: {
     watch: {
       ignored: ['**/test-fixtures/**', '**/__mocks__/**'],
     },
   }
   ```

3. **Split the app into chunks that can be independently developed**: Use monorepo structure to separate concerns so each Vite app is smaller.

4. **Check for expensive plugins**: A plugin's `transform` hook runs for every file. A slow transform (e.g. running heavy regex on every module) compounds with app size. Use `filter` to restrict transforms to relevant files:
   ```typescript
   transform(code, id) {
     if (!id.endsWith('.svg')) return null
     // ...
   }
   ```

---

### Part XVII: Common Problems

---

#### Blank Page After Deployment

**Symptoms**: The page loads but shows nothing, or the initial `index.html` loads but JavaScript fails to load.

**Cause 1: Wrong `base` path**. If deployed at a sub-path but `base` is not set, asset URLs like `/assets/main.js` resolve to the root instead of the sub-path. Fix: set `base: '/my-sub-path/'` in config.

**Cause 2: SPA routing not configured**. A direct URL visit or page refresh hits a path with no file on the server. Fix: configure your server to serve `index.html` for all paths (see Deployment section).

**Cause 3: Environment variables not set at build time**. `import.meta.env.VITE_API_URL` resolves to `undefined` in production if the variable wasn't set during `vite build`. Fix: ensure all required `VITE_*` variables are set in your CI/CD build environment.

#### Import Errors

**"Failed to resolve import"** in the browser:
- The file doesn't exist at the path you specified.
- Case sensitivity: Linux filesystems are case-sensitive. `./Button` may work on Mac but fail on Linux if the file is `./button.tsx`. Fix: be consistent with casing and consider `vite-plugin-checker` to catch this early.

**"does not provide an export named"**:
- You're trying to import a named export that doesn't exist. Check the package's actual exports.
- The package uses CommonJS and Vite's pre-bundling didn't catch it. Fix: add it to `optimizeDeps.include`.

#### Alias Issues

If you add an alias to `vite.config.ts` but TypeScript shows "cannot find module" errors: you also need to add it to `tsconfig.json` under `compilerOptions.paths`. These are two separate systems that must be kept in sync.

Consider `vite-tsconfig-paths` to auto-sync them.

#### Environment Variable Problems

- **`import.meta.env.VITE_*` is `undefined`**: Variable not set at build time, or missing `VITE_` prefix.
- **Variable works in dev, undefined in prod**: The `.env` file has it, but `.env.production` doesn't (or the CI system doesn't have it set).
- **Variable is defined but secret**: Use `PUBLIC_` prefix convention mentally to remind yourself these are public; move secrets to backend.

#### Build Failures

**"Top-level `await` is not available"**: Your `build.target` is set to an environment that doesn't support top-level await (below ES2022). Raise the target or restructure code.

**Large chunk size warnings**: Not a failure, but indicates you should split chunks. Use `manualChunks` or lazy imports. To silence temporarily: `build.chunkSizeWarningLimit: 1000`.

**Out of memory**: Very large apps can exhaust Node.js's default heap. Run with `NODE_OPTIONS=--max-old-space-size=8192 vite build`.

**Circular imports**: Not always an error, but can cause unexpected behavior (a module is `undefined` when first accessed due to initialization order). Vite/Rollup may warn about these. Fix by restructuring to break the cycle.

#### Plugin Conflicts

If two plugins both transform the same file type, the order matters and they can conflict. Symptoms: unexpected output, transforms being undone, errors about invalid JavaScript.

Debug with `vite-plugin-inspect`. It shows you exactly what each plugin produces for each file.

#### Dependency Optimization Problems

**"The requested module does not provide an export"** for a specific dep:
```typescript
optimizeDeps: {
  include: ['problem-dep'],
}
```

**Dependency not updating after `npm install`**:
```bash
vite --force  # clears the pre-bundle cache and re-runs
```

Or set `optimizeDeps.force: true` in config temporarily.

---

### Part XVIII: Best Practices

---

#### Recommended Project Structure

```
src/
├── assets/            # Images, fonts imported by components
├── components/        # Reusable UI components (no business logic)
│   └── ui/            # Primitive components (Button, Input, Card)
├── features/          # Feature-based modules (auth, dashboard, settings)
│   └── auth/
│       ├── components/
│       ├── hooks/
│       ├── api.ts     # API calls for this feature
│       └── index.ts   # Public API of the feature
├── hooks/             # Shared custom hooks
├── lib/               # Third-party library config (axios instance, query client)
├── pages/             # Route-level components (thin wrappers importing features)
├── store/             # Global state
├── types/             # Shared TypeScript types
├── utils/             # Pure utility functions
└── main.tsx           # Entry point (minimal — just renders <App />)
```

This **feature-first** structure scales better than a **type-first** structure (`/components`, `/hooks`, `/services` at the root) because related code lives together and features can be developed, tested, and deleted as units.

#### Configuration Practices

1. **Use `defineConfig` always**: It provides TypeScript autocompletion.
2. **Separate environment-specific config** using the `({ command, mode }) =>` form rather than putting conditions inline everywhere.
3. **Keep aliases minimal**: Only alias paths you actually use in many places. Over-aliasing makes the project harder to navigate.
4. **Type your environment variables** in `vite-env.d.ts` with an `ImportMetaEnv` interface.
5. **Use `vite-tsconfig-paths`** instead of maintaining aliases in two places (config + tsconfig).
6. **Don't commit `.env.local`**: It's for local developer overrides and may contain personal credentials.

#### Production Recommendations

1. **Run `tsc --noEmit` in CI**: Vite doesn't type-check. Your CI must.
2. **Run `vite build` + `vite preview` in CI**: Catch build failures and deployment issues before they reach production.
3. **Set `build.sourcemap: 'hidden'`** and upload sourcemaps to your error monitoring tool.
4. **Configure immutable caching** for `/assets/`: these files have content hashes and never change content at the same URL.
5. **Set `build.reportCompressedSize: false`** if builds are slow: computing brotli sizes takes time.
6. **Analyze bundles regularly** with `rollup-plugin-visualizer` before major releases.

#### Team Workflow Recommendations

1. **Standardize on one package manager** per project. Mixing npm, yarn, and pnpm causes subtle lockfile conflicts.
2. **Add `"type": "module"` to `package.json`** in new projects: enables ESM throughout, which avoids CommonJS/ESM interop friction.
3. **Add `vite-plugin-checker` to development** to surface TypeScript and ESLint errors in the browser overlay — makes errors visible without a separate terminal.
4. **Document non-obvious `vite.config.ts` entries** with comments: future teammates will thank you for explaining why `dedupe: ['react']` or a specific `manualChunks` strategy exists.
5. **Keep `vite.config.ts` lean**: If it grows beyond ~100 lines, extract plugin configurations into separate files.

---

### Part XIX: Advanced Topics

---

#### Server-Side Rendering (SSR)

SSR renders your React/Vue/Svelte app on the server to an HTML string, sends that HTML to the browser (for fast first paint and SEO), and then "hydrates" it on the client side (attaches event listeners to the server-rendered HTML).

**The Vite SSR mental model**:

There are two separate builds and two separate entry points:
- **Client build** (`entry-client.tsx`): calls `ReactDOM.hydrateRoot()` to hydrate server HTML
- **Server build** (`entry-server.tsx`): called by the server to render to string

```typescript
// entry-server.tsx
import { renderToString } from 'react-dom/server'
import { StaticRouter } from 'react-router-dom/server'
import App from './App'

export function render(url: string) {
  return renderToString(
    <StaticRouter location={url}>
      <App />
    </StaticRouter>
  )
}
```

```typescript
// entry-client.tsx
import { hydrateRoot } from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import App from './App'

hydrateRoot(
  document.getElementById('root')!,
  <BrowserRouter>
    <App />
  </BrowserRouter>
)
```

**Two Vite build commands**:
```bash
# client build (browser bundle)
vite build --outDir dist/client

# server build (Node.js bundle)
vite build --ssr src/entry-server.tsx --outDir dist/server
```

**The server** (Express example):
```typescript
// server.ts
import express from 'express'
import { readFileSync } from 'fs'
import { createServer as createViteServer } from 'vite'

const isProd = process.env.NODE_ENV === 'production'

async function createServer() {
  const app = express()

  if (!isProd) {
    // Development: use Vite middleware
    const vite = await createViteServer({ server: { middlewareMode: true }, appType: 'custom' })
    app.use(vite.middlewares)
    
    app.use('*', async (req, res) => {
      const url = req.originalUrl
      let template = readFileSync('index.html', 'utf-8')
      template = await vite.transformIndexHtml(url, template)
      const { render } = await vite.ssrLoadModule('/src/entry-server.tsx')
      const appHtml = render(url)
      const html = template.replace('<!--app-html-->', appHtml)
      res.end(html)
    })
  } else {
    // Production: serve pre-built files
    app.use('/assets', express.static('dist/client/assets'))
    app.use('*', async (req, res) => {
      const template = readFileSync('dist/client/index.html', 'utf-8')
      const { render } = await import('./dist/server/entry-server.js')
      const appHtml = render(req.originalUrl)
      const html = template.replace('<!--app-html-->', appHtml)
      res.end(html)
    })
  }

  app.listen(3000)
}
```

**In practice**: Most teams use a framework on top of Vite (Nuxt, SvelteKit, Astro, Remix) rather than hand-rolling SSR. These frameworks handle the two-entry-point complexity, streaming SSR, data fetching, and hydration mismatches. Only build custom SSR if you have requirements these frameworks can't meet.

#### Library Mode

When building a component library or utility package to publish on npm, use library mode:

```typescript
// vite.config.ts
import { resolve } from 'path'

export default defineConfig({
  build: {
    lib: {
      entry: resolve(__dirname, 'src/index.ts'),
      name: 'MyLib',                         // UMD global name
      formats: ['es', 'cjs'],                // output formats
      fileName: (format) => `my-lib.${format}.js`,
    },
    rollupOptions: {
      // Don't bundle peer dependencies
      external: ['react', 'react-dom', 'react/jsx-runtime'],
      output: {
        globals: {
          react: 'React',
          'react-dom': 'ReactDOM',
        },
      },
    },
  },
})
```

This produces:
- `dist/my-lib.es.js` — ESM bundle (tree-shakable, for bundlers)
- `dist/my-lib.cjs.js` — CommonJS bundle (for Node.js and older tooling)

Your published `package.json` should specify both:
```json
{
  "main": "./dist/my-lib.cjs.js",
  "module": "./dist/my-lib.es.js",
  "exports": {
    ".": {
      "import": "./dist/my-lib.es.js",
      "require": "./dist/my-lib.cjs.js"
    }
  }
}
```

**CSS in libraries**: CSS imported by library components needs special handling. By default, Vite injects CSS at runtime via JS when the component is used. Some library consumers want separate CSS files. A common solution: use CSS modules (scoped by default) and configure build to emit CSS or let consumers handle styling.

#### Multi-Page Applications (MPA)

If your project has multiple HTML entry points (not a SPA — actual separate pages):

```typescript
// vite.config.ts
import { resolve } from 'path'

export default defineConfig({
  build: {
    rollupOptions: {
      input: {
        main: resolve(__dirname, 'index.html'),
        admin: resolve(__dirname, 'admin/index.html'),
        auth: resolve(__dirname, 'auth/index.html'),
      },
    },
  },
})
```

Each HTML file gets its own entry chunk. Shared code is automatically extracted to vendor chunks.

#### Migration from Create React App (CRA)

CRA uses webpack under the hood. Migrating to Vite:

1. **Remove CRA dependencies**: `react-scripts`
2. **Install Vite**:
   ```bash
   npm install --save-dev vite @vitejs/plugin-react
   ```
3. **Move `index.html`** from `public/` to the project root. Update the `%PUBLIC_URL%` references to just `/`.
4. **Add `<script type="module" src="/src/index.tsx">` to `index.html`**.
5. **Create `vite.config.ts`**.
6. **Replace `process.env.REACT_APP_*`** with `import.meta.env.VITE_*`.
7. **Update `package.json` scripts**: `start` → `vite`, `build` → `vite build`.
8. **Fix any `require()` or CJS patterns** that CRA's webpack handled but Vite doesn't.
9. **Add `vite-env.d.ts`** with `/// <reference types="vite/client" />`.

Common CRA migration issues:
- SVG imports: CRA exposed `ReactComponent` named export from SVGs. In Vite, use `vite-plugin-svgr`.
- Global `process.env.NODE_ENV`: Replace with `import.meta.env.MODE` or add a `define: { 'process.env.NODE_ENV': JSON.stringify(mode) }` to config.
- CSS imports with `?url` suffix (CRA allowed arbitrary imports): Vite uses query suffixes more specifically.

---

### Vite Mastery Checklist

---

#### Foundations

- [ ] Can explain why Vite is faster than webpack during development without consulting documentation
- [ ] Understands the difference between esbuild and Rollup and why Vite uses each
- [ ] Can explain what a native ES module is and why it matters
- [ ] Understands the dependency pre-bundling step — what triggers it, where output goes, when it re-runs
- [ ] Can explain HMR conceptually — what an HMR boundary is, what causes a full reload

#### Configuration

- [ ] Can write a `vite.config.ts` from scratch for a React + TypeScript project
- [ ] Understands `resolve.alias` and can sync it with `tsconfig.json` paths
- [ ] Can configure the dev server proxy to forward API requests to a backend
- [ ] Understands `import.meta.env` and the `VITE_` prefix security model
- [ ] Can configure `build.sourcemap`, `build.target`, and `build.rollupOptions`
- [ ] Knows when to use `optimizeDeps.include` and `optimizeDeps.exclude`

#### Development

- [ ] Can debug why HMR isn't working for a specific component
- [ ] Can interpret Vite's startup output and understand what each line means
- [ ] Can configure Vite for Docker/WSL2 environments (polling, host settings)
- [ ] Understands what `server.fs.allow` and `server.fs.deny` control

#### Production

- [ ] Can analyze a production bundle and identify optimization opportunities
- [ ] Can configure code splitting with `manualChunks`
- [ ] Can implement route-based lazy loading with `React.lazy` + `import()`
- [ ] Understands asset hashing and can configure correct cache headers
- [ ] Can deploy a Vite SPA to Nginx, Netlify, and Vercel with correct SPA routing config
- [ ] Understands `base` path configuration for sub-path deployments

#### TypeScript

- [ ] Understands that Vite does not type-check — only strips types
- [ ] Can configure `tsconfig.json` correctly for a Vite project (including `isolatedModules`)
- [ ] Can add type declarations for custom `import.meta.env` variables
- [ ] Knows to run `tsc --noEmit` separately for type validation

#### Plugins

- [ ] Can write a custom Vite plugin with a `transform` hook
- [ ] Understands plugin execution order and `enforce: 'pre' | 'post'`
- [ ] Has used `vite-plugin-inspect` to debug plugin behavior
- [ ] Can configure at least: `@vitejs/plugin-react`, `vite-tsconfig-paths`, `rollup-plugin-visualizer`

#### Advanced

- [ ] Can implement a basic SSR setup with two entry points
- [ ] Can configure library mode to produce ESM + CJS bundles
- [ ] Can set up Vite in a monorepo with local package symlinks
- [ ] Can migrate a CRA or webpack project to Vite
- [ ] Can configure and debug `optimizeDeps` for complex dependency graphs

---

### Skills Expected from a Professional Frontend/Full-Stack Developer Using Vite

A production-level developer using Vite is expected to:

**Debug without guessing**: When something breaks (blank page, import error, HMR not working), they have a systematic process: check the browser console, check the network tab, use `DEBUG=vite:*`, use `vite-plugin-inspect`, check the module graph. They don't randomly change things hoping it helps.

**Own the build pipeline**: They understand what happens between `vite build` and a user loading the page. They know where sourcemaps come from, why asset hashes look the way they do, and how to configure caching headers correctly.

**Keep bundles under control**: They analyze production bundles before major releases. They know which libraries are large, which can be replaced with smaller alternatives, and how to split chunks effectively. They treat bundle size as a product metric.

**Configure for their environment**: They know the differences between dev, staging, and production configurations. They know how to handle secrets correctly (never in `VITE_*`), how to configure the base path for deployments, and how to debug environment variable issues.

**Write and read plugins**: They can write a simple custom plugin for project-specific transforms. They can read existing plugin source code to understand what it does.

**Integrate with backend**: They can configure the dev server proxy, structure a full-stack project, and understand the difference between frontend-only static deployment and an SSR setup.

---

### Recommended Learning Path After Mastering Vite

Once Vite's tooling is solid, the natural progression:

**Immediate next steps**:
- **Vitest**: Vite's native unit testing framework. Uses the same `vite.config.ts`, same transforms, same ESM model. Faster than Jest for Vite projects. Shares nearly identical API with Jest.
- **Storybook with Vite**: Storybook's Vite builder runs component stories in Vite's dev server. Deeper understanding of component isolation and design system tooling.

**Framework-level depth**:
- **TanStack Router**: Type-safe file-based routing with deep Vite integration. The future of React routing.
- **Nuxt** (Vue): Full-stack Vue framework built on Vite. Understanding Nuxt's module system deepens Vite plugin knowledge.
- **SvelteKit**: Full-stack Svelte framework on Vite. Elegant SSR and file-based routing model.
- **Astro**: Multi-framework static site generator on Vite. Its "islands" architecture is important for performance-first thinking.

**Production infrastructure**:
- **Rollup internals**: Vite's production bundler. Understanding Rollup at a deeper level — its plugin hooks, its output format, its tree shaking algorithm — makes you better at diagnosing Vite build issues.
- **esbuild Go API**: For teams writing custom tooling, understanding esbuild's architecture and plugin model at a lower level.
- **Turbopack/Rspack**: Webpack-compatible bundlers written in Rust. Understanding the broader bundler landscape and where Vite sits in it.

**Platform and deployment**:
- **Edge computing** (Cloudflare Workers, Deno Deploy): Deploying Vite apps and SSR to edge runtimes. Understanding `workerd` and the differences from Node.js.
- **Docker + multi-stage builds**: Packaging Vite applications correctly (separate build and serve stages, environment variable handling in containers).

**Tooling engineering**:
- **Unplugin**: A unified plugin interface for Vite, Rollup, webpack, and esbuild. For teams building tools that must work across bundlers.
- **Oxc (JavaScript toolchain in Rust)**: The emerging Rust-based JavaScript toolchain. Understanding it now positions you for the next wave of tooling, as it will likely influence Vite's internals.