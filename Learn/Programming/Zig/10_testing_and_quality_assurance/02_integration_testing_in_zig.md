## Integration Testing in Zig


### End-to-End Testing Patterns

#### Test Organization Structure

Zig's testing framework supports comprehensive end-to-end testing through `test` blocks and the `std.testing` module:

```zig
const std = @import("std");
const testing = std.testing;
const expect = testing.expect;

// Complete workflow testing
test "user registration and login flow" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    
    // Initialize system components
    var database = try Database.init(allocator);
    defer database.deinit();
    
    var auth_service = AuthService.init(&database);
    var user_service = UserService.init(&database);
    
    // Test complete user flow
    const user_data = UserRegistration{
        .username = "testuser",
        .email = "test@example.com",
        .password = "secure_password",
    };
    
    // Registration
    const user_id = try user_service.register(user_data);
    try expect(user_id > 0);
    
    // Email verification simulation
    const verification_token = try user_service.getVerificationToken(user_id);
    try user_service.verifyEmail(verification_token);
    
    // Login attempt
    const session = try auth_service.login("testuser", "secure_password");
    try expect(session.user_id == user_id);
    try expect(session.is_valid);
}
```

#### Test Data Management

```zig
const TestDataManager = struct {
    allocator: std.mem.Allocator,
    temp_files: std.ArrayList([]const u8),
    
    fn init(allocator: std.mem.Allocator) TestDataManager {
        return TestDataManager{
            .allocator = allocator,
            .temp_files = std.ArrayList([]const u8).init(allocator),
        };
    }
    
    fn createTempDatabase(self: *TestDataManager) ![]const u8 {
        const temp_path = try std.fmt.allocPrint(
            self.allocator,
            "/tmp/test_db_{d}.sqlite",
            .{std.time.timestamp()},
        );
        try self.temp_files.append(temp_path);
        
        // Initialize test database with schema
        var db = try sqlite.Database.init(temp_path);
        defer db.deinit();
        try db.exec("CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT)");
        
        return temp_path;
    }
    
    fn cleanup(self: *TestDataManager) void {
        for (self.temp_files.items) |path| {
            std.fs.deleteFileAbsolute(path) catch {};
            self.allocator.free(path);
        }
        self.temp_files.deinit();
    }
};
```

### System Testing Approaches

#### Component Integration Testing

```zig
test "microservice communication flow" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    
    // Start mock services
    var user_service = try MockUserService.start(allocator, 8001);
    defer user_service.stop();
    
    var order_service = try MockOrderService.start(allocator, 8002);
    defer order_service.stop();
    
    var api_gateway = try ApiGateway.init(allocator);
    defer api_gateway.deinit();
    
    // Configure service endpoints
    try api_gateway.addService("users", "http://localhost:8001");
    try api_gateway.addService("orders", "http://localhost:8002");
    
    // Test cross-service workflow
    const client = try HttpClient.init(allocator);
    defer client.deinit();
    
    // Create user through gateway
    const create_user_response = try client.post(
        "http://localhost:8000/api/users",
        .{ .name = "John Doe", .email = "john@example.com" },
    );
    try expect(create_user_response.status_code == 201);
    
    const user_id = create_user_response.json.get("id").?.integer;
    
    // Create order for user
    const create_order_response = try client.post(
        "http://localhost:8000/api/orders",
        .{ .user_id = user_id, .amount = 99.99 },
    );
    try expect(create_order_response.status_code == 201);
}
```

#### Database Integration Testing

```zig
test "database transaction integrity" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    
    var test_data = TestDataManager.init(allocator);
    defer test_data.cleanup();
    
    const db_path = try test_data.createTempDatabase();
    var db = try Database.init(db_path);
    defer db.deinit();
    
    // Test transaction rollback
    var transaction = try db.beginTransaction();
    errdefer transaction.rollback();
    
    try transaction.exec("INSERT INTO users (name) VALUES (?)", .{"User 1"});
    try transaction.exec("INSERT INTO users (name) VALUES (?)", .{"User 2"});
    
    // Simulate error condition
    const should_fail = true;
    if (should_fail) {
        transaction.rollback();
    } else {
        try transaction.commit();
    }
    
    // Verify rollback worked
    const count = try db.queryScalar(u32, "SELECT COUNT(*) FROM users", .{});
    try expect(count == 0);
}
```

### Performance Testing

#### Benchmark Framework Integration

```zig
const Benchmark = struct {
    name: []const u8,
    setup_fn: ?*const fn (std.mem.Allocator) anyerror!void,
    benchmark_fn: *const fn (std.mem.Allocator) anyerror!void,
    cleanup_fn: ?*const fn () void,
    iterations: u32,
    
    fn run(self: Benchmark, allocator: std.mem.Allocator) !BenchmarkResult {
        if (self.setup_fn) |setup| {
            try setup(allocator);
        }
        defer if (self.cleanup_fn) |cleanup| cleanup();
        
        const start_time = std.time.nanoTimestamp();
        
        var i: u32 = 0;
        while (i < self.iterations) : (i += 1) {
            try self.benchmark_fn(allocator);
        }
        
        const end_time = std.time.nanoTimestamp();
        const total_duration = @as(u64, @intCast(end_time - start_time));
        
        return BenchmarkResult{
            .name = self.name,
            .total_duration_ns = total_duration,
            .iterations = self.iterations,
            .avg_duration_ns = total_duration / self.iterations,
        };
    }
};

test "API endpoint performance benchmark" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    
    const benchmark = Benchmark{
        .name = "user_creation_api",
        .setup_fn = setupTestServer,
        .benchmark_fn = benchmarkUserCreation,
        .cleanup_fn = cleanupTestServer,
        .iterations = 1000,
    };
    
    const result = try benchmark.run(allocator);
    
    // Performance assertions
    try expect(result.avg_duration_ns < 50_000_000); // < 50ms average
    
    std.debug.print("Benchmark: {s}\n", .{result.name});
    std.debug.print("Average duration: {d}ns\n", .{result.avg_duration_ns});
    std.debug.print("Total iterations: {d}\n", .{result.iterations});
}
```

#### Memory Performance Testing

```zig
test "memory usage under load" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    
    var memory_tracker = MemoryTracker.init(allocator);
    defer memory_tracker.deinit();
    
    const tracked_allocator = memory_tracker.allocator();
    
    // Simulate high-memory operations
    var data_structures = std.ArrayList(*std.ArrayList(u8)).init(tracked_allocator);
    defer {
        for (data_structures.items) |list| {
            list.deinit();
            tracked_allocator.destroy(list);
        }
        data_structures.deinit();
    }
    
    var i: u32 = 0;
    while (i < 1000) : (i += 1) {
        var list = try tracked_allocator.create(std.ArrayList(u8));
        list.* = std.ArrayList(u8).init(tracked_allocator);
        
        var j: u32 = 0;
        while (j < 1000) : (j += 1) {
            try list.append(@as(u8, @intCast(j % 256)));
        }
        
        try data_structures.append(list);
    }
    
    const peak_memory = memory_tracker.getPeakUsage();
    const current_memory = memory_tracker.getCurrentUsage();
    
    try expect(peak_memory < 100 * 1024 * 1024); // < 100MB peak
    
    std.debug.print("Peak memory usage: {d} bytes\n", .{peak_memory});
    std.debug.print("Current memory usage: {d} bytes\n", .{current_memory});
}
```

### Stress Testing Methodologies

#### Concurrent Load Testing

```zig
test "concurrent user load stress test" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    
    // Start test server
    var server = try TestServer.start(allocator, 8080);
    defer server.stop();
    
    const num_threads = 50;
    const requests_per_thread = 100;
    
    var threads = try allocator.alloc(std.Thread, num_threads);
    defer allocator.free(threads);
    
    var results = try allocator.alloc(StressTestResult, num_threads);
    defer allocator.free(results);
    
    // Launch concurrent stress test threads
    for (threads, 0..) |*thread, i| {
        thread.* = try std.Thread.spawn(.{}, stressTestWorker, .{
            allocator,
            requests_per_thread,
            &results[i],
        });
    }
    
    // Wait for all threads to complete
    for (threads) |thread| {
        thread.join();
    }
    
    // Analyze results
    var total_requests: u32 = 0;
    var total_failures: u32 = 0;
    var total_duration: u64 = 0;
    
    for (results) |result| {
        total_requests += result.requests_completed;
        total_failures += result.failures;
        total_duration += result.total_duration_ns;
    }
    
    const success_rate = @as(f64, @floatFromInt(total_requests - total_failures)) / 
                        @as(f64, @floatFromInt(total_requests));
    
    try expect(success_rate > 0.95); // > 95% success rate under stress
    
    std.debug.print("Stress test results:\n");
    std.debug.print("Total requests: {d}\n", .{total_requests});
    std.debug.print("Success rate: {d:.2}%\n", .{success_rate * 100});
}

fn stressTestWorker(
    allocator: std.mem.Allocator,
    num_requests: u32,
    result: *StressTestResult,
) void {
    const start_time = std.time.nanoTimestamp();
    
    var client = HttpClient.init(allocator) catch return;
    defer client.deinit();
    
    result.* = StressTestResult{};
    
    var i: u32 = 0;
    while (i < num_requests) : (i += 1) {
        const response = client.get("http://localhost:8080/api/health") catch {
            result.failures += 1;
            continue;
        };
        
        if (response.status_code == 200) {
            result.requests_completed += 1;
        } else {
            result.failures += 1;
        }
        
        // Small delay to prevent overwhelming
        std.time.sleep(1_000_000); // 1ms
    }
    
    const end_time = std.time.nanoTimestamp();
    result.total_duration_ns = @as(u64, @intCast(end_time - start_time));
}
```

#### Resource Exhaustion Testing

```zig
test "resource exhaustion resilience" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();
    
    // Test file descriptor exhaustion
    var file_handles = std.ArrayList(std.fs.File).init(allocator);
    defer {
        for (file_handles.items) |file| {
            file.close();
        }
        file_handles.deinit();
    }
    
    // Try to exhaust file descriptors
    var fd_exhausted = false;
    while (!fd_exhausted) {
        const temp_file = std.fs.cwd().createFile(
            "temp_stress_file",
            .{ .read = true, .truncate = true },
        ) catch {
            fd_exhausted = true;
            break;
        };
        
        file_handles.append(temp_file) catch break;
        
        if (file_handles.items.len > 10000) {
            // Prevent infinite loop
            break;
        }
    }
    
    // Test system behavior under resource constraints
    var service = TestService.init(allocator) catch |err| switch (err) {
        error.OutOfMemory, error.SystemResources => {
            // Expected under stress conditions
            return;
        },
        else => return err,
    };
    defer service.deinit();
    
    // Verify graceful degradation
    const response = service.handleRequest("test_request") catch |err| switch (err) {
        error.ServiceUnavailable => {
            // Acceptable under stress
            return;
        },
        else => return err,
    };
    
    try expect(response.len > 0);
}
```

### Continuous Integration Setup

#### Build Configuration

```zig
// build.zig for CI integration
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    
    // Main executable
    const exe = b.addExecutable(.{
        .name = "myapp",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    
    b.installArtifact(exe);
    
    // Unit tests
    const unit_tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });
    
    // Integration tests
    const integration_tests = b.addTest(.{
        .root_source_file = .{ .path = "tests/integration.zig" },
        .target = target,
        .optimize = optimize,
    });
    
    // Performance tests
    const perf_tests = b.addTest(.{
        .root_source_file = .{ .path = "tests/performance.zig" },
        .target = target,
        .optimize = optimize,
    });
    
    // Test steps
    const run_unit_tests = b.addRunArtifact(unit_tests);
    const run_integration_tests = b.addRunArtifact(integration_tests);
    const run_perf_tests = b.addRunArtifact(perf_tests);
    
    // Test suite step
    const test_step = b.step("test", "Run all tests");
    test_step.dependOn(&run_unit_tests.step);
    
    const integration_step = b.step("test-integration", "Run integration tests");
    integration_step.dependOn(&run_integration_tests.step);
    
    const perf_step = b.step("test-performance", "Run performance tests");
    perf_step.dependOn(&run_perf_tests.step);
    
    // Coverage step (if using kcov or similar)
    const coverage_step = b.step("coverage", "Generate test coverage");
    coverage_step.dependOn(&run_unit_tests.step);
    coverage_step.dependOn(&run_integration_tests.step);
}
```

#### GitHub Actions Workflow

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    strategy:
      matrix:
        zig-version: [0.11.0, master]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Zig
      uses: goto-bus-stop/setup-zig@v2
      with:
        version: ${{ matrix.zig-version }}
    
    - name: Run unit tests
      run: zig build test
    
    - name: Run integration tests
      run: zig build test-integration
      
    - name: Run performance tests
      run: zig build test-performance
    
    - name: Generate coverage
      run: |
        sudo apt-get install kcov
        zig build test --prefix-exe kcov --prefix-exe-args "--include-pattern=/src/" --prefix-exe-args coverage/
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        directory: ./coverage
```

#### Test Environment Management

```zig
const TestEnvironment = struct {
    allocator: std.mem.Allocator,
    temp_dir: []const u8,
    services: std.ArrayList(*TestService),
    cleanup_tasks: std.ArrayList(*const fn () void),
    
    fn init(allocator: std.mem.Allocator) !TestEnvironment {
        const temp_dir = try std.fmt.allocPrint(
            allocator,
            "/tmp/test_env_{d}",
            .{std.time.timestamp()},
        );
        
        try std.fs.makeDirAbsolute(temp_dir);
        
        return TestEnvironment{
            .allocator = allocator,
            .temp_dir = temp_dir,
            .services = std.ArrayList(*TestService).init(allocator),
            .cleanup_tasks = std.ArrayList(*const fn () void).init(allocator),
        };
    }
    
    fn addService(self: *TestEnvironment, service: *TestService) !void {
        try self.services.append(service);
        try service.start();
    }
    
    fn cleanup(self: *TestEnvironment) void {
        // Stop services
        for (self.services.items) |service| {
            service.stop();
        }
        self.services.deinit();
        
        // Run cleanup tasks
        for (self.cleanup_tasks.items) |task| {
            task();
        }
        self.cleanup_tasks.deinit();
        
        // Remove temp directory
        std.fs.deleteTreeAbsolute(self.temp_dir) catch {};
        self.allocator.free(self.temp_dir);
    }
};
```

**Key Points:**

- Integration tests should validate complete workflows end-to-end
- Performance testing requires consistent measurement methodology [Inference]
- Stress testing reveals system behavior under resource constraints
- CI pipelines should include multiple test categories with appropriate timeouts
- Test isolation prevents interference between test cases

**Examples of test categorization:**

- Unit tests: Fast, isolated, no external dependencies
- Integration tests: Medium speed, real components, controlled environment
- Performance tests: Longer running, resource monitoring, baseline comparisons
- Stress tests: Extended duration, resource exhaustion scenarios

Important related topics: Test data generation and fixtures, Mock and stub implementations, Test reporting and metrics collection, Database testing strategies with transactions.

---

