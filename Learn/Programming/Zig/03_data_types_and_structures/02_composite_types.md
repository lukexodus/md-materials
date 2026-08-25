## Composite Types


### Arrays and Array Operations

Arrays in Zig are fixed-size, homogeneous collections with their length known at compile time. The type signature includes both the element type and length.

**Array Declaration and Initialization:**
```zig
const numbers: [5]i32 = [5]i32{ 1, 2, 3, 4, 5 };
const chars = [_]u8{ 'H', 'e', 'l', 'l', 'o' }; // Length inferred
const zeros = [10]i32{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
const repeated = [8]i32{42} ** 8; // Repeat initialization
```

**Array Initialization Patterns:**
```zig
// Partial initialization (rest are zero)
const partial: [10]i32 = [_]i32{ 1, 2, 3 };

// Undefined initialization
var buffer: [256]u8 = undefined;

// Computed initialization
const squares = [_]i32{ 1*1, 2*2, 3*3, 4*4, 5*5 };

// Multi-dimensional arrays
const matrix: [3][3]i32 = [3][3]i32{
    [3]i32{ 1, 2, 3 },
    [3]i32{ 4, 5, 6 },
    [3]i32{ 7, 8, 9 },
};
```

**Array Access and Modification:**
```zig
var arr = [_]i32{ 10, 20, 30, 40, 50 };
const first = arr[0];     // Access by index
arr[2] = 99;             // Modify element
const length = arr.len;   // Get array length

// Bounds checking
const safe_access = if (index < arr.len) arr[index] else 0;
```

**Array Operations:**
```zig
const source = [_]i32{ 1, 2, 3, 4, 5 };
var dest: [5]i32 = undefined;

// Copy arrays
dest = source;

// Array comparison
const are_equal = std.mem.eql(i32, &source, &dest);

// Fill array
std.mem.set(i32, dest[0..], 42);

// Find element
const index = std.mem.indexOf(i32, &source, &[_]i32{3});
```

**Array Iteration:**
```zig
const items = [_]i32{ 1, 2, 3, 4, 5 };

// Index-based iteration
for (items, 0..) |item, i| {
    std.debug.print("items[{}] = {}\n", .{ i, item });
}

// Simple iteration
for (items) |item| {
    std.debug.print("{}\n", .{item});
}

// Range iteration
for (0..items.len) |i| {
    std.debug.print("{}\n", .{items[i]});
}
```

### Slices and String Slices

Slices are runtime-sized views into arrays or other memory regions, consisting of a pointer and length.

**Slice Creation:**
```zig
var array = [_]i32{ 1, 2, 3, 4, 5, 6, 7, 8 };
const full_slice: []i32 = array[0..];        // Entire array
const partial_slice: []i32 = array[2..5];    // Elements 2, 3, 4
const from_start: []i32 = array[..3];        // Elements 0, 1, 2
const to_end: []i32 = array[3..];            // Elements 3, 4, 5, 6, 7
```

**Slice Properties and Operations:**
```zig
const slice: []const i32 = &[_]i32{ 1, 2, 3, 4, 5 };
const length = slice.len;           // Runtime length
const ptr = slice.ptr;              // Pointer to first element
const first = slice[0];             // Element access
const sub_slice = slice[1..3];      // Sub-slicing
```

**Mutable vs Immutable Slices:**
```zig
var mutable_array = [_]i32{ 1, 2, 3, 4, 5 };
var mutable_slice: []i32 = mutable_array[0..];
mutable_slice[0] = 99;              // Allowed

const immutable_slice: []const i32 = mutable_array[0..];
// immutable_slice[0] = 99;         // Compile error
```

**String Slices:**
```zig
const message: []const u8 = "Hello, Zig!";
const greeting = message[0..5];     // "Hello"
const punctuation = message[10..];  // "!"

// String literals are []const u8
const literal = "This is a string literal";
const length = literal.len;

// Multi-line strings
const multiline =
    \\First line
    \\Second line
    \\Third line
;
```

**String Operations:**
```zig
const std = @import("std");

const text1 = "Hello";
const text2 = "World";

// String comparison
const are_equal = std.mem.eql(u8, text1, "Hello");

// String concatenation (requires allocator)
var allocator = std.heap.page_allocator;
const combined = try std.fmt.allocPrint(allocator, "{s} {s}!", .{ text1, text2 });

// String searching
const index = std.mem.indexOf(u8, "Hello World", "World");

// String splitting
var iterator = std.mem.split(u8, "one,two,three", ",");
while (iterator.next()) |part| {
    std.debug.print("{s}\n", .{part});
}
```

**Slice Iteration:**
```zig
const data: []const i32 = &[_]i32{ 1, 2, 3, 4, 5 };

for (data, 0..) |value, index| {
    std.debug.print("data[{}] = {}\n", .{ index, value });
}

// Character iteration for strings
const text = "Hello";
for (text) |char| {
    std.debug.print("'{c}'\n", .{char});
}
```

### Structures (Structs)

Structs are composite types that group related data fields together, similar to records or classes in other languages.

**Basic Struct Definition:**
```zig
const Point = struct {
    x: f32,
    y: f32,
    
    // Method definition
    pub fn distance(self: Point, other: Point) f32 {
        const dx = self.x - other.x;
        const dy = self.y - other.y;
        return @sqrt(dx * dx + dy * dy);
    }
    
    // Constructor-like function
    pub fn init(x: f32, y: f32) Point {
        return Point{ .x = x, .y = y };
    }
};
```

**Struct Instantiation and Usage:**
```zig
// Direct initialization
const origin = Point{ .x = 0.0, .y = 0.0 };
const point1 = Point{ .x = 3.0, .y = 4.0 };

// Using constructor
const point2 = Point.init(1.0, 2.0);

// Field access
const x_coord = point1.x;
var mutable_point = Point{ .x = 0.0, .y = 0.0 };
mutable_point.y = 5.0;

// Method calls
const dist = point1.distance(point2);
```

**Struct Features:**
```zig
const Person = struct {
    name: []const u8,
    age: u32,
    active: bool = true,          // Default value
    
    // Constants within struct
    const MAX_AGE: u32 = 150;
    
    // Nested struct
    const Address = struct {
        street: []const u8,
        city: []const u8,
        zip: []const u8,
    };
    
    address: ?Address = null,     // Optional field
    
    // Static method (no self parameter)
    pub fn createDefault() Person {
        return Person{
            .name = "Unknown",
            .age = 0,
        };
    }
    
    // Method with mutable self
    pub fn haveBirthday(self: *Person) void {
        if (self.age < MAX_AGE) {
            self.age += 1;
        }
    }
    
    // Const method
    pub fn canVote(self: Person) bool {
        return self.age >= 18;
    }
};
```

**Generic Structs:**
```zig
fn Vector(comptime T: type) type {
    return struct {
        const Self = @This();
        
        x: T,
        y: T,
        z: T,
        
        pub fn init(x: T, y: T, z: T) Self {
            return Self{ .x = x, .y = y, .z = z };
        }
        
        pub fn add(self: Self, other: Self) Self {
            return Self{
                .x = self.x + other.x,
                .y = self.y + other.y,
                .z = self.z + other.z,
            };
        }
    };
}

// Usage
const Vec3f = Vector(f32);
const Vec3i = Vector(i32);

const v1 = Vec3f.init(1.0, 2.0, 3.0);
const v2 = Vec3f.init(4.0, 5.0, 6.0);
const result = v1.add(v2);
```

**Packed Structs:**
```zig
const Flags = packed struct {
    read: bool,
    write: bool,
    execute: bool,
    _unused: u5 = 0,        // Padding to byte boundary
};

// Guaranteed to be exactly 1 byte
const flags = Flags{ .read = true, .write = false, .execute = true };
const as_byte: u8 = @bitCast(flags);
```

### Unions and Tagged Unions

Unions allow storing different types in the same memory location, with tagged unions providing type safety through enum tags.

**Basic Unions:**
```zig
const Value = union {
    integer: i32,
    float: f32,
    string: []const u8,
};

// Usage requires explicit field access
var value = Value{ .integer = 42 };
// const int_val = value.integer;    // Access the integer field
// const float_val = value.float;    // Undefined behavior if not active field
```

**Tagged Unions (Discriminated Unions):**
```zig
const TokenType = enum {
    number,
    string,
    boolean,
    null_value,
};

const Token = union(TokenType) {
    number: f64,
    string: []const u8,
    boolean: bool,
    null_value: void,
    
    // Methods can be defined
    pub fn print(self: Token) void {
        switch (self) {
            .number => |n| std.debug.print("Number: {}\n", .{n}),
            .string => |s| std.debug.print("String: {s}\n", .{s}),
            .boolean => |b| std.debug.print("Boolean: {}\n", .{b}),
            .null_value => std.debug.print("Null\n", .{}),
        }
    }
};
```

**Tagged Union Operations:**
```zig
// Creation
const token1 = Token{ .number = 3.14 };
const token2 = Token{ .string = "hello" };
const token3 = Token{ .boolean = true };
const token4 = Token{ .null_value = {} };

// Pattern matching with switch
fn processToken(token: Token) void {
    switch (token) {
        .number => |value| {
            std.debug.print("Processing number: {}\n", .{value});
        },
        .string => |text| {
            std.debug.print("Processing string: {s}\n", .{text});
        },
        .boolean => |flag| {
            if (flag) {
                std.debug.print("True value\n", .{});
            } else {
                std.debug.print("False value\n", .{});
            }
        },
        .null_value => {
            std.debug.print("Null value\n", .{});
        },
    }
}

// Tag inspection
const tag = std.meta.activeTag(token1); // Returns TokenType.number
const is_string = token2 == .string;
```

**Generic Tagged Unions:**
```zig
fn Result(comptime T: type, comptime E: type) type {
    return union(enum) {
        ok: T,
        err: E,
        
        pub fn isOk(self: @This()) bool {
            return self == .ok;
        }
        
        pub fn unwrap(self: @This()) T {
            return switch (self) {
                .ok => |value| value,
                .err => @panic("Attempted to unwrap error"),
            };
        }
    };
}

// Usage
const IntResult = Result(i32, []const u8);
const success = IntResult{ .ok = 42 };
const failure = IntResult{ .err = "Division by zero" };

if (success.isOk()) {
    const value = success.unwrap();
}
```

### Enumerations (Enums)

Enums define a set of named integer constants, providing type-safe alternatives to magic numbers.

**Basic Enum Definition:**
```zig
const Color = enum {
    red,
    green,
    blue,
    yellow,
    purple,
    
    // Methods can be defined
    pub fn isWarm(self: Color) bool {
        return switch (self) {
            .red, .yellow => true,
            .green, .blue, .purple => false,
        };
    }
};
```

**Enum with Explicit Values:**
```zig
const Status = enum(u8) {
    pending = 1,
    processing = 2,
    completed = 10,
    failed = 99,
    
    // Convert to string
    pub fn toString(self: Status) []const u8 {
        return switch (self) {
            .pending => "Pending",
            .processing => "Processing",
            .completed => "Completed",
            .failed => "Failed",
        };
    }
};
```

**Enum Operations:**
```zig
const current_color = Color.red;
const is_warm = current_color.isWarm();

// Enum comparison
const same_color = (current_color == Color.red);

// Convert to integer (for enums with explicit backing type)
const status_code = @intFromEnum(Status.completed); // Returns 10

// Convert from integer
const status_from_int = @enumFromInt(Status, 2); // Returns Status.processing

// Iterate over enum values
const all_colors = std.meta.fields(Color);
for (all_colors) |field| {
    std.debug.print("Color: {s}\n", .{field.name});
}
```

**Non-exhaustive Enums:**
```zig
const Protocol = enum(u16) {
    http = 80,
    https = 443,
    ftp = 21,
    ssh = 22,
    _,  // Non-exhaustive marker
    
    pub fn fromPort(port: u16) Protocol {
        return @enumFromInt(Protocol, port);
    }
};

// Can handle unknown values
const unknown_protocol = Protocol.fromPort(8080);
switch (unknown_protocol) {
    .http => std.debug.print("HTTP\n", .{}),
    .https => std.debug.print("HTTPS\n", .{}),
    else => std.debug.print("Unknown protocol: {}\n", .{@intFromEnum(unknown_protocol)}),
}
```

**Enum Sets (Flag Enums):**
```zig
const Permission = enum(u8) {
    read = 1,
    write = 2,
    execute = 4,
    
    pub fn hasPermission(permissions: u8, permission: Permission) bool {
        return (permissions & @intFromEnum(permission)) != 0;
    }
};

const user_permissions: u8 = @intFromEnum(Permission.read) | @intFromEnum(Permission.write);
const can_read = Permission.hasPermission(user_permissions, .read);
const can_execute = Permission.hasPermission(user_permissions, .execute);
```

**Key Points:**
- Arrays have compile-time known sizes and provide bounds checking
- Slices are runtime-sized views with pointer and length, ideal for string handling
- Structs support methods, default values, generics, and memory layout control
- Tagged unions provide type-safe variant types with pattern matching via switch
- Enums create named constants with optional explicit values and support methods
- All composite types can be generic using comptime parameters for flexible, reusable code

---

