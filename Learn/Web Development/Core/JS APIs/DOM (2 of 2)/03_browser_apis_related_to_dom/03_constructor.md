## Constructor


```javascript
const observer = new IntersectionObserver(callback, options);
```

### Callback Function

The callback receives two parameters:

```javascript
function callback(entries, observer) {
    entries.forEach(entry => {
        // Handle each intersection change
    });
}
```

- **entries**: Array of `IntersectionObserverEntry` objects
- **observer**: The IntersectionObserver instance that invoked the callback

### Options Object

```javascript
const options = {
    root: null,              // Viewport or ancestor element
    rootMargin: '0px',       // Margin around root
    threshold: 0             // Single number or array
};
```

**root**: The element used as the viewport for checking visibility. Must be an ancestor of the target. Defaults to browser viewport if `null`.

**rootMargin**: Grows or shrinks the root's bounding box before computing intersections. Uses CSS margin syntax (`"10px 20px 30px 40px"`). Can use percentages.

**threshold**: Single number or array of numbers between 0.0 and 1.0, indicating at what percentage of the target's visibility the callback should execute.

