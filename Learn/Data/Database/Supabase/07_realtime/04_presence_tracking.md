## Presence Tracking


Presence tracks which users are currently connected to a channel, automatically handling joins, leaves, and synchronization of user state across all connected clients.

**Key points:**

- Automatically tracks user connections and disconnections
- Each client can share arbitrary state (status, metadata, etc.)
- State synchronized across all channel subscribers
- Heartbeat mechanism detects disconnections
- Updates trigger callbacks on all connected clients
- Handles network interruptions and reconnections
- Each client identified by unique key within channel

**Example:** Basic presence setup

```javascript
const presenceChannel = supabase
  .channel('room-presence')
  .on('presence', { event: 'sync' }, () => {
    const state = presenceChannel.presenceState()
    console.log('Online users:', state)
  })
  .on('presence', { event: 'join' }, ({ key, newPresences }) => {
    console.log('User joined:', key, newPresences)
  })
  .on('presence', { event: 'leave' }, ({ key, leftPresences }) => {
    console.log('User left:', key, leftPresences)
  })
  .subscribe(async (status) => {
    if (status === 'SUBSCRIBED') {
      await presenceChannel.track({
        user_id: currentUser.id,
        username: currentUser.name,
        online_at: new Date().toISOString()
      })
    }
  })
```

**Example:** Live user list with avatars

```javascript
const userListChannel = supabase
  .channel('online-users')
  .on('presence', { event: 'sync' }, () => {
    const state = userListChannel.presenceState()
    
    // Extract all users from presence state
    const users = Object.keys(state).flatMap(key => 
      state[key].map(presence => presence)
    )
    
    renderUserList(users)
  })
  .subscribe(async (status) => {
    if (status === 'SUBSCRIBED') {
      await userListChannel.track({
        user_id: currentUser.id,
        username: currentUser.name,
        avatar_url: currentUser.avatar,
        status: 'active'
      })
    }
  })

function renderUserList(users) {
  const container = document.getElementById('user-list')
  container.innerHTML = users.map(user => `
    <div class="user">
      <img src="${user.avatar_url}" alt="${user.username}">
      <span>${user.username}</span>
      <span class="status ${user.status}">${user.status}</span>
    </div>
  `).join('')
}
```

**Example:** Updating presence state

```javascript
// Update user status
async function setUserStatus(status) {
  await presenceChannel.track({
    user_id: currentUser.id,
    username: currentUser.name,
    status: status, // 'active', 'away', 'busy'
    last_activity: new Date().toISOString()
  })
}

// Update on user activity
let activityTimer
document.addEventListener('mousemove', () => {
  setUserStatus('active')
  clearTimeout(activityTimer)
  activityTimer = setTimeout(() => {
    setUserStatus('away')
  }, 300000) // 5 minutes
})
```

**Example:** Collaborative editing with active editors

```javascript
const editorChannel = supabase
  .channel('document-editors')
  .on('presence', { event: 'sync' }, () => {
    const editors = editorChannel.presenceState()
    updateEditorList(editors)
  })
  .subscribe(async (status) => {
    if (status === 'SUBSCRIBED') {
      await editorChannel.track({
        user_id: currentUser.id,
        username: currentUser.name,
        cursor_position: 0,
        selected_text: null,
        color: generateUserColor(currentUser.id)
      })
    }
  })

// Update cursor position in real-time
editor.on('cursorActivity', async () => {
  const cursor = editor.getCursor()
  await editorChannel.track({
    user_id: currentUser.id,
    username: currentUser.name,
    cursor_position: cursor.line * 1000 + cursor.ch,
    color: currentUserColor
  })
})
```

**Example:** Gaming lobby presence

```javascript
const lobbyChannel = supabase
  .channel('game-lobby-1')
  .on('presence', { event: 'sync' }, () => {
    const players = lobbyChannel.presenceState()
    const playerCount = Object.keys(players).length
    updateLobbyUI(players, playerCount)
  })
  .on('presence', { event: 'join' }, ({ newPresences }) => {
    showNotification(`${newPresences[0].username} joined the lobby`)
  })
  .on('presence', { event: 'leave' }, ({ leftPresences }) => {
    showNotification(`${leftPresences[0].username} left the lobby`)
  })
  .subscribe(async (status) => {
    if (status === 'SUBSCRIBED') {
      await lobbyChannel.track({
        user_id: currentUser.id,
        username: currentUser.name,
        ready: false,
        team: null,
        character: null
      })
    }
  })

// Update player ready state
async function toggleReady() {
  const currentState = lobbyChannel.presenceState()[currentUser.id][0]
  await lobbyChannel.track({
    ...currentState,
    ready: !currentState.ready
  })
}
```

