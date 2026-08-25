## RSS


RSS (Resident Set Size) is the total memory currently held in physical RAM by a process. It includes JavaScript heap, native allocations (C/C++), memory-mapped files, buffers, and Electron/Chromium internals.

The JavaScript heap is only the memory managed by V8’s garbage collector. Heap snapshots and heap graphs only reflect this portion.

An analogy: think of the heap as the furniture inside a warehouse, and RSS as the entire warehouse building plus everything stored around it. You can remove furniture and still have a growing warehouse.

Why IPC listeners cause RSS growth.

IPC listeners (`ipcMain.on`, `ipcRenderer.on`) create native-backed event subscriptions. These are not just JavaScript objects; they involve:

• Native C++ structures in Electron
• References held by the event emitter
• Closures capturing renderer state
• Message channel infrastructure

If a window is closed but its IPC listeners remain registered, Electron still retains native references to them. V8 may reclaim the JavaScript objects, but the native side does not fully release the associated memory.

As a result:
• Heap snapshots look stable
• RSS steadily increases
• Memory is never returned to the OS

This is why you see “no leak” in heap tools but growing RSS.

Why garbage collection does not help.

V8 garbage collection only applies to objects it owns. IPC wiring lives partially outside V8.

Analogy: garbage collection is like cleaning your desk. IPC leaks are like forgetting to cancel a rented storage unit. Cleaning your desk does not return the storage unit.

Common IPC leak patterns.
1. Registering listeners per window but never removing them.

```js
ipcMain.on('status', handler);
```

If this runs every time a window is created, the handlers accumulate.
2. Using anonymous functions, making removal impossible.

```js
ipcMain.on('event', () => { ... });
```

You cannot later call `removeListener` because there is no reference.
3. Renderer listeners that survive reloads.

```js
ipcRenderer.on('update', handler);
```

Hot reloads or window reloads stack listeners silently.
4. `contextBridge.exposeInMainWorld` functions that internally attach IPC listeners repeatedly.

These are especially dangerous because they look “safe” but run multiple times.

Why Electron is especially sensitive.

Electron combines:
• Node.js event emitters
• Chromium processes
• Native IPC channels

RSS memory fragmentation is common. Even when memory is freed internally, it may never be returned to the OS, so RSS continues to climb.

This is expected behavior but becomes a problem when listeners accumulate indefinitely.

How to fix and prevent it.

In the main process, scope listeners to window lifetime.

```js
function registerIpc(win) {
  const handler = (event, data) => { ... };

  ipcMain.on('event', handler);

  win.on('closed', () => {
    ipcMain.removeListener('event', handler);
  });
}
```

Prefer `ipcMain.handle` over `ipcMain.on` for request/response patterns.

```js
ipcMain.handle('get-data', async () => { ... });
```

Handlers are singleton-style and safer.

In the renderer, clean up on unload.

```js
const handler = (_, data) => { ... };

ipcRenderer.on('update', handler);

window.addEventListener('beforeunload', () => {
  ipcRenderer.removeListener('update', handler);
});
```

Avoid registering IPC listeners inside:
• React render paths
• Repeated preload executions
• Window creation loops without guards

How to confirm this diagnosis.

If RSS increases while:
• Heap stays flat
• GC runs successfully
• CPU is normal

And RSS growth correlates with:
• Window creation/destruction
• Reloads
• IPC-heavy traffic

Then this is almost certainly IPC or native resource leakage, not a JavaScript heap leak.

Key takeaway.

IPC listeners that are never removed do not necessarily leak JavaScript memory, but they do leak native memory. That native memory contributes to RSS, which is why RSS grows even when heap analysis shows no leaks.

This distinction—heap vs native—is the critical insight for diagnosing Electron memory issues.

---

