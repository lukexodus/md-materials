## Context Menu Params


In Electron, a context menu is typically implemented by listening to the `context-menu` event on a `webContents` instance. Electron provides a `params` object to that event, which describes *what the user right-clicked on* and *the state of the page at that moment*.

Think of `params` as a diagnostic report handed to you at right-click time: it tells you “where the click happened” and “what actions make sense here,” so you can decide which menu items to show.

Background on the term:
A *context menu* is a menu whose options depend on context—similar to how right-clicking text in a word processor shows copy/paste, while right-clicking an image shows save or copy image.

Below is a canonical Electron example.

Main process example:

```js
import { app, BrowserWindow, Menu } from 'electron';

app.whenReady().then(() => {
  const win = new BrowserWindow({
    webPreferences: {
      preload: 'preload.js',
    },
  });

  win.loadURL('https://example.com');

  win.webContents.on('context-menu', (event, params) => {
    const template = [];

    if (params.linkURL) {
      template.push({
        label: 'Open Link in Browser',
        click: () => {
          require('electron').shell.openExternal(params.linkURL);
        },
      });
    }

    if (params.mediaType === 'image') {
      template.push({
        label: 'Save Image',
        click: () => {
          console.log('Image URL:', params.srcURL);
        },
      });
    }

    if (params.selectionText) {
      template.push({
        label: 'Copy',
        role: 'copy',
      });
    }

    if (params.isEditable) {
      template.push(
        { type: 'separator' },
        { role: 'undo' },
        { role: 'redo' },
        { type: 'separator' },
        { role: 'cut' },
        { role: 'paste' }
      );
    }

    if (template.length > 0) {
      const menu = Menu.buildFromTemplate(template);
      menu.popup({ window: win });
    }
  });
});
```

Key fields in `params` and what they mean:

* `mediaType`: What was clicked (`none`, `image`, `video`, `audio`, `canvas`, `file`).
* `linkURL`: URL if the click was on a hyperlink.
* `srcURL`: Source URL of media (for images, videos, etc.).
* `selectionText`: Text currently selected, if any.
* `isEditable`: True if the click occurred inside an input, textarea, or content-editable element.
* `x`, `y`: Coordinates of the click within the page.

Analogy:
Imagine a security guard checking a visitor’s badge before opening doors. `params` is the badge—it tells you whether the click came from text, an image, or an input field, so you only “open the doors” (menu options) that make sense.

Important practical note:
Context menus are normally implemented in the **main process**, because `Menu` and `menu.popup()` are main-process APIs. You can forward the event from preload or renderer if needed, but the menu itself is created in main.


---

