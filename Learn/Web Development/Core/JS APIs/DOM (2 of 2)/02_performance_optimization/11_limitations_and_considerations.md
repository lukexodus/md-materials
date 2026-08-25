## Limitations and Considerations


### No Document Context

Nodes in a fragment lack document context until inserted. Properties like `offsetWidth` and computed styles return zero:

```javascript
const fragment = document.createDocumentFragment();
const div = document.createElement('div');
fragment.appendChild(div);

console.log(div.offsetWidth); // 0 - no layout context

container.appendChild(fragment);
console.log(div.offsetWidth); // Actual computed width
```

### querySelector Scope

DocumentFragment supports querySelector but only within its immediate children:

```javascript
const fragment = document.createDocumentFragment();
const parent = document.createElement('div');
const child = document.createElement('span');
child.id = 'target';
parent.appendChild(child);
fragment.appendChild(parent);

fragment.querySelector('#target'); // Works
```

### Single-Use Nature After Append

After appending, the fragment empties automatically:

```javascript
const fragment = document.createDocumentFragment();
fragment.appendChild(document.createElement('div'));

container1.appendChild(fragment);
console.log(fragment.childNodes.length); // 0

// Must rebuild for subsequent insertions
container2.appendChild(fragment); // Inserts nothing
```

