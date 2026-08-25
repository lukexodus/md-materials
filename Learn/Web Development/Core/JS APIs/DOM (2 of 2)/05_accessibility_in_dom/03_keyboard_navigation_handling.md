## Keyboard Navigation Handling


### Focus Management

#### Programmatic Focus Control

Focus management requires explicit handling of the `focus()` method on DOM elements. The `tabindex` attribute controls whether elements can receive focus and their position in the tab order:

- `tabindex="0"`: Element enters natural tab order
- `tabindex="-1"`: Element can receive programmatic focus but is removed from tab order
- `tabindex="1+"`: Creates explicit tab order (generally avoid due to maintenance issues)

```javascript
// Basic focus management
const element = document.getElementById('target');
element.focus();

// Focus with options
element.focus({ preventScroll: true });

// Restore focus after modal closes
const previousFocus = document.activeElement;
modal.close();
previousFocus.focus();
```

#### Focus Trapping

Focus trapping confines keyboard navigation within a specific container, essential for modals and dialogs:

```javascript
function trapFocus(container) {
  const focusableElements = container.querySelectorAll(
    'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
  );
  const firstElement = focusableElements[0];
  const lastElement = focusableElements[focusableElements.length - 1];

  container.addEventListener('keydown', (e) => {
    if (e.key !== 'Tab') return;

    if (e.shiftKey) {
      if (document.activeElement === firstElement) {
        e.preventDefault();
        lastElement.focus();
      }
    } else {
      if (document.activeElement === lastElement) {
        e.preventDefault();
        firstElement.focus();
      }
    }
  });
}
```

#### Focus Indicators

Custom focus indicators must maintain sufficient contrast and visibility:

```css
/* Enhance default focus ring */
:focus {
  outline: 2px solid #0066cc;
  outline-offset: 2px;
}

/* Focus-visible for mouse vs keyboard distinction */
:focus-visible {
  outline: 2px solid #0066cc;
  outline-offset: 2px;
}

:focus:not(:focus-visible) {
  outline: none;
}
```

### Keyboard Event Handling

#### Event Capture and Propagation

Keyboard events follow the standard DOM event flow: capture phase → target phase → bubble phase.

```javascript
element.addEventListener('keydown', handler, { capture: true });
element.addEventListener('keydown', handler); // Bubble phase (default)

// Stop propagation when needed
function handler(e) {
  e.stopPropagation(); // Prevents bubbling to parent
  e.preventDefault(); // Prevents default browser behavior
}
```

#### Key Code vs Key Property

Modern keyboard handling uses `event.key` rather than deprecated `event.keyCode`:

```javascript
element.addEventListener('keydown', (e) => {
  switch(e.key) {
    case 'Enter':
    case ' ': // Space
      handleActivation();
      break;
    case 'ArrowUp':
    case 'ArrowDown':
    case 'ArrowLeft':
    case 'ArrowRight':
      handleNavigation(e.key);
      break;
    case 'Escape':
      handleClose();
      break;
    case 'Home':
      handleFirst();
      break;
    case 'End':
      handleLast();
      break;
  }
});
```

#### Modifier Key Detection

```javascript
element.addEventListener('keydown', (e) => {
  if (e.ctrlKey && e.key === 's') {
    e.preventDefault(); // Prevent browser save dialog
    handleSave();
  }
  
  if (e.shiftKey && e.key === 'Tab') {
    // Reverse tab navigation
  }
  
  if (e.metaKey) { // Command on Mac, Windows key on PC
    // Handle meta key combinations
  }
  
  if (e.altKey) {
    // Handle alt key combinations
  }
});
```

### ARIA Keyboard Patterns

#### Button Pattern

Buttons activate on Space and Enter:

```javascript
function makeButtonAccessible(element) {
  element.setAttribute('role', 'button');
  element.setAttribute('tabindex', '0');
  
  element.addEventListener('keydown', (e) => {
    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      element.click();
    }
  });
}
```

#### Listbox Pattern

Vertical lists use Arrow Up/Down, optional Home/End:

```javascript
class Listbox {
  constructor(container) {
    this.container = container;
    this.options = Array.from(container.querySelectorAll('[role="option"]'));
    this.currentIndex = 0;
    
    container.setAttribute('role', 'listbox');
    container.setAttribute('tabindex', '0');
    
    container.addEventListener('keydown', (e) => this.handleKeydown(e));
  }
  
  handleKeydown(e) {
    switch(e.key) {
      case 'ArrowDown':
        e.preventDefault();
        this.currentIndex = Math.min(this.currentIndex + 1, this.options.length - 1);
        this.updateFocus();
        break;
      case 'ArrowUp':
        e.preventDefault();
        this.currentIndex = Math.max(this.currentIndex - 1, 0);
        this.updateFocus();
        break;
      case 'Home':
        e.preventDefault();
        this.currentIndex = 0;
        this.updateFocus();
        break;
      case 'End':
        e.preventDefault();
        this.currentIndex = this.options.length - 1;
        this.updateFocus();
        break;
      case 'Enter':
      case ' ':
        e.preventDefault();
        this.selectOption(this.currentIndex);
        break;
    }
  }
  
  updateFocus() {
    this.options.forEach((opt, i) => {
      opt.setAttribute('aria-selected', i === this.currentIndex);
      opt.setAttribute('tabindex', i === this.currentIndex ? '0' : '-1');
    });
    this.options[this.currentIndex].focus();
  }
}
```

#### Menu Pattern

Menus require both vertical and horizontal navigation:

```javascript
class Menu {
  constructor(menubar) {
    this.menubar = menubar;
    this.menus = Array.from(menubar.querySelectorAll('[role="menuitem"]'));
    this.currentIndex = 0;
    
    menubar.addEventListener('keydown', (e) => this.handleKeydown(e));
  }
  
  handleKeydown(e) {
    switch(e.key) {
      case 'ArrowRight':
        e.preventDefault();
        this.currentIndex = (this.currentIndex + 1) % this.menus.length;
        this.menus[this.currentIndex].focus();
        break;
      case 'ArrowLeft':
        e.preventDefault();
        this.currentIndex = (this.currentIndex - 1 + this.menus.length) % this.menus.length;
        this.menus[this.currentIndex].focus();
        break;
      case 'ArrowDown':
        e.preventDefault();
        this.openSubmenu();
        break;
      case 'Escape':
        e.preventDefault();
        this.closeSubmenu();
        break;
    }
  }
}
```

#### Tabs Pattern

Tab panels use Arrow Left/Right, sometimes Home/End:

```javascript
class Tabs {
  constructor(tablist) {
    this.tablist = tablist;
    this.tabs = Array.from(tablist.querySelectorAll('[role="tab"]'));
    this.panels = this.tabs.map(tab => 
      document.getElementById(tab.getAttribute('aria-controls'))
    );
    
    this.tabs.forEach((tab, i) => {
      tab.addEventListener('keydown', (e) => this.handleKeydown(e, i));
      tab.addEventListener('click', () => this.selectTab(i));
    });
  }
  
  handleKeydown(e, currentIndex) {
    let newIndex;
    
    switch(e.key) {
      case 'ArrowLeft':
        e.preventDefault();
        newIndex = currentIndex === 0 ? this.tabs.length - 1 : currentIndex - 1;
        break;
      case 'ArrowRight':
        e.preventDefault();
        newIndex = (currentIndex + 1) % this.tabs.length;
        break;
      case 'Home':
        e.preventDefault();
        newIndex = 0;
        break;
      case 'End':
        e.preventDefault();
        newIndex = this.tabs.length - 1;
        break;
      default:
        return;
    }
    
    this.selectTab(newIndex);
    this.tabs[newIndex].focus();
  }
  
  selectTab(index) {
    this.tabs.forEach((tab, i) => {
      const isSelected = i === index;
      tab.setAttribute('aria-selected', isSelected);
      tab.setAttribute('tabindex', isSelected ? '0' : '-1');
      this.panels[i].hidden = !isSelected;
    });
  }
}
```

#### Combobox Pattern

Comboboxes combine text input with list selection:

```javascript
class Combobox {
  constructor(input) {
    this.input = input;
    this.listbox = document.getElementById(input.getAttribute('aria-controls'));
    this.options = Array.from(this.listbox.querySelectorAll('[role="option"]'));
    this.isOpen = false;
    this.activeIndex = -1;
    
    input.setAttribute('role', 'combobox');
    input.setAttribute('aria-autocomplete', 'list');
    input.setAttribute('aria-expanded', 'false');
    
    input.addEventListener('keydown', (e) => this.handleKeydown(e));
  }
  
  handleKeydown(e) {
    switch(e.key) {
      case 'ArrowDown':
        e.preventDefault();
        if (!this.isOpen) {
          this.open();
        } else {
          this.activeIndex = Math.min(this.activeIndex + 1, this.options.length - 1);
          this.updateActiveDescendant();
        }
        break;
      case 'ArrowUp':
        e.preventDefault();
        if (this.isOpen) {
          this.activeIndex = Math.max(this.activeIndex - 1, 0);
          this.updateActiveDescendant();
        }
        break;
      case 'Enter':
        e.preventDefault();
        if (this.isOpen && this.activeIndex >= 0) {
          this.selectOption(this.activeIndex);
        }
        break;
      case 'Escape':
        e.preventDefault();
        this.close();
        break;
    }
  }
  
  updateActiveDescendant() {
    this.options.forEach((opt, i) => {
      opt.setAttribute('aria-selected', i === this.activeIndex);
    });
    this.input.setAttribute('aria-activedescendant', 
      this.options[this.activeIndex].id);
  }
}
```

### Roving Tabindex

Roving tabindex ensures only one element in a group is in the tab order at a time, while allowing arrow key navigation within the group:

```javascript
class RovingTabindex {
  constructor(container, itemSelector) {
    this.container = container;
    this.items = Array.from(container.querySelectorAll(itemSelector));
    this.currentIndex = 0;
    
    this.items.forEach((item, i) => {
      item.setAttribute('tabindex', i === 0 ? '0' : '-1');
      item.addEventListener('keydown', (e) => this.handleKeydown(e, i));
      item.addEventListener('focus', () => this.setCurrentIndex(i));
    });
  }
  
  handleKeydown(e, currentIndex) {
    let newIndex;
    
    switch(e.key) {
      case 'ArrowRight':
      case 'ArrowDown':
        e.preventDefault();
        newIndex = (currentIndex + 1) % this.items.length;
        break;
      case 'ArrowLeft':
      case 'ArrowUp':
        e.preventDefault();
        newIndex = (currentIndex - 1 + this.items.length) % this.items.length;
        break;
      case 'Home':
        e.preventDefault();
        newIndex = 0;
        break;
      case 'End':
        e.preventDefault();
        newIndex = this.items.length - 1;
        break;
      default:
        return;
    }
    
    this.setCurrentIndex(newIndex);
    this.items[newIndex].focus();
  }
  
  setCurrentIndex(index) {
    this.items.forEach((item, i) => {
      item.setAttribute('tabindex', i === index ? '0' : '-1');
    });
    this.currentIndex = index;
  }
}
```

### Skip Links and Landmarks

#### Skip Links

Skip links allow keyboard users to bypass repetitive content:

```html
<a href="#main-content" class="skip-link">Skip to main content</a>

<style>
.skip-link {
  position: absolute;
  top: -40px;
  left: 0;
  background: #000;
  color: #fff;
  padding: 8px;
  z-index: 100;
}

.skip-link:focus {
  top: 0;
}
</style>
```

```javascript
// Ensure skip link target receives focus
document.querySelectorAll('a[href^="#"]').forEach(link => {
  link.addEventListener('click', (e) => {
    const target = document.querySelector(link.getAttribute('href'));
    if (target) {
      target.setAttribute('tabindex', '-1');
      target.focus();
    }
  });
});
```

#### Landmark Navigation

Semantic HTML and ARIA landmarks enable navigation via screen reader shortcuts:

```html
<header role="banner">
  <nav role="navigation" aria-label="Main">
    <!-- Primary navigation -->
  </nav>
</header>

<main role="main" id="main-content">
  <article role="article">
    <!-- Content -->
  </article>
</main>

<aside role="complementary" aria-label="Related">
  <!-- Sidebar -->
</aside>

<footer role="contentinfo">
  <!-- Footer content -->
</footer>
```

### Keyboard Shortcuts

#### Custom Shortcuts

Implement custom shortcuts with care to avoid conflicts:

```javascript
class KeyboardShortcuts {
  constructor() {
    this.shortcuts = new Map();
    document.addEventListener('keydown', (e) => this.handleKeydown(e));
  }
  
  register(key, modifiers, handler) {
    const shortcutKey = this.createKey(key, modifiers);
    this.shortcuts.set(shortcutKey, handler);
  }
  
  createKey(key, modifiers = {}) {
    const parts = [];
    if (modifiers.ctrl) parts.push('ctrl');
    if (modifiers.shift) parts.push('shift');
    if (modifiers.alt) parts.push('alt');
    if (modifiers.meta) parts.push('meta');
    parts.push(key.toLowerCase());
    return parts.join('+');
  }
  
  handleKeydown(e) {
    // Don't intercept shortcuts in form fields
    if (e.target.matches('input, textarea, select')) {
      return;
    }
    
    const shortcutKey = this.createKey(e.key, {
      ctrl: e.ctrlKey,
      shift: e.shiftKey,
      alt: e.altKey,
      meta: e.metaKey
    });
    
    const handler = this.shortcuts.get(shortcutKey);
    if (handler) {
      e.preventDefault();
      handler(e);
    }
  }
}

// Usage
const shortcuts = new KeyboardShortcuts();
shortcuts.register('s', { ctrl: true }, () => save());
shortcuts.register('/', {}, () => focusSearch());
shortcuts.register('?', {}, () => showHelp());
```

#### Documenting Shortcuts

Make shortcuts discoverable:

```html
<div role="dialog" aria-label="Keyboard shortcuts">
  <h2>Keyboard Shortcuts</h2>
  <dl>
    <dt><kbd>Ctrl</kbd> + <kbd>S</kbd></dt>
    <dd>Save changes</dd>
    
    <dt><kbd>/</kbd></dt>
    <dd>Focus search</dd>
    
    <dt><kbd>?</kbd></dt>
    <dd>Show this help</dd>
  </dl>
</div>
```

### Handling Forms

#### Form Navigation

Proper form structure supports efficient keyboard navigation:

```html
<form>
  <fieldset>
    <legend>Personal Information</legend>
    
    <label for="name">Name</label>
    <input type="text" id="name" required>
    
    <label for="email">Email</label>
    <input type="email" id="email" required>
  </fieldset>
  
  <fieldset>
    <legend>Preferences</legend>
    
    <div role="group" aria-labelledby="notification-label">
      <span id="notification-label">Notifications</span>
      <label>
        <input type="checkbox" name="notify-email">
        Email
      </label>
      <label>
        <input type="checkbox" name="notify-sms">
        SMS
      </label>
    </div>
  </fieldset>
  
  <button type="submit">Submit</button>
</form>
```

#### Error Handling

Link error messages to form fields:

```javascript
function showFieldError(field, message) {
  const errorId = `${field.id}-error`;
  let errorElement = document.getElementById(errorId);
  
  if (!errorElement) {
    errorElement = document.createElement('div');
    errorElement.id = errorId;
    errorElement.setAttribute('role', 'alert');
    errorElement.className = 'error-message';
    field.parentNode.appendChild(errorElement);
  }
  
  errorElement.textContent = message;
  field.setAttribute('aria-invalid', 'true');
  field.setAttribute('aria-describedby', errorId);
  field.focus();
}

function clearFieldError(field) {
  const errorId = `${field.id}-error`;
  const errorElement = document.getElementById(errorId);
  
  if (errorElement) {
    errorElement.remove();
  }
  
  field.removeAttribute('aria-invalid');
  field.removeAttribute('aria-describedby');
}
```

### Modal Dialogs

Complete modal implementation with focus management:

```javascript
class Modal {
  constructor(element) {
    this.element = element;
    this.previousFocus = null;
    this.isOpen = false;
    
    element.setAttribute('role', 'dialog');
    element.setAttribute('aria-modal', 'true');
    element.hidden = true;
    
    this.bindEvents();
  }
  
  bindEvents() {
    // Close button
    const closeBtn = this.element.querySelector('[data-close]');
    if (closeBtn) {
      closeBtn.addEventListener('click', () => this.close());
    }
    
    // Backdrop click
    this.element.addEventListener('click', (e) => {
      if (e.target === this.element) {
        this.close();
      }
    });
    
    // Keyboard handling
    this.element.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') {
        this.close();
      }
      
      if (e.key === 'Tab') {
        this.trapFocus(e);
      }
    });
  }
  
  open() {
    this.previousFocus = document.activeElement;
    this.element.hidden = false;
    this.isOpen = true;
    
    // Focus first focusable element
    const focusable = this.getFocusableElements();
    if (focusable.length) {
      focusable[0].focus();
    }
    
    document.body.style.overflow = 'hidden';
  }
  
  close() {
    this.element.hidden = true;
    this.isOpen = false;
    document.body.style.overflow = '';
    
    if (this.previousFocus) {
      this.previousFocus.focus();
    }
  }
  
  getFocusableElements() {
    return Array.from(this.element.querySelectorAll(
      'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
    )).filter(el => !el.disabled && el.offsetParent !== null);
  }
  
  trapFocus(e) {
    const focusable = this.getFocusableElements();
    const first = focusable[0];
    const last = focusable[focusable.length - 1];
    
    if (e.shiftKey) {
      if (document.activeElement === first) {
        e.preventDefault();
        last.focus();
      }
    } else {
      if (document.activeElement === last) {
        e.preventDefault();
        first.focus();
      }
    }
  }
}
```

### React-Specific Patterns

#### Focus Management in React

```javascript
import { useRef, useEffect } from 'react';

function Dialog({ isOpen, onClose, children }) {
  const dialogRef = useRef();
  const previousFocusRef = useRef();
  
  useEffect(() => {
    if (isOpen) {
      previousFocusRef.current = document.activeElement;
      
      // Focus first element
      const focusable = dialogRef.current.querySelectorAll(
        'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
      );
      if (focusable.length) {
        focusable[0].focus();
      }
    } else {
      // Restore focus
      previousFocusRef.current?.focus();
    }
  }, [isOpen]);
  
  const handleKeyDown = (e) => {
    if (e.key === 'Escape') {
      onClose();
    }
  };
  
  if (!isOpen) return null;
  
  return (
    <div
      ref={dialogRef}
      role="dialog"
      aria-modal="true"
      onKeyDown={handleKeyDown}
    >
      {children}
    </div>
  );
}
```

#### Roving Tabindex Hook

```javascript
import { useState, useEffect, useRef } from 'react';

function useRovingTabindex(itemsCount) {
  const [currentIndex, setCurrentIndex] = useState(0);
  const itemRefs = useRef([]);
  
  const handleKeyDown = (e, index) => {
    let newIndex;
    
    switch(e.key) {
      case 'ArrowDown':
      case 'ArrowRight':
        e.preventDefault();
        newIndex = (index + 1) % itemsCount;
        break;
      case 'ArrowUp':
      case 'ArrowLeft':
        e.preventDefault();
        newIndex = (index - 1 + itemsCount) % itemsCount;
        break;
      case 'Home':
        e.preventDefault();
        newIndex = 0;
        break;
      case 'End':
        e.preventDefault();
        newIndex = itemsCount - 1;
        break;
      default:
        return;
    }
    
    setCurrentIndex(newIndex);
    itemRefs.current[newIndex]?.focus();
  };
  
  const getItemProps = (index) => ({
    ref: (el) => itemRefs.current[index] = el,
    tabIndex: index === currentIndex ? 0 : -1,
    onKeyDown: (e) => handleKeyDown(e, index),
    onFocus: () => setCurrentIndex(index)
  });
  
  return { currentIndex, getItemProps };
}

// Usage
function List({ items }) {
  const { getItemProps } = useRovingTabindex(items.length);
  
  return (
    <ul role="list">
      {items.map((item, i) => (
        <li key={item.id} {...getItemProps(i)}>
          {item.content}
        </li>
      ))}
    </ul>
  );
}
```

### Testing Keyboard Navigation

#### Manual Testing Checklist

1. Tab through all interactive elements in logical order
2. Verify visible focus indicators on all focusable elements
3. Test reverse tab (Shift + Tab) navigation
4. Verify keyboard shortcuts don't conflict with browser/screen reader
5. Test arrow key navigation in custom components
6. Verify Escape closes modals and returns focus
7. Test Enter and Space on buttons and custom controls
8. Verify skip links function correctly
9. Test with screen reader keyboard commands
10. Verify form submission with Enter key

#### Automated Testing

```javascript
// Example using Testing Library
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';

test('tabs can be navigated with arrow keys', async () => {
  const user = userEvent.setup();
  render(<TabList tabs={mockTabs} />);
  
  const firstTab = screen.getByRole('tab', { name: 'First' });
  const secondTab = screen.getByRole('tab', { name: 'Second' });
  
  firstTab.focus();
  expect(firstTab).toHaveFocus();
  
  await user.keyboard('{ArrowRight}');
  expect(secondTab).toHaveFocus();
  
  await user.keyboard('{ArrowLeft}');
  expect(firstTab).toHaveFocus();
});

test('modal traps focus', async () => {
  const user = userEvent.setup();
  const onClose = jest.fn();
  
  render(<Modal isOpen={true} onClose={onClose} />);
  
  const closeButton = screen.getByRole('button', { name: 'Close' });
  const submitButton = screen.getByRole('button', { name: 'Submit' });
  
  closeButton.focus();
  expect(closeButton).toHaveFocus();
  
  // Tab forward should wrap to last element
  await user.keyboard('{Tab}');
  expect(submitButton).toHaveFocus();
  
  await user.keyboard('{Tab}');
  expect(closeButton).toHaveFocus();
  
  // Escape should close
  await user.keyboard('{Escape}');
  expect(onClose).toHaveBeenCalled();
});
```

### Performance Considerations

#### Debouncing Keyboard Events

For expensive operations triggered by keyboard input:

```javascript
function debounce(func, wait) {
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

const handleSearch = debounce((query) => {
  // Expensive search operation
  performSearch(query);
}, 300);

searchInput.addEventListener('input', (e) => {
  handleSearch(e.target.value);
});
```

#### Throttling Arrow Key Navigation

For rapid navigation events:

```javascript
function throttle(func, limit) {
  let inThrottle;
  return function executedFunction(...args) {
    if (!inThrottle) {
      func(...args);
      inThrottle = true;
      setTimeout(() => inThrottle = false, limit);
    }
  };
}

const handleArrowKey = throttle((direction) => {
  navigateToItem(direction);
}, 100);

element.addEventListener('keydown', (e) => {
  if (e.key.startsWith('Arrow')) {
    e.preventDefault();
    handleArrowKey(e.key);
  }
});
```

### Browser Compatibility

Modern keyboard event handling is widely supported, but some considerations remain:

- `event.key` is supported in all modern browsers; older implementations may require fallbacks to `event.keyCode`
- `focus-visible` pseudo-class has good support but may require a polyfill for older browsers
- Some mobile browsers may not trigger keyboard events for virtual keyboards in expected ways

[Inference: Testing across browsers and devices remains important for keyboard navigation implementations, particularly for mobile experiences where behavior can vary significantly.]

---

