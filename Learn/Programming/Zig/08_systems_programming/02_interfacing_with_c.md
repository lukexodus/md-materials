## Interfacing with C


### C ABI Compatibility

Zig provides seamless C Application Binary Interface (ABI) compatibility, allowing direct interoperation with C code without wrapper layers or binding generators. The language maintains C calling conventions, data layout compatibility, and memory models.

**Key Points:**

- Zig types map directly to C equivalents (i32 → int, f64 → double, etc.)
- Struct layouts match C memory representation by default
- Function signatures preserve C calling conventions
- No runtime overhead for C interoperability

Zig's `extern` keyword designates C-compatible functions and variables. The `export` keyword makes Zig functions callable from C code with proper name mangling and ABI compliance.

**Examples:**

```zig
// C-compatible function declaration
extern fn malloc(size: usize) ?*anyopaque;
extern fn free(ptr: ?*anyopaque) void;

// Export Zig function to C
export fn zigFunction(x: c_int) c_int {
    return x * 2;
}
```

### Header File Translation

Zig includes `zig translate-c` for automatic C header translation, converting C declarations into equivalent Zig code. This tool handles preprocessor macros, function declarations, struct definitions, and type aliases.

**Translation Process:**

- Preprocessor directives become compile-time constructs
- C macros translate to Zig comptime expressions
- Function pointers map to Zig function types
- Unions and bitfields preserve memory layout

**Examples:**

```bash
# Translate C header to Zig
zig translate-c input.h > output.zig

# Include translated headers
const c = @cImport({
    @cInclude("stdio.h");
    @cInclude("stdlib.h");
});
```

The `@cImport` builtin provides direct header inclusion with automatic translation during compilation, eliminating separate translation steps for simple use cases.

### Calling C Functions

C function invocation in Zig requires proper type declarations and memory management awareness. Zig's type system enforces null safety and error handling while maintaining C compatibility.

**Function Declaration Patterns:**

```zig
// Basic C function binding
extern fn strlen(s: [*:0]const u8) usize;

// C function returning pointer
extern fn getenv(name: [*:0]const u8) ?[*:0]u8;

// C function with complex parameters
extern fn qsort(
    base: *anyopaque,
    nmemb: usize,
    size: usize,
    compar: *const fn (*const anyopaque, *const anyopaque) callconv(.C) c_int,
) void;
```

**Memory Management Considerations:**

- C functions may return null pointers (use optional types)
- Manual memory allocation/deallocation required
- Buffer ownership semantics must be tracked
- String handling requires null-terminated conventions

**Examples:**

```zig
const std = @import("std");

// Safe C string handling
fn safeCStringLength(str: ?[*:0]const u8) usize {
    return if (str) |s| strlen(s) else 0;
}

// Error handling with C functions
fn allocateMemory(size: usize) ![]u8 {
    const ptr = malloc(size) orelse return error.OutOfMemory;
    return @as([*]u8, @ptrCast(ptr))[0..size];
}
```

### Callback Mechanisms

Zig supports C callback patterns through function pointers with explicit calling conventions. The `callconv(.C)` annotation ensures proper ABI compliance for callback functions.

**Callback Function Types:**

```zig
// Define C-compatible callback type
const CallbackFn = *const fn (data: *anyopaque) callconv(.C) void;

// Register callback with C library
extern fn registerCallback(callback: CallbackFn, userdata: *anyopaque) void;

// Implement callback function
fn myCallback(data: *anyopaque) callconv(.C) void {
    const ctx = @as(*MyContext, @ptrCast(@alignCast(data)));
    // Process callback data
}
```

**Event-Driven Integration:** Callbacks enable event-driven programming with C libraries, supporting GUI frameworks, network libraries, and system APIs.

**Examples:**

```zig
// Signal handling callback
const SignalHandler = *const fn (signal: c_int) callconv(.C) void;
extern fn signal(sig: c_int, handler: SignalHandler) SignalHandler;

fn signalHandler(sig: c_int) callconv(.C) void {
    std.log.info("Received signal: {}", .{sig});
}

// Thread callback for pthread
const ThreadFn = *const fn (*anyopaque) callconv(.C) ?*anyopaque;
extern fn pthread_create(
    thread: *pthread_t,
    attr: ?*const pthread_attr_t,
    start_routine: ThreadFn,
    arg: ?*anyopaque,
) c_int;
```

### Library Linking Strategies

Zig provides multiple approaches for linking C libraries: static linking, dynamic linking, and system library integration. The build system supports cross-platform library management and dependency resolution.

**Static Linking:** Static linking embeds library code directly into the executable, creating self-contained binaries without runtime dependencies.

```zig
// build.zig configuration
const exe = b.addExecutable(.{
    .name = "myapp",
    .root_source_file = .{ .path = "src/main.zig" },
});

// Link static library
exe.linkLibC();
exe.addLibraryPath(.{ .path = "/usr/local/lib" });
exe.linkSystemLibrary("mystaticlib");
```

**Dynamic Linking:** Dynamic linking connects to shared libraries at runtime, reducing executable size and enabling library updates without recompilation.

```zig
// Dynamic library linking
exe.linkLibC();
exe.linkSystemLibrary("pthread");
exe.linkSystemLibrary("m"); // math library

// Platform-specific linking
if (target.os.tag == .windows) {
    exe.linkSystemLibrary("kernel32");
    exe.linkSystemLibrary("user32");
}
```

**Cross-Platform Considerations:**

- Library naming conventions vary by platform (lib*.a vs *.lib)
- Search paths differ across operating systems
- ABI compatibility requirements for different architectures

**Build System Integration:**

```zig
// Complex library configuration
pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "app",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    // Conditional library linking
    if (b.option(bool, "use_ssl", "Enable SSL support")) |use_ssl| {
        if (use_ssl) {
            exe.linkSystemLibrary("ssl");
            exe.linkSystemLibrary("crypto");
        }
    }

    // Custom library paths
    exe.addLibraryPath(.{ .path = "libs" });
    exe.addIncludePath(.{ .path = "include" });
}
```

**Package Manager Integration:** [Inference] Zig's package manager can handle C library dependencies through build scripts and manifest files, though the exact implementation details depend on the specific version and configuration.

**Troubleshooting Common Issues:**

- Symbol resolution failures require proper library order
- ABI mismatches cause runtime crashes or undefined behavior
- Missing dependencies need explicit linking or installation
- Version conflicts require careful library management

Important related topics include Zig's build system architecture, cross-compilation capabilities, and memory safety patterns when interfacing with unsafe C code.

---

