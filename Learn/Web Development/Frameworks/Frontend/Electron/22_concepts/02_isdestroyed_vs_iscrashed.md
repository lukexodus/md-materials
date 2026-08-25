## isDestroyed vs isCrashed


In Electron, `webContents` exposes two different status-check methods: **`isDestroyed()`** and **`isCrashed()`**. They are related to the renderer process but measure **different conditions**.

---

### 1. `webContents.isDestroyed()`

* **What it checks:** Whether the `webContents` object itself has been **destroyed or dereferenced**.
* **When true:**

  * You called `win.destroy()` on the `BrowserWindow`
  * The window was closed and its `webContents` no longer exists
* **Implication:** You cannot interact with this `webContents` anymore; all methods will throw errors.

Example:

```js
const { BrowserWindow } = require('electron')
const win = new BrowserWindow()

console.log(win.webContents.isDestroyed()) // false
win.destroy()
console.log(win.webContents.isDestroyed()) // true
```

Analogy:

* `isDestroyed()` = “Is this window object **gone from memory**?”

---

### 2. `webContents.isCrashed()`

* **What it checks:** Whether the **renderer process** running inside this `webContents` has crashed.
* **When true:**

  * The renderer (the web page) has crashed due to an exception, segmentation fault, or GPU issue
  * The `webContents` object **still exists**, but the page is dead
* **Implication:** You may need to reload the page or recreate the renderer

Example:

```js
win.webContents.on('render-process-gone', (event, details) => {
  console.log('Renderer gone:', details)
  console.log('isCrashed?', win.webContents.isCrashed())
})
```

Analogy:

* `isCrashed()` = “Is the engine running this window **broken**, even if the window object still exists?”

---

### 3. Key differences

| Method          | Checks                                 | WebContents exists? | Example event                               |
| --------------- | -------------------------------------- | ------------------- | ------------------------------------------- |
| `isDestroyed()` | Object has been destroyed / cleaned up | No                  | `closed`                                    |
| `isCrashed()`   | Renderer process crashed               | Yes                 | `render-process-gone` with reason `crashed` |

* `isDestroyed()` → **object lifecycle**
* `isCrashed()` → **renderer process health**

---

In practice:

```js
if (!win.webContents.isDestroyed()) {
  if (win.webContents.isCrashed()) {
    win.reload() // recover from crash
  } else {
    win.webContents.send('ping', 'hello')
  }
}
```

This ensures you **don’t send messages to a dead or non-existent webContents**.

---

