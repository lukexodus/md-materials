## Memory Safety


### Use-After-Free Prevention

Zig prevents use-after-free errors through compile-time analysis, runtime checks, and structured memory management patterns that make invalid pointer access detectable or impossible.

**Compile-Time Prevention:**
```zig
const std = @import("std");

fn dangerousFunction() *i32 {
    var local_var: i32 = 42;
    return &local_var; // Compile error: returning address of local variable
}

// Correct approach using allocator
fn safeFunction(allocator: std.mem.Allocator) !*i32 {
    const ptr = try allocator.create(i32);
    ptr.* = 42;
    return ptr;
}
```

**Scope-Based Memory Management:**
```zig
fn scopedExample(allocator: std.mem.Allocator) !void {
    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit(); // All allocations freed automatically
    
    const arena_allocator = arena.allocator();
    
    const data = try arena_allocator.alloc(i32, 100);
    // Use data...
    // No manual free needed - arena.deinit() handles everything
}
```

**Optional Pointers for Null Safety:**
```zig
var maybe_ptr: ?*i32 = null;
var value: i32 = 42;
maybe_ptr = &value;

// Safe access pattern
if (maybe_ptr) |ptr| {
    std.debug.print("Value: {}\n", .{ptr.*});
} else {
    std.debug.print("Pointer is null\n", .{});
}

// Attempting to dereference null pointer directly causes runtime panic
// const bad_access = maybe_ptr.*; // Runtime panic if null
```

**Structured Pointer Lifetimes:**
```zig
const DataManager = struct {
    allocator: std.mem.Allocator,
    data: []i32,
    
    pub fn init(allocator: std.mem.Allocator, size: usize) !DataManager {
        const data = try allocator.alloc(i32, size);
        return DataManager{
            .allocator = allocator,
            .data = data,
        };
    }
    
    pub fn deinit(self: *DataManager) void {
        self.allocator.free(self.data);
        self.data = &[_]i32{}; // Clear slice to prevent further access
    }
    
    pub fn get(self: DataManager, index: usize) ?i32 {
        if (index >= self.data.len) return null;
        return self.data[index];
    }
};
```

**RAII Pattern Implementation:**
```zig
fn processFile(allocator: std.mem.Allocator, filename: []const u8) !void {
    const file = try std.fs.cwd().openFile(filename, .{});
    defer file.close(); // Guaranteed cleanup
    
    const buffer = try allocator.alloc(u8, 4096);
    defer allocator.free(buffer); // Guaranteed cleanup
    
    const bytes_read = try file.readAll(buffer);
    // Process buffer...
    // Cleanup happens automatically via defer
}
```

### Buffer Overflow Protection

Zig provides comprehensive buffer overflow protection through bounds checking, slice safety, and compile-time verification where possible.

**Array Bounds Checking:**
```zig
fn arrayAccess() void {
    var array = [_]i32{ 1, 2, 3, 4, 5 };
    
    // Safe access
    for (array, 0..) |value, i| {
        std.debug.print("array[{}] = {}\n", .{ i, value });
    }
    
    // Runtime bounds checking
    const index: usize = 10;
    if (index < array.len) {
        const value = array[index];
        std.debug.print("Value: {}\n", .{value});
    } else {
        std.debug.print("Index out of bounds\n", .{});
    }
    
    // This would cause runtime panic:
    // const bad_value = array[10]; // Runtime panic: index out of bounds
}
```

**Slice Safety:**
```zig
fn sliceSafety(data: []const u8) void {
    // Slice bounds are checked at runtime
    if (data.len > 0) {
        const first = data[0];           // Safe
        const last = data[data.len - 1]; // Safe
    }
    
    // Safe slicing with bounds checking
    const start: usize = 5;
    const end: usize = 10;
    
    if (end <= data.len and start < end) {
        const slice = data[start..end];
        // Process slice safely
        _ = slice;
    }
}

// Buffer operations with bounds checking
fn safeCopy(dest: []u8, src: []const u8) void {
    const copy_len = @min(dest.len, src.len);
    @memcpy(dest[0..copy_len], src[0..copy_len]);
}
```

**String Operations Safety:**
```zig
fn safeStringOps(allocator: std.mem.Allocator, input: []const u8) ![]u8 {
    // Safe concatenation
    var result = std.ArrayList(u8).init(allocator);
    defer result.deinit();
    
    try result.appendSlice("Prefix: ");
    try result.appendSlice(input);
    try result.appendSlice(" :Suffix");
    
    return result.toOwnedSlice();
}

// Safe buffer writing
fn safeWrite(buffer: []u8, data: []const u8) !usize {
    if (data.len > buffer.len) {
        return error.BufferTooSmall;
    }
    
    @memcpy(buffer[0..data.len], data);
    return data.len;
}
```

**Compile-Time Size Verification:**
```zig
fn compileTimeBounds(comptime size: usize) [size]i32 {
    if (size > 1000) {
        @compileError("Array size too large");
    }
    
    var array: [size]i32 = undefined;
    for (&array, 0..) |*element, i| {
        element.* = @intCast(i);
    }
    return array;
}

// Usage
const small_array = compileTimeBounds(10);  // OK
// const big_array = compileTimeBounds(2000); // Compile error
```

**Sentinel-Terminated Arrays:**
```zig
// Null-terminated strings with bounds
fn processNullTerminated(str: [:0]const u8) void {
    var i: usize = 0;
    while (str[i] != 0) : (i += 1) {
        const char = str[i];
        std.debug.print("{c}", .{char});
        
        // Automatic protection against runaway loops
        if (i >= str.len) break; // Safety check
    }
}
```

### Double-Free Prevention

Zig prevents double-free errors through structured deallocation patterns, ownership tracking, and explicit resource management.

**Single Ownership Pattern:**
```zig
const Resource = struct {
    data: []u8,
    allocator: std.mem.Allocator,
    is_valid: bool = true,
    
    pub fn init(allocator: std.mem.Allocator, size: usize) !Resource {
        const data = try allocator.alloc(u8, size);
        return Resource{
            .data = data,
            .allocator = allocator,
        };
    }
    
    pub fn deinit(self: *Resource) void {
        if (self.is_valid) {
            self.allocator.free(self.data);
            self.is_valid = false;
            self.data = &[_]u8{}; // Clear reference
        }
    }
    
    pub fn isValid(self: Resource) bool {
        return self.is_valid;
    }
};
```

**Move Semantics Simulation:**
```zig
const OwnedBuffer = struct {
    data: ?[]u8,
    allocator: std.mem.Allocator,
    
    pub fn init(allocator: std.mem.Allocator, size: usize) !OwnedBuffer {
        const data = try allocator.alloc(u8, size);
        return OwnedBuffer{
            .data = data,
            .allocator = allocator,
        };
    }
    
    pub fn deinit(self: *OwnedBuffer) void {
        if (self.data) |data| {
            self.allocator.free(data);
            self.data = null; // Prevent double-free
        }
    }
    
    // Transfer ownership
    pub fn transfer(self: *OwnedBuffer) OwnedBuffer {
        const result = OwnedBuffer{
            .data = self.data,
            .allocator = self.allocator,
        };
        self.data = null; // Source no longer owns the data
        return result;
    }
};
```

**Arena Allocator Pattern:**
```zig
fn arenaExample(base_allocator: std.mem.Allocator) !void {
    var arena = std.heap.ArenaAllocator.init(base_allocator);
    defer arena.deinit(); // Single deallocation point
    
    const allocator = arena.allocator();
    
    // Multiple allocations
    const buffer1 = try allocator.alloc(u8, 100);
    const buffer2 = try allocator.alloc(u8, 200);
    const buffer3 = try allocator.alloc(u8, 300);
    
    // No individual free calls needed - arena.deinit() handles all
    // Double-free impossible since individual free calls aren't made
    _ = buffer1;
    _ = buffer2;
    _ = buffer3;
}
```

**Reference Counting (Manual Implementation):**
```zig
const RefCounted = struct {
    data: []u8,
    ref_count: usize,
    allocator: std.mem.Allocator,
    
    pub fn init(allocator: std.mem.Allocator, size: usize) !*RefCounted {
        const self = try allocator.create(RefCounted);
        const data = try allocator.alloc(u8, size);
        
        self.* = RefCounted{
            .data = data,
            .ref_count = 1,
            .allocator = allocator,
        };
        
        return self;
    }
    
    pub fn retain(self: *RefCounted) *RefCounted {
        self.ref_count += 1;
        return self;
    }
    
    pub fn release(self: *RefCounted) void {
        self.ref_count -= 1;
        if (self.ref_count == 0) {
            self.allocator.free(self.data);
            self.allocator.destroy(self);
        }
    }
};
```

### Memory Leak Detection

Zig provides several mechanisms for detecting memory leaks, including debugging allocators and testing infrastructure.

**General Purpose Allocator with Leak Detection:**
```zig
test "memory leak detection" {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer {
        const leaked = gpa.deinit();
        if (leaked == .leak) {
            std.debug.print("Memory leak detected!\n", .{});
        }
    }
    
    const allocator = gpa.allocator();
    
    const buffer = try allocator.alloc(u8, 100);
    // Intentionally not freeing to demonstrate leak detection
    // allocator.free(buffer);
    _ = buffer;
}
```

**Testing Allocator:**
```zig
test "no memory leaks in function" {
    var testing_allocator = std.testing.allocator;
    
    // Function that should not leak
    try functionThatAllocates(testing_allocator);
    
    // Testing allocator will detect leaks automatically
}

fn functionThatAllocates(allocator: std.mem.Allocator) !void {
    const buffer = try allocator.alloc(u8, 256);
    defer allocator.free(buffer); // Must free to avoid leak detection
    
    // Use buffer...
    std.mem.set(u8, buffer, 0);
}
```

**Custom Tracking Allocator:**
```zig
const TrackingAllocator = struct {
    child_allocator: std.mem.Allocator,
    allocations: std.HashMap(usize, AllocInfo, std.hash_map.DefaultContext(usize), std.hash_map.default_max_load_percentage),
    total_allocated: usize = 0,
    
    const AllocInfo = struct {
        size: usize,
        stack_trace: ?std.builtin.StackTrace = null,
    };
    
    pub fn init(child_allocator: std.mem.Allocator) TrackingAllocator {
        return TrackingAllocator{
            .child_allocator = child_allocator,
            .allocations = std.HashMap(usize, AllocInfo, std.hash_map.DefaultContext(usize), std.hash_map.default_max_load_percentage).init(child_allocator),
        };
    }
    
    pub fn deinit(self: *TrackingAllocator) void {
        if (self.allocations.count() > 0) {
            std.debug.print("Memory leaks detected: {} allocations not freed\n", .{self.allocations.count()});
            
            var iterator = self.allocations.iterator();
            while (iterator.next()) |entry| {
                std.debug.print("Leaked {} bytes at address 0x{X}\n", .{ entry.value_ptr.size, entry.key_ptr.* });
            }
        }
        
        self.allocations.deinit();
    }
    
    pub fn allocator(self: *TrackingAllocator) std.mem.Allocator {
        return std.mem.Allocator{
            .ptr = self,
            .vtable = &.{
                .alloc = alloc,
                .resize = resize,
                .free = free,
            },
        };
    }
    
    fn alloc(ctx: *anyopaque, len: usize, ptr_align: u8, ret_addr: usize) ?[*]u8 {
        const self: *TrackingAllocator = @ptrCast(@alignCast(ctx));
        
        const result = self.child_allocator.rawAlloc(len, ptr_align, ret_addr);
        if (result) |ptr| {
            const addr = @intFromPtr(ptr);
            self.allocations.put(addr, AllocInfo{ .size = len }) catch {};
            self.total_allocated += len;
        }
        
        return result;
    }
    
    fn resize(ctx: *anyopaque, buf: []u8, buf_align: u8, new_len: usize, ret_addr: usize) bool {
        const self: *TrackingAllocator = @ptrCast(@alignCast(ctx));
        
        if (self.child_allocator.rawResize(buf, buf_align, new_len, ret_addr)) {
            const addr = @intFromPtr(buf.ptr);
            if (self.allocations.getPtr(addr)) |info| {
                self.total_allocated = self.total_allocated - info.size + new_len;
                info.size = new_len;
            }
            return true;
        }
        
        return false;
    }
    
    fn free(ctx: *anyopaque, buf: []u8, buf_align: u8, ret_addr: usize) void {
        const self: *TrackingAllocator = @ptrCast(@alignCast(ctx));
        
        const addr = @intFromPtr(buf.ptr);
        if (self.allocations.fetchRemove(addr)) |entry| {
            self.total_allocated -= entry.value.size;
        } else {
            std.debug.print("Double free detected at address 0x{X}\n", .{addr});
        }
        
        self.child_allocator.rawFree(buf, buf_align, ret_addr);
    }
};
```

**Stack Trace Collection for Leak Analysis:**
```zig
const LeakDetector = struct {
    pub fn trackAllocation(size: usize) void {
        if (std.builtin.mode == .Debug) {
            var stack_trace: std.builtin.StackTrace = undefined;
            std.debug.captureStackTrace(null, &stack_trace);
            
            std.debug.print("Allocation of {} bytes at:\n", .{size});
            std.debug.dumpStackTrace(stack_trace);
        }
    }
};
```

### Valgrind Integration

[Inference] Zig can work with Valgrind and similar memory debugging tools, though specific integration features may vary by platform and toolchain version.

**Building for Valgrind Analysis:**
```bash
# Build with debug information for better Valgrind output
zig build -Doptimize=Debug

# Run with Valgrind
valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes ./your_program
```

**Valgrind-Friendly Code Patterns:**
```zig
// Ensure all allocations have corresponding deallocations
pub fn valgrindFriendlyFunction(allocator: std.mem.Allocator) !void {
    const buffer = try allocator.alloc(u8, 1024);
    defer allocator.free(buffer); // Guaranteed cleanup
    
    // Initialize memory to avoid "Conditional jump or move depends on uninitialised value(s)"
    @memset(buffer, 0);
    
    // Use buffer...
    for (buffer, 0..) |*byte, i| {
        byte.* = @truncate(i);
    }
}
```

**Valgrind Annotations (Platform-Specific):**
[Unverified] The following shows conceptual Valgrind integration patterns:

```zig
// Hypothetical Valgrind integration
const valgrind = struct {
    extern fn VALGRIND_MALLOCLIKE_BLOCK(addr: *anyopaque, sizeB: usize, rzB: usize, is_zeroed: c_int) void;
    extern fn VALGRIND_FREELIKE_BLOCK(addr: *anyopaque, rzB: usize) void;
    extern fn VALGRIND_MAKE_MEM_UNDEFINED(addr: *anyopaque, len: usize) void;
    extern fn VALGRIND_MAKE_MEM_DEFINED(addr: *anyopaque, len: usize) void;
    
    pub fn markAsAllocated(ptr: *anyopaque, size: usize) void {
        if (@import("builtin").mode == .Debug) {
            VALGRIND_MALLOCLIKE_BLOCK(ptr, size, 0, 0);
        }
    }
    
    pub fn markAsFreed(ptr: *anyopaque) void {
        if (@import("builtin").mode == .Debug) {
            VALGRIND_FREELIKE_BLOCK(ptr, 0);
        }
    }
};
```

**Memory Pattern Detection:**
```zig
test "pattern detection for memory errors" {
    var gpa = std.heap.GeneralPurposeAllocator(.{
        .safety = true,
        .thread_safe = true,
    }){};
    defer {
        const leaked = gpa.deinit();
        try std.testing.expect(leaked == .ok);
    }
    
    const allocator = gpa.allocator();
    
    // Test various memory patterns
    try testNoMemoryErrors(allocator);
}

fn testNoMemoryErrors(allocator: std.mem.Allocator) !void {
    // Allocate and properly free
    const buffer1 = try allocator.alloc(u8, 100);
    defer allocator.free(buffer1);
    
    // Initialize all memory
    @memset(buffer1, 0xFF);
    
    // Test reallocation
    const buffer2 = try allocator.realloc(buffer1[0..0], 200);
    defer if (buffer2.ptr != buffer1.ptr) allocator.free(buffer2);
    
    // Use reallocated memory
    @memset(buffer2, 0xAA);
}
```

**Key Points:**
- Zig prevents use-after-free through compile-time analysis and structured lifetime management
- Buffer overflows are caught through runtime bounds checking on arrays and slices
- Double-free prevention relies on ownership patterns and explicit state tracking
- Memory leak detection uses specialized allocators and testing infrastructure
- Valgrind integration works through standard debugging information and optional annotations
- All memory safety features work together to create a comprehensive protection system

---

