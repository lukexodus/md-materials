## Threads in Rust


### Spawning Threads

Rust provides a standard library module `std::thread` for creating and managing threads. Threads allow for concurrent execution of code, enabling programs to perform multiple operations simultaneously.

**Key Points**

- Threads run independently and can execute in parallel on multicore systems
- Each thread has its own stack but shares the heap with other threads
- Rust's ownership system prevents many common concurrency bugs at compile time
- Thread creation is explicit in Rust, giving fine-grained control over concurrency

The basic way to create a thread is with `std::thread::spawn`:

```rust
use std::thread;
use std::time::Duration;

fn main() {
    // Spawn a new thread
    let handle = thread::spawn(|| {
        println!("Hello from a thread!");
        
        // Simulate some work
        thread::sleep(Duration::from_millis(1000));
        
        println!("Thread finished work!");
    });
    
    println!("Main thread continues execution...");
    
    // Main thread continues execution while the spawned thread runs
    thread::sleep(Duration::from_millis(500));
    println!("Main thread did some work too.");
    
    // Wait for the spawned thread to finish
    handle.join().unwrap();
    println!("All threads finished!");
}
```

To use data from the parent thread, you need to move ownership with the `move` keyword:

```rust
use std::thread;

fn main() {
    let message = String::from("Hello from main thread!");
    
    // Use move to transfer ownership of captured variables
    let handle = thread::spawn(move || {
        println!("In thread: {}", message);
        // message is now owned by this thread closure
    });
    
    // This would cause a compile error since `message` was moved:
    // println!("In main: {}", message);
    
    handle.join().unwrap();
}
```

### Joining Threads

The `join` method on a thread handle waits for the thread to finish execution. This is important for coordinating work between threads and ensuring all threads complete before the program exits.

**Key Points**

- `join()` blocks the current thread until the thread represented by the handle terminates
- Returns a `Result` that contains either the thread's return value or an error if the thread panicked
- Critical for synchronizing work between threads
- Can be used to collect results from multiple threads

```rust
use std::thread;

fn main() {
    let handles: Vec<_> = (0..5)
        .map(|i| {
            thread::spawn(move || {
                // This value will be returned from the thread
                i * i
            })
        })
        .collect();
    
    // Wait for all threads to complete and collect their results
    let results: Vec<_> = handles
        .into_iter()
        .map(|handle| handle.join().unwrap())
        .collect();
    
    println!("Results: {:?}", results); // [0, 1, 4, 9, 16]
}
```

If a thread panics, `join` will return an `Err`:

```rust
use std::thread;

fn main() {
    let handle = thread::spawn(|| {
        panic!("Thread panicked!");
    });
    
    // Handle the result of join
    match handle.join() {
        Ok(value) => println!("Thread completed successfully with: {:?}", value),
        Err(e) => println!("Thread panicked: {:?}", e),
    }
}
```

### Thread Builder API

The `Builder` type in the `thread` module provides more control over thread creation including naming threads, setting stack size, and more.

**Key Points**

- Allows setting thread name for better debugging
- Can configure stack size
- Uses a builder pattern for configuration
- Gives more fine-grained control than `spawn`

```rust
use std::thread;

fn main() {
    // Create a thread with custom settings
    let builder = thread::Builder::new()
        .name("worker-thread".to_string())
        .stack_size(4 * 1024 * 1024); // 4MB stack
    
    // Spawn the thread with the builder
    let handle = builder
        .spawn(|| {
            // Get current thread to check name
            let current = thread::current();
            println!("Running in thread: {}", current.name().unwrap());
            
            // Do some work
            for i in 1..5 {
                println!("Worker thread: iteration {}", i);
                thread::sleep(std::time::Duration::from_millis(500));
            }
        })
        .unwrap();
    
    // Wait for the thread to complete
    handle.join().unwrap();
}
```

### Thread Local Storage

Thread Local Storage (TLS) provides a way to store data that is accessible only from the thread that created it. It's useful for thread-specific data that would otherwise require complex synchronization.

**Key Points**

- Each thread gets its own independent instance of the value
- Declared with the `thread_local!` macro
- Accessed with the `with` method that takes a closure
- Great for thread-specific caches, IDs, or state

```rust
use std::cell::RefCell;
use std::thread;

// Declare thread local storage
thread_local! {
    static COUNTER: RefCell<u32> = RefCell::new(0);
    static THREAD_ID: RefCell<String> = RefCell::new(String::new());
}

fn main() {
    // Initialize the main thread's ID
    THREAD_ID.with(|id| {
        *id.borrow_mut() = "main".to_string();
    });
    
    // Increment the counter in the main thread
    for _ in 0..5 {
        COUNTER.with(|counter| {
            *counter.borrow_mut() += 1;
            println!("[{}] Counter: {}", 
                     THREAD_ID.with(|id| id.borrow().clone()),
                     counter.borrow());
        });
    }
    
    // Create a few threads, each with their own counter
    let handles: Vec<_> = (0..3)
        .map(|i| {
            thread::spawn(move || {
                // Set this thread's ID
                let thread_name = format!("thread-{}", i);
                THREAD_ID.with(|id| {
                    *id.borrow_mut() = thread_name.clone();
                });
                
                // Each thread has its own counter starting from 0
                for _ in 0..3 {
                    COUNTER.with(|counter| {
                        *counter.borrow_mut() += 1;
                        println!("[{}] Counter: {}", 
                                 THREAD_ID.with(|id| id.borrow().clone()),
                                 counter.borrow());
                    });
                    thread::sleep(std::time::Duration::from_millis(100));
                }
            })
        })
        .collect();
    
    // Wait for all threads to complete
    for handle in handles {
        handle.join().unwrap();
    }
    
    // The main thread's counter is unchanged by the other threads
    COUNTER.with(|counter| {
        println!("[main] Final counter value: {}", counter.borrow());
    });
}
```

**Output**

```
[main] Counter: 1
[main] Counter: 2
[main] Counter: 3
[main] Counter: 4
[main] Counter: 5
[thread-0] Counter: 1
[thread-1] Counter: 1
[thread-2] Counter: 1
[thread-0] Counter: 2
[thread-1] Counter: 2
[thread-2] Counter: 2
[thread-0] Counter: 3
[thread-1] Counter: 3
[thread-2] Counter: 3
[main] Final counter value: 5
```

### Thread Panics

When a thread panics, it starts unwinding its stack, running destructors for all variables in scope. Unlike some languages, a thread panic in Rust doesn't bring down the entire process by default (though it can if the panic occurs in the main thread).

**Key Points**

- Thread panics are contained to the thread where they occur
- `catch_unwind` can be used to catch a panic within a thread
- The `panic` hook can be customized to handle panics differently
- Destructors still run during unwinding, maintaining resource safety

```rust
use std::thread;
use std::panic;

fn main() {
    // Set a custom panic hook
    panic::set_hook(Box::new(|panic_info| {
        if let Some(location) = panic_info.location() {
            println!(
                "Panic occurred in file '{}' at line {}",
                location.file(),
                location.line()
            );
        } else {
            println!("Panic occurred but can't get location info");
        }
        
        if let Some(message) = panic_info.payload().downcast_ref::<&str>() {
            println!("Panic message: {}", message);
        }
    }));
    
    // Spawn a thread that will panic
    let handle = thread::spawn(|| {
        println!("Thread running...");
        panic!("Something went wrong!");
        // This code won't be reached
    });
    
    // Join will return Err since the thread panicked
    let thread_result = handle.join();
    println!("Thread completed with result: {:?}", thread_result);
    
    // Using catch_unwind to catch a panic
    let result = panic::catch_unwind(|| {
        println!("Code that might panic");
        // panic!("Another panic");
        "Success"
    });
    
    match result {
        Ok(value) => println!("Operation completed successfully: {}", value),
        Err(_) => println!("Operation panicked"),
    }
}
```

If you want a panic in any thread to stop the entire program, you can use `std::panic::resume_unwind`:

```rust
use std::thread;
use std::panic;

fn main() {
    let handle = thread::spawn(|| {
        panic!("Thread panicked!");
    });
    
    // If the thread panicked, propagate the panic to the main thread
    match handle.join() {
        Ok(_) => println!("Thread completed successfully"),
        Err(e) => {
            println!("Thread panicked, now propagating to main thread");
            panic::resume_unwind(e);
        }
    }
    
    println!("This line won't be reached if the thread panicked");
}
```

### Thread Safety Patterns

Rust's ownership system prevents many common concurrency bugs, but you still need patterns to share and mutate data safely across threads.

**Key Points**

- Rust's type system enforces thread safety through traits like `Send` and `Sync`
- Several synchronization primitives are available for different use cases
- Choose the right primitive based on your sharing pattern needs
- Message passing is often preferable to shared state

#### Send and Sync Traits

- `Send`: Types that can be transferred across thread boundaries
- `Sync`: Types that can be shared between threads (i.e., `&T` is `Send`)

These traits are automatically implemented when applicable and are used by the compiler to ensure thread safety.

#### Mutex for Exclusive Access

```rust
use std::sync::{Arc, Mutex};
use std::thread;

fn main() {
    // Arc provides thread-safe reference counting
    // Mutex provides exclusive access to the data
    let counter = Arc::new(Mutex::new(0));
    let mut handles = vec![];
    
    for _ in 0..10 {
        let counter = Arc::clone(&counter);
        let handle = thread::spawn(move || {
            // Lock the mutex to get exclusive access
            let mut num = counter.lock().unwrap();
            *num += 1;
            // Mutex is automatically unlocked when `num` goes out of scope
        });
        handles.push(handle);
    }
    
    // Wait for all threads to complete
    for handle in handles {
        handle.join().unwrap();
    }
    
    println!("Final count: {}", *counter.lock().unwrap()); // 10
}
```

#### RwLock for Reader-Writer Patterns

```rust
use std::sync::{Arc, RwLock};
use std::thread;

fn main() {
    let data = Arc::new(RwLock::new(vec![1, 2, 3]));
    let mut handles = vec![];
    
    // Spawn reader threads
    for i in 0..3 {
        let data = Arc::clone(&data);
        handles.push(thread::spawn(move || {
            // Multiple threads can read at the same time
            let values = data.read().unwrap();
            println!("Reader {}: {:?}", i, *values);
        }));
    }
    
    // Spawn writer thread
    {
        let data = Arc::clone(&data);
        handles.push(thread::spawn(move || {
            // Only one thread can write at a time
            let mut values = data.write().unwrap();
            values.push(4);
            println!("Writer: {:?}", *values);
        }));
    }
    
    // Wait for all threads
    for handle in handles {
        handle.join().unwrap();
    }
    
    println!("Final data: {:?}", *data.read().unwrap());
}
```

#### Atomic Types for Simple Counters

```rust
use std::sync::atomic::{AtomicU64, Ordering};
use std::sync::Arc;
use std::thread;

fn main() {
    // AtomicU64 allows for thread-safe operations without a mutex
    let counter = Arc::new(AtomicU64::new(0));
    let mut handles = vec![];
    
    for _ in 0..10 {
        let counter = Arc::clone(&counter);
        let handle = thread::spawn(move || {
            // Atomically increment the counter
            counter.fetch_add(1, Ordering::SeqCst);
        });
        handles.push(handle);
    }
    
    for handle in handles {
        handle.join().unwrap();
    }
    
    println!("Final count: {}", counter.load(Ordering::SeqCst)); // 10
}
```

#### Message Passing with Channels

```rust
use std::sync::mpsc;
use std::thread;
use std::time::Duration;

fn main() {
    // Create a channel for sending messages between threads
    let (tx, rx) = mpsc::channel();
    
    // Clone the transmitter for multiple producer threads
    let tx1 = tx.clone();
    
    thread::spawn(move || {
        let messages = vec![
            String::from("hello"),
            String::from("from"),
            String::from("the"),
            String::from("thread"),
        ];
        
        for msg in messages {
            tx1.send(msg).unwrap();
            thread::sleep(Duration::from_millis(100));
        }
    });
    
    thread::spawn(move || {
        let messages = vec![
            String::from("more"),
            String::from("messages"),
            String::from("for"),
            String::from("you"),
        ];
        
        for msg in messages {
            tx.send(msg).unwrap();
            thread::sleep(Duration::from_millis(150));
        }
    });
    
    // The main thread receives all messages
    for received in rx {
        println!("Got: {}", received);
    }
}
```

#### Barriers for Thread Synchronization

```rust
use std::sync::{Arc, Barrier};
use std::thread;

fn main() {
    let mut handles = Vec::with_capacity(10);
    let barrier = Arc::new(Barrier::new(10));
    
    for i in 0..10 {
        let b = Arc::clone(&barrier);
        handles.push(thread::spawn(move || {
            println!("Thread {} is waiting at the barrier", i);
            
            // Wait until all threads reach this point
            b.wait();
            
            println!("Thread {} has passed the barrier", i);
        }));
    }
    
    for handle in handles {
        handle.join().unwrap();
    }
}
```

**Conclusion**

Rust's threading model provides powerful tools for concurrent programming while maintaining memory safety guarantees. By leveraging Rust's ownership system and thread-safe abstractions, you can write concurrent code that is both safe and efficient.

Key patterns to remember include:

- Use `Arc` (Atomic Reference Counting) to share ownership between threads
- Choose the appropriate synchronization primitive for your needs
- Consider message passing with channels for cleaner thread communication
- Let Rust's type system help you by enforcing `Send` and `Sync` requirements

Related topics worth exploring:

- Rayon for parallel iteration
- Async/await for asynchronous programming
- Thread pools for efficient thread reuse
- Crossbeam for advanced concurrency primitives
- Parking_lot for faster mutexes and other synchronization primitives

---

