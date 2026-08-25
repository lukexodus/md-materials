## Renderer Script


```javascript
// renderer.js - Renderer Process
const messagesDiv = document.getElementById('messages');

function addMessage(text) {
  const msgDiv = document.createElement('div');
  msgDiv.className = 'message';
  msgDiv.textContent = `${new Date().toLocaleTimeString()}: ${text}`;
  messagesDiv.appendChild(msgDiv);
}

// Use invoke for request-response pattern
document.getElementById('pingBtn').addEventListener('click', async () => {
  addMessage('Renderer: Sending ping...');
  
  try {
    const response = await window.electronAPI.sendPing('Hello from renderer!');
    addMessage(`Renderer received: ${response}`);
  } catch (error) {
    addMessage(`Error: ${error.message}`);
  }
});

// Use send for one-way async messages
document.getElementById('asyncBtn').addEventListener('click', () => {
  addMessage('Renderer: Sending async message...');
  window.electronAPI.sendAsync('Async hello from renderer!');
});

// Listen for replies from main process
window.electronAPI.onAsyncReply((message) => {
  addMessage(`Async reply received: ${message}`);
});

addMessage('Renderer process ready!');
```

