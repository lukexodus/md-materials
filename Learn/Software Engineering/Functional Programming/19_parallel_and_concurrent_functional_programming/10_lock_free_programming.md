## Lock-Free Programming


Lock-free programming uses atomic operations and clever algorithms to coordinate concurrent access without blocking threads. A lock-free algorithm guarantees system-wide progress even if individual threads are delayed or suspended.

**Atomic Operations**

Modern processors provide atomic compare-and-swap (CAS) operations that form the foundation of lock-free algorithms:

```javascript
// Simulated CAS operation (JavaScript doesn't expose true CAS)
class AtomicReference {
  constructor(value) {
    this.value = value;
  }

  compareAndSet(expected, newValue) {
    if (this.value === expected) {
      this.value = newValue;
      return true;
    }
    return false;
  }

  get() {
    return this.value;
  }
}
```

**Lock-Free Stack**

Implement a concurrent stack using CAS:

```javascript
class LockFreeStack {
  constructor() {
    this.head = new AtomicReference(null);
  }

  push(value) {
    const newNode = { value, next: null };
    while (true) {
      const currentHead = this.head.get();
      newNode.next = currentHead;
      if (this.head.compareAndSet(currentHead, newNode)) {
        return;
      }
      // CAS failed, retry with updated head
    }
  }

  pop() {
    while (true) {
      const currentHead = this.head.get();
      if (currentHead === null) {
        return null;
      }
      if (this.head.compareAndSet(currentHead, currentHead.next)) {
        return currentHead.value;
      }
      // CAS failed, retry with updated head
    }
  }
}

// Multiple threads can push/pop without locks
const stack = new LockFreeStack();
stack.push(1);
stack.push(2);
console.log(stack.pop()); // 2
```

**Lock-Free Queue**

Michael-Scott queue algorithm for concurrent FIFO access:

```javascript
class LockFreeQueue {
  constructor() {
    const sentinel = { value: null, next: new AtomicReference(null) };
    this.head = new AtomicReference(sentinel);
    this.tail = new AtomicReference(sentinel);
  }

  enqueue(value) {
    const newNode = { value, next: new AtomicReference(null) };
    while (true) {
      const currentTail = this.tail.get();
      const tailNext = currentTail.next.get();

      if (currentTail === this.tail.get()) {
        if (tailNext === null) {
          if (currentTail.next.compareAndSet(null, newNode)) {
            this.tail.compareAndSet(currentTail, newNode);
            return;
          }
        } else {
          this.tail.compareAndSet(currentTail, tailNext);
        }
      }
    }
  }

  dequeue() {
    while (true) {
      const currentHead = this.head.get();
      const currentTail = this.tail.get();
      const headNext = currentHead.next.get();

      if (currentHead === this.head.get()) {
        if (currentHead === currentTail) {
          if (headNext === null) {
            return null; // Queue is empty
          }
          this.tail.compareAndSet(currentTail, headNext);
        } else {
          const value = headNext.value;
          if (this.head.compareAndSet(currentHead, headNext)) {
            return value;
          }
        }
      }
    }
  }
}
```

**ABA Problem and Solutions**

The ABA problem occurs when a value changes from A to B and back to A, fooling CAS:

```javascript
// Problem: Thread 1 reads A, gets suspended
// Thread 2 changes A→B→A
// Thread 1 resumes, CAS succeeds but state actually changed

// Solution: Add version numbers
class VersionedReference {
  constructor(value) {
    this.value = value;
    this.version = 0;
  }

  compareAndSet(expectedValue, expectedVersion, newValue) {
    if (this.value === expectedValue && this.version === expectedVersion) {
      this.value = newValue;
      this.version++;
      return true;
    }
    return false;
  }

  get() {
    return { value: this.value, version: this.version };
  }
}
```

**Lock-Free Counter**

Increment a counter without locks using atomic operations:

```javascript
class LockFreeCounter {
  constructor() {
    this.count = new AtomicReference(0);
  }

  increment() {
    while (true) {
      const current = this.count.get();
      if (this.count.compareAndSet(current, current + 1)) {
        return current + 1;
      }
    }
  }

  decrement() {
    while (true) {
      const current = this.count.get();
      if (this.count.compareAndSet(current, current - 1)) {
        return current - 1;
      }
    }
  }

  get() {
    return this.count.get();
  }
}

// Multiple threads can increment/decrement safely
const counter = new LockFreeCounter();
Promise.all([
  Promise.resolve(counter.increment()),
  Promise.resolve(counter.increment()),
  Promise.resolve(counter.increment())
]).then(() => console.log(counter.get())); // 3
```

**Treiber Stack with Elimination**

Optimize contention using elimination arrays:

```javascript
class EliminationBackoffStack {
  constructor() {
    this.stack = new LockFreeStack();
    this.eliminationArray = Array(10).fill(null).map(() => new AtomicReference(null));
  }

  push(value) {
    // Try elimination first
    const slot = Math.floor(Math.random() * this.eliminationArray.length);
    const exchangePoint = this.eliminationArray[slot];
    
    if (exchangePoint.compareAndSet(null, { type: 'push', value })) {
      // Wait for matching pop
      const start = Date.now();
      while (Date.now() - start < 100) {
        const current = exchangePoint.get();
        if (current && current.type === 'matched') {
          exchangePoint.compareAndSet(current, null);
          return; // Eliminated!
        }
      }
      exchangePoint.compareAndSet({ type: 'push', value }, null);
    }

    // Elimination failed, use stack
    this.stack.push(value);
  }

  pop() {
    // Similar elimination logic for pop
    // Falls back to stack.pop() if elimination fails
    return this.stack.pop();
  }
}
```

**Work Stealing Deque**

Lock-free double-ended queue for work stealing schedulers:

```javascript
class WorkStealingDeque {
  constructor() {
    this.buffer = new Array(32);
    this.top = new AtomicReference(0);
    this.bottom = 0;
  }

  push(task) {
    const b = this.bottom;
    this.buffer[b % this.buffer.length] = task;
    this.bottom = b + 1;
  }

  pop() {
    this.bottom = this.bottom - 1;
    const b = this.bottom;
    const t = this.top.get();

    if (b < t) {
      this.bottom = t;
      return null;
    }

    const task = this.buffer[b % this.buffer.length];
    if (b > t) {
      return task;
    }

    // Last element, race with steal
    if (this.top.compareAndSet(t, t + 1)) {
      this.bottom = t + 1;
      return task;
    }

    this.bottom = t + 1;
    return null;
  }

  steal() {
    while (true) {
      const t = this.top.get();
      const b = this.bottom;

      if (t >= b) {
        return null;
      }

      const task = this.buffer[t % this.buffer.length];
      if (this.top.compareAndSet(t, t + 1)) {
        return task;
      }
    }
  }
}
```

**Memory Ordering and Barriers**

[Inference] Lock-free algorithms may require memory barriers to ensure visibility of updates across cores. JavaScript's memory model provides sequential consistency, but lower-level languages require explicit barriers.

```javascript
// Conceptual example - JavaScript handles this automatically
class LockFreeFlag {
  constructor() {
    this.flag = new AtomicReference(false);
    this.data = null;
  }

  publish(value) {
    this.data = value;
    // Memory barrier ensures data write visible before flag
    this.flag.compareAndSet(false, true);
  }

  tryConsume() {
    if (this.flag.compareAndSet(true, false)) {
      // Memory barrier ensures we see data write
      return this.data;
    }
    return null;
  }
}
```

**Hazard Pointers**

Safe memory reclamation in lock-free data structures:

```javascript
class HazardPointerSystem {
  constructor() {
    this.hazards = new Map();
    this.retireList = [];
  }

  protect(threadId, pointer) {
    this.hazards.set(threadId, pointer);
  }

  unprotect(threadId) {
    this.hazards.delete(threadId);
  }

  retire(pointer) {
    this.retireList.push(pointer);
    if (this.retireList.length > 100) {
      this.scan();
    }
  }

  scan() {
    const protected = new Set(this.hazards.values());
    this.retireList = this.retireList.filter(ptr => {
      if (!protected.has(ptr)) {
        // Safe to reclaim
        return false;
      }
      return true;
    });
  }
}
```

**Key Points**

- Lock-free algorithms use atomic CAS operations instead of locks
- Retry loops handle contention without blocking threads
- System-wide progress guaranteed even if individual threads stall
- ABA problem requires version counters or hazard pointers
- Memory ordering is critical for correctness across cores
- Elimination techniques reduce contention in high-concurrency scenarios
- More complex than locks but provides better scalability and progress guarantees

---

