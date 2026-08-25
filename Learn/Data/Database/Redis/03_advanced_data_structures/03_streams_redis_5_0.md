## Streams (Redis 5.0+)


### What are Redis Streams

Redis Streams are a powerful data structure introduced in Redis 5.0 that provides an append-only log of messages, similar to Apache Kafka but with Redis's simplicity and performance characteristics. Streams are designed for real-time data processing, event sourcing, and message queuing with built-in support for consumer groups, automatic message acknowledgment, and efficient range queries. Each message in a stream has a unique ID and can contain multiple field-value pairs, making it ideal for structured event data.

### Stream Entry Structure

**Entry ID Format**

```
<millisecondsTime>-<sequenceNumber>
```

**Examples**

```
1609459200000-0    # First message at timestamp 1609459200000
1609459200000-1    # Second message at same timestamp
1609459200001-0    # First message at next millisecond
```

**Auto-generated IDs**

- Use `*` for automatic ID generation
- Redis generates monotonically increasing IDs
- Guaranteed uniqueness within a stream

### Basic Stream Operations

#### XADD - Adding Messages

**Basic Syntax**

```bash
XADD stream_name ID field1 value1 [field2 value2 ...]
```

**Examples**

```bash
XADD events * user_id 123 action login timestamp 1609459200
XADD events * user_id 456 action purchase item_id 789 amount 29.99
XADD events 1609459200000-0 user_id 123 action logout
```

**Advanced XADD Options**

```bash
XADD stream_name MAXLEN 1000 * field value     # Limit stream length
XADD stream_name MAXLEN ~ 1000 * field value   # Approximate limit (more efficient)
XADD stream_name MINID 1609459200000-0 * field value # Remove entries older than ID
```

**Return Value**

```bash
XADD events * user_id 123 action login
# Returns: "1609459200000-0"
```

#### XREAD - Reading Messages

**Basic Syntax**

```bash
XREAD [COUNT count] [BLOCK milliseconds] STREAMS stream1 [stream2 ...] id1 [id2 ...]
```

**Examples**

```bash
XREAD STREAMS events 0                    # Read all messages from beginning
XREAD STREAMS events $                    # Read new messages from now
XREAD STREAMS events 1609459200000-0      # Read messages after specific ID
XREAD COUNT 10 STREAMS events 0           # Read first 10 messages
XREAD BLOCK 5000 STREAMS events $         # Block for 5 seconds waiting for new messages
```

**Multiple Streams**

```bash
XREAD STREAMS events logs 0 0             # Read from both streams
XREAD STREAMS events logs $ $             # Monitor both streams for new messages
```

**Output Format**

```bash
1) 1) "events"
   2) 1) 1) "1609459200000-0"
         2) 1) "user_id"
            2) "123"
            3) "action"
            4) "login"
      2) 1) "1609459200001-0"
         2) 1) "user_id"
            2) "456"
            3) "action"
            4) "purchase"
```

#### XRANGE - Reading Message Ranges

**Basic Syntax**

```bash
XRANGE stream_name start end [COUNT count]
```

**Examples**

```bash
XRANGE events - +                         # Read all messages
XRANGE events 1609459200000-0 1609459300000-0  # Read specific time range
XRANGE events - + COUNT 10                # Read first 10 messages
XRANGE events (1609459200000-0 +          # Exclusive start range
```

**Special Range Identifiers**

- `-`: Minimum possible ID
- `+`: Maximum possible ID
- `(`: Exclusive range indicator

**XREVRANGE - Reverse Range**

```bash
XREVRANGE events + - COUNT 10             # Get last 10 messages
XREVRANGE events + 1609459200000-0        # Read in reverse order
```

#### XLEN - Getting Stream Length

**Basic Syntax**

```bash
XLEN stream_name
```

**Example**

```bash
XLEN events
# Returns: 1547
```

### Consumer Groups

#### XGROUP - Managing Consumer Groups

**Create Consumer Group**

```bash
XGROUP CREATE stream_name group_name start_id [MKSTREAM]
```

**Examples**

```bash
XGROUP CREATE events analytics_group 0           # Process from beginning
XGROUP CREATE events realtime_group $            # Process new messages only
XGROUP CREATE events backup_group 0 MKSTREAM     # Create stream if it doesn't exist
```

**Consumer Group Management**

```bash
XGROUP DESTROY events analytics_group            # Delete consumer group
XGROUP SETID events analytics_group 1609459200000-0  # Reset group position
XGROUP DELCONSUMER events analytics_group consumer1   # Remove consumer
```

**Create Consumer**

```bash
XGROUP CREATECONSUMER stream_name group_name consumer_name
```

#### XREADGROUP - Reading with Consumer Groups

**Basic Syntax**

```bash
XREADGROUP GROUP group_name consumer_name [COUNT count] [BLOCK milliseconds] [NOACK] STREAMS stream1 [stream2 ...] id1 [id2 ...]
```

**Examples**

```bash
XREADGROUP GROUP analytics_group consumer1 STREAMS events >
XREADGROUP GROUP analytics_group consumer1 COUNT 5 STREAMS events >
XREADGROUP GROUP analytics_group consumer1 BLOCK 1000 STREAMS events >
XREADGROUP GROUP analytics_group consumer1 NOACK STREAMS events >
```

**Special IDs for Consumer Groups**

- `>`: Read undelivered messages
- `0`: Read pending messages for this consumer

**Message Acknowledgment**

```bash
XACK stream_name group_name id1 [id2 ...]
```

**Example**

```bash
XACK events analytics_group 1609459200000-0 1609459200001-0
```

### Advanced Stream Operations

#### Message Information and Management

**XINFO - Stream Information**

```bash
XINFO STREAM stream_name                  # Stream details
XINFO GROUPS stream_name                  # Consumer groups info
XINFO CONSUMERS stream_name group_name    # Consumer info
```

**XPENDING - Pending Messages**

```bash
XPENDING stream_name group_name           # Overview of pending messages
XPENDING stream_name group_name - + 10    # Detailed pending messages
XPENDING stream_name group_name - + 10 consumer1  # Pending for specific consumer
```

**XCLAIM - Claiming Messages**

```bash
XCLAIM stream_name group_name consumer_name min_idle_time id1 [id2 ...]
```

**Example**

```bash
XCLAIM events analytics_group consumer2 3600000 1609459200000-0
```

**XAUTOCLAIM - Automatic Message Claiming**

```bash
XAUTOCLAIM stream_name group_name consumer_name min_idle_time start [COUNT count]
```

#### Stream Maintenance

**XDEL - Deleting Messages**

```bash
XDEL stream_name id1 [id2 ...]
```

**Example**

```bash
XDEL events 1609459200000-0 1609459200001-0
```

**XTRIM - Trimming Streams**

```bash
XTRIM stream_name MAXLEN [~] count
XTRIM stream_name MINID [~] id
```

**Examples**

```bash
XTRIM events MAXLEN 1000                  # Keep last 1000 messages
XTRIM events MAXLEN ~ 1000                # Approximate trimming (more efficient)
XTRIM events MINID 1609459200000-0        # Remove messages older than ID
```

### Stream Processing Patterns

#### Producer-Consumer Pattern

**Simple Producer**

```python
import redis
import json
import time

r = redis.Redis()

def produce_event(event_type, data):
    event_data = {
        'timestamp': int(time.time()),
        'type': event_type,
        'data': json.dumps(data)
    }
    
    message_id = r.xadd('events', event_data)
    return message_id

# Usage
produce_event('user_login', {'user_id': 123, 'ip': '192.168.1.1'})
produce_event('purchase', {'user_id': 123, 'item_id': 789, 'amount': 29.99})
```

**Simple Consumer**

```python
def consume_events():
    last_id = '0'
    
    while True:
        messages = r.xread({'events': last_id}, count=10, block=1000)
        
        for stream_name, stream_messages in messages:
            for message_id, fields in stream_messages:
                process_message(message_id, fields)
                last_id = message_id

def process_message(message_id, fields):
    event_type = fields.get('type', '').decode()
    data = json.loads(fields.get('data', '{}').decode())
    
    print(f"Processing {event_type}: {data}")
```

#### Consumer Group Pattern

**Consumer Group Setup**

```python
import redis
import json
import threading

r = redis.Redis()

class StreamConsumer:
    def __init__(self, stream_name, group_name, consumer_name):
        self.stream_name = stream_name
        self.group_name = group_name
        self.consumer_name = consumer_name
        
        # Create consumer group if it doesn't exist
        try:
            r.xgroup_create(stream_name, group_name, id='0', mkstream=True)
        except redis.exceptions.ResponseError:
            pass  # Group already exists
    
    def consume(self):
        while True:
            try:
                messages = r.xreadgroup(
                    self.group_name,
                    self.consumer_name,
                    {self.stream_name: '>'},
                    count=5,
                    block=1000
                )
                
                for stream_name, stream_messages in messages:
                    for message_id, fields in stream_messages:
                        if self.process_message(message_id, fields):
                            r.xack(stream_name, self.group_name, message_id)
                        
            except Exception as e:
                print(f"Error: {e}")
                time.sleep(1)
    
    def process_message(self, message_id, fields):
        try:
            event_type = fields.get('type', b'').decode()
            data = json.loads(fields.get('data', b'{}').decode())
            
            # Process based on event type
            if event_type == 'user_login':
                handle_user_login(data)
            elif event_type == 'purchase':
                handle_purchase(data)
            
            return True
        except Exception as e:
            print(f"Failed to process message {message_id}: {e}")
            return False

# Start multiple consumers
def start_consumer_group():
    consumers = []
    for i in range(3):
        consumer = StreamConsumer('events', 'analytics_group', f'consumer_{i}')
        thread = threading.Thread(target=consumer.consume)
        thread.daemon = True
        thread.start()
        consumers.append(consumer)
    
    return consumers
```

#### Fan-out Pattern

**Multiple Consumer Groups**

```python
def setup_fanout_pattern():
    stream_name = 'events'
    
    # Create different consumer groups for different purposes
    groups = [
        ('analytics_group', '0'),      # Process all historical data
        ('realtime_group', '$'),       # Process only new messages
        ('backup_group', '0'),         # Backup processing
        ('ml_group', '$')              # Machine learning pipeline
    ]
    
    for group_name, start_id in groups:
        try:
            r.xgroup_create(stream_name, group_name, id=start_id, mkstream=True)
        except redis.exceptions.ResponseError:
            pass  # Group already exists

def create_specialized_consumer(group_name, processor_func):
    def consume():
        consumer_name = f"{group_name}_consumer"
        
        while True:
            messages = r.xreadgroup(
                group_name,
                consumer_name,
                {'events': '>'},
                count=10,
                block=1000
            )
            
            for stream_name, stream_messages in messages:
                for message_id, fields in stream_messages:
                    if processor_func(message_id, fields):
                        r.xack(stream_name, group_name, message_id)
    
    return consume
```

#### Error Handling and Recovery

**Pending Message Recovery**

```python
def recover_pending_messages(stream_name, group_name, consumer_name):
    # Get pending messages
    pending = r.xpending_range(stream_name, group_name, '-', '+', 100)
    
    for message_info in pending:
        message_id = message_info['message_id']
        idle_time = message_info['time_since_delivered']
        
        # Reclaim messages idle for more than 5 minutes
        if idle_time > 300000:
            try:
                claimed = r.xclaim(
                    stream_name,
                    group_name,
                    consumer_name,
                    300000,  # min idle time
                    [message_id]
                )
                
                # Reprocess claimed messages
                for claimed_message in claimed:
                    message_id, fields = claimed_message
                    if process_message(message_id, fields):
                        r.xack(stream_name, group_name, message_id)
                        
            except Exception as e:
                print(f"Failed to reclaim message {message_id}: {e}")
```

**Dead Letter Queue Pattern**

```python
def setup_dead_letter_queue():
    def process_with_dlq(message_id, fields, max_retries=3):
        retry_count = int(fields.get('retry_count', 0))
        
        try:
            # Attempt to process message
            result = process_message(message_id, fields)
            if result:
                return True
                
        except Exception as e:
            print(f"Processing failed for {message_id}: {e}")
        
        # Increment retry count
        retry_count += 1
        
        if retry_count >= max_retries:
            # Move to dead letter queue
            dlq_data = dict(fields)
            dlq_data['retry_count'] = retry_count
            dlq_data['failed_at'] = int(time.time())
            dlq_data['original_message_id'] = message_id
            
            r.xadd('dead_letter_queue', dlq_data)
            return True  # Acknowledge to remove from main stream
        else:
            # Requeue with retry count
            requeue_data = dict(fields)
            requeue_data['retry_count'] = retry_count
            r.xadd('events', requeue_data)
            return True
        
        return False
```

### Use Cases

#### Event Sourcing

**Event Store Implementation**

```python
import redis
import json
import uuid
from datetime import datetime

class EventStore:
    def __init__(self, redis_client):
        self.redis = redis_client
    
    def append_event(self, aggregate_id, event_type, event_data, expected_version=None):
        event = {
            'aggregate_id': aggregate_id,
            'event_type': event_type,
            'event_data': json.dumps(event_data),
            'event_id': str(uuid.uuid4()),
            'timestamp': datetime.utcnow().isoformat(),
            'version': self.get_next_version(aggregate_id)
        }
        
        if expected_version is not None:
            current_version = self.get_current_version(aggregate_id)
            if current_version != expected_version:
                raise ConcurrencyError(f"Expected version {expected_version}, got {current_version}")
        
        # Store in aggregate-specific stream
        stream_name = f"events:{aggregate_id}"
        message_id = self.redis.xadd(stream_name, event)
        
        # Also store in global event stream
        self.redis.xadd('all_events', event)
        
        return message_id
    
    def get_events(self, aggregate_id, from_version=0):
        stream_name = f"events:{aggregate_id}"
        messages = self.redis.xrange(stream_name, '-', '+')
        
        events = []
        for message_id, fields in messages:
            event = {
                'message_id': message_id,
                'aggregate_id': fields[b'aggregate_id'].decode(),
                'event_type': fields[b'event_type'].decode(),
                'event_data': json.loads(fields[b'event_data'].decode()),
                'event_id': fields[b'event_id'].decode(),
                'timestamp': fields[b'timestamp'].decode(),
                'version': int(fields[b'version'])
            }
            
            if event['version'] > from_version:
                events.append(event)
        
        return events
    
    def get_current_version(self, aggregate_id):
        events = self.get_events(aggregate_id)
        return max([e['version'] for e in events]) if events else 0
    
    def get_next_version(self, aggregate_id):
        return self.get_current_version(aggregate_id) + 1

# Usage example
event_store = EventStore(r)

# Append events
event_store.append_event('user_123', 'UserCreated', {'name': 'John', 'email': 'john@example.com'})
event_store.append_event('user_123', 'EmailUpdated', {'email': 'john.doe@example.com'})
event_store.append_event('user_123', 'UserDeactivated', {'reason': 'user_request'})

# Read events
events = event_store.get_events('user_123')
for event in events:
    print(f"Version {event['version']}: {event['event_type']}")
```

**Projection Building**

```python
class ProjectionBuilder:
    def __init__(self, event_store, projection_name):
        self.event_store = event_store
        self.projection_name = projection_name
        self.redis = event_store.redis
        
        # Create consumer group for this projection
        try:
            self.redis.xgroup_create('all_events', projection_name, id='0', mkstream=True)
        except redis.exceptions.ResponseError:
            pass
    
    def build_projection(self, handlers):
        consumer_name = f"{self.projection_name}_consumer"
        
        while True:
            messages = self.redis.xreadgroup(
                self.projection_name,
                consumer_name,
                {'all_events': '>'},
                count=10,
                block=1000
            )
            
            for stream_name, stream_messages in messages:
                for message_id, fields in stream_messages:
                    event_type = fields[b'event_type'].decode()
                    
                    if event_type in handlers:
                        try:
                            event_data = json.loads(fields[b'event_data'].decode())
                            aggregate_id = fields[b'aggregate_id'].decode()
                            
                            handlers[event_type](aggregate_id, event_data)
                            self.redis.xack(stream_name, self.projection_name, message_id)
                            
                        except Exception as e:
                            print(f"Failed to process event {message_id}: {e}")

# User projection example
def build_user_projection():
    handlers = {
        'UserCreated': lambda aid, data: r.hset(f"user:{aid}", mapping=data),
        'EmailUpdated': lambda aid, data: r.hset(f"user:{aid}", 'email', data['email']),
        'UserDeactivated': lambda aid, data: r.hset(f"user:{aid}", 'status', 'deactivated')
    }
    
    projection = ProjectionBuilder(event_store, 'user_projection')
    projection.build_projection(handlers)
```

#### Real-time Analytics

**Metrics Collection**

```python
import time
from collections import defaultdict

class MetricsCollector:
    def __init__(self, redis_client):
        self.redis = redis_client
        self.metrics = defaultdict(int)
        
        # Create consumer group for metrics
        try:
            self.redis.xgroup_create('events', 'metrics_group', id='$', mkstream=True)
        except redis.exceptions.ResponseError:
            pass
    
    def start_collection(self):
        consumer_name = 'metrics_consumer'
        
        while True:
            messages = self.redis.xreadgroup(
                'metrics_group',
                consumer_name,
                {'events': '>'},
                count=100,
                block=1000
            )
            
            for stream_name, stream_messages in messages:
                for message_id, fields in stream_messages:
                    self.process_metric(message_id, fields)
                    self.redis.xack(stream_name, 'metrics_group', message_id)
                
                # Flush metrics every 100 messages
                if len(stream_messages) > 0:
                    self.flush_metrics()
    
    def process_metric(self, message_id, fields):
        event_type = fields.get(b'type', b'').decode()
        
        if event_type == 'page_view':
            self.metrics['page_views'] += 1
            page = fields.get(b'page', b'').decode()
            self.metrics[f'page_views:{page}'] += 1
            
        elif event_type == 'user_login':
            self.metrics['user_logins'] += 1
            
        elif event_type == 'purchase':
            self.metrics['purchases'] += 1
            amount = float(fields.get(b'amount', 0))
            self.metrics['revenue'] += amount
    
    def flush_metrics(self):
        timestamp = int(time.time())
        
        for metric_name, value in self.metrics.items():
            # Store in time series
            self.redis.zadd(f"metrics:{metric_name}", {timestamp: value})
            
            # Keep only last 24 hours
            yesterday = timestamp - 86400
            self.redis.zremrangebyscore(f"metrics:{metric_name}", 0, yesterday)
        
        # Reset counters
        self.metrics.clear()
```

**Real-time Dashboard**

```python
class RealTimeDashboard:
    def __init__(self, redis_client):
        self.redis = redis_client
        
        # Create consumer group for dashboard updates
        try:
            self.redis.xgroup_create('events', 'dashboard_group', id='$', mkstream=True)
        except redis.exceptions.ResponseError:
            pass
    
    def start_dashboard(self):
        consumer_name = 'dashboard_consumer'
        
        while True:
            messages = self.redis.xreadgroup(
                'dashboard_group',
                consumer_name,
                {'events': '>'},
                count=10,
                block=1000
            )
            
            for stream_name, stream_messages in messages:
                for message_id, fields in stream_messages:
                    self.update_dashboard(fields)
                    self.redis.xack(stream_name, 'dashboard_group', message_id)
    
    def update_dashboard(self, fields):
        event_type = fields.get(b'type', b'').decode()
        timestamp = int(time.time())
        
        # Update real-time counters
        self.redis.incr(f"realtime:{event_type}")
        self.redis.expire(f"realtime:{event_type}", 300)  # 5 minute window
        
        # Update minute-based aggregates
        minute_key = f"minute:{timestamp // 60}"
        self.redis.hincrby(minute_key, event_type, 1)
        self.redis.expire(minute_key, 3600)  # 1 hour retention
    
    def get_dashboard_data(self):
        # Get real-time counters
        realtime_keys = self.redis.keys("realtime:*")
        realtime_data = {}
        
        for key in realtime_keys:
            event_type = key.decode().split(':')[1]
            count = self.redis.get(key)
            realtime_data[event_type] = int(count) if count else 0
        
        # Get minute aggregates for last hour
        current_minute = int(time.time()) // 60
        minute_data = {}
        
        for i in range(60):
            minute_key = f"minute:{current_minute - i}"
            data = self.redis.hgetall(minute_key)
            
            if data:
                minute_data[current_minute - i] = {
                    k.decode(): int(v) for k, v in data.items()
                }
        
        return {
            'realtime': realtime_data,
            'historical': minute_data
        }
```

#### Activity Feeds

**Activity Stream**

```python
class ActivityFeed:
    def __init__(self, redis_client):
        self.redis = redis_client
    
    def add_activity(self, user_id, activity_type, activity_data):
        activity = {
            'user_id': user_id,
            'activity_type': activity_type,
            'activity_data': json.dumps(activity_data),
            'timestamp': int(time.time())
        }
        
        # Add to user's activity stream
        self.redis.xadd(f"activity:{user_id}", activity, maxlen=1000)
        
        # Add to global activity stream
        self.redis.xadd('global_activity', activity)
        
        # Notify followers
        self.notify_followers(user_id, activity)
    
    def notify_followers(self, user_id, activity):
        # Get user's followers
        followers = self.redis.smembers(f"followers:{user_id}")
        
        for follower in followers:
            follower_id = follower.decode()
            
            # Add to follower's feed
            feed_activity = dict(activity)
            feed_activity['source_user'] = user_id
            
            self.redis.xadd(f"feed:{follower_id}", feed_activity, maxlen=500)
    
    def get_user_feed(self, user_id, count=20):
        messages = self.redis.xrevrange(f"feed:{user_id}", '+', '-', count=count)
        
        feed = []
        for message_id, fields in messages:
            activity = {
                'id': message_id,
                'user_id': fields[b'user_id'].decode(),
                'activity_type': fields[b'activity_type'].decode(),
                'activity_data': json.loads(fields[b'activity_data'].decode()),
                'timestamp': int(fields[b'timestamp']),
                'source_user': fields.get(b'source_user', b'').decode()
            }
            feed.append(activity)
        
        return feed
```

### Performance Considerations

#### Memory Management

**Stream Trimming Strategies**

```python
# Automatic trimming during XADD
r.xadd('events', {'field': 'value'}, maxlen=10000)

# Periodic trimming
def trim_streams():
    streams = ['events', 'logs', 'metrics']
    
    for stream in streams:
        # Keep last 24 hours of data
        cutoff_time = int(time.time() - 86400) * 1000
        cutoff_id = f"{cutoff_time}-0"
        
        r.xtrim(stream, minid=cutoff_id, approximate=True)
```

**Memory Optimization**

- Use approximate trimming (`~`) for better performance
- Set appropriate MAXLEN limits during XADD
- Consider using MINID for time-based trimming
- Monitor memory usage with INFO memory

#### Performance Tuning

**Batch Processing**

```python
def batch_process_stream(stream_name, batch_size=100):
    last_id = '0'
    
    while True:
        messages = r.xread({stream_name: last_id}, count=batch_size, block=1000)
        
        if not messages:
            continue
            
        batch = []
        for stream_name, stream_messages in messages:
            for message_id, fields in stream_messages:
                batch.append((message_id, fields))
                last_id = message_id
        
        # Process batch
        process_message_batch(batch)
```

**Connection Pooling**

```python
import redis.connection

# Use connection pooling for better performance
pool = redis.ConnectionPool(host='localhost', port=6379, db=0, max_connections=10)
r = redis.Redis(connection_pool=pool)
```

**Key points:**

- Redis Streams provide append-only logs with unique message IDs and structured data
- Basic operations include XADD for adding messages, XREAD for consuming, and XRANGE for querying ranges
- Consumer groups enable distributed processing with automatic load balancing and message acknowledgment
- Stream processing patterns include producer-consumer, fan-out, and error handling with dead letter queues
- Primary use cases are event sourcing for audit trails, real-time analytics for metrics collection, and activity feeds
- Performance optimization involves memory management through trimming and efficient batch processing
- Advanced features include message claiming, pending message recovery, and automatic consumer group management

---

