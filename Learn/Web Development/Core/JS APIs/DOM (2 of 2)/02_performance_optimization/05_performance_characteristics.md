## Performance Characteristics


### Reflow and Repaint Reduction

Each direct DOM insertion triggers layout recalculation. DocumentFragment batches these operations into a single insertion point:

```javascript
// Poor: 100 reflows
for (let i = 0; i < 100; i++) {
  container.appendChild(document.createElement('div'));
}

// Optimized: 1 reflow
const fragment = document.createDocumentFragment();
for (let i = 0; i < 100; i++) {
  fragment.appendChild(document.createElement('div'));
}
container.appendChild(fragment);
```

### Memory Efficiency

DocumentFragment maintains minimal overhead compared to creating temporary container elements:

```javascript
// Uses temporary container (more memory)
const temp = document.createElement('div');
temp.innerHTML = generateLargeHTML();
while (temp.firstChild) {
  container.appendChild(temp.firstChild);
}

// DocumentFragment approach
const fragment = document.createDocumentFragment();
const temp = document.createElement('div');
temp.innerHTML = generateLargeHTML();
while (temp.firstChild) {
  fragment.appendChild(temp.firstChild);
}
container.appendChild(fragment);
```

