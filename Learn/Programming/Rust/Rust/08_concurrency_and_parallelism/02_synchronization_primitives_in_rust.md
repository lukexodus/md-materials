## Synchronization Primitives in Rust


### Mutex and RwLock

Mutex (mutual exclusion) and RwLock (reader-writer lock) are fundamental synchronization primitives that protect shared data from concurrent access.

**Key Points**

- Both are poisoned if a thread panics while holding the lock
- Used to protect shared mutable state across threads
- Smart pointer design ensures locks are automatically released
- Cannot be moved after creation if they contain non-`Send` data
- Always use `std::sync` versions for threading, not `std::cell` versions

#### Mutex

```rust
use std::sync::{Arc, Mutex};
use std::thread;

// Create a mutex containing a value
let counter = Arc::new(Mutex::new(0));
let mut handles = vec![];

for _ in 0..10 {
    let counter = Arc::clone(&counter);
    let handle = thread::spawn(move || {
        // Lock the mutex to get exclusive access
        let mut num = counter.lock().unwrap();
        *num += 1;
        // Lock is automatically released when `num` goes out of scope
    });
    handles.push(handle);
}

for handle in handles {
    handle.join().unwrap();
}

println!("Result: {}", *counter.lock().unwrap()); // Should print 10
```

#### RwLock

```rust
use std::sync::{Arc, RwLock};
use std::thread;

let data = Arc::new(RwLock::new(vec![1, 2, 3]));
let mut handles = vec![];

// Spawn reader threads
for _ in 0..3 {
    let data = Arc::clone(&data);
    let handle = thread::spawn(move || {
        // Multiple readers can access simultaneously
        let values = data.read().unwrap();
        println!("Values: {:?}", *values);
    });
    handles.push(handle);
}

// Spawn writer thread
let data_writer = Arc::clone(&data);
let writer = thread::spawn(move || {
    // Writer gets exclusive access
    let mut values = data_writer.write().unwrap();
    values.push(4);
});
handles.push(writer);

for handle in handles {
    handle.join().unwrap();
}
```

**Key Points about RwLock**

- Allows multiple readers simultaneously
- Writers get exclusive access
- More efficient than Mutex when reads are common
- More overhead than Mutex for simple operations
- Vulnerable to writer starvation in read-heavy workloads

### Atomic Types

Atomic types provide low-level synchronization primitives for lock-free operations.

**Key Points**

- Perform thread-safe operations without locks
- Available for common integer types, booleans, and pointers
- Operations include load, store, swap, compare-exchange, fetch-and-modify
- Define memory ordering for operations
- Typically faster than locks for simple operations

```rust
use std::sync::atomic::{AtomicBool, AtomicI32, AtomicUsize, Ordering};
use std::thread;

// Create atomic variables
let counter = AtomicI32::new(0);
let running = AtomicBool::new(true);

// Atomically increment counter in multiple threads
let mut handles = vec![];
for _ in 0..10 {
    let handle = thread::spawn(move || {
        // No lock needed, the operation is atomic
        counter.fetch_add(1, Ordering::SeqCst);
    });
    handles.push(handle);
}

// Use atomic flag to signal threads to stop
thread::spawn(move || {
    // Set the flag atomically
    running.store(false, Ordering::SeqCst);
});

// Safely check if we should continue
while running.load(Ordering::SeqCst) {
    // Do work...
}

// Common atomic operations
let value = AtomicI32::new(5);
value.store(10, Ordering::SeqCst);                  // Set value
let current = value.load(Ordering::SeqCst);         // Get value
value.fetch_add(5, Ordering::SeqCst);               // Add 5, return old value
value.fetch_sub(3, Ordering::SeqCst);               // Subtract 3, return old value
value.compare_exchange(12, 20, Ordering::SeqCst, 
                       Ordering::SeqCst);           // CAS operation
```

**Example** Implementing a thread-safe counter using atomics:

```rust
use std::sync::atomic::{AtomicUsize, Ordering};

struct AtomicCounter {
    count: AtomicUsize,
}

impl AtomicCounter {
    fn new() -> Self {
        AtomicCounter {
            count: AtomicUsize::new(0),
        }
    }

    fn increment(&self) -> usize {
        self.count.fetch_add(1, Ordering::SeqCst)
    }

    fn decrement(&self) -> usize {
        self.count.fetch_sub(1, Ordering::SeqCst)
    }

    fn get(&self) -> usize {
        self.count.load(Ordering::SeqCst)
    }
}
```

### Barriers and Condvars

Barriers and condition variables synchronize threads by controlling when they can proceed.

#### Barrier

A barrier ensures all threads reach a synchronization point before any can proceed.

**Key Points**

- Blocks threads until a specific number have reached the barrier
- Useful for phased computations
- Reset automatically after all threads have passed
- Provides a generation counter to track barrier completions

```rust
use std::sync::{Arc, Barrier};
use std::thread;

let barrier = Arc::new(Barrier::new(3)); // 3 threads must reach the barrier
let mut handles = vec![];

for i in 0..3 {
    let b = Arc::clone(&barrier);
    let handle = thread::spawn(move || {
        println!("Thread {} doing work", i);
        
        // Simulate work
        thread::sleep(std::time::Duration::from_millis(i * 100));
        
        println!("Thread {} waiting at barrier", i);
        
        // Wait for all threads to reach this point
        b.wait();
        
        println!("Thread {} continuing after barrier", i);
    });
    handles.push(handle);
}

for handle in handles {
    handle.join().unwrap();
}
```

#### Condition Variables (Condvar)

Condition variables allow threads to wait for a specific condition to become true.

**Key Points**

- Used with a Mutex to protect the condition state
- `wait()` atomically releases the lock and blocks the thread
- `notify_one()` wakes a single waiting thread
- `notify_all()` wakes all waiting threads
- Handles spurious wakeups with a predicate function

```rust
use std::sync::{Arc, Mutex, Condvar};
use std::thread;

// Create a shared condition variable and mutex
let pair = Arc::new((Mutex::new(false), Condvar::new()));
let pair_clone = Arc::clone(&pair);

// Spawn a thread that will set the condition
thread::spawn(move || {
    let (lock, cvar) = &*pair_clone;
    
    // Simulate work
    thread::sleep(std::time::Duration::from_secs(1));
    
    // Update the condition
    let mut ready = lock.lock().unwrap();
    *ready = true;
    
    // Notify all waiting threads
    cvar.notify_all();
});

// Main thread waits for the condition
let (lock, cvar) = &*pair;
let mut ready = lock.lock().unwrap();

// Wait for the condition to become true
while !*ready {
    ready = cvar.wait(ready).unwrap();
}

println!("Condition is now true");
```

**Example** A bounded buffer using Mutex and Condvar:

```rust
use std::sync::{Arc, Mutex, Condvar};
use std::thread;
use std::collections::VecDeque;

struct BoundedQueue<T> {
    queue: Mutex<VecDeque<T>>,
    not_empty: Condvar,
    not_full: Condvar,
    capacity: usize,
}

impl<T> BoundedQueue<T> {
    fn new(capacity: usize) -> Self {
        BoundedQueue {
            queue: Mutex::new(VecDeque::with_capacity(capacity)),
            not_empty: Condvar::new(),
            not_full: Condvar::new(),
            capacity,
        }
    }
    
    fn push(&self, item: T) {
        let mut queue = self.queue.lock().unwrap();
        
        // Wait until there's room in the queue
        while queue.len() == self.capacity {
            queue = self.not_full.wait(queue).unwrap();
        }
        
        queue.push_back(item);
        
        // Notify a waiting consumer
        self.not_empty.notify_one();
    }
    
    fn pop(&self) -> T {
        let mut queue = self.queue.lock().unwrap();
        
        // Wait until there's an item to pop
        while queue.is_empty() {
            queue = self.not_empty.wait(queue).unwrap();
        }
        
        let item = queue.pop_front().unwrap();
        
        // Notify a waiting producer
        self.not_full.notify_one();
        
        item
    }
}
```

### Semaphores (via crates)

Semaphores restrict the number of simultaneous accesses to a shared resource.

**Key Points**

- Not provided in the standard library, but available via crates
- Binary semaphores have two states (like a mutex)
- Counting semaphores allow n simultaneous accesses
- Common implementation: `tokio::sync::Semaphore` or `std-semaphore` crate

```rust
// Using tokio::sync::Semaphore
use tokio::sync::Semaphore;
use std::sync::Arc;

#[tokio::main]
async fn main() {
    // Create a semaphore with 3 permits
    let semaphore = Arc::new(Semaphore::new(3));
    let mut handles = vec![];
    
    for i in 0..5 {
        let sem = Arc::clone(&semaphore);
        let handle = tokio::spawn(async move {
            // Acquire a permit
            let permit = sem.acquire().await.unwrap();
            println!("Task {} acquired a permit", i);
            
            // Simulate work
            tokio::time::sleep(tokio::time::Duration::from_secs(1)).await;
            
            println!("Task {} releasing permit", i);
            // Permit is released when dropped
            drop(permit);
        });
        handles.push(handle);
    }
    
    for handle in handles {
        handle.await.unwrap();
    }
}
```

**Example** Using a semaphore to limit concurrent HTTP requests:

```rust
use tokio::sync::Semaphore;
use std::sync::Arc;
use reqwest::Client;

async fn fetch_with_limit(urls: Vec<String>, max_concurrent: usize) -> Vec<Result<String, reqwest::Error>> {
    let client = Client::new();
    let semaphore = Arc::new(Semaphore::new(max_concurrent));
    let mut handles = vec![];
    
    for url in urls {
        let sem = Arc::clone(&semaphore);
        let client = client.clone();
        
        let handle = tokio::spawn(async move {
            // Acquire permit before making request
            let _permit = sem.acquire().await.unwrap();
            
            // Make the HTTP request
            let response = client.get(&url).send().await?;
            let body = response.text().await?;
            
            // Permit is automatically released when _permit is dropped
            Ok::<String, reqwest::Error>(body)
        });
        
        handles.push(handle);
    }
    
    let mut results = vec![];
    for handle in handles {
        results.push(handle.await.unwrap());
    }
    
    results
}
```

### Memory Ordering Models

Memory ordering specifies how operations on shared memory are ordered between threads.

**Key Points**

- Relaxed ordering allows for maximum performance but minimum guarantees
- Acquire-release provides synchronization between threads
- Sequential consistency provides strongest guarantees but lowest performance
- Orderings form a hierarchy: Relaxed < Acquire/Release < SeqCst
- Affects visibility of operations across different threads
- Crucial for correct lock-free algorithms

```rust
use std::sync::atomic::{AtomicBool, AtomicUsize, Ordering};
use std::thread;

// Memory ordering example
let flag = AtomicBool::new(false);
let data = AtomicUsize::new(0);

// Thread to set data and signal it's ready
thread::spawn(move || {
    data.store(42, Ordering::Relaxed);
    // Use Release ordering to establish happens-before relationship
    flag.store(true, Ordering::Release);
});

// Thread to read data when ready
thread::spawn(move || {
    // Use Acquire ordering to see the changes from Release
    while !flag.load(Ordering::Acquire) {
        thread::yield_now();
    }
    
    // Now safe to read data, guaranteed to see 42
    assert_eq!(data.load(Ordering::Relaxed), 42);
});
```

Memory ordering types:

1. **Relaxed (Ordering::Relaxed)**
    
    - No synchronization between threads
    - Only guarantees atomicity
    - Fastest but least guarantees
    - Use for simple counters or when other synchronization is in place
2. **Acquire (Ordering::Acquire)**
    
    - Used for reading/loading values
    - Guarantees all subsequent reads/writes in this thread see writes from other threads before this operation
    - Part of acquire-release synchronization
3. **Release (Ordering::Release)**
    
    - Used for writing/storing values
    - Guarantees all previous reads/writes in this thread are visible to other threads that acquire after this operation
    - Complementary to Acquire
4. **AcqRel (Ordering::AcqRel)**
    
    - Combines Acquire and Release semantics
    - Used for read-modify-write operations
    - Both reads from previous operations and writes for subsequent operations
5. **SeqCst (Ordering::SeqCst)**
    
    - Strongest ordering guarantee
    - All threads see the same global order of operations
    - Safest choice but potentially slowest
    - Use when unsure

### Lock-Free Programming Concepts

Lock-free programming aims to avoid traditional locks while maintaining thread safety.

**Key Points**

- Avoids issues with locks: deadlocks, priority inversion
- Scales better under contention
- Uses atomic operations and careful memory ordering
- Significantly harder to get right than lock-based code
- Often compromises between performance and complexity

**Common Lock-Free Patterns:**

#### 1. Compare-And-Swap (CAS) Operations

```rust
use std::sync::atomic::{AtomicUsize, Ordering};

fn increment_with_cas(counter: &AtomicUsize) -> usize {
    let mut current = counter.load(Ordering::Relaxed);
    loop {
        let new_value = current + 1;
        // Try to swap the current value with new_value
        match counter.compare_exchange(
            current,
            new_value,
            Ordering::SeqCst,
            Ordering::Relaxed,
        ) {
            Ok(previous) => return previous, // Success, return old value
            Err(actual) => current = actual, // Failed, try again with updated value
        }
    }
}
```

#### 2. Double-Checked Locking Pattern

```rust
use std::sync::{Arc, Mutex, atomic::{AtomicBool, Ordering}};
use std::thread;

struct LazyInitialized {
    initialized: AtomicBool,
    data: Mutex<Option<Vec<u8>>>,
}

impl LazyInitialized {
    fn new() -> Self {
        LazyInitialized {
            initialized: AtomicBool::new(false),
            data: Mutex::new(None),
        }
    }
    
    fn get_data(&self) -> Vec<u8> {
        // Fast path: check if initialized without locking
        if !self.initialized.load(Ordering::Acquire) {
            // Slow path: acquire lock and check again
            let mut data = self.data.lock().unwrap();
            if data.is_none() {
                // Initialize the data
                *data = Some(vec![1, 2, 3]);
                // Signal that initialization is complete
                self.initialized.store(true, Ordering::Release);
            }
        }
        
        // Data is guaranteed to be initialized now
        self.data.lock().unwrap().clone().unwrap()
    }
}
```

#### 3. ABA Problem and Solutions

```rust
use std::sync::atomic::{AtomicUsize, Ordering};

// ABA problem happens when a value changes from A to B and back to A
// A thread might think nothing changed when actually something did

// Solution: Use version counter (tag) with the pointer
struct TaggedPointer<T> {
    // In real implementations, this would be a single AtomicU128 or similar
    ptr: AtomicUsize,     // Pointer to data
    tag: AtomicUsize,     // Version counter
}

impl<T> TaggedPointer<T> {
    fn new(ptr: *mut T) -> Self {
        TaggedPointer {
            ptr: AtomicUsize::new(ptr as usize),
            tag: AtomicUsize::new(0),
        }
    }
    
    fn compare_exchange(&self, old_ptr: *mut T, old_tag: usize, 
                       new_ptr: *mut T, new_tag: usize) -> Result<(), ()> {
        // Check if pointer and tag match expected values
        if self.ptr.load(Ordering::SeqCst) == old_ptr as usize &&
           self.tag.load(Ordering::SeqCst) == old_tag {
            
            // Update both atomically in a real implementation
            self.ptr.store(new_ptr as usize, Ordering::SeqCst);
            self.tag.store(new_tag, Ordering::SeqCst);
            Ok(())
        } else {
            Err(())
        }
    }
}
```

#### 4. Lock-Free Queue Example

```rust
use std::sync::atomic::{AtomicPtr, Ordering};
use std::ptr;

struct Node<T> {
    data: T,
    next: AtomicPtr<Node<T>>,
}

struct LockFreeQueue<T> {
    head: AtomicPtr<Node<T>>,
    tail: AtomicPtr<Node<T>>,
}

impl<T> LockFreeQueue<T> {
    fn new() -> Self {
        // Create a dummy node
        let dummy = Box::into_raw(Box::new(Node {
            data: unsafe { std::mem::uninitialized() },
            next: AtomicPtr::new(ptr::null_mut()),
        }));
        
        LockFreeQueue {
            head: AtomicPtr::new(dummy),
            tail: AtomicPtr::new(dummy),
        }
    }
    
    fn enqueue(&self, data: T) {
        let new_node = Box::into_raw(Box::new(Node {
            data,
            next: AtomicPtr::new(ptr::null_mut()),
        }));
        
        loop {
            let tail = self.tail.load(Ordering::Acquire);
            let next = unsafe { (*tail).next.load(Ordering::Acquire) };
            
            // Check if tail is still the same
            if tail == self.tail.load(Ordering::Acquire) {
                if next.is_null() {
                    // Try to link new node at the end
                    match unsafe { (*tail).next.compare_exchange(
                        ptr::null_mut(),
                        new_node,
                        Ordering::Release,
                        Ordering::Relaxed,
                    ) } {
                        Ok(_) => {
                            // Link successful, try to update tail
                            let _ = self.tail.compare_exchange(
                                tail,
                                new_node,
                                Ordering::Release,
                                Ordering::Relaxed,
                            );
                            return;
                        }
                        Err(_) => continue, // Another thread updated next, retry
                    }
                } else {
                    // Tail is falling behind, help advance it
                    let _ = self.tail.compare_exchange(
                        tail,
                        next,
                        Ordering::Release,
                        Ordering::Relaxed,
                    );
                }
            }
        }
    }
    
    // Dequeue implementation would follow similar pattern
}
```

**Conclusion** Rust's synchronization primitives provide a comprehensive toolkit for safe concurrent programming. From high-level abstractions like Mutex and RwLock to low-level atomic operations, Rust gives developers fine-grained control over thread synchronization while maintaining memory safety. The strong type system and ownership model help prevent many common concurrency bugs at compile time, while still allowing for advanced lock-free programming when needed. Understanding the memory ordering models is crucial for correct low-level concurrent code, especially when using atomic operations or implementing lock-free algorithms.

### Related Topics

For deeper understanding of concurrent programming in Rust, explore async/await concurrency model, thread pools (e.g., Rayon for data parallelism), actor model frameworks like Actix, and formal verification techniques for concurrent algorithms. Additionally, learning about cache coherence protocols can provide insight into why certain synchronization patterns perform better than others.

---

