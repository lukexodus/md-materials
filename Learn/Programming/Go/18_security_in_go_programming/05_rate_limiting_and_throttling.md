## Rate Limiting and Throttling


**Token Bucket Implementation** Basic rate limiting using token bucket algorithm:

```go
import (
    "sync"
    "time"
)

type RateLimiter struct {
    tokens    int
    capacity  int
    refillRate time.Duration
    lastRefill time.Time
    mutex     sync.Mutex
}

func NewRateLimiter(capacity int, refillRate time.Duration) *RateLimiter {
    return &RateLimiter{
        tokens:     capacity,
        capacity:   capacity,
        refillRate: refillRate,
        lastRefill: time.Now(),
    }
}

func (rl *RateLimiter) Allow() bool {
    rl.mutex.Lock()
    defer rl.mutex.Unlock()
    
    now := time.Now()
    elapsed := now.Sub(rl.lastRefill)
    tokensToAdd := int(elapsed / rl.refillRate)
    
    if tokensToAdd > 0 {
        rl.tokens = min(rl.capacity, rl.tokens+tokensToAdd)
        rl.lastRefill = now
    }
    
    if rl.tokens > 0 {
        rl.tokens--
        return true
    }
    
    return false
}
```

**HTTP Rate Limiting Middleware** Middleware for web applications:

```go
func rateLimitMiddleware(limiter *RateLimiter) func(http.Handler) http.Handler {
    return func(next http.Handler) http.Handler {
        return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
            if !limiter.Allow() {
                http.Error(w, "Rate limit exceeded", http.StatusTooManyRequests)
                return
            }
            next.ServeHTTP(w, r)
        })
    }
}
```

**IP-based Rate Limiting** Rate limiting per IP address:

```go
type IPRateLimiter struct {
    limiters map[string]*RateLimiter
    mutex    sync.RWMutex
    capacity int
    refill   time.Duration
}

func NewIPRateLimiter(capacity int, refill time.Duration) *IPRateLimiter {
    return &IPRateLimiter{
        limiters: make(map[string]*RateLimiter),
        capacity: capacity,
        refill:   refill,
    }
}

func (ipl *IPRateLimiter) GetLimiter(ip string) *RateLimiter {
    ipl.mutex.Lock()
    defer ipl.mutex.Unlock()
    
    limiter, exists := ipl.limiters[ip]
    if !exists {
        limiter = NewRateLimiter(ipl.capacity, ipl.refill)
        ipl.limiters[ip] = limiter
    }
    
    return limiter
}
```

