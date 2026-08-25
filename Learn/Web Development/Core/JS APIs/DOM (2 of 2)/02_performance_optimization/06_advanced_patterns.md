## Advanced Patterns


### Complex Nested Structures

Build hierarchical DOM structures efficiently:

```javascript
function createComplexStructure(data) {
  const fragment = document.createDocumentFragment();
  
  data.forEach(item => {
    const card = document.createElement('div');
    card.className = 'card';
    
    const header = document.createElement('header');
    header.textContent = item.title;
    
    const body = document.createElement('div');
    body.className = 'card-body';
    
    const list = document.createElement('ul');
    item.items.forEach(subItem => {
      const li = document.createElement('li');
      li.textContent = subItem;
      list.appendChild(li);
    });
    
    body.appendChild(list);
    card.appendChild(header);
    card.appendChild(body);
    fragment.appendChild(card);
  });
  
  return fragment;
}

container.appendChild(createComplexStructure(largeDataset));
```

### Cloning for Reuse

DocumentFragment can be cloned to create multiple identical structures:

```javascript
const template = document.createDocumentFragment();
const baseStructure = document.createElement('div');
baseStructure.className = 'template';
baseStructure.innerHTML = '<span class="label"></span><input type="text">';
template.appendChild(baseStructure);

// Clone and customize multiple times
for (let i = 0; i < 50; i++) {
  const clone = template.cloneNode(true);
  clone.querySelector('.label').textContent = `Field ${i}`;
  container.appendChild(clone);
}
```

### Event Delegation Setup

Attach event listeners before insertion to avoid traversal overhead:

```javascript
const fragment = document.createDocumentFragment();
const wrapper = document.createElement('div');
wrapper.className = 'button-group';

wrapper.addEventListener('click', (e) => {
  if (e.target.matches('button')) {
    handleButtonClick(e.target.dataset.id);
  }
});

for (let i = 0; i < 100; i++) {
  const button = document.createElement('button');
  button.dataset.id = i;
  button.textContent = `Button ${i}`;
  wrapper.appendChild(button);
}

fragment.appendChild(wrapper);
container.appendChild(fragment);
```

