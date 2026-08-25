## Frameless Windows


Frameless windows in Electron remove all operating system chrome, including toolbars, borders, title bars, and window controls, displaying only the web page content. This enables developers to create custom-styled applications with unique user interfaces that break free from standard platform conventions, ideal for media players, kiosks, or design-forward applications.[1][2]

### Creating Frameless Windows

A frameless window is created by setting the `frame` property to `false` in the BrowserWindow constructor options. This single property removes all OS-provided window chrome, leaving only the rendered web content visible. When creating frameless windows, developers should also specify a `backgroundColor` to ensure proper subpixel anti-aliasing, particularly on Windows.[2][3][4]

```javascript
const { BrowserWindow } = require('electron')

const win = new BrowserWindow({
  width: 800,
  height: 600,
  frame: false,
  backgroundColor: '#FFF'
})
```

After creating a frameless window, developers must implement custom controls for closing, minimizing, maximizing, and dragging, as these standard window operations are no longer accessible through OS-provided UI elements.[3][1]

### Title Bar Styles (macOS)

macOS provides alternative approaches to frameless windows through the `titleBarStyle` option, which offers various levels of chrome removal while preserving some native functionality. The `hidden` value hides the title bar and extends content to fill the full window size, yet still displays window controls ("traffic lights") in the top-left corner. This creates a chromeless appearance while maintaining standard macOS window controls.[5][1]

The `hiddenInset` value provides a similar effect but insets the window controls slightly from the window edge, offering a visually distinct alternative look. The `customButtonsOnHover` option uses custom-drawn close, miniaturize, and fullscreen buttons that appear when hovering in the top-left corner, resolving mouse event issues that can occur with standard toolbar buttons. This option is specifically applicable for frameless windows and requires setting `frame: false`.[1][5]

### Draggable Regions

Frameless windows are non-draggable by default since they lack the OS-provided title bar that normally handles window movement. Developers must explicitly specify draggable regions using the CSS property `-webkit-app-region: drag` to tell Electron which areas should respond to drag gestures. This property is typically applied to custom title bar elements to replicate standard window dragging behavior.[6][7][5]

Non-draggable areas within draggable regions can be excluded using `-webkit-app-region: no-drag`, which is essential for buttons and interactive elements in custom title bars. Only rectangular shapes are currently supported for draggable regions, limiting the complexity of drag-enabled areas. Note that only the `drag` and `no-drag` values are supported—other values are not valid.[7][5][6]

```css
.titlebar {
  -webkit-user-select: none;
  -webkit-app-region: drag;
}

.titlebar-button {
  -webkit-app-region: no-drag;
}
```

Draggable regions can also be set programmatically in JavaScript by setting the `webkitAppRegion` style property on DOM elements. This enables dynamic control over which regions are draggable based on application state or user preferences.[7]

### Text Selection Conflicts

In frameless windows, dragging behavior may conflict with text selection, particularly in title bar areas. When users attempt to drag the title bar, they may accidentally select text instead of moving the window. To prevent this, disable text selection within draggable areas using `-webkit-user-select: none` in CSS. This ensures dragging gestures take priority over text selection in regions designated for window movement.[6][7]

### Custom Window Controls

Since frameless windows remove native window controls, developers must implement custom buttons for closing, minimizing, maximizing, and restoring windows. These controls communicate with the main process through IPC to trigger window operations. Typical implementations create a custom title bar with styled buttons that call BrowserWindow methods like `close()`, `minimize()`, `maximize()`, and `restore()`.[4][3]

Custom controls must be marked with `-webkit-app-region: no-drag` to ensure they remain clickable within the draggable title bar region. This prevents drag gestures from interfering with button clicks. Window control implementations should also handle platform differences, as macOS users expect controls in the top-left corner while Windows users expect them in the top-right.[8][4][6][7]

### Transparent Windows

Transparent windows extend frameless window capabilities by making the entire window background transparent, allowing the desktop or underlying applications to show through. This is achieved by setting both `frame: false` and `transparent: true` in the BrowserWindow constructor. CSS backgrounds using `rgba(0, 0, 0, 0)` or similar transparent values enable selective transparency, creating non-rectangular window shapes or overlay effects.[9][1]

```javascript
const win = new BrowserWindow({
  width: 100,
  height: 100,
  frame: false,
  transparent: true,
  resizable: false
})
```

Transparent windows have several limitations. Users cannot click through transparent areas to interact with underlying applications. Transparent windows are not resizable—setting `resizable: true` may cause the window to stop functioning correctly on some platforms. The CSS `blur()` filter only affects window content and cannot blur content from other applications visible beneath the transparent window.[9]

Platform-specific limitations further constrain transparent windows. On Windows, transparent windows cannot be maximized using the system menu or by double-clicking the title bar due to technical constraints. On macOS, native window shadows are not displayed on transparent windows. Opening DevTools breaks transparency on all platforms.[9]

### Seamless Title Bar Design

Creating seamless custom title bars requires coordinating HTML structure, CSS styling, and JavaScript event handling. The typical approach involves creating a fixed-position div at the top of the page with draggable regions and embedded window control buttons. The title bar should use `position: absolute` or `fixed` with `top: 0` to anchor it at the window's top edge.[4][8]

Background color selection is important for text rendering quality—using `backgroundColor: '#FFF'` in BrowserWindow options enables subpixel anti-aliasing, improving text clarity in the custom title bar. The title bar should also set `user-select: none` to prevent accidental text selection during dragging. For cross-platform compatibility, title bars should adapt their layout based on the detected platform, positioning controls appropriately for Windows and macOS conventions.[8][4][7]

Sources
[1] Frameless Window in ElectronJS https://www.geeksforgeeks.org/javascript/frameless-window-in-electronjs/
[2] Custom Window Styles | Electron https://www.electronjs.org/pt/docs/latest/tutorial/custom-window-styles
[3] Frameless window with controls in electron (Windows) https://stackoverflow.com/questions/35876939/frameless-window-with-controls-in-electron-windows
[4] Electron seamless titlebar tutorial (Windows 10 style) - GitHub https://github.com/binaryfunt/electron-seamless-titlebar-tutorial
[5] Frameless Window | Electron https://zeke.github.io/electron.atom.io/docs/api/frameless-window/
[6] Frameless Window - Electron - W3cubDocs http://docs3.w3cub.com/electron/api/frameless-window/
[7] How do I move a frameless window in Electron without using -webkit ... https://stackoverflow.com/questions/44818508/how-do-i-move-a-frameless-window-in-electron-without-using-webkit-app-region
[8] Custom Title bar for electron app (Windows and MAC) https://ghosty.hashnode.dev/custom-title-bar-for-electron-app-windows-and-mac
[9] app · Electron documentation https://tinydew4.gitbooks.io/electron/api/app.html
[10] Electron Tutorial 7: Frameless Window https://www.youtube.com/watch?v=wiblQhPqXdY
[11] Frameless Window In Electron : Electron Tutorial #2 https://www.youtube.com/watch?v=sh-NtL89pB8


---

