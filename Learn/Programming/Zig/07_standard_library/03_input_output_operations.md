## Input/Output Operations


Zig's I/O system emphasizes explicit error handling, memory safety, and cross-platform compatibility. The standard library provides comprehensive facilities for file operations, networking, and data serialization while maintaining zero-cost abstractions.

### File System Operations

The file system API provides cross-platform access to directories, files, and metadata through the `std.fs` module. All operations use explicit error handling and resource management.

**Key points:**

- Cross-platform file system abstraction through `std.fs`
- Explicit error handling for all file operations
- Directory iteration and manipulation capabilities
- File metadata access (size, permissions, timestamps)
- Atomic file operations and temporary file handling

**Example:**

```zig
const std = @import("std");
const fs = std.fs;
const print = std.debug.print;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // File creation and writing
    const file = try fs.cwd().createFile("example.txt", .{});
    defer file.close();
    
    const content = "Hello, Zig file system!\n";
    try file.writeAll(content);
    
    // File reading
    const read_file = try fs.cwd().openFile("example.txt", .{});
    defer read_file.close();
    
    const file_size = try read_file.getEndPos();
    const contents = try allocator.alloc(u8, file_size);
    defer allocator.free(contents);
    
    _ = try read_file.readAll(contents);
    print("File contents: {s}", .{contents});
    
    // File metadata
    const stat = try read_file.stat();
    print("File size: {} bytes\n", .{stat.size});
    print("File kind: {}\n", .{stat.kind});
}
```

**Directory operations:**

```zig
const std = @import("std");
const fs = std.fs;

pub fn directoryOperations(allocator: std.mem.Allocator) !void {
    // Create directory
    try fs.cwd().makeDir("test_dir");
    defer fs.cwd().deleteDir("test_dir") catch {};
    
    // Directory iteration
    var dir = try fs.cwd().openDir(".", .{ .iterate = true });
    defer dir.close();
    
    var iter = dir.iterate();
    while (try iter.next()) |entry| {
        print("Found: {s} ({})\n", .{ entry.name, entry.kind });
    }
    
    // Path operations
    const path = try fs.path.join(allocator, &[_][]const u8{ "test_dir", "subdir", "file.txt" });
    defer allocator.free(path);
    
    // Check if file exists
    const exists = fs.cwd().access("example.txt", .{}) catch false;
    print("File exists: {}\n", .{exists});
    
    // Copy file
    try fs.cwd().copyFile("source.txt", fs.cwd(), "destination.txt", .{});
}
```

### Stream-based I/O

Zig implements stream-based I/O through reader and writer interfaces that provide uniform access to various data sources and destinations.

**Key points:**

- Generic Reader and Writer interfaces for uniform I/O
- Buffered I/O for performance optimization
- Stream composition and chaining capabilities
- Error propagation through the type system
- Memory-mapped file support for large files

**Example:**

```zig
const std = @import("std");

pub fn streamOperations(allocator: std.mem.Allocator) !void {
    // File streams
    const file = try std.fs.cwd().createFile("stream_test.txt", .{});
    defer file.close();
    
    const writer = file.writer();
    const reader = file.reader();
    
    // Writing to stream
    try writer.print("Line 1: {}\n", .{42});
    try writer.print("Line 2: {s}\n", .{"Hello"});
    try writer.writeAll("Line 3: Direct write\n");
    
    // Reset file position for reading
    try file.seekTo(0);
    
    // Reading from stream
    var buffer: [256]u8 = undefined;
    const bytes_read = try reader.readAll(&buffer);
    std.debug.print("Read {} bytes: {s}", .{ bytes_read, buffer[0..bytes_read] });
    
    // Buffered I/O for performance
    var buffered_writer = std.io.bufferedWriter(writer);
    const buf_writer = buffered_writer.writer();
    
    try buf_writer.writeAll("Buffered content\n");
    try buffered_writer.flush(); // Ensure data is written
}
```

**Stream composition and utilities:**

```zig
const std = @import("std");

// Custom stream wrapper
fn CountingWriter(comptime WriterType: type) type {
    return struct {
        child_writer: WriterType,
        bytes_written: usize,
        
        const Self = @This();
        const Error = WriterType.Error;
        const Writer = std.io.Writer(*Self, Error, write);
        
        pub fn writer(self: *Self) Writer {
            return .{ .context = self };
        }
        
        pub fn write(self: *Self, bytes: []const u8) Error!usize {
            const result = try self.child_writer.write(bytes);
            self.bytes_written += result;
            return result;
        }
    };
}

// Memory streams
pub fn memoryStreams(allocator: std.mem.Allocator) !void {
    // Fixed buffer stream
    var buffer: [1024]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&buffer);
    const writer = fbs.writer();
    const reader = fbs.reader();
    
    try writer.print("Memory stream content: {}\n", .{123});
    
    // Reset for reading
    fbs.reset();
    const content = try reader.readAllAlloc(allocator, 1024);
    defer allocator.free(content);
    
    std.debug.print("Memory stream: {s}", .{content});
}
```

### Network Programming Basics

Zig provides cross-platform networking through the `std.net` module, supporting both TCP and UDP protocols with async/await integration.

**Key points:**

- Cross-platform socket abstraction in `std.net`
- TCP and UDP protocol support
- Address resolution and binding capabilities
- Non-blocking I/O integration [Inference]
- IPv4 and IPv6 support

**Example:**

```zig
const std = @import("std");
const net = std.net;

// TCP Server
pub fn tcpServer() !void {
    const address = try net.Address.parseIp("127.0.0.1", 8080);
    
    const server = try address.listen(.{
        .reuse_address = true,
    });
    defer server.deinit();
    
    std.debug.print("Server listening on {}\n", .{address});
    
    while (true) {
        const connection = try server.accept();
        defer connection.stream.close();
        
        // Handle connection
        try handleClient(connection);
    }
}

fn handleClient(connection: net.Server.Connection) !void {
    const writer = connection.stream.writer();
    const reader = connection.stream.reader();
    
    var buffer: [1024]u8 = undefined;
    const bytes_read = try reader.read(&buffer);
    
    std.debug.print("Received: {s}", .{buffer[0..bytes_read]});
    
    const response = "HTTP/1.1 200 OK\r\nContent-Length: 13\r\n\r\nHello, World!";
    try writer.writeAll(response);
}

// TCP Client
pub fn tcpClient() !void {
    const address = try net.Address.parseIp("127.0.0.1", 8080);
    const stream = try net.tcpConnectToAddress(address);
    defer stream.close();
    
    const writer = stream.writer();
    const reader = stream.reader();
    
    try writer.writeAll("GET / HTTP/1.1\r\nHost: localhost\r\n\r\n");
    
    var buffer: [1024]u8 = undefined;
    const bytes_read = try reader.read(&buffer);
    std.debug.print("Server response: {s}", .{buffer[0..bytes_read]});
}
```

**UDP networking:**

```zig
const std = @import("std");
const net = std.net;

pub fn udpOperations() !void {
    // UDP Server
    const server_address = try net.Address.parseIp("127.0.0.1", 9090);
    const server_socket = try std.posix.socket(
        server_address.any.family,
        std.posix.SOCK.DGRAM,
        std.posix.IPPROTO.UDP,
    );
    defer std.posix.close(server_socket);
    
    try std.posix.bind(server_socket, &server_address.any, server_address.getOsSockLen());
    
    // UDP Client
    const client_socket = try std.posix.socket(
        std.posix.AF.INET,
        std.posix.SOCK.DGRAM,
        std.posix.IPPROTO.UDP,
    );
    defer std.posix.close(client_socket);
    
    // Send data
    const message = "UDP Hello";
    _ = try std.posix.sendto(
        client_socket,
        message,
        0,
        &server_address.any,
        server_address.getOsSockLen(),
    );
    
    // Receive data
    var buffer: [1024]u8 = undefined;
    var sender_addr: std.posix.sockaddr = undefined;
    var addr_len: std.posix.socklen_t = @sizeOf(std.posix.sockaddr);
    
    const bytes_received = try std.posix.recvfrom(
        server_socket,
        &buffer,
        0,
        &sender_addr,
        &addr_len,
    );
    
    std.debug.print("Received UDP: {s}", .{buffer[0..bytes_received]});
}
```

### Serialization Patterns

Zig provides JSON serialization built into the standard library and supports custom serialization through structured approaches.

**Key points:**

- Built-in JSON parsing and stringification in `std.json`
- Compile-time reflection for automatic serialization
- Custom serialization through reader/writer interfaces
- Binary serialization support through packed structs
- Error handling for malformed data

**Example:**

```zig
const std = @import("std");
const json = std.json;

const Person = struct {
    name: []const u8,
    age: u32,
    email: ?[]const u8 = null,
    active: bool = true,
};

pub fn jsonSerialization(allocator: std.mem.Allocator) !void {
    const person = Person{
        .name = "Alice",
        .age = 30,
        .email = "alice@example.com",
    };
    
    // Serialize to JSON
    const json_string = try json.stringifyAlloc(allocator, person, .{});
    defer allocator.free(json_string);
    std.debug.print("JSON: {s}\n", .{json_string});
    
    // Deserialize from JSON
    const json_data = 
        \\{
        \\  "name": "Bob",
        \\  "age": 25,
        \\  "email": null,
        \\  "active": false
        \\}
    ;
    
    const parsed = try json.parseFromSlice(Person, allocator, json_data, .{});
    defer parsed.deinit();
    
    const bob = parsed.value;
    std.debug.print("Parsed: {} years old, active: {}\n", .{ bob.age, bob.active });
}
```

**Custom serialization patterns:**

```zig
const std = @import("std");

// Serializable interface pattern
fn Serializable(comptime T: type) type {
    return struct {
        pub fn serialize(self: T, writer: anytype) !void {
            // Implementation depends on type
            _ = self;
            _ = writer;
        }
        
        pub fn deserialize(reader: anytype, allocator: std.mem.Allocator) !T {
            // Implementation depends on type
            _ = reader;
            _ = allocator;
            return T{};
        }
    };
}

// Binary serialization
const BinaryMessage = packed struct {
    message_type: u8,
    length: u32,
    timestamp: u64,
    data: [256]u8,
    
    pub fn serialize(self: BinaryMessage, writer: anytype) !void {
        try writer.writeInt(u8, self.message_type, .little);
        try writer.writeInt(u32, self.length, .little);
        try writer.writeInt(u64, self.timestamp, .little);
        try writer.writeAll(&self.data);
    }
    
    pub fn deserialize(reader: anytype) !BinaryMessage {
        return BinaryMessage{
            .message_type = try reader.readInt(u8, .little),
            .length = try reader.readInt(u32, .little),
            .timestamp = try reader.readInt(u64, .little),
            .data = try reader.readBytesNoEof(256),
        };
    }
};
```

### Binary Data Handling

Zig provides comprehensive support for binary data manipulation including endianness handling, bit operations, and memory-mapped access.

**Key points:**

- Explicit endianness specification for cross-platform compatibility
- Packed structs for memory-efficient binary layouts
- Bit manipulation utilities in `std.mem` and `std.math`
- Memory-mapped file access for large binary files
- Type-safe binary reading and writing

**Example:**

```zig
const std = @import("std");

// Binary file format
const FileHeader = packed struct {
    magic: u32,
    version: u16,
    flags: u16,
    data_size: u64,
    checksum: u32,
    reserved: [12]u8,
};

pub fn binaryDataHandling(allocator: std.mem.Allocator) !void {
    // Create binary data
    var header = FileHeader{
        .magic = 0x12345678,
        .version = 1,
        .flags = 0x00FF,
        .data_size = 1024,
        .checksum = 0xDEADBEEF,
        .reserved = std.mem.zeroes([12]u8),
    };
    
    // Write binary data
    const file = try std.fs.cwd().createFile("binary_data.bin", .{});
    defer file.close();
    
    const writer = file.writer();
    
    // Write header with explicit endianness
    try writer.writeInt(u32, header.magic, .little);
    try writer.writeInt(u16, header.version, .little);
    try writer.writeInt(u16, header.flags, .little);
    try writer.writeInt(u64, header.data_size, .little);
    try writer.writeInt(u32, header.checksum, .little);
    try writer.writeAll(&header.reserved);
    
    // Write some data
    const data = try allocator.alloc(u8, header.data_size);
    defer allocator.free(data);
    
    // Fill with pattern
    for (data, 0..) |*byte, i| {
        byte.* = @as(u8, @truncate(i));
    }
    try writer.writeAll(data);
    
    // Read binary data back
    try file.seekTo(0);
    const reader = file.reader();
    
    const read_header = FileHeader{
        .magic = try reader.readInt(u32, .little),
        .version = try reader.readInt(u16, .little),
        .flags = try reader.readInt(u16, .little),
        .data_size = try reader.readInt(u64, .little),
        .checksum = try reader.readInt(u32, .little),
        .reserved = try reader.readBytesNoEof(12),
    };
    
    std.debug.print("Magic: 0x{X}\n", .{read_header.magic});
    std.debug.print("Version: {}\n", .{read_header.version});
    std.debug.print("Data size: {}\n", .{read_header.data_size});
}
```

**Bit manipulation and binary utilities:**

```zig
const std = @import("std");

pub fn bitOperations() void {
    // Bit manipulation
    var flags: u32 = 0;
    
    // Set bits
    flags |= (1 << 0); // Set bit 0
    flags |= (1 << 3); // Set bit 3
    
    // Clear bits
    flags &= ~@as(u32, 1 << 1); // Clear bit 1
    
    // Test bits
    const bit_0_set = (flags & (1 << 0)) != 0;
    const bit_1_set = (flags & (1 << 1)) != 0;
    
    std.debug.print("Bit 0: {}, Bit 1: {}\n", .{ bit_0_set, bit_1_set });
    
    // Byte swapping for endianness
    const value: u32 = 0x12345678;
    const swapped = @byteSwap(value);
    std.debug.print("Original: 0x{X}, Swapped: 0x{X}\n", .{ value, swapped });
    
    // Memory operations
    var buffer = [_]u8{ 1, 2, 3, 4, 5 };
    std.mem.reverse(u8, &buffer);
    std.debug.print("Reversed: {any}\n", .{buffer});
    
    // Copy with overlap detection
    std.mem.copyForwards(u8, buffer[1..4], buffer[0..3]);
    std.debug.print("After copy: {any}\n", .{buffer});
}
```

**Output:** [Inference] Binary data handling in Zig emphasizes type safety and explicit control over memory layout, endianness, and data representation while maintaining cross-platform compatibility.

**Conclusion:** Zig's I/O operations provide comprehensive, cross-platform functionality with explicit error handling and memory safety. The system balances performance with safety through zero-cost abstractions while maintaining explicit control over resource management and data representation.

---

