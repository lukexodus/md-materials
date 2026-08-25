## Generic Types and Functions


Zig's generics system provides compile-time polymorphism through type parameters, enabling code reuse while maintaining zero-runtime cost. The system is based on compile-time evaluation and type inference, making it both powerful and efficient.

### Generic Function Parameters

Generic functions in Zig use the `anytype` keyword or explicit type parameters to accept arguments of multiple types. The compiler generates specialized versions for each unique combination of types used.

**Key points:**

- `anytype` allows functions to accept any type as a parameter
- Type inference occurs at compile time
- Each unique type combination creates a separate function instantiation
- Generic parameters can be constrained using compile-time checks

**Example:**

```zig
fn add(comptime T: type, a: T, b: T) T {
    return a + b;
}

fn addAny(a: anytype, b: @TypeOf(a)) @TypeOf(a) {
    return a + b;
}

// Usage
const result1 = add(i32, 5, 3);
const result2 = add(f64, 2.5, 1.7);
const result3 = addAny(10, 20);
```

### Type Parameters

Type parameters in Zig are compile-time parameters that allow functions and types to operate on different types. They must be marked with the `comptime` keyword when declared as parameters.

**Key points:**

- Type parameters must be `comptime` known
- Can be used in function signatures, return types, and function bodies
- Support both explicit type passing and type inference
- Enable generic data structures and algorithms

**Example:**

```zig
fn createArray(comptime T: type, comptime size: usize) [size]T {
    var arr: [size]T = undefined;
    for (arr, 0..) |*elem, i| {
        elem.* = @as(T, @intCast(i));
    }
    return arr;
}

fn getMaxValue(comptime T: type) T {
    return switch (@typeInfo(T)) {
        .Int => |int_info| if (int_info.signedness == .signed) 
            std.math.maxInt(T) else std.math.maxInt(T),
        .Float => std.math.inf(T),
        else => @compileError("Unsupported type"),
    };
}
```

### Constraint Specification

Zig provides compile-time type introspection and conditional compilation to implement type constraints. Unlike some languages, Zig doesn't have a formal trait system but uses compile-time evaluation for type checking.

**Key points:**

- Use `@typeInfo()` for type introspection
- `@hasField()` and `@hasDecl()` check for struct members
- `@compileError()` provides compile-time error messages
- Switch statements on type information enable type-based logic

**Example:**

```zig
fn requiresNumeric(comptime T: type) void {
    switch (@typeInfo(T)) {
        .Int, .Float, .ComptimeInt, .ComptimeFloat => {},
        else => @compileError("Type must be numeric"),
    }
}

fn requiresIterable(comptime T: type) void {
    if (!@hasField(T, "len")) {
        @compileError("Type must have 'len' field");
    }
}

fn processNumeric(comptime T: type, value: T) T {
    requiresNumeric(T);
    return value * 2;
}
```

### Generic Struct Definitions

Generic structs in Zig use type parameters to create reusable data structures. The struct definition itself is a compile-time function that returns a type.

**Key points:**

- Generic structs are functions that return types
- Must be called with `comptime` type parameters
- Can include both type and value parameters
- Support method definitions within the generic type

**Example:**

```zig
fn List(comptime T: type) type {
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
        
        pub fn append(self: *Self, item: T) !void {
            // Implementation for appending items
            _ = self;
            _ = item;
        }
        
        pub fn get(self: Self, index: usize) ?T {
            if (index >= self.items.len) return null;
            return self.items[index];
        }
    };
}

// Generic struct with multiple parameters
fn Matrix(comptime T: type, comptime rows: usize, comptime cols: usize) type {
    return struct {
        data: [rows][cols]T,
        
        pub fn init() @This() {
            return @This(){
                .data = std.mem.zeroes([rows][cols]T),
            };
        }
        
        pub fn set(self: *@This(), row: usize, col: usize, value: T) void {
            self.data[row][col] = value;
        }
        
        pub fn get(self: @This(), row: usize, col: usize) T {
            return self.data[row][col];
        }
    };
}
```

### Template Instantiation

Template instantiation in Zig occurs at compile time when generic functions or types are used with specific type arguments. Each unique combination creates a separate instantiation.

**Key points:**

- Instantiation happens automatically when generics are used
- Each unique type combination creates separate compiled code
- Unused instantiations are not compiled (dead code elimination)
- Instantiation errors occur at compile time

**Example:**

```zig
const std = @import("std");

// Generic function
fn swap(comptime T: type, a: *T, b: *T) void {
    const temp = a.*;
    a.* = b.*;
    b.* = temp;
}

// Generic type instantiation
const IntList = List(i32);
const FloatList = List(f64);
const StringMatrix = Matrix([]const u8, 3, 3);

pub fn main() !void {
    var allocator = std.heap.page_allocator;
    
    // Function instantiation
    var x: i32 = 5;
    var y: i32 = 10;
    swap(i32, &x, &y);
    
    var a: f64 = 1.5;
    var b: f64 = 2.5;
    swap(f64, &a, &b);
    
    // Type instantiation
    var int_list = IntList.init(allocator);
    var float_list = FloatList.init(allocator);
    var matrix = StringMatrix.init();
    
    _ = int_list;
    _ = float_list;
    _ = matrix;
}
```

**Advanced instantiation patterns:**

```zig
// Conditional instantiation based on type properties
fn OptimizedSort(comptime T: type) type {
    return struct {
        pub fn sort(items: []T) void {
            const type_info = @typeInfo(T);
            switch (type_info) {
                .Int => |int_info| {
                    if (int_info.bits <= 32) {
                        // Use counting sort for small integers
                        countingSort(items);
                    } else {
                        // Use quicksort for larger integers
                        quickSort(items);
                    }
                },
                else => {
                    // Use generic comparison sort
                    comparisonSort(items);
                }
            }
        }
        
        fn countingSort(items: []T) void { /* Implementation */ _ = items; }
        fn quickSort(items: []T) void { /* Implementation */ _ = items; }
        fn comparisonSort(items: []T) void { /* Implementation */ _ = items; }
    };
}
```

**Output:** [Inference] The compile-time nature of Zig's generics system enables zero-runtime cost abstractions while providing powerful polymorphism capabilities through type parameters and compile-time evaluation.

**Conclusion:** Zig's generic system balances simplicity with power, using compile-time evaluation to provide type safety and performance without runtime overhead, making it suitable for systems programming where both abstraction and efficiency are critical.

---

