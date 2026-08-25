## **Usage in Renderer Process**


After setting up the preload script, you can use it in your renderer:

```javascript
// Access platform info
console.log(window.electron.platform)

// Use IPC
window.electron.invoke('some-channel', data)
  .then(result => console.log(result))

// Listen to events
window.electron.on('channel-name', (event, data) => {
  console.log(data)
})
```

