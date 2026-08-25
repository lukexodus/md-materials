## Drag and Drop Interfaces (DOM/JS)


### Native HTML5 Drag and Drop API

The HTML5 Drag and Drop API provides built-in browser support for dragging elements. Any element becomes draggable by setting `draggable="true"`.

#### Event Lifecycle

The drag operation triggers seven distinct events in sequence:

**On the draggable element:**

- `dragstart` - Fires when drag begins; set drag data and visual feedback here
- `drag` - Fires continuously during drag (every few hundred milliseconds)
- `dragend` - Fires when drag completes, regardless of success or cancellation

**On drop targets:**

- `dragenter` - Fires when dragged element enters a valid drop target
- `dragover` - Fires continuously while over target; must call `preventDefault()` to allow drop
- `dragleave` - Fires when dragged element leaves the target
- `drop` - Fires when element is released over target; only if `dragover` was prevented

#### DataTransfer Object

The `DataTransfer` object carries data between drag source and drop target. Access it via `event.dataTransfer`.

**Setting data:**

```javascript
element.addEventListener('dragstart', (e) => {
  e.dataTransfer.setData('text/plain', 'some data');
  e.dataTransfer.setData('application/json', JSON.stringify({id: 123}));
});
```

**Reading data:**

```javascript
element.addEventListener('drop', (e) => {
  e.preventDefault();
  const text = e.dataTransfer.getData('text/plain');
  const json = JSON.parse(e.dataTransfer.getData('application/json'));
});
```

**Key properties:**

- `effectAllowed` - Restricts cursor feedback ('copy', 'move', 'link', 'copyMove', 'all', 'none')
- `dropEffect` - Indicates operation type during drag
- `files` - FileList for file drag operations
- `types` - Array of MIME types available in current drag

#### Visual Feedback Mechanisms

**Drag image customization:**

```javascript
dragstart: (e) => {
  const ghost = document.createElement('div');
  ghost.className = 'custom-drag-ghost';
  ghost.textContent = 'Dragging...';
  document.body.appendChild(ghost);
  e.dataTransfer.setDragImage(ghost, 0, 0);
  setTimeout(() => ghost.remove(), 0);
}
```

**CSS pseudo-classes:** The browser provides `:drag` pseudo-class but support is limited. Use JavaScript classes instead:

```javascript
dragstart: (e) => e.target.classList.add('dragging'),
dragend: (e) => e.target.classList.remove('dragging')
```

#### Cross-Browser Quirks

**Firefox requires data to be set:** Firefox will not initiate drag unless `setData()` is called during `dragstart`, even if the data isn't used.

**Mobile Safari incompatibility:** iOS Safari does not support HTML5 drag and drop for touch events until iOS 15, and even then support is incomplete. Use touch event polyfills or pointer events instead.

**Event timing differences:** The order of `dragleave` and `dragenter` when moving between nested elements varies by browser. Track state carefully to avoid flicker.

### Pointer-Based Drag Implementation

Modern drag interfaces often bypass the native API entirely, using pointer events for precise control.

#### Pointer Events vs Mouse Events

Pointer events unify mouse, touch, and pen input:

```javascript
element.addEventListener('pointerdown', handleDragStart);
element.addEventListener('pointermove', handleDragMove);
element.addEventListener('pointerup', handleDragEnd);
element.addEventListener('pointercancel', handleDragCancel);
```

**Advantages over mouse events:**

- Single event handler for all input types
- `setPointerCapture()` ensures events continue even when pointer leaves element
- Pressure sensitivity via `pressure` property
- Contact geometry via `width` and `height` properties

#### Pointer Capture

```javascript
let isDragging = false;

function handlePointerDown(e) {
  isDragging = true;
  e.target.setPointerCapture(e.pointerId);
  // Store initial position
  const rect = e.target.getBoundingClientRect();
  e.target.dataset.offsetX = e.clientX - rect.left;
  e.target.dataset.offsetY = e.clientY - rect.top;
}

function handlePointerMove(e) {
  if (!isDragging) return;
  
  const offsetX = parseFloat(e.target.dataset.offsetX);
  const offsetY = parseFloat(e.target.dataset.offsetY);
  
  e.target.style.left = `${e.clientX - offsetX}px`;
  e.target.style.top = `${e.clientY - offsetY}px`;
}

function handlePointerUp(e) {
  isDragging = false;
  e.target.releasePointerCapture(e.pointerId);
}
```

Pointer capture prevents losing tracking when cursor moves rapidly or leaves the window.

#### Touch Event Considerations

When supporting touch directly (without pointer events):

**Prevent default scrolling:**

```javascript
touchstart: (e) => {
  e.preventDefault(); // Blocks scrolling
  // Store touch identifier
  activeTouch = e.touches[0].identifier;
}
```

**Track correct touch:**

```javascript
touchmove: (e) => {
  const touch = Array.from(e.touches).find(t => t.identifier === activeTouch);
  if (!touch) return;
  // Use touch.clientX, touch.clientY
}
```

**Handle multi-touch:** Multi-touch requires tracking multiple simultaneous drags by `identifier`. Most drag interfaces ignore secondary touches.

### Coordinate Systems and Transforms

#### Position Calculation Strategies

**Absolute positioning (simple):**

```javascript
element.style.left = `${e.clientX}px`;
element.style.top = `${e.clientY}px`;
```

Requires `position: absolute` or `fixed`. Breaks in scrollable containers with transformed ancestors.

**Transform-based positioning (GPU-accelerated):**

```javascript
const x = e.clientX - initialX;
const y = e.clientY - initialY;
element.style.transform = `translate(${x}px, ${y}px)`;
```

Better performance through GPU compositing. Maintains document flow. Requires tracking delta from start position.

**Relative to container:**

```javascript
const container = element.offsetParent;
const rect = container.getBoundingClientRect();
const x = e.clientX - rect.left - container.scrollLeft;
const y = e.clientY - rect.top - container.scrollTop;
```

#### Handling CSS Transforms

Parent transforms affect coordinate calculations. `getBoundingClientRect()` returns transformed coordinates, but `offsetLeft/Top` do not.

**Getting actual visual position:**

```javascript
function getTransformedPosition(element) {
  const rect = element.getBoundingClientRect();
  return {
    x: rect.left + window.scrollX,
    y: rect.top + window.scrollY
  };
}
```

**Inverting parent transforms:** For precise positioning under scale/rotate transforms, invert the transformation matrix:

```javascript
function getTransformMatrix(element) {
  const style = window.getComputedStyle(element);
  const matrix = style.transform;
  if (matrix === 'none') return null;
  
  const values = matrix.match(/matrix.*\((.+)\)/)[1].split(', ');
  return values.map(parseFloat);
}
```

[Inference]: Full matrix inversion for arbitrary transforms requires matrix math libraries. Most interfaces constrain transforms or reset them during drag.

#### Scroll Compensation

Scrollable containers require offset adjustment:

```javascript
function getScrollAwarePosition(e, container) {
  const rect = container.getBoundingClientRect();
  return {
    x: e.clientX - rect.left + container.scrollLeft,
    y: e.clientY - rect.top + container.scrollTop
  };
}
```

**Auto-scrolling near edges:**

```javascript
function checkAutoScroll(e, container) {
  const threshold = 50;
  const rect = container.getBoundingClientRect();
  const speed = 5;
  
  if (e.clientY - rect.top < threshold) {
    container.scrollTop -= speed;
  } else if (rect.bottom - e.clientY < threshold) {
    container.scrollTop += speed;
  }
  
  if (e.clientX - rect.left < threshold) {
    container.scrollLeft -= speed;
  } else if (rect.right - e.clientX < threshold) {
    container.scrollLeft += speed;
  }
}
```

### Drop Zone Detection

#### Geometric Collision Detection

**Point-in-rectangle:**

```javascript
function isOverDropZone(x, y, dropZone) {
  const rect = dropZone.getBoundingClientRect();
  return x >= rect.left && x <= rect.right &&
         y >= rect.top && y <= rect.bottom;
}
```

**Center-point detection:**

```javascript
function getDraggedElementCenter(element) {
  const rect = element.getBoundingClientRect();
  return {
    x: rect.left + rect.width / 2,
    y: rect.top + rect.height / 2
  };
}
```

Using center point prevents edge cases where drag element partially overlaps multiple zones.

**Area-based detection (overlap percentage):**

```javascript
function getOverlapPercentage(rect1, rect2) {
  const x_overlap = Math.max(0, 
    Math.min(rect1.right, rect2.right) - Math.max(rect1.left, rect2.left));
  const y_overlap = Math.max(0,
    Math.min(rect1.bottom, rect2.bottom) - Math.max(rect1.top, rect2.top));
  
  const overlapArea = x_overlap * y_overlap;
  const rect1Area = rect1.width * rect1.height;
  
  return (overlapArea / rect1Area) * 100;
}
```

#### Z-Index and Element Stacking

**Finding topmost drop zone:**

```javascript
function getTopMostDropZone(x, y, dropZones) {
  const candidates = dropZones.filter(zone => 
    isOverDropZone(x, y, zone)
  );
  
  if (candidates.length === 0) return null;
  if (candidates.length === 1) return candidates[0];
  
  // Compare z-index and DOM order
  return candidates.reduce((topmost, current) => {
    const topmostZ = parseInt(getComputedStyle(topmost).zIndex) || 0;
    const currentZ = parseInt(getComputedStyle(current).zIndex) || 0;
    return currentZ > topmostZ ? current : topmost;
  });
}
```

**Using `elementsFromPoint()`:**

```javascript
function getDropZoneAtPoint(x, y, dropZoneSelector) {
  const elements = document.elementsFromPoint(x, y);
  return elements.find(el => el.matches(dropZoneSelector));
}
```

This respects actual visual stacking order including z-index, but has performance implications with many elements.

#### Spatial Indexing for Large Sets

With hundreds of drop zones, checking every zone per pixel movement becomes expensive.

**Grid-based spatial hash:**

```javascript
class SpatialGrid {
  constructor(cellSize = 100) {
    this.cellSize = cellSize;
    this.grid = new Map();
  }
  
  getCell(x, y) {
    const cellX = Math.floor(x / this.cellSize);
    const cellY = Math.floor(y / this.cellSize);
    return `${cellX},${cellY}`;
  }
  
  insert(element) {
    const rect = element.getBoundingClientRect();
    const cells = this.getCellsForRect(rect);
    
    cells.forEach(cell => {
      if (!this.grid.has(cell)) this.grid.set(cell, []);
      this.grid.get(cell).push(element);
    });
  }
  
  getCellsForRect(rect) {
    const cells = [];
    const startX = Math.floor(rect.left / this.cellSize);
    const endX = Math.floor(rect.right / this.cellSize);
    const startY = Math.floor(rect.top / this.cellSize);
    const endY = Math.floor(rect.bottom / this.cellSize);
    
    for (let x = startX; x <= endX; x++) {
      for (let y = startY; y <= endY; y++) {
        cells.push(`${x},${y}`);
      }
    }
    return cells;
  }
  
  query(x, y) {
    const cell = this.getCell(x, y);
    return this.grid.get(cell) || [];
  }
}
```

Reduces collision checks from O(n) to O(k) where k is elements per grid cell.

### Constraint Systems

#### Axis Locking

```javascript
let dragAxis = null;
const threshold = 10;
let dragStartX, dragStartY;

function determineDragAxis(e) {
  if (dragAxis) return dragAxis;
  
  const dx = Math.abs(e.clientX - dragStartX);
  const dy = Math.abs(e.clientY - dragStartY);
  
  if (dx > threshold || dy > threshold) {
    dragAxis = dx > dy ? 'horizontal' : 'vertical';
  }
  return dragAxis;
}

function applyAxisConstraint(x, y) {
  const axis = determineDragAxis(e);
  if (axis === 'horizontal') {
    return { x, y: dragStartY };
  } else if (axis === 'vertical') {
    return { x: dragStartX, y };
  }
  return { x, y };
}
```

#### Snap-to-Grid

```javascript
function snapToGrid(x, y, gridSize) {
  return {
    x: Math.round(x / gridSize) * gridSize,
    y: Math.round(y / gridSize) * gridSize
  };
}
```

**Grid with offset:**

```javascript
function snapToGridWithOffset(x, y, gridSize, offsetX, offsetY) {
  return {
    x: Math.round((x - offsetX) / gridSize) * gridSize + offsetX,
    y: Math.round((y - offsetY) / gridSize) * gridSize + offsetY
  };
}
```

#### Boundary Constraints

**Constrain to container:**

```javascript
function constrainToContainer(element, container) {
  const elemRect = element.getBoundingClientRect();
  const contRect = container.getBoundingClientRect();
  
  let x = parseFloat(element.style.left);
  let y = parseFloat(element.style.top);
  
  x = Math.max(0, Math.min(x, contRect.width - elemRect.width));
  y = Math.max(0, Math.min(y, contRect.height - elemRect.height));
  
  return { x, y };
}
```

**Magnetic snap to edges:**

```javascript
function magneticSnap(pos, containerSize, elementSize, snapDistance = 10) {
  if (pos < snapDistance) return 0;
  if (pos > containerSize - elementSize - snapDistance) {
    return containerSize - elementSize;
  }
  return pos;
}
```

### Sortable Lists

#### Insertion Point Detection

**Between-items approach:**

```javascript
function getInsertionIndex(y, items) {
  for (let i = 0; i < items.length; i++) {
    const rect = items[i].getBoundingClientRect();
    const midpoint = rect.top + rect.height / 2;
    
    if (y < midpoint) return i;
  }
  return items.length;
}
```

**Visual placeholder:**

```javascript
let placeholder = null;

function updatePlaceholder(insertionIndex, container) {
  if (!placeholder) {
    placeholder = document.createElement('div');
    placeholder.className = 'drop-placeholder';
  }
  
  const items = Array.from(container.children).filter(el => 
    el !== placeholder && !el.classList.contains('dragging')
  );
  
  if (insertionIndex >= items.length) {
    container.appendChild(placeholder);
  } else {
    container.insertBefore(placeholder, items[insertionIndex]);
  }
}
```

#### DOM Reordering Strategies

**Immediate DOM update:**

```javascript
function reorderImmediate(draggedElement, targetIndex, container) {
  const items = Array.from(container.children);
  if (targetIndex >= items.length) {
    container.appendChild(draggedElement);
  } else {
    container.insertBefore(draggedElement, items[targetIndex]);
  }
}
```

Causes layout thrashing on every move. Use with `requestAnimationFrame` batching.

**Deferred update (animation-friendly):**

```javascript
let pendingOrder = null;

function handleMove(e) {
  // Update visual position with transforms
  updateDraggedElementPosition(e);
  
  // Calculate and store target order
  const targetIndex = getInsertionIndex(e.clientY, items);
  pendingOrder = { draggedElement, targetIndex };
  
  // Update placeholder only
  updatePlaceholder(targetIndex);
}

function handleDrop() {
  if (pendingOrder) {
    // Apply actual DOM reordering once
    reorderImmediate(pendingOrder.draggedElement, pendingOrder.targetIndex);
  }
}
```

#### Animated Reordering

**CSS transitions on siblings:**

```javascript
function enableTransitions(items) {
  items.forEach(item => {
    item.style.transition = 'transform 200ms ease-out';
  });
}

function shiftItemsForInsertion(items, insertionIndex, draggedHeight) {
  items.forEach((item, i) => {
    if (i >= insertionIndex) {
      item.style.transform = `translateY(${draggedHeight}px)`;
    } else {
      item.style.transform = 'translateY(0)';
    }
  });
}
```

**FLIP technique (First, Last, Invert, Play):**

```javascript
function animateReorder(container, callback) {
  // First: Record initial positions
  const items = Array.from(container.children);
  const first = items.map(item => item.getBoundingClientRect());
  
  // Mutate DOM
  callback();
  
  // Last: Record final positions
  const last = items.map(item => item.getBoundingClientRect());
  
  // Invert: Apply negative transform to put elements at old position
  items.forEach((item, i) => {
    const dx = first[i].left - last[i].left;
    const dy = first[i].top - last[i].top;
    
    item.style.transition = 'none';
    item.style.transform = `translate(${dx}px, ${dy}px)`;
  });
  
  // Force reflow
  container.offsetHeight;
  
  // Play: Transition to new position
  items.forEach(item => {
    item.style.transition = 'transform 200ms ease-out';
    item.style.transform = 'translate(0, 0)';
  });
}
```

FLIP prevents layout-triggered reflows during animation, achieving 60fps reordering.

### Performance Optimization

#### Throttling and Debouncing

**`requestAnimationFrame` throttle:**

```javascript
let rafId = null;
let lastPosition = null;

function handleMove(e) {
  lastPosition = { x: e.clientX, y: e.clientY };
  
  if (!rafId) {
    rafId = requestAnimationFrame(() => {
      updateDragPosition(lastPosition);
      rafId = null;
    });
  }
}
```

Limits updates to display refresh rate (~60fps), preventing wasted computation.

**Time-based throttle for expensive operations:**

```javascript
const throttle = (fn, delay) => {
  let lastCall = 0;
  return (...args) => {
    const now = Date.now();
    if (now - lastCall >= delay) {
      lastCall = now;
      fn(...args);
    }
  };
};

const checkDropZones = throttle((x, y) => {
  // Expensive collision detection
}, 50); // Max 20 checks per second
```

#### Layer Promotion and Compositing

**Force GPU compositing:**

```css
.dragging {
  will-change: transform;
  /* Or */
  transform: translateZ(0);
}
```

Promotes element to own compositor layer, preventing main thread repaints.

**Minimize paint areas:**

```javascript
// Set dragged element to position:fixed during drag
function startDrag(element) {
  const rect = element.getBoundingClientRect();
  element.style.position = 'fixed';
  element.style.left = `${rect.left}px`;
  element.style.top = `${rect.top}px`;
  element.style.width = `${rect.width}px`;
  element.style.margin = '0'; // Prevent layout shifts
}
```

Fixed positioning removes element from document flow, preventing ancestor repaints.

#### Virtual Scrolling Integration

Drag operations in virtualized lists require special handling since only visible items exist in DOM.

**Tracking scroll-relative position:**

```javascript
class VirtualDragHandler {
  constructor(virtualList) {
    this.list = virtualList;
    this.draggedIndex = null;
    this.scrollOffset = 0;
  }
  
  handleDragStart(index) {
    this.draggedIndex = index;
    this.scrollOffset = this.list.scrollTop;
  }
  
  getInsertionIndex(clientY) {
    const scrolledY = clientY + this.list.scrollTop - this.scrollOffset;
    const itemHeight = this.list.itemHeight;
    return Math.floor(scrolledY / itemHeight);
  }
  
  handleDrop() {
    const newIndex = this.getInsertionIndex(lastMouseY);
    this.list.moveItem(this.draggedIndex, newIndex);
  }
}
```

[Inference]: Most virtual list libraries provide specific drag integration; custom implementation needs to account for item recycling and viewport changes during drag.

#### Memory Management

**Cleanup event listeners:**

```javascript
class DragManager {
  constructor() {
    this.boundHandleMove = this.handleMove.bind(this);
    this.boundHandleUp = this.handleUp.bind(this);
  }
  
  startDrag() {
    document.addEventListener('pointermove', this.boundHandleMove);
    document.addEventListener('pointerup', this.boundHandleUp);
  }
  
  endDrag() {
    document.removeEventListener('pointermove', this.boundHandleMove);
    document.removeEventListener('pointerup', this.boundHandleUp);
    // Clear references
    this.draggedElement = null;
    this.lastPosition = null;
  }
}
```

**WeakMap for element data:**

```javascript
const dragData = new WeakMap();

function storeDragData(element, data) {
  dragData.set(element, data);
  // Automatically cleaned up when element is garbage collected
}
```

### Accessibility

#### Keyboard Navigation

Drag interfaces must be keyboard-accessible:

```javascript
element.addEventListener('keydown', (e) => {
  if (e.key === ' ' || e.key === 'Enter') {
    toggleDragMode(element);
  }
  
  if (inDragMode) {
    switch(e.key) {
      case 'ArrowUp':
        moveElement(element, 0, -gridSize);
        break;
      case 'ArrowDown':
        moveElement(element, 0, gridSize);
        break;
      case 'ArrowLeft':
        moveElement(element, -gridSize, 0);
        break;
      case 'ArrowRight':
        moveElement(element, gridSize, 0);
        break;
      case 'Escape':
        cancelDrag();
        break;
    }
    e.preventDefault();
  }
});
```

#### ARIA Attributes

**Draggable items:**

```javascript
element.setAttribute('role', 'button');
element.setAttribute('aria-pressed', 'false');
element.setAttribute('aria-describedby', 'drag-instructions');
element.setAttribute('tabindex', '0');
```

**Drop zones:**

```javascript
dropZone.setAttribute('role', 'region');
dropZone.setAttribute('aria-label', 'Drop zone for items');
dropZone.setAttribute('aria-dropeffect', 'move');
```

**Live region announcements:**

```javascript
const announcer = document.createElement('div');
announcer.setAttribute('role', 'status');
announcer.setAttribute('aria-live', 'assertive');
announcer.setAttribute('aria-atomic', 'true');
announcer.className = 'sr-only';
document.body.appendChild(announcer);

function announce(message) {
  announcer.textContent = message;
  setTimeout(() => announcer.textContent = '', 1000);
}

// Usage
announce('Item moved to position 3 of 10');
```

#### Focus Management

```javascript
function handleDrop(draggedElement, targetIndex) {
  // Perform reordering
  reorderElements(draggedElement, targetIndex);
  
  // Return focus to dragged element in new position
  draggedElement.focus();
  
  // Announce change
  announce(`Moved to position ${targetIndex + 1} of ${totalItems}`);
}
```

### Multi-Selection Drag

#### Selection Management

```javascript
const selected = new Set();

function handleClick(e, element) {
  if (e.ctrlKey || e.metaKey) {
    toggleSelection(element);
  } else if (e.shiftKey && lastSelected) {
    selectRange(lastSelected, element);
  } else {
    clearSelection();
    selectElement(element);
  }
  lastSelected = element;
}

function selectElement(element) {
  selected.add(element);
  element.classList.add('selected');
  element.setAttribute('aria-selected', 'true');
}

function selectRange(start, end) {
  const items = Array.from(container.children);
  const startIdx = items.indexOf(start);
  const endIdx = items.indexOf(end);
  
  const [first, last] = startIdx < endIdx ? 
    [startIdx, endIdx] : [endIdx, startIdx];
  
  for (let i = first; i <= last; i++) {
    selectElement(items[i]);
  }
}
```

#### Ghost Element for Multiple Items

```javascript
function createMultiDragGhost(selectedElements) {
  const ghost = document.createElement('div');
  ghost.className = 'multi-drag-ghost';
  
  // Show count
  const badge = document.createElement('span');
  badge.className = 'count-badge';
  badge.textContent = selectedElements.size;
  ghost.appendChild(badge);
  
  // Show preview of first item
  const preview = selectedElements.values().next().value.cloneNode(true);
  preview.style.opacity = '0.8';
  ghost.appendChild(preview);
  
  document.body.appendChild(ghost);
  return ghost;
}
```

#### Batch Operations

```javascript
function handleMultiDrop(selectedElements, targetIndex) {
  // Get original indices
  const items = Array.from(container.children);
  const indices = Array.from(selectedElements).map(el => items.indexOf(el));
  indices.sort((a, b) => a - b);
  
  // Adjust target index for removed elements before it
  const adjustedTarget = targetIndex - indices.filter(i => i < targetIndex).length;
  
  // Remove all selected elements
  const elements = indices.map(i => items[i]);
  elements.forEach(el => el.remove());
  
  // Insert at target
  const referenceNode = container.children[adjustedTarget];
  elements.forEach(el => {
    if (referenceNode) {
      container.insertBefore(el, referenceNode);
    } else {
      container.appendChild(el);
    }
  });
}
```

### Touch-Specific Patterns

#### Long-Press to Initiate

```javascript
let longPressTimer = null;
const longPressDuration = 500;

element.addEventListener('touchstart', (e) => {
  longPressTimer = setTimeout(() => {
    startDrag(e);
    navigator.vibrate && navigator.vibrate(50); // Haptic feedback
  }, longPressDuration);
});

element.addEventListener('touchmove', () => {
  clearTimeout(longPressTimer);
});

element.addEventListener('touchend', () => {
  clearTimeout(longPressTimer);
});
```

#### Preventing Scroll During Drag

```javascript
function preventScrollDuringDrag(element) {
  let isDragging = false;
  
  element.addEventListener('touchstart', (e) => {
    isDragging = true;
  }, { passive: false });
  
  element.addEventListener('touchmove', (e) => {
    if (isDragging) {
      e.preventDefault(); // Prevents scroll
    }
  }, { passive: false });
  
  element.addEventListener('touchend', () => {
    isDragging = false;
  });
}
```

Note: `{ passive: false }` is required to call `preventDefault()` on touch events.

#### Touch-Specific Visual Feedback

```javascript
element.addEventListener('touchstart', () => {
  element.classList.add('touch-active');
  // Slightly scale up
  element.style.transform = 'scale(1.05)';
});

element.addEventListener('touchend', () => {
  element.classList.remove('touch-active');
  element.style.transform = '';
});
```

### Canvas-Based Drag Systems

For high-performance dragging with many elements (>1000), Canvas rendering outperforms DOM.

#### Hit Detection

```javascript
class CanvasDragManager {
  constructor(canvas) {
    this.canvas = canvas;
    this.ctx = canvas.getContext('2d');
    this.elements = [];
  }
  
  findElementAt(x, y) {
    // Iterate in reverse (top to bottom)
    for (let i = this.elements.length - 1; i >= 0; i--) {
      const el = this.elements[i];
      if (x >= el.x && x <= el.x + el.width &&
          y >= el.y && y <= el.y + el.height) {
        return el;
      }
    }
    return null;
  }
  
  handleMouseDown(e) {
    const rect = this.canvas.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    
    this.draggedElement = this.findElementAt(x, y);
    if (this.draggedElement) {
      this.offsetX = x - this.draggedElement.x;
      this.offsetY = y - this.draggedElement.y;
    }
  }
  
  handleMouseMove(e) {
    if (!this.draggedElement) return;
    
    const rect = this.canvas.getBoundingClientRect();
    this.draggedElement.x = e.clientX - rect.left - this.offsetX;
    this.draggedElement.y = e.clientY - rect.top - this.offsetY;
    
    this.render();
  }
  
  render() {
    this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
    this.elements.forEach(el => this.drawElement(el));
  }
}
```

#### Pixel-Perfect Hit Detection

For complex shapes, use off-screen canvas color-coding:

```javascript
class PixelHitDetection {
  constructor(mainCanvas) {
    this.mainCanvas = mainCanvas;
    this.hitCanvas = document.createElement('canvas');
    this.hitCanvas.width = mainCanvas.width;
    this.hitCanvas.height = mainCanvas.height;
    this.hitCtx = this.hitCanvas.getContext('2d');
    this.colorToElement = new Map();
  }
  
  register(element)
```

---

