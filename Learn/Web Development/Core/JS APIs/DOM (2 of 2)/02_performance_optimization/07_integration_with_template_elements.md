## Integration with Template Elements


Combine with `<template>` for declarative fragment creation:

```javascript
const template = document.getElementById('row-template');
const fragment = document.createDocumentFragment();

data.forEach(item => {
  const clone = template.content.cloneNode(true);
  clone.querySelector('.name').textContent = item.name;
  clone.querySelector('.value').textContent = item.value;
  fragment.appendChild(clone);
});

table.appendChild(fragment);
```

