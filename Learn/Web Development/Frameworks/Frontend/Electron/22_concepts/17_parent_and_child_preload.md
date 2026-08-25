## Parent and Child Preload


It depends on what you want each window to do. There’s no strict rule that parent and child windows must share the same preload script, but there are some best practices.
1. **Separate preloads per window**

   * Each `BrowserWindow` (parent or child) can have its own `preload.js`.
   * This is useful if the parent and child need **different APIs or different access levels**.
   * Example: The parent might have full Node access and IPC bridges, while the child only needs a subset.
2. **Shared preload**

   * If parent and child need the same APIs, you can point both windows to the same preload script.
   * Inside that preload, you can still **branch logic based on window type** if necessary:

```javascript
const { contextBridge, ipcRenderer } = require('electron');

if (window.location.pathname.includes('settings')) {
  contextBridge.exposeInMainWorld('api', {
    doSettingsThing: () => ipcRenderer.send('settings-action')
  });
} else {
  contextBridge.exposeInMainWorld('api', {
    doMainThing: () => ipcRenderer.send('main-action')
  });
}
```
3. **Combination approach**

   * You can have a **common preload module** that exports shared functionality, and then have small per-window preload scripts that `require()` that module and add window-specific APIs.
   * This avoids duplication but keeps each window isolated.

**Rule of thumb:**

* Use separate preloads if the windows have different responsibilities or security needs.
* Share preloads if the functionality is mostly the same and you want to reduce duplication.


---

