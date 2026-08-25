## Sorted Sets (ZSets)


### What are Sorted Sets

Sorted Sets (ZSets) are one of Redis's most powerful data structures, combining the unique properties of sets with the ability to associate each member with a score. Unlike regular sets, sorted sets maintain order based on these scores, making them ideal for scenarios requiring both uniqueness and ranking. Each member in a sorted set has an associated floating-point score, and members are automatically sorted by their scores in ascending order. When multiple members have the same score, they are ordered lexicographically.

### Basic Operations

#### ZADD - Adding Members

**Basic Syntax**

```bash
ZADD key score member [score member ...]
```

**Examples**

```bash
ZADD leaderboard 100 player1
ZADD leaderboard 200 player2 150 player3
ZADD leaderboard 100 player4
```

**Advanced ZADD Options**

```bash
ZADD key NX score member     # Only add if member doesn't exist
ZADD key XX score member     # Only update if member exists
ZADD key CH score member     # Return number of changed elements
ZADD key INCR score member   # Increment score (like ZINCRBY)
```

**Return Values**

- Returns number of elements added (not including updated elements)
- With CH option: returns number of elements changed
- With INCR option: returns the new score

#### ZREM - Removing Members

**Basic Syntax**

```bash
ZREM key member [member ...]
```

**Examples**

```bash
ZREM leaderboard player1
ZREM leaderboard player2 player3
```

**Related Removal Commands**

```bash
ZREMRANGEBYRANK key start stop        # Remove by rank range
ZREMRANGEBYSCORE key min max          # Remove by score range
ZREMRANGEBYLEX key min max            # Remove by lexicographical range
```

#### ZRANGE - Retrieving Members by Rank

**Basic Syntax**

```bash
ZRANGE key start stop [WITHSCORES]
```

**Examples**

```bash
ZRANGE leaderboard 0 -1              # All members, lowest to highest score
ZRANGE leaderboard 0 2               # Top 3 lowest scores
ZRANGE leaderboard 0 -1 WITHSCORES   # All members with their scores
ZRANGE leaderboard -3 -1             # Last 3 members (highest scores)
```

**Output Format**

```bash
# Without WITHSCORES
1) "player1"
2) "player4"
3) "player3"

# With WITHSCORES
1) "player1"
2) "100"
3) "player4"
4) "100"
5) "player3"
6) "150"
```

#### ZREVRANGE - Retrieving Members in Reverse Order

**Basic Syntax**

```bash
ZREVRANGE key start stop [WITHSCORES]
```

**Examples**

```bash
ZREVRANGE leaderboard 0 -1           # All members, highest to lowest score
ZREVRANGE leaderboard 0 2            # Top 3 highest scores
ZREVRANGE leaderboard 0 -1 WITHSCORES
```

### Score and Rank Operations

#### ZRANK - Getting Member Rank

**Basic Syntax**

```bash
ZRANK key member
```

**Examples**

```bash
ZRANK leaderboard player1    # Returns 0 (lowest score gets rank 0)
ZRANK leaderboard player3    # Returns 2
ZRANK leaderboard nonexistent # Returns (nil)
```

**ZREVRANK - Reverse Rank**

```bash
ZREVRANK leaderboard player1  # Rank in descending order
```

#### ZSCORE - Getting Member Score

**Basic Syntax**

```bash
ZSCORE key member
```

**Examples**

```bash
ZSCORE leaderboard player1    # Returns "100"
ZSCORE leaderboard player3    # Returns "150"
ZSCORE leaderboard nonexistent # Returns (nil)
```

**ZMSCORE - Multiple Scores**

```bash
ZMSCORE leaderboard player1 player2 player3
```

#### ZCOUNT - Counting Members by Score Range

**Basic Syntax**

```bash
ZCOUNT key min max
```

**Examples**

```bash
ZCOUNT leaderboard 100 200    # Count members with scores 100-200
ZCOUNT leaderboard -inf +inf  # Count all members
ZCOUNT leaderboard (100 200   # Exclusive lower bound
ZCOUNT leaderboard 100 (200   # Exclusive upper bound
```

### Range Operations by Score

#### ZRANGEBYSCORE - Retrieve Members by Score Range

**Basic Syntax**

```bash
ZRANGEBYSCORE key min max [WITHSCORES] [LIMIT offset count]
```

**Examples**

```bash
ZRANGEBYSCORE leaderboard 100 200
ZRANGEBYSCORE leaderboard 100 200 WITHSCORES
ZRANGEBYSCORE leaderboard -inf +inf LIMIT 0 10
ZRANGEBYSCORE leaderboard (100 200    # Exclusive lower bound
ZRANGEBYSCORE leaderboard 100 (200    # Exclusive upper bound
```

**ZREVRANGEBYSCORE - Reverse Order**

```bash
ZREVRANGEBYSCORE key max min [WITHSCORES] [LIMIT offset count]
```

**Examples**

```bash
ZREVRANGEBYSCORE leaderboard 200 100
ZREVRANGEBYSCORE leaderboard +inf -inf LIMIT 0 5
```

#### Advanced Score Range Operations

**ZRANGEBYLEX - Lexicographical Range**

```bash
ZRANGEBYLEX key min max [LIMIT offset count]
```

**Examples**

```bash
ZRANGEBYLEX leaderboard [a [z        # Members starting with a-z
ZRANGEBYLEX leaderboard (player1 +   # Members lexicographically after player1
```

**ZLEXCOUNT - Count by Lexicographical Range**

```bash
ZLEXCOUNT key min max
```

### Advanced Operations

#### ZINCRBY - Incrementing Scores

**Basic Syntax**

```bash
ZINCRBY key increment member
```

**Examples**

```bash
ZINCRBY leaderboard 10 player1       # Increase player1's score by 10
ZINCRBY leaderboard -5 player2       # Decrease player2's score by 5
ZINCRBY leaderboard 1 newplayer      # Add new player with score 1
```

#### ZCARD - Getting Set Size

**Basic Syntax**

```bash
ZCARD key
```

**Example**

```bash
ZCARD leaderboard    # Returns total number of members
```

#### Set Operations

**ZUNIONSTORE - Union of Sorted Sets**

```bash
ZUNIONSTORE destination numkeys key1 [key2 ...] [WEIGHTS weight1 [weight2 ...]] [AGGREGATE SUM|MIN|MAX]
```

**Examples**

```bash
ZUNIONSTORE combined 2 leaderboard1 leaderboard2
ZUNIONSTORE combined 2 leaderboard1 leaderboard2 WEIGHTS 1 2
ZUNIONSTORE combined 2 leaderboard1 leaderboard2 AGGREGATE MAX
```

**ZINTERSTORE - Intersection of Sorted Sets**

```bash
ZINTERSTORE destination numkeys key1 [key2 ...] [WEIGHTS weight1 [weight2 ...]] [AGGREGATE SUM|MIN|MAX]
```

**Examples**

```bash
ZINTERSTORE common 2 leaderboard1 leaderboard2
ZINTERSTORE common 2 leaderboard1 leaderboard2 WEIGHTS 0.5 1.5
```

#### Blocking Operations

**BZPOPMAX - Blocking Pop Maximum**

```bash
BZPOPMAX key [key ...] timeout
```

**BZPOPMIN - Blocking Pop Minimum**

```bash
BZPOPMIN key [key ...] timeout
```

**Examples**

```bash
BZPOPMAX leaderboard 0    # Block until element available
BZPOPMIN leaderboard 10   # Block for maximum 10 seconds
```

### Use Cases

#### Leaderboards

**Gaming Leaderboard Implementation**

```bash
# Add players with scores
ZADD game_leaderboard 1500 player1 2000 player2 1800 player3

# Get top 10 players
ZREVRANGE game_leaderboard 0 9 WITHSCORES

# Get player rank
ZREVRANK game_leaderboard player1

# Update player score
ZINCRBY game_leaderboard 100 player1

# Get players in score range
ZRANGEBYSCORE game_leaderboard 1500 2000 WITHSCORES
```

**Real-time Leaderboard Updates**

```python
import redis

r = redis.Redis()

def update_player_score(player_id, score_change):
    new_score = r.zincrby("leaderboard", score_change, player_id)
    return new_score

def get_top_players(count=10):
    return r.zrevrange("leaderboard", 0, count-1, withscores=True)

def get_player_rank(player_id):
    rank = r.zrevrank("leaderboard", player_id)
    return rank + 1 if rank is not None else None
```

#### Time Series Data

**Event Tracking with Timestamps**

```bash
# Add events with timestamps
ZADD user_events 1609459200 "login" 1609459260 "page_view" 1609459320 "purchase"

# Get events in time range
ZRANGEBYSCORE user_events 1609459200 1609459300 WITHSCORES

# Get recent events
ZREVRANGE user_events 0 9 WITHSCORES
```

**Time-based Analytics**

```python
import time
import redis

r = redis.Redis()

def track_event(user_id, event_type):
    timestamp = int(time.time())
    r.zadd(f"user_events:{user_id}", {f"{event_type}:{timestamp}": timestamp})

def get_user_events(user_id, start_time, end_time):
    return r.zrangebyscore(f"user_events:{user_id}", start_time, end_time, withscores=True)

def get_recent_events(user_id, count=10):
    return r.zrevrange(f"user_events:{user_id}", 0, count-1, withscores=True)
```

#### Priority Queues

**Task Priority System**

```bash
# Add tasks with priorities (higher score = higher priority)
ZADD task_queue 1 "low_priority_task" 5 "medium_priority_task" 10 "high_priority_task"

# Get highest priority task
ZREVRANGE task_queue 0 0

# Process and remove highest priority task
ZPOPMAX task_queue
```

**Implementation Example**

```python
import redis
import json

r = redis.Redis()

def add_task(task_data, priority):
    task_id = f"task:{task_data['id']}"
    r.zadd("task_queue", {task_id: priority})
    r.hset(task_id, mapping=task_data)

def get_next_task():
    result = r.zpopmax("task_queue")
    if result:
        task_id, priority = result[0]
        task_data = r.hgetall(task_id)
        r.delete(task_id)
        return task_data, priority
    return None, None
```

#### Rate Limiting

**Time Window Rate Limiting**

```bash
# Track requests with timestamps
ZADD rate_limit:user123 1609459200 "req1" 1609459201 "req2" 1609459202 "req3"

# Remove old requests (older than 60 seconds)
ZREMRANGEBYSCORE rate_limit:user123 -inf (1609459140)

# Check current request count
ZCARD rate_limit:user123
```

**Implementation**

```python
import time
import redis

r = redis.Redis()

def is_rate_limited(user_id, max_requests=100, window_seconds=3600):
    key = f"rate_limit:{user_id}"
    current_time = int(time.time())
    
    # Remove old requests
    r.zremrangebyscore(key, 0, current_time - window_seconds)
    
    # Check current count
    current_count = r.zcard(key)
    
    if current_count >= max_requests:
        return True
    
    # Add current request
    r.zadd(key, {f"req_{current_time}": current_time})
    r.expire(key, window_seconds)
    
    return False
```

#### Trending Content

**Content Popularity Tracking**

```bash
# Track content views with decay
ZADD trending_content 100 "article1" 150 "article2" 80 "article3"

# Increment view count
ZINCRBY trending_content 1 "article1"

# Get trending content
ZREVRANGE trending_content 0 9 WITHSCORES
```

**Time-decay Implementation**

```python
import time
import redis

r = redis.Redis()

def track_view(content_id, decay_factor=0.1):
    current_time = int(time.time())
    
    # Apply time decay to existing scores
    pipeline = r.pipeline()
    
    # Get all content with scores
    content_scores = r.zrange("trending", 0, -1, withscores=True)
    
    for content, score in content_scores:
        # Calculate time-decayed score
        new_score = score * (1 - decay_factor)
        pipeline.zadd("trending", {content: new_score})
    
    # Add/increment current content
    pipeline.zincrby("trending", 1, content_id)
    pipeline.execute()
```

### Performance Considerations

#### Memory Usage

**Score Storage**

- Each score is stored as a 64-bit floating-point number
- Memory usage scales with number of members
- Consider using integer scores when possible for better memory efficiency

**Skiplist Implementation**

- Redis uses skip lists for sorted set implementation
- Provides O(log N) complexity for most operations
- Efficient for both random access and range queries

#### Time Complexity

**Common Operations**

- ZADD: O(log N)
- ZREM: O(log N)
- ZRANGE: O(log N + M) where M is number of elements returned
- ZRANGEBYSCORE: O(log N + M)
- ZRANK: O(log N)
- ZSCORE: O(1)
- ZCOUNT: O(log N)

**Optimization Tips**

- Use LIMIT with range operations to reduce data transfer
- Prefer ZREVRANGE over ZRANGE then reversing in application
- Use ZCARD instead of ZRANGE 0 -1 to get count
- Consider using multiple smaller sorted sets for very large datasets

#### Best Practices

**Key Naming**

```bash
# Good examples
user:123:scores
leaderboard:daily:2024-01-01
trending:articles:tech

# Avoid
user123scores
daily_leaderboard_2024_01_01
```

**Score Design**

- Use meaningful score ranges
- Consider score precision requirements
- Plan for score updates and increments
- Use timestamps for time-based ordering

**Batch Operations**

```bash
# Efficient batch adding
ZADD leaderboard 100 player1 200 player2 300 player3

# Use pipelines for multiple operations
redis-cli --pipe
```

### Advanced Patterns

#### Combining with Other Data Types

**Sorted Set + Hash Pattern**

```bash
# Store ranking in sorted set
ZADD user_scores 1500 user123

# Store detailed data in hash
HSET user:123 name "John" level 45 last_login 1609459200
```

**Sorted Set + Set Pattern**

```bash
# Main leaderboard
ZADD global_leaderboard 1500 user123

# Category-specific rankings
ZADD category:fps:leaderboard 1500 user123
SADD user:123:categories fps strategy
```

#### Expiration and Cleanup

**Automatic Cleanup**

```bash
# Set expiration on the entire sorted set
EXPIRE leaderboard 86400

# Or use separate cleanup process
ZREMRANGEBYSCORE old_events -inf (1609459200)
```

**Sliding Window Pattern**

```python
def maintain_sliding_window(key, window_size, current_time):
    # Remove old entries
    r.zremrangebyscore(key, 0, current_time - window_size)
    
    # Set expiration to clean up empty keys
    r.expire(key, window_size)
```

**Key points:**

- Sorted sets combine uniqueness with automatic ordering by score
- Basic operations include ZADD, ZREM, ZRANGE, and ZREVRANGE for managing members
- Score operations like ZRANK, ZSCORE, and ZCOUNT provide ranking and counting capabilities
- ZRANGEBYSCORE enables powerful range queries based on score values
- Primary use cases include leaderboards, time series data, priority queues, and rate limiting
- Performance is optimized with skip list implementation providing O(log N) complexity
- Advanced patterns combine sorted sets with other Redis data types for complex applications

---

