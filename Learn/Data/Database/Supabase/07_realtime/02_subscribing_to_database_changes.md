## Subscribing to Database Changes


Postgres Changes allow clients to listen for INSERT, UPDATE, DELETE, or all changes on specific tables. Changes are captured using PostgreSQL's logical replication feature and streamed through the Realtime server.

**Key points:**

- Requires Realtime replication enabled on table (via Supabase dashboard or SQL)
- Changes published after transaction commit, not during
- Can filter by specific columns or row values
- Respects Row Level Security policies for authenticated users
- Payload includes old and new row data for updates
- Event types: INSERT, UPDATE, DELETE, or wildcard '*'
- Schema filtering limits subscriptions to specific schemas

**Example:** Listening to all changes on a table

```javascript
const channel = supabase
  .channel('db-changes')
  .on('postgres_changes',
    { event: '*', schema: 'public', table: 'todos' },
    (payload) => {
      console.log('Change detected:', payload)
      // payload.eventType: 'INSERT' | 'UPDATE' | 'DELETE'
      // payload.new: new row data (for INSERT and UPDATE)
      // payload.old: old row data (for UPDATE and DELETE)
      // payload.table: table name
      // payload.schema: schema name
      // payload.commit_timestamp: when change was committed
    }
  )
  .subscribe()
```

**Example:** Listening to specific event types

```javascript
// Only INSERTs
const insertChannel = supabase
  .channel('inserts-only')
  .on('postgres_changes',
    { event: 'INSERT', schema: 'public', table: 'messages' },
    (payload) => {
      console.log('New message:', payload.new)
    }
  )
  .subscribe()

// Only UPDATEs
const updateChannel = supabase
  .channel('updates-only')
  .on('postgres_changes',
    { event: 'UPDATE', schema: 'public', table: 'tasks' },
    (payload) => {
      console.log('Updated from:', payload.old)
      console.log('Updated to:', payload.new)
    }
  )
  .subscribe()

// Only DELETEs
const deleteChannel = supabase
  .channel('deletes-only')
  .on('postgres_changes',
    { event: 'DELETE', schema: 'public', table: 'users' },
    (payload) => {
      console.log('Deleted user:', payload.old)
    }
  )
  .subscribe()
```

**Example:** Multiple subscriptions on single channel

```javascript
const channel = supabase
  .channel('multi-table')
  .on('postgres_changes',
    { event: 'INSERT', schema: 'public', table: 'messages' },
    handleNewMessage
  )
  .on('postgres_changes',
    { event: 'INSERT', schema: 'public', table: 'notifications' },
    handleNewNotification
  )
  .on('postgres_changes',
    { event: 'UPDATE', schema: 'public', table: 'users' },
    handleUserUpdate
  )
  .subscribe()
```

**Enabling replication on a table (SQL):**

```sql
-- Enable replication for a table
ALTER TABLE public.todos REPLICA IDENTITY FULL;

-- Publish table changes to Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE public.todos;
```

[Note: REPLICA IDENTITY FULL required to receive old row data on UPDATE and DELETE events. Default REPLICA IDENTITY DEFAULT only includes primary key values.]

