## Broadcast Channels


Broadcast allows sending ephemeral messages between connected clients without database persistence. Messages are delivered to all clients subscribed to the same channel topic.

**Key points:**

- Messages not stored in database (ephemeral)
- Low-latency delivery directly through WebSocket
- Supports arbitrary JSON payloads
- Can broadcast to specific channel or all subscribers
- Self-receive option determines if sender receives own messages
- Useful for temporary state and coordination
- No message ordering guarantees across clients [Inference: due to network variations]

**Example:** Basic broadcast setup

```javascript
// Client A: Sending messages
const channel = supabase
  .channel('room-1')
  .on('broadcast', { event: 'cursor-move' }, (payload) => {
    console.log('Cursor moved:', payload)
  })
  .subscribe()

// Send a broadcast message
await channel.send({
  type: 'broadcast',
  event: 'cursor-move',
  payload: { x: 100, y: 200, user: 'Alice' }
})
```

**Example:** Chat application

```javascript
const chatChannel = supabase
  .channel('chat-room-123')
  .on('broadcast', { event: 'message' }, ({ payload }) => {
    displayMessage(payload.username, payload.text, payload.timestamp)
  })
  .subscribe()

// Send chat message
async function sendMessage(text) {
  await chatChannel.send({
    type: 'broadcast',
    event: 'message',
    payload: {
      username: currentUser.name,
      text: text,
      timestamp: new Date().toISOString()
    }
  })
}
```

**Example:** Collaborative cursor tracking

```javascript
const cursorChannel = supabase
  .channel('canvas-cursors', {
    config: {
      broadcast: { self: false } // Don't receive own cursor events
    }
  })
  .on('broadcast', { event: 'cursor' }, ({ payload }) => {
    updateCursor(payload.userId, payload.x, payload.y, payload.color)
  })
  .subscribe()

// Throttled cursor position updates
let lastSent = 0
canvas.addEventListener('mousemove', (e) => {
  const now = Date.now()
  if (now - lastSent > 50) { // Throttle to 20 updates/second
    cursorChannel.send({
      type: 'broadcast',
      event: 'cursor',
      payload: {
        userId: currentUser.id,
        x: e.clientX,
        y: e.clientY,
        color: currentUser.cursorColor
      }
    })
    lastSent = now
  }
})
```

**Example:** Custom event types for different interactions

```javascript
const collaborationChannel = supabase
  .channel('document-collab')
  .on('broadcast', { event: 'selection' }, ({ payload }) => {
    highlightSelection(payload.userId, payload.start, payload.end)
  })
  .on('broadcast', { event: 'typing' }, ({ payload }) => {
    showTypingIndicator(payload.userId, payload.isTyping)
  })
  .on('broadcast', { event: 'comment' }, ({ payload }) => {
    addComment(payload.position, payload.text, payload.author)
  })
  .subscribe()
```

