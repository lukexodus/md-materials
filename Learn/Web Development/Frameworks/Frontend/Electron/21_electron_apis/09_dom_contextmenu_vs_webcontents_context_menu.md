## DOM `contextmenu` vs webContents `context-menu`


In Electron there are two fundamentally different ways to implement context menus, and the trade-off you quoted (“requires manual event prevention and IPC setup but provides more control”) applies specifically to the **DOM `contextmenu` approach**.

I will contrast them directly, then summarize when each is appropriate.

First, some background on the terms.

The **DOM `contextmenu` event** is a standard browser event fired in the renderer whenever a user right-clicks (or long-presses). It lives entirely in the web page’s JavaScript environment.

The **`webContents` `context-menu` event** is an Electron-specific event fired in the **main process**, emitted by Chromium after it analyzes what was clicked.

You can think of it this way:

* DOM `contextmenu`: “The page noticed a right-click.”
* `webContents.context-menu`: “Chromium already classified the click and is reporting it to Electron.”

---

### 1. DOM `contextmenu` (renderer-level)

Renderer example:

```js
document.addEventListener('contextmenu', (e) => {
  e.preventDefault();

  const target = e.target;

  window.api.showContextMenu({
    tagName: target.tagName,
    isEditable: target.isContentEditable,
    selection: window.getSelection()?.toString(),
  });
});
```

Main process:

```js
ipcMain.handle('show-context-menu', (event, data) => {
  // Build menu manually
});
```

Characteristics:

* You **must call `event.preventDefault()`** to suppress the default Chromium menu.
* You **must send data manually via IPC**.
* You must **infer context yourself** (element type, selection, attributes).

Control level:

* Very high.
* You decide *exactly* when a menu appears.
* You can conditionally suppress menus (e.g., only on specific elements).
* Works even when you want *non-standard* triggers (custom right-click logic, long-press, keyboard).

Analogy:
This is like intercepting a knock at the door before anyone looks through the peephole—you decide whether to open, ignore, or show a custom interaction.

Costs:

* More boilerplate.
* Higher risk of missing edge cases (images, links, spellcheck, media).
* Must maintain IPC contracts.

---

### 2. `webContents.on('context-menu')` (Chromium-level)

Main process example:

```js
win.webContents.on('context-menu', (event, params) => {
  if (params.mediaType === 'image') {
    // show image menu
  }
});
```

Characteristics:

* No DOM event handling required.
* No IPC required.
* Electron gives you a **rich `params` object**:

  * `mediaType`
  * `linkURL`
  * `srcURL`
  * `selectionText`
  * `isEditable`
  * spellcheck info
  * coordinates

Control level:

* Medium to high.
* You can still customize menus dynamically.
* But you react *after* Chromium decides the click is valid.

Analogy:
This is like letting the doorman identify the visitor first, then choosing how to respond based on a detailed report.

Benefits:

* Far less code.
* Much harder to get wrong.
* Matches native Chromium behavior.
* Best default choice.

Limitations:

* Only fires on actual right-clicks.
* Cannot easily implement nonstandard triggers.
* Harder to suppress menus selectively at the DOM level.

---

### 3. Why DOM context menus give “more control”

That statement is accurate because DOM-based handling lets you:

* Block context menus on specific elements or regions.
* Implement app-specific logic (e.g., permissions, modes).
* Replace right-click behavior entirely.
* Trigger menus from non-mouse interactions.

However, that control comes at the cost of:

* Manual event suppression.
* Manual context extraction.
* IPC complexity.

---

### 4. Direct comparison summary

* Use **`webContents.context-menu`** when:

  * You want native-like behavior.
  * You need access to Chromium’s click classification.
  * You want simplicity and reliability.

* Use **DOM `contextmenu`** when:

  * You need absolute control over when menus appear.
  * You want custom interaction models.
  * You want renderer-driven UX logic.

Hybrid approach (common in large apps):

* Use DOM `contextmenu` only for special cases.
* Let `webContents.context-menu` handle everything else.


---

