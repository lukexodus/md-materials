## Provisional Load


**Event:** `did-fail-provisional-load`  
**Emitted on:** `webContents` of a `BrowserWindow`  
**When it occurs:** When a **navigation fails at the provisional load stage**—basically, the browser tried to start loading a URL, but it failed **before committing** the load.

**Common reasons for failure:**

- Invalid URL (e.g., `htp://example.com`)
- Network issues (DNS failure, no internet)
- Blocked by security policies (CSP, HTTPS issues)
- Window or tab being closed before the page loaded
    

**Listener example:**

```javascript
const { BrowserWindow } = require('electron');

const win = new BrowserWindow({ /* options */ });

win.webContents.on('did-fail-provisional-load', (event, url, isMainFrame, errorCode, errorDescription) => {
  console.log(`Failed to load: ${url}`);
  console.log(`Error code: ${errorCode} - ${errorDescription}`);
  console.log(`Is main frame? ${isMainFrame}`);
});
```

**Parameters:**

1. `event` – the event object
    
2. `url` – URL that failed to load
    
3. `isMainFrame` – `true` if the main frame failed, `false` for an iframe
    
4. `errorCode` – numeric code of the failure (e.g., `-105` for `ERR_NAME_NOT_RESOLVED`)
    
5. `errorDescription` – human-readable error message
    

**Key distinction:**

- `did-fail-provisional-load` happens **before the page starts committing**.
    
- `did-fail-load` happens **after the load started but failed**.
    

So, if you want to handle network errors **before anything renders**, listen to `did-fail-provisional-load`. If you want to catch **mid-load failures**, use `did-fail-load`.


---

