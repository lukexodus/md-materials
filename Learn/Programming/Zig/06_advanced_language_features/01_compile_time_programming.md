## Compile-time Programming


### Comptime Keyword Usage

The `comptime` keyword enables computations to occur during compilation rather than runtime, allowing for powerful compile-time programming and zero-cost abstractions.

**Comptime Variables:**
```zig
comptime var global_counter = 0;

fn getNextId() u32 {
    comptime {
        global_counter += 1;
        return global_counter;
    }
}

// Each call gets a unique compile-time computed ID
const id1 = getNextId(); // 1
const id2 = getNextId(); // 2
const id3 = getNextId(); // 3
```

**Comptime Parameters:**
```zig
fn createArray(comptime T: type, comptime size: usize, comptime default_value: T) [size]T {
    var array: [size]T = undefined;
    comptime var i = 0;
    inline while (i < size) : (i += 1) {
        array[i] = default_value;
    }
    return array;
}

// Creates different arrays at compile time
const int_array = createArray(i32, 10, 42);
const float_array = createArray(f64, 5, 3.14);
const bool_array = createArray(bool, 3, true);
```

**Comptime Expressions:**
```zig
const Config = struct {
    buffer_size: usize,
    max_connections: u32,
    debug_enabled: bool,
    
    // Computed at compile time
    const calculated_buffer_size = comptime blk: {
        var size: usize = 1024;
        if (@import("builtin").mode == .Debug) {
            size *= 2; // Double buffer size in debug mode
        }
        break :blk size;
    };
    
    const version_string = comptime std.fmt.comptimePrint("v{d}.{d}.{d}", .{ 1, 2, 3 });
};
```

**Comptime Conditionals:**
```zig
fn platformSpecificFunction() void {
    comptime if (@import("builtin").target.os.tag == .windows) {
        // Windows-specific code compiled only on Windows
        std.debug.print("Running on Windows\n", .{});
    } else if (@import("builtin").target.os.tag == .linux) {
        // Linux-specific code compiled only on Linux
        std.debug.print("Running on Linux\n", .{});
    } else {
        // Other platforms
        std.debug.print("Running on other platform\n", .{});
    }
}

// Feature flag compilation
fn optionalFeature() void {
    const enable_feature = @import("config").enable_advanced_logging;
    
    comptime if (enable_feature) {
        std.debug.print("Advanced logging enabled\n", .{});
        // Complex logging code only compiled when feature is enabled
    } else {
        // Minimal logging
        std.debug.print("Basic logging\n", .{});
    }
}
```

**Comptime String Operations:**
```zig
const compile_time_strings = struct {
    const base_name = "MyApplication";
    const version = "1.0.0";
    const build_type = if (@import("builtin").mode == .Debug) "Debug" else "Release";
    
    // String concatenation at compile time
    const full_name = comptime base_name ++ " " ++ version ++ " (" ++ build_type ++ ")";
    
    // Generate function names
    const getter_name = comptime "get" ++ capitalize(base_name);
    
    fn capitalize(comptime str: []const u8) []const u8 {
        if (str.len == 0) return str;
        
        var result: [str.len]u8 = undefined;
        result[0] = std.ascii.toUpper(str[0]);
        
        comptime var i = 1;
        inline while (i < str.len) : (i += 1) {
            result[i] = str[i];
        }
        
        return result[0..];
    }
};
```

### Compile-time Function Execution

Functions can be executed entirely at compile time when all their inputs are comptime-known, enabling complex code generation and optimization.

**Comptime Mathematical Computations:**
```zig
fn fibonacci(comptime n: u32) u64 {
    if (n <= 1) return n;
    return fibonacci(n - 1) + fibonacci(n - 2);
}

// Computed at compile time - no runtime cost
const fib_10 = fibonacci(10);  // 55
const fib_20 = fibonacci(20);  // 6765

// Generate lookup table at compile time
const fib_table = comptime blk: {
    var table: [21]u64 = undefined;
    for (table, 0..) |*entry, i| {
        entry.* = fibonacci(i);
    }
    break :blk table;
};
```

**Comptime Data Structure Generation:**
```zig
const FieldInfo = struct {
    name: []const u8,
    type_name: []const u8,
    offset: usize,
};

fn generateFieldInfo(comptime T: type) []const FieldInfo {
    const fields = std.meta.fields(T);
    comptime var field_infos: [fields.len]FieldInfo = undefined;
    
    inline for (fields, 0..) |field, i| {
        field_infos[i] = FieldInfo{
            .name = field.name,
            .type_name = @typeName(field.type),
            .offset = @offsetOf(T, field.name),
        };
    }
    
    return &field_infos;
}

const Person = struct {
    name: []const u8,
    age: u32,
    height: f32,
};

// Generated at compile time
const person_fields = generateFieldInfo(Person);
```

**Comptime Hash Map Generation:**
```zig
fn ComptimeHashMap(comptime K: type, comptime V: type, comptime entries: anytype) type {
    return struct {
        const Self = @This();
        const Entry = struct { key: K, value: V };
        const entries_array = comptime blk: {
            var array: [entries.len]Entry = undefined;
            inline for (entries, 0..) |entry, i| {
                array[i] = Entry{
                    .key = entry.@"0",
                    .value = entry.@"1",
                };
            }
            break :blk array;
        };
        
        pub fn get(key: K) ?V {
            inline for (entries_array) |entry| {
                if (std.meta.eql(entry.key, key)) {
                    return entry.value;
                }
            }
            return null;
        }
        
        pub fn has(key: K) bool {
            return get(key) != null;
        }
    };
}

// Usage - entire map is compile-time generated
const StatusMap = ComptimeHashMap(u32, []const u8, .{
    .{ 200, "OK" },
    .{ 404, "Not Found" },
    .{ 500, "Internal Server Error" },
});

const status_text = StatusMap.get(404); // Some("Not Found")
```

**Comptime String Processing:**
```zig
fn parseEnumFromString(comptime EnumType: type, comptime str: []const u8) EnumType {
    const enum_info = @typeInfo(EnumType).Enum;
    
    inline for (enum_info.fields) |field| {
        if (std.mem.eql(u8, field.name, str)) {
            return @enumFromInt(field.value);
        }
    }
    
    @compileError("Invalid enum value: " ++ str);
}

const Color = enum { red, green, blue };

// Parsed at compile time
const red_color = parseEnumFromString(Color, "red");
const blue_color = parseEnumFromString(Color, "blue");
// const invalid = parseEnumFromString(Color, "yellow"); // Compile error
```

### Type Reflection Capabilities

Zig provides extensive type introspection capabilities through `@typeInfo()` and related built-in functions, enabling powerful generic programming.

**Basic Type Information:**
```zig
fn analyzeType(comptime T: type) void {
    const type_info = @typeInfo(T);
    
    std.debug.print("Type: {s}\n", .{@typeName(T)});
    std.debug.print("Size: {} bytes\n", .{@sizeOf(T)});
    std.debug.print("Alignment: {} bytes\n", .{@alignOf(T)});
    
    switch (type_info) {
        .Int => |int_info| {
            std.debug.print("Integer: {} bits, signed: {}\n", .{ int_info.bits, int_info.signedness == .signed });
        },
        .Float => |float_info| {
            std.debug.print("Float: {} bits\n", .{float_info.bits});
        },
        .Struct => |struct_info| {
            std.debug.print("Struct with {} fields\n", .{struct_info.fields.len});
            inline for (struct_info.fields) |field| {
                std.debug.print("  Field: {s} : {s}\n", .{ field.name, @typeName(field.type) });
            }
        },
        .Array => |array_info| {
            std.debug.print("Array: [{}]{s}\n", .{ array_info.len, @typeName(array_info.child) });
        },
        else => {
            std.debug.print("Other type category\n", .{});
        },
    }
}
```

**Struct Field Manipulation:**
```zig
fn hasField(comptime T: type, comptime field_name: []const u8) bool {
    const fields = std.meta.fields(T);
    inline for (fields) |field| {
        if (std.mem.eql(u8, field.name, field_name)) {
            return true;
        }
    }
    return false;
}

fn getFieldType(comptime T: type, comptime field_name: []const u8) ?type {
    const fields = std.meta.fields(T);
    inline for (fields) |field| {
        if (std.mem.eql(u8, field.name, field_name)) {
            return field.type;
        }
    }
    return null;
}

fn setFieldValue(instance: anytype, comptime field_name: []const u8, value: anytype) void {
    const T = @TypeOf(instance);
    if (hasField(T, field_name)) {
        @field(instance, field_name) = value;
    }
}

// Usage
const Point = struct { x: f32, y: f32, z: f32 };

const has_x = hasField(Point, "x");           // true
const has_w = hasField(Point, "w");           // false
const x_type = getFieldType(Point, "x");      // f32

var point = Point{ .x = 0, .y = 0, .z = 0 };
setFieldValue(&point, "x", 3.14);
```

**Enum Reflection:**
```zig
fn enumToString(value: anytype) []const u8 {
    const T = @TypeOf(value);
    const type_info = @typeInfo(T);
    
    if (type_info != .Enum) {
        @compileError("Expected enum type");
    }
    
    inline for (type_info.Enum.fields) |field| {
        if (@intFromEnum(value) == field.value) {
            return field.name;
        }
    }
    
    return "unknown";
}

fn stringToEnum(comptime T: type, str: []const u8) ?T {
    const type_info = @typeInfo(T);
    
    if (type_info != .Enum) {
        @compileError("Expected enum type");
    }
    
    inline for (type_info.Enum.fields) |field| {
        if (std.mem.eql(u8, field.name, str)) {
            return @enumFromInt(field.value);
        }
    }
    
    return null;
}

const Status = enum { pending, processing, completed, failed };

const status = Status.processing;
const status_name = enumToString(status);      // "processing"
const parsed_status = stringToEnum(Status, "completed"); // Status.completed
```

**Function Reflection:**
```zig
fn analyzeFunctionType(comptime func: anytype) void {
    const T = @TypeOf(func);
    const type_info = @typeInfo(T);
    
    if (type_info != .Fn) {
        @compileError("Expected function type");
    }
    
    const func_info = type_info.Fn;
    
    std.debug.print("Function with {} parameters\n", .{func_info.params.len});
    
    inline for (func_info.params, 0..) |param, i| {
        if (param.type) |param_type| {
            std.debug.print("  Param {}: {s}\n", .{ i, @typeName(param_type) });
        } else {
            std.debug.print("  Param {}: anytype\n", .{i});
        }
    }
    
    if (func_info.return_type) |return_type| {
        std.debug.print("Returns: {s}\n", .{@typeName(return_type)});
    } else {
        std.debug.print("Returns: anytype\n", .{});
    }
}

fn sampleFunction(x: i32, y: f32) bool {
    return x > 0 and y > 0.0;
}

// Analyze function at compile time
const analysis = analyzeFunctionType(sampleFunction);
```

### Generic Programming Patterns

Zig's compile-time programming enables sophisticated generic programming patterns through type parameters and compile-time logic.

**Generic Data Structures:**
```zig
fn ArrayList(comptime T: type) type {
    return struct {
        const Self = @This();
        
        items: []T,
        capacity: usize,
        allocator: std.mem.Allocator,
        
        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .items = &[_]T{},
                .capacity = 0,
                .allocator = allocator,
            };
        }
        
        pub fn deinit(self: Self) void {
            if (self.capacity > 0) {
                self.allocator.free(self.items.ptr[0..self.capacity]);
            }
        }
        
        pub fn append(self: *Self, item: T) !void {
            if (self.items.len >= self.capacity) {
                try self.grow();
            }
            
            self.items.ptr[self.items.len] = item;
            self.items.len += 1;
        }
        
        fn grow(self: *Self) !void {
            const new_capacity = if (self.capacity == 0) 4 else self.capacity * 2;
            const new_memory = try self.allocator.alloc(T, new_capacity);
            
            if (self.items.len > 0) {
                @memcpy(new_memory[0..self.items.len], self.items);
            }
            
            if (self.capacity > 0) {
                self.allocator.free(self.items.ptr[0..self.capacity]);
            }
            
            self.items.ptr = new_memory.ptr;
            self.capacity = new_capacity;
        }
    };
}

// Usage with different types
var int_list = ArrayList(i32).init(allocator);
var string_list = ArrayList([]const u

try int_list.append(42);
try string_list.append("Hello");
```

**Conditional Generic Compilation:**
```zig
fn SmartPointer(comptime T: type, comptime thread_safe: bool) type {
    return struct {
        const Self = @This();
        
        data: *T,
        ref_count: if (thread_safe) std.atomic.Atomic(usize) else usize,
        allocator: std.mem.Allocator,
        
        pub fn init(allocator: std.mem.Allocator, value: T) !Self {
            const data = try allocator.create(T);
            data.* = value;
            
            return Self{
                .data = data,
                .ref_count = if (thread_safe) 
                    std.atomic.Atomic(usize).init(1) 
                else 
                    1,
                .allocator = allocator,
            };
        }
        
        pub fn retain(self: *Self) void {
            if (thread_safe) {
                _ = self.ref_count.fetchAdd(1, .SeqCst);
            } else {
                self.ref_count += 1;
            }
        }
        
        pub fn release(self: *Self) void {
            const old_count = if (thread_safe)
                self.ref_count.fetchSub(1, .SeqCst)
            else blk: {
                const count = self.ref_count;
                self.ref_count -= 1;
                break :blk count;
            };
            
            if (old_count == 1) {
                self.allocator.destroy(self.data);
            }
        }
    };
}

// Different instantiations based on thread safety needs
const ThreadSafeIntPtr = SmartPointer(i32, true);
const SingleThreadIntPtr = SmartPointer(i32, false);
```

**Constraint-Based Generics:**
```zig
fn requiresNumericType(comptime T: type) void {
    const type_info = @typeInfo(T);
    switch (type_info) {
        .Int, .Float, .ComptimeInt, .ComptimeFloat => {},
        else => @compileError("Type must be numeric, got " ++ @typeName(T)),
    }
}

fn Calculator(comptime T: type) type {
    comptime requiresNumericType(T);
    
    return struct {
        const Self = @This();
        
        pub fn add(a: T, b: T) T {
            return a + b;
        }
        
        pub fn multiply(a: T, b: T) T {
            return a * b;
        }
        
        pub fn power(base: T, exp: u32) T {
            if (exp == 0) return 1;
            
            var result = base;
            var i: u32 = 1;
            while (i < exp) : (i += 1) {
                result *= base;
            }
            return result;
        }
        
        // Only available for integer types
        pub fn gcd(a: T, b: T) T {
            comptime if (@typeInfo(T) != .Int) {
                @compileError("GCD only available for integer types");
            };
            
            var x = if (a < 0) -a else a;
            var y = if (b < 0) -b else b;
            
            while (y != 0) {
                const temp = y;
                y = x % y;
                x = temp;
            }
            
            return x;
        }
    };
}

// Usage
const IntCalc = Calculator(i32);
const FloatCalc = Calculator(f64);

const sum = IntCalc.add(5, 3);
const product = FloatCalc.multiply(2.5, 4.0);
const gcd_result = IntCalc.gcd(48, 18);
// const bad_gcd = FloatCalc.gcd(2.5, 1.5); // Compile error
```

**Interface-Like Patterns:**
```zig
fn Drawable(comptime T: type) type {
    // Compile-time interface checking
    comptime {
        if (!std.meta.hasMethod(T, "draw")) {
            @compileError("Type " ++ @typeName(T) ++ " must implement draw() method");
        }
        if (!std.meta.hasMethod(T, "getBounds")) {
            @compileError("Type " ++ @typeName(T) ++ " must implement getBounds() method");
        }
    }
    
    return struct {
        const Self = @This();
        
        instance: T,
        
        pub fn init(instance: T) Self {
            return Self{ .instance = instance };
        }
        
        pub fn render(self: Self) void {
            const bounds = self.instance.getBounds();
            std.debug.print("Rendering at bounds: {any}\n", .{bounds});
            self.instance.draw();
        }
    };
}

const Rectangle = struct {
    x: f32,
    y: f32,
    width: f32,
    height: f32,
    
    pub fn draw(self: Rectangle) void {
        std.debug.print("Drawing rectangle at ({}, {})\n", .{ self.x, self.y });
    }
    
    pub fn getBounds(self: Rectangle) struct { x: f32, y: f32, w: f32, h: f32 } {
        return .{ .x = self.x, .y = self.y, .w = self.width, .h = self.height };
    }
};

// Usage
const rect = Rectangle{ .x = 0, .y = 0, .width = 100, .height = 50 };
const drawable = Drawable(Rectangle).init(rect);
drawable.render();
```

### Metaprogramming Techniques

Advanced metaprogramming in Zig enables code generation, automatic serialization, and sophisticated compile-time transformations.

**Automatic Serialization Generation:**
```zig
fn JsonSerializable(comptime T: type) type {
    return struct {
        const Self = @This();
        
        pub fn toJson(instance: T, allocator: std.mem.Allocator) ![]u8 {
            var json = std.ArrayList(u8).init(allocator);
            try json.append('{');
            
            const fields = std.meta.fields(T);
            inline for (fields, 0..) |field, i| {
                if (i > 0) try json.appendSlice(", ");
                
                // Add field name
                try json.append('"');
                try json.appendSlice(field.name);
                try json.appendSlice("\": ");
                
                // Add field value based on type
                const field_value = @field(instance, field.name);
                try Self.serializeValue(&json, field_value);
            }
            
            try json.append('}');
            return json.toOwnedSlice();
        }
        
        fn serializeValue(json: *std.ArrayList(u8), value: anytype) !void {
            const ValueType = @TypeOf(value);
            const type_info = @typeInfo(ValueType);
            
            switch (type_info) {
                .Int, .ComptimeInt => {
                    const str = try std.fmt.allocPrint(json.allocator, "{}", .{value});
                    defer json.allocator.free(str);
                    try json.appendSlice(str);
                },
                .Float, .ComptimeFloat => {
                    const str = try std.fmt.allocPrint(json.allocator, "{d}", .{value});
                    defer json.allocator.free(str);
                    try json.appendSlice(str);
                },
                .Bool => {
                    try json.appendSlice(if (value) "true" else "false");
                },
                .Pointer => |ptr_info| {
                    if (ptr_info.size == .Slice and ptr_info.child == u8) {
                        // String
                        try json.append('"');
                        try json.appendSlice(value);
                        try json.append('"');
                    }
                },
                else => {
                    try json.appendSlice("null");
                },
            }
        }
        
        pub fn fromJson(json_str: []const u8, allocator: std.mem.Allocator) !T {
            // [Unverified] Implementation would require JSON parsing
            _ = json_str;
            _ = allocator;
            @compileError("JSON deserialization not implemented in this example");
        }
    };
}

const User = struct {
    id: u32,
    name: []const u8,
    active: bool,
    score: f64,
};

// Usage
const user = User{
    .id = 123,
    .name = "Alice",
    .active = true,
    .score = 95.5,
};

const UserJson = JsonSerializable(User);
const json_string = try UserJson.toJson(user, allocator);
```

**Compile-time Code Generation:**
```zig
fn generateAccessors(comptime T: type) type {
    const fields = std.meta.fields(T);
    
    // Generate getter and setter functions for each field
    var declarations: [fields.len * 2]std.builtin.Type.Declaration = undefined;
    
    inline for (fields, 0..) |field, i| {
        const getter_name = "get" ++ capitalize(field.name);
        const setter_name = "set" ++ capitalize(field.name);
        
        // [Inference] This demonstrates the concept, though actual implementation
        // would require more complex type construction
        _ = getter_name;
        _ = setter_name;
        _ = declarations;
    }
    
    return struct {
        const Self = @This();
        
        // Generate getters
        inline for (fields) |field| {
            // Dynamic function generation would go here
            _ = field;
        }
    };
}

// Simpler approach using comptime function generation
fn PropertyAccessor(comptime T: type) type {
    return struct {
        const Self = @This();
        
        pub fn getProperty(instance: T, comptime field_name: []const u8) @TypeOf(@field(instance, field_name)) {
            return @field(instance, field_name);
        }
        
        pub fn setProperty(instance: *T, comptime field_name: []const u8, value: anytype) void {
            @field(instance, field_name) = value;
        }
        
        pub fn hasProperty(comptime field_name: []const u8) bool {
            const fields = std.meta.fields(T);
            inline for (fields) |field| {
                if (std.mem.eql(u8, field.name, field_name)) {
                    return true;
                }
            }
            return false;
        }
    };
}
```

**Template-like Code Generation:**
```zig
fn generateEventSystem(comptime EventTypes: type) type {
    const event_fields = std.meta.fields(EventTypes);
    
    return struct {
        const Self = @This();
        const HandlerFn = fn (data: anytype) void;
        
        // Generate handler storage for each event type
        const handlers = comptime blk: {
            var handler_struct_fields: [event_fields.len]std.builtin.Type.StructField = undefined;
            
            inline for (event_fields, 0..) |field, i| {
                handler_struct_fields[i] = std.builtin.Type.StructField{
                    .name = field.name ++ "_handlers",
                    .type = std.ArrayList(HandlerFn),
                    .default_value = null,
                    .is_comptime = false,
                    .alignment = @alignOf(std.ArrayList(HandlerFn)),
                };
            }
            
            break :blk @Type(std.builtin.Type{
                .Struct = std.builtin.Type.Struct{
                    .layout = .Auto,
                    .fields = &handler_struct_fields,
                    .decls = &[_]std.builtin.Type.Declaration{},
                    .is_tuple = false,
                },
            });
        };
        
        handler_storage: handlers,
        allocator: std.mem.Allocator,
        
        pub fn init(allocator: std.mem.Allocator) Self {
            var self = Self{
                .handler_storage = undefined,
                .allocator = allocator,
            };
            
            // Initialize handler arrays
            inline for (event_fields) |field| {
                const handler_field_name = field.name ++ "_handlers";
                @field(self.handler_storage, handler_field_name) = std.ArrayList(HandlerFn).init(allocator);
            }
            
            return self;
        }
        
        pub fn subscribe(self: *Self, comptime event_name: []const u8, handler: HandlerFn) !void {
            const handler_field_name = event_name ++ "_handlers";
            
            comptime if (!@hasField(handlers, handler_field_name)) {
                @compileError("Unknown event type: " ++ event_name);
            };
            
            try @field(self.handler_storage, handler_field_name).append(handler);
        }
        
        pub fn emit(self: Self, comptime event_name: []const u8, data: anytype) void {
            const handler_field_name = event_name ++ "_handlers";
            const event_handlers = @field(self.handler_storage, handler_field_name);
            
            for (event_handlers.items) |handler| {
                handler(data);
            }
        }
    };
}

// Define event types
const MyEventTypes = enum {
    user_login,
    user_logout,
    data_updated,
};

// Generate event system
const EventSystem = generateEventSystem(MyEventTypes);
```

**Key Points:**
- `comptime` enables zero-cost abstractions through compile-time computation
- Functions can execute entirely at compile time when inputs are comptime-known
- Type reflection provides comprehensive introspection capabilities for generic programming
- Generic patterns support conditional compilation and constraint checking
- Metaprogramming techniques enable automatic code generation and advanced abstractions
- All compile-time programming is statically verified and produces optimized runtime code

---

