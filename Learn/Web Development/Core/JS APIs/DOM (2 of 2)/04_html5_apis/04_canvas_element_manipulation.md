## Canvas Element Manipulation


### Canvas Context Types

The canvas element supports multiple rendering contexts, each with distinct capabilities:

**2D Context (`CanvasRenderingContext2D`)**: Vector graphics, text, images, and pixel manipulation. Accessed via `canvas.getContext('2d')`.

**WebGL Context (`WebGLRenderingContext`)**: Hardware-accelerated 3D graphics using OpenGL ES. Accessed via `canvas.getContext('webgl')` or `canvas.getContext('webgl2')`.

**Bitmap Renderer Context**: Transfers `ImageBitmap` objects directly. Accessed via `canvas.getContext('bitmaprenderer')`.

Once a context is created, the canvas is locked to that type. Requesting a different context type returns `null`.

### Canvas Initialization and Sizing

#### HTML Declaration

```html
<canvas id="myCanvas" width="800" height="600"></canvas>
```

The `width` and `height` attributes define the canvas's coordinate space (drawing buffer size), not its display size. CSS controls display dimensions.

#### JavaScript Initialization

```javascript
const canvas = document.getElementById('myCanvas');
const ctx = canvas.getContext('2d');

// Set drawing buffer size
canvas.width = 1920;
canvas.height = 1080;

// CSS controls display size
canvas.style.width = '960px';
canvas.style.height = '540px';
```

#### Resolution and Display Size Relationship

When CSS dimensions differ from buffer dimensions, the browser scales the rendered output:

```javascript
// High DPI display handling
const dpr = window.devicePixelRatio || 1;
const rect = canvas.getBoundingClientRect();

canvas.width = rect.width * dpr;
canvas.height = rect.height * dpr;
canvas.style.width = rect.width + 'px';
canvas.style.height = rect.height + 'px';

ctx.scale(dpr, dpr);
```

This maintains crisp rendering on high-density displays by matching the buffer size to physical pixels while drawing in CSS pixels.

### Drawing Operations

#### Path Construction

Paths define shapes through a sequence of commands. The path exists in memory until stroked or filled:

```javascript
ctx.beginPath();
ctx.moveTo(50, 50);
ctx.lineTo(200, 50);
ctx.lineTo(200, 200);
ctx.closePath(); // Connects back to start point
ctx.stroke();
```

**Path methods**:

- `moveTo(x, y)`: Move to position without drawing
- `lineTo(x, y)`: Draw straight line to position
- `arc(x, y, radius, startAngle, endAngle, counterclockwise)`: Draw circular arc
- `arcTo(x1, y1, x2, y2, radius)`: Draw arc connecting two tangent lines
- `bezierCurveTo(cp1x, cp1y, cp2x, cp2y, x, y)`: Cubic Bézier curve
- `quadraticCurveTo(cpx, cpy, x, y)`: Quadratic Bézier curve
- `rect(x, y, width, height)`: Add rectangle to path
- `ellipse(x, y, radiusX, radiusY, rotation, startAngle, endAngle, counterclockwise)`: Draw elliptical arc

#### Filling and Stroking

```javascript
// Fill solid shape
ctx.fillStyle = '#ff0000';
ctx.fillRect(10, 10, 100, 100);

// Stroke outline
ctx.strokeStyle = '#0000ff';
ctx.lineWidth = 3;
ctx.strokeRect(10, 10, 100, 100);

// Path-based fill and stroke
ctx.beginPath();
ctx.arc(150, 150, 50, 0, Math.PI * 2);
ctx.fillStyle = 'rgba(0, 255, 0, 0.5)';
ctx.fill();
ctx.strokeStyle = '#000000';
ctx.stroke();
```

#### Line Styling

```javascript
ctx.lineWidth = 5;
ctx.lineCap = 'round'; // 'butt', 'round', 'square'
ctx.lineJoin = 'round'; // 'miter', 'round', 'bevel'
ctx.miterLimit = 10; // Maximum miter length
ctx.setLineDash([10, 5]); // Dash pattern: 10px line, 5px gap
ctx.lineDashOffset = 0; // Offset for dash pattern
```

### Text Rendering

```javascript
ctx.font = '48px serif';
ctx.fillStyle = '#000000';
ctx.fillText('Hello Canvas', 50, 100);

// Stroke text (outline)
ctx.strokeStyle = '#ff0000';
ctx.lineWidth = 2;
ctx.strokeText('Outline Text', 50, 200);

// Text alignment
ctx.textAlign = 'start'; // 'start', 'end', 'left', 'right', 'center'
ctx.textBaseline = 'alphabetic'; // 'top', 'hanging', 'middle', 'alphabetic', 'ideographic', 'bottom'

// Measure text dimensions
const metrics = ctx.measureText('Hello Canvas');
console.log(metrics.width); // Pixel width of text
console.log(metrics.actualBoundingBoxAscent); // Distance above baseline
console.log(metrics.actualBoundingBoxDescent); // Distance below baseline
```

### Image Drawing

#### Drawing Images

```javascript
const img = new Image();
img.onload = () => {
  // Draw entire image
  ctx.drawImage(img, 0, 0);
  
  // Draw with scaling
  ctx.drawImage(img, 0, 0, 400, 300);
  
  // Draw portion of image (sprite sheet slicing)
  // drawImage(image, sx, sy, sWidth, sHeight, dx, dy, dWidth, dHeight)
  ctx.drawImage(img, 32, 0, 32, 32, 100, 100, 64, 64);
};
img.src = 'image.png';
```

The nine-parameter version extracts a rectangle from the source image and draws it scaled to the destination rectangle.

#### Image Smoothing

```javascript
ctx.imageSmoothingEnabled = true;
ctx.imageSmoothingQuality = 'high'; // 'low', 'medium', 'high'
```

Disabling smoothing produces crisp pixel art when scaling images.

### Transformations

Transformations modify the coordinate system, affecting all subsequent drawing operations:

```javascript
// Translation
ctx.translate(100, 100); // Move origin to (100, 100)

// Rotation (radians)
ctx.rotate(Math.PI / 4); // Rotate 45 degrees

// Scaling
ctx.scale(2, 0.5); // Scale 2x horizontally, 0.5x vertically

// Shearing/Skewing with transform matrix
ctx.transform(1, 0.5, 0, 1, 0, 0); // Horizontal skew
```

Transformations accumulate. Each transformation applies relative to the current transformation state.

#### Transformation Matrix

The `setTransform` and `transform` methods use a 2D transformation matrix:

```javascript
// setTransform replaces current matrix
ctx.setTransform(a, b, c, d, e, f);

// transform multiplies with current matrix
ctx.transform(a, b, c, d, e, f);
```

Matrix parameters:

- `a`: Horizontal scaling
- `b`: Vertical skewing
- `c`: Horizontal skewing
- `d`: Vertical scaling
- `e`: Horizontal translation
- `f`: Vertical translation

```javascript
// Reset to identity matrix
ctx.setTransform(1, 0, 0, 1, 0, 0);

// Or use resetTransform (modern browsers)
ctx.resetTransform();
```

#### State Stack

```javascript
ctx.save(); // Push current state onto stack

ctx.translate(100, 100);
ctx.rotate(Math.PI / 4);
ctx.fillStyle = '#ff0000';
// ... drawing operations with transformed state

ctx.restore(); // Pop state from stack, reverting transformations and styles
```

The state stack preserves:

- Transformation matrix
- Clipping region
- Stroke and fill styles
- Line width, cap, join, dash pattern
- Text styling
- Global alpha and composite operation
- Shadow properties

### Compositing and Blending

#### Global Alpha

```javascript
ctx.globalAlpha = 0.5; // 0.0 (transparent) to 1.0 (opaque)
ctx.fillRect(50, 50, 100, 100); // Drawn at 50% opacity
```

#### Global Composite Operation

Controls how new shapes blend with existing canvas content:

```javascript
ctx.globalCompositeOperation = 'source-over'; // Default
```

Common operations:

- `source-over`: New content drawn over existing (default)
- `source-in`: New content only where it overlaps existing
- `source-out`: New content only where it doesn't overlap existing
- `source-atop`: New content drawn only where it overlaps existing
- `destination-over`: Existing content drawn over new
- `destination-in`: Existing content kept only where new content drawn
- `destination-out`: Existing content removed where new content drawn
- `destination-atop`: Existing content kept only where it overlaps new
- `lighter`: Colors added together
- `copy`: Only new content shown
- `xor`: Existing XOR new content
- `multiply`: Multiply color values
- `screen`: Invert, multiply, invert again
- `overlay`: Combination of multiply and screen
- `darken`: Keep darker of two colors
- `lighten`: Keep lighter of two colors

### Clipping

Clipping restricts drawing to a defined region:

```javascript
ctx.save();

// Define clipping path
ctx.beginPath();
ctx.arc(250, 250, 100, 0, Math.PI * 2);
ctx.clip();

// Only visible within clipping region
ctx.fillStyle = '#ff0000';
ctx.fillRect(0, 0, 500, 500);

ctx.restore(); // Remove clipping region
```

Multiple `clip()` calls intersect clipping regions. The clipping region cannot be expanded without restoring to a previous state.

#### Non-zero and Even-odd Fill Rules

```javascript
ctx.clip('nonzero'); // Default
ctx.clip('evenodd'); // Alternating inside/outside
```

The fill rule determines whether a point is inside the path for complex paths with self-intersections.

### Pixel Manipulation

#### Reading Pixel Data

```javascript
const imageData = ctx.getImageData(x, y, width, height);
const pixels = imageData.data; // Uint8ClampedArray

// Pixels stored as [r, g, b, a, r, g, b, a, ...]
for (let i = 0; i < pixels.length; i += 4) {
  const r = pixels[i];
  const g = pixels[i + 1];
  const b = pixels[i + 2];
  const a = pixels[i + 3];
  
  // Modify pixels
  pixels[i] = 255 - r; // Invert red channel
}
```

Each pixel occupies four consecutive array elements (RGBA), with values 0-255.

#### Writing Pixel Data

```javascript
ctx.putImageData(imageData, x, y);

// With dirty rectangle (only update portion)
ctx.putImageData(imageData, x, y, dirtyX, dirtyY, dirtyWidth, dirtyHeight);
```

#### Creating ImageData

```javascript
// Create blank ImageData
const imageData = ctx.createImageData(width, height);

// Create from existing ImageData
const newImageData = ctx.createImageData(existingImageData);
```

#### Performance Considerations for Pixel Manipulation

`getImageData` and `putImageData` are expensive operations:

- Force GPU-to-CPU synchronization in accelerated contexts
- Process potentially millions of pixels
- Block the main thread

For real-time effects, minimize calls and operate on smaller regions when possible.

### Gradients and Patterns

#### Linear Gradients

```javascript
const gradient = ctx.createLinearGradient(x0, y0, x1, y1);
gradient.addColorStop(0, '#ff0000');
gradient.addColorStop(0.5, '#00ff00');
gradient.addColorStop(1, '#0000ff');

ctx.fillStyle = gradient;
ctx.fillRect(0, 0, 400, 300);
```

The gradient runs from point (x0, y0) to point (x1, y1). Color stops define interpolation points between 0.0 and 1.0.

#### Radial Gradients

```javascript
const gradient = ctx.createRadialGradient(x0, y0, r0, x1, y1, r1);
gradient.addColorStop(0, '#ffffff');
gradient.addColorStop(1, '#000000');

ctx.fillStyle = gradient;
ctx.fillRect(0, 0, 400, 300);
```

Defines gradient between two circles. The gradient interpolates from the first circle (x0, y0, radius r0) to the second circle (x1, y1, radius r1).

#### Conic Gradients

```javascript
const gradient = ctx.createConicGradient(startAngle, x, y);
gradient.addColorStop(0, '#ff0000');
gradient.addColorStop(0.25, '#ffff00');
gradient.addColorStop(0.5, '#00ff00');
gradient.addColorStop(0.75, '#0000ff');
gradient.addColorStop(1, '#ff0000');

ctx.fillStyle = gradient;
ctx.fillRect(0, 0, 400, 300);
```

Creates gradient rotating around a center point, starting at the specified angle (in radians).

#### Patterns

```javascript
const img = new Image();
img.onload = () => {
  const pattern = ctx.createPattern(img, 'repeat');
  // Repeat options: 'repeat', 'repeat-x', 'repeat-y', 'no-repeat'
  
  ctx.fillStyle = pattern;
  ctx.fillRect(0, 0, 400, 300);
};
img.src = 'pattern.png';

// Pattern from canvas
const patternCanvas = document.createElement('canvas');
patternCanvas.width = 20;
patternCanvas.height = 20;
const patternCtx = patternCanvas.getContext('2d');
patternCtx.fillStyle = '#ff0000';
patternCtx.fillRect(0, 0, 10, 10);
const pattern = ctx.createPattern(patternCanvas, 'repeat');
```

Patterns can be created from `Image`, `Canvas`, or `Video` elements.

### Shadows

```javascript
ctx.shadowColor = 'rgba(0, 0, 0, 0.5)';
ctx.shadowBlur = 10; // Blur radius in pixels
ctx.shadowOffsetX = 5;
ctx.shadowOffsetY = 5;

ctx.fillStyle = '#ff0000';
ctx.fillRect(50, 50, 100, 100);

// Disable shadows
ctx.shadowColor = 'transparent';
// Or
ctx.shadowBlur = 0;
```

Shadows apply to all drawing operations (shapes, text, images). [Inference: Large blur values may impact performance as they require more computation per drawn pixel.]

### Clearing and Erasing

```javascript
// Clear entire canvas
ctx.clearRect(0, 0, canvas.width, canvas.height);

// Clear specific rectangle
ctx.clearRect(x, y, width, height);

// Erase by drawing with destination-out composite
ctx.globalCompositeOperation = 'destination-out';
ctx.fillRect(x, y, width, height);
ctx.globalCompositeOperation = 'source-over'; // Reset
```

### Hit Detection

Canvas doesn't provide built-in hit detection. Common approaches:

#### Mathematical Hit Detection

```javascript
function isPointInRect(x, y, rect) {
  return x >= rect.x && x <= rect.x + rect.width &&
         y >= rect.y && y <= rect.y + rect.height;
}

canvas.addEventListener('click', (e) => {
  const rect = canvas.getBoundingClientRect();
  const x = e.clientX - rect.left;
  const y = e.clientY - rect.top;
  
  if (isPointInRect(x, y, myRect)) {
    // Handle click
  }
});
```

#### Path-based Hit Detection

```javascript
ctx.beginPath();
ctx.arc(150, 150, 50, 0, Math.PI * 2);

canvas.addEventListener('click', (e) => {
  const rect = canvas.getBoundingClientRect();
  const x = e.clientX - rect.left;
  const y = e.clientY - rect.top;
  
  if (ctx.isPointInPath(x, y)) {
    // Point is inside the path
  }
  
  if (ctx.isPointInStroke(x, y)) {
    // Point is on the stroke
  }
});
```

These methods test against the current path or a provided Path2D object.

#### Off-screen Color Mapping

```javascript
// Draw objects with unique colors on hidden canvas
const hitCanvas = document.createElement('canvas');
const hitCtx = hitCanvas.getContext('2d');
hitCanvas.width = canvas.width;
hitCanvas.height = canvas.height;

const objectColors = new Map();
objects.forEach((obj, index) => {
  const color = `rgb(${index}, 0, 0)`;
  objectColors.set(color, obj);
  hitCtx.fillStyle = color;
  hitCtx.fillRect(obj.x, obj.y, obj.width, obj.height);
});

canvas.addEventListener('click', (e) => {
  const rect = canvas.getBoundingClientRect();
  const x = e.clientX - rect.left;
  const y = e.clientY - rect.top;
  
  const pixel = hitCtx.getImageData(x, y, 1, 1).data;
  const color = `rgb(${pixel[0]}, ${pixel[1]}, ${pixel[2]})`;
  const hitObject = objectColors.get(color);
});
```

### Path2D Objects

Path2D creates reusable path objects:

```javascript
const circle = new Path2D();
circle.arc(100, 100, 50, 0, Math.PI * 2);

const rect = new Path2D();
rect.rect(200, 200, 100, 100);

ctx.stroke(circle);
ctx.fill(rect);

// SVG path data
const heart = new Path2D('M10 10 L20 20 L30 10 Z');
ctx.fill(heart);

// Combining paths
const combined = new Path2D();
combined.addPath(circle);
combined.addPath(rect);
ctx.stroke(combined);

// Hit detection
if (ctx.isPointInPath(circle, x, y)) {
  // Point inside circle
}
```

### Animation Techniques

#### RequestAnimationFrame Loop

```javascript
let lastTime = 0;

function animate(currentTime) {
  const deltaTime = currentTime - lastTime;
  lastTime = currentTime;
  
  // Clear canvas
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  
  // Update state
  updateObjects(deltaTime);
  
  // Draw frame
  drawObjects();
  
  requestAnimationFrame(animate);
}

requestAnimationFrame(animate);
```

`requestAnimationFrame` synchronizes with the browser's repaint cycle (typically 60fps) and pauses when the tab is inactive.

#### Double Buffering

Canvas automatically double-buffers drawing operations. All commands execute on an off-screen buffer, then the result displays atomically. Explicit double buffering using multiple canvases is unnecessary unless creating complex layered effects.

#### Dirty Rectangle Optimization

```javascript
const dirtyRects = [];

function markDirty(x, y, width, height) {
  dirtyRects.push({ x, y, width, height });
}

function draw() {
  dirtyRects.forEach(rect => {
    ctx.clearRect(rect.x, rect.y, rect.width, rect.height);
    drawObjectsInRegion(rect);
  });
  dirtyRects.length = 0;
}
```

Only redraw portions of the canvas that changed, reducing pixel processing for large canvases.

#### Layering Multiple Canvases

```javascript
<div style="position: relative;">
  <canvas id="background" style="position: absolute; z-index: 0;"></canvas>
  <canvas id="midground" style="position: absolute; z-index: 1;"></canvas>
  <canvas id="foreground" style="position: absolute; z-index: 2;"></canvas>
</div>
```

Separate static and dynamic content across layers. Only animate canvases containing moving elements, leaving static layers unchanged.

### Performance Optimization

#### Minimize State Changes

```javascript
// Inefficient - multiple state changes
objects.forEach(obj => {
  ctx.fillStyle = obj.color;
  ctx.fillRect(obj.x, obj.y, obj.width, obj.height);
});

// Efficient - batch by state
const objectsByColor = groupBy(objects, 'color');
Object.entries(objectsByColor).forEach(([color, objs]) => {
  ctx.fillStyle = color;
  objs.forEach(obj => {
    ctx.fillRect(obj.x, obj.y, obj.width, obj.height);
  });
});
```

Context state changes are expensive. Batch operations requiring the same state.

#### Pre-render Complex Shapes

```javascript
// Create off-screen canvas for complex shape
const shapeCanvas = document.createElement('canvas');
const shapeCtx = shapeCanvas.getContext('2d');
shapeCanvas.width = 100;
shapeCanvas.height = 100;

// Draw complex shape once
drawComplexShape(shapeCtx);

// Reuse in main canvas
function draw() {
  for (let i = 0; i < 100; i++) {
    ctx.drawImage(shapeCanvas, x[i], y[i]);
  }
}
```

#### Avoid Unnecessary Clears

```javascript
// Only clear changed regions
ctx.clearRect(prevX, prevY, width, height);

// Or use fillRect with background color
ctx.fillStyle = '#ffffff';
ctx.fillRect(0, 0, canvas.width, canvas.height);
```

Full canvas clears process every pixel. Clearing only necessary regions reduces work.

#### Integer Coordinates

```javascript
// Causes antialiasing, slower rendering
ctx.fillRect(10.5, 10.5, 100, 100);

// Crisp, faster rendering
ctx.fillRect(10, 10, 100, 100);
```

Non-integer coordinates trigger subpixel rendering and antialiasing.

#### Reduce Shadow Complexity

Shadows are expensive:

```javascript
// Cache shadowed content
const shadowCanvas = document.createElement('canvas');
const shadowCtx = shadowCanvas.getContext('2d');
shadowCtx.shadowColor = 'rgba(0, 0, 0, 0.5)';
shadowCtx.shadowBlur = 10;
drawShape(shadowCtx);

// Draw cached version
ctx.drawImage(shadowCanvas, x, y);
```

### Canvas Security and Tainting

Canvases become "tainted" when drawing cross-origin images without CORS headers:

```javascript
const img = new Image();
img.crossOrigin = 'anonymous'; // Request CORS
img.src = 'https://example.com/image.png';

img.onload = () => {
  ctx.drawImage(img, 0, 0);
  
  // This will throw SecurityError if image is tainted
  const imageData = ctx.getImageData(0, 0, 100, 100);
};
```

Tainted canvases prevent:

- `getImageData()`
- `toDataURL()`
- `toBlob()`

The entire canvas becomes tainted if any tainted content is drawn to it.

### Canvas to Image Export

```javascript
// Data URL
const dataURL = canvas.toDataURL('image/png');
const img = new Image();
img.src = dataURL;

// Specify quality for JPEG/WEBP (0.0 to 1.0)
const jpegURL = canvas.toDataURL('image/jpeg', 0.8);

// Blob (asynchronous, more efficient)
canvas.toBlob((blob) => {
  const url = URL.createObjectURL(blob);
  const img = new Image();
  img.src = url;
  
  // Clean up
  URL.revokeObjectURL(url);
}, 'image/png');

// Download
canvas.toBlob((blob) => {
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = 'canvas-image.png';
  a.click();
  URL.revokeObjectURL(url);
});
```

### OffscreenCanvas

OffscreenCanvas enables canvas rendering in Web Workers:

```javascript
// Main thread
const offscreen = canvas.transferControlToOffscreen();
const worker = new Worker('canvas-worker.js');
worker.postMessage({ canvas: offscreen }, [offscreen]);

// canvas-worker.js
self.onmessage = (e) => {
  const canvas = e.data.canvas;
  const ctx = canvas.getContext('2d');
  
  function draw() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);
    // Drawing operations
    requestAnimationFrame(draw);
  }
  
  requestAnimationFrame(draw);
};
```

This offloads rendering to a separate thread, keeping the main thread responsive. [Inference: Support varies across browsers; feature detection recommended.]

### Canvas Memory Considerations

Large canvases consume significant memory:

```javascript
// Memory usage (approximate)
const bytesPerPixel = 4; // RGBA
const memoryUsage = canvas.width * canvas.height * bytesPerPixel;

// 4K canvas: 3840 × 2160 × 4 = 33,177,600 bytes (~31.6 MB)
```

Multiple large canvases or frequent canvas creation can exhaust available memory, particularly on mobile devices. Reuse canvases when possible and limit maximum dimensions based on device capabilities.

### Canvas Context Attributes

```javascript
const ctx = canvas.getContext('2d', {
  alpha: false, // Disable alpha channel for performance
  desynchronized: true, // Reduce latency (may cause tearing)
  willReadFrequently: true // Optimize for frequent getImageData calls
});
```

These attributes must be set during context creation and cannot be changed afterward. [Unverified: Browser support and actual performance impact of these attributes varies.]

---

