## Cleanup in Navigation Context


### Page Navigation Abort

```javascript
// Vanilla JS
let currentFetch;

document.querySelectorAll('a').forEach(link => {
  link.addEventListener('click', () => {
    if (currentFetch) {
      currentFetch.abort();
    }
  });
});

function navigateAndFetch(url) {
  currentFetch = new AbortController();
  
  return fetch(url, { signal: currentFetch.signal })
    .then(res => res.json())
    .catch(err => {
      if (err.name !== 'AbortError') {
        throw err;
      }
    });
}
```

### Single Page Application Pattern

```javascript
// Router-based cleanup
class Router {
  constructor() {
    this.currentController = null;
  }
  
  async navigate(route) {
    // Abort previous route's requests
    if (this.currentController) {
      this.currentController.abort();
    }
    
    this.currentController = new AbortController();
    
    try {
      const data = await fetch(`/api${route}`, {
        signal: this.currentController.signal
      });
      
      this.render(await data.json());
    } catch (err) {
      if (err.name !== 'AbortError') {
        this.renderError(err);
      }
    }
  }
}
```

