## windows.location in Electron


In Electron, `window.location` in a renderer process works almost the same as in a normal browser: it represents the **current URL of the web page loaded in that renderer window**.

It’s an object with properties like:

* `window.location.href` → full URL string (e.g., `file:///path/to/index.html` or `https://example.com`)
* `window.location.pathname` → path portion (e.g., `/index.html`)
* `window.location.origin` → origin (protocol + host, e.g., `file://` or `https://example.com`)
* `window.location.hash` → any fragment after `#`
* `window.location.search` → query parameters after `?`

In Electron, since most windows load local files via `file://`, `window.location` often looks like this:

```text
file:///home/user/project/dist/index.html
```

So if you do:

```javascript
console.log(window.location.pathname);
```

You might see:

```
/home/user/project/dist/index.html
```

This is often used in preload scripts to **branch behavior depending on which HTML page is loaded**, e.g., parent vs child window.

**Important note:** Electron’s `window.location` is read/write, just like in the browser. Changing it navigates the renderer window, which is equivalent to `window.location.href = 'newpage.html'`.

---

