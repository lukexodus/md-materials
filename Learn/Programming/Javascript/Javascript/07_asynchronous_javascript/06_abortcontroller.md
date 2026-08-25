## `AbortController`


**Overview**
`AbortController` is a modern Web API that allows you to **abort asynchronous operations**, most commonly **`fetch` requests**, before they complete. It gives you more control over resource management, timeouts, and canceling unnecessary network activity.

Introduced in **DOM standard** and now widely supported in browsers.

---

**Key Points**

- Used to **cancel ongoing tasks** (especially `fetch` requests)
- Provides a **signal** object (`AbortSignal`) passed to the async operation
- You call `.abort()` on the controller to trigger cancellation
- The operation must explicitly listen for the abort signal

---

### **Basic structure**

```javascript
const controller = new AbortController();     // create controller
const signal = controller.signal;             // get its signal

fetch("/data.json", { signal })
  .then(response => response.json())
  .then(data => console.log(data))
  .catch(err => {
    if (err.name === "AbortError") {
      console.log("Fetch aborted");
    } else {
      console.error("Fetch error:", err);
    }
  });

// Abort the request after 1 second
setTimeout(() => controller.abort(), 1000);
```

---

### **How it works**

- `AbortController` creates a controller with a `signal` property
- That `signal` is passed into `fetch` (or any API that supports it)
- When `.abort()` is called, the fetch is **canceled**, and a rejection occurs with `AbortError`

---

### **Use cases**

- Cancel requests when user navigates away
- Prevent multiple overlapping API calls
- Implement manual or automatic timeouts
- Cancel media loads, streaming, or long polls

---

### **Abort multiple fetches**

```javascript
const controller = new AbortController();

fetch("/api/1", { signal: controller.signal });
fetch("/api/2", { signal: controller.signal });

// Aborts both
controller.abort();
```

---

### **Limitations**

- Only works with APIs that **support AbortSignal** (e.g., `fetch`, some media APIs)
- Older APIs like `XMLHttpRequest` need manual cancelation logic
- Aborting doesn't undo side effects if a request already started processing on the server

---

**Conclusion**

`AbortController` is a powerful tool for **canceling async tasks**, especially HTTP requests. Use it with `fetch` to improve responsiveness, avoid race conditions, and reduce resource waste. It is the modern standard for request cancellation in JavaScript.

---

