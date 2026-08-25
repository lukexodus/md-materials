## `nodeIntegration` vs `contextIsolation`


Because **`nodeIntegration: false` only removes Node.js globals**, while **`contextIsolation: true` creates a hard JavaScript boundary**, they solve different threat classes. Without context isolation, the renderer and preload still share the same execution context, which allows privilege escalation even though Node.js is “disabled”.

Below is a precise explanation, with a concrete exploit-style example and an analogy.

---

### 1. What `nodeIntegration: false` actually does

With `nodeIntegration: false`:
- `require`, `process`, `fs`, etc. are **not injected into `window`**
- Renderer JavaScript looks like a normal browser environment
    

But:
- The **preload script still runs with full Node.js access**
- The preload runs **in the same JS world** as the renderer if `contextIsolation` is off
    

So the renderer cannot _start_ with Node.js, but it can **steal it**.

---

### 2. What happens without `contextIsolation`

**Preload (unsafe)**

```js
// preload.js
window.api = {
  readFile: (path) => require('fs').readFileSync(path, 'utf8')
}
```

**Renderer (attacker-controlled XSS)**

```js
// runs in page context
const original = window.api.readFile

window.api.readFile = (...args) => {
  console.log('Intercepted:', args)
  return original('/etc/passwd')
}
```

Why this works:
- Preload and renderer share the **same `window` object**
- Renderer can:
    - Replace functions
    - Redefine prototypes
    - Intercept privileged calls
    - Access closures indirectly
        

This is **privilege escalation**, not just information access.

---

### 3. What `contextIsolation: true` changes

With `contextIsolation: true`:
- Preload runs in a **separate JavaScript world**
- Renderer and preload do **not share `window`**
- Communication happens only through **explicitly bridged values**
    

Rewriting the preload safely:

```js
const { contextBridge } = require('electron')

contextBridge.exposeInMainWorld('api', {
  readFile: (path) => require('fs').readFileSync(path, 'utf8')
})
```

Now:
- Renderer sees a **copy of the function reference**
- Cannot overwrite internal logic
- Cannot intercept Node.js calls
- Cannot reach `require`, even indirectly
    

Analogy:  
Without context isolation, the renderer and preload sit at the **same desk**.  
With context isolation, they are separated by **bulletproof glass** and only pass sealed envelopes.

---

### 4. Why this is called “true security”

Security failures in Electron almost never come from:
- “Node.js was available”
    

They come from:
- Shared global state
- Prototype pollution
- Function replacement
- Closure capture
    

`nodeIntegration: false` removes the gun.  
Without `contextIsolation`, the attacker can still **grab the keys**.

---

### 5. Capability-based security model

With both enabled:
- Renderer gets **capabilities**, not power
- Each exposed function is:
    - Explicit
    - Auditable
    - Minimal
- No ambient authority exists
    

This matches modern security design used by:
- Browsers
- Sandboxed OS processes
- Microkernels

---

### 6. Final summary

- `nodeIntegration: false`  
    → “Do not give the renderer Node.js by default”
- `contextIsolation: true`  
    → “Do not let the renderer touch privileged code at all”
    

You need **both** because they protect against **different attack vectors**.

If you want, I can next show:
- A **real CVE-style exploit** that worked with nodeIntegration off but contextIsolation off
- A **diagram of JS worlds**
- How Electron internally enforces the isolation boundary

---

