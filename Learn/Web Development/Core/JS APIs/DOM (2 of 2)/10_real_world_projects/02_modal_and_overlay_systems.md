## Modal and Overlay Systems


### DOM Structure Patterns

#### Portal-based Architecture

Modals typically render outside the normal component hierarchy to avoid z-index conflicts and positioning constraints. The portal pattern involves creating a dedicated container at the document body level:

```javascript
// Create portal container
const portalRoot = document.getElementById('modal-root') || (() => {
  const div = document.createElement('div');
  div.id = 'modal-root';
  document.body.appendChild(div);
  return div;
})();
```

The modal content is then injected into this container while maintaining logical parent-child relationships in the component tree.

#### Layered Container Strategy

Complex applications often maintain multiple overlay layers:

- **Base layer**: Standard modals and dialogs
- **Elevated layer**: Priority modals (confirmations, alerts)
- **Toast layer**: Non-blocking notifications
- **Tooltip layer**: Contextual helpers

Each layer manages its own z-index range, preventing stacking conflicts.

### Focus Management

#### Focus Trapping

When a modal opens, keyboard focus must be constrained within the modal boundary. Implementation involves:

```javascript
function trapFocus(element) {
  const focusableElements = element.querySelectorAll(
    'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
  );
  const firstElement = focusableElements[0];
  const lastElement = focusableElements[focusableElements.length - 1];

  element.addEventListener('keydown', (e) => {
    if (e.key !== 'Tab') return;
    
    if (e.shiftKey) {
      if (document.activeElement === firstElement) {
        lastElement.focus();
        e.preventDefault();
      }
    } else {
      if (document.activeElement === lastElement) {
        firstElement.focus();
        e.preventDefault();
      }
    }
  });
}
```

#### Initial Focus Assignment

The modal should focus the first interactive element or a designated primary action on open. For destructive actions, focus the cancel button to prevent accidental confirmation.

#### Return Focus

Store the previously focused element before opening the modal:

```javascript
const previouslyFocused = document.activeElement;
// ... open modal
// On close:
previouslyFocused?.focus();
```

### Scroll Behavior Control

#### Body Scroll Lock

Prevent background scrolling when modals are active:

```javascript
function lockScroll() {
  const scrollbarWidth = window.innerWidth - document.documentElement.clientWidth;
  document.body.style.overflow = 'hidden';
  document.body.style.paddingRight = `${scrollbarWidth}px`;
}

function unlockScroll() {
  document.body.style.overflow = '';
  document.body.style.paddingRight = '';
}
```

The padding compensation prevents layout shift when the scrollbar disappears.

#### Nested Modal Considerations

Track active modal count to handle multiple overlays:

```javascript
let modalCount = 0;

function openModal() {
  if (modalCount === 0) lockScroll();
  modalCount++;
}

function closeModal() {
  modalCount--;
  if (modalCount === 0) unlockScroll();
}
```

#### iOS Touch Handling

Mobile Safari requires additional measures:

```javascript
let scrollPosition = 0;

function lockScrollMobile() {
  scrollPosition = window.pageYOffset;
  document.body.style.position = 'fixed';
  document.body.style.top = `-${scrollPosition}px`;
  document.body.style.width = '100%';
}

function unlockScrollMobile() {
  document.body.style.position = '';
  document.body.style.top = '';
  window.scrollTo(0, scrollPosition);
}
```

### Event Handling

#### Backdrop Click Detection

Distinguish between backdrop clicks and modal content clicks:

```javascript
overlay.addEventListener('click', (e) => {
  if (e.target === overlay) {
    closeModal();
  }
});
```

Alternative approach using mousedown/mouseup coordination:

```javascript
let mouseDownTarget = null;

overlay.addEventListener('mousedown', (e) => {
  mouseDownTarget = e.target;
});

overlay.addEventListener('click', (e) => {
  if (e.target === overlay && mouseDownTarget === overlay) {
    closeModal();
  }
  mouseDownTarget = null;
});
```

This prevents false closes when dragging starts inside the modal and ends on the backdrop.

#### Escape Key Handling

Close modals with the Escape key:

```javascript
function handleEscape(e) {
  if (e.key === 'Escape') {
    closeTopmostModal();
  }
}

document.addEventListener('keydown', handleEscape);
```

For nested modals, only the topmost should respond to Escape.

#### Event Propagation Control

Prevent modal content events from bubbling to backdrop handlers:

```javascript
modalContent.addEventListener('click', (e) => {
  e.stopPropagation();
});
```

### Animation and Transitions

#### CSS-based Transitions

Apply classes for enter/exit animations:

```javascript
function openModal(modal) {
  modal.classList.add('modal-entering');
  
  requestAnimationFrame(() => {
    modal.classList.add('modal-active');
    modal.classList.remove('modal-entering');
  });
}

function closeModal(modal) {
  modal.classList.add('modal-exiting');
  
  modal.addEventListener('transitionend', () => {
    modal.remove();
  }, { once: true });
}
```

Corresponding CSS:

```css
.modal-entering {
  opacity: 0;
  transform: scale(0.95);
}

.modal-active {
  opacity: 1;
  transform: scale(1);
  transition: opacity 200ms, transform 200ms;
}

.modal-exiting {
  opacity: 0;
  transform: scale(0.95);
  transition: opacity 150ms, transform 150ms;
}
```

#### JavaScript Animation Control

For complex animations, use the Web Animations API:

```javascript
modal.animate([
  { opacity: 0, transform: 'translateY(-20px)' },
  { opacity: 1, transform: 'translateY(0)' }
], {
  duration: 250,
  easing: 'cubic-bezier(0.4, 0, 0.2, 1)',
  fill: 'forwards'
});
```

#### Stagger Animations

For modals with multiple elements, coordinate animations:

```javascript
const elements = modal.querySelectorAll('.animate-item');
elements.forEach((el, index) => {
  el.style.animationDelay = `${index * 50}ms`;
});
```

### State Management

#### Single Modal Manager

Centralized control for modal lifecycle:

```javascript
class ModalManager {
  constructor() {
    this.stack = [];
    this.container = document.getElementById('modal-root');
  }

  open(config) {
    const modal = this.createModal(config);
    this.stack.push(modal);
    this.container.appendChild(modal.element);
    modal.open();
    return modal;
  }

  close(modal) {
    const index = this.stack.indexOf(modal);
    if (index > -1) {
      this.stack.splice(index, 1);
      modal.close();
    }
  }

  closeAll() {
    while (this.stack.length > 0) {
      this.close(this.stack[this.stack.length - 1]);
    }
  }

  getTopModal() {
    return this.stack[this.stack.length - 1];
  }
}
```

#### Multi-Modal Coordination

Handle z-index stacking for nested modals:

```javascript
open(config) {
  const baseZIndex = 1000;
  const zIndex = baseZIndex + (this.stack.length * 10);
  
  const modal = this.createModal({
    ...config,
    zIndex
  });
  
  this.stack.push(modal);
}
```

#### State Persistence

Track modal state for restoration:

```javascript
class Modal {
  constructor(id, config) {
    this.id = id;
    this.config = config;
    this.data = {};
  }

  saveState() {
    sessionStorage.setItem(
      `modal-${this.id}`,
      JSON.stringify(this.data)
    );
  }

  restoreState() {
    const saved = sessionStorage.getItem(`modal-${this.id}`);
    if (saved) {
      this.data = JSON.parse(saved);
    }
  }
}
```

### Accessibility Implementation

#### ARIA Attributes

Essential attributes for screen reader support:

```html
<div role="dialog" 
     aria-modal="true"
     aria-labelledby="modal-title"
     aria-describedby="modal-description">
  <h2 id="modal-title">Modal Title</h2>
  <div id="modal-description">Modal content description</div>
</div>
```

#### Alert Dialogs

For modals requiring immediate attention:

```html
<div role="alertdialog"
     aria-modal="true"
     aria-labelledby="alert-title"
     aria-describedby="alert-description">
  <!-- Content -->
</div>
```

#### Live Region Announcements

Notify screen readers when modals open:

```javascript
function announceModal(title) {
  const announcer = document.createElement('div');
  announcer.setAttribute('role', 'status');
  announcer.setAttribute('aria-live', 'polite');
  announcer.className = 'sr-only';
  announcer.textContent = `Dialog opened: ${title}`;
  document.body.appendChild(announcer);
  
  setTimeout(() => announcer.remove(), 1000);
}
```

#### Keyboard Navigation

Ensure all interactive elements are keyboard accessible:

```javascript
modal.addEventListener('keydown', (e) => {
  // Close on Escape
  if (e.key === 'Escape') {
    closeModal();
  }
  
  // Activate on Enter (for non-button elements)
  if (e.key === 'Enter' && e.target.hasAttribute('role')) {
    e.target.click();
  }
});
```

### Performance Optimization

#### Lazy Rendering

Create modal DOM only when needed:

```javascript
class LazyModal {
  constructor(contentFactory) {
    this.contentFactory = contentFactory;
    this.element = null;
  }

  open() {
    if (!this.element) {
      this.element = this.contentFactory();
      document.body.appendChild(this.element);
    }
    this.element.classList.add('active');
  }

  destroy() {
    this.element?.remove();
    this.element = null;
  }
}
```

#### Virtual Scrolling for Large Lists

For modals containing extensive lists:

```javascript
class VirtualList {
  constructor(container, items, rowHeight) {
    this.container = container;
    this.items = items;
    this.rowHeight = rowHeight;
    this.visibleStart = 0;
    this.visibleEnd = 0;
    
    this.container.addEventListener('scroll', () => this.render());
    this.render();
  }

  render() {
    const scrollTop = this.container.scrollTop;
    const viewportHeight = this.container.clientHeight;
    
    this.visibleStart = Math.floor(scrollTop / this.rowHeight);
    this.visibleEnd = Math.ceil((scrollTop + viewportHeight) / this.rowHeight);
    
    // Render only visible items
    const fragment = document.createDocumentFragment();
    for (let i = this.visibleStart; i < this.visibleEnd; i++) {
      if (this.items[i]) {
        const row = this.createRow(this.items[i], i);
        fragment.appendChild(row);
      }
    }
    
    this.container.innerHTML = '';
    this.container.appendChild(fragment);
  }
}
```

#### Intersection Observer for Backdrop

Optimize backdrop rendering for multiple modals:

```javascript
const backdropObserver = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      entry.target.classList.add('visible');
    } else {
      entry.target.classList.remove('visible');
    }
  });
});
```

#### RequestAnimationFrame Batching

Batch DOM updates for smooth animations:

```javascript
class AnimationBatcher {
  constructor() {
    this.queue = [];
    this.scheduled = false;
  }

  add(callback) {
    this.queue.push(callback);
    if (!this.scheduled) {
      this.scheduled = true;
      requestAnimationFrame(() => this.flush());
    }
  }

  flush() {
    this.queue.forEach(cb => cb());
    this.queue = [];
    this.scheduled = false;
  }
}
```

### Memory Management

#### Cleanup Patterns

Properly dispose of modals to prevent memory leaks:

```javascript
class Modal {
  constructor() {
    this.listeners = [];
  }

  addEventListener(element, event, handler) {
    element.addEventListener(event, handler);
    this.listeners.push({ element, event, handler });
  }

  destroy() {
    // Remove all event listeners
    this.listeners.forEach(({ element, event, handler }) => {
      element.removeEventListener(event, handler);
    });
    this.listeners = [];
    
    // Remove DOM elements
    this.element?.remove();
    this.element = null;
  }
}
```

#### WeakMap for Modal Data

Store modal-associated data without preventing garbage collection:

```javascript
const modalData = new WeakMap();

function attachData(modal, data) {
  modalData.set(modal, data);
}

function getData(modal) {
  return modalData.get(modal);
}
```

#### Circular Reference Prevention

Avoid memory leaks from circular references:

```javascript
class ModalController {
  constructor(modal) {
    // Store weak reference
    this.modalRef = new WeakRef(modal);
  }

  getModal() {
    return this.modalRef.deref();
  }
}
```

### Advanced Positioning

#### Dynamic Positioning

Calculate optimal position based on viewport:

```javascript
function positionModal(modal, trigger) {
  const triggerRect = trigger.getBoundingClientRect();
  const modalRect = modal.getBoundingClientRect();
  const viewport = {
    width: window.innerWidth,
    height: window.innerHeight
  };

  let top = triggerRect.bottom + 8;
  let left = triggerRect.left;

  // Flip if overflows bottom
  if (top + modalRect.height > viewport.height) {
    top = triggerRect.top - modalRect.height - 8;
  }

  // Adjust if overflows right
  if (left + modalRect.width > viewport.width) {
    left = viewport.width - modalRect.width - 16;
  }

  modal.style.top = `${top}px`;
  modal.style.left = `${left}px`;
}
```

#### Collision Detection

Prevent overlapping with other UI elements:

```javascript
function hasCollision(rect1, rect2) {
  return !(
    rect1.right < rect2.left ||
    rect1.left > rect2.right ||
    rect1.bottom < rect2.top ||
    rect1.top > rect2.bottom
  );
}

function findSafePosition(modal, obstacles) {
  const modalRect = modal.getBoundingClientRect();
  const positions = generateCandidatePositions(modalRect);
  
  for (const pos of positions) {
    const testRect = {
      left: pos.x,
      top: pos.y,
      right: pos.x + modalRect.width,
      bottom: pos.y + modalRect.height
    };
    
    if (!obstacles.some(obs => hasCollision(testRect, obs))) {
      return pos;
    }
  }
  
  return positions[0]; // Fallback to default
}
```

#### Viewport Constraints

Keep modals within viewport boundaries:

```javascript
function constrainToViewport(modal) {
  const rect = modal.getBoundingClientRect();
  const padding = 16;
  
  let { top, left } = rect;
  
  if (left < padding) left = padding;
  if (top < padding) top = padding;
  if (rect.right > window.innerWidth - padding) {
    left = window.innerWidth - rect.width - padding;
  }
  if (rect.bottom > window.innerHeight - padding) {
    top = window.innerHeight - rect.height - padding;
  }
  
  modal.style.transform = `translate(${left}px, ${top}px)`;
}
```

### Responsive Behavior

#### Breakpoint-based Rendering

Adjust modal presentation for different screen sizes:

```javascript
class ResponsiveModal {
  constructor(config) {
    this.config = config;
    this.mediaQueries = {
      mobile: window.matchMedia('(max-width: 768px)'),
      tablet: window.matchMedia('(min-width: 769px) and (max-width: 1024px)'),
      desktop: window.matchMedia('(min-width: 1025px)')
    };
    
    this.setupMediaListeners();
  }

  setupMediaListeners() {
    Object.values(this.mediaQueries).forEach(mq => {
      mq.addEventListener('change', () => this.updateLayout());
    });
  }

  updateLayout() {
    if (this.mediaQueries.mobile.matches) {
      this.applyMobileLayout();
    } else if (this.mediaQueries.tablet.matches) {
      this.applyTabletLayout();
    } else {
      this.applyDesktopLayout();
    }
  }

  applyMobileLayout() {
    this.element.classList.add('modal-fullscreen');
    this.element.classList.remove('modal-centered', 'modal-sidebar');
  }
}
```

#### Touch Gesture Support

Enable swipe-to-dismiss on mobile:

```javascript
class SwipeableModal {
  constructor(modal) {
    this.modal = modal;
    this.startY = 0;
    this.currentY = 0;
    this.isDragging = false;
    
    this.setupTouchHandlers();
  }

  setupTouchHandlers() {
    this.modal.addEventListener('touchstart', (e) => {
      this.startY = e.touches[0].clientY;
      this.isDragging = true;
    });

    this.modal.addEventListener('touchmove', (e) => {
      if (!this.isDragging) return;
      
      this.currentY = e.touches[0].clientY;
      const deltaY = this.currentY - this.startY;
      
      if (deltaY > 0) {
        this.modal.style.transform = `translateY(${deltaY}px)`;
      }
    });

    this.modal.addEventListener('touchend', () => {
      const deltaY = this.currentY - this.startY;
      
      if (deltaY > 100) {
        this.close();
      } else {
        this.modal.style.transform = '';
      }
      
      this.isDragging = false;
    });
  }
}
```

#### Orientation Change Handling

Respond to device orientation changes:

```javascript
window.addEventListener('orientationchange', () => {
  const modals = document.querySelectorAll('.modal.active');
  modals.forEach(modal => {
    recalculatePosition(modal);
    adjustContentHeight(modal);
  });
});
```

### Error Handling

#### Graceful Degradation

Handle failures without breaking the UI:

```javascript
class RobustModal {
  async open() {
    try {
      await this.loadContent();
      this.render();
      this.attachEvents();
    } catch (error) {
      console.error('Modal error:', error);
      this.showErrorState();
    }
  }

  showErrorState() {
    this.element.innerHTML = `
      <div class="modal-error">
        <p>Unable to load content</p>
        <button onclick="this.closest('.modal').remove()">Close</button>
      </div>
    `;
  }
}
```

#### Timeout Protection

Prevent indefinite loading states:

```javascript
async function openModalWithTimeout(modalFactory, timeout = 5000) {
  const timeoutPromise = new Promise((_, reject) => {
    setTimeout(() => reject(new Error('Modal timeout')), timeout);
  });

  try {
    const modal = await Promise.race([
      modalFactory(),
      timeoutPromise
    ]);
    return modal;
  } catch (error) {
    showErrorModal('Content failed to load');
  }
}
```

#### State Recovery

Restore application state if modal crashes:

```javascript
class SafeModalManager {
  constructor() {
    this.stateBackup = null;
  }

  open(modal) {
    this.stateBackup = this.captureState();
    
    try {
      modal.open();
    } catch (error) {
      this.restoreState(this.stateBackup);
      throw error;
    }
  }

  captureState() {
    return {
      scrollPosition: window.scrollY,
      focusedElement: document.activeElement,
      bodyOverflow: document.body.style.overflow
    };
  }

  restoreState(state) {
    window.scrollTo(0, state.scrollPosition);
    state.focusedElement?.focus();
    document.body.style.overflow = state.bodyOverflow;
  }
}
```

---

