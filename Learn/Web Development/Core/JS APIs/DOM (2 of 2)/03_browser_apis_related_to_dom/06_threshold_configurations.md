## Threshold Configurations


### Single Threshold

```javascript
const observer = new IntersectionObserver(callback, {
    threshold: 0.5  // Trigger when 50% visible
});
```

Callback fires twice:

1. When visibility crosses 50% (increasing)
2. When visibility crosses 50% (decreasing)

### Multiple Thresholds

```javascript
const observer = new IntersectionObserver(callback, {
    threshold: [0, 0.25, 0.5, 0.75, 1.0]
});
```

Callback fires at each threshold crossing. Enables granular visibility tracking:

```javascript
function callback(entries) {
    entries.forEach(entry => {
        const percent = Math.round(entry.intersectionRatio * 100);
        console.log(`Element ${percent}% visible`);
    });
}
```

### Threshold Array Generation

```javascript
function buildThresholdArray(steps = 20) {
    const thresholds = [];
    for (let i = 0; i <= steps; i++) {
        thresholds.push(i / steps);
    }
    return thresholds;
}

const observer = new IntersectionObserver(callback, {
    threshold: buildThresholdArray(100)  // 101 thresholds: 0, 0.01, 0.02...1.0
});
```

