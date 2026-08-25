## Realtime Concepts and Use Cases


Realtime operates through persistent WebSocket connections that allow servers to push updates to clients without polling. The system consists of three primary features: database change streaming (Postgres Changes), custom message broadcasting (Broadcast), and user presence tracking (Presence).

**Key points:**

- WebSocket connections maintain persistent bidirectional channels between client and server
- Single connection can handle multiple subscriptions to different channels
- Messages delivered with minimal latency (typically under 100ms)
- Automatic reconnection handling with exponential backoff
- Connection state managed by client library
- Supports both public and authenticated channels

**Common use cases:**

- Collaborative applications (document editing, whiteboards, project management)
- Chat and messaging systems
- Live dashboards and analytics
- Multiplayer games and interactive experiences
- Notification systems and activity feeds
- Live commenting and reactions
- Real-time data synchronization across devices
- Auction and bidding platforms
- Live sports scores and trading platforms
- Customer support chat systems

**Example:** Basic channel subscription

```javascript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  'https://your-project.supabase.co',
  'your-anon-key'
)

const channel = supabase
  .channel('custom-channel-name')
  .on('postgres_changes', 
    { event: '*', schema: 'public', table: 'messages' },
    (payload) => {
      console.log('Change received!', payload)
    }
  )
  .subscribe()
```

The architecture involves clients connecting to Realtime servers, which maintain subscriptions and forward relevant events. Database changes are captured via Postgres logical replication, while Broadcast and Presence events are handled directly by the Realtime server.

