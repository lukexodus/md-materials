## desktopCapturer


The `desktopCapturer` is an Electron API module that allows you to capture audio and video from desktop sources such as screens and windows.

### Basic Usage

```javascript
const { desktopCapturer } = require('electron');

// Get available sources
desktopCapturer.getSources({ types: ['window', 'screen'] })
  .then(async sources => {
    for (const source of sources) {
      console.log(source.name, source.id);
    }
  });
```

### Key Methods

**`desktopCapturer.getSources(options)`**

- Returns a Promise that resolves with an array of `DesktopCapturerSource` objects
- `options.types` - Array of strings specifying source types: `'screen'` and/or `'window'`
- `options.thumbnailSize` - Size of the thumbnail (optional)
- `options.fetchWindowIcons` - Boolean to fetch window icons (optional)

### DesktopCapturerSource Object Properties

- `id` - String identifier for the source (used with `getUserMedia`)
- `name` - Screen or window title
- `thumbnail` - NativeImage thumbnail
- `display_id` - Display identifier
- `appIcon` - Application icon (if `fetchWindowIcons` was true)

### Using with WebRTC

```javascript
async function getStream(sourceId) {
  const stream = await navigator.mediaDevices.getUserMedia({
    audio: false,
    video: {
      mandatory: {
        chromeMediaSource: 'desktop',
        chromeMediaSourceId: sourceId
      }
    }
  });
  return stream;
}
```

[Unverified] The exact API surface and all implementation details may have changed in recent Electron versions beyond my knowledge cutoff. I recommend checking the official Electron documentation at <https://www.electronjs.org/docs> for the most current information.​​​​​​​​​​​​​​​​

---

