## Batch Operations Pattern


Combine with requestAnimationFrame for optimal rendering:

```javascript
function batchInsert(items, container, batchSize = 50) {
  let index = 0;
  
  function processBatch() {
    const fragment = document.createDocumentFragment();
    const end = Math.min(index + batchSize, items.length);
    
    for (; index < end; index++) {
      const element = createElementFromItem(items[index]);
      fragment.appendChild(element);
    }
    
    container.appendChild(fragment);
    
    if (index < items.length) {
      requestAnimationFrame(processBatch);
    }
  }
  
  processBatch();
}
```

