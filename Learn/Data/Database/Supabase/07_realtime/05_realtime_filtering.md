## Realtime Filtering


Filtering limits which database changes are delivered to clients based on column values, reducing unnecessary data transfer and processing.

**Key points:**

- Filters applied server-side before message delivery
- Supports equality filters on specific columns
- Multiple filters can be combined (AND logic)
- Reduces bandwidth and client-side processing
- Filter values must match exactly (no wildcards or ranges)
- Filters work with RLS policies (both must pass)

**Example:** Filter by specific column value

```javascript
// Only receive messages for specific room
const roomChannel = supabase
  .channel('messages-room-5')
  .on('postgres_changes',
    { 
      event: 'INSERT', 
      schema: 'public', 
      table: 'messages',
      filter: 'room_id=eq.5'
    },
    (payload) => {
      displayMessage(payload.new)
    }
  )
  .subscribe()
```

**Example:** Multiple filters

```javascript
// Only receive high-priority notifications for current user
const notificationChannel = supabase
  .channel('my-urgent-notifications')
  .on('postgres_changes',
    { 
      event: 'INSERT', 
      schema: 'public', 
      table: 'notifications',
      filter: `user_id=eq.${currentUser.id}`
    },
    (payload) => {
      if (payload.new.priority === 'high') {
        showUrgentNotification(payload.new)
      }
    }
  )
  .subscribe()
```

**Example:** User-specific updates

```javascript
// Listen to changes on own profile only
const profileChannel = supabase
  .channel('my-profile-updates')
  .on('postgres_changes',
    { 
      event: 'UPDATE', 
      schema: 'public', 
      table: 'profiles',
      filter: `id=eq.${currentUser.id}`
    },
    (payload) => {
      updateLocalProfile(payload.new)
    }
  )
  .subscribe()
```

**Example:** Status-specific monitoring

```javascript
// Monitor only pending orders
const ordersChannel = supabase
  .channel('pending-orders')
  .on('postgres_changes',
    { 
      event: '*', 
      schema: 'public', 
      table: 'orders',
      filter: 'status=eq.pending'
    },
    (payload) => {
      if (payload.eventType === 'INSERT') {
        addOrderToQueue(payload.new)
      } else if (payload.eventType === 'UPDATE') {
        // Order status changed, may need to remove from queue
        if (payload.new.status !== 'pending') {
          removeOrderFromQueue(payload.old.id)
        }
      }
    }
  )
  .subscribe()
```

[Note: Filters use PostgREST filter syntax. Supported operators include eq (equals), neq (not equals), gt (greater than), lt (less than), gte (greater than or equal), lte (less than or equal), in (in list), and is (is null/not null).]

