## Structured Clone


`structuredClone` is a default (built-in) function**, but **only in sufficiently recent JavaScript runtimes**. It is not universally available in all environments or versions.

Background first.
`structuredClone` is a standardized Web API that implements the *Structured Clone Algorithm*. Conceptually, think of it as a very strict photocopier: it copies plain data exactly, but refuses to copy things with live behavior (functions, prototypes, native handles, sockets, DOM nodes, etc.). Electron’s IPC uses essentially the same algorithm under the hood.

Now, environment by environment.

In modern browsers, `structuredClone` is globally available (for example, `window.structuredClone`) in recent Chrome, Firefox, and Safari.

In Node.js, `structuredClone` became a **global function starting in Node 17** and is fully stable in Node 18+. In older Node versions, it does not exist unless you polyfill it.

In Electron, availability depends on the **embedded Node.js and Chromium versions**, and also **where the code runs**:

* In the renderer (Chromium context), it is available if Chromium is new enough.
* In preload and main (Node context), it is available if the bundled Node version is ≥ 17.

So in Electron 22+ (roughly), `structuredClone` is normally available everywhere. In older Electron versions, it may be missing in preload or main.

```js
function isSerialized(obj) {
  try {
    structuredClone(obj);
    return true;
  } catch {
    return false;
  }
}
```

This tests whether the object can pass the structured clone algorithm, which is exactly what `ipcRenderer.send` requires.

However, two important caveats.

First, **this will throw if `structuredClone` itself is undefined**. In older environments, you must guard it:

```js
if (typeof structuredClone !== 'function') {
  throw new Error('structuredClone not available in this runtime');
}
```

Second, **passing `structuredClone` does not guarantee semantic safety**, only structural clonability. For example:

* Dates clone fine.
* Maps and Sets clone fine.
* Class instances lose their prototype and methods.
* Errors clone, but stack traces may differ.

Analogy.
Think of `structuredClone` as checking whether an item can be shipped through customs. Passing inspection means it is allowed to cross the border, not that it will arrive with its original packaging or branding intact.

Practical Electron note.
If your data passes `structuredClone`, it is safe to send via `ipcRenderer.send`. If it fails, Electron will throw a “could not be cloned” error internally. Your pre-check is reasonable, but in production code many developers rely on IPC throwing naturally and log the failure centrally.

If you want, I can:

* Map exact Electron versions to `structuredClone` availability.
* Show a lightweight fallback for older Electron/Node.
* Explain how this relates to your earlier IPC memory and listener issues.

---

