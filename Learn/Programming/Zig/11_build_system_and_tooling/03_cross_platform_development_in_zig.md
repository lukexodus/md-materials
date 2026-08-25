## Cross-platform Development in Zig


### Target Specification

#### Build Target Configuration

Zig provides comprehensive cross-compilation support through its target system:

```zig
// build.zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    // Define multiple targets
    const targets = [_]std.zig.CrossTarget{
        .{ .cpu_arch = .x86_64, .os_tag = .linux },
        .{ .cpu_arch = .x86_64, .os_tag = .windows },
        .{ .cpu_arch = .x86_64, .os_tag = .macos },
        .{ .cpu_arch = .aarch64, .os_tag = .linux },
        .{ .cpu_arch = .aarch64, .os_tag = .macos },
        .{ .cpu_arch = .wasm32, .os_tag = .freestanding },
    };
    
    const optimize = b.standardOptimizeOption(.{});
    
    for (targets) |target| {
        const exe = b.addExecutable(.{
            .name = b.fmt("myapp-{s}-{s}", .{ 
                @tagName(target.cpu_arch.?), 
                @tagName(target.os_tag.?) 
            }),
            .root_source_file = .{ .path = "src/main.zig" },
            .target = b.resolveTargetQuery(target),
            .optimize = optimize,
        });
        
        b.installArtifact(exe);
    }
}
```

#### Runtime Target Detection

```zig
const std = @import("std");
const builtin = @import("builtin");

const PlatformInfo = struct {
    os: std.Target.Os.Tag,
    arch: std.Target.Cpu.Arch,
    endian: std.builtin.Endian,
    pointer_width: u8,
    
    fn current() PlatformInfo {
        return PlatformInfo{
            .os = builtin.os.tag,
            .arch = builtin.cpu.arch,
            .endian = builtin.cpu.arch.endian(),
            .pointer_width = @bitSizeOf(usize),
        };
    }
    
    fn isUnix(self: PlatformInfo) bool {
        return switch (self.os) {
            .linux, .macos, .freebsd, .openbsd, .netbsd => true,
            else => false,
        };
    }
    
    fn supportsThreads(self: PlatformInfo) bool {
        return switch (self.os) {
            .freestanding, .wasi => false,
            else => true,
        };
    }
};

pub fn main() !void {
    const platform = PlatformInfo.current();
    
    std.debug.print("Platform: {s}-{s}\n", .{ 
        @tagName(platform.os), 
        @tagName(platform.arch) 
    });
    std.debug.print("Pointer width: {d} bits\n", .{platform.pointer_width});
    std.debug.print("Endianness: {s}\n", .{@tagName(platform.endian)});
}
```

#### Custom Target Specifications

```zig
// Custom embedded target example
const embedded_target = std.zig.CrossTarget{
    .cpu_arch = .arm,
    .cpu_model = .{ .explicit = &std.Target.arm.cpu.cortex_m4 },
    .os_tag = .freestanding,
    .abi = .eabi,
    .cpu_features_add = std.Target.arm.featureSet(&[_]std.Target.arm.Feature{
        .thumb2,
        .vfp4d16sp,
    }),
};

const wasm_target = std.zig.CrossTarget{
    .cpu_arch = .wasm32,
    .os_tag = .freestanding,
    .cpu_features_add = std.Target.wasm.featureSet(&[_]std.Target.wasm.Feature{
        .bulk_memory,
        .multivalue,
        .sign_ext,
    }),
};
```

### Platform Abstraction Layers

#### File System Abstraction

```zig
const FileSystem = struct {
    const Self = @This();
    
    const PathSeparator = switch (builtin.os.tag) {
        .windows => '\\',
        else => '/',
    };
    
    const PathMax = switch (builtin.os.tag) {
        .windows => 260,
        .linux => 4096,
        .macos => 1024,
        else => 512,
    };
    
    fn joinPath(allocator: std.mem.Allocator, parts: []const []const u8) ![]u8 {
        var result = std.ArrayList(u8).init(allocator);
        
        for (parts, 0..) |part, i| {
            if (i > 0) {
                try result.append(PathSeparator);
            }
            try result.appendSlice(part);
        }
        
        return result.toOwnedSlice();
    }
    
    fn getHomeDirectory(allocator: std.mem.Allocator) ![]const u8 {
        return switch (builtin.os.tag) {
            .windows => std.process.getEnvVarOwned(allocator, "USERPROFILE"),
            else => std.process.getEnvVarOwned(allocator, "HOME"),
        };
    }
    
    fn getConfigDirectory(allocator: std.mem.Allocator) ![]const u8 {
        return switch (builtin.os.tag) {
            .windows => blk: {
                const appdata = try std.process.getEnvVarOwned(allocator, "APPDATA");
                break :blk appdata;
            },
            .macos => blk: {
                const home = try getHomeDirectory(allocator);
                defer allocator.free(home);
                break :blk try joinPath(allocator, &[_][]const u8{ home, "Library", "Application Support" });
            },
            else => blk: {
                if (std.process.getEnvVarOwned(allocator, "XDG_CONFIG_HOME")) |xdg_config| {
                    break :blk xdg_config;
                } else |_| {
                    const home = try getHomeDirectory(allocator);
                    defer allocator.free(home);
                    break :blk try joinPath(allocator, &[_][]const u8{ home, ".config" });
                }
            },
        };
    }
};
```

#### Process Management Abstraction

```zig
const ProcessManager = struct {
    const ProcessId = switch (builtin.os.tag) {
        .windows => std.os.windows.HANDLE,
        else => std.os.pid_t,
    };
    
    fn getCurrentProcessId() ProcessId {
        return switch (builtin.os.tag) {
            .windows => std.os.windows.kernel32.GetCurrentProcess(),
            else => std.os.linux.getpid(),
        };
    }
    
    fn spawn(allocator: std.mem.Allocator, args: []const []const u8) !ProcessId {
        return switch (builtin.os.tag) {
            .windows => spawnWindows(allocator, args),
            else => spawnUnix(allocator, args),
        };
    }
    
    fn spawnWindows(allocator: std.mem.Allocator, args: []const []const u8) !ProcessId {
        // [Inference] Windows-specific process creation
        const cmd_line = try std.mem.join(allocator, " ", args);
        defer allocator.free(cmd_line);
        
        var si = std.mem.zeroes(std.os.windows.STARTUPINFOW);
        var pi = std.mem.zeroes(std.os.windows.PROCESS_INFORMATION);
        
        const cmd_line_w = try std.unicode.utf8ToUtf16LeAllocZ(allocator, cmd_line);
        defer allocator.free(cmd_line_w);
        
        if (std.os.windows.kernel32.CreateProcessW(
            null,
            cmd_line_w,
            null,
            null,
            std.os.windows.FALSE,
            0,
            null,
            null,
            &si,
            &pi,
        ) == std.os.windows.FALSE) {
            return error.ProcessCreationFailed;
        }
        
        _ = std.os.windows.kernel32.CloseHandle(pi.hThread);
        return pi.hProcess;
    }
    
    fn spawnUnix(allocator: std.mem.Allocator, args: []const []const u8) !ProcessId {
        const argv = try allocator.alloc(?[*:0]const u8, args.len + 1);
        defer allocator.free(argv);
        
        for (args, 0..) |arg, i| {
            argv[i] = try allocator.dupeZ(u8, arg);
        }
        argv[args.len] = null;
        
        defer {
            for (argv[0..args.len]) |arg| {
                if (arg) |a| allocator.free(std.mem.span(a));
            }
        }
        
        const pid = try std.os.fork();
        if (pid == 0) {
            // Child process
            const err = std.os.execvpeZ(argv[0].?, argv.ptr, std.c.environ);
            std.process.exit(1);
        }
        
        return pid;
    }
};
```

#### Network Abstraction Layer

```zig
const NetworkLayer = struct {
    const Socket = switch (builtin.os.tag) {
        .windows => std.os.windows.ws2_32.SOCKET,
        else => std.os.fd_t,
    };
    
    const SocketError = error{
        ConnectionFailed,
        BindFailed,
        ListenFailed,
        AcceptFailed,
        SendFailed,
        ReceiveFailed,
    };
    
    fn createTcpSocket() !Socket {
        return switch (builtin.os.tag) {
            .windows => blk: {
                // [Inference] Windows socket initialization
                var wsadata: std.os.windows.ws2_32.WSADATA = undefined;
                if (std.os.windows.ws2_32.WSAStartup(0x0202, &wsadata) != 0) {
                    return SocketError.ConnectionFailed;
                }
                
                const socket = std.os.windows.ws2_32.socket(
                    std.os.windows.ws2_32.AF_INET,
                    std.os.windows.ws2_32.SOCK_STREAM,
                    std.os.windows.ws2_32.IPPROTO_TCP,
                );
                
                if (socket == std.os.windows.ws2_32.INVALID_SOCKET) {
                    return SocketError.ConnectionFailed;
                }
                
                break :blk socket;
            },
            else => std.os.socket(std.os.AF.INET, std.os.SOCK.STREAM, 0),
        };
    }
    
    fn closeSocket(socket: Socket) void {
        switch (builtin.os.tag) {
            .windows => {
                _ = std.os.windows.ws2_32.closesocket(socket);
                _ = std.os.windows.ws2_32.WSACleanup();
            },
            else => std.os.close(socket),
        }
    }
};
```

### Conditional Compilation

#### Compile-Time Platform Detection

```zig
const std = @import("std");
const builtin = @import("builtin");

// Platform-specific constants
const max_path_len = switch (builtin.os.tag) {
    .windows => 260,
    .linux => 4096,
    .macos => 1024,
    else => 512,
};

const line_ending = switch (builtin.os.tag) {
    .windows => "\r\n",
    else => "\n",
};

// Platform-specific types
const FileHandle = switch (builtin.os.tag) {
    .windows => std.os.windows.HANDLE,
    else => std.os.fd_t,
};

// Conditional function compilation
fn platformSpecificInit() !void {
    switch (builtin.os.tag) {
        .windows => {
            // Windows-specific initialization
            try initializeWindowsSubsystems();
        },
        .linux => {
            // Linux-specific initialization
            try setupLinuxEnvironment();
        },
        .macos => {
            // macOS-specific initialization
            try configureMacOSSettings();
        },
        else => {
            // Generic fallback
            std.log.warn("Using generic initialization for platform: {s}", .{@tagName(builtin.os.tag)});
        },
    }
}
```

#### Feature-Based Compilation

```zig
const has_threads = switch (builtin.os.tag) {
    .freestanding, .wasi => false,
    else => true,
};

const has_filesystem = switch (builtin.os.tag) {
    .freestanding => false,
    .wasi => true, // WASI has limited filesystem support
    else => true,
};

const supports_networking = switch (builtin.os.tag) {
    .freestanding => false,
    else => true,
};

// Conditional API availability
const ThreadPool = if (has_threads) struct {
    threads: []std.Thread,
    work_queue: std.fifo.LinearFifo(WorkItem, .Dynamic),
    
    fn init(allocator: std.mem.Allocator, thread_count: u32) !ThreadPool {
        return ThreadPool{
            .threads = try allocator.alloc(std.Thread, thread_count),
            .work_queue = std.fifo.LinearFifo(WorkItem, .Dynamic).init(allocator),
        };
    }
    
    fn submitWork(self: *ThreadPool, work: WorkItem) !void {
        try self.work_queue.writeItem(work);
    }
} else struct {
    // Single-threaded fallback
    fn init(allocator: std.mem.Allocator, thread_count: u32) !ThreadPool {
        _ = allocator;
        _ = thread_count;
        return ThreadPool{};
    }
    
    fn submitWork(self: *ThreadPool, work: WorkItem) !void {
        _ = self;
        // Execute work immediately on single thread
        work.execute();
    }
};
```

#### Preprocessor-Style Compilation

```zig
// Configuration through comptime
const config = struct {
    const enable_logging = switch (builtin.mode) {
        .Debug => true,
        .ReleaseSafe => true,
        .ReleaseFast, .ReleaseSmall => false,
    };
    
    const buffer_size = switch (builtin.os.tag) {
        .windows => 8192,
        .linux => 16384,
        else => 4096,
    };
    
    const use_simd = switch (builtin.cpu.arch) {
        .x86_64 => builtin.cpu.features.isEnabled(@intFromEnum(std.Target.x86.Feature.avx2)),
        .aarch64 => builtin.cpu.features.isEnabled(@intFromEnum(std.Target.aarch64.Feature.neon)),
        else => false,
    };
};

fn log(comptime fmt: []const u8, args: anytype) void {
    if (config.enable_logging) {
        std.debug.print(fmt, args);
    }
}

fn processBuffer(data: []u8) void {
    if (config.use_simd) {
        processBufferSIMD(data);
    } else {
        processBufferScalar(data);
    }
}
```

### Architecture-Specific Optimizations

#### SIMD Operations

```zig
const std = @import("std");
const builtin = @import("builtin");

fn vectorAdd(a: []const f32, b: []const f32, result: []f32) void {
    std.debug.assert(a.len == b.len and b.len == result.len);
    
    switch (builtin.cpu.arch) {
        .x86_64 => {
            if (builtin.cpu.features.isEnabled(@intFromEnum(std.Target.x86.Feature.avx2))) {
                vectorAddAVX2(a, b, result);
            } else if (builtin.cpu.features.isEnabled(@intFromEnum(std.Target.x86.Feature.sse2))) {
                vectorAddSSE2(a, b, result);
            } else {
                vectorAddScalar(a, b, result);
            }
        },
        .aarch64 => {
            if (builtin.cpu.features.isEnabled(@intFromEnum(std.Target.aarch64.Feature.neon))) {
                vectorAddNEON(a, b, result);
            } else {
                vectorAddScalar(a, b, result);
            }
        },
        else => vectorAddScalar(a, b, result),
    }
}

fn vectorAddAVX2(a: []const f32, b: []const f32, result: []f32) void {
    // [Inference] AVX2-specific implementation would use intrinsics
    const vector_len = 8; // AVX2 processes 8 f32s at once
    var i: usize = 0;
    
    while (i + vector_len <= a.len) : (i += vector_len) {
        // AVX2 vector operations would go here
        // Using scalar fallback for demonstration
        for (0..vector_len) |j| {
            result[i + j] = a[i + j] + b[i + j];
        }
    }
    
    // Handle remaining elements
    while (i < a.len) : (i += 1) {
        result[i] = a[i] + b[i];
    }
}

fn vectorAddScalar(a: []const f32, b: []const f32, result: []f32) void {
    for (a, b, result) |av, bv, *rv| {
        rv.* = av + bv;
    }
}
```

#### Memory Alignment Optimizations

```zig
const MemoryManager = struct {
    const cache_line_size = switch (builtin.cpu.arch) {
        .x86_64, .aarch64 => 64,
        .arm => 32,
        else => 64, // Conservative default
    };
    
    fn alignedAlloc(allocator: std.mem.Allocator, comptime T: type, count: usize) ![]align(cache_line_size) T {
        const slice = try allocator.alignedAlloc(T, cache_line_size, count);
        return @as([]align(cache_line_size) T, @alignCast(slice));
    }
    
    // Cache-friendly data structure
    const CacheFriendlyArray = struct {
        data: []align(cache_line_size) f32,
        allocator: std.mem.Allocator,
        
        fn init(allocator: std.mem.Allocator, size: usize) !CacheFriendlyArray {
            const aligned_size = std.mem.alignForward(usize, size * @sizeOf(f32), cache_line_size);
            const element_count = aligned_size / @sizeOf(f32);
            
            return CacheFriendlyArray{
                .data = try alignedAlloc(allocator, f32, element_count),
                .allocator = allocator,
            };
        }
        
        fn deinit(self: *CacheFriendlyArray) void {
            self.allocator.free(self.data);
        }
    };
};
```

#### CPU-Specific Code Paths

```zig
const CpuOptimizations = struct {
    fn fastMemcpy(dest: []u8, src: []const u8) void {
        std.debug.assert(dest.len >= src.len);
        
        switch (builtin.cpu.arch) {
            .x86_64 => {
                if (builtin.cpu.features.isEnabled(@intFromEnum(std.Target.x86.Feature.avx2))) {
                    fastMemcpyAVX2(dest, src);
                } else if (builtin.cpu.features.isEnabled(@intFromEnum(std.Target.x86.Feature.sse2))) {
                    fastMemcpySSE2(dest, src);
                } else {
                    @memcpy(dest[0..src.len], src);
                }
            },
            .aarch64 => {
                if (src.len >= 64) {
                    fastMemcpyNEON(dest, src);
                } else {
                    @memcpy(dest[0..src.len], src);
                }
            },
            else => @memcpy(dest[0..src.len], src),
        }
    }
    
    fn fastMemcpyAVX2(dest: []u8, src: []const u8) void {
        // [Inference] AVX2-optimized memory copy implementation
        const chunk_size = 32; // AVX2 register size
        var i: usize = 0;
        
        // Process 32-byte chunks
        while (i + chunk_size <= src.len) : (i += chunk_size) {
            // AVX2 load/store operations would go here
            @memcpy(dest[i..i + chunk_size], src[i..i + chunk_size]);
        }
        
        // Handle remaining bytes
        @memcpy(dest[i..i + (src.len - i)], src[i..]);
    }
};
```

### Deployment Strategies

#### Multi-Target Build System

```zig
// build.zig - Production build configuration
const std = @import("std");

const ReleaseTarget = struct {
    name: []const u8,
    target: std.zig.CrossTarget,
    features: ?[]const []const u8 = null,
    strip: bool = true,
    optimize: std.builtin.OptimizeMode = .ReleaseFast,
};

const release_targets = [_]ReleaseTarget{
    .{
        .name = "linux-x86_64",
        .target = .{ .cpu_arch = .x86_64, .os_tag = .linux },
        .features = &[_][]const u8{ "avx2", "fma" },
    },
    .{
        .name = "linux-aarch64",
        .target = .{ .cpu_arch = .aarch64, .os_tag = .linux },
        .features = &[_][]const u8{"neon"},
    },
    .{
        .name = "windows-x86_64",
        .target = .{ .cpu_arch = .x86_64, .os_tag = .windows },
        .features = &[_][]const u8{ "avx2", "fma" },
    },
    .{
        .name = "macos-x86_64",
        .target = .{ .cpu_arch = .x86_64, .os_tag = .macos },
        .features = &[_][]const u8{ "avx2", "fma" },
    },
    .{
        .name = "macos-aarch64",
        .target = .{ .cpu_arch = .aarch64, .os_tag = .macos },
        .features = &[_][]const u8{"neon"},
    },
};

pub fn build(b: *std.Build) void {
    const release_all = b.step("release-all", "Build all release targets");
    
    for (release_targets) |release_target| {
        var target = release_target.target;
        
        // Add CPU features if specified
        if (release_target.features) |features| {
            // [Inference] Feature enabling would be implemented here
        }
        
        const exe = b.addExecutable(.{
            .name = b.fmt("myapp-{s}", .{release_target.name}),
            .root_source_file = .{ .path = "src/main.zig" },
            .target = b.resolveTargetQuery(target),
            .optimize = release_target.optimize,
            .strip = release_target.strip,
        });
        
        // Platform-specific build options
        switch (target.os_tag.?) {
            .windows => {
                exe.linkLibC();
                exe.linkSystemLibrary("ws2_32");
                exe.linkSystemLibrary("kernel32");
            },
            .linux => {
                exe.linkLibC();
                exe.linkSystemLibrary("pthread");
            },
            .macos => {
                exe.linkLibC();
                exe.linkFramework("Foundation");
            },
            else => {},
        }
        
        const install_exe = b.addInstallArtifact(exe, .{
            .dest_dir = .{ .override = .{ .custom = release_target.name } },
        });
        
        release_all.dependOn(&install_exe.step);
    }
}
```

#### Container-Based Deployment

```dockerfile
# Multi-stage Dockerfile for cross-platform builds
FROM zigtools/zig:0.11.0 as builder

WORKDIR /build
COPY . .

# Build for multiple targets
RUN zig build release-all

# Runtime stage - Linux
FROM alpine:latest as linux-runtime
RUN apk --no-cache add ca-certificates
COPY --from=builder /build/zig-out/linux-x86_64/myapp /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/myapp"]

# Windows runtime would use different base image
FROM mcr.microsoft.com/windows/nanoserver:ltsc2022 as windows-runtime
COPY --from=builder /build/zig-out/windows-x86_64/myapp.exe /myapp.exe
ENTRYPOINT ["/myapp.exe"]
```

#### Automated Release Pipeline

```yaml
# GitHub Actions workflow for cross-platform releases
name: Release

on:
  push:
    tags: ['v*']

jobs:
  build-matrix:
    strategy:
      matrix:
        include:
          - os: ubuntu-latest
            target: linux-x86_64
            artifact_name: myapp-linux-x86_64
          - os: ubuntu-latest
            target: linux-aarch64
            artifact_name: myapp-linux-aarch64
          - os: ubuntu-latest
            target: windows-x86_64
            artifact_name: myapp-windows-x86_64.exe
          - os: macos-latest
            target: macos-x86_64
            artifact_name: myapp-macos-x86_64
          - os: macos-latest
            target: macos-aarch64
            artifact_name: myapp-macos-aarch64

    runs-on: ${{ matrix.os }}
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Zig
      uses: goto-bus-stop/setup-zig@v2
      with:
        version: 0.11.0
    
    - name: Build
      run: |
        zig build -Dtarget=${{ matrix.target }} -Doptimize=ReleaseFast
        
    - name: Upload artifacts
      uses: actions/upload-artifact@v3
      with:
        name: ${{ matrix.artifact_name }}
        path: zig-out/bin/
```

**Key Points:**

- Cross-compilation in Zig requires no additional toolchains for most targets
- Platform abstraction should be implemented at compile-time when possible for zero-runtime cost
- Architecture-specific optimizations can provide significant performance improvements [Inference]
- Conditional compilation enables single codebase deployment across multiple platforms
- Build systems should automate multi-target compilation and packaging

**Examples of deployment considerations:**

- Static linking reduces runtime dependencies across platforms
- Feature detection at compile-time eliminates runtime overhead
- Platform-specific optimizations should gracefully fall back to generic implementations
- Container-based deployment can standardize runtime environments

Important related topics: WebAssembly compilation targets, Embedded systems cross-compilation, Dynamic library creation across platforms, Performance profiling across different architectures.

---

