## Console Methods for DOM Debugging


### Interactive Element Inspection

**`$0` through `$4`** reference the last five elements inspected in the Elements panel. `$0` is the most recent, `$4` the oldest. These persist across console commands within the same session.

```javascript
$0.classList.add('highlight');
$0.getBoundingClientRect();
```

**`inspect(element)`** opens the Elements panel and focuses on the specified DOM node. Useful when you have a reference to an element programmatically but need to see it in the DOM tree.

```javascript
const problematicDiv = document.querySelector('.broken-layout');
inspect(problematicDiv);
```

### Element Selection Shortcuts

**`$(selector)`** is an alias for `document.querySelector()`. Returns the first matching element.

**`$$(selector)`** returns an array of all matching elements (not a NodeList), making array methods immediately available without conversion.

```javascript
$$('.menu-item').forEach(item => console.log(item.textContent));
$$('.menu-item').map(item => item.dataset.id);
```

**`$x(xpath)`** evaluates an XPath expression and returns matching nodes as an array.

```javascript
$x("//button[contains(text(), 'Submit')]")
$x("//div[@class='container']//a")
```

### Event Monitoring

**`monitorEvents(element, [events])`** logs all events (or specified event types) fired on an element to the console. Without the second parameter, logs all events.

```javascript
monitorEvents($0); // Monitor all events on selected element
monitorEvents(window, ['resize', 'scroll']);
monitorEvents($('.form'), ['focus', 'blur', 'input']);
```

**`unmonitorEvents(element, [events])`** stops event monitoring.

**`getEventListeners(element)`** returns an object containing arrays of event listeners registered on the element, organized by event type. Shows the listener function, whether it uses capture, passive status, and more.

```javascript
getEventListeners($0);
// Returns: { click: Array(2), mouseover: Array(1), ... }

getEventListeners(document).DOMContentLoaded.forEach(listener => {
  console.log(listener.listener.toString());
});
```

### DOM Mutation Observation

**`monitor(function)`** logs a message to the console whenever the specified function is called, showing the function name and arguments passed.

```javascript
monitor(myElement.addEventListener);
```

**`unmonitor(function)`** stops monitoring the function.

### Property and Method Inspection

**`dir(element)`** displays an interactive property list of the element object, showing all properties and methods (not just the DOM representation). More comprehensive than `console.log()` for examining what's available on an object.

```javascript
dir($0); // Shows all properties/methods of selected element
```

**`keys(object)`** returns an array of property names. **`values(object)`** returns an array of property values.

```javascript
keys($0.dataset); // ['userId', 'itemId', 'active']
values($0.style); // CSS property values
```

### Table Visualization

**`console.table(data, [columns])`** displays array or object data in tabular format. The optional columns parameter specifies which properties to display.

```javascript
console.table($$('.product').map(el => ({
  name: el.querySelector('.name').textContent,
  price: el.querySelector('.price').textContent,
  stock: el.dataset.stock
})));

console.table($$('a'), ['href', 'textContent']);
```

### Query Performance

**`console.time(label)`** and **`console.timeEnd(label)`** measure execution time of operations between the calls.

```javascript
console.time('querySelector');
document.querySelector('.complex > .selector > .chain');
console.timeEnd('querySelector');

console.time('getElementById');
document.getElementById('simple');
console.timeEnd('getElementById');
```

**`console.timeLog(label, [data])`** logs the elapsed time at an intermediate point without ending the timer.

### Memory and Performance Profiling

**`console.profile([label])`** starts a JavaScript CPU profile. **`console.profileEnd([label])`** stops it and displays results in the Profiler panel.

```javascript
console.profile('DOMOperations');
for(let i = 0; i < 1000; i++) {
  document.body.appendChild(document.createElement('div'));
}
console.profileEnd('DOMOperations');
```

**`console.count(label)`** logs the number of times it's been called with that label. **`console.countReset(label)`** resets the counter.

```javascript
$$('.item').forEach(item => {
  if(item.classList.contains('active')) {
    console.count('active items');
  }
});
```

### Copy and Clear

**`copy(object)`** copies the string representation of the object to the clipboard. Particularly useful for extracting data from the page.

```javascript
copy($$('.email').map(el => el.textContent));
copy(JSON.stringify(myDataObject, null, 2));
```

**`clear()`** clears the console history.

### Grouping Output

**`console.group(label)`** and **`console.groupCollapsed(label)`** create collapsible groups in the console. **`console.groupEnd()`** closes the current group.

```javascript
$$('.section').forEach(section => {
  console.group(section.querySelector('h2').textContent);
  console.log('Elements:', section.querySelectorAll('*').length);
  console.log('Text length:', section.textContent.length);
  console.groupEnd();
});
```

### Conditional Logging

**`console.assert(condition, message)`** only logs when the condition is false. Useful for validating DOM state assumptions.

```javascript
console.assert($('.required-element'), 'Required element missing');
console.assert($$('.item').length === 10, 'Expected 10 items, found', $$('.item').length);
```

### Trace and Context

**`console.trace([label])`** outputs a stack trace showing how execution reached that point. Valuable for understanding event propagation or function call chains.

```javascript
element.addEventListener('click', () => {
  console.trace('Click handler called');
});
```

**`console.dir(element, {depth: null})`** in Node.js-style environments shows full object depth. [Inference: Browser console implementations vary in whether they accept the depth parameter]

### Debug and Breakpoint Control

**`debug(function)`** sets a breakpoint on the function's first line. When the function is called, the debugger pauses there. **`undebug(function)`** removes the breakpoint.

```javascript
debug(myEventHandler);
```

**`debugger;`** statement (not a console method, but related) explicitly pauses execution when DevTools is open.

### Live Expressions

Modern DevTools support "Live Expressions" (typically via a dedicated UI button) that continuously evaluate and display an expression's value. Useful for monitoring values that change as you interact with the page.

```javascript
// Examples of expressions to monitor live:
document.querySelectorAll('.active').length
window.scrollY
$0.getBoundingClientRect().top
```

### QuerySelector Performance Comparison

```javascript
console.time('Native');
document.querySelectorAll('.class');
console.timeEnd('Native');

console.time('$$ helper');
$$('.class');
console.timeEnd('$$ helper');
```

[Inference: The $$ helper typically has negligible overhead compared to native methods as it's a thin wrapper]

### Batch Element Analysis

```javascript
// Analyze all images on page
console.table($$('img').map(img => ({
  src: img.src,
  width: img.naturalWidth,
  height: img.naturalHeight,
  loaded: img.complete,
  visible: img.offsetParent !== null
})));

// Find elements without required attributes
$$('button').filter(btn => !btn.hasAttribute('aria-label')).forEach(inspect);

// Memory impact estimation
console.log('Total nodes:', document.querySelectorAll('*').length);
console.log('Event listeners:', Object.keys(getEventListeners(document)).length);
```

### Style Computation Debugging

```javascript
// Get computed styles efficiently
const computed = getComputedStyle($0);
console.table({
  display: computed.display,
  position: computed.position,
  zIndex: computed.zIndex,
  width: computed.width,
  height: computed.height
});

// Find style inheritance chain
let element = $0;
console.group('Style inheritance');
while(element) {
  console.log(element.tagName, getComputedStyle(element).display);
  element = element.parentElement;
}
console.groupEnd();
```

### Event Listener Audit

```javascript
// Find all elements with click handlers
$$('*').filter(el => {
  const listeners = getEventListeners(el);
  return listeners.click && listeners.click.length > 0;
}).forEach(el => {
  console.log(el, getEventListeners(el).click);
});

// Count total event listeners
let totalListeners = 0;
$$('*').forEach(el => {
  const listeners = getEventListeners(el);
  totalListeners += Object.values(listeners).reduce((sum, arr) => sum + arr.length, 0);
});
console.log('Total event listeners:', totalListeners);
```

---

