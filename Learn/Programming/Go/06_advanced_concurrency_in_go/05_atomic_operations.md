## Atomic Operations


The sync/atomic package provides low-level atomic memory primitives for implementing lock-free data structures.

**Basic Atomic Operations:**

```go
type AtomicCounter struct {
    value int64
}

func (c *AtomicCounter) Increment() int64 {
    return atomic.AddInt64(&c.value, 1)
}

func (c *AtomicCounter) Load() int64 {
    return atomic.LoadInt64(&c.value)
}

func (c *AtomicCounter) CompareAndSwap(old, new int64) bool {
    return atomic.CompareAndSwapInt64(&c.value, old, new)
}
```

**Lock-Free Queue Implementation:**

```go
type LockFreeQueue struct {
    head unsafe.Pointer
    tail unsafe.Pointer
}

type node struct {
    value interface{}
    next  unsafe.Pointer
}

func (q *LockFreeQueue) Enqueue(value interface{}) {
    newNode := &node{value: value}
    newNodePtr := unsafe.Pointer(newNode)
    
    for {
        tail := atomic.LoadPointer(&q.tail)
        next := atomic.LoadPointer(&(*node)(tail).next)
        
        if tail == atomic.LoadPointer(&q.tail) {
            if next == nil {
                if atomic.CompareAndSwapPointer(&(*node)(tail).next, next, newNodePtr) {
                    break
                }
            } else {
                atomic.CompareAndSwapPointer(&q.tail, tail, next)
            }
        }
    }
    atomic.CompareAndSwapPointer(&q.tail, atomic.LoadPointer(&q.tail), newNodePtr)
}
```

**Atomic Value for Configuration:**

```go
type Config struct {
    Timeout time.Duration
    MaxConn int
}

type Service struct {
    config atomic.Value
}

func (s *Service) UpdateConfig(cfg Config) {
    s.config.Store(cfg)
}

func (s *Service) GetConfig() Config {
    return s.config.Load().(Config)
}
```

