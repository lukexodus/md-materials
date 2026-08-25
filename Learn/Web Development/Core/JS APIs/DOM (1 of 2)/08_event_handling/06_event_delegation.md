## Event Delegation


### Core Mechanism

Event delegation exploits event propagation (bubbling) to handle events on multiple child elements through a single listener attached to a common ancestor. Instead of attaching individual listeners to each target element, one listener on a parent intercepts events as they bubble up from descendant elements.

The pattern relies on:

- **Event bubbling**: Events propagate from target element upward through ancestors
- **event.target**: References the actual element that triggered the event
- **event.currentTarget**: References the element with the attached listener

### Implementation Pattern

```javascript
// Without delegation - multiple listeners
buttons.forEach(button => {
  button.addEventListener('click', handleClick);
});

// With delegation - single listener
container.addEventListener('click', (event) => {
  if (event.target.matches('button')) {
    handleClick(event);
  }
});
```

### Event Flow and Target Identification

Events traverse the DOM in three phases:

1. **Capturing phase**: From window down to target (rarely used for delegation)
2. **Target phase**: Event reaches the actual target element
3. **Bubbling phase**: From target back up to window (delegation operates here)

The listener on the ancestor receives events during bubbling and examines `event.target` to determine which descendant triggered it.

### Selector Matching Strategies

**Element.matches()** - Direct element matching:

```javascript
parent.addEventListener('click', (event) => {
  if (event.target.matches('.delete-btn')) {
    // Handle delete button clicks
  }
});
```

**Element.closest()** - Ancestor matching from target:

```javascript
parent.addEventListener('click', (event) => {
  const button = event.target.closest('button');
  if (button && parent.contains(button)) {
    // Handle button or any descendant of button
  }
});
```

**classList/className checks** - Specific class testing:

```javascript
parent.addEventListener('click', (event) => {
  if (event.target.classList.contains('actionable')) {
    // Handle elements with specific class
  }
});
```

**data-attribute matching**:

```javascript
parent.addEventListener('click', (event) => {
  const action = event.target.dataset.action;
  if (action) {
    handlers[action]?.(event);
  }
});
```

### Closest() for Nested Elements

When event targets contain nested children (icons inside buttons, spans inside links), `event.target` might reference the inner element rather than the intended interactive element:

```javascript
// Problematic - target might be <span> inside button
parent.addEventListener('click', (event) => {
  if (event.target.tagName === 'BUTTON') {
    // Misses clicks on button's children
  }
});

// Better - finds button ancestor
parent.addEventListener('click', (event) => {
  const button = event.target.closest('button');
  if (button && parent.contains(button)) {
    // Handles clicks on button or any descendant
  }
});
```

The `parent.contains(button)` check prevents matching elements outside the delegation scope.

### Performance Characteristics

**Memory efficiency:**

- N elements with individual listeners: N event listener objects in memory
- N elements with delegation: 1 event listener object

**Event processing:**

- Individual listeners: Browser directly invokes handler on target
- Delegation: Browser bubbles event → ancestor handler executes → selector matching logic runs

**[Inference]** For small numbers of elements (<10), the selector matching overhead might exceed memory savings. For dynamic lists with dozens or hundreds of elements, delegation provides measurable benefits.

### Dynamic Content Handling

Delegation automatically handles elements added after listener attachment:

```javascript
list.addEventListener('click', (event) => {
  if (event.target.matches('.item')) {
    // Works for items added later via:
    // list.appendChild(newItem)
  }
});

// Items added dynamically are automatically handled
setTimeout(() => {
  list.innerHTML += '<div class="item">New Item</div>';
}, 1000);
```

No listener re-attachment required when DOM changes.

### Non-Bubbling Events

Some events don't bubble and cannot be delegated in the standard way:

**Non-bubbling events:**

- `focus`, `blur` (use `focusin`, `focusout` alternatives which do bubble)
- `load`, `unload`
- `mouseenter`, `mouseleave` (use `mouseover`, `mouseout` with relatedTarget checks)
- `scroll` (bubbles in some contexts but not reliably)

**Workarounds:**

```javascript
// focus/blur - use bubbling alternatives
parent.addEventListener('focusin', (event) => {
  if (event.target.matches('input')) {
    // Handles focus on inputs
  }
});

// mouseenter/mouseleave - use mouseover with relatedTarget
parent.addEventListener('mouseover', (event) => {
  if (event.target.matches('.item') && 
      !event.target.contains(event.relatedTarget)) {
    // Simulates mouseenter
  }
});

// scroll - must use capture phase or direct listeners
parent.addEventListener('scroll', handler, true); // Capture phase
```

### stopPropagation() Impact

If child elements or intermediate handlers call `event.stopPropagation()`, the event won't reach the delegating ancestor:

```javascript
// Delegation won't work if propagation stopped
childElement.addEventListener('click', (event) => {
  event.stopPropagation(); // Event never reaches parent
});

parent.addEventListener('click', (event) => {
  // Never called for childElement clicks
});
```

This creates implicit dependencies where delegation silently fails if propagation is interrupted.

### Multiple Selector Patterns

**Switch-based routing:**

```javascript
parent.addEventListener('click', (event) => {
  const { target } = event;
  
  if (target.matches('.delete')) {
    handleDelete(target);
  } else if (target.matches('.edit')) {
    handleEdit(target);
  } else if (target.matches('.view')) {
    handleView(target);
  }
});
```

**Action-based routing with data attributes:**

```javascript
parent.addEventListener('click', (event) => {
  const action = event.target.dataset.action;
  const handlers = {
    delete: handleDelete,
    edit: handleEdit,
    view: handleView
  };
  
  handlers[action]?.(event.target);
});
```

**Class-based handler mapping:**

```javascript
const handlerMap = new Map([
  ['delete-btn', handleDelete],
  ['edit-btn', handleEdit],
  ['save-btn', handleSave]
]);

parent.addEventListener('click', (event) => {
  for (const [className, handler] of handlerMap) {
    if (event.target.classList.contains(className)) {
      handler(event);
      break;
    }
  }
});
```

### Event Retargeting in Shadow DOM

Events crossing shadow DOM boundaries are retargeted so `event.target` appears to be the shadow host rather than the internal element:

```javascript
// Inside shadow DOM
shadowRoot.querySelector('button').addEventListener('click', (event) => {
  console.log(event.target); // <button>
});

// Outside shadow DOM with delegation
document.addEventListener('click', (event) => {
  console.log(event.target); // <custom-element> (shadow host)
});
```

Use `event.composedPath()` to access the original target across shadow boundaries.

### Delegation with Capture Phase

Attach listeners during capture phase for events that need interception before reaching targets:

```javascript
parent.addEventListener('click', (event) => {
  if (event.target.matches('.disabled')) {
    event.preventDefault();
    event.stopPropagation();
  }
}, true); // true = capture phase
```

This allows validation/cancellation before target-phase handlers execute.

### Preventing Default on Delegated Events

When delegating form submissions or link clicks, prevent default behavior selectively:

```javascript
form.addEventListener('submit', (event) => {
  if (event.target.matches('.ajax-form')) {
    event.preventDefault();
    // Handle with fetch
  }
  // Let non-matching forms submit normally
});

document.addEventListener('click', (event) => {
  const link = event.target.closest('a[data-spa]');
  if (link) {
    event.preventDefault();
    // Handle SPA navigation
  }
});
```

### Delegation Anti-Patterns

**Over-delegating to document/body:**

```javascript
// Creates global handler checking every click
document.addEventListener('click', (event) => {
  if (event.target.matches('.specific-button')) {
    // Runs selector match for all document clicks
  }
});
```

Better to delegate to nearest stable ancestor of target elements.

**Excessive selector complexity:**

```javascript
// Complex selector evaluated repeatedly
parent.addEventListener('click', (event) => {
  if (event.target.matches('.container > .list > .item:not(.disabled) > .action')) {
    // Expensive matching on every click
  }
});
```

Simplify selectors or use data attributes for better performance.

**Ignoring event ordering:**

```javascript
// Multiple delegation handlers on same element
parent.addEventListener('click', handler1);
parent.addEventListener('click', handler2);
// Handler execution order is registration order
// No guaranteed priority without explicit coordination
```

### Memory Leak Prevention

Delegation reduces memory leaks by minimizing listener attachment to temporary elements:

```javascript
// Without delegation - potential leaks
function addItem() {
  const item = document.createElement('div');
  item.addEventListener('click', () => {
    // Closure may retain references
    expensiveData.process();
  });
  list.appendChild(item);
  // If item removed without listener cleanup, leak possible
}

// With delegation - no per-item listeners
list.addEventListener('click', (event) => {
  if (event.target.matches('.item')) {
    // No per-item closures
  }
});
```

### Framework Patterns

**React synthetic events** - [Inference] React historically used root-level delegation (React 16 and earlier delegated to document):

```javascript
// React automatically handles delegation
<div onClick={handler}>
  <button>Click</button>
  <button>Click</button>
</div>
```

React 17+ delegates to the root container rather than document.

**Vue event modifiers** support delegation-like patterns:

```html
<div @click="handleClick">
  <button>Item 1</button>
  <button>Item 2</button>
</div>
```

**Angular event binding** doesn't use delegation by default; each element gets its own listener.

### Use Case Decision Matrix

**Use delegation when:**

- Managing many similar child elements (lists, tables, grids)
- Child elements added/removed dynamically
- Memory constraints significant
- Event types bubble reliably

**Avoid delegation when:**

- Only 1-3 target elements exist
- Events don't bubble (without workarounds)
- Complex ancestor-descendant relationships make selector matching fragile
- Need guaranteed capture of stopped events
- Performance profiling shows selector matching overhead exceeds benefits

### Debugging Delegated Events

```javascript
parent.addEventListener('click', (event) => {
  console.log({
    target: event.target,           // Element that triggered event
    currentTarget: event.currentTarget, // Element with listener
    matches: event.target.matches('.selector'),
    path: event.composedPath()     // Full propagation path
  });
});
```

The path array shows all elements the event traverses, useful for understanding why delegation did or didn't trigger.

---

