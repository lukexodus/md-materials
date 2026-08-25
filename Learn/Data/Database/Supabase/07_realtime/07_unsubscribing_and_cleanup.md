## Unsubscribing and Cleanup


Proper cleanup of subscriptions prevents memory leaks and reduces server load when channels are no longer needed.

**Key points:**

- Unsubscribing closes WebSocket channel and stops message delivery
- Client library automatically handles reconnection cancellation
- Multiple callbacks on same channel all removed on unsubscribe
- Presence state automatically cleared on unsubscribe
- Cleanup should occur on component unmount or navigation
- Unsubscribed channels can be resubscribed later

**Example:** Basic unsubscribe

```javascript
const channel = supabase
  .channel('temp-channel')
  .on('postgres_changes', { event: '*', schema: 'public', table: 'data' }, handleChange)
  .subscribe()

// Later, when no longer needed
await supabase.removeChannel(channel)
```

**Example:** React component cleanup

```javascript
import { useEffect, useState } from 'react'
import { supabase } from './supabaseClient'

function MessagesComponent({ roomId }) {
  const [messages, setMessages] = useState([])

  useEffect(() => {
    const channel = supabase
      .channel(`room-${roomId}`)
      .on('postgres_changes',
        { 
          event: 'INSERT', 
          schema: 'public', 
          table: 'messages',
          filter: `room_id=eq.${roomId}`
        },
        (payload) => {
          setMessages(prev => [...prev, payload.new])
        }
      )
      .subscribe()

    // Cleanup function
    return () => {
      supabase.removeChannel(channel)
    }
  }, [roomId]) // Re-subscribe when roomId changes

  return (
    <div>
      {messages.map(msg => <div key={msg.id}>{msg.text}</div>)}
    </div>
  )
}
```

**Example:** Multiple channel cleanup

```javascript
const channels = []

function subscribeToRooms(roomIds) {
  roomIds.forEach(roomId => {
    const channel = supabase
      .channel(`room-${roomId}`)
      .on('postgres_changes',
        { event: 'INSERT', schema: 'public', table: 'messages', filter: `room_id=eq.${roomId}` },
        handleMessage
      )
      .subscribe()
    
    channels.push(channel)
  })
}

function cleanupAllChannels() {
  channels.forEach(channel => {
    supabase.removeChannel(channel)
  })
  channels.length = 0 // Clear array
}

// On app shutdown or navigation
window.addEventListener('beforeunload', cleanupAllChannels)
```

**Example:** Conditional cleanup based on user action

```javascript
let activeChannel = null

function joinRoom(roomId) {
  // Cleanup previous room subscription if exists
  if (activeChannel) {
    supabase.removeChannel(activeChannel)
  }

  // Subscribe to new room
  activeChannel = supabase
    .channel(`room-${roomId}`)
    .on('postgres_changes',
      { event: '*', schema: 'public', table: 'messages', filter: `room_id=eq.${roomId}` },
      handleMessage
    )
    .on('presence', { event: 'sync' }, updateUserList)
    .subscribe(async (status) => {
      if (status === 'SUBSCRIBED') {
        await activeChannel.track({
          user_id: currentUser.id,
          username: currentUser.name
        })
      }
    })
}

function leaveRoom() {
  if (activeChannel) {
    supabase.removeChannel(activeChannel)
    activeChannel = null
  }
}
```

**Example:** Removing all channels

```javascript
// Remove all active channels at once
await supabase.removeAllChannels()
```

