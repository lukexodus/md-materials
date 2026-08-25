## Tooltip System


### Core Architecture

#### Basic Tooltip Structure

A tooltip system requires positioning logic, visibility management, and DOM manipulation.

```javascript
class Tooltip {
  constructor(options = {}) {
    this.options = {
      placement: 'top',
      offset: 8,
      delay: 200,
      hideDelay: 0,
      arrow: true,
      trigger: 'hover',
      interactive: false,
      maxWidth: 300,
      className: '',
      animation: 'fade',
      ...options
    };
    
    this.tooltip = null;
    this.arrow = null;
    this.trigger = null;
    this.showTimeout = null;
    this.hideTimeout = null;
    this.isVisible = false;
    this.isDestroyed = false;
  }
  
  create(triggerElement, content) {
    this.trigger = triggerElement;
    
    // Create tooltip element
    this.tooltip = document.createElement('div');
    this.tooltip.className = `tooltip ${this.options.className}`;
    this.tooltip.setAttribute('role', 'tooltip');
    this.tooltip.style.position = 'absolute';
    this.tooltip.style.maxWidth = `${this.options.maxWidth}px`;
    
    // Set content
    if (typeof content === 'string') {
      this.tooltip.textContent = content;
    } else if (content instanceof HTMLElement) {
      this.tooltip.appendChild(content);
    }
    
    // Create arrow
    if (this.options.arrow) {
      this.arrow = document.createElement('div');
      this.arrow.className = 'tooltip-arrow';
      this.tooltip.appendChild(this.arrow);
    }
    
    // Attach event listeners
    this.attachListeners();
    
    // Generate unique IDs for accessibility
    const tooltipId = `tooltip-${Math.random().toString(36).substr(2, 9)}`;
    this.tooltip.id = tooltipId;
    this.trigger.setAttribute('aria-describedby', tooltipId);
    
    return this;
  }
  
  attachListeners() {
    const { trigger, interactive } = this.options;
    
    if (trigger === 'hover') {
      this.trigger.addEventListener('mouseenter', this.handleMouseEnter);
      this.trigger.addEventListener('mouseleave', this.handleMouseLeave);
      this.trigger.addEventListener('focus', this.handleFocus);
      this.trigger.addEventListener('blur', this.handleBlur);
      
      if (interactive) {
        this.tooltip.addEventListener('mouseenter', this.handleTooltipMouseEnter);
        this.tooltip.addEventListener('mouseleave', this.handleTooltipMouseLeave);
      }
    } else if (trigger === 'click') {
      this.trigger.addEventListener('click', this.handleClick);
    } else if (trigger === 'focus') {
      this.trigger.addEventListener('focus', this.handleFocus);
      this.trigger.addEventListener('blur', this.handleBlur);
    }
  }
  
  handleMouseEnter = () => {
    clearTimeout(this.hideTimeout);
    this.showTimeout = setTimeout(() => {
      this.show();
    }, this.options.delay);
  };
  
  handleMouseLeave = () => {
    clearTimeout(this.showTimeout);
    if (!this.options.interactive) {
      this.hideTimeout = setTimeout(() => {
        this.hide();
      }, this.options.hideDelay);
    }
  };
  
  handleTooltipMouseEnter = () => {
    clearTimeout(this.hideTimeout);
  };
  
  handleTooltipMouseLeave = () => {
    this.hideTimeout = setTimeout(() => {
      this.hide();
    }, this.options.hideDelay);
  };
  
  handleFocus = () => {
    this.show();
  };
  
  handleBlur = () => {
    this.hide();
  };
  
  handleClick = (e) => {
    e.stopPropagation();
    this.toggle();
  };
  
  show() {
    if (this.isVisible || this.isDestroyed) return;
    
    document.body.appendChild(this.tooltip);
    this.position();
    
    // Trigger reflow for animation
    this.tooltip.offsetHeight;
    
    this.tooltip.classList.add('tooltip-visible');
    this.isVisible = true;
    
    // Listen for scroll/resize
    window.addEventListener('scroll', this.handleScroll, true);
    window.addEventListener('resize', this.handleResize);
    
    this.trigger.dispatchEvent(new CustomEvent('tooltip:show'));
  }
  
  hide() {
    if (!this.isVisible) return;
    
    this.tooltip.classList.remove('tooltip-visible');
    
    const duration = parseFloat(getComputedStyle(this.tooltip).transitionDuration) * 1000;
    
    setTimeout(() => {
      if (this.tooltip?.parentNode) {
        this.tooltip.parentNode.removeChild(this.tooltip);
      }
      this.isVisible = false;
    }, duration || 0);
    
    window.removeEventListener('scroll', this.handleScroll, true);
    window.removeEventListener('resize', this.handleResize);
    
    this.trigger.dispatchEvent(new CustomEvent('tooltip:hide'));
  }
  
  toggle() {
    this.isVisible ? this.hide() : this.show();
  }
  
  handleScroll = () => {
    if (this.isVisible) {
      this.position();
    }
  };
  
  handleResize = () => {
    if (this.isVisible) {
      this.position();
    }
  };
  
  destroy() {
    this.hide();
    
    const { trigger } = this.options;
    
    this.trigger.removeEventListener('mouseenter', this.handleMouseEnter);
    this.trigger.removeEventListener('mouseleave', this.handleMouseLeave);
    this.trigger.removeEventListener('focus', this.handleFocus);
    this.trigger.removeEventListener('blur', this.handleBlur);
    this.trigger.removeEventListener('click', this.handleClick);
    
    if (this.tooltip) {
      this.tooltip.removeEventListener('mouseenter', this.handleTooltipMouseEnter);
      this.tooltip.removeEventListener('mouseleave', this.handleTooltipMouseLeave);
    }
    
    this.trigger.removeAttribute('aria-describedby');
    
    this.isDestroyed = true;
  }
  
  position() {
    const triggerRect = this.trigger.getBoundingClientRect();
    const tooltipRect = this.tooltip.getBoundingClientRect();
    const { placement, offset } = this.options;
    
    const positions = this.calculatePosition(triggerRect, tooltipRect, placement, offset);
    
    this.tooltip.style.left = `${positions.x}px`;
    this.tooltip.style.top = `${positions.y}px`;
    
    if (this.arrow) {
      this.positionArrow(positions.placement, triggerRect, tooltipRect);
    }
  }
  
  calculatePosition(triggerRect, tooltipRect, preferredPlacement, offset) {
    const viewport = {
      width: window.innerWidth,
      height: window.innerHeight
    };
    
    const positions = {
      top: {
        x: triggerRect.left + (triggerRect.width / 2) - (tooltipRect.width / 2),
        y: triggerRect.top - tooltipRect.height - offset
      },
      bottom: {
        x: triggerRect.left + (triggerRect.width / 2) - (tooltipRect.width / 2),
        y: triggerRect.bottom + offset
      },
      left: {
        x: triggerRect.left - tooltipRect.width - offset,
        y: triggerRect.top + (triggerRect.height / 2) - (tooltipRect.height / 2)
      },
      right: {
        x: triggerRect.right + offset,
        y: triggerRect.top + (triggerRect.height / 2) - (tooltipRect.height / 2)
      }
    };
    
    // Check if preferred placement fits
    let placement = preferredPlacement;
    let pos = positions[placement];
    
    // Flip if doesn't fit
    if (!this.fitsInViewport(pos, tooltipRect, viewport)) {
      const flips = {
        top: 'bottom',
        bottom: 'top',
        left: 'right',
        right: 'left'
      };
      
      placement = flips[placement];
      pos = positions[placement];
      
      // If still doesn't fit, try other placements
      if (!this.fitsInViewport(pos, tooltipRect, viewport)) {
        const placements = ['top', 'bottom', 'left', 'right'];
        for (const p of placements) {
          const testPos = positions[p];
          if (this.fitsInViewport(testPos, tooltipRect, viewport)) {
            placement = p;
            pos = testPos;
            break;
          }
        }
      }
    }
    
    // Adjust position to stay within viewport
    pos = this.adjustForViewport(pos, tooltipRect, viewport);
    
    return { ...pos, placement };
  }
  
  fitsInViewport(pos, rect, viewport) {
    return (
      pos.x >= 0 &&
      pos.y >= 0 &&
      pos.x + rect.width <= viewport.width &&
      pos.y + rect.height <= viewport.height
    );
  }
  
  adjustForViewport(pos, rect, viewport) {
    const adjusted = { ...pos };
    
    // Horizontal adjustment
    if (adjusted.x < 0) {
      adjusted.x = 8; // Minimum padding
    } else if (adjusted.x + rect.width > viewport.width) {
      adjusted.x = viewport.width - rect.width - 8;
    }
    
    // Vertical adjustment
    if (adjusted.y < 0) {
      adjusted.y = 8;
    } else if (adjusted.y + rect.height > viewport.height) {
      adjusted.y = viewport.height - rect.height - 8;
    }
    
    return adjusted;
  }
  
  positionArrow(placement, triggerRect, tooltipRect) {
    const arrowSize = 8;
    
    if (placement === 'top' || placement === 'bottom') {
      const triggerCenter = triggerRect.left + (triggerRect.width / 2);
      const tooltipLeft = parseFloat(this.tooltip.style.left);
      const arrowLeft = triggerCenter - tooltipLeft - arrowSize;
      
      this.arrow.style.left = `${arrowLeft}px`;
      this.arrow.style.top = placement === 'top' ? 'auto' : `-${arrowSize}px`;
      this.arrow.style.bottom = placement === 'top' ? `-${arrowSize}px` : 'auto';
    } else {
      const triggerCenter = triggerRect.top + (triggerRect.height / 2);
      const tooltipTop = parseFloat(this.tooltip.style.top);
      const arrowTop = triggerCenter - tooltipTop - arrowSize;
      
      this.arrow.style.top = `${arrowTop}px`;
      this.arrow.style.left = placement === 'left' ? 'auto' : `-${arrowSize}px`;
      this.arrow.style.right = placement === 'left' ? `-${arrowSize}px` : 'auto';
    }
  }
}
```

### Positioning Engine

#### Advanced Positioning with Collision Detection

```javascript
class PositionEngine {
  constructor() {
    this.placements = [
      'top', 'top-start', 'top-end',
      'bottom', 'bottom-start', 'bottom-end',
      'left', 'left-start', 'left-end',
      'right', 'right-start', 'right-end'
    ];
  }
  
  compute(reference, floating, options = {}) {
    const {
      placement = 'top',
      offset = 8,
      shift = true,
      flip = true,
      autoPlacement = false
    } = options;
    
    const refRect = reference.getBoundingClientRect();
    const floatRect = floating.getBoundingClientRect();
    const viewport = this.getViewport();
    
    let finalPlacement = placement;
    let position;
    
    if (autoPlacement) {
      finalPlacement = this.findBestPlacement(refRect, floatRect, viewport, offset);
    }
    
    position = this.getPosition(refRect, floatRect, finalPlacement, offset);
    
    if (flip) {
      const collision = this.detectCollision(position, floatRect, viewport);
      if (collision) {
        finalPlacement = this.getFlippedPlacement(finalPlacement);
        position = this.getPosition(refRect, floatRect, finalPlacement, offset);
      }
    }
    
    if (shift) {
      position = this.applyShift(position, floatRect, viewport);
    }
    
    return {
      x: position.x,
      y: position.y,
      placement: finalPlacement,
      arrow: this.getArrowPosition(refRect, floatRect, finalPlacement, position)
    };
  }
  
  getPosition(refRect, floatRect, placement, offset) {
    const [side, alignment] = placement.split('-');
    
    const basePositions = {
      top: {
        x: refRect.left + (refRect.width / 2) - (floatRect.width / 2),
        y: refRect.top - floatRect.height - offset
      },
      bottom: {
        x: refRect.left + (refRect.width / 2) - (floatRect.width / 2),
        y: refRect.bottom + offset
      },
      left: {
        x: refRect.left - floatRect.width - offset,
        y: refRect.top + (refRect.height / 2) - (floatRect.height / 2)
      },
      right: {
        x: refRect.right + offset,
        y: refRect.top + (refRect.height / 2) - (floatRect.height / 2)
      }
    };
    
    let pos = basePositions[side];
    
    // Apply alignment
    if (alignment === 'start') {
      if (side === 'top' || side === 'bottom') {
        pos.x = refRect.left;
      } else {
        pos.y = refRect.top;
      }
    } else if (alignment === 'end') {
      if (side === 'top' || side === 'bottom') {
        pos.x = refRect.right - floatRect.width;
      } else {
        pos.y = refRect.bottom - floatRect.height;
      }
    }
    
    return pos;
  }
  
  detectCollision(position, floatRect, viewport) {
    return (
      position.x < 0 ||
      position.y < 0 ||
      position.x + floatRect.width > viewport.width ||
      position.y + floatRect.height > viewport.height
    );
  }
  
  getFlippedPlacement(placement) {
    const flips = {
      'top': 'bottom',
      'top-start': 'bottom-start',
      'top-end': 'bottom-end',
      'bottom': 'top',
      'bottom-start': 'top-start',
      'bottom-end': 'top-end',
      'left': 'right',
      'left-start': 'right-start',
      'left-end': 'right-end',
      'right': 'left',
      'right-start': 'left-start',
      'right-end': 'left-end'
    };
    return flips[placement] || placement;
  }
  
  applyShift(position, floatRect, viewport, padding = 8) {
    const shifted = { ...position };
    
    if (shifted.x < padding) {
      shifted.x = padding;
    } else if (shifted.x + floatRect.width > viewport.width - padding) {
      shifted.x = viewport.width - floatRect.width - padding;
    }
    
    if (shifted.y < padding) {
      shifted.y = padding;
    } else if (shifted.y + floatRect.height > viewport.height - padding) {
      shifted.y = viewport.height - floatRect.height - padding;
    }
    
    return shifted;
  }
  
  findBestPlacement(refRect, floatRect, viewport, offset) {
    const availableSpace = {
      top: refRect.top - offset,
      bottom: viewport.height - refRect.bottom - offset,
      left: refRect.left - offset,
      right: viewport.width - refRect.right - offset
    };
    
    const requiredSpace = {
      top: floatRect.height,
      bottom: floatRect.height,
      left: floatRect.width,
      right: floatRect.width
    };
    
    // Find side with most space where tooltip fits
    let bestSide = 'top';
    let maxSpace = availableSpace.top;
    
    for (const side of ['bottom', 'left', 'right']) {
      if (availableSpace[side] >= requiredSpace[side] && 
          availableSpace[side] > maxSpace) {
        bestSide = side;
        maxSpace = availableSpace[side];
      }
    }
    
    // If no side fits, use side with most space
    if (maxSpace < requiredSpace[bestSide]) {
      maxSpace = -Infinity;
      for (const side of ['top', 'bottom', 'left', 'right']) {
        if (availableSpace[side] > maxSpace) {
          bestSide = side;
          maxSpace = availableSpace[side];
        }
      }
    }
    
    return bestSide;
  }
  
  getArrowPosition(refRect, floatRect, placement, position) {
    const [side] = placement.split('-');
    const arrowSize = 8;
    
    const arrow = { x: 0, y: 0 };
    
    if (side === 'top' || side === 'bottom') {
      const refCenter = refRect.left + (refRect.width / 2);
      arrow.x = refCenter - position.x - arrowSize;
      arrow.y = side === 'top' ? floatRect.height : -arrowSize;
    } else {
      const refCenter = refRect.top + (refRect.height / 2);
      arrow.y = refCenter - position.y - arrowSize;
      arrow.x = side === 'left' ? floatRect.width : -arrowSize;
    }
    
    return arrow;
  }
  
  getViewport() {
    return {
      width: window.innerWidth,
      height: window.innerHeight
    };
  }
}
```

### Virtual Positioning (Floating UI Pattern)

```javascript
class VirtualElement {
  constructor(x, y, width = 0, height = 0) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
  }
  
  getBoundingClientRect() {
    return {
      x: this.x,
      y: this.y,
      width: this.width,
      height: this.height,
      top: this.y,
      right: this.x + this.width,
      bottom: this.y + this.height,
      left: this.x
    };
  }
}

class ContextMenuTooltip {
  constructor() {
    this.tooltip = null;
    this.virtualElement = null;
  }
  
  showAtCursor(event, content) {
    // Create virtual element at cursor position
    this.virtualElement = new VirtualElement(
      event.clientX,
      event.clientY,
      1,
      1
    );
    
    this.show(this.virtualElement, content);
  }
  
  showAtSelection(content) {
    const selection = window.getSelection();
    if (!selection.rangeCount) return;
    
    const range = selection.getRangeAt(0);
    const rect = range.getBoundingClientRect();
    
    this.virtualElement = new VirtualElement(
      rect.x,
      rect.y,
      rect.width,
      rect.height
    );
    
    this.show(this.virtualElement, content);
  }
  
  show(reference, content) {
    if (!this.tooltip) {
      this.tooltip = document.createElement('div');
      this.tooltip.className = 'context-tooltip';
      document.body.appendChild(this.tooltip);
    }
    
    this.tooltip.textContent = content;
    
    const positionEngine = new PositionEngine();
    const position = positionEngine.compute(reference, this.tooltip, {
      placement: 'bottom',
      autoPlacement: true
    });
    
    this.tooltip.style.left = `${position.x}px`;
    this.tooltip.style.top = `${position.y}px`;
    this.tooltip.classList.add('visible');
  }
  
  hide() {
    if (this.tooltip) {
      this.tooltip.classList.remove('visible');
    }
  }
}
```

### Content Management

#### Dynamic Content Loading

```javascript
class AsyncTooltip extends Tooltip {
  constructor(options = {}) {
    super(options);
    this.contentCache = new Map();
    this.loadingTemplate = options.loadingTemplate || 'Loading...';
    this.errorTemplate = options.errorTemplate || 'Failed to load';
  }
  
  async show() {
    if (this.isVisible) return;
    
    const contentSource = this.trigger.dataset.tooltipContent;
    const cacheKey = this.trigger.dataset.tooltipCache;
    
    // Show loading state
    this.setContent(this.loadingTemplate);
    super.show();
    
    try {
      let content;
      
      if (cacheKey && this.contentCache.has(cacheKey)) {
        content = this.contentCache.get(cacheKey);
      } else {
        content = await this.loadContent(contentSource);
        
        if (cacheKey) {
          this.contentCache.set(cacheKey, content);
        }
      }
      
      this.setContent(content);
      this.position(); // Reposition after content change
      
    } catch (error) {
      this.setContent(this.errorTemplate);
      console.error('Tooltip content load failed:', error);
    }
  }
  
  async loadContent(source) {
    // If source is a URL
    if (source.startsWith('http') || source.startsWith('/')) {
      const response = await fetch(source);
      if (!response.ok) throw new Error('Network response failed');
      return await response.text();
    }
    
    // If source is a selector
    if (source.startsWith('#') || source.startsWith('.')) {
      const element = document.querySelector(source);
      return element ? element.innerHTML : '';
    }
    
    // If source is a function name
    if (typeof window[source] === 'function') {
      return await window[source](this.trigger);
    }
    
    return source;
  }
  
  setContent(content) {
    if (typeof content === 'string') {
      this.tooltip.innerHTML = content;
    } else if (content instanceof HTMLElement) {
      this.tooltip.innerHTML = '';
      this.tooltip.appendChild(content.cloneNode(true));
    }
  }
}
```

#### Rich Content Templates

```javascript
class RichTooltip extends Tooltip {
  constructor(options = {}) {
    super(options);
    this.templates = {
      default: (data) => `<div class="tooltip-content">${data.text}</div>`,
      card: (data) => `
        <div class="tooltip-card">
          ${data.image ? `<img src="${data.image}" alt="">` : ''}
          <div class="tooltip-card-body">
            ${data.title ? `<h4>${data.title}</h4>` : ''}
            ${data.description ? `<p>${data.description}</p>` : ''}
          </div>
        </div>
      `,
      list: (data) => `
        <div class="tooltip-list">
          ${data.title ? `<h4>${data.title}</h4>` : ''}
          <ul>
            ${data.items.map(item => `<li>${item}</li>`).join('')}
          </ul>
        </div>
      `,
      action: (data) => `
        <div class="tooltip-action">
          <div class="tooltip-action-content">${data.text}</div>
          <div class="tooltip-action-buttons">
            ${data.buttons.map(btn => 
              `<button data-action="${btn.action}">${btn.label}</button>`
            ).join('')}
          </div>
        </div>
      `
    };
  }
  
  create(triggerElement, content) {
    super.create(triggerElement, '');
    
    const templateName = content.template || 'default';
    const template = this.templates[templateName];
    
    if (template) {
      this.tooltip.innerHTML = template(content);
      
      // Attach button handlers for action template
      if (templateName === 'action') {
        this.tooltip.querySelectorAll('[data-action]').forEach(btn => {
          btn.addEventListener('click', (e) => {
            const action = e.target.dataset.action;
            this.trigger.dispatchEvent(new CustomEvent('tooltip:action', {
              detail: { action, data: content }
            }));
            this.hide();
          });
        });
      }
    }
    
    return this;
  }
}
```

### Tooltip Manager

```javascript
class TooltipManager {
  constructor(options = {}) {
    this.tooltips = new Map();
    this.globalOptions = options;
    this.observer = null;
  }
  
  init() {
    // Initialize tooltips on existing elements
    this.scanDocument();
    
    // Watch for dynamically added elements
    this.observer = new MutationObserver((mutations) => {
      mutations.forEach(mutation => {
        mutation.addedNodes.forEach(node => {
          if (node.nodeType === 1) {
            this.initElement(node);
            node.querySelectorAll?.('[data-tooltip]').forEach(el => {
              this.initElement(el);
            });
          }
        });
      });
    });
    
    this.observer.observe(document.body, {
      childList: true,
      subtree: true
    });
    
    // Global click handler to close interactive tooltips
    document.addEventListener('click', (e) => {
      if (!e.target.closest('[data-tooltip]') && 
          !e.target.closest('.tooltip')) {
        this.hideAll();
      }
    });
    
    // Handle escape key
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') {
        this.hideAll();
      }
    });
  }
  
  scanDocument() {
    document.querySelectorAll('[data-tooltip]').forEach(el => {
      this.initElement(el);
    });
  }
  
  initElement(element) {
    if (this.tooltips.has(element)) return;
    
    const content = element.dataset.tooltip;
    const placement = element.dataset.tooltipPlacement;
    const trigger = element.dataset.tooltipTrigger;
    const delay = element.dataset.tooltipDelay;
    const interactive = element.hasAttribute('data-tooltip-interactive');
    
    const options = {
      ...this.globalOptions,
      placement,
      trigger,
      delay: delay ? parseInt(delay) : undefined,
      interactive
    };
    
    const tooltip = new Tooltip(options);
    tooltip.create(element, content);
    
    this.tooltips.set(element, tooltip);
  }
  
  get(element) {
    return this.tooltips.get(element);
  }
  
  show(element) {
    const tooltip = this.tooltips.get(element);
    if (tooltip) tooltip.show();
  }
  
  hide(element) {
    const tooltip = this.tooltips.get(element);
    if (tooltip) tooltip.hide();
  }
  
  hideAll() {
    this.tooltips.forEach(tooltip => tooltip.hide());
  }
  
  destroy(element) {
    const tooltip = this.tooltips.get(element);
    if (tooltip) {
      tooltip.destroy();
      this.tooltips.delete(element);
    }
  }
  
  destroyAll() {
    this.tooltips.forEach(tooltip => tooltip.destroy());
    this.tooltips.clear();
    
    if (this.observer) {
      this.observer.disconnect();
    }
  }
  
  update(element, content) {
    const tooltip = this.tooltips.get(element);
    if (tooltip && tooltip.tooltip) {
      tooltip.tooltip.textContent = content;
      if (tooltip.isVisible) {
        tooltip.position();
      }
    }
  }
}

// Usage
const manager = new TooltipManager({
  placement: 'top',
  delay: 300,
  offset: 10
});

manager.init();
```

### Performance Optimizations

#### Tooltip Pooling

```javascript
class TooltipPool {
  constructor(maxSize = 10) {
    this.pool = [];
    this.maxSize = maxSize;
    this.active = new Set();
  }
  
  acquire() {
    let tooltip;
    
    if (this.pool.length > 0) {
      tooltip = this.pool.pop();
      tooltip.reset();
    } else {
      tooltip = this.createTooltip();
    }
    
    this.active.add(tooltip);
    return tooltip;
  }
  
  release(tooltip) {
    if (!this.active.has(tooltip)) return;
    
    this.active.delete(tooltip);
    
    if (this.pool.length < this.maxSize) {
      tooltip.hide();
      this.pool.push(tooltip);
    } else {
      tooltip.destroy();
    }
  }
  
  createTooltip() {
    return new Tooltip();
  }
  
  clear() {
    this.pool.forEach(tooltip => tooltip.destroy());
    this.active.forEach(tooltip => tooltip.destroy());
    this.pool = [];
    this.active.clear();
  }
}
```

#### Intersection-Based Activation

```javascript
class LazyTooltipManager extends TooltipManager {
  constructor(options = {}) {
    super(options);
    this.intersectionObserver = null;
  }
  
  init() {
    this.intersectionObserver = new IntersectionObserver(
      (entries) => {
        entries.forEach(entry => {
          if (entry.isIntersecting) {
            // Element is visible, initialize tooltip
            if (!this.tooltips.has(entry.target)) {
              this.initElement(entry.target);
            }
          } else {
            // Element is not visible, destroy tooltip to save memory
            this.destroy(entry.target);
          }
        });
      },
      {
        rootMargin: '100px' // Start loading before element is visible
      }
    );
    
	document.querySelectorAll('[data-tooltip]').forEach(el => {
	    this.intersectionObserver.observe(el);
	});
	
	// Watch for new elements
	this.observer = new MutationObserver(mutations => {
	    mutations.forEach(mutation => {
	        mutation.addedNodes.forEach(node => {
	            if (
	                node.nodeType === 1 &&
	                node.hasAttribute?.('data-tooltip')
	            ) {
	                this.intersectionObserver.observe(node);
	            }
	        });
	    });
	});

	this.observer.observe(document.body, {
		childList: true,
		subtree: true,
	});
	}

	destroyAll() {
	    super.destroyAll();
	
	    if (this.intersectionObserver) {
	        this.intersectionObserver.disconnect();
	    }
	}
}
````

#### Debounced Positioning

```javascript
class OptimizedTooltip extends Tooltip {
  constructor(options = {}) {
    super(options);
    this.positionDebounceTime = options.positionDebounceTime || 16;
    this.debouncedPosition = this.debounce(
      () => super.position(),
      this.positionDebounceTime
    );
  }
  
  position() {
    this.debouncedPosition();
  }
  
  debounce(func, wait) {
    let timeout;
    let rafId;
    
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout);
        cancelAnimationFrame(rafId);
        
        rafId = requestAnimationFrame(() => {
          func.apply(this, args);
        });
      };
      
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
    };
  }
  
  handleScroll = () => {
    if (this.isVisible) {
      // Check if trigger is still in viewport
      const rect = this.trigger.getBoundingClientRect();
      const inViewport = (
        rect.top >= 0 &&
        rect.left >= 0 &&
        rect.bottom <= window.innerHeight &&
        rect.right <= window.innerWidth
      );
      
      if (!inViewport) {
        this.hide();
      } else {
        this.position();
      }
    }
  };
}
````

### Accessibility Features

#### ARIA and Keyboard Support

```javascript
class AccessibleTooltip extends Tooltip {
  constructor(options = {}) {
    super(options);
    this.describedById = null;
  }
  
  create(triggerElement, content) {
    super.create(triggerElement, content);
    
    // Generate unique ID
    this.describedById = `tooltip-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
    this.tooltip.id = this.describedById;
    
    // Set ARIA attributes
    this.trigger.setAttribute('aria-describedby', this.describedById);
    this.tooltip.setAttribute('role', 'tooltip');
    
    // Make trigger focusable if not already
    if (!this.trigger.hasAttribute('tabindex') && 
        !this.isFocusable(this.trigger)) {
      this.trigger.setAttribute('tabindex', '0');
    }
    
    // Add keyboard support
    this.trigger.addEventListener('keydown', this.handleKeyDown);
    
    return this;
  }
  
  handleKeyDown = (e) => {
    // Show on Enter/Space if click trigger
    if (this.options.trigger === 'click') {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        this.toggle();
      }
    }
    
    // Hide on Escape
    if (e.key === 'Escape' && this.isVisible) {
      this.hide();
      this.trigger.focus();
    }
  };
  
  isFocusable(element) {
    const focusableTags = ['A', 'BUTTON', 'INPUT', 'SELECT', 'TEXTAREA'];
    return focusableTags.includes(element.tagName) || 
           element.hasAttribute('tabindex');
  }
  
  show() {
    super.show();
    
    // Announce to screen readers
    this.tooltip.setAttribute('aria-live', 'polite');
    
    // If interactive, manage focus
    if (this.options.interactive) {
      const firstFocusable = this.tooltip.querySelector(
        'button, a, input, select, textarea, [tabindex]:not([tabindex="-1"])'
      );
      
      if (firstFocusable) {
        // Save last focused element
        this.lastFocused = document.activeElement;
        
        // Trap focus within tooltip
        this.tooltip.addEventListener('keydown', this.trapFocus);
      }
    }
  }
  
  hide() {
    super.hide();
    
    // Restore focus if interactive
    if (this.options.interactive && this.lastFocused) {
      this.lastFocused.focus();
      this.lastFocused = null;
    }
    
    this.tooltip.removeEventListener('keydown', this.trapFocus);
  }
  
  trapFocus = (e) => {
    if (e.key !== 'Tab') return;
    
    const focusableElements = this.tooltip.querySelectorAll(
      'button, a, input, select, textarea, [tabindex]:not([tabindex="-1"])'
    );
    
    const firstFocusable = focusableElements[0];
    const lastFocusable = focusableElements[focusableElements.length - 1];
    
    if (e.shiftKey) {
      if (document.activeElement === firstFocusable) {
        lastFocusable.focus();
        e.preventDefault();
      }
    } else {
      if (document.activeElement === lastFocusable) {
        firstFocusable.focus();
        e.preventDefault();
      }
    }
  };
  
  destroy() {
    this.trigger.removeEventListener('keydown', this.handleKeyDown);
    this.trigger.removeAttribute('aria-describedby');
    super.destroy();
  }
}
```

### Animation System

#### CSS-Based Animations

```css
.tooltip {
  position: absolute;
  z-index: 9999;
  padding: 8px 12px;
  background: #333;
  color: white;
  border-radius: 4px;
  font-size: 14px;
  pointer-events: none;
  opacity: 0;
  transform: scale(0.9);
  transition: opacity 200ms ease, transform 200ms ease;
}

.tooltip-visible {
  opacity: 1;
  transform: scale(1);
  pointer-events: auto;
}

.tooltip-interactive {
  pointer-events: auto;
}

/* Placement-specific animations */
.tooltip[data-placement^="top"] {
  transform-origin: bottom center;
}

.tooltip[data-placement^="bottom"] {
  transform-origin: top center;
}

.tooltip[data-placement^="left"] {
  transform-origin: right center;
}

.tooltip[data-placement^="right"] {
  transform-origin: left center;
}

/* Arrow */
.tooltip-arrow {
  position: absolute;
  width: 16px;
  height: 16px;
  background: #333;
  transform: rotate(45deg);
}

.tooltip[data-placement^="top"] .tooltip-arrow {
  bottom: -4px;
}

.tooltip[data-placement^="bottom"] .tooltip-arrow {
  top: -4px;
}

.tooltip[data-placement^="left"] .tooltip-arrow {
  right: -4px;
}

.tooltip[data-placement^="right"] .tooltip-arrow {
  left: -4px;
}
```

#### JavaScript Animation Controller

```javascript
class AnimatedTooltip extends Tooltip {
  constructor(options = {}) {
    super(options);
    this.animationOptions = {
      duration: options.animationDuration || 200,
      easing: options.animationEasing || 'ease-out',
      type: options.animationType || 'fade' // fade, scale, slide
    };
  }
  
  show() {
    if (this.isVisible || this.isDestroyed) return;
    
    document.body.appendChild(this.tooltip);
    this.position();
    
    // Set initial state
    this.setInitialAnimationState();
    
    // Trigger reflow
    this.tooltip.offsetHeight;
    
    // Animate
    this.animate('show');
    
    this.isVisible = true;
    window.addEventListener('scroll', this.handleScroll, true);
    window.addEventListener('resize', this.handleResize);
    
    this.trigger.dispatchEvent(new CustomEvent('tooltip:show'));
  }
  
  hide() {
    if (!this.isVisible) return;
    
    this.animate('hide').then(() => {
      if (this.tooltip?.parentNode) {
        this.tooltip.parentNode.removeChild(this.tooltip);
      }
      this.isVisible = false;
    });
    
    window.removeEventListener('scroll', this.handleScroll, true);
    window.removeEventListener('resize', this.handleResize);
    
    this.trigger.dispatchEvent(new CustomEvent('tooltip:hide'));
  }
  
  setInitialAnimationState() {
    const { type } = this.animationOptions;
    
    if (type === 'fade') {
      this.tooltip.style.opacity = '0';
    } else if (type === 'scale') {
      this.tooltip.style.opacity = '0';
      this.tooltip.style.transform = 'scale(0.8)';
    } else if (type === 'slide') {
      const placement = this.options.placement;
      const offset = 10;
      
      this.tooltip.style.opacity = '0';
      
      if (placement.startsWith('top')) {
        this.tooltip.style.transform = `translateY(${offset}px)`;
      } else if (placement.startsWith('bottom')) {
        this.tooltip.style.transform = `translateY(-${offset}px)`;
      } else if (placement.startsWith('left')) {
        this.tooltip.style.transform = `translateX(${offset}px)`;
      } else if (placement.startsWith('right')) {
        this.tooltip.style.transform = `translateX(-${offset}px)`;
      }
    }
  }
  
  animate(direction) {
    const { duration, easing, type } = this.animationOptions;
    
    return new Promise(resolve => {
      const endState = direction === 'show' ? {
        opacity: '1',
        transform: type === 'scale' ? 'scale(1)' : 
                  type === 'slide' ? 'translate(0, 0)' : ''
      } : {
        opacity: '0',
        transform: type === 'scale' ? 'scale(0.8)' : 
                  type === 'slide' ? this.getSlideTransform() : ''
      };
      
      this.tooltip.style.transition = `all ${duration}ms ${easing}`;
      
      Object.assign(this.tooltip.style, endState);
      
      setTimeout(resolve, duration);
    });
  }
  
  getSlideTransform() {
    const placement = this.options.placement;
    const offset = 10;
    
    if (placement.startsWith('top')) return `translateY(${offset}px)`;
    if (placement.startsWith('bottom')) return `translateY(-${offset}px)`;
    if (placement.startsWith('left')) return `translateX(${offset}px)`;
    if (placement.startsWith('right')) return `translateX(-${offset}px)`;
    
    return '';
  }
}
```

### Touch and Mobile Support

```javascript
class MobileTooltip extends Tooltip {
  constructor(options = {}) {
    super(options);
    this.touchTimeout = null;
    this.isTouchDevice = 'ontouchstart' in window;
    this.longPressDelay = options.longPressDelay || 500;
  }
  
  attachListeners() {
    if (this.isTouchDevice) {
      this.trigger.addEventListener('touchstart', this.handleTouchStart, { passive: true });
      this.trigger.addEventListener('touchend', this.handleTouchEnd);
      this.trigger.addEventListener('touchmove', this.handleTouchMove, { passive: true });
    } else {
      super.attachListeners();
    }
  }
  
  handleTouchStart = (e) => {
    this.touchStartPos = {
      x: e.touches[0].clientX,
      y: e.touches[0].clientY
    };
    
    this.touchTimeout = setTimeout(() => {
      this.show();
    }, this.longPressDelay);
  };
  
  handleTouchMove = (e) => {
    if (!this.touchStartPos) return;
    
    const touch = e.touches[0];
    const deltaX = Math.abs(touch.clientX - this.touchStartPos.x);
    const deltaY = Math.abs(touch.clientY - this.touchStartPos.y);
    
    // Cancel if moved more than 10px
    if (deltaX > 10 || deltaY > 10) {
      clearTimeout(this.touchTimeout);
    }
  };
  
  handleTouchEnd = (e) => {
    clearTimeout(this.touchTimeout);
    
    // Quick tap toggles tooltip
    if (this.isVisible) {
      this.hide();
    }
  };
  
  show() {
    super.show();
    
    // On mobile, add overlay to close on outside tap
    if (this.isTouchDevice && !this.overlay) {
      this.overlay = document.createElement('div');
      this.overlay.className = 'tooltip-overlay';
      this.overlay.style.cssText = `
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        z-index: 9998;
      `;
      
      this.overlay.addEventListener('touchstart', () => {
        this.hide();
      });
      
      document.body.appendChild(this.overlay);
    }
  }
  
  hide() {
    if (this.overlay) {
      this.overlay.remove();
      this.overlay = null;
    }
    
    super.hide();
  }
  
  destroy() {
    if (this.isTouchDevice) {
      this.trigger.removeEventListener('touchstart', this.handleTouchStart);
      this.trigger.removeEventListener('touchend', this.handleTouchEnd);
      this.trigger.removeEventListener('touchmove', this.handleTouchMove);
    }
    
    if (this.overlay) {
      this.overlay.remove();
    }
    
    super.destroy();
  }
}
```

This comprehensive overview covers tooltip architecture, positioning algorithms, content management, performance optimization, accessibility, animations, and mobile support patterns used in production tooltip systems.

---

