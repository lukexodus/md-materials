## Collections and Algorithms in Zig


Zig provides a comprehensive standard library with efficient collection types and algorithms. The collections are designed with explicit memory management, zero-cost abstractions, and performance in mind, giving developers full control over memory allocation and data structure behavior.

### ArrayList

ArrayList is Zig's dynamic array implementation, similar to vectors in other languages. It provides amortized O(1) append operations and efficient random access.

```zig
const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;

fn arrayListBasics(allocator: Allocator) !void {
    var list = ArrayList(i32).init(allocator);
    defer list.deinit();

    // Adding elements
    try list.append(42);
    try list.appendSlice(&[_]i32{ 1, 2, 3 });
    try list.insert(0, 100); // Insert at beginning

    // Accessing elements
    const first = list.items[0];
    const last = list.getLast();
    
    // Modifying elements
    list.items[1] = 999;
    
    // Removing elements
    const popped = list.pop();
    const removed = list.orderedRemove(0);
    _ = list.swapRemove(0); // Faster removal, doesn't preserve order
}
```

### ArrayList Advanced Operations

```zig
fn advancedArrayListOperations(allocator: Allocator) !void {
    var list = ArrayList([]const u8).init(allocator);
    defer {
        // Clean up string allocations
        for (list.items) |item| {
            allocator.free(item);
        }
        list.deinit();
    }

    // Pre-allocate capacity for better performance
    try list.ensureTotalCapacity(1000);
    
    // Batch operations
    const strings = [_][]const u8{ "hello", "world", "zig" };
    for (strings) |str| {
        const owned = try allocator.dupe(u8, str);
        try list.append(owned);
    }

    // Resize operations
    try list.resize(10);
    list.shrinkAndFree(5);
    
    // Clone and concatenate
    var cloned = try list.clone();
    defer cloned.deinit();
    
    try list.appendSlice(cloned.items);
}
```

### HashMap

HashMap provides efficient key-value storage with average O(1) lookup, insertion, and deletion operations.

```zig
const HashMap = std.HashMap;
const StringHashMap = std.StringHashMap;

fn hashMapBasics(allocator: Allocator) !void {
    var map = StringHashMap(i32).init(allocator);
    defer map.deinit();

    // Inserting values
    try map.put("answer", 42);
    try map.put("count", 100);
    
    // Retrieving values
    if (map.get("answer")) |value| {
        std.debug.print("Found: {}\n", .{value});
    }
    
    // Check existence
    const exists = map.contains("answer");
    
    // Remove values
    const removed = map.remove("count");
    _ = removed;
}
```

### Custom HashMap with Custom Types

```zig
const User = struct {
    id: u32,
    name: []const u8,
    
    fn hash(self: User) u32 {
        return std.hash_map.hashString(self.name) ^ self.id;
    }
    
    fn eql(self: User, other: User) bool {
        return self.id == other.id and std.mem.eql(u8, self.name, other.name);
    }
};

const UserHashMap = HashMap(User, []const u8, UserContext, std.hash_map.default_max_load_percentage);

const UserContext = struct {
    pub fn hash(self: @This(), user: User) u64 {
        _ = self;
        return user.hash();
    }
    
    pub fn eql(self: @This(), a: User, b: User) bool {
        _ = self;
        return a.eql(b);
    }
};

fn customHashMap(allocator: Allocator) !void {
    var user_map = UserHashMap.init(allocator);
    defer user_map.deinit();
    
    const user1 = User{ .id = 1, .name = "Alice" };
    const user2 = User{ .id = 2, .name = "Bob" };
    
    try user_map.put(user1, "Administrator");
    try user_map.put(user2, "User");
    
    if (user_map.get(user1)) |role| {
        std.debug.print("User role: {s}\n", .{role});
    }
}
```

### Sorting Algorithms

Zig's standard library provides several sorting algorithms optimized for different use cases.

```zig
fn sortingExamples(allocator: Allocator) !void {
    var numbers = [_]i32{ 64, 34, 25, 12, 22, 11, 90 };
    
    // Standard sort (typically introsort)
    std.sort.pdq(i32, &numbers, {}, comptime std.sort.asc(i32));
    
    // Stable sort (preserves relative order of equal elements)
    std.sort.block(i32, &numbers, {}, comptime std.sort.desc(i32));
    
    // Custom comparison function
    const Person = struct {
        name: []const u8,
        age: u32,
    };
    
    var people = [_]Person{
        .{ .name = "Alice", .age = 30 },
        .{ .name = "Bob", .age = 25 },
        .{ .name = "Charlie", .age = 35 },
    };
    
    // Sort by age
    std.sort.pdq(Person, &people, {}, struct {
        fn lessThan(context: void, a: Person, b: Person) bool {
            _ = context;
            return a.age < b.age;
        }
    }.lessThan);
}
```

### Advanced Sorting with Custom Context

```zig
const SortContext = struct {
    reverse: bool,
    
    fn lessThan(self: @This(), a: i32, b: i32) bool {
        return if (self.reverse) a > b else a < b;
    }
};

fn advancedSorting() void {
    var data = [_]i32{ 5, 2, 8, 1, 9 };
    
    const ctx = SortContext{ .reverse = true };
    std.sort.pdq(i32, &data, ctx, SortContext.lessThan);
}
```

### Search Algorithms

Binary search and linear search implementations for sorted and unsorted data.

```zig
fn searchAlgorithms() void {
    const data = [_]i32{ 1, 3, 5, 7, 9, 11, 13, 15 };
    
    // Binary search (requires sorted data)
    const target = 7;
    if (std.sort.binarySearch(i32, target, &data, {}, std.sort.asc(i32))) |index| {
        std.debug.print("Found {} at index {}\n", .{ target, index });
    }
    
    // Linear search
    if (std.mem.indexOf(i32, &data, &[_]i32{9})) |index| {
        std.debug.print("Linear search found at index {}\n", .{index});
    }
    
    // Custom binary search
    const result = binarySearchCustom(i32, &data, target, std.sort.asc(i32));
    if (result) |index| {
        std.debug.print("Custom search found at index {}\n", .{index});
    }
}

fn binarySearchCustom(
    comptime T: type,
    items: []const T,
    key: T,
    comptime compareFn: fn (void, T, T) bool,
) ?usize {
    var left: usize = 0;
    var right: usize = items.len;
    
    while (left < right) {
        const mid = left + (right - left) / 2;
        if (compareFn({}, items[mid], key)) {
            left = mid + 1;
        } else if (compareFn({}, key, items[mid])) {
            right = mid;
        } else {
            return mid;
        }
    }
    return null;
}
```

### Iterator Patterns

Zig doesn't have built-in iterators like some languages, but provides flexible patterns for iteration.

```zig
const Iterator = struct {
    items: []const i32,
    index: usize = 0,
    
    fn next(self: *Iterator) ?i32 {
        if (self.index >= self.items.len) return null;
        const item = self.items[self.index];
        self.index += 1;
        return item;
    }
    
    fn reset(self: *Iterator) void {
        self.index = 0;
    }
};

fn iteratorExample() void {
    const data = [_]i32{ 1, 2, 3, 4, 5 };
    var iter = Iterator{ .items = &data };
    
    while (iter.next()) |item| {
        std.debug.print("Item: {}\n", .{item});
    }
}
```

### Generic Iterator Pattern

```zig
fn GenericIterator(comptime T: type) type {
    return struct {
        const Self = @This();
        
        items: []const T,
        index: usize = 0,
        
        fn init(items: []const T) Self {
            return Self{ .items = items };
        }
        
        fn next(self: *Self) ?T {
            if (self.index >= self.items.len) return null;
            const item = self.items[self.index];
            self.index += 1;
            return item;
        }
        
        fn peek(self: *const Self) ?T {
            if (self.index >= self.items.len) return null;
            return self.items[self.index];
        }
        
        fn hasNext(self: *const Self) bool {
            return self.index < self.items.len;
        }
        
        fn collect(self: *Self, allocator: Allocator) ![]T {
            var result = ArrayList(T).init(allocator);
            defer result.deinit();
            
            while (self.next()) |item| {
                try result.append(item);
            }
            
            return result.toOwnedSlice();
        }
    };
}

fn genericIteratorExample(allocator: Allocator) !void {
    const strings = [_][]const u8{ "hello", "world", "zig" };
    var iter = GenericIterator([]const u8).init(&strings);
    
    while (iter.next()) |item| {
        std.debug.print("String: {s}\n", .{item});
    }
    
    // Reset and collect
    iter.reset();
    const collected = try iter.collect(allocator);
    defer allocator.free(collected);
}
```

### Filtering and Mapping Iterator

```zig
fn FilterIterator(comptime T: type) type {
    return struct {
        const Self = @This();
        const FilterFn = fn (T) bool;
        
        items: []const T,
        index: usize = 0,
        filter_fn: FilterFn,
        
        fn init(items: []const T, filter_fn: FilterFn) Self {
            return Self{
                .items = items,
                .filter_fn = filter_fn,
            };
        }
        
        fn next(self: *Self) ?T {
            while (self.index < self.items.len) {
                const item = self.items[self.index];
                self.index += 1;
                if (self.filter_fn(item)) {
                    return item;
                }
            }
            return null;
        }
    };
}

fn isEven(n: i32) bool {
    return n % 2 == 0;
}

fn filterIteratorExample() void {
    const numbers = [_]i32{ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 };
    var filter_iter = FilterIterator(i32).init(&numbers, isEven);
    
    while (filter_iter.next()) |even| {
        std.debug.print("Even number: {}\n", .{even});
    }
}
```

### Custom Collection Types

### Ring Buffer Implementation

```zig
fn RingBuffer(comptime T: type) type {
    return struct {
        const Self = @This();
        
        buffer: []T,
        head: usize = 0,
        tail: usize = 0,
        full: bool = false,
        allocator: Allocator,
        
        fn init(allocator: Allocator, capacity: usize) !Self {
            const buffer = try allocator.alloc(T, capacity);
            return Self{
                .buffer = buffer,
                .allocator = allocator,
            };
        }
        
        fn deinit(self: *Self) void {
            self.allocator.free(self.buffer);
        }
        
        fn push(self: *Self, item: T) bool {
            self.buffer[self.head] = item;
            
            if (self.full) {
                self.tail = (self.tail + 1) % self.buffer.len;
            }
            
            self.head = (self.head + 1) % self.buffer.len;
            self.full = self.head == self.tail;
            
            return true;
        }
        
        fn pop(self: *Self) ?T {
            if (self.empty()) return null;
            
            const item = self.buffer[self.tail];
            self.full = false;
            self.tail = (self.tail + 1) % self.buffer.len;
            
            return item;
        }
        
        fn empty(self: *const Self) bool {
            return !self.full and self.head == self.tail;
        }
        
        fn size(self: *const Self) usize {
            if (self.full) return self.buffer.len;
            if (self.head >= self.tail) return self.head - self.tail;
            return self.buffer.len + self.head - self.tail;
        }
    };
}
```

### Priority Queue Implementation

```zig
fn PriorityQueue(comptime T: type) type {
    return struct {
        const Self = @This();
        const CompareFn = fn (void, T, T) bool;
        
        items: ArrayList(T),
        compare_fn: CompareFn,
        
        fn init(allocator: Allocator, compare_fn: CompareFn) Self {
            return Self{
                .items = ArrayList(T).init(allocator),
                .compare_fn = compare_fn,
            };
        }
        
        fn deinit(self: *Self) void {
            self.items.deinit();
        }
        
        fn add(self: *Self, item: T) !void {
            try self.items.append(item);
            self.siftUp(self.items.items.len - 1);
        }
        
        fn removeMin(self: *Self) ?T {
            if (self.items.items.len == 0) return null;
            
            const min = self.items.items[0];
            const last = self.items.pop();
            
            if (self.items.items.len > 0) {
                self.items.items[0] = last;
                self.siftDown(0);
            }
            
            return min;
        }
        
        fn peek(self: *const Self) ?T {
            if (self.items.items.len == 0) return null;
            return self.items.items[0];
        }
        
        fn siftUp(self: *Self, start_index: usize) void {
            var index = start_index;
            while (index > 0) {
                const parent_index = (index - 1) / 2;
                if (!self.compare_fn({}, self.items.items[index], self.items.items[parent_index])) {
                    break;
                }
                std.mem.swap(T, &self.items.items[index], &self.items.items[parent_index]);
                index = parent_index;
            }
        }
        
        fn siftDown(self: *Self, start_index: usize) void {
            var index = start_index;
            while (true) {
                var min_index = index;
                const left_child = 2 * index + 1;
                const right_child = 2 * index + 2;
                
                if (left_child < self.items.items.len and 
                    self.compare_fn({}, self.items.items[left_child], self.items.items[min_index])) {
                    min_index = left_child;
                }
                
                if (right_child < self.items.items.len and 
                    self.compare_fn({}, self.items.items[right_child], self.items.items[min_index])) {
                    min_index = right_child;
                }
                
                if (min_index == index) break;
                
                std.mem.swap(T, &self.items.items[index], &self.items.items[min_index]);
                index = min_index;
            }
        }
    };
}
```

### Trie (Prefix Tree) Implementation

```zig
const TrieNode = struct {
    children: std.HashMap(u8, *TrieNode, std.hash_map.default_hash_context_type(u8), std.hash_map.default_max_load_percentage),
    is_end: bool = false,
    allocator: Allocator,
    
    fn init(allocator: Allocator) TrieNode {
        return TrieNode{
            .children = std.HashMap(u8, *TrieNode, std.hash_map.default_hash_context_type(u8), std.hash_map.default_max_load_percentage).init(allocator),
            .allocator = allocator,
        };
    }
    
    fn deinit(self: *TrieNode) void {
        var iter = self.children.iterator();
        while (iter.next()) |entry| {
            entry.value_ptr.*.deinit();
            self.allocator.destroy(entry.value_ptr.*);
        }
        self.children.deinit();
    }
};

const Trie = struct {
    root: TrieNode,
    allocator: Allocator,
    
    fn init(allocator: Allocator) Trie {
        return Trie{
            .root = TrieNode.init(allocator),
            .allocator = allocator,
        };
    }
    
    fn deinit(self: *Trie) void {
        self.root.deinit();
    }
    
    fn insert(self: *Trie, word: []const u8) !void {
        var current = &self.root;
        
        for (word) |char| {
            if (!current.children.contains(char)) {
                const new_node = try self.allocator.create(TrieNode);
                new_node.* = TrieNode.init(self.allocator);
                try current.children.put(char, new_node);
            }
            current = current.children.get(char).?;
        }
        
        current.is_end = true;
    }
    
    fn search(self: *const Trie, word: []const u8) bool {
        var current = &self.root;
        
        for (word) |char| {
            if (!current.children.contains(char)) {
                return false;
            }
            current = current.children.get(char).?;
        }
        
        return current.is_end;
    }
    
    fn startsWith(self: *const Trie, prefix: []const u8) bool {
        var current = &self.root;
        
        for (prefix) |char| {
            if (!current.children.contains(char)) {
                return false;
            }
            current = current.children.get(char).?;
        }
        
        return true;
    }
};
```

### Algorithm Utilities

```zig
const AlgorithmUtils = struct {
    // Find all permutations
    fn permutations(comptime T: type, allocator: Allocator, items: []const T) ![][]T {
        if (items.len == 0) return &[_][]T{};
        if (items.len == 1) {
            const result = try allocator.alloc([]T, 1);
            result[0] = try allocator.dupe(T, items);
            return result;
        }
        
        var results = ArrayList([]T).init(allocator);
        defer results.deinit();
        
        for (items, 0..) |_, i| {
            var remaining = ArrayList(T).init(allocator);
            defer remaining.deinit();
            
            for (items, 0..) |item, j| {
                if (i != j) try remaining.append(item);
            }
            
            const sub_perms = try permutations(T, allocator, remaining.items);
            defer {
                for (sub_perms) |perm| allocator.free(perm);
                allocator.free(sub_perms);
            }
            
            for (sub_perms) |perm| {
                var new_perm = try allocator.alloc(T, items.len);
                new_perm[0] = items[i];
                @memcpy(new_perm[1..], perm);
                try results.append(new_perm);
            }
        }
        
        return results.toOwnedSlice();
    }
    
    // Longest Common Subsequence
    fn longestCommonSubsequence(allocator: Allocator, a: []const u8, b: []const u8) ![]u8 {
        const m = a.len;
        const n = b.len;
        
        // Create DP table
        var dp = try allocator.alloc([]usize, m + 1);
        defer allocator.free(dp);
        
        for (dp) |*row| {
            row.* = try allocator.alloc(usize, n + 1);
        }
        defer {
            for (dp) |row| allocator.free(row);
        }
        
        // Initialize DP table
        for (0..m + 1) |i| {
            for (0..n + 1) |j| {
                dp[i][j] = 0;
            }
        }
        
        // Fill DP table
        for (1..m + 1) |i| {
            for (1..n + 1) |j| {
                if (a[i - 1] == b[j - 1]) {
                    dp[i][j] = dp[i - 1][j - 1] + 1;
                } else {
                    dp[i][j] = @max(dp[i - 1][j], dp[i][j - 1]);
                }
            }
        }
        
        // Reconstruct LCS
        var result = ArrayList(u8).init(allocator);
        defer result.deinit();
        
        var i = m;
        var j = n;
        while (i > 0 and j > 0) {
            if (a[i - 1] == b[j - 1]) {
                try result.append(a[i - 1]);
                i -= 1;
                j -= 1;
            } else if (dp[i - 1][j] > dp[i][j - 1]) {
                i -= 1;
            } else {
                j -= 1;
            }
        }
        
        // Reverse result
        std.mem.reverse(u8, result.items);
        return result.toOwnedSlice();
    }
};
```

### Performance Benchmarking

```zig
const BenchmarkTimer = struct {
    start_time: i128,
    
    fn start() BenchmarkTimer {
        return BenchmarkTimer{
            .start_time = std.time.nanoTimestamp(),
        };
    }
    
    fn elapsed(self: *const BenchmarkTimer) i128 {
        return std.time.nanoTimestamp() - self.start_time;
    }
    
    fn elapsedMs(self: *const BenchmarkTimer) f64 {
        return @as(f64, @floatFromInt(self.elapsed())) / 1_000_000.0;
    }
};

fn benchmarkCollections(allocator: Allocator) !void {
    const size = 100_000;
    
    // ArrayList benchmark
    var timer = BenchmarkTimer.start();
    var list = ArrayList(i32).init(allocator);
    defer list.deinit();
    
    for (0..size) |i| {
        try list.append(@intCast(i));
    }
    
    std.debug.print("ArrayList insert: {d:.2}ms\n", .{timer.elapsedMs()});
    
    // HashMap benchmark
    timer = BenchmarkTimer.start();
    var map = std.AutoHashMap(i32, i32).init(allocator);
    defer map.deinit();
    
    for (0..size) |i| {
        try map.put(@intCast(i), @intCast(i * 2));
    }
    
    std.debug.print("HashMap insert: {d:.2}ms\n", .{timer.elapsedMs()});
}
```

**Conclusion:** Zig's collection types and algorithms provide excellent performance with explicit memory management. The standard library offers solid foundations while allowing developers to build custom collection types tailored to specific needs. The combination of compile-time generics, zero-cost abstractions, and direct memory control makes Zig collections both efficient and flexible for systems programming and application development.

---

