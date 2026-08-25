## Event-Driven Architectures with LISTEN/NOTIFY


### Introduction to PostgreSQL LISTEN/NOTIFY

PostgreSQL's LISTEN/NOTIFY is a powerful built-in asynchronous notification system that enables real-time, event-driven architectures within database applications. This publish-subscribe mechanism allows database events to trigger actions in connected client applications without constant polling, leading to more responsive and efficient systems.

**Key Points:**

- Native implementation of the publish-subscribe pattern
- Enables real-time communication between database and applications
- Reduces overhead compared to polling-based approaches
- Built directly into PostgreSQL core functionality

### Core Components

### NOTIFY Command

The NOTIFY command broadcasts a message with an optional payload to all clients listening on a specific channel.

```sql
-- Basic notification without payload
NOTIFY channel_name;

-- Notification with a payload (PostgreSQL 9.0+)
NOTIFY channel_name, 'This is the payload message';
```

### LISTEN Command

The LISTEN command registers a client's interest in a specific notification channel.

```sql
-- Start listening on a specific channel
LISTEN channel_name;
```

### UNLISTEN Command

The UNLISTEN command unregisters a client from a notification channel.

```sql
-- Stop listening on a specific channel
UNLISTEN channel_name;

-- Stop listening on all channels
UNLISTEN *;
```

### pg_notify() Function

An alternative way to send notifications, particularly useful in PL/pgSQL functions.

```sql
-- Using pg_notify function
SELECT pg_notify('channel_name', 'Payload message');
```

### Notification Delivery

### Asynchronous Nature

Notifications are asynchronous and non-guaranteed. They're delivered when the client is idle and checking for notifications, not immediately upon generation.

### Connection Requirements

Notifications are only delivered to active database connections that are listening on the specified channel.

### Transaction Context

Notifications are only sent when the transaction that issues the NOTIFY completes successfully.

```sql
BEGIN;
INSERT INTO table_name (column1, column2) VALUES ('value1', 'value2');
NOTIFY data_changed;
COMMIT;  -- Notification is sent only after successful commit
```

### Implementation Patterns

### Basic Notification System

```sql
-- In database session 1
LISTEN data_changes;

-- In database session 2
INSERT INTO users (name, email) VALUES ('John Doe', 'john@example.com');
NOTIFY data_changes, 'users:insert:' || currval('users_id_seq');
```

### Trigger-Based Notifications

```sql
CREATE OR REPLACE FUNCTION notify_data_change() RETURNS TRIGGER AS $$
BEGIN
    -- Construct a JSON payload with information about the change
    PERFORM pg_notify(
        'data_changes',
        json_build_object(
            'table', TG_TABLE_NAME,
            'action', TG_OP,
            'id', CASE 
                   WHEN TG_OP = 'DELETE' THEN OLD.id 
                   ELSE NEW.id 
                 END
        )::text
    );
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_notify_trigger
AFTER INSERT OR UPDATE OR DELETE ON users
FOR EACH ROW EXECUTE FUNCTION notify_data_change();
```

### Function-Based Notifications

```sql
CREATE OR REPLACE FUNCTION process_order(order_id integer) RETURNS void AS $$
BEGIN
    -- Process the order
    UPDATE orders SET status = 'processed' WHERE id = order_id;
    
    -- Notify about the order processing
    PERFORM pg_notify(
        'orders_processed',
        json_build_object(
            'order_id', order_id,
            'processed_at', now()
        )::text
    );
END;
$$ LANGUAGE plpgsql;
```

### Client Implementation

### Node.js with pg Library

```javascript
const { Client } = require('pg');

const client = new Client({
  connectionString: 'postgresql://username:password@localhost:5432/database'
});

client.connect();

// Listen for notifications
client.query('LISTEN data_changes');

// Handle notifications
client.on('notification', (msg) => {
  console.log('Received notification:', msg.channel);
  console.log('Payload:', msg.payload);
  
  // Parse the payload if it's JSON
  try {
    const payload = JSON.parse(msg.payload);
    console.log('Table:', payload.table);
    console.log('Action:', payload.action);
    console.log('ID:', payload.id);
    
    // Perform appropriate action based on notification
    if (payload.table === 'users' && payload.action === 'INSERT') {
      // Refresh user list, update cache, etc.
    }
  } catch (e) {
    console.error('Error parsing payload:', e);
  }
});
```

### Python with psycopg2

```python
import select
import psycopg2
import psycopg2.extensions
import json

# Connect to PostgreSQL
conn = psycopg2.connect("dbname=database user=username password=password")
conn.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT)

# Create a cursor
cursor = conn.cursor()

# Start listening
cursor.execute("LISTEN data_changes;")

print("Waiting for notifications...")

while True:
    # Check if there's a notification to be processed
    if select.select([conn], [], [], 5) == ([], [], []):
        # Timeout
        pass
    else:
        # Get the notification
        conn.poll()
        while conn.notifies:
            notify = conn.notifies.pop()
            print(f"Channel: {notify.channel}")
            print(f"Payload: {notify.payload}")
            
            try:
                # Parse JSON payload
                payload = json.loads(notify.payload)
                print(f"Table: {payload['table']}")
                print(f"Action: {payload['action']}")
                print(f"ID: {payload['id']}")
                
                # Handle the notification
                if payload['table'] == 'users' and payload['action'] == 'INSERT':
                    # Update cache, refresh UI, etc.
                    pass
            except json.JSONDecodeError:
                print("Payload is not valid JSON")
```

### Ruby with pg Gem

```ruby
require 'pg'
require 'json'

conn = PG.connect(dbname: 'database', user: 'username', password: 'password')

# Set connection to non-blocking mode
conn.exec("LISTEN data_changes")

puts "Waiting for notifications..."

loop do
  conn.wait_for_notify do |channel, pid, payload|
    puts "Channel: #{channel}"
    puts "Process ID: #{pid}"
    puts "Payload: #{payload}"
    
    begin
      data = JSON.parse(payload)
      puts "Table: #{data['table']}"
      puts "Action: #{data['action']}"
      puts "ID: #{data['id']}"
      
      # Handle the notification
      if data['table'] == 'users' && data['action'] == 'INSERT'
        # Refresh data, update cache, etc.
      end
    rescue JSON::ParserError
      puts "Payload is not valid JSON"
    end
  end
end
```

### Advanced Usage Patterns

### Payload Size Limitations

PostgreSQL limits notification payloads to 8000 bytes. For larger data, use a reference pattern:

```sql
-- Store large data
INSERT INTO notification_data (id, data) 
VALUES (gen_random_uuid(), 'large data payload here');

-- Send only the reference
NOTIFY channel_name, 'ref:' || currval('notification_data_id_seq');
```

Client code then fetches the complete data:

```sql
-- Client retrieves the full data
SELECT data FROM notification_data WHERE id = '12345';
```

### Channel Namespacing

Organize notifications into logical groups with channel naming conventions:

```sql
-- Table-specific channels
NOTIFY users:insert, payload;
NOTIFY users:update, payload;
NOTIFY users:delete, payload;

-- Feature-specific channels
NOTIFY auth:login, payload;
NOTIFY auth:logout, payload;
```

### Notification Queuing

Since notifications are only delivered to active connections, implement a queuing system for offline clients:

```sql
CREATE TABLE notification_queue (
    id SERIAL PRIMARY KEY,
    channel TEXT NOT NULL,
    payload TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    delivered BOOLEAN DEFAULT FALSE
);

CREATE OR REPLACE FUNCTION queue_notification() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO notification_queue (channel, payload)
    VALUES (TG_ARGV[0], NEW.data::text);
    
    PERFORM pg_notify(TG_ARGV[0], NEW.id::text);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER queue_user_notifications
AFTER INSERT ON user_events
FOR EACH ROW EXECUTE FUNCTION queue_notification('user_events');
```

### Real-world Applications

### Real-time Dashboards

Keep dashboards updated in real-time without polling:

```sql
-- Trigger function to notify about metric changes
CREATE OR REPLACE FUNCTION notify_metric_update() RETURNS TRIGGER AS $$
BEGIN
    PERFORM pg_notify(
        'metrics_update',
        json_build_object(
            'metric', TG_TABLE_NAME,
            'value', NEW.value,
            'timestamp', NEW.recorded_at
        )::text
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to various metric tables
CREATE TRIGGER active_users_update
AFTER INSERT OR UPDATE ON active_users
FOR EACH ROW EXECUTE FUNCTION notify_metric_update();
```

### Chat Applications

Implement real-time chat features:

```sql
-- Store message
INSERT INTO messages (sender_id, recipient_id, content)
VALUES (1, 2, 'Hello there!');

-- Notify recipient
SELECT pg_notify(
    'user_messages:' || recipient_id,
    json_build_object(
        'message_id', currval('messages_id_seq'),
        'sender_id', sender_id,
        'content', content
    )::text
)
FROM messages
WHERE id = currval('messages_id_seq');
```

### Cache Invalidation

Invalidate application caches when data changes:

```sql
CREATE OR REPLACE FUNCTION invalidate_cache() RETURNS TRIGGER AS $$
BEGIN
    PERFORM pg_notify(
        'cache_invalidation',
        json_build_object(
            'table', TG_TABLE_NAME,
            'key', CASE 
                     WHEN TG_OP = 'DELETE' THEN OLD.id::text 
                     ELSE NEW.id::text 
                   END
        )::text
    );
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER invalidate_products_cache
AFTER INSERT OR UPDATE OR DELETE ON products
FOR EACH ROW EXECUTE FUNCTION invalidate_cache();
```

### Task Queues

Implement simple task queues for background processing:

```sql
CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    type TEXT NOT NULL,
    parameters JSONB NOT NULL,
    status TEXT DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT NOW(),
    processed_at TIMESTAMP
);

CREATE OR REPLACE FUNCTION notify_new_task() RETURNS TRIGGER AS $$
BEGIN
    PERFORM pg_notify(
        'tasks:' || NEW.type,
        json_build_object(
            'task_id', NEW.id,
            'parameters', NEW.parameters
        )::text
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER task_notification
AFTER INSERT ON tasks
FOR EACH ROW EXECUTE FUNCTION notify_new_task();
```

### Performance Considerations

**Key Points:**

- Notifications add minimal overhead to the database
- Excessive notifications can impact performance
- Each active listener consumes server resources
- Connection pooling may interfere with notification delivery
- High-frequency notifications may cause network congestion

### Keeping Connections Alive

Database connections must remain open to receive notifications. Use heartbeats to keep connections alive:

```sql
-- Server-side function for heartbeat
CREATE OR REPLACE FUNCTION heartbeat() RETURNS void AS $$
BEGIN
    PERFORM pg_notify('heartbeat', now()::text);
END;
$$ LANGUAGE plpgsql;

-- Schedule using pg_cron extension
SELECT cron.schedule('* * * * *', 'SELECT heartbeat()');
```

Client implementation:

```javascript
// Node.js heartbeat response
let lastHeartbeat = Date.now();

client.on('notification', (msg) => {
  if (msg.channel === 'heartbeat') {
    lastHeartbeat = Date.now();
    return;
  }
  
  // Process other notifications...
});

// Check connection health
setInterval(() => {
  const timeSinceHeartbeat = Date.now() - lastHeartbeat;
  if (timeSinceHeartbeat > 120000) { // 2 minutes
    console.log('No heartbeat received, reconnecting...');
    reconnectDatabase();
  }
}, 30000);
```

### Monitoring LISTEN/NOTIFY Usage

```sql
-- Check active listeners
SELECT pid, channel FROM pg_listening_channels();

-- Monitor notification frequency
CREATE TABLE notification_stats (
    channel TEXT NOT NULL,
    hour TIMESTAMP NOT NULL,
    count INTEGER DEFAULT 1,
    PRIMARY KEY (channel, hour)
);

CREATE OR REPLACE FUNCTION log_notification() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO notification_stats (channel, hour, count)
    VALUES (TG_ARGV[0], date_trunc('hour', now()), 1)
    ON CONFLICT (channel, hour)
    DO UPDATE SET count = notification_stats.count + 1;
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;
```

### Security Considerations

### Access Control

```sql
-- Grant privileges to use LISTEN/NOTIFY
GRANT USAGE ON SCHEMA public TO app_user;

-- Restrict access to specific notification channels via functions
CREATE OR REPLACE FUNCTION send_notification(channel text, payload text) RETURNS void AS $$
BEGIN
    -- Check if user has access to this channel
    IF NOT EXISTS (
        SELECT 1 FROM user_channel_access 
        WHERE username = current_user AND channel_name = channel
    ) THEN
        RAISE EXCEPTION 'Not authorized to send notifications on channel %', channel;
    END IF;
    
    PERFORM pg_notify(channel, payload);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Only grant access to the function, not directly to NOTIFY
REVOKE ALL ON FUNCTION pg_notify FROM PUBLIC;
GRANT EXECUTE ON FUNCTION send_notification TO app_user;
```

### Payload Security

Always sanitize payloads and avoid including sensitive information:

```sql
-- Hash sensitive IDs before including in notifications
SELECT pg_notify(
    'user_event',
    json_build_object(
        'type', 'login',
        'user_reference', encode(digest(user_id::text, 'sha256'), 'hex')
    )::text
);
```

### Common Challenges and Solutions

### Lost Notifications

Notifications sent when no clients are listening are lost. Implement a catch-up mechanism:

```sql
-- Record changes in a log table
CREATE TABLE change_log (
    id SERIAL PRIMARY KEY,
    table_name TEXT NOT NULL,
    operation TEXT NOT NULL,
    record_id INTEGER NOT NULL,
    changed_at TIMESTAMP DEFAULT NOW()
);

-- Client queries for missed changes
SELECT * FROM change_log 
WHERE changed_at > 'last_connection_time'
ORDER BY changed_at;
```

### Connection Pooling Issues

Most connection pools interfere with LISTEN/NOTIFY. Solutions include:

1. Dedicated connection for notifications
2. Using pgBouncer in session mode
3. Application-level message distribution

### High-frequency Notifications

For systems with many notifications, implement batching:

```sql
CREATE OR REPLACE FUNCTION batch_notifications() RETURNS TRIGGER AS $$
BEGIN
    -- Insert into batch table instead of immediate notification
    INSERT INTO notification_batch (table_name, operation, record_id)
    VALUES (TG_TABLE_NAME, TG_OP, NEW.id);
    
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Scheduled function to send batched notifications
CREATE OR REPLACE FUNCTION send_batched_notifications() RETURNS void AS $$
DECLARE
    batch_json JSONB;
BEGIN
    SELECT json_agg(json_build_object(
        'table', table_name,
        'operation', operation,
        'id', record_id
    ))
    INTO batch_json
    FROM notification_batch
    WHERE sent = FALSE
    LIMIT 100;
    
    IF batch_json IS NOT NULL THEN
        PERFORM pg_notify('batched_changes', batch_json::text);
        
        UPDATE notification_batch
        SET sent = TRUE
        WHERE id IN (
            SELECT id FROM notification_batch
            WHERE sent = FALSE
            ORDER BY id
            LIMIT 100
        );
    END IF;
END;
$$ LANGUAGE plpgsql;
```

### Testing LISTEN/NOTIFY Applications

### Manual Testing with psql

```sql
-- In one terminal
psql -d database -c "LISTEN test_channel;"

-- In another terminal
psql -d database -c "NOTIFY test_channel, 'Test message';"
```

### Automated Testing

```python
import pytest
import psycopg2
import threading
import queue

@pytest.fixture
def db_connection():
    conn = psycopg2.connect("dbname=test_db user=test_user")
    conn.set_isolation_level(psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT)
    yield conn
    conn.close()

def test_notification_system(db_connection):
    notifications = queue.Queue()
    
    # Setup listener in a thread
    def listen_for_notifications():
        cursor = db_connection.cursor()
        cursor.execute("LISTEN test_channel;")
        
        while True:
            db_connection.poll()
            while db_connection.notifies:
                notify = db_connection.notifies.pop()
                notifications.put(notify)
    
    # Start listener thread
    listener_thread = threading.Thread(target=listen_for_notifications)
    listener_thread.daemon = True
    listener_thread.start()
    
    # Give the listener time to start
    time.sleep(0.1)
    
    # Send a notification
    cursor = db_connection.cursor()
    cursor.execute("NOTIFY test_channel, 'test_payload';")
    
    # Check if notification was received
    notify = notifications.get(timeout=1)
    assert notify.channel == "test_channel"
    assert notify.payload == "test_payload"
```

### Conclusion

PostgreSQL's LISTEN/NOTIFY mechanism offers a powerful foundation for building event-driven architectures. By eliminating the need for constant polling, it enables more efficient and responsive applications. While it has limitations, particularly around guaranteed delivery and payload size, thoughtful implementation patterns can overcome these challenges. For many applications, LISTEN/NOTIFY provides an elegant solution for real-time updates and event propagation without introducing external messaging systems.

### Related Topics

- PostgreSQL Logical Replication
- Message Queuing Systems (RabbitMQ, Kafka) vs. LISTEN/NOTIFY
- Change Data Capture (CDC) Patterns
- WebSockets with PostgreSQL Notifications
- Event Sourcing with PostgreSQL

---

