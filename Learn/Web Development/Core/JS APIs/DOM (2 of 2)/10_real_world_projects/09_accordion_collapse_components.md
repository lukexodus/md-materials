## Accordion/Collapse Components


### Core Architecture Patterns

#### Single-Responsibility Structure

Separate concerns between container (accordion), items (panels), and controls (triggers) for maintainable component design.

```javascript
class Accordion {
  constructor(element, options = {}) {
    this.element = element;
    this.options = {
      allowMultiple: false,
      animationDuration: 300,
      defaultExpanded: null,
      ...options
    };
    
    this.panels = [];
    this.init();
  }
  
  init() {
    const panelElements = this.element.querySelectorAll('[data-accordion-panel]');
    panelElements.forEach((el, index) => {
      const panel = new AccordionPanel(el, this, index);
      this.panels.push(panel);
    });
    
    if (this.options.defaultExpanded !== null) {
      this.expand(this.options.defaultExpanded);
    }
  }
  
  expand(index) {
    const panel = this.panels[index];
    if (!panel) return;
    
    if (!this.options.allowMultiple) {
      this.panels.forEach((p, i) => {
        if (i !== index) p.collapse();
      });
    }
    
    panel.expand();
  }
  
  collapse(index) {
    const panel = this.panels[index];
    if (panel) panel.collapse();
  }
  
  toggle(index) {
    const panel = this.panels[index];
    if (panel) panel.toggle();
  }
}

class AccordionPanel {
  constructor(element, accordion, index) {
    this.element = element;
    this.accordion = accordion;
    this.index = index;
    this.isExpanded = false;
    
    this.trigger = element.querySelector('[data-accordion-trigger]');
    this.content = element.querySelector('[data-accordion-content]');
    this.contentInner = this.content.firstElementChild;
    
    this.setupAccessibility();
    this.attachEvents();
  }
  
  setupAccessibility() {
    const triggerId = `accordion-trigger-${this.index}`;
    const contentId = `accordion-content-${this.index}`;
    
    this.trigger.id = triggerId;
    this.content.id = contentId;
    
    this.trigger.setAttribute('aria-controls', contentId);
    this.trigger.setAttribute('aria-expanded', 'false');
    this.content.setAttribute('aria-labelledby', triggerId);
    this.content.setAttribute('role', 'region');
  }
  
  attachEvents() {
    this.handleClick = this.handleClick.bind(this);
    this.handleKeydown = this.handleKeydown.bind(this);
    
    this.trigger.addEventListener('click', this.handleClick);
    this.trigger.addEventListener('keydown', this.handleKeydown);
  }
  
  handleClick(e) {
    e.preventDefault();
    this.toggle();
  }
  
  handleKeydown(e) {
    // Handle keyboard navigation
    switch(e.key) {
      case 'ArrowDown':
        e.preventDefault();
        this.focusNext();
        break;
      case 'ArrowUp':
        e.preventDefault();
        this.focusPrevious();
        break;
      case 'Home':
        e.preventDefault();
        this.accordion.panels[0].trigger.focus();
        break;
      case 'End':
        e.preventDefault();
        this.accordion.panels[this.accordion.panels.length - 1].trigger.focus();
        break;
    }
  }
  
  focusNext() {
    const nextIndex = (this.index + 1) % this.accordion.panels.length;
    this.accordion.panels[nextIndex].trigger.focus();
  }
  
  focusPrevious() {
    const prevIndex = (this.index - 1 + this.accordion.panels.length) % this.accordion.panels.length;
    this.accordion.panels[prevIndex].trigger.focus();
  }
  
  toggle() {
    if (this.isExpanded) {
      this.collapse();
    } else {
      this.accordion.expand(this.index);
    }
  }
  
  expand() {
    if (this.isExpanded) return;
    
    this.isExpanded = true;
    this.trigger.setAttribute('aria-expanded', 'true');
    this.element.classList.add('is-expanded');
    
    // Animate expansion
    const height = this.contentInner.offsetHeight;
    this.content.style.height = '0px';
    
    requestAnimationFrame(() => {
      this.content.style.height = `${height}px`;
    });
    
    this.dispatchEvent('expand');
  }
  
  collapse() {
    if (!this.isExpanded) return;
    
    this.isExpanded = false;
    this.trigger.setAttribute('aria-expanded', 'false');
    
    // Animate collapse
    this.content.style.height = `${this.content.offsetHeight}px`;
    
    requestAnimationFrame(() => {
      this.content.style.height = '0px';
    });
    
    // Remove expanded class after animation
    setTimeout(() => {
      this.element.classList.remove('is-expanded');
    }, this.accordion.options.animationDuration);
    
    this.dispatchEvent('collapse');
  }
  
  dispatchEvent(type) {
    const event = new CustomEvent(`accordion:${type}`, {
      detail: { index: this.index, panel: this }
    });
    this.element.dispatchEvent(event);
  }
  
  destroy() {
    this.trigger.removeEventListener('click', this.handleClick);
    this.trigger.removeEventListener('keydown', this.handleKeydown);
  }
}
```

### Animation Strategies

#### Height-Based Animation

The most common approach calculates content height and animates the container.

```javascript
class HeightAnimator {
  constructor(element, duration = 300) {
    this.element = element;
    this.duration = duration;
    this.isAnimating = false;
  }
  
  expand(content) {
    if (this.isAnimating) return;
    this.isAnimating = true;
    
    const targetHeight = content.scrollHeight;
    
    this.element.style.height = '0px';
    this.element.style.overflow = 'hidden';
    this.element.style.transition = `height ${this.duration}ms ease-in-out`;
    
    requestAnimationFrame(() => {
      this.element.style.height = `${targetHeight}px`;
    });
    
    const handleTransitionEnd = () => {
      this.element.style.height = 'auto';
      this.element.style.overflow = '';
      this.isAnimating = false;
      this.element.removeEventListener('transitionend', handleTransitionEnd);
    };
    
    this.element.addEventListener('transitionend', handleTransitionEnd);
  }
  
  collapse() {
    if (this.isAnimating) return;
    this.isAnimating = true;
    
    const currentHeight = this.element.offsetHeight;
    
    this.element.style.height = `${currentHeight}px`;
    this.element.style.overflow = 'hidden';
    this.element.style.transition = `height ${this.duration}ms ease-in-out`;
    
    requestAnimationFrame(() => {
      this.element.style.height = '0px';
    });
    
    const handleTransitionEnd = () => {
      this.element.style.overflow = '';
      this.isAnimating = false;
      this.element.removeEventListener('transitionend', handleTransitionEnd);
    };
    
    this.element.addEventListener('transitionend', handleTransitionEnd);
  }
}
```

#### Grid-Based Animation

Uses CSS Grid's `grid-template-rows` for smoother animations without calculating heights.

```css
.accordion-content {
  display: grid;
  grid-template-rows: 0fr;
  transition: grid-template-rows 300ms ease-in-out;
  overflow: hidden;
}

.accordion-content.is-expanded {
  grid-template-rows: 1fr;
}

.accordion-content-inner {
  min-height: 0; /* Important for grid animation */
}
```

```javascript
class GridAnimator {
  expand(element) {
    element.classList.add('is-expanded');
  }
  
  collapse(element) {
    element.classList.remove('is-expanded');
  }
}
```

#### Web Animations API

Provides more control over animation lifecycle and performance.

```javascript
class WebAnimator {
  constructor(duration = 300, easing = 'ease-in-out') {
    this.duration = duration;
    this.easing = easing;
    this.currentAnimation = null;
  }
  
  expand(element, content) {
    if (this.currentAnimation) {
      this.currentAnimation.cancel();
    }
    
    const startHeight = element.offsetHeight;
    const endHeight = content.scrollHeight;
    
    this.currentAnimation = element.animate([
      { height: `${startHeight}px`, overflow: 'hidden' },
      { height: `${endHeight}px`, overflow: 'hidden' }
    ], {
      duration: this.duration,
      easing: this.easing,
      fill: 'forwards'
    });
    
    this.currentAnimation.onfinish = () => {
      element.style.height = 'auto';
      element.style.overflow = '';
      this.currentAnimation = null;
    };
    
    return this.currentAnimation.finished;
  }
  
  collapse(element) {
    if (this.currentAnimation) {
      this.currentAnimation.cancel();
    }
    
    const startHeight = element.offsetHeight;
    
    this.currentAnimation = element.animate([
      { height: `${startHeight}px`, overflow: 'hidden' },
      { height: '0px', overflow: 'hidden' }
    ], {
      duration: this.duration,
      easing: this.easing,
      fill: 'forwards'
    });
    
    this.currentAnimation.onfinish = () => {
      this.currentAnimation = null;
    };
    
    return this.currentAnimation.finished;
  }
}
```

#### Max-Height Technique

Uses `max-height` with a sufficiently large value, simpler but less precise.

```css
.accordion-content {
  max-height: 0;
  overflow: hidden;
  transition: max-height 300ms ease-in-out;
}

.accordion-content.is-expanded {
  max-height: 5000px; /* Large enough for content */
}
```

**[Inference]** This technique can cause timing issues if content exceeds the max-height value or creates unnecessarily long animations for small content due to the large transition range.

### Accessibility Implementation

#### ARIA Attributes

Proper ARIA attributes communicate accordion state to assistive technologies.

```javascript
class AccessibleAccordion {
  setupPanel(trigger, content, index) {
    // Unique IDs
    const triggerId = `accordion-trigger-${this.id}-${index}`;
    const contentId = `accordion-content-${this.id}-${index}`;
    
    // Trigger attributes
    trigger.id = triggerId;
    trigger.setAttribute('aria-expanded', 'false');
    trigger.setAttribute('aria-controls', contentId);
    
    // Content attributes
    content.id = contentId;
    content.setAttribute('role', 'region');
    content.setAttribute('aria-labelledby', triggerId);
    content.setAttribute('hidden', ''); // Native hidden attribute
  }
  
  expandPanel(trigger, content) {
    trigger.setAttribute('aria-expanded', 'true');
    content.removeAttribute('hidden');
  }
  
  collapsePanel(trigger, content) {
    trigger.setAttribute('aria-expanded', 'false');
    content.setAttribute('hidden', '');
  }
}
```

#### Keyboard Navigation

Full keyboard support follows WAI-ARIA Authoring Practices.

```javascript
class KeyboardNavigableAccordion {
  handleKeyDown(e, currentIndex) {
    const triggers = this.getAllTriggers();
    let targetIndex = currentIndex;
    
    switch(e.key) {
      case 'ArrowDown':
        e.preventDefault();
        targetIndex = (currentIndex + 1) % triggers.length;
        triggers[targetIndex].focus();
        break;
        
      case 'ArrowUp':
        e.preventDefault();
        targetIndex = (currentIndex - 1 + triggers.length) % triggers.length;
        triggers[targetIndex].focus();
        break;
        
      case 'Home':
        e.preventDefault();
        triggers[0].focus();
        break;
        
      case 'End':
        e.preventDefault();
        triggers[triggers.length - 1].focus();
        break;
        
      case 'Enter':
      case ' ':
        e.preventDefault();
        this.toggle(currentIndex);
        break;
    }
  }
  
  getAllTriggers() {
    return Array.from(this.element.querySelectorAll('[data-accordion-trigger]'));
  }
}
```

#### Focus Management

Manage focus appropriately during expansion/collapse operations.

```javascript
class FocusManagingAccordion {
  expandPanel(panelIndex) {
    const panel = this.panels[panelIndex];
    const trigger = panel.trigger;
    const content = panel.content;
    
    // Expand animation
    this.animator.expand(content);
    
    // Focus remains on trigger after expansion
    trigger.focus();
    
    // Optional: scroll expanded content into view
    if (this.options.scrollIntoView) {
      requestAnimationFrame(() => {
        content.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
      });
    }
  }
  
  collapsePanel(panelIndex) {
    const panel = this.panels[panelIndex];
    const trigger = panel.trigger;
    const content = panel.content;
    
    // If focus is inside content, move to trigger
    if (content.contains(document.activeElement)) {
      trigger.focus();
    }
    
    this.animator.collapse(content);
  }
}
```

#### Screen Reader Announcements

Provide feedback for dynamic state changes.

```javascript
class AnnouncingAccordion {
  constructor(element, options = {}) {
    this.element = element;
    this.options = options;
    this.liveRegion = this.createLiveRegion();
  }
  
  createLiveRegion() {
    const region = document.createElement('div');
    region.setAttribute('role', 'status');
    region.setAttribute('aria-live', 'polite');
    region.setAttribute('aria-atomic', 'true');
    region.className = 'sr-only';
    document.body.appendChild(region);
    return region;
  }
  
  announce(message) {
    this.liveRegion.textContent = '';
    requestAnimationFrame(() => {
      this.liveRegion.textContent = message;
    });
  }
  
  expandPanel(index) {
    const panel = this.panels[index];
    panel.expand();
    
    const label = panel.trigger.textContent.trim();
    this.announce(`${label} expanded`);
  }
  
  collapsePanel(index) {
    const panel = this.panels[index];
    panel.collapse();
    
    const label = panel.trigger.textContent.trim();
    this.announce(`${label} collapsed`);
  }
  
  destroy() {
    if (this.liveRegion && this.liveRegion.parentNode) {
      this.liveRegion.parentNode.removeChild(this.liveRegion);
    }
  }
}
```

### Performance Optimization

#### Virtual Scrolling for Large Lists

Render only visible accordion panels to reduce DOM nodes.

```javascript
class VirtualAccordion {
  constructor(element, items, options = {}) {
    this.element = element;
    this.items = items;
    this.options = {
      itemHeight: 60,
      bufferSize: 5,
      ...options
    };
    
    this.scrollContainer = element.querySelector('[data-scroll-container]');
    this.contentContainer = element.querySelector('[data-content-container]');
    
    this.visibleRange = { start: 0, end: 0 };
    this.renderedPanels = new Map();
    
    this.init();
  }
  
  init() {
    this.updateTotalHeight();
    this.updateVisibleRange();
    this.render();
    
    this.scrollContainer.addEventListener('scroll', () => {
      this.updateVisibleRange();
      this.render();
    });
  }
  
  updateTotalHeight() {
    const totalHeight = this.items.length * this.options.itemHeight;
    this.contentContainer.style.height = `${totalHeight}px`;
  }
  
  updateVisibleRange() {
    const scrollTop = this.scrollContainer.scrollTop;
    const containerHeight = this.scrollContainer.clientHeight;
    
    const start = Math.max(0, 
      Math.floor(scrollTop / this.options.itemHeight) - this.options.bufferSize
    );
    
    const end = Math.min(this.items.length,
      Math.ceil((scrollTop + containerHeight) / this.options.itemHeight) + this.options.bufferSize
    );
    
    this.visibleRange = { start, end };
  }
  
  render() {
    const { start, end } = this.visibleRange;
    
    // Remove panels outside visible range
    for (const [index, panel] of this.renderedPanels) {
      if (index < start || index >= end) {
        panel.element.remove();
        panel.destroy();
        this.renderedPanels.delete(index);
      }
    }
    
    // Add panels in visible range
    for (let i = start; i < end; i++) {
      if (!this.renderedPanels.has(i)) {
        const panelElement = this.createPanel(this.items[i], i);
        this.contentContainer.appendChild(panelElement);
        this.renderedPanels.set(i, { element: panelElement });
      }
    }
  }
  
  createPanel(item, index) {
    const panel = document.createElement('div');
    panel.className = 'accordion-panel';
    panel.style.position = 'absolute';
    panel.style.top = `${index * this.options.itemHeight}px`;
    panel.style.left = '0';
    panel.style.right = '0';
    
    panel.innerHTML = `
      <button class="accordion-trigger">${item.title}</button>
      <div class="accordion-content">${item.content}</div>
    `;
    
    return panel;
  }
}
```

#### Content Lazy Loading

Load panel content only when expanded, reducing initial payload.

```javascript
class LazyLoadAccordion {
  constructor(element, options = {}) {
    this.element = element;
    this.options = {
      loadingTemplate: '<div class="loading">Loading...</div>',
      errorTemplate: '<div class="error">Failed to load content</div>',
      ...options
    };
    
    this.panels = new Map();
    this.init();
  }
  
  async expandPanel(index) {
    const panel = this.panels.get(index);
    if (!panel) return;
    
    const content = panel.content;
    const dataSource = content.dataset.source;
    
    // Check if content already loaded
    if (content.dataset.loaded === 'true') {
      this.animator.expand(content);
      return;
    }
    
    // Show loading state
    content.innerHTML = this.options.loadingTemplate;
    this.animator.expand(content);
    
    try {
      const data = await this.fetchContent(dataSource);
      content.innerHTML = this.renderContent(data);
      content.dataset.loaded = 'true';
    } catch (error) {
      content.innerHTML = this.options.errorTemplate;
      console.error('Failed to load accordion content:', error);
    }
  }
  
  async fetchContent(source) {
    const response = await fetch(source);
    if (!response.ok) {
      throw new Error(`HTTP error ${response.status}`);
    }
    return response.json();
  }
  
  renderContent(data) {
    // Render loaded data
    return data.html;
  }
}
```

#### Debounced Resize Handling

Optimize resize calculations for responsive accordions.

```javascript
class ResponsiveAccordion {
  constructor(element, options = {}) {
    this.element = element;
    this.options = options;
    
    this.resizeObserver = new ResizeObserver(
      this.debounce(this.handleResize.bind(this), 150)
    );
    
    this.resizeObserver.observe(this.element);
  }
  
  handleResize(entries) {
    for (const entry of entries) {
      // Recalculate heights for expanded panels
      this.panels.forEach(panel => {
        if (panel.isExpanded) {
          this.updatePanelHeight(panel);
        }
      });
    }
  }
  
  updatePanelHeight(panel) {
    const content = panel.content;
    const inner = panel.contentInner;
    
    if (panel.isExpanded) {
      const newHeight = inner.offsetHeight;
      content.style.height = `${newHeight}px`;
    }
  }
  
  debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout);
        func(...args);
      };
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
    };
  }
  
  destroy() {
    this.resizeObserver.disconnect();
  }
}
```

#### RequestAnimationFrame Batching

Batch DOM operations for smoother animations.

```javascript
class BatchedAccordion {
  constructor(element) {
    this.element = element;
    this.pendingUpdates = new Set();
    this.rafId = null;
  }
  
  scheduleUpdate(panel, operation) {
    this.pendingUpdates.add({ panel, operation });
    
    if (!this.rafId) {
      this.rafId = requestAnimationFrame(() => {
        this.processBatch();
      });
    }
  }
  
  processBatch() {
    // Batch read operations
    const measurements = new Map();
    for (const { panel } of this.pendingUpdates) {
      if (panel.isExpanded) {
        measurements.set(panel, panel.contentInner.offsetHeight);
      }
    }
    
    // Batch write operations
    for (const { panel, operation } of this.pendingUpdates) {
      if (operation === 'expand') {
        const height = measurements.get(panel);
        panel.content.style.height = `${height}px`;
      } else if (operation === 'collapse') {
        panel.content.style.height = '0px';
      }
    }
    
    this.pendingUpdates.clear();
    this.rafId = null;
  }
  
  expand(panel) {
    this.scheduleUpdate(panel, 'expand');
  }
  
  collapse(panel) {
    this.scheduleUpdate(panel, 'collapse');
  }
}
```

### State Management Patterns

#### Single Source of Truth

Centralize accordion state for predictable behavior.

```javascript
class StatefulAccordion {
  constructor(element, options = {}) {
    this.element = element;
    this.options = options;
    
    // Centralized state
    this.state = {
      expandedIndices: new Set(),
      focusedIndex: null,
      disabledIndices: new Set()
    };
    
    this.listeners = new Set();
  }
  
  getState() {
    return {
      expandedIndices: Array.from(this.state.expandedIndices),
      focusedIndex: this.state.focusedIndex,
      disabledIndices: Array.from(this.state.disabledIndices)
    };
  }
  
  setState(updates) {
    const prevState = this.getState();
    
    if (updates.expandedIndices !== undefined) {
      this.state.expandedIndices = new Set(updates.expandedIndices);
    }
    
    if (updates.focusedIndex !== undefined) {
      this.state.focusedIndex = updates.focusedIndex;
    }
    
    if (updates.disabledIndices !== undefined) {
      this.state.disabledIndices = new Set(updates.disabledIndices);
    }
    
    this.notifyListeners(prevState, this.getState());
    this.syncUI();
  }
  
  subscribe(callback) {
    this.listeners.add(callback);
    return () => this.listeners.delete(callback);
  }
  
  notifyListeners(prevState, newState) {
    for (const listener of this.listeners) {
      listener(newState, prevState);
    }
  }
  
  syncUI() {
    this.panels.forEach((panel, index) => {
      const shouldBeExpanded = this.state.expandedIndices.has(index);
      const isDisabled = this.state.disabledIndices.has(index);
      
      if (shouldBeExpanded !== panel.isExpanded) {
        if (shouldBeExpanded) {
          panel.expand();
        } else {
          panel.collapse();
        }
      }
      
      panel.trigger.disabled = isDisabled;
    });
  }
  
  toggle(index) {
    if (this.state.disabledIndices.has(index)) return;
    
    const expanded = new Set(this.state.expandedIndices);
    
    if (expanded.has(index)) {
      expanded.delete(index);
    } else {
      if (!this.options.allowMultiple) {
        expanded.clear();
      }
      expanded.add(index);
    }
    
    this.setState({ expandedIndices: Array.from(expanded) });
  }
}
```

#### URL State Synchronization

Sync accordion state with URL for bookmarkable/shareable states.

```javascript
class URLSyncedAccordion extends StatefulAccordion {
  constructor(element, options = {}) {
    super(element, options);
    
    this.urlParam = options.urlParam || 'accordion';
    
    // Initialize from URL
    this.loadFromURL();
    
    // Listen to browser navigation
    window.addEventListener('popstate', () => {
      this.loadFromURL();
    });
    
    // Update URL when state changes
    this.subscribe((newState) => {
      this.updateURL(newState);
    });
  }
  
  loadFromURL() {
    const params = new URLSearchParams(window.location.search);
    const expanded = params.get(this.urlParam);
    
    if (expanded) {
      const indices = expanded.split(',').map(Number).filter(n => !isNaN(n));
      this.setState({ expandedIndices: indices });
    }
  }
  
  updateURL(state) {
    const params = new URLSearchParams(window.location.search);
    
    if (state.expandedIndices.length > 0) {
      params.set(this.urlParam, state.expandedIndices.join(','));
    } else {
      params.delete(this.urlParam);
    }
    
    const newURL = `${window.location.pathname}?${params.toString()}`;
    window.history.replaceState({}, '', newURL);
  }
}
```

#### Local Storage Persistence

Persist accordion state across page reloads.

```javascript
class PersistentAccordion extends StatefulAccordion {
  constructor(element, options = {}) {
    super(element, options);
    
    this.storageKey = options.storageKey || `accordion-${this.element.id}`;
    
    // Load saved state
    this.loadFromStorage();
    
    // Save on state change
    this.subscribe((newState) => {
      this.saveToStorage(newState);
    });
  }
  
  loadFromStorage() {
    try {
      const saved = localStorage.getItem(this.storageKey);
      if (saved) {
        const state = JSON.parse(saved);
        this.setState({
          expandedIndices: state.expandedIndices || []
        });
      }
    } catch (error) {
      console.error('Failed to load accordion state:', error);
    }
  }
  
  saveToStorage(state) {
    try {
      localStorage.setItem(this.storageKey, JSON.stringify({
        expandedIndices: state.expandedIndices,
        timestamp: Date.now()
      }));
    } catch (error) {
      console.error('Failed to save accordion state:', error);
    }
  }
  
  clearStorage() {
    try {
      localStorage.removeItem(this.storageKey);
    } catch (error) {
      console.error('Failed to clear accordion state:', error);
    }
  }
}
```

### Advanced Features

#### Nested Accordions

Handle parent-child accordion relationships properly.

```javascript
class NestedAccordion {
  constructor(element, options = {}) {
    this.element = element;
    this.options = options;
    this.parent = null;
    this.children = [];
    
    // Find parent accordion
    let parentElement = element.parentElement;
    while (parentElement) {
      if (parentElement.hasAttribute('data-accordion')) {
        this.parent = parentElement.__accordion__;
        if (this.parent) {
          this.parent.registerChild(this);
        }
        break;
      }
      parentElement = parentElement.parentElement;
    }
    
    this.element.__accordion__ = this;
  }
  
  registerChild(child) {
    this.children.push(child);
  }
  
  expand(index) {
    // Expand in parent accordion first
    if (this.parent) {
      const parentPanel = this.findContainingPanel();
      if (parentPanel) {
        this.parent.expand(parentPanel.index);
      }
    }
    
    // Then expand own panel
    super.expand(index);
  }
  
  findContainingPanel() {
    if (!this.parent) return null;
    
    return this.parent.panels.find(panel => 
      panel.content.contains(this.element)
    );
  }
  
  collapseAll() {
    // Collapse all children first
    this.children.forEach(child => child.collapseAll());
    
    // Then collapse own panels
    this.panels.forEach((panel, index) => {
      this.collapse(index);
    });
  }
}
```

#### Search/Filter Functionality

Filter accordion panels based on search input.

```javascript
class SearchableAccordion {
    constructor(element, options = {}) {
        this.element = element;
        this.options = {
            searchSelector: '[data-accordion-search]',
            highlightClass: 'search-highlight',
            ...options,
        };

        this.searchInput = element.querySelector(
            this.options.searchSelector
        );
        this.allPanels = [];
        this.filteredIndices = new Set();

        if (this.searchInput) {
            this.setupSearch();
        }
    }

    setupSearch() {
        this.handleSearch = this.debounce(
            this.performSearch.bind(this),
            300
        );
        this.searchInput.addEventListener(
            'input',
            this.handleSearch
        );
    }

    performSearch(e) {
        const query = e.target.value
            .toLowerCase()
            .trim();

        if (!query) {
            this.clearSearch();
            return;
        }

        this.filteredIndices.clear();

        this.allPanels.forEach((panel, index) => {
            const triggerText =
                panel.trigger.textContent.toLowerCase();
            const contentText =
                panel.content.textContent.toLowerCase();

            if (
                triggerText.includes(query) ||
                contentText.includes(query)
            ) {
                this.filteredIndices.add(index);
                panel.element.style.display = '';
                this.highlightMatches(panel, query);
            } else {
                panel.element.style.display = 'none';
            }
        });

        // Auto-expand matching panels
        if (this.options.autoExpandOnSearch) {
            this.filteredIndices.forEach(index => {
                this.expand(index);
            });
        }

        this.announceResults();
    }

    highlightMatches(panel, query) {
        const highlight = text => {
            const regex = new RegExp(
                `(${query})`,
                'gi'
            );
            return text.replace(
                regex,
                `<mark class="${this.options.highlightClass}">$1</mark>`
            );
        };

        // Store original text if not already stored
        if (!panel.originalTriggerHTML) {
            panel.originalTriggerHTML =
                panel.trigger.innerHTML;
            panel.originalContentHTML =
                panel.content.innerHTML;
        }

        panel.trigger.innerHTML = highlight(
            panel.originalTriggerHTML
        );
    }

    clearSearch() {
        this.filteredIndices.clear();

        this.allPanels.forEach(panel => {
            panel.element.style.display = '';

            if (panel.originalTriggerHTML) {
                panel.trigger.innerHTML =
                    panel.originalTriggerHTML;
            }
        });
    }

    announceResults() {
        const count = this.filteredIndices.size;
        const message =
            count === 0
                ? 'No results found'
                : `${count} result${
                      count === 1 ? '' : 's'
                  } found`;

        if (this.liveRegion) {
            this.liveRegion.textContent = message;
        }
    }

    debounce(func, wait) {
        let timeout;
        return function (...args) {
            clearTimeout(timeout);
            timeout = setTimeout(
                () => func.apply(this, args),
                wait
            );
        };
    }
}
````

#### Drag-to-Reorder
Allow users to reorder accordion panels via drag and drop.

```javascript
class ReorderableAccordion {
  constructor(element, options = {}) {
    this.element = element;
    this.options = {
      dragHandleSelector: '[data-drag-handle]',
      onReorder: null,
      ...options
    };
    
    this.draggedPanel = null;
    this.draggedOverPanel = null;
    
    this.setupDragAndDrop();
  }
  
  setupDragAndDrop() {
    this.panels.forEach((panel, index) => {
      const handle = panel.element.querySelector(this.options.dragHandleSelector);
      
      if (handle) {
        handle.setAttribute('draggable', 'true');
        handle.addEventListener('dragstart', (e) => this.handleDragStart(e, panel));
        handle.addEventListener('dragend', (e) => this.handleDragEnd(e));
      }
      
      panel.element.addEventListener('dragover', (e) => this.handleDragOver(e, panel));
      panel.element.addEventListener('drop', (e) => this.handleDrop(e, panel));
      panel.element.addEventListener('dragleave', (e) => this.handleDragLeave(e));
    });
  }
  
  handleDragStart(e, panel) {
    this.draggedPanel = panel;
    panel.element.classList.add('is-dragging');
    e.dataTransfer.effectAllowed = 'move';
    e.dataTransfer.setData('text/html', panel.element.innerHTML);
  }
  
  handleDragEnd(e) {
    if (this.draggedPanel) {
      this.draggedPanel.element.classList.remove('is-dragging');
      this.draggedPanel = null;
    }
    
    this.panels.forEach(p => {
      p.element.classList.remove('drag-over');
    });
  }
  
  handleDragOver(e, panel) {
    if (e.preventDefault) {
      e.preventDefault();
    }
    
    e.dataTransfer.dropEffect = 'move';
    
    if (panel !== this.draggedPanel) {
      panel.element.classList.add('drag-over');
      this.draggedOverPanel = panel;
    }
    
    return false;
  }
  
  handleDragLeave(e) {
    e.target.classList.remove('drag-over');
  }
  
  handleDrop(e, targetPanel) {
    if (e.stopPropagation) {
      e.stopPropagation();
    }
    
    if (this.draggedPanel && this.draggedPanel !== targetPanel) {
      // Reorder in DOM
      const draggedElement = this.draggedPanel.element;
      const targetElement = targetPanel.element;
      
      if (this.panels.indexOf(targetPanel) < this.panels.indexOf(this.draggedPanel)) {
        targetElement.parentNode.insertBefore(draggedElement, targetElement);
      } else {
        targetElement.parentNode.insertBefore(draggedElement, targetElement.nextSibling);
      }
      
      // Update panels array
      this.updatePanelOrder();
      
      // Notify callback
      if (this.options.onReorder) {
        this.options.onReorder(this.getPanelOrder());
      }
    }
    
    return false;
  }
  
  updatePanelOrder() {
    const elements = Array.from(this.element.querySelectorAll('[data-accordion-panel]'));
    this.panels = elements.map(el => this.panels.find(p => p.element === el));
    
    // Update indices
    this.panels.forEach((panel, index) => {
      panel.index = index;
    });
  }
  
  getPanelOrder() {
    return this.panels.map(panel => ({
      index: panel.index,
      id: panel.element.id || null
    }));
  }
}
````

#### Group/Category Management

Organize panels into collapsible groups.

```javascript
class GroupedAccordion {
  constructor(element, options = {}) {
    this.element = element;
    this.options = options;
    
    this.groups = new Map();
    this.initializeGroups();
  }
  
  initializeGroups() {
    const groupElements = this.element.querySelectorAll('[data-accordion-group]');
    
    groupElements.forEach((groupElement, groupIndex) => {
      const groupId = groupElement.dataset.accordionGroup;
      const groupToggle = groupElement.querySelector('[data-group-toggle]');
      const panels = Array.from(groupElement.querySelectorAll('[data-accordion-panel]'));
      
      const group = {
        id: groupId,
        element: groupElement,
        toggle: groupToggle,
        panels: panels,
        isExpanded: groupElement.dataset.expanded === 'true'
      };
      
      this.groups.set(groupId, group);
      
      if (groupToggle) {
        groupToggle.addEventListener('click', () => {
          this.toggleGroup(groupId);
        });
      }
    });
  }
  
  toggleGroup(groupId) {
    const group = this.groups.get(groupId);
    if (!group) return;
    
    group.isExpanded = !group.isExpanded;
    
    if (group.isExpanded) {
      group.element.classList.add('is-expanded');
      group.toggle.setAttribute('aria-expanded', 'true');
    } else {
      group.element.classList.remove('is-expanded');
      group.toggle.setAttribute('aria-expanded', 'false');
      
      // Collapse all panels in group
      group.panels.forEach(panel => {
        const index = this.getPanelIndex(panel);
        if (index !== -1) {
          this.collapse(index);
        }
      });
    }
  }
  
  expandGroup(groupId) {
    const group = this.groups.get(groupId);
    if (!group || group.isExpanded) return;
    
    this.toggleGroup(groupId);
  }
  
  collapseGroup(groupId) {
    const group = this.groups.get(groupId);
    if (!group || !group.isExpanded) return;
    
    this.toggleGroup(groupId);
  }
  
  getPanelIndex(panelElement) {
    return this.panels.findIndex(p => p.element === panelElement);
  }
}
```

### Framework Integration Examples

#### React Implementation

```jsx
import React, { useState, useRef, useEffect } from 'react';

const AccordionContext = React.createContext();

function Accordion({ children, allowMultiple = false, defaultExpanded = [] }) {
  const [expandedIndices, setExpandedIndices] = useState(new Set(defaultExpanded));
  
  const toggle = (index) => {
    setExpandedIndices(prev => {
      const next = new Set(prev);
      
      if (next.has(index)) {
        next.delete(index);
      } else {
        if (!allowMultiple) {
          next.clear();
        }
        next.add(index);
      }
      
      return next;
    });
  };
  
  const value = {
    expandedIndices,
    toggle,
    allowMultiple
  };
  
  return (
    <AccordionContext.Provider value={value}>
      <div className="accordion" role="presentation">
        {React.Children.map(children, (child, index) => 
          React.cloneElement(child, { index })
        )}
      </div>
    </AccordionContext.Provider>
  );
}

function AccordionPanel({ index, children }) {
  const { expandedIndices, toggle } = React.useContext(AccordionContext);
  const isExpanded = expandedIndices.has(index);
  
  const contentRef = useRef(null);
  const [height, setHeight] = useState(0);
  
  useEffect(() => {
    if (isExpanded && contentRef.current) {
      setHeight(contentRef.current.scrollHeight);
    } else {
      setHeight(0);
    }
  }, [isExpanded]);
  
  const triggerId = `accordion-trigger-${index}`;
  const contentId = `accordion-content-${index}`;
  
  return (
    <div className={`accordion-panel ${isExpanded ? 'is-expanded' : ''}`}>
      {React.Children.map(children, child => {
        if (child.type === AccordionTrigger) {
          return React.cloneElement(child, {
            onClick: () => toggle(index),
            'aria-expanded': isExpanded,
            'aria-controls': contentId,
            id: triggerId
          });
        }
        
        if (child.type === AccordionContent) {
          return React.cloneElement(child, {
            ref: contentRef,
            style: { height: `${height}px` },
            'aria-labelledby': triggerId,
            id: contentId,
            hidden: !isExpanded
          });
        }
        
        return child;
      })}
    </div>
  );
}

function AccordionTrigger({ children, onClick, ...props }) {
  return (
    <button
      className="accordion-trigger"
      onClick={onClick}
      {...props}
    >
      {children}
    </button>
  );
}

const AccordionContent = React.forwardRef(({ children, ...props }, ref) => {
  return (
    <div
      ref={ref}
      className="accordion-content"
      role="region"
      {...props}
    >
      <div className="accordion-content-inner">
        {children}
      </div>
    </div>
  );
});

// Usage
function App() {
  return (
    <Accordion defaultExpanded={[0]} allowMultiple={false}>
      <AccordionPanel>
        <AccordionTrigger>Panel 1</AccordionTrigger>
        <AccordionContent>Content 1</AccordionContent>
      </AccordionPanel>
      
      <AccordionPanel>
        <AccordionTrigger>Panel 2</AccordionTrigger>
        <AccordionContent>Content 2</AccordionContent>
      </AccordionPanel>
    </Accordion>
  );
}
```

#### Vue 3 Implementation

```vue
<!-- Accordion.vue -->
<template>
  <div class="accordion" role="presentation">
    <slot></slot>
  </div>
</template>

<script setup>
import { provide, ref } from 'vue';

const props = defineProps({
  allowMultiple: {
    type: Boolean,
    default: false
  },
  modelValue: {
    type: Array,
    default: () => []
  }
});

const emit = defineEmits(['update:modelValue']);

const expandedIndices = ref(new Set(props.modelValue));

const toggle = (index) => {
  const next = new Set(expandedIndices.value);
  
  if (next.has(index)) {
    next.delete(index);
  } else {
    if (!props.allowMultiple) {
      next.clear();
    }
    next.add(index);
  }
  
  expandedIndices.value = next;
  emit('update:modelValue', Array.from(next));
};

provide('accordion', {
  expandedIndices,
  toggle
});
</script>

<!-- AccordionPanel.vue -->
<template>
  <div 
    class="accordion-panel"
    :class="{ 'is-expanded': isExpanded }"
  >
    <button
      :id="triggerId"
      class="accordion-trigger"
      :aria-expanded="isExpanded"
      :aria-controls="contentId"
      @click="handleToggle"
    >
      <slot name="trigger"></slot>
    </button>
    
    <div
      :id="contentId"
      ref="contentRef"
      class="accordion-content"
      role="region"
      :aria-labelledby="triggerId"
      :style="{ height: contentHeight }"
    >
      <div ref="innerRef" class="accordion-content-inner">
        <slot name="content"></slot>
      </div>
    </div>
  </div>
</template>

<script setup>
import { inject, computed, ref, watch, onMounted } from 'vue';

const props = defineProps({
  index: {
    type: Number,
    required: true
  }
});

const accordion = inject('accordion');
const contentRef = ref(null);
const innerRef = ref(null);

const isExpanded = computed(() => 
  accordion.expandedIndices.value.has(props.index)
);

const triggerId = computed(() => `accordion-trigger-${props.index}`);
const contentId = computed(() => `accordion-content-${props.index}`);

const contentHeight = ref('0px');

watch(isExpanded, (expanded) => {
  if (expanded && innerRef.value) {
    contentHeight.value = `${innerRef.value.scrollHeight}px`;
  } else {
    contentHeight.value = '0px';
  }
});

const handleToggle = () => {
  accordion.toggle(props.index);
};

onMounted(() => {
  if (isExpanded.value && innerRef.value) {
    contentHeight.value = `${innerRef.value.scrollHeight}px`;
  }
});
</script>

<!-- Usage -->
<template>
  <Accordion v-model="expanded" :allow-multiple="true">
    <AccordionPanel :index="0">
      <template #trigger>Panel 1</template>
      <template #content>Content 1</template>
    </AccordionPanel>
    
    <AccordionPanel :index="1">
      <template #trigger>Panel 2</template>
      <template #content>Content 2</template>
    </AccordionPanel>
  </Accordion>
</template>

<script setup>
import { ref } from 'vue';

const expanded = ref([0]);
</script>
```

### Testing Strategies

#### Unit Tests

```javascript
describe('Accordion', () => {
  let accordion;
  let element;
  
  beforeEach(() => {
    element = document.createElement('div');
    element.innerHTML = `
      <div data-accordion-panel>
        <button data-accordion-trigger>Panel 1</button>
        <div data-accordion-content><div>Content 1</div></div>
      </div>
      <div data-accordion-panel>
        <button data-accordion-trigger>Panel 2</button>
        <div data-accordion-content><div>Content 2</div></div>
      </div>
    `;
    document.body.appendChild(element);
    
    accordion = new Accordion(element);
  });
  
  afterEach(() => {
    accordion.destroy();
    document.body.removeChild(element);
  });
  
  test('initializes with all panels collapsed', () => {
    accordion.panels.forEach(panel => {
      expect(panel.isExpanded).toBe(false);
      expect(panel.trigger.getAttribute('aria-expanded')).toBe('false');
    });
  });
  
  test('expands panel when trigger clicked', () => {
    const trigger = accordion.panels[0].trigger;
    trigger.click();
    
    expect(accordion.panels[0].isExpanded).toBe(true);
    expect(trigger.getAttribute('aria-expanded')).toBe('true');
  });
  
  test('collapses other panels when allowMultiple is false', () => {
    accordion.options.allowMultiple = false;
    
    accordion.expand(0);
    expect(accordion.panels[0].isExpanded).toBe(true);
    
    accordion.expand(1);
    expect(accordion.panels[0].isExpanded).toBe(false);
    expect(accordion.panels[1].isExpanded).toBe(true);
  });
  
  test('allows multiple panels when allowMultiple is true', () => {
    accordion.options.allowMultiple = true;
    
    accordion.expand(0);
    accordion.expand(1);
    
    expect(accordion.panels[0].isExpanded).toBe(true);
    expect(accordion.panels[1].isExpanded).toBe(true);
  });
  
  test('handles keyboard navigation', () => {
    const trigger0 = accordion.panels[0].trigger;
    const trigger1 = accordion.panels[1].trigger;
    
    trigger0.focus();
    
    const downEvent = new KeyboardEvent('keydown', { key: 'ArrowDown' });
    trigger0.dispatchEvent(downEvent);
    
    expect(document.activeElement).toBe(trigger1);
  });
});
```

#### Integration Tests

```javascript
describe('Accordion Integration', () => {
  test('maintains accessibility throughout interaction', async () => {
    const { container } = render(<TestAccordion />);
    
    const trigger = screen.getByRole('button', { name: /panel 1/i });
    const content = screen.getByRole('region', { hidden: true });
    
    // Initial state
    expect(trigger).toHaveAttribute('aria-expanded', 'false');
    expect(content).toHaveAttribute('aria-hidden', 'true');
    expect(content).toHaveAttribute('aria-labelledby', trigger.id);
    
    // After expansion
    await userEvent.click(trigger);
    
    expect(trigger).toHaveAttribute('aria-expanded', 'true');
    expect(content).not.toHaveAttribute('aria-hidden');
  });
  
  test('animates height smoothly', async () => {
    const { container } = render(<TestAccordion />);
    
    const content = container.querySelector('.accordion-content');
    const initialHeight = content.offsetHeight;
    
    const trigger = screen.getByRole('button', { name: /panel 1/i });
    await userEvent.click(trigger);
    
    // [Inference] Height should change during animation
    await waitFor(() => {
      expect(content.offsetHeight).toBeGreaterThan(initialHeight);
    });
  });
});
```

#### Accessibility Tests

```javascript
import { axe, toHaveNoViolations } from 'jest-axe';

expect.extend(toHaveNoViolations);

describe('Accordion Accessibility', () => {
  test('has no accessibility violations', async () => {
    const { container } = render(<TestAccordion />);
    const results = await axe(container);
    expect(results).toHaveNoViolations();
  });
  
  test('announces state changes to screen readers', async () => {
    const { container } = render(<TestAccordion />);
    
    const liveRegion = container.querySelector('[aria-live="polite"]');
    expect(liveRegion).toBeInTheDocument();
    
    const trigger = screen.getByRole('button', { name: /panel 1/i });
    await userEvent.click(trigger);
    
    await waitFor(() => {
      expect(liveRegion).toHaveTextContent(/panel 1 expanded/i);
    });
  });
});
```

This comprehensive overview covers the essential patterns, techniques, and considerations for building robust accordion/collapse components in modern web applications.

---

