## HTML API-triggered Fullscreen


If you want to trigger fullscreen in a web page using an **HTML/JavaScript API**, you use the **Fullscreen API**, which is part of standard web APIs. It allows an element (like a `<div>` or the `<body>`) to enter fullscreen mode programmatically.

Here’s a concise example:

```html
<!DOCTYPE html>
<html>
<head>
  <title>Fullscreen Example</title>
</head>
<body>
  <button id="fsBtn">Go Fullscreen</button>
  <div id="content" style="width: 100%; height: 300px; background-color: lightblue;">
    Fullscreen this content
  </div>

  <script>
    const button = document.getElementById('fsBtn');
    const content = document.getElementById('content');

    button.addEventListener('click', () => {
      if (content.requestFullscreen) {
        content.requestFullscreen();
      } else if (content.webkitRequestFullscreen) { // Safari
        content.webkitRequestFullscreen();
      } else if (content.msRequestFullscreen) { // IE/Edge
        content.msRequestFullscreen();
      }
    });

    // Optional: Listen for exit fullscreen
    document.addEventListener('fullscreenchange', () => {
      if (!document.fullscreenElement) {
        console.log('Exited fullscreen');
      }
    });
  </script>
</body>
</html>
```

**Explanation:**

- `element.requestFullscreen()` triggers fullscreen for the element.
    
- Some browsers (Safari, IE/Edge) require prefixes: `webkitRequestFullscreen`, `msRequestFullscreen`.
    
- `document.fullscreenElement` tells you what element is currently fullscreen.
    
- Fullscreen mode can only be triggered **by user interaction** (like a click), due to browser security restrictions.
    

You can also exit fullscreen programmatically:

```js
if (document.exitFullscreen) {
  document.exitFullscreen();
}
```

This API works in browsers, and in **Electron**, it works too, but you can also use **BrowserWindow** methods like `win.setFullScreen(true)` for native fullscreen.

---

If you want, I can give an **Electron-specific version** where the fullscreen is triggered from the renderer using an IPC call to the main process. That approach integrates better with Electron’s window management. Do you want me to show that?

---

