## NativeImage and Image Handle


Brief background.  
In Electron, `image` is typically a `NativeImage` object. A `NativeImage` is Electron’s cross-platform wrapper around an operating system image object (for example, an HBITMAP on Windows or an NSImage/CGImage on macOS).

What `getNativeHandle()` does.  
`image.getNativeHandle()` returns a **raw binary handle** to the underlying OS image object. The return value is a **Node.js Buffer**, not a JavaScript object you can meaningfully inspect.

Conceptual analogy.  
Think of `NativeImage` as a “safe, padded box” that Electron gives you to move an image around in JavaScript.  
`getNativeHandle()` is like opening that box and pulling out the **metal part number stamped by the factory**. That number only makes sense to the factory’s machines (the OS and native code), not to normal users (JavaScript).

Platform-specific meaning (high level).  
• Windows: the buffer contains a handle related to a GDI bitmap (e.g., HBITMAP).  
• macOS: the buffer points to a Core Graphics / Cocoa image object.  
• Linux: it maps to the underlying GTK / X11 / Wayland image representation.

Electron deliberately does not normalize this, because native graphics systems differ fundamentally.

Important implications.

1. The buffer is **platform-specific**. Code using it is not portable.
2. The buffer is **not serializable** via IPC in a meaningful way. Sending it across processes will not recreate the native image.
3. It is only useful when calling **native Node addons (C++ / N-API)** or OS APIs that explicitly expect that handle.
4. You must not modify the buffer contents. Treat it as read-only.

When this is appropriate.  
Use `getNativeHandle()` only if you are integrating with:  
• A native Node addon you wrote.  
• A system API that explicitly requires an OS image handle.  
• Low-level OS integrations (e.g., custom window theming, native plugins).

When this is not appropriate.  
Do not use it for:  
• Rendering in the renderer.  
• Passing images over IPC.  
• Persisting images.  
• Any logic that should remain cross-platform.

Practical guidance.  
If your goal is to:  
• Display the image → use `nativeImage.toDataURL()` or `toBitmap()`.  
• Send the image via IPC → send raw pixel data or a data URL.  
• Interact with native code → `getNativeHandle()` is correct, but only on the native side.

In short, `getNativeHandle()` is an **escape hatch** from Electron’s abstraction layer. Use it only when you fully control the native boundary and understand the OS-level expectations.

---

