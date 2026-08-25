## Practical Use Cases


### Lazy Loading Images

```javascript
const imageObserver = new IntersectionObserver((entries, observer) => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            const img = entry.target;
            img.src = img.dataset.src;
            img.classList.remove('lazy');
            observer.unobserve(img);
        }
    });
}, {
    rootMargin: '50px'  // Preload 50px before visible
});

document.querySelectorAll('img.lazy').forEach(img => {
    imageObserver.observe(img);
});
```

HTML structure:

```html
<img class="lazy" data-src="image.jpg" alt="Description">
```

### Infinite Scroll

```javascript
const sentinel = document.getElementById('sentinel');

const infiniteObserver = new IntersectionObserver(entries => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            loadMoreContent();
        }
    });
}, {
    rootMargin: '200px'  // Trigger before reaching bottom
});

infiniteObserver.observe(sentinel);

async function loadMoreContent() {
    const newItems = await fetchItems();
    appendItemsToDOM(newItems);
}
```

### Scroll Animations

```javascript
const animationObserver = new IntersectionObserver(entries => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            entry.target.classList.add('animate-in');
        } else {
            entry.target.classList.remove('animate-in');
        }
    });
}, {
    threshold: 0.1
});

document.querySelectorAll('.animate-on-scroll').forEach(el => {
    animationObserver.observe(el);
});
```

### Analytics and Impression Tracking

```javascript
const impressionObserver = new IntersectionObserver(entries => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            const adId = entry.target.dataset.adId;
            trackImpression(adId);
            impressionObserver.unobserve(entry.target);
        }
    });
}, {
    threshold: 0.5,  // At least 50% visible
    rootMargin: '0px'
});

document.querySelectorAll('.ad-unit').forEach(ad => {
    impressionObserver.observe(ad);
});
```

### Visibility Duration Tracking

```javascript
const visibilityTimers = new WeakMap();

const durationObserver = new IntersectionObserver(entries => {
    entries.forEach(entry => {
        if (entry.isIntersecting) {
            // Start timing
            visibilityTimers.set(entry.target, Date.now());
        } else {
            // Calculate duration
            const startTime = visibilityTimers.get(entry.target);
            if (startTime) {
                const duration = Date.now() - startTime;
                console.log(`Visible for ${duration}ms`);
                visibilityTimers.delete(entry.target);
            }
        }
    });
});
```

### Sticky Header Detection

```javascript
const header = document.querySelector('header');
const sentinel = document.createElement('div');
sentinel.style.height = '1px';
header.parentElement.insertBefore(sentinel, header);

const stickyObserver = new IntersectionObserver(entries => {
    entries.forEach(entry => {
        header.classList.toggle('stuck', !entry.isIntersecting);
    });
}, {
    threshold: 1.0  // Fully visible or not
});

stickyObserver.observe(sentinel);
```

### Pausing Video Outside Viewport

```javascript
const videoObserver = new IntersectionObserver(entries => {
    entries.forEach(entry => {
        const video = entry.target;
        if (entry.isIntersecting) {
            video.play();
        } else {
            video.pause();
        }
    });
}, {
    threshold: 0.5
});

document.querySelectorAll('video[data-autoplay]').forEach(video => {
    videoObserver.observe(video);
});
```

