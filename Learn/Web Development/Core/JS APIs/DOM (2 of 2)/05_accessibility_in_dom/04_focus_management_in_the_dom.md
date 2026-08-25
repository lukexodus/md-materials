## Focus Management in the DOM


### Focus State and the Active Element

The browser maintains a single focus context at any given time, accessible via `document.activeElement`. This property returns the currently focused element, or `<body>` if no interactive element has focus. The focus state determines which element receives keyboard events and is critical for both user interaction and accessibility.

```javascript
// Query current focus
const focused = document.activeElement;

// Check if specific element has focus
if (element === document.activeElement) {
  // Element is focused
}
```

### Focusable Elements

Elements are focusable if they meet specific criteria. Natively focusable elements include form controls (`<input>`, `<button>`, `<select>`, `<textarea>`), links (`<a>` with `href`), and certain interactive elements (`<audio>`, `<video>` with `controls`). Non-interactive elements become focusable when assigned `tabindex`.

The `tabindex` attribute controls focusability and tab order:

- `tabindex="0"` — Element enters natural tab order
- `tabindex="-1"` — Programmatically focusable, excluded from tab sequence
- `tabindex="1+"` — Custom tab order (generally discouraged)

```javascript
// Make div focusable but skip in tab order
div.tabIndex = -1;

// Add to natural tab order
div.tabIndex = 0;
```

### Programmatic Focus Control

Focus can be controlled programmatically using `focus()` and `blur()` methods. The `focus()` method accepts options to control behavior:

```javascript
// Basic focus
element.focus();

// Focus with options
element.focus({
  preventScroll: true,  // Don't scroll element into view
  focusVisible: true    // [Inference] Force visible focus indicator
});

// Remove focus
element.blur();
```

The `focusVisible` option is **[Unverified]** — browser support and exact behavior may vary across implementations.

### Focus Events

Four primary focus events exist in the DOM:

**focus** — Fires when element receives focus (does not bubble) **blur** — Fires when element loses focus (does not bubble) **focusin** — Fires when element receives focus (bubbles) **focusout** — Fires when element loses focus (bubbles)

```javascript
// Non-bubbling events (use capture or direct attachment)
input.addEventListener('focus', (e) => {
  console.log('Input focused');
});

// Bubbling events (can delegate)
form.addEventListener('focusin', (e) => {
  console.log('Something in form focused:', e.target);
});
```

The `relatedTarget` property on focus events indicates the element losing focus (for `focus`/`focusin`) or gaining focus (for `blur`/`focusout`):

```javascript
input.addEventListener('blur', (e) => {
  console.log('Lost focus to:', e.relatedTarget);
});
```

### Focus Trapping

Focus trapping confines keyboard navigation within a specific container, essential for modals, dialogs, and overlays. Implementation requires intercepting Tab key events and cycling focus among focusable descendants:

```javascript
function trapFocus(container) {
  const focusableSelectors = 'a[href], button:not([disabled]), textarea:not([disabled]), input:not([disabled]), select:not([disabled]), [tabindex]:not([tabindex="-1"])';
  
  const focusable = Array.from(
    container.querySelectorAll(focusableSelectors)
  );
  
  const firstFocusable = focusable[0];
  const lastFocusable = focusable[focusable.length - 1];
  
  container.addEventListener('keydown', (e) => {
    if (e.key !== 'Tab') return;
    
    if (e.shiftKey) {
      if (document.activeElement === firstFocusable) {
        e.preventDefault();
        lastFocusable.focus();
      }
    } else {
      if (document.activeElement === lastFocusable) {
        e.preventDefault();
        firstFocusable.focus();
      }
    }
  });
}
```

**[Inference]**: This approach cycles focus but doesn't account for dynamically added/removed elements or nested focus traps.

### Focus Restoration

Restoring focus after transient UI changes maintains user context and keyboard navigation continuity:

```javascript
// Store reference before UI change
const previousFocus = document.activeElement;

// After UI update completes
if (previousFocus && typeof previousFocus.focus === 'function') {
  previousFocus.focus();
}
```

Focus restoration is critical when:

- Closing modals/dialogs
- Removing elements that had focus
- Completing form submissions
- Dismissing notifications

### Focus Indicators and :focus-visible

The `:focus` pseudo-class applies whenever an element has focus, regardless of input method. The `:focus-visible` pseudo-class applies when the browser determines a visible focus indicator should be shown, typically for keyboard navigation:

```css
/* Always show focus styles */
button:focus {
  outline: 2px solid blue;
}

/* Show only for keyboard navigation */
button:focus-visible {
  outline: 2px solid blue;
}

/* Remove outline for mouse/touch, keep for keyboard */
button:focus:not(:focus-visible) {
  outline: none;
}
```

**[Inference]**: The browser's heuristic for `:focus-visible` typically triggers on keyboard navigation but exact behavior varies.

### Focus Management in Shadow DOM

Shadow DOM creates isolated focus contexts. Focus events do not cross shadow boundaries by default unless using composed events:

```javascript
const shadow = element.attachShadow({ mode: 'open' });

// Focus events don't escape shadow root by default
shadow.addEventListener('focusin', (e) => {
  console.log('Composed:', e.composed); // true for focusin/focusout
});
```

`focusin` and `focusout` are composed events (cross shadow boundaries), while `focus` and `blur` are not. When querying focus within shadow DOM:

```javascript
// Active element in main document
const docActive = document.activeElement;

// Active element within shadow root
const shadowActive = shadowRoot.activeElement;
```

### Focus Order and Tab Navigation

Tab order follows document order for elements with `tabindex="0"` or naturally focusable elements. Positive `tabindex` values create custom ordering (values 1+ focused before natural order), but this pattern is discouraged:

```html
<!-- Natural tab order: 1, 2, 3 -->
<button>First</button>
<button>Second</button>
<button>Third</button>

<!-- Disrupted order: 2, 3, 1 (avoid this) -->
<button tabindex="2">First</button>
<button tabindex="3">Second</button>
<button tabindex="1">Third</button>
```

Maintain logical tab order by structuring HTML in reading order rather than manipulating `tabindex`.

### Focus Management in SPAs

Single-page applications require manual focus management during route changes and dynamic content updates:

```javascript
// Route change handler
router.on('change', (route) => {
  // Update content
  renderRoute(route);
  
  // Focus management strategy depends on change type
  const mainContent = document.querySelector('main');
  
  // Option 1: Focus main content container
  if (!mainContent.hasAttribute('tabindex')) {
    mainContent.tabIndex = -1;
  }
  mainContent.focus();
  
  // Option 2: Focus first heading
  const heading = mainContent.querySelector('h1, h2');
  if (heading) {
    heading.tabIndex = -1;
    heading.focus();
  }
});
```

### Delegated Focus in Shadow DOM

The `delegatesFocus` option in Shadow DOM automatically focuses the first focusable descendant when the shadow host receives focus:

```javascript
const shadow = element.attachShadow({ 
  mode: 'open',
  delegatesFocus: true 
});

// When element receives focus, first focusable child is focused instead
element.focus(); // Actually focuses first input, button, etc. in shadow
```

This simplifies focus management for custom components by eliminating manual redirection logic.

### Focus and Scroll Behavior

By default, calling `focus()` scrolls the element into view. This can be controlled:

```javascript
// Prevent automatic scroll
element.focus({ preventScroll: true });

// Manual scroll control after focus
element.scrollIntoView({ 
  behavior: 'smooth',
  block: 'center' 
});
```

### Inert Attribute and Focus Management

The `inert` attribute removes elements from focus order and interaction:

```html
<div inert>
  <!-- All interactive elements become unfocusable and unclickable -->
  <button>Cannot be focused or clicked</button>
  <input type="text">
</div>
```

**[Inference]**: Browser support for `inert` is modern; older browsers may require polyfills. The attribute is particularly useful for implementing modal overlays where background content should be completely inaccessible.

### Focus Management with ARIA

ARIA attributes coordinate with focus management:

- `aria-activedescendant` — Indicates which descendant has virtual focus in composite widgets
- `role="dialog"` with `aria-modal="true"` — Signals assistive technology that focus is trapped
- `aria-hidden="true"` — Hides content from assistive technology (should match `inert` or focus trapping)

```javascript
// Composite widget pattern
const listbox = document.querySelector('[role="listbox"]');
const options = listbox.querySelectorAll('[role="option"]');
let activeIndex = 0;

listbox.addEventListener('keydown', (e) => {
  if (e.key === 'ArrowDown') {
    activeIndex = Math.min(activeIndex + 1, options.length - 1);
    listbox.setAttribute('aria-activedescendant', options[activeIndex].id);
  }
});
```

### Focus Management Performance

Frequent focus changes can impact performance, particularly with complex DOMs or many focus listeners:

```javascript
// Avoid rapid focus changes in tight loops
// Bad pattern:
elements.forEach(el => {
  el.focus();
  processElement(el);
});

// Better: Focus once at end
let targetElement;
elements.forEach(el => {
  if (shouldFocus(el)) targetElement = el;
  processElement(el);
});
if (targetElement) targetElement.focus();
```

**[Inference]**: The performance impact depends on listener count, DOM complexity, and browser rendering optimizations.

### Document Visibility and Focus

Focus behavior changes when documents are hidden or backgrounded:

```javascript
document.addEventListener('visibilitychange', () => {
  if (document.hidden) {
    // Document backgrounded - focus events may not fire normally
  } else {
    // Document visible again - may need to restore focus context
    restoreFocusContext();
  }
});
```

**[Unverified]**: Exact focus event behavior when documents transition between visible/hidden states may vary across browsers and contexts.

---

