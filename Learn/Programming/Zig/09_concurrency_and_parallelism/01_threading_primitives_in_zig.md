## Threading Primitives in Zig


### Thread Creation and Management

Zig provides built-in support for thread creation through `std.Thread`. The language emphasizes explicit control over thread lifecycle and resource management.

#### Basic Thread Creation

```zig
const std = @import("std");
const Thread = std.Thread;

fn worker_function(data: *u32) void {
    data.* += 42;
}

pub fn main() !void {
    var data: u32 = 10;
    const thread = try Thread.spawn(.{}, worker_function, .{&data});
    thread.join();
    std.debug.print("Result: {}\n", .{data}); // Output: 52
}
```

#### Thread Configuration

Zig allows detailed thread configuration through spawn options:

```zig
const thread = try Thread.spawn(.{
    .stack_size = 16 * 1024, // 16KB stack
    .allocator = allocator,
}, worker_function, .{&data});
```

### Mutex and Atomic Operations

#### Mutex Implementation

Zig provides `std.Thread.Mutex` for mutual exclusion:

```zig
const std = @import("std");
const Mutex = std.Thread.Mutex;

var counter: u32 = 0;
var mutex = Mutex{};

fn increment_counter() void {
    mutex.lock();
    defer mutex.unlock();
    counter += 1;
}
```

#### Atomic Operations

Zig's atomic operations are built into the language with `@atomicLoad`, `@atomicStore`, and `@atomicRmw`:

```zig
var atomic_counter: u32 = 0;

// Atomic increment
_ = @atomicRmw(u32, &atomic_counter, .Add, 1, .SeqCst);

// Atomic load
const value = @atomicLoad(u32, &atomic_counter, .SeqCst);

// Atomic store
@atomicStore(u32, &atomic_counter, 42, .SeqCst);

// Compare and swap
const old_value = @cmpxchgWeak(u32, &atomic_counter, 42, 100, .SeqCst, .SeqCst);
```

#### Memory Ordering Options

Zig supports various memory ordering semantics:

- `.Unordered` - No ordering constraints
- `.Monotonic` - No reordering with other atomic operations
- `.Acquire` - No reordering of loads after this operation
- `.Release` - No reordering of stores before this operation
- `.AcqRel` - Both Acquire and Release
- `.SeqCst` - Sequential consistency (strongest guarantee)

### Condition Variables

[Inference] Zig's standard library includes condition variables through `std.Thread.Condition`:

```zig
const std = @import("std");
const Condition = std.Thread.Condition;
const Mutex = std.Thread.Mutex;

var condition = Condition{};
var mutex = Mutex{};
var ready = false;

fn waiter() void {
    mutex.lock();
    defer mutex.unlock();
    
    while (!ready) {
        condition.wait(&mutex);
    }
    // Continue execution when signaled
}

fn signaler() void {
    mutex.lock();
    ready = true;
    mutex.unlock();
    
    condition.signal(); // Wake one waiting thread
    // or condition.broadcast(); // Wake all waiting threads
}
```

### Thread-Local Storage

#### Thread-Local Variables

Zig supports thread-local storage using the `threadlocal` keyword:

```zig
threadlocal var tls_counter: u32 = 0;

fn increment_tls() void {
    tls_counter += 1;
    std.debug.print("Thread-local counter: {}\n", .{tls_counter});
}
```

#### Thread-Local Storage Management

Each thread maintains its own copy of thread-local variables, initialized independently:

```zig
threadlocal var thread_id: u32 = undefined;

fn worker(id: u32) void {
    thread_id = id; // Each thread has its own copy
    // Operations on thread_id are isolated per thread
}
```

### Lock-Free Programming

#### Lock-Free Data Structures

Zig's atomic operations enable lock-free programming patterns:

```zig
const AtomicQueue = struct {
    head: std.atomic.Atomic(u32) = std.atomic.Atomic(u32).init(0),
    tail: std.atomic.Atomic(u32) = std.atomic.Atomic(u32).init(0),
    buffer: [1024]?*Node = [_]?*Node{null} ** 1024,
    
    fn enqueue(self: *AtomicQueue, node: *Node) bool {
        const tail = self.tail.load(.Acquire);
        const next_tail = (tail + 1) % self.buffer.len;
        
        if (next_tail == self.head.load(.Acquire)) {
            return false; // Queue full
        }
        
        self.buffer[tail] = node;
        self.tail.store(next_tail, .Release);
        return true;
    }
};
```

#### Compare-and-Swap Patterns

Lock-free algorithms often rely on compare-and-swap operations:

```zig
fn lock_free_increment(counter: *u32) void {
    while (true) {
        const current = @atomicLoad(u32, counter, .Acquire);
        const new_value = current + 1;
        
        if (@cmpxchgWeak(u32, counter, current, new_value, .Release, .Acquire) == null) {
            break; // Successfully updated
        }
        // Retry if another thread modified the value
    }
}
```

### Memory Management in Concurrent Contexts

#### Allocator Thread Safety

[Inference] Most Zig allocators are not thread-safe by default. For concurrent access:

```zig
const ThreadSafeAllocator = struct {
    allocator: std.mem.Allocator,
    mutex: Mutex = Mutex{},
    
    fn alloc(self: *ThreadSafeAllocator, size: usize) ![]u8 {
        self.mutex.lock();
        defer self.mutex.unlock();
        return self.allocator.alloc(u8, size);
    }
    
    fn free(self: *ThreadSafeAllocator, memory: []u8) void {
        self.mutex.lock();
        defer self.mutex.unlock();
        self.allocator.free(memory);
    }
};
```

### Error Handling in Concurrent Code

#### Thread Error Propagation

[Inference] Thread functions in Zig can return errors, but error propagation between threads requires explicit handling:

```zig
const WorkerError = error{
    ProcessingFailed,
    OutOfMemory,
};

fn worker_with_errors() WorkerError!void {
    // Potentially failing operations
    return WorkerError.ProcessingFailed;
}

// Error handling requires explicit result collection
var result: WorkerError!void = undefined;
const thread = try Thread.spawn(.{}, struct {
    fn run(res: *WorkerError!void) void {
        res.* = worker_with_errors();
    }
}.run, .{&result});

thread.join();
try result; // Propagate error from worker thread
```

### Performance Considerations

**Key Points:**

- Atomic operations have varying performance costs depending on memory ordering
- Lock-free algorithms can provide better scalability but increase complexity
- Thread creation overhead should be considered for short-lived tasks
- Memory locality affects performance in multi-threaded scenarios

**Examples of optimization strategies:**

- Using relaxed memory ordering when strict ordering isn't required
- Implementing thread pools to amortize creation costs
- Designing cache-friendly data layouts for concurrent access
- Batching atomic operations to reduce contention

Important related topics: Thread pools and work queues, Memory models and synchronization, Cross-platform threading considerations, Debugging concurrent code in Zig.

---

