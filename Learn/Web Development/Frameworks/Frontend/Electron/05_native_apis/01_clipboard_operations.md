## Clipboard Operations


The clipboard module provides methods for performing copy and paste operations on the system clipboard. It runs in both Main and Renderer processes (non-sandboxed only).[1][2]

### Text Operations

The clipboard supports reading and writing plain text content.[1]

**Writing Text**
```javascript
const { clipboard } = require('electron')

clipboard.writeText('hello i am a bit of text!')
```

**Reading Text**
```javascript
const text = clipboard.readText()
console.log(text)
// hello i am a bit of text!
```

Both methods accept an optional `type` parameter that can be `'clipboard'` (default) or `'selection'` (Linux only). The selection clipboard is specific to X Window systems and represents text selected with the mouse.[3][1]

### HTML Markup Operations

HTML content can be written and read from the clipboard.[2][1]

**Writing HTML**
```javascript
const { clipboard } = require('electron')

clipboard.writeHTML('<b>Hi</b>')
```

**Reading HTML**
```javascript
const html = clipboard.readHTML()
console.log(html)
// <meta charset='utf-8'><b>Hi</b>
```

The `readHTML()` method returns markup when available, though behavior may vary by platform. On some systems, plain text written via `writeHTML()` may be returned as plain text rather than markup.[4][2]

### Image Operations

The clipboard can handle images using NativeImage objects.[2][1]

**Writing Images**
```javascript
const { clipboard, nativeImage } = require('electron')

const image = nativeImage.createFromPath('/path/to/image.png')
clipboard.writeImage(image)
```

**Reading Images**
```javascript
const image = clipboard.readImage()
console.log(image.isEmpty()) // false if image exists
```

The `readImage()` method returns a `NativeImage` object representing clipboard image content.[1][2]

### Rich Text Format (RTF)

RTF content can be read and written for rich text editing applications.[1]

**Writing RTF**
```javascript
clipboard.writeRTF('{\\rtf1\\ansi{\\fonttbl\\f0\\fswiss Helvetica;}\\f0\\pard\nThis is some {\\b bold} text.\\par\n}')
```

**Reading RTF**
```javascript
const rtf = clipboard.readRTF()
console.log(rtf)
```

RTF operations preserve text formatting across clipboard transfers.[1]

### Bookmarks (macOS)

Bookmarks store URLs with associated titles for drag-and-drop operations.[2][1]

**Writing Bookmarks**
```javascript
clipboard.writeBookmark('Electron Homepage', 'https://electronjs.org')
```

**Reading Bookmarks**
```javascript
const bookmark = clipboard.readBookmark()
console.log(bookmark.title) // 'Electron Homepage'
console.log(bookmark.url)   // 'https://electronjs.org'
```

This feature is macOS-specific and returns an object with `title` and `url` properties.[1]

### Find Pasteboard (macOS)

macOS provides a separate find pasteboard for search-related operations.[2]

**Writing to Find Pasteboard**
```javascript
clipboard.writeFindText('search term')
```

**Reading from Find Pasteboard**
```javascript
const findText = clipboard.readFindText()
console.log(findText) // 'search term'
```

The find pasteboard holds information about the current state of the active application's find panel.[2]

### Buffer Operations

Custom data formats can be written using buffers.[1]

**Writing Buffers**
```javascript
const buffer = Buffer.from('this is binary', 'utf8')
clipboard.writeBuffer('public/utf8-plain-text', buffer)
```

**Reading Buffers**
```javascript
const ret = clipboard.readBuffer('public/utf8-plain-text')
console.log(ret.toString('utf8')) // 'this is binary'
```

The `format` parameter specifies a custom MIME type or format identifier.[1]

### Composite Write Operations

The `write()` method enables writing multiple formats simultaneously.[4][1]

```javascript
const { clipboard, nativeImage } = require('electron')

clipboard.write({
  text: 'Plain text version',
  html: '<b>HTML version</b>',
  image: nativeImage.createFromPath('/path/to/image.png'),
  rtf: '{\\rtf1\\ansi RTF version}',
  bookmark: 'https://electronjs.org'
})
```

This atomically writes all provided formats to the clipboard. Applications can then read the format most appropriate for their needs.[4][2][1]

### Clearing the Clipboard

Remove all clipboard content using the `clear()` method.[1]

```javascript
clipboard.clear()
```

An optional `type` parameter can specify `'selection'` or `'clipboard'` (default).[1]

### Checking Available Formats

Determine which formats are currently available in the clipboard.[1]

```javascript
const formats = clipboard.availableFormats()
console.log(formats)
// ['text/plain', 'text/html', 'image/png']
```

The `availableFormats()` method returns an array of MIME type strings. The optional `type` parameter can be `'selection'` or `'clipboard'`.[1]

**Checking Specific Format**
```javascript
const hasText = clipboard.has('text/plain')
console.log(hasText) // true or false
```

The `has()` method checks if a specific format exists.[1]

### Linux Selection Clipboard

Linux systems support a separate selection clipboard for mouse-highlighted text.[3][1]

```javascript
const { clipboard } = require('electron')

clipboard.writeText('Example String', 'selection')
console.log(clipboard.readText('selection'))
// Example String
```

All clipboard methods accept `'selection'` as the second parameter on Linux to interact with the selection clipboard instead of the standard clipboard.[3][1]

### Context Isolation Considerations

When using context isolation in the renderer process, clipboard access requires exposure through the `contextBridge` API.[2]

**Preload Script**
```javascript
const { contextBridge, clipboard } = require('electron')

contextBridge.exposeInMainWorld('clipboard', {
  readText: () => clipboard.readText(),
  writeText: (text) => clipboard.writeText(text)
})
```

**Renderer Process**
```javascript
// Now accessible via window.clipboard
window.clipboard.writeText('Hello World')
const text = window.clipboard.readText()
```

This ensures secure clipboard access in sandboxed renderer processes.[2]

Sources
[1] clipboard | Electron https://www.electronjs.org/docs/latest/api/clipboard/
[2] clipboard | Electron https://electronjs.org/docs/latest/api/clipboard
[3] clipboard · GitBook http://electron.ebookchain.org/en/api/clipboard.html
[4] Clipboard API in ElectronJS - GeeksforGeeks https://www.geeksforgeeks.org/javascript/clipboard-api-in-electronjs/
[5] clipboard https://www.electronjs.org/docs/latest/api/clipboard
[6] Accessing Clipboard Files in Electron: A Complete Guide https://jsdev.space/clipboard-electron/
[7] Sending File to the Renderer - Electron, v3 - Frontend Masters https://frontendmasters.com/courses/electron-v3/sending-file-to-the-renderer/
[8] In Electron Framework, Can I access clipboard? https://stackoverflow.com/questions/31130150/in-electron-framework-can-i-access-clipboard/31175073
[9] Mastering the use of the Clipboard with Electron Framework https://ourcodeworld.com/articles/read/203/mastering-the-use-of-the-clipboard-with-electron-framework
[10] Access Electron API from a completely different system process https://stackoverflow.com/questions/51224896/access-electron-api-from-a-completely-different-system-process


---

