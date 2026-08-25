## Response Body Cleanup


### Stream Cancellation

```javascript
const response = await fetch('/large-file');
const reader = response.body.getReader();

try {
  while (true) {
    const { done, value } = await reader.read();
    if (done) break;
    
    // Process chunk
    if (shouldCancel) {
      await reader.cancel();
      break;
    }
  }
} finally {
  reader.releaseLock();
}
```

### Blob URL Cleanup

```javascript
const response = await fetch('/image.jpg');
const blob = await response.blob();
const blobUrl = URL.createObjectURL(blob);

// Use the URL
img.src = blobUrl;

// Cleanup when done
img.onload = () => {
  URL.revokeObjectURL(blobUrl);
};

// Or in React
useEffect(() => {
  const url = URL.createObjectURL(blob);
  setImageUrl(url);
  
  return () => URL.revokeObjectURL(url);
}, [blob]);
```

