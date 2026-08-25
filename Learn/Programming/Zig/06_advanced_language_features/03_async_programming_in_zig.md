## Async Programming in Zig


Zig provides powerful async programming capabilities through its built-in async/await syntax and coroutine system. Unlike many other languages, Zig's async implementation is zero-cost, meaning there's no runtime overhead when async features aren't used, and minimal overhead when they are.

### Async Function Syntax

Async functions in Zig are declared using the `async` keyword before the function definition. These functions return a frame type that represents the suspended execution state.

```zig
const std = @import("std");

async fn fetchData(url: []const u8) ![]u8 {
    // Simulate network request
    std.time.sleep(1000 * std.time.ns_per_ms);
    return "response data";
}

async fn processRequest() !void {
    const data = try await fetchData("https://api.example.com");
    std.debug.print("Received: {s}\n", .{data});
}
```

**Key points:**

- Async functions automatically return a frame type
- The frame contains all local variables and execution state
- Frames are allocated on the heap by default but can be stack-allocated
- Async functions can be called both synchronously and asynchronously

### Function Frame Types

Every async function has an associated frame type that can be accessed using the `@Frame` builtin:

```zig
async fn myAsyncFunction() void {
    suspend;
}

const FrameType = @Frame(myAsyncFunction);

fn caller() void {
    var frame: FrameType = async myAsyncFunction();
    resume frame;
}
```

### Await Expressions

The `await` keyword is used to suspend execution until an async operation completes. It can only be used within async functions or async contexts.

```zig
async fn downloadFile(filename: []const u8) ![]u8 {
    const file_data = try await readFileAsync(filename);
    const processed = try await processDataAsync(file_data);
    return processed;
}

async fn readFileAsync(filename: []const u8) ![]u8 {
    // Simulate file I/O
    suspend;
    return "file contents";
}

async fn processDataAsync(data: []u8) ![]u8 {
    // Simulate processing
    suspend;
    return data;
}
```

**Key points:**

- `await` automatically handles frame resumption
- Multiple awaits can be chained together
- Error handling works seamlessly with async/await
- Awaiting a non-async function returns the result immediately

### Suspend and Resume

Direct control over coroutine suspension and resumption is possible through `suspend` and `resume`:

```zig
var global_frame: ?anyframe = null;

async fn suspendingFunction() void {
    std.debug.print("Before suspend\n", .{});
    suspend {
        global_frame = @frame();
    }
    std.debug.print("After resume\n", .{});
}

fn resumeFromElsewhere() void {
    if (global_frame) |frame| {
        resume frame;
        global_frame = null;
    }
}
```

### Event Loop Integration

Zig doesn't include a built-in event loop, but integrates well with existing event loop systems. Custom event loops can be implemented using async/await:

```zig
const std = @import("std");
const ArrayList = std.ArrayList;

const Task = struct {
    frame: anyframe,
    ready: bool = false,
};

const EventLoop = struct {
    tasks: ArrayList(Task),
    allocator: std.mem.Allocator,

    fn init(allocator: std.mem.Allocator) EventLoop {
        return EventLoop{
            .tasks = ArrayList(Task).init(allocator),
            .allocator = allocator,
        };
    }

    fn spawn(self: *EventLoop, comptime func: anytype, args: anytype) !void {
        const frame = try self.allocator.create(@Frame(func));
        frame.* = async func(args);
        try self.tasks.append(Task{ .frame = frame });
    }

    fn run(self: *EventLoop) void {
        while (self.tasks.items.len > 0) {
            var i: usize = 0;
            while (i < self.tasks.items.len) {
                const task = &self.tasks.items[i];
                if (task.ready) {
                    resume task.frame;
                    _ = self.tasks.swapRemove(i);
                } else {
                    i += 1;
                }
            }
            // Yield to system or check for I/O events
            std.time.sleep(1 * std.time.ns_per_ms);
        }
    }
};
```

### Async Memory Management

Memory management in async contexts requires careful consideration of frame lifetimes and allocator usage:

```zig
const std = @import("std");

async fn asyncWithAllocation(allocator: std.mem.Allocator) ![]u8 {
    const buffer = try allocator.alloc(u8, 1024);
    defer allocator.free(buffer);
    
    // Use buffer in async operations
    try await processBuffer(buffer);
    
    // Buffer is automatically freed when function exits
    return try allocator.dupe(u8, "completed");
}

async fn processBuffer(buffer: []u8) !void {
    // Simulate async processing
    suspend;
    @memset(buffer, 0);
}
```

**Key points:**

- Deferred cleanup works correctly with async functions
- Frame allocation can be controlled with `@asyncCall`
- Memory allocated in async functions persists across suspensions
- Arena allocators work well with async patterns

### Stack vs Heap Allocation

Frames can be allocated on the stack for better performance when the lifetime is predictable:

```zig
async fn stackAllocatedAsync() void {
    suspend;
}

fn caller() void {
    var frame: @Frame(stackAllocatedAsync) = undefined;
    frame = async stackAllocatedAsync();
    resume frame;
}

// Using @asyncCall for explicit control
fn callerWithAsyncCall(allocator: std.mem.Allocator) !void {
    const frame_size = @sizeOf(@Frame(stackAllocatedAsync));
    var frame_memory: [frame_size]u8 align(@alignOf(@Frame(stackAllocatedAsync))) = undefined;
    
    const frame = @asyncCall(&frame_memory, {}, stackAllocatedAsync, .{});
    resume frame;
}
```

### Coroutine Patterns

#### Producer-Consumer Pattern

```zig
const std = @import("std");

const Channel = struct {
    buffer: std.ArrayList(i32),
    producer_frame: ?anyframe = null,
    consumer_frame: ?anyframe = null,
    allocator: std.mem.Allocator,

    fn init(allocator: std.mem.Allocator) Channel {
        return Channel{
            .buffer = std.ArrayList(i32).init(allocator),
            .allocator = allocator,
        };
    }

    async fn send(self: *Channel, value: i32) !void {
        try self.buffer.append(value);
        if (self.consumer_frame) |frame| {
            self.consumer_frame = null;
            resume frame;
        }
    }

    async fn receive(self: *Channel) i32 {
        while (self.buffer.items.len == 0) {
            suspend {
                self.consumer_frame = @frame();
            }
        }
        return self.buffer.orderedRemove(0);
    }
};
```

#### Async Iterator Pattern

```zig
const AsyncIterator = struct {
    current: i32 = 0,
    max: i32,

    fn init(max: i32) AsyncIterator {
        return AsyncIterator{ .max = max };
    }

    async fn next(self: *AsyncIterator) ?i32 {
        if (self.current >= self.max) return null;
        
        const value = self.current;
        self.current += 1;
        
        // Simulate async work
        suspend;
        
        return value;
    }
};

async fn useAsyncIterator() void {
    var iter = AsyncIterator.init(5);
    
    while (try await iter.next()) |value| {
        std.debug.print("Value: {}\n", .{value});
    }
}
```

#### Timeout Pattern

```zig
const TimeoutError = error{Timeout};

async fn withTimeout(comptime T: type, operation: anyframe->T, timeout_ms: u64) !T {
    var timer_frame: @Frame(timer) = async timer(timeout_ms);
    var operation_frame = operation;
    
    // Wait for either operation or timeout
    suspend {
        // This would need integration with actual timer system
        resume @frame();
    }
    
    // Implementation would track which completed first
    return TimeoutError.Timeout;
}

async fn timer(ms: u64) void {
    std.time.sleep(ms * std.time.ns_per_ms);
}
```

### Error Handling in Async Context

Error handling works seamlessly with async functions, propagating through await expressions:

```zig
const NetworkError = error{ ConnectionFailed, Timeout, InvalidResponse };

async fn networkRequest(url: []const u8) NetworkError![]u8 {
    const connection = try await establishConnection(url);
    defer closeConnection(connection);
    
    const response = try await sendRequest(connection);
    return try await parseResponse(response);
}

async fn establishConnection(url: []const u8) NetworkError!Connection {
    // Simulate connection logic
    suspend;
    if (url.len == 0) return NetworkError.ConnectionFailed;
    return Connection{};
}

const Connection = struct {};

async fn sendRequest(conn: Connection) NetworkError!Response {
    _ = conn;
    suspend;
    return Response{};
}

const Response = struct {};

async fn parseResponse(response: Response) NetworkError![]u8 {
    _ = response;
    suspend;
    return "parsed data";
}

fn closeConnection(conn: Connection) void {
    _ = conn;
    // Cleanup connection
}
```

### Testing Async Code

Testing async functions requires special consideration for frame management:

```zig
const testing = std.testing;

test "async function behavior" {
    const frame = async asyncTestFunction();
    const result = await frame;
    try testing.expect(result == 42);
}

async fn asyncTestFunction() i32 {
    suspend;
    return 42;
}

test "async with allocator" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    const result = try await asyncAllocationTest(allocator);
    try testing.expectEqualStrings("success", result);
    allocator.free(result);
}

async fn asyncAllocationTest(allocator: std.mem.Allocator) ![]u8 {
    suspend;
    return try allocator.dupe(u8, "success");
}
```

### Performance Considerations

Async programming in Zig offers excellent performance characteristics:

- Zero-cost abstraction when async isn't used
- Minimal runtime overhead for async operations
- Stack allocation option for performance-critical code
- No built-in garbage collection requirements
- Direct control over memory layout and allocation

**Example** of performance-optimized async code:

```zig
// Pre-allocate frame for hot path
var hot_path_frame: @Frame(criticalAsyncOperation) = undefined;

async fn criticalAsyncOperation() void {
    // Performance-critical async operation
    suspend;
}

fn optimizedCaller() void {
    hot_path_frame = async criticalAsyncOperation();
    resume hot_path_frame;
}
```

**Conclusion:** Zig's async programming model provides powerful concurrency capabilities while maintaining the language's principles of explicitness and performance. The combination of zero-cost abstractions, explicit memory management, and direct control over execution flow makes it suitable for both high-level application development and systems programming scenarios.

---

