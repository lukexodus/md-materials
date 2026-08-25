## MutationObserver


The `MutationObserver` interface provides a mechanism to asynchronously observe changes to the DOM tree, replacing the deprecated Mutation Events specification with a more performant and flexible solution.

### Constructor and Instantiation

```javascript
const observer = new MutationObserver(callback);
```

The constructor accepts a single callback function that executes when observed mutations occur. The callback receives two parameters:

```javascript
const callback = (mutationsList, observer) => {
  // mutationsList: Array of MutationRecord objects
  // observer: The MutationObserver instance itself
};
```

### Core Methods

**observe(target, options)**

Initiates observation of a target node with specified configuration:

```javascript
observer.observe(targetNode, {
  childList: boolean,
  attributes: boolean,
  characterData: boolean,
  subtree: boolean,
  attributeOldValue: boolean,
  characterDataOldValue: boolean,
  attributeFilter: array
});
```

**disconnect()**

Stops the observer from receiving notifications. Previously queued mutations are discarded:

```javascript
observer.disconnect();
```

**takeRecords()**

Synchronously retrieves all pending mutation records from the observer's queue and clears it:

```javascript
const pendingMutations = observer.takeRecords();
// Returns array of MutationRecord objects
```

### Configuration Options

**childList (boolean)**

Monitors additions and removals of child nodes (including text nodes):

```javascript
observer.observe(element, { childList: true });
// Detects: appendChild, removeChild, insertBefore, replaceChild
```

**attributes (boolean)**

Tracks changes to element attributes:

```javascript
observer.observe(element, { attributes: true });
// Detects: setAttribute, removeAttribute, attribute property changes
```

**characterData (boolean)**

Monitors modifications to text node content:

```javascript
observer.observe(textNode, { characterData: true });
// Detects: textContent, nodeValue, data property changes
```

**subtree (boolean)**

Extends observation to all descendants of the target node:

```javascript
observer.observe(element, { 
  childList: true, 
  subtree: true 
});
// Observes entire subtree, not just direct children
```

**attributeOldValue (boolean)**

Records the previous attribute value before modification. Requires `attributes: true`:

```javascript
observer.observe(element, { 
  attributes: true, 
  attributeOldValue: true 
});
// MutationRecord.oldValue contains previous attribute value
```

**characterDataOldValue (boolean)**

Records the previous text content before modification. Requires `characterData: true`:

```javascript
observer.observe(textNode, { 
  characterData: true, 
  characterDataOldValue: true 
});
// MutationRecord.oldValue contains previous text
```

**attributeFilter (Array\<string>)**

Limits attribute observation to specified attribute names. Implicitly sets `attributes: true`:

```javascript
observer.observe(element, { 
  attributeFilter: ['class', 'data-state'] 
});
// Only monitors class and data-state attributes
```

### MutationRecord Structure

Each mutation generates a `MutationRecord` object with the following properties:

**type (string)**

- `"childList"` - Child node modification
- `"attributes"` - Attribute change
- `"characterData"` - Text content change

**target (Node)** The node directly affected by the mutation.

**addedNodes (NodeList)** Nodes added to the tree (for `childList` mutations). Empty `NodeList` if none added.

**removedNodes (NodeList)** Nodes removed from the tree (for `childList` mutations). Empty `NodeList` if none removed.

**previousSibling (Node | null)** The previous sibling of added/removed nodes. `null` if no previous sibling or not applicable.

**nextSibling (Node | null)** The next sibling of added/removed nodes. `null` if no next sibling or not applicable.

**attributeName (string | null)** Name of the changed attribute (for `attributes` mutations). `null` for other mutation types.

**attributeNamespace (string | null)** Namespace of the changed attribute. `null` for non-namespaced attributes or other mutation types.

**oldValue (string | null)** Previous value before the mutation, if `attributeOldValue` or `characterDataOldValue` was enabled. `null` otherwise.

```javascript
const observer = new MutationObserver(mutations => {
  mutations.forEach(mutation => {
    console.log({
      type: mutation.type,
      target: mutation.target,
      addedNodes: mutation.addedNodes,
      removedNodes: mutation.removedNodes,
      attributeName: mutation.attributeName,
      oldValue: mutation.oldValue
    });
  });
});
```

### Execution Model and Timing

**Asynchronous microtask delivery:**

Mutation callbacks execute asynchronously as microtasks, not synchronously during DOM modifications. Multiple mutations within a single JavaScript execution context are batched and delivered together:

```javascript
element.setAttribute('class', 'one');
element.setAttribute('class', 'two');
element.setAttribute('class', 'three');
// Single callback invocation with 3 MutationRecords
```

**Delivery timing:**

Callbacks execute after the current JavaScript task completes but before the next task or rendering. This occurs during microtask checkpoint processing:

```javascript
element.textContent = 'Modified';
console.log('Synchronous');
// Callback executes here (microtask)
// Then rendering occurs
```

**Microtask queue ordering:**

MutationObserver callbacks execute in the order they were registered when multiple observers monitor the same changes:

```javascript
const observer1 = new MutationObserver(cb1);
const observer2 = new MutationObserver(cb2);
observer1.observe(element, { childList: true });
observer2.observe(element, { childList: true });
element.appendChild(node);
// cb1 executes before cb2
```

### Multiple Observers on Same Target

Multiple `MutationObserver` instances can observe the same node independently. Each receives its own mutation records:

```javascript
const observer1 = new MutationObserver(mutations => {
  console.log('Observer 1:', mutations.length);
});

const observer2 = new MutationObserver(mutations => {
  console.log('Observer 2:', mutations.length);
});

observer1.observe(element, { attributes: true });
observer2.observe(element, { childList: true });

element.setAttribute('class', 'test'); // Only observer1 notified
element.appendChild(node); // Only observer2 notified
```

### Re-observing Nodes

Calling `observe()` on an already-observed target with different options replaces the previous observation configuration:

```javascript
observer.observe(element, { childList: true });
// Later...
observer.observe(element, { attributes: true });
// Now only observes attributes, childList observation stopped
```

To observe multiple targets, call `observe()` multiple times with different target nodes:

```javascript
observer.observe(element1, { childList: true });
observer.observe(element2, { attributes: true });
// Single observer monitors both elements
```

### Performance Characteristics

**[Inference]** MutationObserver delivers significantly better performance than deprecated Mutation Events because:

1. **Batched delivery** - Multiple mutations are coalesced into a single callback invocation
2. **Asynchronous execution** - No synchronous event propagation overhead
3. **Selective monitoring** - Precise configuration reduces unnecessary processing
4. **No event bubbling** - Eliminates bubble/capture phase complexity

**Memory considerations:**

Each observer maintains internal state and references to observed nodes. Failing to call `disconnect()` can prevent garbage collection of observed DOM subtrees:

```javascript
// Potential memory leak
function attachObserver(element) {
  const observer = new MutationObserver(callback);
  observer.observe(element, { childList: true });
  // observer reference lost, but still observing
}

// Proper cleanup
function attachObserver(element) {
  const observer = new MutationObserver(callback);
  observer.observe(element, { childList: true });
  return observer; // Return for later disconnect()
}
```

### Common Use Cases

**Detecting dynamic content injection:**

```javascript
const observer = new MutationObserver(mutations => {
  mutations.forEach(mutation => {
    mutation.addedNodes.forEach(node => {
      if (node.nodeType === 1 && node.matches('.dynamic-content')) {
        initializeComponent(node);
      }
    });
  });
});

observer.observe(document.body, { 
  childList: true, 
  subtree: true 
});
```

**Monitoring attribute changes for reactive updates:**

```javascript
const observer = new MutationObserver(mutations => {
  mutations.forEach(mutation => {
    if (mutation.attributeName === 'data-state') {
      updateUI(mutation.target);
    }
  });
});

observer.observe(stateContainer, { 
  attributes: true, 
  attributeFilter: ['data-state'] 
});
```

**Lazy initialization when elements appear:**

```javascript
const observer = new MutationObserver((mutations, obs) => {
  const targetElement = document.querySelector('.lazy-target');
  if (targetElement) {
    initializeTarget(targetElement);
    obs.disconnect(); // Stop observing once found
  }
});

observer.observe(document.body, { 
  childList: true, 
  subtree: true 
});
```

**Tracking DOM modifications for undo/redo:**

```javascript
const historyStack = [];

const observer = new MutationObserver(mutations => {
  historyStack.push(mutations.map(m => ({
    type: m.type,
    target: m.target,
    oldValue: m.oldValue,
    addedNodes: Array.from(m.addedNodes),
    removedNodes: Array.from(m.removedNodes)
  })));
});

observer.observe(editableArea, {
  childList: true,
  attributes: true,
  characterData: true,
  subtree: true,
  attributeOldValue: true,
  characterDataOldValue: true
});
```

**Responding to external library DOM changes:**

```javascript
// Monitor changes made by third-party components
const observer = new MutationObserver(mutations => {
  mutations.forEach(mutation => {
    if (mutation.target.classList.contains('third-party-widget')) {
      syncApplicationState(mutation.target);
    }
  });
});

observer.observe(widgetContainer, {
  attributes: true,
  childList: true,
  subtree: true
});
```

### Interaction with Shadow DOM

MutationObserver can observe shadow roots directly:

```javascript
const shadowRoot = element.attachShadow({ mode: 'open' });
observer.observe(shadowRoot, { 
  childList: true, 
  subtree: true 
});
// Observes mutations within shadow tree
```

**[Inference]** Observing a shadow host element with `subtree: true` does not penetrate shadow boundaries. Shadow DOM mutations require separate observation of the shadow root itself.

### Transient Observer Pattern

For single-use observation scenarios, disconnect within the callback:

```javascript
const observer = new MutationObserver((mutations, obs) => {
  // Process mutations
  processChanges(mutations);
  
  // Immediately disconnect
  obs.disconnect();
});

observer.observe(element, { childList: true });
```

### Mutation Callback Recursion

DOM modifications within the mutation callback can trigger additional mutations. The observer queues these for the next microtask checkpoint:

```javascript
const observer = new MutationObserver(mutations => {
  // This modification triggers a new mutation
  element.setAttribute('data-count', counter++);
  // New mutation delivered in next microtask, not recursively
});

observer.observe(element, { attributes: true });
element.setAttribute('data-trigger', 'value');
// Initial callback executes
// Then callback for data-count mutation executes
```

**Preventing infinite loops:**

Without safeguards, mutation callbacks can create infinite loops:

```javascript
// Dangerous - infinite loop
const observer = new MutationObserver(mutations => {
  element.textContent = Math.random(); // Triggers mutation
});

observer.observe(element, { characterData: true, subtree: true });
element.textContent = 'initial'; // Starts infinite loop
```

**Safe patterns:**

```javascript
// Conditional modification
const observer = new MutationObserver(mutations => {
  const current = element.getAttribute('data-state');
  if (current !== 'processed') {
    element.setAttribute('data-state', 'processed');
  }
});

// Temporary disconnection
const observer = new MutationObserver(mutations => {
  observer.disconnect();
  element.textContent = 'Modified';
  observer.observe(element, { characterData: true, subtree: true });
});
```

### Browser Compatibility

MutationObserver has universal support across modern browsers:

- Chrome 26+
- Firefox 14+
- Safari 6.1+
- Edge (all versions)
- IE 11

The API is stable and specified in the DOM Standard maintained by WHATWG.

### Debugging Considerations

**Logging mutations comprehensively:**

```javascript
const observer = new MutationObserver(mutations => {
  console.group('Mutations detected:', mutations.length);
  mutations.forEach((mutation, index) => {
    console.log(`[${index}] Type: ${mutation.type}`);
    console.log('  Target:', mutation.target);
    
    if (mutation.type === 'childList') {
      console.log('  Added:', mutation.addedNodes.length);
      console.log('  Removed:', mutation.removedNodes.length);
    } else if (mutation.type === 'attributes') {
      console.log('  Attribute:', mutation.attributeName);
      console.log('  Old value:', mutation.oldValue);
      console.log('  New value:', mutation.target.getAttribute(mutation.attributeName));
    }
  });
  console.groupEnd();
});
```

**Tracking observer lifecycle:**

```javascript
class TrackedMutationObserver {
  constructor(callback) {
    this.active = false;
    this.targets = new Set();
    this.observer = new MutationObserver((mutations, obs) => {
      callback(mutations, this);
    });
  }
  
  observe(target, options) {
    this.observer.observe(target, options);
    this.targets.add(target);
    this.active = true;
  }
  
  disconnect() {
    this.observer.disconnect();
    this.targets.clear();
    this.active = false;
  }
  
  isObserving(target) {
    return this.targets.has(target);
  }
}
```

### Comparison to Mutation Events (Deprecated)

MutationObserver replaces the following deprecated Mutation Events:

- `DOMNodeInserted`
- `DOMNodeRemoved`
- `DOMSubtreeModified`
- `DOMAttrModified`
- `DOMCharacterDataModified`

**Key improvements:**

- Asynchronous vs. synchronous delivery
- Batched mutations vs. individual events
- No event propagation overhead
- Selective observation configuration
- Better performance characteristics

**Migration pattern:**

```javascript
// Old (deprecated)
element.addEventListener('DOMNodeInserted', (event) => {
  console.log('Node inserted:', event.target);
});

// New
const observer = new MutationObserver(mutations => {
  mutations.forEach(mutation => {
    mutation.addedNodes.forEach(node => {
      console.log('Node inserted:', node);
    });
  });
});

observer.observe(element, { childList: true });
```

### Working with takeRecords()

The `takeRecords()` method retrieves pending mutations before they're delivered to the callback:

```javascript
const observer = new MutationObserver(mutations => {
  console.log('Callback received:', mutations.length);
});

observer.observe(element, { attributes: true });

element.setAttribute('class', 'one');
element.setAttribute('class', 'two');

// Retrieve mutations before callback executes
const records = observer.takeRecords();
console.log('Taken records:', records.length); // 2

// Callback will not execute for these mutations
```

**Practical application - synchronous processing before disconnect:**

```javascript
function stopObservingAndProcess(observer) {
  const pendingMutations = observer.takeRecords();
  observer.disconnect();
  
  // Process any mutations that were queued but not yet delivered
  processMutations(pendingMutations);
}
```

### WeakRef and FinalizationRegistry Interactions

**[Inference]** MutationObserver maintains strong references to observed nodes, preventing garbage collection. This differs from `WeakRef` patterns and requires explicit `disconnect()` for cleanup:

```javascript
// Observer prevents garbage collection
let element = document.createElement('div');
const observer = new MutationObserver(callback);
observer.observe(element, { attributes: true });

element = null; // Element not collected due to observer reference
observer.disconnect(); // Now element can be collected
```

---

