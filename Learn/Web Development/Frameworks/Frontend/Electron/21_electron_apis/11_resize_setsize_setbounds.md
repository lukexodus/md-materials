## Resize setSize, setBounds


In **Electron**, there are two common ways to change a `BrowserWindow`’s dimensions: `setBounds` and `setSize`. They overlap but have different scopes and flexibility.

---

### 1. `setSize(width, height[, animate])`

* **Purpose:** Directly sets the window’s width and height.
* **Syntax:**

```js
win.setSize(width, height, animate);
```

* `width` / `height`: integers, pixels.

* `animate` (optional): `true` on macOS to animate the resize.

* **Example:**

```js
const { BrowserWindow } = require('electron');

let win = new BrowserWindow({ width: 800, height: 600 });

win.setSize(1024, 768); // resize window to 1024x768
```

* **Notes:**

  * Only changes size, not position.
  * Faster and simpler for just resizing.

---

### 2. `setBounds(bounds[, animate])`

* **Purpose:** Sets both **size and position** of the window in one call.
* **Syntax:**

```js
win.setBounds(bounds, animate);
```

* `bounds` is an object:

```js
{
  x: 100,    // left position on screen
  y: 100,    // top position on screen
  width: 1024,
  height: 768
}
```

* **Example:**

```js
win.setBounds({ x: 200, y: 100, width: 1280, height: 720 });
```

* **Notes:**

  * More flexible if you need to move and resize simultaneously.
  * On multi-monitor setups, coordinates relate to the primary display.

---

### Key Differences

| Feature                  | `setSize` | `setBounds` |
| ------------------------ | --------- | ----------- |
| Resize only              | ✅         | ✅           |
| Resize + move            | ❌         | ✅           |
| Accepts object           | ❌         | ✅           |
| Simpler for quick resize | ✅         | ❌           |
| Animation support        | ✅ (macOS) | ✅ (macOS)   |

---

**Analogy:**

* `setSize` is like **changing the dimensions of a picture frame without moving it**.
* `setBounds` is like **picking up the frame, moving it somewhere, and resizing it at the same time**.

---

