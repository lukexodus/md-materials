## Window Events and Lifecycle


Electron's BrowserWindow provides a comprehensive event system that tracks the complete lifecycle of application windows, from creation through destruction. Understanding these events enables developers to build responsive applications with graceful loading states, proper resource cleanup, and optimized user experiences.[1]

### Window Creation and Display Events

The `ready-to-show` event is emitted when the renderer process has rendered the page for the first time while the window remains hidden. This event is crucial for preventing visual flashes during window initialization—developers should create windows with `show: false` and call `show()` only after this event fires. The event typically occurs after `did-finish-load`, though pages with many remote resources may emit it earlier. Note that using this event implies the renderer is considered "visible" and will paint even when `show` is false, and it will never fire if `paintWhenInitiallyHidden: false` is set.[1]

The `show` and `hide` events fire when windows are shown or hidden respectively. The `show` event occurs when the window becomes visible to users, while `hide` triggers when the window is concealed through programmatic calls or user action.[2][1]

### Focus and Blur Events

The `focus` event is emitted when the window gains focus, while the `blur` event fires when the window loses focus. These events are essential for implementing features like auto-pause in media applications or tracking active window state. At the application level, the app module provides `browser-window-focus` and `browser-window-blur` events that fire when any BrowserWindow in the application gains or loses focus, passing the affected window as a parameter.[3][4][2][1]

### Window State Events

Windows can transition between various states, each triggering corresponding events. The `maximize` event fires when the window is maximized, while `unmaximize` occurs when exiting a maximized state. Similarly, `minimize` is emitted when the window is minimized, and `restore` fires when restoring from a minimized state. Fullscreen transitions trigger `enter-full-screen` and `leave-full-screen` events for native fullscreen, plus `enter-html-full-screen` and `leave-html-full-screen` for HTML API-triggered fullscreen.[2][1]

### Resize and Move Events

The `will-resize` event (macOS and Windows) fires before the window is resized, allowing prevention via `event.preventDefault()`. It includes details about the new bounds and the edge being dragged, though it only fires for manual resizing—programmatic calls to `setBounds` or `setSize` do not trigger it. The `resize` event fires after resizing completes, while `resized` (macOS and Windows) emits once when resizing finishes, including after animated `setBounds`/`setSize` calls on macOS.[1]

Similarly, `will-move` (macOS and Windows) fires before manual window movement, while `move` triggers during movement. The `moved` event (macOS and Windows) fires once when movement completes, and on macOS it's aliased to `move`.[1]

### Close and Cleanup Events

The window close lifecycle involves multiple events that provide opportunities for cleanup and user confirmation. The `close` event fires when the window is going to be closed, before the DOM's `beforeunload` and `unload` events. Calling `event.preventDefault()` cancels the close operation. Developers typically use the `beforeunload` handler in the renderer process to decide whether the window should close—returning any value other than `undefined` will cancel the close in Electron.[1]

The `closed` event fires after the window has closed completely. After receiving this event, you must remove references to the window and avoid using it further to prevent memory leaks. The `destroy()` method forces immediate closure without emitting `unload` or `beforeunload` events in the renderer, though it still guarantees the `closed` event fires.[1]

### Responsiveness Events

The `unresponsive` event fires when the web page becomes unresponsive, typically indicating the renderer process is blocked. The `responsive` event fires when an unresponsive page becomes responsive again. These events are critical for implementing user notifications or recovery mechanisms when the renderer hangs.[2][1]

### Application-Level Lifecycle Events

The app module controls the entire application lifecycle through events that manage all windows collectively. The `ready` event fires once when Electron finishes initialization and is the earliest point where BrowserWindow instances can be safely created. The `will-finish-launching` event occurs during basic startup (equivalent to `ready` on Windows and Linux, but earlier on macOS).[3][1]

The `window-all-closed` event fires when all windows have been closed. If no listener is registered, the default behavior is to quit the application, but subscribing to this event gives you control over whether to quit. On macOS, applications commonly stay active even after all windows close, so developers often check the platform before calling `app.quit()`.[3]

The `before-quit` event fires before the application starts closing windows, and `event.preventDefault()` can delay termination. The `will-quit` event occurs after all windows close and the app is about to quit—again, `event.preventDefault()` can prevent termination. Finally, the `quit` event fires when the application is actually quitting. Note that on Windows, none of these quit events fire if the app closes due to system shutdown, restart, or user logout.[3]

### Platform-Specific Events

macOS provides sheet-related events: `sheet-begin` fires when the window opens a sheet, and `sheet-end` fires when closing a sheet. The `new-window-for-tab` event fires when the native new tab button is clicked. Windows provides `session-end` and `query-session-end` events that fire when a session ends due to shutdown, restart, or logout, with the latter allowing delayed shutdown via `event.preventDefault()`.[2][1]

### Content and Title Events

The `page-title-updated` event fires when the document changes its title. It provides the new title string and an `explicitSet` boolean that indicates whether the title was explicitly set or synthesized from the file URL. Calling `event.preventDefault()` prevents the native window title from changing.[1]

Sources
[1] Process Model https://electronjs.org/docs/latest/tutorial/process-model
[2] BrowserWindow https://electronjs.org/docs/latest/api/browser-window
[3] app https://electronjs.org/docs/latest/api/app
[4] app · Electron documentation https://tinydew4.gitbooks.io/electron/api/app.html
[5] Electron - How to know when renderer window is ready https://stackoverflow.com/questions/42284627/electron-how-to-know-when-renderer-window-is-ready
[6] app https://www.electronjs.org/docs/latest/api/app
[7] app | FAQ - GitHub Pages https://imfly.github.io/electron-docs-gitbook/en/api/app.html
[8] Electron js tutorial for beginners # Important App life cycle ... https://www.youtube.com/watch?v=ECq-mMdKepc
[9] BrowserWindow · GitBook http://electron.ebookchain.org/en/api/browser-window.html
[10] Electron - Close initial window but keep child open - Stack Overflow https://stackoverflow.com/questions/48224116/electron-close-initial-window-but-keep-child-open

---

