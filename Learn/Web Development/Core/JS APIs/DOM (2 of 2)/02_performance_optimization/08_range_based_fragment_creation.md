## Range-Based Fragment Creation


Use Range API for efficient fragment creation from HTML strings:

```javascript
function createFragmentFromHTML(htmlString) {
  const range = document.createRange();
  range.selectNode(document.body);
  return range.createContextualFragment(htmlString);
}

const fragment = createFragmentFromHTML(`
  <div class="item">Item 1</div>
  <div class="item">Item 2</div>
  <div class="item">Item 3</div>
`);

container.appendChild(fragment);
```

