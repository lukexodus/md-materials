## `did-finish-load` vs `dom-ready` vs `ready-to-show`


The `ready-to-show` event in Electron is a **BrowserWindow lifecycle signal** that indicates the window has completed its **first render** and can be displayed without a white flash.

Background context. In Electron, creating a `BrowserWindow` and loading a URL are asynchronous. The renderer process may finish loading resources (`did-finish-load`) before anything is actually painted to the screen. Showing the window too early often results in a blank or white window for a brief moment.

What `ready-to-show` means. The event fires when Electron determines that the renderer has produced its **first non-empty frame**. In practical terms, this means Chromium has something real to display.

Analogy. Think of a theater stage.  
`did-finish-load` is when the actors arrive and memorize their lines.  
`ready-to-show` is when the curtain is up, lights are on, and the scene is visually ready for the audience.  
Calling `show()` before that is like opening the curtain while the stage is still dark.

Typical usage pattern. The window is created with `show: false`. The application listens for `ready-to-show`, and only then calls `window.show()`. This avoids flicker and improves perceived startup quality.

Key distinctions from related events.

- `did-finish-load`: Indicates that HTML and subresources are loaded, but rendering may still be incomplete.   
- `dom-ready`: Fires earlier; DOM exists, but styles, images, and layout may not be finalized.   
- `ready-to-show`: Focuses specifically on **visual readiness**, not network or DOM state.
    

Important caveats.

- The event may **never fire** if rendering never produces a frame (for example, a blank page or a crash in the renderer). Production apps usually include a fallback timeout. 
- It is **not a guarantee** that all images, fonts, or async data are finished loading—only that something has been painted.
- It is emitted per window, not globally.

When you should use it.

- Splash-screen–free startup flows. 
- Apps that prioritize polish and perceived performance. 
- Windows that are heavy on CSS, fonts, or JavaScript execution at startup.

When you may not need it.

- Utility windows or dev tools.
- Windows shown immediately with minimal UI.
- Cases where a brief blank frame is acceptable.
    
In summary, `ready-to-show` is a **presentation-quality control**, not a loading milestone. Its purpose is to ensure that when a window becomes visible, it already looks intentional rather than unfinished.


---

