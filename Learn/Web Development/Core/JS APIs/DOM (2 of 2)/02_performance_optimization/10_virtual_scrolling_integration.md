## Virtual Scrolling Integration


DocumentFragment works efficiently with virtual scrolling implementations:

```javascript
function renderVisibleItems(startIndex, endIndex, data) {
  const fragment = document.createDocumentFragment();
  
  for (let i = startIndex; i < endIndex; i++) {
    const item = document.createElement('div');
    item.className = 'virtual-item';
    item.style.transform = `translateY(${i * itemHeight}px)`;
    item.textContent = data[i];
    fragment.appendChild(item);
  }
  
  viewport.innerHTML = ''; // Clear previous items
  viewport.appendChild(fragment);
}
```

