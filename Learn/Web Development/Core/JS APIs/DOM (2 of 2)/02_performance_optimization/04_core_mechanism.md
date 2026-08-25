## Core Mechanism


DocumentFragment serves as a lightweight container that holds DOM nodes outside the main document tree. When appended to the DOM, only its children are inserted while the fragment itself remains empty and reusable. This eliminates the reflow and repaint costs associated with multiple individual insertions.

```javascript
const fragment = document.createDocumentFragment();

// Build structure in memory
for (let i = 0; i < 1000; i++) {
  const div = document.createElement('div');
  div.textContent = `Item ${i}`;
  fragment.appendChild(div);
}

// Single DOM insertion
container.appendChild(fragment);
```

