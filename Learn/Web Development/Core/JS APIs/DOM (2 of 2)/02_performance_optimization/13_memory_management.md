## Memory Management


DocumentFragment nodes are garbage collected when no longer referenced:

```javascript
function createAndInsert() {
  const fragment = document.createDocumentFragment();
  
  for (let i = 0; i < 1000; i++) {
    fragment.appendChild(document.createElement('div'));
  }
  
  container.appendChild(fragment);
  // fragment is now empty and eligible for GC
}
```

