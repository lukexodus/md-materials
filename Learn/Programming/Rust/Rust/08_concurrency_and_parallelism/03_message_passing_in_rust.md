## Message Passing in Rust


### Introduction to Message Passing

Message passing is a concurrency paradigm where threads or processes communicate by sending messages rather than sharing memory directly. In Rust, message passing is the preferred method for concurrent communication, embodying the language's motto: "Do not communicate by sharing memory; instead, share memory by communicating."

This approach aligns perfectly with Rust's ownership model, providing safe concurrency without data races.

**Key Points**:

- Message passing enforces isolation between concurrent units
- It reduces the need for locks and shared mutable state
- Rust's ownership system ensures messages are safely transferred between threads
- Channels provide the primary mechanism for message passing in Rust
- The approach scales from simple producer-consumer patterns to complex actor systems

### Channels (mpsc, crossbeam)

#### Standard Library Channels (std::sync::mpsc)

The standard library provides Multiple Producer, Single Consumer (MPSC) channels through the `std::sync::mpsc` module:

```rust
use std::sync::mpsc;
use std::thread;
use std::time::Duration;

fn basic_channel_example() {
    // Create a channel
    let (tx, rx) = mpsc::channel();
    
    // Spawn a thread that will send messages
    thread::spawn(move || {
        let messages = vec![
            "Hello".to_string(),
            "from".to_string(),
            "the".to_string(),
            "thread".to_string(),
        ];
        
        for msg in messages {
            tx.send(msg).unwrap();
            thread::sleep(Duration::from_millis(100));
        }
        
        // tx is dropped at the end of this scope
    });
    
    // Receive messages in the main thread
    for received in rx {
        println!("Got: {}", received);
    }
    // The for loop ends when all senders are dropped
}
```

The standard library provides three types of channels:

1. **Synchronous channels** (`sync_channel`) - Have a bounded buffer; senders block when the buffer is full:

```rust
fn sync_channel_example() {
    // Create a synchronous channel with a buffer size of 2
    let (tx, rx) = mpsc::sync_channel(2);
    
    thread::spawn(move || {
        // These won't block because buffer isn't full yet
        tx.send(1).unwrap();
        tx.send(2).unwrap();
        
        println!("Sent first two messages");
        
        // This will block until a message is received
        tx.send(3).unwrap();
        
        println!("Sent third message");
    });
    
    // Give the sender time to send the first two messages
    thread::sleep(Duration::from_millis(100));
    println!("Sleeping before receiving");
    
    // Now receive the messages
    for i in 0..3 {
        thread::sleep(Duration::from_millis(300));
        let msg = rx.recv().unwrap();
        println!("Received: {}", msg);
    }
}
```

2. **Asynchronous channels** (default `channel`) - Have an unbounded buffer; senders never block:

```rust
fn async_channel_example() {
    let (tx, rx) = mpsc::channel();
    
    thread::spawn(move || {
        for i in 0..1000 {
            // Won't block even with many messages
            tx.send(i).unwrap();
        }
        println!("All messages sent without blocking");
    });
    
    // Receive only the first 10 messages
    for _ in 0..10 {
        println!("Received: {}", rx.recv().unwrap());
    }
    
    // Remaining messages stay in the channel buffer
    println!("Stopped receiving");
}
```

3. **Rendezvous channels** - Special case of sync channels with zero buffer capacity:

```rust
fn rendezvous_channel_example() {
    let (tx, rx) = mpsc::sync_channel(0);
    
    thread::spawn(move || {
        println!("Sending...");
        // This will block until the receiver calls recv()
        tx.send(42).unwrap();
        println!("Sent!");
    });
    
    // Give the sender thread time to start and block
    thread::sleep(Duration::from_millis(500));
    println!("About to receive");
    let value = rx.recv().unwrap();
    println!("Received: {}", value);
}
```

#### Crossbeam Channels

The `crossbeam-channel` crate provides more advanced channel features, including Multiple Producer, Multiple Consumer (MPMC) capabilities:

```rust
use crossbeam_channel as cb;

fn crossbeam_basic_example() {
    let (s, r) = cb::bounded(100);
    
    // Multiple senders can be created by cloning
    let s2 = s.clone();
    
    thread::spawn(move || {
        for i in 0..50 {
            s.send(i).unwrap();
        }
    });
    
    thread::spawn(move || {
        for i in 50..100 {
            s2.send(i).unwrap();
        }
    });
    
    // Multiple consumers can receive from the same channel
    thread::spawn(move || {
        for _ in 0..50 {
            let msg = r.recv().unwrap();
            println!("Consumer 1 got: {}", msg);
        }
    });
    
    for _ in 0..50 {
        let msg = r.recv().unwrap();
        println!("Main thread got: {}", msg);
    }
}
```

Crossbeam offers both bounded and unbounded channels:

```rust
fn crossbeam_channel_types() {
    // Bounded channel with a capacity of 10
    let (s1, r1) = cb::bounded(10);
    
    // Unbounded channel
    let (s2, r2) = cb::unbounded();
    
    // Zero-capacity channel (rendezvous)
    let (s3, r3) = cb::bounded(0);
}
```

### Send and Sync Traits

At the core of Rust's thread safety guarantees are the `Send` and `Sync` traits:

- **`Send`**: Types that can be safely transferred between threads
- **`Sync`**: Types that can be safely shared between threads using references

These marker traits are automatically implemented for types when appropriate and are crucial for message passing:

```rust
// Demonstration of Send and Sync
fn send_sync_demonstration() {
    // This struct is Send because all its fields are Send
    struct Message {
        id: i32,
        content: String,
    }
    
    // This would not be Send because Rc is not Send
    // struct NotThreadSafe {
    //     counter: std::rc::Rc<i32>,
    // }
    
    let (tx, rx) = mpsc::channel();
    
    thread::spawn(move || {
        // This works because Message is Send
        let msg = Message {
            id: 1,
            content: "Hello from thread".to_string(),
        };
        
        tx.send(msg).unwrap(); // Message ownership transfers to channel
    });
    
    let received = rx.recv().unwrap();
    println!("Received message {} with content: {}", 
             received.id, received.content);
}
```

Understanding `Send` and `Sync` is critical for designing thread-safe types:

```rust
use std::sync::{Arc, Mutex};
use std::cell::RefCell;

fn send_sync_types() {
    // Send + Sync: Can be shared across threads safely
    let counter = Arc::new(Mutex::new(0));
    let counter_clone = counter.clone();
    
    thread::spawn(move || {
        let mut num = counter_clone.lock().unwrap();
        *num += 1;
    });
    
    // Not Send: Cannot be sent between threads
    let cell = RefCell::new(5);
    
    // This would not compile:
    // thread::spawn(move || {
    //     *cell.borrow_mut() += 1;
    // });
    
    // Making non-Send types thread-safe
    let thread_safe_cell = Arc::new(Mutex::new(RefCell::new(5)));
    let cell_clone = thread_safe_cell.clone();
    
    thread::spawn(move || {
        let guard = cell_clone.lock().unwrap();
        *guard.borrow_mut() += 1;
    });
}
```

Common types and their thread safety properties:

|Type|Send|Sync|Usage in Message Passing|
|---|---|---|---|
|`i32`, `String`, etc.|Yes|Yes|Can be sent directly|
|`Vec<T>`, `HashMap<K, V>`|Yes*|Yes*|Can be sent if T, K, V are Send|
|`Rc<T>`|No|Yes*|Cannot be sent between threads|
|`Arc<T>`|Yes*|Yes*|Thread-safe shared ownership|
|`Mutex<T>`, `RwLock<T>`|Yes*|Yes*|Thread-safe synchronization|
|`RefCell<T>`|Yes*|No|Interior mutability, not thread-safe|
|`MutexGuard<T>`|No|Yes*|Must not leave the thread|
|Raw pointers|Yes|No|Unsafe across threads|

*If their generic parameter(s) also satisfy the trait

### Channel Patterns (fan-out, fan-in)

Channels enable various concurrency patterns:

#### Fan-Out Pattern (One Sender, Multiple Receivers)

```rust
fn fan_out_pattern() {
    // Create a channel
    let (tx, rx) = mpsc::channel();
    let rx = Arc::new(Mutex::new(rx));
    
    // Spawn multiple worker threads
    let mut handles = vec![];
    for id in 0..4 {
        let rx = rx.clone();
        let handle = thread::spawn(move || {
            loop {
                let message = {
                    let mut rx_guard = rx.lock().unwrap();
                    match rx_guard.try_recv() {
                        Ok(msg) => msg,
                        Err(mpsc::TryRecvError::Empty) => continue,
                        Err(mpsc::TryRecvError::Disconnected) => break,
                    }
                };
                
                println!("Worker {}: processing message {}", id, message);
                thread::sleep(Duration::from_millis(100));
            }
            println!("Worker {}: shutting down", id);
        });
        handles.push(handle);
    }
    
    // Send work items
    for i in 0..20 {
        tx.send(i).unwrap();
    }
    
    // Drop sender to signal workers to terminate
    drop(tx);
    
    // Wait for workers to finish
    for handle in handles {
        handle.join().unwrap();
    }
}
```

#### Fan-In Pattern (Multiple Senders, One Receiver)

```rust
fn fan_in_pattern() {
    // Create a channel
    let (tx, rx) = mpsc::channel();
    
    // Spawn multiple producer threads
    let mut handles = vec![];
    for id in 0..4 {
        let tx = tx.clone();
        let handle = thread::spawn(move || {
            for i in 0..5 {
                let msg = format!("Message {}-{}", id, i);
                tx.send(msg).unwrap();
                thread::sleep(Duration::from_millis(50));
            }
            println!("Producer {}: finished sending", id);
        });
        handles.push(handle);
    }
    
    // Drop the original sender
    drop(tx);
    
    // Receive all messages
    for msg in rx {
        println!("Received: {}", msg);
    }
    
    // Wait for producers to finish
    for handle in handles {
        handle.join().unwrap();
    }
}
```

#### Pipeline Pattern

```rust
fn pipeline_pattern() {
    // Stage 1: Generate numbers
    let (tx1, rx1) = mpsc::channel();
    thread::spawn(move || {
        for i in 0..10 {
            tx1.send(i).unwrap();
            thread::sleep(Duration::from_millis(100));
        }
    });
    
    // Stage 2: Square the numbers
    let (tx2, rx2) = mpsc::channel();
    thread::spawn(move || {
        for val in rx1 {
            tx2.send(val * val).unwrap();
        }
    });
    
    // Stage 3: Filter even numbers
    let (tx3, rx3) = mpsc::channel();
    thread::spawn(move || {
        for val in rx2 {
            if val % 2 == 0 {
                tx3.send(val).unwrap();
            }
        }
    });
    
    // Final stage: Print results
    for val in rx3 {
        println!("Pipeline result: {}", val);
    }
}
```

#### Work Stealing Pattern

```rust
use std::collections::VecDeque;

fn work_stealing_pattern() {
    // Create work queues for each worker
    let mut queues = Vec::new();
    for _ in 0..4 {
        queues.push(Arc::new(Mutex::new(VecDeque::new())));
    }
    
    // Create a channel to signal completion
    let (done_tx, done_rx) = mpsc::channel();
    
    // Create workers
    let mut handles = Vec::new();
    for id in 0..4 {
        let my_queue = queues[id].clone();
        let all_queues = queues.clone();
        let done_tx = done_tx.clone();
        
        let handle = thread::spawn(move || {
            let mut tasks_completed = 0;
            
            loop {
                // Try to get work from own queue first
                let task = {
                    let mut queue = my_queue.lock().unwrap();
                    queue.pop_front()
                };
                
                match task {
                    Some(task_id) => {
                        // Process the task
                        println!("Worker {} processing task {}", id, task_id);
                        thread::sleep(Duration::from_millis(100));
                        tasks_completed += 1;
                    }
                    None => {
                        // Try to steal work from other queues
                        let mut found_work = false;
                        for i in 0..all_queues.len() {
                            if i == id { continue; } // Skip own queue
                            
                            let stolen = {
                                let mut other_queue = all_queues[i].lock().unwrap();
                                if other_queue.len() > 1 {
                                    // Steal half the work
                                    let steal_count = other_queue.len() / 2;
                                    let mut stolen = Vec::new();
                                    for _ in 0..steal_count {
                                        if let Some(task) = other_queue.pop_back() {
                                            stolen.push(task);
                                        }
                                    }
                                    stolen
                                } else {
                                    Vec::new()
                                }
                            };
                            
                            if !stolen.is_empty() {
                                found_work = true;
                                let mut my_queue = my_queue.lock().unwrap();
                                for task in stolen {
                                    my_queue.push_back(task);
                                }
                                break;
                            }
                        }
                        
                        if !found_work {
                            // No work found, check if we should terminate
                            match done_rx.try_recv() {
                                Ok(_) | Err(mpsc::TryRecvError::Disconnected) => {
                                    println!("Worker {} shutting down, completed {} tasks", 
                                             id, tasks_completed);
                                    break;
                                }
                                Err(mpsc::TryRecvError::Empty) => {
                                    // No termination signal yet, keep checking
                                    thread::sleep(Duration::from_millis(10));
                                }
                            }
                        }
                    }
                }
            }
        });
        
        handles.push(handle);
    }
    
    // Add some initial tasks with uneven distribution
    {
        let mut queue0 = queues[0].lock().unwrap();
        for i in 0..20 {
            queue0.push_back(i);
        }
    }
    
    // Let workers process for a while
    thread::sleep(Duration::from_secs(1));
    
    // Signal completion
    drop(done_tx);
    
    // Wait for workers to finish
    for handle in handles {
        handle.join().unwrap();
    }
}
```

### Select Operations (via crossbeam)

Crossbeam provides a `select!` macro that allows waiting on multiple channel operations simultaneously, similar to Go's `select` statement:

```rust
use crossbeam_channel::{select, unbounded};

fn select_example() {
    let (s1, r1) = unbounded();
    let (s2, r2) = unbounded();
    
    // Spawn a thread that sends to the first channel
    thread::spawn(move || {
        thread::sleep(Duration::from_millis(500));
        s1.send("Message on channel 1").unwrap();
    });
    
    // Spawn another thread that sends to the second channel
    thread::spawn(move || {
        thread::sleep(Duration::from_millis(1000));
        s2.send("Message on channel 2").unwrap();
    });
    
    // Wait for either channel to receive a message
    loop {
        select! {
            recv(r1) -> msg => {
                println!("Received from channel 1: {}", msg.unwrap());
            }
            recv(r2) -> msg => {
                println!("Received from channel 2: {}", msg.unwrap());
            }
        }
        
        // Check if both channels are empty and disconnected
        if r1.is_empty() && r2.is_empty() && r1.is_disconnected() && r2.is_disconnected() {
            break;
        }
    }
}
```

#### Timeout with Select

```rust
use crossbeam_channel::after;

fn select_with_timeout() {
    let (s, r) = unbounded();
    
    thread::spawn(move || {
        thread::sleep(Duration::from_secs(2));
        s.send("Delayed message").unwrap();
    });
    
    // Wait for a message with timeout
    select! {
        recv(r) -> msg => {
            println!("Received: {}", msg.unwrap());
        }
        recv(after(Duration::from_secs(1))) -> _ => {
            println!("Timed out after 1 second");
        }
    }
    
    // The message will still arrive later
    if let Ok(msg) = r.recv() {
        println!("Eventually received: {}", msg);
    }
}
```

#### Default Case with Select

```rust
fn select_with_default() {
    let (s, r) = unbounded::<i32>();
    
    // No messages yet
    select! {
        recv(r) -> msg => {
            println!("Received: {}", msg.unwrap());
        }
        default => {
            println!("No messages available");
        }
    }
    
    // Now send a message
    s.send(42).unwrap();
    
    // This time we'll receive it
    select! {
        recv(r) -> msg => {
            println!("Received: {}", msg.unwrap());
        }
        default => {
            println!("No messages available");
        }
    }
}
```

#### Select with Send Operations

```rust
fn select_with_send() {
    let (s1, r1) = unbounded::<&str>();
    let (s2, r2) = unbounded::<&str>();
    
    // Try to send to whichever channel is ready first
    select! {
        send(s1, "Message for channel 1") -> res => {
            if res.is_ok() {
                println!("Sent to channel 1");
            }
        }
        send(s2, "Message for channel 2") -> res => {
            if res.is_ok() {
                println!("Sent to channel 2");
            }
        }
    }
    
    // Receive from both channels
    println!("From r1: {}", r1.recv().unwrap());
    println!("From r2: {}", r2.recv().unwrap());
}
```

### Actor Model Implementation

The Actor Model is a concurrent computation model where "actors" are the fundamental unit of computation. Each actor:

1. Has its own state
2. Processes messages sequentially
3. Can send messages to other actors
4. Can create new actors

Here's a basic implementation of an actor system in Rust:

```rust
use std::collections::HashMap;
use std::sync::mpsc::{channel, Sender, Receiver};
use std::thread;

// Message to be passed between actors
enum Message {
    Text(String),
    Number(i32),
    Shutdown,
}

// Actor trait
trait Actor: Send + 'static {
    fn receive(&mut self, msg: Message, ctx: &Context);
}

// Actor context for sending messages
struct Context {
    addresses: HashMap<String, Sender<Message>>,
}

impl Context {
    fn new() -> Self {
        Context {
            addresses: HashMap::new(),
        }
    }
    
    fn send(&self, actor_name: &str, msg: Message) {
        if let Some(addr) = self.addresses.get(actor_name) {
            let _ = addr.send(msg);
        }
    }
    
    fn register(&mut self, name: &str, addr: Sender<Message>) {
        self.addresses.insert(name.to_string(), addr);
    }
}

// Actor system that manages actors
struct ActorSystem {
    context: Context,
    handles: Vec<thread::JoinHandle<()>>,
}

impl ActorSystem {
    fn new() -> Self {
        ActorSystem {
            context: Context::new(),
            handles: Vec::new(),
        }
    }
    
    fn spawn<A: Actor>(&mut self, name: &str, mut actor: A) {
        let (tx, rx): (Sender<Message>, Receiver<Message>) = channel();
        
        // Register the actor's address
        self.context.register(name, tx);
        
        // Create a clone of the context for the actor
        let mut ctx = Context::new();
        for (name, addr) in &self.context.addresses {
            ctx.register(name, addr.clone());
        }
        
        // Spawn the actor in its own thread
        let handle = thread::spawn(move || {
            for msg in rx {
                match msg {
                    Message::Shutdown => break,
                    _ => actor.receive(msg, &ctx),
                }
            }
        });
        
        self.handles.push(handle);
    }
    
    fn send(&self, actor_name: &str, msg: Message) {
        self.context.send(actor_name, msg);
    }
    
    fn shutdown(self) {
        // Send shutdown message to all actors
        for (name, _) in self.context.addresses {
            self.context.send(&name, Message::Shutdown);
        }
        
        // Wait for all actors to finish
        for handle in self.handles {
            let _ = handle.join();
        }
    }
}

// Example actors
struct LoggerActor {
    prefix: String,
}

impl Actor for LoggerActor {
    fn receive(&mut self, msg: Message, _ctx: &Context) {
        match msg {
            Message::Text(text) => {
                println!("{}: {}", self.prefix, text);
            }
            Message::Number(num) => {
                println!("{}: {}", self.prefix, num);
            }
            Message::Shutdown => {
                println!("{}: Shutting down", self.prefix);
            }
        }
    }
}

struct PingActor;

impl Actor for PingActor {
    fn receive(&mut self, msg: Message, ctx: &Context) {
        match msg {
            Message::Text(text) => {
                if text == "ping" {
                    ctx.send("logger", Message::Text("pong".to_string()));
                }
            }
            _ => {}
        }
    }
}

fn main() {
    // Create an actor system
    let mut system = ActorSystem::new();
    
    // Spawn actors
    system.spawn("logger", LoggerActor { prefix: "LOG".to_string() });
    system.spawn("ping", PingActor);
    
    // Send messages
    system.send("logger", Message::Text("Hello, actor world!".to_string()));
    system.send("ping", Message::Text("ping".to_string()));
    system.send("logger", Message::Number(42));
    
    // Give some time for messages to be processed
    thread::sleep(Duration::from_millis(500));
    
    // Shutdown the system
    system.shutdown();
}
```

#### More Advanced Actor System

Building upon the basic actor implementation, we can create a more sophisticated actor system with additional features:

##### Actor Supervision and Fault Tolerance

**Key Points**
- Supervision hierarchies allow actors to monitor and restart child actors upon failure
- Proper error handling enables fault isolation - failures in one actor don't cascade through the system
- Supervision strategies can include: restart, stop, escalate, or resume

```rust
enum SupervisionStrategy {
    Restart,
    Stop,
    Escalate,
    Resume,
}

struct Supervisor<T> {
    children: HashMap<ActorId, ActorRef<T>>,
    strategy: SupervisionStrategy,
}

impl<T> Supervisor<T> {
    fn handle_failure(&mut self, failed_actor: ActorId, error: ActorError) {
        match self.strategy {
            SupervisionStrategy::Restart => {
                // Recreate the actor and replace the old reference
                if let Some(actor) = self.children.get(&failed_actor) {
                    let new_actor = actor.restart();
                    self.children.insert(failed_actor, new_actor);
                }
            },
            SupervisionStrategy::Stop => {
                self.children.remove(&failed_actor);
            },
            SupervisionStrategy::Escalate => {
                // Pass error to parent supervisor
                self.escalate_error(error);
            },
            SupervisionStrategy::Resume => {
                // Do nothing, let actor continue
            }
        }
    }
}
```

##### Distributed Actor Systems

**Key Points**
- Actors can communicate across network boundaries with serialized messages
- Actor references can be location-transparent
- Requires networking, serialization, and discovery mechanisms

```rust
use serde::{Serialize, Deserialize};

#[derive(Serialize, Deserialize)]
struct RemoteActorRef {
    node_id: String,
    actor_id: ActorId,
}

impl RemoteActorRef {
    fn send<T: Serialize>(&self, message: T) -> Result<(), RemoteError> {
        // Serialize message
        let serialized = bincode::serialize(&message)?;
        
        // Send over network to remote node
        let connection = get_connection_to_node(&self.node_id)?;
        connection.send_to_actor(self.actor_id, serialized)?;
        
        Ok(())
    }
}
```

##### Actor System Configuration and Deployment

**Key Points**
- Actor systems need configuration for thread pools, mailbox sizes, dispatcher strategies
- Deployment configurations determine where actors run and how they're initialized
- Runtime monitoring enables performance tuning

```rust
struct ActorSystemConfig {
    thread_pool_size: usize,
    default_mailbox_size: usize,
    shutdown_timeout: Duration,
}

struct ActorSystem {
    config: ActorSystemConfig,
    dispatcher: Dispatcher,
    root_actors: HashMap<String, Box<dyn Actor>>,
}

impl ActorSystem {
    fn new(config: ActorSystemConfig) -> Self {
        let dispatcher = Dispatcher::new(config.thread_pool_size);
        
        ActorSystem {
            config,
            dispatcher,
            root_actors: HashMap::new(),
        }
    }
    
    fn spawn<A: Actor + 'static>(&mut self, name: &str, actor: A) -> ActorRef<A::Message> {
        let actor_ref = ActorRef::new(actor, self.config.default_mailbox_size);
        self.root_actors.insert(name.to_string(), Box::new(actor));
        actor_ref
    }
}
```

##### Actor Lifecycle Management

**Key Points**
- Actors have a well-defined lifecycle: preStart, postStop, preRestart, postRestart
- Graceful termination requires proper coordination and shutdown signals
- Resource cleanup ensures no leaks when actors terminate

```rust
trait LifecycleAware {
    fn pre_start(&mut self) {}
    fn post_stop(&mut self) {}
    fn pre_restart(&mut self, reason: &ActorError) {}
    fn post_restart(&mut self, reason: &ActorError) {}
}

impl<T: LifecycleAware + Actor> ActorCell<T> {
    fn start(&mut self) {
        self.inner.pre_start();
        self.status = ActorStatus::Running;
    }
    
    fn stop(&mut self) {
        self.status = ActorStatus::Stopping;
        self.inner.post_stop();
        self.status = ActorStatus::Stopped;
    }
    
    fn restart(&mut self, reason: ActorError) {
        self.status = ActorStatus::Restarting;
        self.inner.pre_restart(&reason);
        // Create new instance or reset state
        self.inner.post_restart(&reason);
        self.status = ActorStatus::Running;
    }
}
```

##### Message Routing and Dispatching

**Key Points**
- Advanced actor systems can route messages based on content, actor load, or other criteria
- Routing strategies include round-robin, consistent hashing, and custom logic
- Can implement worker pools, load balancing, and sharding

```rust
enum RoutingStrategy {
    RoundRobin,
    ConsistentHashing(Box<dyn Fn(&Message) -> u64>),
    SmallestMailbox,
    Custom(Box<dyn Fn(&Message) -> usize>),
}

struct Router<M> {
    routees: Vec<ActorRef<M>>,
    strategy: RoutingStrategy,
    current: usize, // For round-robin
}

impl<M: Message> Router<M> {
    fn route(&mut self, message: M) -> Result<(), RoutingError> {
        if self.routees.is_empty() {
            return Err(RoutingError::NoRouteesAvailable);
        }
        
        let idx = match &self.strategy {
            RoutingStrategy::RoundRobin => {
                let idx = self.current;
                self.current = (self.current + 1) % self.routees.len();
                idx
            },
            RoutingStrategy::ConsistentHashing(hasher) => {
                let hash = hasher(&message);
                (hash as usize) % self.routees.len()
            },
            RoutingStrategy::SmallestMailbox => {
                // Find actor with smallest mailbox
                self.routees.iter()
                    .enumerate()
                    .min_by_key(|(_, actor)| actor.mailbox_size())
                    .map(|(idx, _)| idx)
                    .unwrap_or(0)
            },
            RoutingStrategy::Custom(selector) => {
                let idx = selector(&message);
                idx % self.routees.len()
            }
        };
        
        self.routees[idx].send(message)?;
        Ok(())
    }
}
```

##### Testing Actor Systems

**Key Points**
- Specialized testing frameworks for actor systems
- Probe actors can verify message delivery and processing
- Time control for testing time-dependent behaviors
- Support for synchronous testing of asynchronous systems

```rust
struct TestProbe<M> {
    rx: Receiver<M>,
    tx: Sender<M>,
}

impl<M: Clone> TestProbe<M> {
    fn new() -> Self {
        let (tx, rx) = mpsc::channel();
        TestProbe { rx, tx }
    }
    
    fn expect_msg(&self, timeout: Duration) -> Option<M> {
        match self.rx.recv_timeout(timeout) {
            Ok(msg) => Some(msg),
            Err(_) => None,
        }
    }
    
    fn expect_no_msg(&self, duration: Duration) -> bool {
        self.rx.recv_timeout(duration).is_err()
    }
    
    fn send_to<T: Actor<Message = M>>(&self, actor: &ActorRef<T>, msg: M) {
        actor.send(msg).expect("Failed to send message in test");
    }
}
```

#### State Persistence and Recovery

**Key Points**
- Event sourcing patterns store actor state changes as events
- Persistent actors can recover state after crashes or restarts
- Snapshots optimize recovery of large state actors

```rust
trait PersistentActor: Actor {
    type Event: Serialize + Deserialize;
    type State: Default + Serialize + Deserialize;
    
    fn persist_id(&self) -> String;
    
    fn apply_event(&mut self, event: Self::Event);
    
    fn persist(&mut self, event: Self::Event) {
        // Store event to persistent storage
        let persist_id = self.persist_id();
        let serialized = bincode::serialize(&event).expect("Failed to serialize event");
        
        EVENT_STORE.store(persist_id, serialized);
        
        // Apply event to current state
        self.apply_event(event);
    }
    
    fn recover(&mut self) {
        let persist_id = self.persist_id();
        let events = EVENT_STORE.get_events(persist_id);
        
        for event_data in events {
            let event: Self::Event = bincode::deserialize(&event_data)
                .expect("Failed to deserialize event");
            self.apply_event(event);
        }
    }
    
    fn snapshot(&self) {
        // Create and store snapshot of current state
    }
    
    fn restore_from_snapshot(&mut self) {
        // Restore from latest snapshot and apply only newer events
    }
}
```

**Conclusion**

Advanced actor systems in Rust require careful design around supervision hierarchies, lifecycle management, message routing, and persistence strategies. When implemented correctly, they provide excellent tools for building fault-tolerant, scalable, and distributed applications. The combination of Rust's safety guarantees with the actor model's isolation properties creates robust concurrent systems that can gracefully handle failures and scale across cores or machines.

Further developments in this area would involve integration with distributed systems technologies like service discovery, consensus algorithms, and cluster sharding mechanisms similar to those found in established actor frameworks like Akka.

