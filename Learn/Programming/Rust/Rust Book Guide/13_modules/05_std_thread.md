## `std::thread`


The `std::thread` module in Rust provides functionality for creating and managing threads, enabling concurrent execution of code. Rust threads are lightweight and safe due to Rust’s ownership and borrowing rules, which prevent data races at compile time.

### **Creating a New Thread**

Use `std::thread::spawn` to create a new thread.

```rust
use std::thread;

fn main() {
    let handle = thread::spawn(|| {
        println!("Hello from a new thread!");
    });

    handle.join().unwrap(); // Wait for the thread to finish
}
```

### **Moving Ownership into a Thread**

Use `move` to transfer ownership of variables into a thread.

```rust
use std::thread;

fn main() {
    let message = String::from("Hello, Rust!");

    let handle = thread::spawn(move || {
        println!("{}", message);
    });

    handle.join().unwrap();
}
```

---

### **Thread Management**

#### **Waiting for a Thread (Joining)**

The `.join()` method blocks execution until the thread completes.

```rust
use std::thread;

fn main() {
    let handle = thread::spawn(|| {
        for i in 1..5 {
            println!("Thread: {}", i);
        }
    });

    handle.join().unwrap();
    println!("Main thread continues...");
}
```

#### **Detaching a Thread**

If you don't want to wait for a thread to finish, you can let it run independently.

```rust
use std::thread;
use std::time::Duration;

fn main() {
    thread::spawn(|| {
        thread::sleep(Duration::from_secs(2));
        println!("This thread runs independently.");
    });

    println!("Main thread does not wait.");
    thread::sleep(Duration::from_secs(3));
}
```

---

### **Concurrency with Multiple Threads**

#### **Spawning Multiple Threads**

You can create multiple threads using a loop.

```rust
use std::thread;

fn main() {
    let mut handles = vec![];

    for i in 0..5 {
        let handle = thread::spawn(move || {
            println!("Thread {} is running", i);
        });
        handles.push(handle);
    }

    for handle in handles {
        handle.join().unwrap();
    }
}
```

---

### **Thread Communication**

#### **Sharing Data Between Threads (Arc)**

Since Rust enforces ownership rules, you cannot share non-thread-safe types like `Rc<T>` between threads. Instead, use `Arc<T>` (Atomic Reference Counted).

```rust
use std::sync::Arc;
use std::thread;

fn main() {
    let data = Arc::new(vec![1, 2, 3, 4, 5]);

    let mut handles = vec![];

    for i in 0..3 {
        let data = Arc::clone(&data);
        let handle = thread::spawn(move || {
            println!("Thread {}: {:?}", i, data);
        });
        handles.push(handle);
    }

    for handle in handles {
        handle.join().unwrap();
    }
}
```

---

### **Thread Sleeping and Yielding**

#### **Sleeping a Thread**

Use `thread::sleep` to pause execution.

```rust
use std::thread;
use std::time::Duration;

fn main() {
    println!("Sleeping...");
    thread::sleep(Duration::from_secs(2));
    println!("Awake!");
}
```

#### **Yielding Execution**

`thread::yield_now()` allows the scheduler to run another thread before continuing.

```rust
use std::thread;

fn main() {
    println!("Yielding execution...");
    thread::yield_now();
    println!("Back to execution.");
}
```

#### **Getting Thread Information**

#### **`std::thread::current()` – Get the Current Thread Handle**

Retrieves a handle to the currently executing thread.

```rust
use std::thread;

fn main() {
    let handle = thread::current();
    println!("Current thread: {:?}", handle.name());
}
```

#### **`std::thread::Thread::id()` – Get Thread ID**

Each thread has a unique ID that can be retrieved using `.id()`.

```rust
use std::thread;

fn main() {
    let handle = thread::spawn(|| {
        let id = thread::current().id();
        println!("Thread ID: {:?}", id);
    });

    handle.join().unwrap();
}
```

---

### **Naming Threads**

Threads can be named using `Builder`.

```rust
use std::thread;

fn main() {
    let handle = thread::Builder::new()
        .name("WorkerThread".to_string())
        .spawn(|| {
            println!("Thread name: {:?}", thread::current().name());
        })
        .unwrap();

    handle.join().unwrap();
}
```

---

### **Custom Stack Size**

You can create a thread with a custom stack size using `Builder`.

```rust
use std::thread;

fn main() {
    let handle = thread::Builder::new()
        .stack_size(4 * 1024 * 1024) // 4MB stack
        .spawn(|| {
            println!("Running with a custom stack size");
        })
        .unwrap();

    handle.join().unwrap();
}
```

---

### **Thread Parking and Unparking**

Threads can be paused and resumed using `thread::park()` and `thread::unpark()`.

#### **Pausing (`park()`) and Resuming (`unpark()`) a Thread**

```rust
use std::thread;
use std::time::Duration;

fn main() {
    let parked_thread = thread::spawn(|| {
        println!("Thread is parking...");
        thread::park(); // This pauses the thread
        println!("Thread resumed!");
    });

    thread::sleep(Duration::from_secs(2));
    parked_thread.thread().unpark(); // Resumes the parked thread

    parked_thread.join().unwrap();
}
```

---

### **Thread Panic Handling**

Threads that panic will not crash the entire program unless `join().unwrap()` is used. You can catch panics using `Result`.

```rust
use std::thread;

fn main() {
    let handle = thread::spawn(|| {
        panic!("Something went wrong!");
    });

    match handle.join() {
        Ok(_) => println!("Thread completed successfully."),
        Err(e) => println!("Thread panicked: {:?}", e),
    }
}
```

---

