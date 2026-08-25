## Surviving Listeners Across Reloads


This can happen very easily in Electron, and it is one of the most common IPC-related memory and behavior bugs. I will explain the mechanism precisely, then give concrete prevention patterns.

Why reloads stack `ipcRenderer` listeners.

A renderer reload (`window.location.reload()`, `BrowserWindow.reload()`, DevTools hot reload, or framework HMR) does **not** necessarily restart the entire Electron renderer process. What usually happens is:

• The JavaScript context is re-executed  
• Preload may or may never re-run, depending on configuration  
• The underlying IPC channel remains alive  
• Existing listeners are still registered

`ipcRenderer` is backed by a native EventEmitter that survives reloads unless the process itself exits.

Analogy: reloading is like restarting a program’s “main function” without rebooting the computer. Global hooks stay attached.

What exactly stacks.

Each reload executes:

```js
ipcRenderer.on('update', handler);
```

again.

If the previous listener was never removed, you now have:

• Listener #1 (old)  
• Listener #2 (new)  
• Listener #3 (after another reload)

Every IPC message now fires all of them.

Why this is silent and dangerous.

• No error is thrown  
• Messages still “work”  
• Memory grows gradually  
• Effects multiply (duplicate UI updates, duplicated logs, etc.)

Electron does not warn because `EventEmitter` allows unlimited listeners by default.

How this happens in practice.

Common patterns that cause it:

1. Listener registration in top-level renderer code.
    

```js
// renderer.js
ipcRenderer.on('update', handler);
```

Every reload re-executes this file.

2. Listener registration inside React/Vue/Svelte component bodies without cleanup.
    

```js
useEffect(() => {
  ipcRenderer.on('update', handler);
}, []);
```

On hot reload, effects re-run without unmounting the old tree.

3. Listener registration inside preload exposed APIs that run more than once.
    

```js
contextBridge.exposeInMainWorld('api', {
  onUpdate: (cb) => ipcRenderer.on('update', cb)
});
```

Each call attaches a new listener.

Why garbage collection does not help.

`ipcRenderer.on` registers the handler on a native-backed emitter. Even if the JS function becomes unreachable, the native emitter still holds a reference to it.

Heap GC cannot collect it.

How to prevent this reliably.

1. Always remove listeners explicitly.
    

```js
const handler = (_, data) => { ... };

ipcRenderer.on('update', handler);

window.addEventListener('beforeunload', () => {
  ipcRenderer.removeListener('update', handler);
});
```

This ensures cleanup on reload and navigation.

2. Prefer `once` when appropriate.
    

If you only expect one message:

```js
ipcRenderer.once('update', handler);
```

This auto-removes after first execution.

3. Guard against duplicate registration.
    

```js
let registered = false;

if (!registered) {
  ipcRenderer.on('update', handler);
  registered = true;
}
```

This is crude but effective in simple setups.

4. Use a subscription API that returns an unsubscribe function (best practice).
    

In preload:

```js
contextBridge.exposeInMainWorld('api', {
  onUpdate: (cb) => {
    ipcRenderer.on('update', cb);
    return () => ipcRenderer.removeListener('update', cb);
  }
});
```

In renderer:

```js
const unsubscribe = window.api.onUpdate(handler);

// on reload / unmount
unsubscribe();
```

Analogy: you check in and get a receipt; when you leave, you hand the receipt back.

5. In frameworks, always clean up effects.
    

React example:

```js
useEffect(() => {
  const handler = (_, data) => { ... };

  ipcRenderer.on('update', handler);

  return () => {
    ipcRenderer.removeListener('update', handler);
  };
}, []);
```

This is mandatory, especially with hot module replacement.

6. Detect listener leaks early.
    

Electron is just Node.js under the hood:

```js
ipcRenderer.setMaxListeners(20);
```

If you exceed this, Node will warn you. This is not a fix, but it is an early warning system.

How to confirm this is happening.

Add logging:

```js
console.log(ipcRenderer.listenerCount('update'));
```

Reload the window repeatedly. If the number increases, you are leaking listeners.

Key takeaway.

Renderer reloads re-execute JavaScript but do not necessarily tear down IPC infrastructure. Every `ipcRenderer.on` call must have a corresponding removal path. If not, reloads and hot reloads will silently stack listeners, leading to duplicated behavior and native memory growth that heap tools cannot see.

---



