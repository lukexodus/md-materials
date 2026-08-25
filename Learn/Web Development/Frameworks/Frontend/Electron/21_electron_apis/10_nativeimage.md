## nativeImage


The `nativeImage` module in Electron provides utilities for creating and manipulating images. It handles various image formats and sources, including files, buffers, and data URLs.

### Creating Native Images

You can create native images from several sources:

```javascript
const { nativeImage } = require('electron')

// From a file path
const image1 = nativeImage.createFromPath('/path/to/image.png')

// From a buffer
const buffer = fs.readFileSync('/path/to/image.png')
const image2 = nativeImage.createFromBuffer(buffer)

// From a data URL
const image3 = nativeImage.createFromDataURL('data:image/png;base64,iVBORw0KG...')

// Create an empty image
const image4 = nativeImage.createEmpty()
```

### Common Methods

**Getting image properties:**

```javascript
const size = image.getSize()  // Returns { width: number, height: number }
const aspectRatio = image.getAspectRatio()  // Returns width/height
const isEmpty = image.isEmpty()  // Returns boolean
```

**Converting and exporting:**

```javascript
// Convert to different formats
const pngBuffer = image.toPNG()
const jpegBuffer = image.toJPEG(quality)  // quality: 0-100
const dataURL = image.toDataURL()
const bitmap = image.toBitmap()

// Get native handle (platform-specific)
const nativeHandle = image.getNativeHandle()
```

**Resizing and cropping:**

```javascript
// Resize image
const resized = image.resize({ 
  width: 100, 
  height: 100,
  quality: 'best'  // 'good', 'better', 'best'
})

// Crop image
const cropped = image.crop({ 
  x: 10, 
  y: 10, 
  width: 50, 
  height: 50 
})
```

### High DPI Support

Electron’s `nativeImage` handles high-DPI displays automatically:

```javascript
// Add representations for different scale factors
const image = nativeImage.createEmpty()
image.addRepresentation({
  scaleFactor: 1.0,
  buffer: buffer1x
})
image.addRepresentation({
  scaleFactor: 2.0,
  buffer: buffer2x
})
```

This snippet demonstrates how **Electron’s `nativeImage` supports high-DPI (HiDPI / Retina) displays** by storing multiple image representations at different scale factors.

Brief background on high-DPI.
On high-DPI displays, one “CSS pixel” maps to multiple physical pixels. For example, on a 2× display, a 16×16 logical icon is actually rendered using a 32×32 bitmap. If you provide only a 1× bitmap, the OS scales it up, which causes blur.

What `nativeImage` is doing conceptually.
A `nativeImage` is not a single bitmap. It is more like a **folder of the same image at different resolutions**, each labeled with the scale factor it is meant for. The OS then picks the most appropriate one at render time.

Analogy.
Think of it like road signs printed in different sizes. The highway authority stores multiple versions of the same sign. Drivers do not choose which one to read; the system installs the correct size for the road. Similarly, Electron hands all versions to the OS, and the OS chooses.

Explanation of the code.

```javascript
const image = nativeImage.createEmpty()
```

This creates an empty `NativeImage` container with no bitmap data yet.

```javascript
image.addRepresentation({
  scaleFactor: 1.0,
  buffer: buffer1x
})
```

This adds the **standard-DPI version** of the image.
• `scaleFactor: 1.0` means “1 device pixel per logical pixel.”
• `buffer1x` must contain raw pixel data at the base resolution.

```javascript
image.addRepresentation({
  scaleFactor: 2.0,
  buffer: buffer2x
})
```

This adds the **HiDPI version**.
• `scaleFactor: 2.0` means “2 device pixels per logical pixel.”
• `buffer2x` should be exactly double the width and height of the 1× image.

How Electron uses this internally.
When the image is used (tray icon, window icon, menu item, etc.), Electron:
1. Detects the display’s scale factor.
2. Chooses the closest matching representation.
3. Hands that bitmap to the OS without rescaling when possible.

Why this matters.
• Sharp icons on Retina / 4K displays.
• No manual DPI detection logic in your app.
• Correct behavior when a window is moved between monitors with different scale factors.

Important constraints.
1. The buffers must be raw image data in a supported format (usually PNG decoded into pixels, or bitmap data from `nativeImage`).
2. Width and height must align with the scale factor (e.g., 16×16 @1×, 32×32 @2×).
3. If a matching scale factor is missing, Electron will fall back and scale, reducing quality.

When you need to do this manually.
You typically do this only when:
• Constructing images dynamically.
• Loading images from nonstandard sources (binary streams, native addons).
• Building tray or dock icons programmatically.

If you are loading icons from files, Electron already does this automatically when you provide correctly named assets (for example, `icon.png`, `icon@2x.png` on macOS).

In summary, this pattern explicitly teaches `nativeImage` how to behave like a first-class, DPI-aware OS image by supplying multiple resolutions and letting the system choose correctly.

### Template Images (macOS)

On macOS, you can create template images that adapt to the system theme:

```javascript
const image = nativeImage.createFromPath('/path/to/icon.png')
image.setTemplateImage(true)
```

This snippet is specific to **macOS** and uses a concept called a **template image**.

Brief background on template images.  
On macOS, certain UI icons are not drawn with fixed colors. Instead, the system treats them as **masks** and automatically tints them based on context, such as light mode, dark mode, active/inactive state, or accessibility contrast settings.

What `setTemplateImage(true)` means.  
Calling `image.setTemplateImage(true)` tells macOS:  
“This image should be treated as a symbolic shape, not as a fully colored picture.”

Conceptual analogy.  
Think of a rubber stamp rather than a photograph.  
A photograph has fixed colors. A rubber stamp has only shape, and the ink color is chosen at the moment it is pressed. A template image is the rubber stamp.

Explanation of the code.

```javascript
const image = nativeImage.createFromPath('/path/to/icon.png')
```

This loads an image from disk into a `NativeImage`.

```javascript
image.setTemplateImage(true)
```

This marks the image as a template. From this point on:  
• The system ignores most original colors.  
• The alpha channel (transparency) defines the shape.  
• macOS applies the appropriate tint automatically.

Where template images are typically used.  
• Menu bar (status bar) icons.  
• Toolbar icons.  
• Sidebar icons in native-looking UIs.

Practical requirements for the image asset.

1. Use a **monochrome** image (usually black with transparency).
2. Avoid gradients, shadows, or multiple colors.
3. Ensure clean alpha edges; the shape quality directly affects rendering.

What happens if you do not use a template image.  
If you use a regular image:  
• It will keep its colors.  
• It may look incorrect in dark mode.  
• It will not automatically reflect active/inactive state changes.

Platform limitation.  
This behavior is **macOS-only**.  
On Windows and Linux, `setTemplateImage(true)` has no effect, because the concept does not exist in their native UI systems.

How this interacts with high-DPI.  
Template images still benefit from multiple scale factors (`@2x`, `@3x`). The system chooses the correct resolution first, then applies tinting.

In summary.  
`setTemplateImage(true)` tells macOS to treat your icon as a **theme-aware symbol**. You provide the shape; the system provides the color, ensuring correct appearance across light mode, dark mode, and different UI states.

### Practical Examples

**Setting an app icon:**

```javascript
const { app, nativeImage } = require('electron')

const icon = nativeImage.createFromPath('app-icon.png')
app.dock.setIcon(icon)  // macOS
```

**Creating a tray icon:**

```javascript
const { Tray, nativeImage } = require('electron')

const trayIcon = nativeImage.createFromPath('tray-icon.png')
const tray = new Tray(trayIcon)
```

**Processing images:**

```javascript
// Load, resize, and save
const original = nativeImage.createFromPath('large.png')
const thumbnail = original.resize({ width: 200, height: 200 })
const thumbnailBuffer = thumbnail.toPNG()
fs.writeFileSync('thumbnail.png', thumbnailBuffer)
```

The module integrates with other Electron APIs like `BrowserWindow` (for window icons), `Tray` (for system tray icons), and `Notification` (for notification icons).​​​​​​​​​​​​​​​​

---

