## Performance and Scaling Considerations


Realtime connections consume server resources and require careful management for applications with many concurrent users or high message volumes.

**Key points:**

- Each WebSocket connection maintained by Realtime server
- Connection limit depends on plan (Free: 200 concurrent, Pro: 500+, Enterprise: custom)
- Message rate limits prevent abuse (varies by plan)
- Database change events can create load on Postgres replication
- Throttling broadcast messages reduces bandwidth consumption
- Channel names should be specific to avoid unnecessary subscriptions
- Multiplexing multiple subscriptions over single connection improves efficiency
- Heartbeat packets maintain connection health

**Connection optimization strategies:**

- Reuse single channel for multiple related subscriptions
- Unsubscribe from channels when no longer needed
- Use filters to limit data delivered to clients
- Batch updates when possible rather than sending individual changes
- Consider throttling high-frequency events (cursor movements, etc.)
- Implement reconnection logic with exponential backoff
- Monitor connection count and usage in Supabase dashboard

**Example:** Efficient channel reuse

```javascript
// Good: Single channel with multiple subscriptions
const multiChannel = supabase
  .channel('app-updates')
  .on('postgres_changes', 
    { event: 'INSERT', schema: 'public', table: 'messages', filter: 'room_id=eq.1' },
    handleMessage
  )
  .on('broadcast', { event: 'typing' }, handleTyping)
  .on('presence', { event: 'sync' }, handlePresence)
  .subscribe()

// Less efficient: Multiple channels
const messageChannel = supabase.channel('messages').on(...).subscribe()
const typingChannel = supabase.channel('typing').on(...).subscribe()
const presenceChannel = supabase.channel('presence').on(...).subscribe()
```

**Example:** Throttling high-frequency events

```javascript
// Throttle cursor position updates
function throttle(func, delay) {
  let timeoutId
  let lastExecTime = 0
  
  return function(...args) {
    const currentTime = Date.now()
    const timeSinceLastExec = currentTime - lastExecTime
    
    if (timeSinceLastExec >= delay) {
      func.apply(this, args)
      lastExecTime = currentTime
    } else {
      clearTimeout(timeoutId)
      timeoutId = setTimeout(() => {
        func.apply(this, args)
        lastExecTime = Date.now()
      }, delay - timeSinceLastExec)
    }
  }
}

const throttledCursorUpdate = throttle((x, y) => {
  channel.send({
    type: 'broadcast',
    event: 'cursor',
    payload: { x, y, userId: currentUser.id }
  })
}, 100) // Maximum 10 updates per second

canvas.addEventListener('mousemove', (e) => {
  throttledCursorUpdate(e.clientX, e.clientY)
})
```

**Example:** Connection monitoring

```javascript
let connectionStatus = 'disconnected'
let reconnectAttempts = 0
const maxReconnectAttempts = 5

const channel = supabase
  .channel('monitored-channel')
  .on('postgres_changes', { event: '*', schema: 'public', table: 'data' }, handleChange)
  .subscribe((status, error) => {
    if (status === 'SUBSCRIBED') {
      connectionStatus = 'connected'
      reconnectAttempts = 0
      console.log('Connected to Realtime')
    } else if (status === 'CHANNEL_ERROR') {
      connectionStatus = 'error'
      console.error('Channel error:', error)
      
      if (reconnectAttempts < maxReconnectAttempts) {
        reconnectAttempts++
        const delay = Math.min(1000 * Math.pow(2, reconnectAttempts), 30000)
        console.log(`Reconnecting in ${delay}ms...`)
        setTimeout(() => {
          channel.subscribe()
        }, delay)
      }
    } else if (status === 'TIMED_OUT') {
      connectionStatus = 'timeout'
      console.warn('Connection timed out')
    } else if (status === 'CLOSED') {
      connectionStatus = 'closed'
      console.log('Connection closed')
    }
  })
```

**Scaling considerations:**

- [Inference: Database replication slots consume resources; enabling replication on many tables may impact performance]
- Message throughput limited by network bandwidth and Realtime server capacity
- Large payloads increase latency and bandwidth usage
- Consider message queuing systems for extremely high volumes
- Geographic distribution of users affects latency
- Horizontal scaling available on Enterprise plans

