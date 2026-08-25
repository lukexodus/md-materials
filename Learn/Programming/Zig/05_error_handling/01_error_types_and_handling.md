## Error Types and Handling


Zig implements a unique error handling system based on error union types that combines explicit error management with performance efficiency. The system requires programmers to handle errors explicitly while avoiding the runtime overhead of exception-based mechanisms.

### Error Union Types

Error union types represent values that can be either successful results or error conditions. Zig expresses these types using the `ErrorType!ReturnType` syntax, creating a tagged union that contains either an error or a successful value.

#### Basic Error Union Declaration

Error unions combine a specific error set with a return type, creating a single type that represents both success and failure cases.

```zig
const FileError = error{
    AccessDenied,
    FileNotFound,
    OutOfMemory,
};

fn openFile(path: []const u8) FileError!File {
    // function returns either FileError or File
}
```

The exclamation mark operator creates the union between the error set and the return type, enabling functions to return either successful values or specific error conditions.

#### Inferred Error Sets

Zig can infer error sets automatically when functions don't explicitly declare their error types. The compiler analyzes the function body to determine all possible error conditions.

```zig
fn processData() !Result {
    // compiler infers possible errors from function body
    var file = try openFile("data.txt");
    var result = try parseContent(file);
    return result;
}
```

[Inference] The compiler builds the inferred error set by analyzing all error-returning operations within the function, creating the minimal necessary error set.

#### Error Union Storage

Error unions store either an error value or a success value, but never both simultaneously. The representation uses tagged union semantics with efficient memory layout.

```zig
var result: FileError!i32 = 42;        // contains success value
result = FileError.FileNotFound;       // now contains error
```

[Unverified] The specific memory layout may optimize for common cases, potentially storing small success values inline with error tags to minimize memory overhead.

### Try Expressions

Try expressions provide syntactic sugar for error propagation, automatically returning errors to the calling function while unwrapping successful values for continued processing.

#### Basic Try Syntax

The `try` keyword attempts to unwrap an error union, returning the error immediately if present or continuing with the unwrapped value if successful.

```zig
fn processFile(path: []const u8) !void {
    var file = try openFile(path);      // returns error if openFile fails
    var content = try readFile(file);   // returns error if readFile fails
    try processContent(content);        // returns error if processContent fails
}
```

Try expressions eliminate explicit error checking code while maintaining explicit error propagation behavior.

#### Try with Error Transformation

Try expressions can transform errors during propagation, converting specific error types into different error sets as needed.

```zig
fn wrapperFunction() WrapperError!Result {
    var result = try processFile("input.txt") catch |err| switch (err) {
        FileError.FileNotFound => WrapperError.InputMissing,
        FileError.AccessDenied => WrapperError.PermissionError,
        else => return err,
    };
    return result;
}
```

#### Try Expression Performance

Try expressions compile to efficient conditional branches that check error conditions without function call overhead or stack unwinding mechanisms.

**Performance characteristics:**

- Single conditional branch for error checking
- No stack unwinding or cleanup code generation
- Direct register passing for success values
- Minimal code size increase compared to manual checking

### Catch Expressions

Catch expressions provide error handling mechanisms that can recover from errors, transform error values, or provide default values when errors occur.

#### Basic Catch Syntax

The `catch` operator handles errors by providing alternative execution paths when error conditions are encountered.

```zig
var result = openFile("config.txt") catch default_config;
var value = parseInt(input_string) catch 0;
```

Catch expressions can provide immediate values or execute complex error handling logic depending on the application requirements.

#### Catch with Error Payload

Catch expressions can capture the specific error value for detailed error handling or logging purposes.

```zig
var file = openFile(path) catch |err| {
    std.log.err("Failed to open file: {}", .{err});
    return err;
};
```

The error payload enables sophisticated error handling strategies that depend on the specific error condition encountered.

#### Catch Expression Chaining

Multiple catch expressions can be chained to handle different error conditions with increasing levels of fallback behavior.

```zig
var config = loadConfig("primary.conf") catch 
            loadConfig("backup.conf") catch 
            loadConfig("default.conf") catch 
            createDefaultConfig();
```

#### Catch with Unreachable

When programmers can prove that errors cannot occur in specific contexts, catch expressions can use `unreachable` to indicate impossible error conditions.

```zig
var result = knownSafeOperation() catch unreachable;
```

[Inference] The compiler may optimize code paths with unreachable catch handlers, potentially eliminating error checking code entirely when it can prove safety.

### Error Propagation Patterns

Zig supports several patterns for propagating errors through call stacks while maintaining explicit control over error handling strategies.

#### Automatic Error Propagation

Try expressions automatically propagate errors up the call stack without requiring explicit error handling at intermediate levels.

```zig
fn highLevel() !Result {
    return try midLevel();
}

fn midLevel() !Result {
    return try lowLevel();
}

fn lowLevel() !Result {
    // actual error generation or success
}
```

This pattern enables clean separation between error generation and error handling while maintaining explicit error types.

#### Error Set Union

Functions can declare error sets that combine multiple possible error sources, creating unified error handling interfaces.

```zig
const CombinedError = FileError || NetworkError || ParseError;

fn complexOperation() CombinedError!Result {
    var file_data = try readFile("input.txt");
    var network_data = try fetchData(url);
    var parsed = try parseData(file_data, network_data);
    return parsed;
}
```

#### Selective Error Handling

Error propagation can be selective, handling specific errors while propagating others to higher-level handlers.

```zig
fn robustOperation() !Result {
    var result = criticalOperation() catch |err| switch (err) {
        OperationError.Recoverable => try recoverAndRetry(),
        OperationError.Temporary => {
            std.time.sleep(1000);
            return try robustOperation();
        },
        else => return err,
    };
    return result;
}
```

#### Error Context Preservation

[Inference] Error propagation maintains error context information, enabling debugging and logging systems to trace error origins through multiple call levels.

**Key points** for error propagation include understanding when to handle errors versus when to propagate them, managing error set compatibility across function boundaries, and maintaining performance while providing adequate error information.

### Custom Error Types

Zig enables definition of custom error types that represent domain-specific error conditions with meaningful names and semantic information.

#### Error Set Declaration

Custom error sets define specific error conditions relevant to particular domains or modules.

```zig
const DatabaseError = error{
    ConnectionFailed,
    QueryTimeout,
    InvalidSchema,
    DataCorruption,
    InsufficientPermissions,
};
```

Error sets provide namespace isolation and semantic clarity for error conditions specific to different system components.

#### Global Error Sets

The global error set includes all possible errors that can occur within a program, enabling generic error handling when specific error types are unknown.

```zig
fn genericHandler(operation: anytype) anyerror!void {
    operation() catch |err| {
        std.log.err("Operation failed: {}", .{err});
        return err;
    };
}
```

#### Error Documentation and Semantics

Custom error types serve as documentation for the failure modes of functions and systems, making error conditions explicit in the type system.

```zig
/// Represents errors that can occur during JSON parsing
const JsonError = error{
    /// Input contains invalid JSON syntax
    InvalidSyntax,
    /// JSON structure exceeds maximum depth
    TooDeep,
    /// Required field missing from JSON object
    MissingField,
    /// Field contains wrong type for expected value
    WrongType,
};
```

Documentation comments on error types provide semantic information about when and why specific errors occur.

#### Error Set Composition

Complex systems can compose error sets from multiple sources, creating hierarchical error handling strategies.

```zig
const SystemError = DatabaseError || NetworkError || FileSystemError;
const ApplicationError = SystemError || BusinessLogicError || ValidationError;

fn applicationOperation() ApplicationError!Result {
    // can fail with any error from the composed set
}
```

### Integration with Type System

Zig's error handling integrates seamlessly with the language's type system, providing compile-time verification of error handling completeness.

#### Exhaustive Error Handling

The compiler can verify that all possible errors from an error set are handled when using switch expressions on caught errors.

```zig
processData() catch |err| switch (err) {
    ProcessError.InvalidInput => handleInvalidInput(),
    ProcessError.OutOfMemory => handleMemoryError(),
    ProcessError.NetworkFailure => handleNetworkError(),
    // compiler ensures all ProcessError variants are covered
};
```

#### Error Union Coercion

Error unions can be coerced to wider error sets automatically, enabling flexible error handling across different abstraction levels.

```zig
fn specificFunction() SpecificError!Result { ... }
fn genericFunction() anyerror!Result {
    return try specificFunction();  // automatic coercion
}
```

#### Optional Integration

Error unions can combine with optional types to represent operations that might fail or return no value.

```zig
fn findItem(criteria: Criteria) FindError!?Item {
    var result = try searchDatabase(criteria);
    return if (result.isEmpty()) null else result.item;
}
```

### Performance and Optimization

Zig's error handling system provides excellent performance characteristics while maintaining safety and explicitness.

#### Zero-Cost Abstractions

Error handling compiles to efficient machine code without runtime overhead beyond simple conditional branches for error checking.

**Performance benefits:**

- No exception unwinding or cleanup overhead
- Direct register passing for success values
- Minimal code size increase for error paths
- Predictable performance characteristics

#### Compiler Optimizations

[Unverified] The compiler may perform various optimizations on error handling code, though specific optimization strategies depend on compiler implementation details.

**Potential optimizations:**

- Elimination of error checking when success can be proven
- Inlining of simple catch expressions
- Branch prediction hints for common success paths
- Dead code elimination for unreachable error paths

#### Error Path Optimization

Error handling paths can be optimized for the uncommon case, keeping success paths fast while still providing comprehensive error information.

```zig
fn optimizedOperation() !Result {
    // success path optimized for performance
    var result = try fastOperation();
    return result;
} catch |err| {
    // error path can include expensive logging/cleanup
    logDetailedError(err);
    return err;
};
```

**Key points** for error handling performance include understanding the cost of different error propagation strategies, optimizing for common success cases, and balancing error information richness against performance requirements.

Related topics include error handling patterns in concurrent code, integration with logging and monitoring systems, error recovery strategies for long-running applications, and designing error hierarchies for large-scale systems.

---

