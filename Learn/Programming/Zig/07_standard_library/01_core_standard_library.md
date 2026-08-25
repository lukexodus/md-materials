## Core Standard Library


Zig's standard library provides essential functionality for systems programming through a well-organized collection of modules. The library emphasizes safety, performance, and explicit resource management while maintaining zero-cost abstractions.

### Basic Data Structures

The standard library includes fundamental data structures for memory management and collection handling. These structures provide building blocks for more complex applications.

**Key points:**

- ArrayList for dynamic arrays with automatic memory management
- HashMap for key-value storage with customizable hash functions
- LinkedList for sequential data with efficient insertion/deletion
- ArrayDeque for double-ended queue operations
- All structures require explicit allocator management

**Example:**

```zig
const std = @import("std");
const ArrayList = std.ArrayList;
const HashMap = std.HashMap;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // ArrayList usage
    var list = ArrayList(i32).init(allocator);
    defer list.deinit();
    
    try list.append(42);
    try list.append(84);
    try list.insert(1, 63);
    
    // HashMap usage
    var map = HashMap([]const u8, i32, std.hash_map.StringContext, 80).init(allocator);
    defer map.deinit();
    
    try map.put("answer", 42);
    try map.put("double", 84);
    
    if (map.get("answer")) |value| {
        std.debug.print("Found: {}\n", .{value});
    }
}
```

**Array and slice operations:**

```zig
const std = @import("std");

// Array utilities
const arr = [_]i32{1, 2, 3, 4, 5};
const slice = arr[1..4];

// Sorting and searching
var mutable_arr = [_]i32{5, 2, 8, 1, 9};
std.sort.insertion(i32, &mutable_arr, {}, std.sort.asc(i32));

const index = std.sort.binarySearch(i32, 5, &mutable_arr, {}, std.sort.asc(i32));
```

### String manipulation Utilities

Zig provides comprehensive string handling through UTF-8 aware utilities and memory-safe operations. String manipulation focuses on explicit memory management and encoding awareness.

**Key points:**

- Strings are UTF-8 byte arrays (`[]const u8`)
- No null-termination requirement unlike C strings
- Built-in Unicode support through `std.unicode`
- Memory allocation required for dynamic string operations
- Formatting through `std.fmt` module

**Example:**

```zig
const std = @import("std");
const print = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // String operations
    const original = "Hello, Zig!";
    const upper = try std.ascii.allocUpperString(allocator, original);
    defer allocator.free(upper);
    
    // String formatting
    const formatted = try std.fmt.allocPrint(allocator, "Number: {d}, String: {s}", .{42, "test"});
    defer allocator.free(formatted);
    
    // String splitting
    var iter = std.mem.split(u8, "apple,banana,cherry", ",");
    while (iter.next()) |part| {
        print("Part: {s}\n", .{part});
    }
    
    // String searching and replacement
    const haystack = "The quick brown fox";
    const needle = "quick";
    if (std.mem.indexOf(u8, haystack, needle)) |index| {
        print("Found '{}' at index {}\n", .{needle, index});
    }
}
```

**UTF-8 handling:**

```zig
const std = @import("std");

pub fn processUnicodeString(text: []const u8) !void {
    // Validate UTF-8
    if (!std.unicode.utf8ValidateSlice(text)) {
        return error.InvalidUtf8;
    }
    
    // Iterate over Unicode code points
    var iter = std.unicode.Utf8Iterator{.bytes = text, .i = 0};
    while (iter.nextCodepoint()) |codepoint| {
        std.debug.print("Codepoint: U+{X}\n", .{codepoint});
    }
    
    // Count grapheme clusters (user-perceived characters)
    const grapheme_count = try std.unicode.utf8CountCodepoints(text);
    std.debug.print("Grapheme count: {}\n", .{grapheme_count});
}
```

### Mathematical Functions

The math module provides comprehensive mathematical operations including trigonometry, logarithms, and specialized functions for systems programming needs.

**Key points:**

- Full floating-point math library in `std.math`
- Integer overflow detection and handling
- Platform-specific optimizations where available
- Support for different floating-point precisions
- Statistical and advanced mathematical functions

**Example:**

```zig
const std = @import("std");
const math = std.math;

pub fn main() void {
    // Basic arithmetic with overflow checking
    const a: i32 = 100;
    const b: i32 = 50;
    
    const sum = math.add(i32, a, b) catch |err| switch (err) {
        error.Overflow => {
            std.debug.print("Addition overflow!\n", .{});
            return;
        },
    };
    
    // Floating-point operations
    const angle = math.pi / 4.0;
    const sin_val = math.sin(angle);
    const cos_val = math.cos(angle);
    const sqrt_val = math.sqrt(16.0);
    
    std.debug.print("sin(π/4) = {d:.6}\n", .{sin_val});
    std.debug.print("cos(π/4) = {d:.6}\n", .{cos_val});
    std.debug.print("√16 = {d}\n", .{sqrt_val});
    
    // Power and logarithmic functions
    const power = math.pow(f64, 2.0, 8.0);
    const log_val = math.log(f64, power);
    const log10_val = math.log10(f64, 1000.0);
    
    // Min/max and clamping
    const min_val = math.min(42, 84);
    const max_val = math.max(42, 84);
    const clamped = math.clamp(150, 0, 100);
    
    std.debug.print("Clamped 150 to [0,100]: {}\n", .{clamped});
}
```

**Advanced mathematical operations:**

```zig
const std = @import("std");
const math = std.math;

// Statistical functions
fn calculateStats(values: []const f64) struct {mean: f64, variance: f64, stddev: f64} {
    var sum: f64 = 0;
    for (values) |val| sum += val;
    const mean = sum / @as(f64, @floatFromInt(values.len));
    
    var variance_sum: f64 = 0;
    for (values) |val| {
        const diff = val - mean;
        variance_sum += diff * diff;
    }
    const variance = variance_sum / @as(f64, @floatFromInt(values.len));
    const stddev = math.sqrt(variance);
    
    return .{.mean = mean, .variance = variance, .stddev = stddev};
}
```

### Time and Date Handling

Zig's time handling focuses on system timestamps and duration calculations. The standard library provides utilities for working with Unix timestamps and monotonic time.

**Key points:**

- `std.time` module for time operations
- Unix timestamp support through `std.time.timestamp()`
- Monotonic time for performance measurement
- Sleep functionality for blocking operations
- Cross-platform time zone handling [Unverified]

**Example:**

```zig
const std = @import("std");
const time = std.time;

pub fn main() !void {
    // Current timestamp
    const current_timestamp = time.timestamp();
    std.debug.print("Current Unix timestamp: {}\n", .{current_timestamp});
    
    // Monotonic time for performance measurement
    const start = time.nanoTimestamp();
    
    // Simulate work
    time.sleep(time.ns_per_ms * 100); // Sleep for 100ms
    
    const end = time.nanoTimestamp();
    const duration_ns = end - start;
    const duration_ms = duration_ns / time.ns_per_ms;
    
    std.debug.print("Operation took: {} ms\n", .{duration_ms});
    
    // Time calculations
    const seconds_per_day = 24 * 60 * 60;
    const days_since_epoch = current_timestamp / seconds_per_day;
    std.debug.print("Days since Unix epoch: {}\n", .{days_since_epoch});
}
```

**Timer and benchmarking utilities:**

```zig
const std = @import("std");

const Timer = struct {
    start_time: i128,
    
    pub fn start() Timer {
        return Timer{
            .start_time = std.time.nanoTimestamp(),
        };
    }
    
    pub fn lap(self: Timer) i128 {
        return std.time.nanoTimestamp() - self.start_time;
    }
    
    pub fn read(self: Timer) f64 {
        const elapsed_ns = self.lap();
        return @as(f64, @floatFromInt(elapsed_ns)) / std.time.ns_per_s;
    }
};

pub fn benchmarkFunction(comptime func: anytype, args: anytype) !f64 {
    const timer = Timer.start();
    _ = @call(.auto, func, args);
    return timer.read();
}
```

### Random Number Generation

Zig provides cryptographically secure and pseudo-random number generators through the `std.Random` interface. The system supports various algorithms and seeding mechanisms.

**Key points:**

- Multiple PRNG algorithms available (Xoshiro256++, PCG, etc.)
- Cryptographically secure random through `std.crypto.random`
- Seedable generators for reproducible sequences
- Type-safe random value generation
- Thread-safe random number access

**Example:**

```zig
const std = @import("std");

pub fn main() !void {
    // Cryptographically secure random
    const secure_random = std.crypto.random;
    const secure_int = secure_random.int(u32);
    const secure_float = secure_random.float(f64);
    
    std.debug.print("Secure random int: {}\n", .{secure_int});
    std.debug.print("Secure random float: {d:.6}\n", .{secure_float});
    
    // Seedable PRNG for reproducible sequences
    var prng = std.rand.DefaultPrng.init(12345);
    const random = prng.random();
    
    // Generate various random types
    const rand_bool = random.boolean();
    const rand_int = random.intRange(i32, 1, 100);
    const rand_float = random.floatNorm(f64); // Normal distribution
    
    std.debug.print("Random boolean: {}\n", .{rand_bool});
    std.debug.print("Random int [1,100): {}\n", .{rand_int});
    std.debug.print("Random normal float: {d:.6}\n", .{rand_float});
    
    // Fill array with random data
    var buffer: [16]u8 = undefined;
    random.bytes(&buffer);
    
    std.debug.print("Random bytes: ");
    for (buffer) |byte| {
        std.debug.print("{:02X} ", .{byte});
    }
    std.debug.print("\n", .{});
}
```

**Custom random distributions:**

```zig
const std = @import("std");

// Weighted random selection
fn weightedChoice(random: std.Random, comptime T: type, choices: []const T, weights: []const f64) T {
    std.debug.assert(choices.len == weights.len);
    
    var total_weight: f64 = 0;
    for (weights) |weight| total_weight += weight;
    
    const rand_val = random.float(f64) * total_weight;
    var cumulative: f64 = 0;
    
    for (choices, weights) |choice, weight| {
        cumulative += weight;
        if (rand_val <= cumulative) return choice;
    }
    
    return choices[choices.len - 1];
}

// Generate random string
fn randomString(allocator: std.mem.Allocator, random: std.Random, length: usize) ![]u8 {
    const charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    var result = try allocator.alloc(u8, length);
    
    for (result) |*char| {
        const index = random.intRange(usize, 0, charset.len);
        char.* = charset[index];
    }
    
    return result;
}
```

**Output:** The standard library modules integrate seamlessly to provide comprehensive functionality for systems programming, from basic data manipulation to cryptographically secure operations.

**Conclusion:** Zig's standard library emphasizes explicit resource management, type safety, and performance while providing essential functionality for systems programming through well-designed APIs that maintain zero-cost abstractions and cross-platform compatibility.

---

