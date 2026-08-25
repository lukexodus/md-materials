## Custom Events via Broadcast


Broadcast enables application-specific custom events for real-time coordination and ephemeral state sharing between clients without database involvement.

**Key points:**

- Events defined by arbitrary string identifiers
- Payload can be any JSON-serializable data
- No server-side validation or processing of event structure
- Multiple event types can coexist on single channel
- Event handlers registered per event type
- Useful for coordinating UI state, temporary interactions, and peer-to-peer communication

**Example:** Multi-event collaboration system

```javascript
const docChannel = supabase
  .channel('document-123')
  .on('broadcast', { event: 'text-insert' }, ({ payload }) => {
    insertTextAtPosition(payload.position, payload.text, payload.userId)
  })
  .on('broadcast', { event: 'text-delete' }, ({ payload }) => {
    deleteTextRange(payload.start, payload.end, payload.userId)
  })
  .on('broadcast', { event: 'format-apply' }, ({ payload }) => {
    applyFormatting(payload.range, payload.format, payload.userId)
  })
  .on('broadcast', { event: 'selection-change' }, ({ payload }) => {
    showUserSelection(payload.userId, payload.start, payload.end)
  })
  .on('broadcast', { event: 'comment-add' }, ({ payload }) => {
    addCommentMarker(payload.position, payload.commentId, payload.userId)
  })
  .subscribe()

// Sending different event types
function insertText(pos, text) {
  docChannel.send({
    type: 'broadcast',
    event: 'text-insert',
    payload: {
      position: pos,
      text: text,
      userId: currentUser.id,
      timestamp: Date.now()
    }
  })
}

function addComment(pos, comment) {
  docChannel.send({
    type: 'broadcast',
    event: 'comment-add',
    payload: {
      position: pos,
      commentId: generateId(),
      userId: currentUser.id,
      text: comment,
      timestamp: Date.now()
    }
  })
}
```

**Example:** Game state synchronization

```javascript
const gameChannel = supabase
  .channel('game-session-456')
  .on('broadcast', { event: 'player-move' }, ({ payload }) => {
  updatePlayerPosition(payload.playerId, payload.x, payload.y, payload.direction)
  })
  .on('broadcast', { event: 'player-action' }, ({ payload }) => {
    executePlayerAction(payload.playerId, payload.action, payload.target)
  })
  .on('broadcast', { event: 'game-event' }, ({ payload }) => {
    handleGameEvent(payload.eventType, payload.data)
  })
  .on('broadcast', { event: 'chat-message' }, ({ payload }) => {
    displayChatMessage(payload.playerId, payload.message)
  })
  .subscribe()

// Game loop sending player position
setInterval(() => {
  if (playerHasMoved) {
    gameChannel.send({
      type: 'broadcast',
      event: 'player-move',
      payload: {
        playerId: localPlayer.id,
        x: localPlayer.x,
        y: localPlayer.y,
        direction: localPlayer.direction,
        velocity: localPlayer.velocity
      }
    })
    playerHasMoved = false
  }
}, 50) // 20 updates per second

// Player performs action
function performAction(actionType, target) {
  gameChannel.send({
    type: 'broadcast',
    event: 'player-action',
    payload: {
      playerId: localPlayer.id,
      action: actionType,
      target: target,
      timestamp: Date.now()
    }
  })
}
```

**Example:** Drawing application with tool events
```javascript
const canvasChannel = supabase
  .channel('canvas-789', {
    config: {
      broadcast: { self: false }
    }
  })
  .on('broadcast', { event: 'draw-start' }, ({ payload }) => {
    startRemoteDrawing(payload.userId, payload.x, payload.y, payload.tool)
  })
  .on('broadcast', { event: 'draw-move' }, ({ payload }) => {
    continueRemoteDrawing(payload.userId, payload.x, payload.y)
  })
  .on('broadcast', { event: 'draw-end' }, ({ payload }) => {
    endRemoteDrawing(payload.userId)
  })
  .on('broadcast', { event: 'tool-change' }, ({ payload }) => {
    updateUserTool(payload.userId, payload.tool, payload.color, payload.size)
  })
  .on('broadcast', { event: 'object-add' }, ({ payload }) => {
    addObjectToCanvas(payload.objectType, payload.properties)
  })
  .on('broadcast', { event: 'object-transform' }, ({ payload }) => {
    transformObject(payload.objectId, payload.transform)
  })
  .subscribe()

let isDrawing = false
let currentPath = []

canvas.addEventListener('mousedown', (e) => {
  isDrawing = true
  currentPath = [{ x: e.clientX, y: e.clientY }]
  
  canvasChannel.send({
    type: 'broadcast',
    event: 'draw-start',
    payload: {
      userId: currentUser.id,
      x: e.clientX,
      y: e.clientY,
      tool: currentTool,
      color: currentColor,
      size: brushSize
    }
  })
})

canvas.addEventListener('mousemove', (e) => {
  if (!isDrawing) return
  
  currentPath.push({ x: e.clientX, y: e.clientY })
  
  canvasChannel.send({
    type: 'broadcast',
    event: 'draw-move',
    payload: {
      userId: currentUser.id,
      x: e.clientX,
      y: e.clientY
    }
  })
})

canvas.addEventListener('mouseup', () => {
  if (!isDrawing) return
  isDrawing = false
  
  canvasChannel.send({
    type: 'broadcast',
    event: 'draw-end',
    payload: {
      userId: currentUser.id,
      path: currentPath
    }
  })
})
```

**Example:** Form collaboration with field locking
```javascript
const formChannel = supabase
  .channel('form-edit-101')
  .on('broadcast', { event: 'field-focus' }, ({ payload }) => {
    lockField(payload.fieldId, payload.userId, payload.username)
  })
  .on('broadcast', { event: 'field-blur' }, ({ payload }) => {
    unlockField(payload.fieldId, payload.userId)
  })
  .on('broadcast', { event: 'field-change' }, ({ payload }) => {
    updateFieldPreview(payload.fieldId, payload.value, payload.userId)
  })
  .on('broadcast', { event: 'validation-error' }, ({ payload }) => {
    showFieldError(payload.fieldId, payload.error)
  })
  .subscribe()

// Notify others when focusing on a field
document.querySelectorAll('input, textarea, select').forEach(field => {
  field.addEventListener('focus', () => {
    formChannel.send({
      type: 'broadcast',
      event: 'field-focus',
      payload: {
        fieldId: field.id,
        userId: currentUser.id,
        username: currentUser.name
      }
    })
  })
  
  field.addEventListener('blur', () => {
    formChannel.send({
      type: 'broadcast',
      event: 'field-blur',
      payload: {
        fieldId: field.id,
        userId: currentUser.id
      }
    })
  })
  
  field.addEventListener('input', throttle(() => {
    formChannel.send({
      type: 'broadcast',
      event: 'field-change',
      payload: {
        fieldId: field.id,
        value: field.value,
        userId: currentUser.id
      }
    })
  }, 500))
})
```

**Example:** Notification system with custom priorities
```javascript
const notificationChannel = supabase
  .channel('app-notifications')
  .on('broadcast', { event: 'notification' }, ({ payload }) => {
    switch(payload.priority) {
      case 'critical':
        showCriticalAlert(payload.title, payload.message)
        playAlertSound()
        break
      case 'high':
        showNotificationToast(payload.title, payload.message, 'warning')
        break
      case 'normal':
        showNotificationToast(payload.title, payload.message, 'info')
        break
      case 'low':
        addToNotificationList(payload)
        break
    }
  })
  .on('broadcast', { event: 'notification-dismiss' }, ({ payload }) => {
    dismissNotification(payload.notificationId)
  })
  .on('broadcast', { event: 'notification-read' }, ({ payload }) => {
    markNotificationRead(payload.notificationId)
  })
  .subscribe()

// Send notification to all users
function broadcastNotification(title, message, priority = 'normal') {
  notificationChannel.send({
    type: 'broadcast',
    event: 'notification',
    payload: {
      id: generateId(),
      title: title,
      message: message,
      priority: priority,
      timestamp: Date.now(),
      senderId: currentUser.id
    }
  })
}
```

