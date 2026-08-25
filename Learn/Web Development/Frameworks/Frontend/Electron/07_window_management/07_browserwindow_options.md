## BrowserWindow Options


The BrowserWindow constructor accepts a comprehensive options object that controls both the appearance and behavior of application windows. These options are divided into window-level properties inherited from BaseWindow and web page-specific settings configured through the `webPreferences` object.[1][2]

### Dimension and Position Options

Window dimensions are controlled through several related options that define initial size and constraints. The `width` option sets the window's width in pixels, defaulting to 800, while `height` sets the height, defaulting to 600. The `x` and `y` options position the window at specific screen coordinates—`x` controls the left offset from the screen, and `y` controls the top offset. Both `x` and `y` must be provided together; if either is omitted, the window is centered.[2][3]

The `useContentSize` option changes how dimensions are interpreted—when `true`, `width` and `height` represent the web page's size, excluding window frame dimensions. This ensures precise content sizing regardless of frame thickness. Size constraints prevent inappropriate window dimensions: `minWidth` and `minHeight` set minimum dimensions (defaulting to 0), while `maxWidth` and `maxHeight` set maximum dimensions (defaulting to no limit).[3][4][2]

The `center` option automatically positions the window in the screen center, overriding any `x` or `y` values. The `movable` option (macOS and Windows) determines whether users can drag the window to new positions, defaulting to `true`. The `resizable` option controls manual resizing capability, defaulting to `true`.[2][3]

### Window Appearance Options

The `frame` option removes all operating system chrome when set to `false`, creating frameless windows with only web content visible. The `show` option determines immediate visibility—setting it to `false` creates hidden windows that must be shown manually with `show()`, preventing visual flashes during initialization. The `backgroundColor` option sets the window's background color using hexadecimal values or color names, appearing before page load and through transparent areas.[4][2]

Transparency options enable various visual effects. The `transparent` option makes the window background fully transparent, allowing per-pixel transparency through CSS. The `opacity` option (macOS and Windows) creates uniform semi-transparency, accepting values from 0.0 (invisible) to 1.0 (opaque). Note that `transparent` and `opacity` serve different purposes—`transparent` enables selective transparency via CSS, while `opacity` applies uniform transparency to the entire window.[5][2]

The `hasShadow` option controls drop shadow display, defaulting to platform-specific behavior on macOS and Windows with no effect on Linux. The `roundedCorners` option (macOS) enables rounded window corners, defaulting to `true`. The `thickFrame` option (Windows) adds standard window frames and chrome, typically used with `frame: false` to create semi-frameless windows retaining resize handles.[6][2]

### Title Bar Customization

The `title` option sets the default window title as a string. The `titleBarStyle` option (macOS and Windows) customizes title bar appearance with several values. The `default` value shows the standard title bar, `hidden` hides the title bar while showing window controls, `hiddenInset` hides the title bar with inset controls, and `customButtonsOnHover` uses custom-drawn buttons appearing on hover.[7][2]

The `titleBarOverlay` option (Windows and macOS) enables additional title bar customization for frameless windows. When enabled with specific configurations, it allows web content to extend into the title bar area while preserving window controls. The `autoHideMenuBar` option hides the menu bar unless users press Alt, providing cleaner interfaces while maintaining menu accessibility.[2]

copy with with examples. highest header level should only be 3. context electron

Here’s a well-organized explanation of **title bar customization in Electron** with examples, following your formatting constraints.

***

### Title Bar Customization in Electron

Electron provides several options in the `BrowserWindow` constructor to control how the title bar and window frame appear. These options affect both the aesthetics and user interaction across macOS, Windows, and Linux.

#### `title`

The `title` option sets the **default window title**. This title appears in the window’s title bar (if visible) and task switchers.

**Example:**

```js
const win = new BrowserWindow({
  title: "My Electron App",
  width: 800,
  height: 600
});
```

You can later update it dynamically using:

```js
win.setTitle("New Title");
```

#### `titleBarStyle`

The `titleBarStyle` option customizes the **appearance of the title bar** on macOS and Windows. It determines the visibility and behavior of window controls (close, minimize, maximize).

Available values:

- **`default`** – Shows the standard operating system title bar.  
- **`hidden`** – Hides the title bar but keeps the window controls visible.  
- **`hiddenInset`** – Similar to `hidden`, but with controls slightly inset from the window edge.  
- **`customButtonsOnHover`** – Draws custom window buttons that only appear when hovered.

**Example:**

```js
const win = new BrowserWindow({
  width: 800,
  height: 600,
  titleBarStyle: "hiddenInset"
});
```

#### `titleBarOverlay`

Introduced to improve design flexibility, `titleBarOverlay` lets you **extend web content into the title bar area** while keeping the native window controls. It’s especially useful for creating **modern, integrated layouts**.

Only applicable on **macOS and Windows** when using a **frameless window** (`frame: false`).

**Example (Windows/macOS):**

```js
const win = new BrowserWindow({
  width: 900,
  height: 600,
  frame: false,
  titleBarOverlay: {
    color: "#2f3241",
    symbolColor: "#74b1be",
    height: 30
  }
});
```

In your web page, you can then style the top area as part of your layout, using CSS to align with the custom overlay.

#### `autoHideMenuBar`

This option **hides the menu bar** by default, showing it only when the user presses the `Alt` key (Windows/Linux). It’s great for clean, minimal UIs.

**Example:**

```js
const win = new BrowserWindow({
  width: 800,
  height: 600,
  autoHideMenuBar: true
});
```

To always show the menu again:

```js
win.setAutoHideMenuBar(false);
win.setMenuBarVisibility(true);
```

### Window Behavior Options

The `modal` option creates modal windows that disable parent window interaction until closed, requiring the `parent` option to specify the parent BrowserWindow. The `parent` option establishes parent-child relationships, causing child windows to always appear on top of parents and close automatically when parents close.[8][2]

The `alwaysOnTop` option keeps windows above all others, useful for floating palettes or overlay interfaces. The `fullscreen` option starts windows in fullscreen mode, while `kiosk` enters kiosk mode that prevents users from exiting fullscreen. The `fullscreenable` option (macOS) controls whether the maximize button enters fullscreen or merely maximizes the window.[2]

The `skipTaskbar` option (Windows and macOS) prevents windows from appearing in taskbars or docks, appropriate for utility windows. The `focusable` option determines keyboard focus capability, defaulting to `true`—non-focusable windows cannot accept keyboard input but still receive mouse events.[2]

### Advanced Window Options

The `type` option sets platform-specific window types affecting behavior and appearance. On macOS, values include `desktop`, `textured`, `panel`, and `toolbar`. On Windows, `toolbar` creates elevated-appearance windows. On Linux, values include `desktop`, `dock`, `toolbar`, `splash`, and `notification`, each producing different window manager behaviors.[2]

The `enableLargerThanScreen` option (macOS) allows windows larger than screen dimensions, useful for multi-monitor setups or zoomed content. The `acceptFirstMouse` option (macOS) determines whether clicks on inactive windows activate them and pass through to content (true) or require separate activation and interaction clicks (false).[2]

The `tabbingIdentifier` option (macOS) groups windows into native tabs—windows with matching identifiers can be merged into tab groups. The `vibrancy` option (macOS) applies blur and translucency effects with values like `appearance-based`, `light`, `dark`, `titlebar`, `selection`, `menu`, `popover`, `sidebar`, and others. The `backgroundMaterial` option (Windows 11) provides similar effects with values `auto`, `none`, `mica`, `acrylic`, and `tabbed`.[9][2]

### WebPreferences Options

The `webPreferences` object configures the renderer process and web page behavior, nested within the main options object. This critical subsection controls security, Node.js integration, preload scripts, and rendering features.[10][2]

#### Security and Sandboxing

The `nodeIntegration` option enables Node.js APIs in the renderer process, defaulting to `false` for security. The `contextIsolation` option runs Electron APIs and preload scripts in a separate JavaScript context, defaulting to `true` since it prevents loaded content from tampering with preload scripts. The `sandbox` option enables Chromium's OS-level sandbox, defaulting to `true` since Electron 20—it disables Node.js but maintains limited preload script APIs.[11][4][10]

The `webSecurity` option enforces same-origin policy when `true` (default), while `false` disables security for testing. The `allowRunningInsecureContent` option permits HTTPS pages to load HTTP resources when `true`, defaulting to `false`. These security options should be carefully configured based on content trust levels.[12][10]

#### Preload Scripts and Sessions

The `preload` option specifies an absolute file path to a script loaded before other page scripts. Preload scripts always have Node.js API access regardless of `nodeIntegration` settings, making them ideal for exposing safe APIs to renderers via `contextBridge`. The `additionalArguments` option passes strings to `process.argv` in the renderer, useful for transmitting configuration to preload scripts.[4][10][11]

#### Session and Partition Options in Electron

Electron’s `BrowserWindow` constructor supports both the `session` and `partition` options, which control how browser data (like cookies, cache, and storage) is managed. These options define **how different instances of your app isolate or share browsing data**.

##### `session` Option

The `session` option directly assigns a **specific `Session` object** from the `electron.session` module to the window. This gives you complete control over what browser storage or network configuration the window uses.  

If you provide this option, it **overrides** any `partition` setting.

**Example:**

```js
const { app, BrowserWindow, session } = require('electron');

app.whenReady().then(() => {
  // Create a custom session
  const customSession = session.fromPartition('persist:customSession');

  // Assign it explicitly to the new window
  const win = new BrowserWindow({
    width: 800,
    height: 600,
    session: customSession
  });

  win.loadURL('https://example.com');
});
```

In this example:
- A named persistent session (`persist:customSession`) is created.
- The same session is reused for multiple windows if desired, ensuring shared cookies and cache.

##### `partition` Option

Instead of manually creating a session object, you can specify a **partition** string. Electron automatically manages sessions based on this string.

**Partition rules:**
- When the string starts with **`persist:`**, the session is **persistent**, meaning data survives app restarts.
- When it **does not** start with `persist:`, the session is **in-memory only** and will be cleared when the window closes or the app exits.

**Example (Persistent Session):**

```js
const win1 = new BrowserWindow({
  partition: 'persist:sharedSession'
});

const win2 = new BrowserWindow({
  partition: 'persist:sharedSession'
});
```

Both windows will share the same session data (cookies, local storage, etc.), much like two tabs in the same browser profile.

**Example (In-Memory Session):**

```js
const win = new BrowserWindow({
  partition: 'tempSession'
});
```

Here, the session’s data exists only while the window is open. This is ideal for private windows or temporary browsing contexts.

##### Session vs. Partition Precedence

When both `session` and `partition` options are provided:
- The **`session`** option **takes precedence**.
- The `partition` value is ignored in that case.

**Example:**

```js
const win = new BrowserWindow({
  session: session.fromPartition('persist:mainSession'),
  partition: 'persist:otherSession' // Ignored
});
```

This ensures that if you explicitly provide a `Session` object, Electron will use it—regardless of any `partition` setting.

#### Node.js and Worker Integration

Electron provides advanced configuration options that control the availability of Node.js APIs in **web workers** and **subframes (iframes and child windows)**. These features allow developers to use Node.js beyond the main renderer thread — improving flexibility and enabling more complex architectures.

***

##### `nodeIntegrationInWorker`

By default, Electron’s renderer process **does not allow Node.js APIs inside web workers** for security and isolation reasons. The `nodeIntegrationInWorker` option changes this by enabling Node.js integration within **web workers** (created via `new Worker()`).

This can be useful when you want to offload CPU-heavy or asynchronous operations to background threads while still having access to filesystem operations, `crypto`, or other Node modules.

**Default:** `false`

**Example (Node.js enabled in web worker):**

```js
// main.js
const { app, BrowserWindow } = require('electron');

app.whenReady().then(() => {
  const win = new BrowserWindow({
    webPreferences: {
      nodeIntegration: true,
      nodeIntegrationInWorker: true // Enable Node.js in web workers
    }
  });

  win.loadFile('index.html');
});
```

```js
// index.html
<script>
  const worker = new Worker('worker.js'); // Worker with Node access
</script>
```

```js
// worker.js
const fs = require('fs'); // Node.js API in worker
fs.writeFileSync('example.txt', 'Hello from worker!');
```

This enables the background worker to perform Node-enabled tasks, such as reading or writing files, without blocking the main renderer thread.

***

##### `nodeIntegrationInSubFrames`

The `nodeIntegrationInSubFrames` option (currently **experimental**) allows **Node.js APIs** to run in **iframes** or **child windows** created within a renderer that itself has Node integration. It also ensures the specified **preload scripts** run for each iframe.

Because this setup expands the JavaScript environment’s power considerably, it should be used cautiously — especially when loading remote or untrusted content.

**Default:** `false`

**Key behavior:**
- When enabled, **iframes and subwindows** can access Node.js modules.
- The `process.isMainFrame` property can be used inside preload scripts to **check whether code is running in the main frame or a subframe**.

**Example (Node.js in iframe):**

```js
// main.js
const { app, BrowserWindow } = require('electron');

app.whenReady().then(() => {
  const win = new BrowserWindow({
    webPreferences: {
      nodeIntegration: true,
      nodeIntegrationInSubFrames: true,
      preload: `${__dirname}/preload.js`
    }
  });

  win.loadFile('index.html');
});
```

```js
// preload.js
console.log('Is main frame?', process.isMainFrame); // true or false
if (!process.isMainFrame) {
  const os = require('os');
  console.log('Running in iframe, platform:', os.platform());
}
```

```html
<!-- index.html -->
<iframe src="subframe.html"></iframe>
```

```html
<!-- subframe.html -->
<script>
  // Can access Node.js here if nodeIntegrationInSubFrames is true
  const { remote } = require('electron');
  console.log('Subframe has Node.js access');
</script>
```

***

##### When to Use These Optio9ns

Use these integrations strategically:
- **`nodeIntegrationInWorker`**: Safe for internal app logic, e.g., parallelizing file parsing or data processing.
- **`nodeIntegrationInSubFrames`**: Useful when building full-fledged internal tools or dashboards with modular views—but avoid when displaying external content for security reasons.

#### Developer Tools and Debugging

The `devTools` option enables DevTools access—when `false`, `BrowserWindow.webContents.openDevTools()` cannot open DevTools. Disabling DevTools improves security for production applications by preventing code inspection.[10]

#### Content Rendering Options

The `javascript` option enables JavaScript execution, defaulting to `true`. The `images` option enables image rendering, defaulting to `true`. The `imageAnimationPolicy` option controls GIF and animated image playback with values `animate` (default), `animateOnce`, or `noAnimation`.[10]

The `webgl` option enables WebGL support, defaulting to `true`. The `plugins` option enables plugin support, defaulting to `false`. The `experimentalFeatures` option enables Chromium experimental features, defaulting to `false`.[10]

#### Zoom and Font Options

The `zoomFactor` option sets default page zoom, where `3.0` represents 300%, defaulting to `1.0`. The `defaultFontFamily` object specifies default fonts for various font families: `standard`, `serif`, `sansSerif`, `monospace`, `cursive`, `fantasy`, and `math`, each with platform-specific defaults. The `defaultFontSize` option sets base font size (defaulting to 16), while `defaultMonospaceFontSize` sets monospace font size (defaulting to 13). The `minimumFontSize` option prevents fonts smaller than specified size, defaulting to 0.[12][10]

#### Performance and Throttling

Electron provides several `webPreferences` options to optimize performance and resource usage, particularly when dealing with background windows or repeated script execution. These options help balance responsiveness with efficiency.

***

##### `backgroundThrottling`

The `backgroundThrottling` option controls whether Electron **throttles animations and timers** when a window or tab is not visible (in the background). Throttling reduces CPU and battery usage by slowing down or pausing tasks that don't need to run at full speed when hidden.

**Default:** `true`

**Behavior:**
- When `true`, background pages slow down `requestAnimationFrame`, `setTimeout`, and other timers.
- The **Page Visibility API** (`document.hidden`, `visibilitychange` event) is also affected.
- If **any `webContents` in a `BrowserWindow`** disables throttling, the entire window continues rendering frames at full speed.

**Example (Disable throttling for a real-time dashboard):**

```js
const { app, BrowserWindow } = require('electron');

app.whenReady().then(() => {
  const win = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      backgroundThrottling: false // Keep animations/timers running
    }
  });

  win.loadFile('dashboard.html');
});
```

**Use case:**
- **Enable throttling (`true`)**: For static windows, documentation viewers, or forms where background activity isn't critical.
- **Disable throttling (`false`)**: For real-time dashboards, stock tickers, monitoring tools, or music visualizers that need continuous updates even when minimized.

**Example (Check visibility state in renderer):**

```html
<!-- dashboard.html -->
<script>
  document.addEventListener('visibilitychange', () => {
    if (document.hidden) {
      console.log('Window is now hidden');
    } else {
      console.log('Window is now visible');
    }
  });

  // Animation continues even when hidden if backgroundThrottling: false
  function animate() {
    console.log('Animating...');
    requestAnimationFrame(animate);
  }
  animate();
</script>
```

***

##### `v8CacheOptions`

The `v8CacheOptions` option controls how **V8 (Chromium's JavaScript engine) caches compiled code**. Code caching significantly improves **startup performance** by reusing previously compiled JavaScript instead of recompiling it on every launch.

**Default:** `'code'`

**Available values:**

| Value                              | Behavior                                                                             |
| ---------------------------------- | ------------------------------------------------------------------------------------ |
| `'none'`                           | Disables code caching entirely                                                       |
| `'code'`                           | Uses heuristics to cache "hot" code (frequently executed)                            |
| `'bypassHeatCheck'`                | Caches code without waiting for heuristic checks; uses lazy compilation              |
| `'bypassHeatCheckAndEagerCompile'` | Caches all code immediately with eager compilation (fastest startup after first run) |

**Example (Maximize startup speed with eager compilation):**

```js
const { app, BrowserWindow } = require('electron');

app.whenReady().then(() => {
  const win = new BrowserWindow({
    width: 900,
    height: 700,
    webPreferences: {
      v8CacheOptions: 'bypassHeatCheckAndEagerCompile' // Aggressive caching
    }
  });

  win.loadFile('index.html');
});
```

**Use case:**
- **`'none'`**: For development or debugging where you want fresh compilation every time.
- **`'code'`** (default): Good balance for most apps—only caches frequently-run code.
- **`'bypassHeatCheck'`**: Speeds up apps with moderate script sizes.
- **`'bypassHeatCheckAndEagerCompile'`**: Best for large apps (IDEs, editors) with heavy JavaScript bundles that load repeatedly.

**Example (Measuring startup improvement):**

```js
// main.js
const { app, BrowserWindow } = require('electron');

app.whenReady().then(() => {
  console.time('Window Load');

  const win = new BrowserWindow({
    webPreferences: {
      v8CacheOptions: 'bypassHeatCheckAndEagerCompile'
    }
  });

  win.loadFile('index.html');

  win.webContents.on('did-finish-load', () => {
    console.timeEnd('Window Load'); // Check startup time
  });
});
```

After the first launch, subsequent startups should be noticeably faster as V8 reuses compiled code.

***

##### When to Use These Options

**Combine both for optimal performance:**

```js
const win = new BrowserWindow({
  webPreferences: {
    backgroundThrottling: false, // For always-active monitoring apps
    v8CacheOptions: 'bypassHeatCheckAndEagerCompile' // Fast cold starts
  }
});
```

This configuration suits apps that need **constant activity** (like system monitors or chat clients) and benefit from **fast launches**.

#### Platform-Specific Options

The `scrollBounce` option (macOS) enables rubber banding scroll effects, defaulting to `false`. This creates the elastic bounce effect when scrolling beyond content boundaries on macOS.[10]

#### Dialog and Navigation Options

The `safeDialogs` option enables browser-style consecutive dialog protection, preventing infinite alert loops and defaulting to `false`. The `safeDialogsMessage` option customizes the protection message, though it remains in English without localization. The `disableDialogs` option completely disables all dialogs, overriding `safeDialogs` and defaulting to `false`.[10]

The `navigateOnDragDrop` option causes dragging files or links onto pages to navigate, defaulting to `false`. The `autoplayPolicy` option controls media autoplay with values `no-user-gesture-required` (default), `user-gesture-required`, or `document-user-activation-required`.[12

copy but with more short explanations

The `autoplayPolicy` option configures how media (audio/video) is allowed to start playing in an Electron `BrowserWindow`.

- `no-user-gesture-required` (default): Media can autoplay as soon as it’s ready, without any user interaction.
- `user-gesture-required`: Media can only autoplay after a user action in the page (like a click or keypress).
- `document-user-activation-required`: Stricter; the document must have an explicit activation (such as interacting directly with the media or page) before autoplay is allowed.

#### Specialized Rendering Options

The `offscreen` option enables offscreen rendering for headless automation or custom rendering pipelines, defaulting to `false`. The `useSharedTexture` option (experimental) enables GPU-accelerated offscreen rendering via shared textures, defaulting to `false`. The `sharedTexturePixelFormat` option (experimental) specifies output format as `argb` (8-bit RGBA, SRGB SDR, default) or `rgbaf16` (16-bit float RGBA, scRGB HDR).[10]

The `enablePreferredSizeMode` option enables preferred size mode, where the window communicates the minimum size needed to display content without scrolling via `preferred-size-changed` events, defaulting to `false`.[12][10]

#### Feature Flags

The `enableBlinkFeatures` option enables specific Chromium Blink features via comma-separated strings like `CSSVariables,KeyboardEventKey`. The `disableBlinkFeatures` option disables features using the same format. The full list of supported features is found in Chromium's RuntimeEnabledFeatures.json5 file.[13][10]

#### Accessibility and Miscellaneous

The `accessibleTitle` option provides alternative window titles for accessibility tools like screen readers, invisible to regular users. The `spellcheck` option enables the built-in spellchecker, defaulting to `true`. The `enableWebSQL` option enables the deprecated WebSQL API, defaulting to `true`.[10]

The `textAreasAreResizable` option makes textarea elements user-resizable, defaulting to `true`. The `disableHtmlFullscreenWindowResize` option prevents window resizing when entering HTML fullscreen, defaulting to `false`.[10]

The `webviewTag` option enables the `<webview>` tag for embedding isolated guest content, defaulting to `false`. When enabled, preload scripts in webviews have Node.js integration, so developers must validate webview settings using the `will-attach-webview` event to prevent malicious preload scripts.[10]

#### Rendering Initialization

The `paintWhenInitiallyHidden` option determines whether the renderer should be active when created with `show: false`, defaulting to `true`. Setting it to `false` ensures `document.visibilityState` works correctly on first load with hidden windows but prevents the `ready-to-show` event from firing. This option balances correct visibility state reporting against event-driven initialization patterns.[2]

Sources
[1] BrowserWindow https://electronjs.org/docs/latest/api/browser-window
[2] Electron js tutorial for beginners # Important App life cycle ... https://www.youtube.com/watch?v=ECq-mMdKepc
[3] BaseWindowConstructorOptions Object - Electron https://electronjs.org/docs/latest/api/structures/base-window-options
[4] BrowserWindow | FAQ https://imfly.github.io/electron-docs-gitbook/en/api/browser-window.html
[5] app · Electron documentation https://tinydew4.gitbooks.io/electron/api/app.html
[6] [Bug]: window transparency not respected (black/gray ... https://github.com/electron/electron/issues/40515
[7] Frameless Window | Electron https://zeke.github.io/electron.atom.io/docs/api/frameless-window/
[8] Electron browser window - Stack Overflow https://stackoverflow.com/questions/47673817/electron-browser-window
[9] Process Model https://electronjs.org/docs/latest/tutorial/process-model
[10] BrowserWindow · GitBook http://electron.ebookchain.org/en/api/browser-window.html
[11] Electron Plugin https://app-config.dev/guide/electron.html
[12] WebPreferences Object https://electronjs.org/docs/latest/api/structures/web-preferences
[13] BrowserWindowConstructorOptio... https://electronjs.org/docs/latest/api/structures/browser-window-options
[14] Electron.js 11.0.4 - BrowserWindow is not a contructor https://stackoverflow.com/questions/65203027/electron-js-11-0-4-browserwindow-is-not-a-contructor
[15] Add an option to BrowserWindow constructor to set global ... https://github.com/electron/electron/issues/6504
[16] If I run my app in frameless mode, the window is 2 pixels larger than ... https://www.reddit.com/r/electronjs/comments/ignx2h/if_i_run_my_app_in_frameless_mode_the_window_is_2/

---


