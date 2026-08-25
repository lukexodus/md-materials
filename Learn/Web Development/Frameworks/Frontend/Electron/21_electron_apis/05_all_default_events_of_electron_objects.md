## All Default Events of Electron Objects


### Window Events (BrowserWindow)

#### Lifecycle Events

- **ready-to-show** - Window can be displayed without visual flash
- **show** - Window is shown
- **hide** - Window is hidden
- **close** - Window is going to be closed
- **closed** - Window has been closed
- **session-end** - Window session is going to end (Windows only)

#### Focus Events

- **focus** - Window gains focus
- **blur** - Window loses focus
- **maximize** - Window is maximized
- **unmaximize** - Window exits maximized state
- **minimize** - Window is minimized
- **restore** - Window is restored from minimized state
- **enter-full-screen** - Window enters full-screen state
- **leave-full-screen** - Window leaves full-screen state
- **enter-html-full-screen** - Window enters HTML full-screen (triggered by HTML API)
- **leave-html-full-screen** - Window leaves HTML full-screen

#### Interaction Events

- **resize** - Window is being resized
- **resized** - Window has been resized (macOS/Windows)
- **will-resize** - Window is about to be resized (macOS/Windows)
- **move** - Window is being moved
- **moved** - Window has been moved (macOS/Windows)
- **will-move** - Window is about to be moved (macOS/Windows)

#### State Events

- **responsive** - Unresponsive page becomes responsive
- **unresponsive** - Page becomes unresponsive
- **always-on-top-changed** - Always-on-top state changed
- **app-command** - App command invoked (Windows)
- **scroll-touch-begin** - Scroll touch event began (macOS)
- **scroll-touch-end** - Scroll touch event ended (macOS)
- **scroll-touch-edge** - Scroll touch event reached edge (macOS)
- **swipe** - Trackpad swipe gesture (macOS)
- **rotate-gesture** - Rotate gesture on trackpad (macOS)
- **sheet-begin** - Window opens a sheet (macOS)
- **sheet-end** - Window closes a sheet (macOS)
- **new-window-for-tab** - Native new tab button clicked (macOS)
- **system-context-menu** - System context menu triggered (Windows)

### WebContents Events

#### Navigation Events

- **did-start-loading** - Tab spinner starts spinning
- **did-stop-loading** - Tab spinner stops spinning
- **did-start-navigation** - Navigation started
- **will-navigate** - Navigation about to happen
- **did-navigate** - Main frame navigation done
- **did-frame-navigate** - Any frame navigation done
- **did-navigate-in-page** - In-page navigation occurred
- **will-redirect** - Server redirect during navigation
- **did-redirect-navigation** - Redirect received during navigation
- **navigation-entry-committed** - Navigation entry committed

#### Loading Events

- **dom-ready** - DOM of top-level frame loaded
- **page-title-updated** - Page title updated
- **page-favicon-updated** - Page favicon updated
- **did-finish-load** - Navigation finished
- **did-fail-load** - Navigation failed
- **did-frame-finish-load** - Frame finished loading
- **did-fail-provisional-load** - Provisional load failed

#### Content Events

- **new-window** - Page requests new window (deprecated)
- **webview-attached** - WebView attached to page
- **will-attach-webview** - WebView about to attach
- **did-attach-webview** - WebView attached
- **console-message** - Console message logged
- **preload-error** - Preload script threw error
- **ipc-message** - Async IPC message from renderer
- **ipc-message-sync** - Sync IPC message from renderer
- **desktop-capturer-get-sources** - desktopCapturer.getSources() called
- **render-process-gone** - Renderer process crashed/killed
- **unresponsive** - Page becomes unresponsive
- **responsive** - Unresponsive page responsive again
- **plugin-crashed** - Plugin process crashed
- **destroyed** - WebContents destroyed

#### Media Events

- **media-started-playing** - Media starts playing
- **media-paused** - Media paused
- **did-change-theme-color** - Page theme color changed
- **update-target-url** - Mouse hovers over link
- **cursor-changed** - Cursor type changed
- **context-menu** - New context menu needs display

#### Security Events

- **certificate-error** - Failed to verify certificate
- **select-client-certificate** - Client certificate requested
- **login** - Authentication requested
- **found-in-page** - Result for findInPage available
- **select-bluetooth-device** - Bluetooth device selection needed
- **paint** - New frame generated
- **devtools-opened** - DevTools opened
- **devtools-closed** - DevTools closed
- **devtools-focused** - DevTools focused
- **devtools-reload-page** - DevTools reload requested
- **will-prevent-unload** - beforeunload handler invoked
- **crashed** - Renderer process crashed (deprecated)
- **before-input-event** - Input event about to be sent

#### Download Events

- **did-create-window** - New window created by renderer

### App Events

#### Lifecycle Events

- **will-finish-launching** - App finishing basic startup
- **ready** - Electron initialization complete
- **window-all-closed** - All windows closed
- **before-quit** - Before application quits
- **will-quit** - All windows closed, app will quit
- **quit** - Application is quitting
- **activate** - Application activated (macOS)
- **did-become-active** - Application became active (macOS)
- **continue-activity** - Handoff activity wants to resume (macOS)
- **will-continue-activity** - Handoff activity about to resume (macOS)
- **continue-activity-error** - Handoff activity failed (macOS)
- **activity-was-continued** - Handoff activity resumed on another device (macOS)
- **update-activity-state** - Handoff about to resume on another device (macOS)
- **new-window-for-tab** - User clicked new tab button (macOS)

#### System Events

- **browser-window-created** - New BrowserWindow created
- **web-contents-created** - New WebContents created
- **certificate-error** - Failed to verify certificate
- **select-client-certificate** - Client certificate requested
- **login** - Authentication requested
- **gpu-info-update** - GPU info update available
- **gpu-process-crashed** - GPU process crashed
- **renderer-process-crashed** - Renderer process crashed (deprecated)
- **render-process-gone** - Renderer process gone
- **child-process-gone** - Child process gone
- **accessibility-support-changed** - Accessibility support changed (macOS/Windows)
- **session-created** - New Session created
- **second-instance** - Second instance executed (with single instance lock)

#### Platform-Specific Events

- **open-file** - User wants to open file (macOS)
- **open-url** - User wants to open URL (macOS)
- **did-resign-active** - App stopped being active (macOS)

### Session Events

#### Request Events

- **will-download** - Download about to start
- **extension-loaded** - Extension loaded (after ready)
- **extension-unloaded** - Extension unloaded
- **extension-ready** - Extension loaded (at ready)
- **preconnect** - Preconnect hint from rendering process
- **spellcheck-dictionary-initialized** - Spellcheck dictionary file initialized
- **spellcheck-dictionary-download-begin** - Spellcheck dictionary download began
- **spellcheck-dictionary-download-success** - Spellcheck dictionary downloaded
- **spellcheck-dictionary-download-failure** - Spellcheck dictionary download failed
- **select-serial-port** - Serial port selection requested (when `serial` permission requested)
- **serial-port-added** - Serial port added
- **serial-port-removed** - Serial port removed
- **select-hid-device** - HID device selection requested
- **hid-device-added** - HID device added
- **hid-device-removed** - HID device removed
- **hid-device-revoked** - HID device access revoked
- **select-usb-device** - USB device selection requested
- **usb-device-added** - USB device added
- **usb-device-removed** - USB device removed
- **usb-device-revoked** - USB device access revoked

### Additional Object Events

#### Tray Events

- **click** - Tray icon clicked
- **right-click** - Tray icon right-clicked (macOS/Windows)
- **double-click** - Tray icon double-clicked (macOS/Windows)
- **balloon-show** - Tray balloon shown (Windows)
- **balloon-click** - Tray balloon clicked (Windows)
- **balloon-closed** - Tray balloon closed (Windows)
- **drop** - Dragged items dropped on tray (macOS)
- **drop-files** - Dragged files dropped on tray (macOS)
- **drop-text** - Dragged text dropped on tray (macOS)
- **drag-enter** - Drag operation entered tray (macOS)
- **drag-leave** - Drag operation exited tray (macOS)
- **drag-end** - Drag operation ended on tray (macOS)
- **mouse-enter** - Mouse entered tray icon (macOS)
- **mouse-leave** - Mouse left tray icon (macOS)
- **mouse-move** - Mouse moved in tray icon (macOS)
- **mouse-up** - Mouse up on tray icon (macOS)
- **mouse-down** - Mouse down on tray icon (macOS)

#### IncomingMessage Events (HTTP Response)

- **data** - Response data chunk
- **end** - Response body ended
- **aborted** - Request aborted mid-stream
- **error** - Error encountered

#### DownloadItem Events

- **updated** - Download updated (progress)
- **done** - Download completed/failed/cancelled

#### TouchBar Events (macOS)

- **escape-touch** - Escape touch bar item touched

-----

**Note:** This list reflects the Electron API as of my knowledge cutoff (January 2025). Event availability may vary by Electron version and operating system. Some events are platform-specific (macOS, Windows, Linux). Always consult the official Electron documentation for your specific version.​​​​​​​​​​​​​​​​



