## Rate Limiting


Rate limiting prevents abuse, protects infrastructure, and ensures fair resource allocation across users.

**Built-in rate limits:**

Supabase implements rate limiting at multiple layers:

**API request limits [Unverified - specific values may vary by plan]:**

- REST API requests per minute per IP address
- Realtime connection limits per project
- Authentication operations per hour
- Storage API operations per second

**Plan-based limits:**

- **Free tier**: Lower limits suitable for development and small projects
- **Pro tier**: Higher limits with burst capacity
- **Team/Enterprise**: Custom limits negotiated based on needs

**Rate limit response:**

When exceeded, the API returns:

```
HTTP/1.1 429 Too Many Requests
Content-Type: application/json

{
  "message": "API rate limit exceeded",
  "hint": "Retry after some time"
}
```

Response headers indicate current status:

```
X-RateLimit-Limit: 500
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1640000060
Retry-After: 60
```

**Application-level rate limiting:**

Implement additional rate limiting in Edge Functions:

```javascript
// Simple in-memory rate limiter (for single-instance Edge Functions)
const rateLimits = new Map();

function checkRateLimit(userId, maxRequests = 10, windowMs = 60000) {
  const now = Date.now();
  const userLimits = rateLimits.get(userId) || { count: 0, resetTime: now + windowMs };
  
  // Reset if window expired
  if (now > userLimits.resetTime) {
    userLimits.count = 0;
    userLimits.resetTime = now + windowMs;
  }
  
  userLimits.count++;
  rateLimits.set(userId, userLimits);
  
  if (userLimits.count > maxRequests) {
    return {
      allowed: false,
      retryAfter: Math.ceil((userLimits.resetTime - now) / 1000)
    };
  }
  
  return { allowed: true };
}
```

**Database-level rate limiting:**

Track and limit actions using database tables:

```sql
CREATE TABLE rate_limits (
  user_id UUID NOT NULL,
  action TEXT NOT NULL,
  count INTEGER NOT NULL DEFAULT 1,
  window_start TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY (user_id, action, window_start)
);

CREATE FUNCTION check_rate_limit(
  p_user_id UUID,
  p_action TEXT,
  p_max_requests INTEGER,
  p_window_interval INTERVAL
)
RETURNS BOOLEAN AS $$
DECLARE
  v_count INTEGER;
BEGIN
  -- Clean old windows
  DELETE FROM rate_limits
  WHERE window_start < NOW() - p_window_interval;
  
  -- Get current count
  SELECT COALESCE(SUM(count), 0) INTO v_count
  FROM rate_limits
  WHERE user_id = p_user_id
    AND action = p_action
    AND window_start >= NOW() - p_window_interval;
  
  -- Check limit
  IF v_count >= p_max_requests THEN
    RETURN FALSE;
  END IF;
  
  -- Increment count
  INSERT INTO rate_limits (user_id, action, window_start, count)
  VALUES (p_user_id, p_action, DATE_TRUNC('minute', NOW()), 1)
  ON CONFLICT (user_id, action, window_start)
  DO UPDATE SET count = rate_limits.count + 1;
  
  RETURN TRUE;
END;
$$ LANGUAGE plpgsql;
```

**Client-side strategies:**

**Exponential backoff:**

```javascript
async function fetchWithRetry(fetchFn, maxRetries = 3) {
  for (let i = 0; i < maxRetries; i++) {
    try {
      const result = await fetchFn();
      return result;
    } catch (error) {
      if (error.status === 429) {
        const retryAfter = error.headers?.['retry-after'] || Math.pow(2, i);
        await new Promise(resolve => setTimeout(resolve, retryAfter * 1000));
        continue;
      }
      throw error;
    }
  }
  throw new Error('Max retries exceeded');
}
```

**Request throttling:**

```javascript
// Throttle requests using a queue
class RequestQueue {
  constructor(maxRequestsPerSecond) {
    this.queue = [];
    this.processing = false;
    this.interval = 1000 / maxRequestsPerSecond;
  }
  
  async enqueue(request) {
    return new Promise((resolve, reject) => {
      this.queue.push({ request, resolve, reject });
      this.process();
    });
  }
  
  async process() {
    if (this.processing || this.queue.length === 0) return;
    
    this.processing = true;
    const { request, resolve, reject } = this.queue.shift();
    
    try {
      const result = await request();
      resolve(result);
    } catch (error) {
      reject(error);
    }
    
    setTimeout(() => {
      this.processing = false;
      this.process();
    }, this.interval);
  }
}
```

**Mitigation strategies:**

- Cache frequently accessed data client-side
- Use Realtime subscriptions instead of polling
- Batch operations when possible
- Implement pagination for large datasets
- Use efficient queries with proper filtering and selection
- Upgrade to higher-tier plans for increased limits
- Distribute load across multiple API keys for microservices [Inference: This may violate terms of service; verify documentation]

**Monitoring:**

Track rate limit headers in your application:

```javascript
const { data, error } = await supabase.from('users').select('*');

// Check response headers (if accessible in your client library)
const remaining = response.headers['x-ratelimit-remaining'];
const resetTime = response.headers['x-ratelimit-reset'];

if (remaining < 10) {
  console.warn('Approaching rate limit');
}
```

