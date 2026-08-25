## Progressive Enhancement in DOM and JavaScript


Progressive enhancement is a development strategy where baseline functionality is delivered through HTML and CSS, with JavaScript layered on top to enhance the experience for capable browsers. The DOM serves as the enhancement target, with JavaScript progressively adding interactivity, state management, and advanced features.

### Core Enhancement Patterns

#### Feature Detection Over Browser Detection

Feature detection tests for specific capabilities rather than inferring support from browser identity. The DOM provides native testing mechanisms through property existence checks and method availability.

```javascript
// Direct property/method existence
if ('IntersectionObserver' in window) {
  // Enhance with intersection observation
}

// API availability with fallback chain
if (typeof document.startViewTransition === 'function') {
  document.startViewTransition(() => updateDOM());
} else {
  updateDOM();
}

// CSS feature detection via DOM
const supportsGrid = CSS.supports('display', 'grid');
const supportsContainer = CSS.supports('container-type', 'inline-size');
```

#### Graceful Degradation Through HTML Semantics

The DOM naturally supports progressive enhancement when JavaScript operates on semantic HTML. Buttons, links, and forms work without JavaScript, then gain enhanced behavior.

```javascript
// Link that works without JS, enhanced with JS
const link = document.querySelector('a[href="#panel"]');
link.addEventListener('click', (e) => {
  e.preventDefault();
  document.getElementById('panel').showModal(); // Enhanced modal
  // Without JS, fragment navigation still works
});

// Form with native submission, enhanced with fetch
const form = document.querySelector('form');
form.addEventListener('submit', async (e) => {
  e.preventDefault();
  const data = new FormData(form);
  await fetch(form.action, { method: form.method, body: data });
  // Without JS, normal form submission occurs
});
```

### DOM API Enhancement Layers

#### Capability-Based DOM Manipulation

Modern DOM APIs enable progressive enhancement through capability checks that determine which manipulation strategies to use.

```javascript
// Progressive element insertion
function insertContent(container, content) {
  if ('replaceChildren' in container) {
    container.replaceChildren(content);
  } else if ('replaceWith' in container.firstChild) {
    const temp = document.createElement('div');
    temp.appendChild(content);
    container.innerHTML = temp.innerHTML;
  } else {
    container.innerHTML = '';
    container.appendChild(content);
  }
}

// Progressive animation enhancement
function animateElement(element, keyframes, options) {
  if (typeof element.animate === 'function') {
    return element.animate(keyframes, options);
  } else {
    // Fallback: Apply end state immediately
    const finalFrame = keyframes[keyframes.length - 1];
    Object.assign(element.style, finalFrame);
    return { finished: Promise.resolve() };
  }
}
```

#### Event Delegation for Dynamic Content

Event delegation on stable DOM nodes enables enhancement of dynamically added content without re-binding.

```javascript
// Single listener handles current and future elements
document.addEventListener('click', (e) => {
  const button = e.target.closest('[data-action]');
  if (!button) return;
  
  const action = button.dataset.action;
  handleAction(action, button);
});

// Progressive disclosure enhancement
document.addEventListener('click', (e) => {
  const toggle = e.target.closest('[aria-expanded]');
  if (!toggle) return;
  
  const expanded = toggle.getAttribute('aria-expanded') === 'true';
  toggle.setAttribute('aria-expanded', !expanded);
  
  const targetId = toggle.getAttribute('aria-controls');
  const target = document.getElementById(targetId);
  target.hidden = expanded;
});
```

### State Management Enhancement

#### DOM as State Source

The DOM itself can serve as the source of truth, with JavaScript reading and modifying existing state rather than maintaining parallel state.

```javascript
// Read state from DOM attributes
function getFilterState() {
  const filters = document.querySelectorAll('[data-filter]');
  return Array.from(filters)
    .filter(f => f.getAttribute('aria-pressed') === 'true')
    .map(f => f.dataset.filter);
}

// Persist state to DOM for SSR compatibility
function saveScrollPosition(container) {
  container.dataset.scrollTop = container.scrollTop;
  container.dataset.scrollLeft = container.scrollLeft;
}

function restoreScrollPosition(container) {
  if (container.dataset.scrollTop) {
    container.scrollTop = parseInt(container.dataset.scrollTop, 10);
    container.scrollLeft = parseInt(container.dataset.scrollLeft, 10);
  }
}
```

#### Progressive State Synchronization

State can be progressively enhanced from server-rendered HTML to client-side interactivity.

```javascript
// Hydration pattern: attach behavior to server-rendered content
function hydrateComponent(element) {
  const initialState = JSON.parse(element.dataset.state || '{}');
  
  // Enhance with client-side reactivity
  const state = new Proxy(initialState, {
    set(target, prop, value) {
      target[prop] = value;
      updateDOM(element, state);
      return true;
    }
  });
  
  attachEventListeners(element, state);
}

// Progressive loading: start with critical content
function progressivelyLoadContent(container) {
  const critical = container.querySelector('[data-critical]');
  // Critical content already rendered
  
  if ('requestIdleCallback' in window) {
    requestIdleCallback(() => {
      const deferred = container.querySelectorAll('[data-deferred]');
      deferred.forEach(loadDeferredContent);
    });
  }
}
```

### Performance-Oriented Enhancement

#### Intersection Observer for Lazy Enhancement

Enhance elements only when they become relevant to the user's viewport.

```javascript
// Progressive image enhancement
const imageObserver = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      const img = entry.target;
      if (img.dataset.src) {
        img.src = img.dataset.src;
        img.removeAttribute('data-src');
      }
      imageObserver.unobserve(img);
    }
  });
}, { rootMargin: '50px' });

// Lazy component initialization
const componentObserver = new IntersectionObserver((entries) => {
  entries.forEach(entry => {
    if (entry.isIntersecting) {
      const component = entry.target;
      initializeComponent(component);
      componentObserver.unobserve(component);
    }
  });
});
```

#### Mutation Observer for Progressive Adaptation

Observe DOM changes and progressively enhance new content as it appears.

```javascript
// Auto-enhance dynamically inserted content
const enhancementObserver = new MutationObserver((mutations) => {
  mutations.forEach(mutation => {
    mutation.addedNodes.forEach(node => {
      if (node.nodeType === Node.ELEMENT_NODE) {
        enhanceElement(node);
        node.querySelectorAll('[data-enhance]').forEach(enhanceElement);
      }
    });
  });
});

enhancementObserver.observe(document.body, {
  childList: true,
  subtree: true
});

function enhanceElement(element) {
  const type = element.dataset.enhance;
  switch(type) {
    case 'tooltip':
      attachTooltip(element);
      break;
    case 'modal':
      attachModalBehavior(element);
      break;
  }
}
```

### Accessibility-Preserving Enhancement

#### ARIA State Progressive Enhancement

JavaScript enhancements maintain and extend ARIA semantics established in HTML.

```javascript
// Enhance with ARIA live regions
function createLiveRegion(politeness = 'polite') {
  let region = document.getElementById('live-region');
  
  if (!region) {
    region = document.createElement('div');
    region.id = 'live-region';
    region.setAttribute('aria-live', politeness);
    region.setAttribute('aria-atomic', 'true');
    region.className = 'sr-only';
    document.body.appendChild(region);
  }
  
  return {
    announce(message) {
      region.textContent = message;
    }
  };
}

// Progressive focus management
function enhanceModalFocus(dialog) {
  const focusableElements = dialog.querySelectorAll(
    'a[href], button, textarea, input, select, [tabindex]:not([tabindex="-1"])'
  );
  
  const firstFocusable = focusableElements[0];
  const lastFocusable = focusableElements[focusableElements.length - 1];
  
  dialog.addEventListener('keydown', (e) => {
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

#### Keyboard Enhancement Patterns

Progressive enhancement of keyboard interaction beyond basic HTML semantics.

```javascript
// Enhance with arrow key navigation
function enhanceMenuNavigation(menu) {
  const items = Array.from(menu.querySelectorAll('[role="menuitem"]'));
  
  menu.addEventListener('keydown', (e) => {
    const currentIndex = items.indexOf(document.activeElement);
    let nextIndex;
    
    switch(e.key) {
      case 'ArrowDown':
        e.preventDefault();
        nextIndex = (currentIndex + 1) % items.length;
        items[nextIndex].focus();
        break;
      case 'ArrowUp':
        e.preventDefault();
        nextIndex = (currentIndex - 1 + items.length) % items.length;
        items[nextIndex].focus();
        break;
      case 'Home':
        e.preventDefault();
        items[0].focus();
        break;
      case 'End':
        e.preventDefault();
        items[items.length - 1].focus();
        break;
    }
  });
}
```

### Form Enhancement Patterns

#### Progressive Validation

Layer client-side validation on top of native HTML5 validation and server-side validation.

```javascript
// Enhance form with real-time validation
function enhanceFormValidation(form) {
  // Preserve native validation as baseline
  form.setAttribute('novalidate', ''); // Disable native UI, keep constraint validation
  
  const fields = form.querySelectorAll('input, textarea, select');
  
  fields.forEach(field => {
    field.addEventListener('blur', () => {
      validateField(field);
    });
    
    field.addEventListener('input', debounce(() => {
      if (field.dataset.touched) {
        validateField(field);
      }
    }, 300));
  });
  
  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    
    fields.forEach(field => field.dataset.touched = 'true');
    
    const isValid = Array.from(fields).every(validateField);
    
    if (isValid) {
      await submitForm(form);
    }
  });
}

function validateField(field) {
  // Use native constraint validation API
  const isValid = field.checkValidity();
  
  const errorContainer = document.getElementById(`${field.id}-error`);
  if (!errorContainer) return isValid;
  
  if (!isValid) {
    errorContainer.textContent = field.validationMessage;
    field.setAttribute('aria-invalid', 'true');
    field.setAttribute('aria-describedby', errorContainer.id);
  } else {
    errorContainer.textContent = '';
    field.removeAttribute('aria-invalid');
    field.removeAttribute('aria-describedby');
  }
  
  return isValid;
}
```

#### Autocomplete Enhancement

Progressive enhancement of input fields with autocomplete suggestions.

```javascript
// Enhance input with autocomplete
function enhanceAutocomplete(input, fetchSuggestions) {
  const listId = `${input.id}-suggestions`;
  let list = document.getElementById(listId);
  
  if (!list) {
    list = document.createElement('ul');
    list.id = listId;
    list.setAttribute('role', 'listbox');
    list.hidden = true;
    input.parentNode.appendChild(list);
  }
  
  input.setAttribute('role', 'combobox');
  input.setAttribute('aria-autocomplete', 'list');
  input.setAttribute('aria-controls', listId);
  input.setAttribute('aria-expanded', 'false');
  
  let selectedIndex = -1;
  
  input.addEventListener('input', debounce(async () => {
    const query = input.value.trim();
    if (query.length < 2) {
      hideSuggestions();
      return;
    }
    
    const suggestions = await fetchSuggestions(query);
    displaySuggestions(suggestions);
  }, 300));
  
  input.addEventListener('keydown', (e) => {
    const items = list.querySelectorAll('[role="option"]');
    
    switch(e.key) {
      case 'ArrowDown':
        e.preventDefault();
        selectedIndex = Math.min(selectedIndex + 1, items.length - 1);
        updateSelection(items);
        break;
      case 'ArrowUp':
        e.preventDefault();
        selectedIndex = Math.max(selectedIndex - 1, -1);
        updateSelection(items);
        break;
      case 'Enter':
        if (selectedIndex >= 0) {
          e.preventDefault();
          selectSuggestion(items[selectedIndex]);
        }
        break;
      case 'Escape':
        hideSuggestions();
        break;
    }
  });
  
  function displaySuggestions(suggestions) {
    list.innerHTML = '';
    suggestions.forEach((suggestion, index) => {
      const item = document.createElement('li');
      item.setAttribute('role', 'option');
      item.textContent = suggestion;
      item.addEventListener('click', () => selectSuggestion(item));
      list.appendChild(item);
    });
    
    list.hidden = false;
    input.setAttribute('aria-expanded', 'true');
    selectedIndex = -1;
  }
  
  function hideSuggestions() {
    list.hidden = true;
    input.setAttribute('aria-expanded', 'false');
    selectedIndex = -1;
  }
  
  function updateSelection(items) {
    items.forEach((item, index) => {
      const selected = index === selectedIndex;
      item.setAttribute('aria-selected', selected);
      if (selected) {
        input.setAttribute('aria-activedescendant', item.id || `option-${index}`);
      }
    });
  }
  
  function selectSuggestion(item) {
    input.value = item.textContent;
    hideSuggestions();
    input.dispatchEvent(new Event('change', { bubbles: true }));
  }
}
```

### Content Loading Enhancement

#### Progressive Hydration Strategies

Enhance server-rendered content progressively based on priority and viewport.

```javascript
// Priority-based hydration
class HydrationScheduler {
  constructor() {
    this.queue = {
      critical: [],
      high: [],
      normal: [],
      low: []
    };
  }
  
  register(element, priority = 'normal') {
    const component = {
      element,
      hydrate: () => this.hydrateComponent(element)
    };
    
    this.queue[priority].push(component);
  }
  
  async start() {
    // Critical: Hydrate immediately
    await this.processQueue(this.queue.critical);
    
    // High: Hydrate on requestAnimationFrame
    requestAnimationFrame(async () => {
      await this.processQueue(this.queue.high);
      
      // Normal/Low: Hydrate on idle
      if ('requestIdleCallback' in window) {
        requestIdleCallback(async () => {
          await this.processQueue(this.queue.normal);
          await this.processQueue(this.queue.low);
        }, { timeout: 2000 });
      } else {
        setTimeout(async () => {
          await this.processQueue(this.queue.normal);
          await this.processQueue(this.queue.low);
        }, 1000);
      }
    });
  }
  
  async processQueue(queue) {
    for (const component of queue) {
      await component.hydrate();
    }
  }
  
  hydrateComponent(element) {
    const type = element.dataset.component;
    // Attach event listeners and state management
    // without re-rendering the initial HTML
  }
}
```

#### Streaming Content Enhancement

Enhance content as it streams into the DOM.

```javascript
// Progressive content streaming
async function streamContent(url, container) {
  const response = await fetch(url);
  const reader = response.body.getReader();
  const decoder = new TextDecoder();
  
  let buffer = '';
  
  while (true) {
    const { done, value } = await reader.read();
    
    if (done) break;
    
    buffer += decoder.decode(value, { stream: true });
    
    // Process complete elements from buffer
    const lastCloseTag = buffer.lastIndexOf('</');
    if (lastCloseTag === -1) continue;
    
    const nextCloseTag = buffer.indexOf('>', lastCloseTag);
    if (nextCloseTag === -1) continue;
    
    const completeHTML = buffer.substring(0, nextCloseTag + 1);
    buffer = buffer.substring(nextCloseTag + 1);
    
    // Insert and enhance
    const temp = document.createElement('div');
    temp.innerHTML = completeHTML;
    
    Array.from(temp.children).forEach(child => {
      container.appendChild(child);
      enhanceElement(child);
    });
  }
}
```

### Error Handling and Fallbacks

#### Graceful Feature Degradation

[Inference] When enhancement features fail, the application should fall back to baseline functionality rather than breaking.

```javascript
// Wrap enhancements in try-catch with fallbacks
function safeEnhance(element, enhancer) {
  try {
    enhancer(element);
  } catch (error) {
    console.warn('Enhancement failed, using baseline:', error);
    // Element still functions with HTML/CSS baseline
  }
}

// Test enhancement before applying
function conditionallyEnhance(element, feature, enhancer) {
  if (supportsFeature(feature)) {
    try {
      enhancer(element);
      element.dataset.enhanced = feature;
    } catch (error) {
      console.warn(`Failed to enhance with ${feature}:`, error);
    }
  }
}

function supportsFeature(feature) {
  const tests = {
    'customElements': 'customElements' in window,
    'shadowDOM': 'attachShadow' in Element.prototype,
    'webAnimations': typeof Element.prototype.animate === 'function',
    'intersectionObserver': 'IntersectionObserver' in window,
    'resizeObserver': 'ResizeObserver' in window
  };
  
  return tests[feature] || false;
}
```

#### Network Resilience

[Inference] Progressive enhancement should account for unreliable network conditions.

```javascript
// Optimistic UI with rollback
async function submitWithOptimisticUpdate(form, optimisticUpdate, rollback) {
  const formData = new FormData(form);
  
  // Apply optimistic update immediately
  optimisticUpdate();
  
  try {
    const response = await fetch(form.action, {
      method: form.method,
      body: formData
    });
    
    if (!response.ok) {
      throw new Error('Submission failed');
    }
    
    const result = await response.json();
    return result;
  } catch (error) {
    // Rollback on failure
    rollback();
    
    // Show error to user
    const errorMsg = form.querySelector('[role="alert"]');
    if (errorMsg) {
      errorMsg.textContent = 'Submission failed. Please try again.';
    }
    
    throw error;
  }
}

// Retry with exponential backoff
async function fetchWithRetry(url, options = {}, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      const response = await fetch(url, options);
      return response;
    } catch (error) {
      if (i === maxRetries - 1) throw error;
      
      const delay = Math.pow(2, i) * 1000;
      await new Promise(resolve => setTimeout(resolve, delay));
    }
  }
}
```

### Testing Progressive Enhancement

#### Feature Detection Testing

[Inference] Progressive enhancement requires testing both enhanced and baseline experiences.

```javascript
// Test helper for simulating capability absence
function withoutFeature(feature, test) {
  const original = window[feature];
  
  try {
    window[feature] = undefined;
    test();
  } finally {
    window[feature] = original;
  }
}

// Usage in tests
withoutFeature('IntersectionObserver', () => {
  const component = createComponent();
  // Verify component still functions
  expect(component.isVisible()).toBe(true);
});
```

#### DOM State Verification

Testing should verify that DOM state is correctly maintained as enhancement layers are added.

```javascript
// Test progressive form enhancement
function testFormEnhancement() {
  const form = document.createElement('form');
  form.innerHTML = `
    <input name="email" type="email" required>
    <button type="submit">Submit</button>
  `;
  
  // Test baseline: form works without JS
  const submitEvent = new Event('submit', { cancelable: true });
  const submitted = form.dispatchEvent(submitEvent);
  expect(submitted).toBe(true);
  
  // Test enhanced: validation prevents invalid submission
  enhanceFormValidation(form);
  const emailInput = form.querySelector('[name="email"]');
  emailInput.value = 'invalid-email';
  
  const enhancedSubmit = new Event('submit', { cancelable: true });
  const enhancedSubmitted = form.dispatchEvent(enhancedSubmit);
  expect(enhancedSubmitted).toBe(false);
  expect(emailInput.getAttribute('aria-invalid')).toBe('true');
}
```

This covers the core patterns and strategies for progressive enhancement using DOM and JavaScript APIs, focusing on practical implementation approaches that maintain baseline functionality while adding enhanced experiences.

---

