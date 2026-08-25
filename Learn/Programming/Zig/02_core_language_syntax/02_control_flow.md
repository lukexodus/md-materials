## Control Flow


Control flow in Zig provides structured mechanisms for directing program execution through conditional logic, iteration, and flow control statements. The language emphasizes explicitness and compile-time verification while maintaining runtime performance.

### Conditional Statements

Zig's conditional statements require boolean expressions without implicit type conversions. The language distinguishes between optional values and boolean conditions, preventing common programming errors found in C-style languages.

#### Basic If-Else Structure

The `if` statement evaluates boolean expressions and executes code blocks based on the result. Zig requires explicit boolean values, rejecting integer or pointer comparisons that rely on implicit truthiness.

```zig
if (condition) {
    // execute when true
} else if (other_condition) {
    // alternative condition
} else {
    // default case
}
```

#### Optional Value Handling

Zig integrates optional value unwrapping directly into conditional statements, combining null checking with value extraction in a single operation.

```zig
if (optional_value) |unwrapped| {
    // use unwrapped value when not null
} else {
    // handle null case
}
```

This pattern eliminates null pointer dereferences at compile time by requiring explicit handling of optional values.

#### Error Union Conditionals

Error unions can be tested and unwrapped within conditional statements, enabling clean error handling patterns without try-catch mechanisms.

```zig
if (error_union_result) |success_value| {
    // handle successful result
} else |error_value| {
    // handle error case
}
```

### Switch Expressions

Zig implements switch as expressions rather than statements, meaning they produce values and can be used in assignments and function returns. Switch expressions must handle all possible cases exhaustively.

#### Exhaustive Pattern Matching

Switch expressions require coverage of all possible values for the switched expression's type. The compiler enforces exhaustiveness, preventing runtime errors from unhandled cases.

```zig
const result = switch (enum_value) {
    .option_a => "first choice",
    .option_b => "second choice",
    .option_c => "third choice",
};
```

#### Range and Multiple Value Matching

Switch cases can match ranges of values or multiple discrete values within a single case block.

```zig
const category = switch (number) {
    0 => "zero",
    1...10 => "small",
    11, 12, 13 => "teens start",
    14...19 => "teens continue",
    else => "large",
};
```

#### Capture Groups

Switch expressions can capture matched values for use within case blocks, particularly useful with union types and tagged enums.

```zig
switch (tagged_union) {
    .variant_a => |payload| handleVariantA(payload),
    .variant_b => |payload| handleVariantB(payload),
}
```

### Loop Constructs

Zig provides three primary loop constructs: `while`, `for`, and loop labels for complex control flow scenarios. Each loop type serves specific iteration patterns while maintaining explicit behavior.

#### While Loops

While loops continue execution while a boolean condition remains true. Zig supports optional value unwrapping and continue expressions within while loop conditions.

```zig
while (condition) {
    // loop body
}

// with continue expression
while (condition) : (continue_expression) {
    // loop body
}

// with optional unwrapping
while (getNextItem()) |item| {
    processItem(item);
}
```

#### For Loops

For loops iterate over arrays, slices, and ranges with automatic index and value extraction. The loop variable scope is limited to the loop body.

```zig
// iterate over array
for (array) |item| {
    processItem(item);
}

// with index access
for (array, 0..) |item, index| {
    processWithIndex(item, index);
}

// range iteration
for (0..10) |i| {
    doSomething(i);
}
```

#### Loop Labels and Control

Loop labels enable precise control over nested loop structures, allowing break and continue statements to target specific loop levels.

```zig
outer: while (outer_condition) {
    inner: while (inner_condition) {
        if (break_both) break :outer;
        if (continue_outer) continue :outer;
        break :inner;
    }
}
```

### Break and Continue Statements

Break and continue statements provide fine-grained control over loop execution flow. These statements can target specific loops using labels and can carry values when breaking from loop expressions.

#### Basic Break and Continue

Break terminates loop execution immediately, while continue skips to the next iteration. Both statements respect loop label targets when specified.

```zig
while (condition) {
    if (should_skip) continue;
    if (should_exit) break;
    // normal processing
}
```

#### Break with Values

Loops can function as expressions by breaking with values, enabling loops to produce results based on their execution.

```zig
const result = while (iterator.next()) |item| {
    if (item.matches_criteria) {
        break item.value;
    }
} else default_value;
```

#### Nested Loop Control

Labels enable break and continue statements to affect outer loops from within nested structures, providing precise control flow management.

**Key points** for loop control include understanding label scope, value propagation through break statements, and the interaction between optional unwrapping and loop termination.

### Unreachable and Panic

Zig provides mechanisms for handling impossible code paths and runtime assertion failures through `unreachable` and `panic` functions.

#### Unreachable Statements

The `unreachable` keyword marks code paths that should never execute during normal program operation. Reaching unreachable code results in undefined behavior in optimized builds and panic in debug builds.

```zig
switch (enum_value) {
    .known_case_a => handleA(),
    .known_case_b => handleB(),
    // all cases handled, this should never execute
    else => unreachable,
}
```

[Inference] The compiler may optimize code assuming unreachable paths never execute, potentially removing dead code and enabling aggressive optimizations.

#### Panic Function

The `panic` function terminates program execution with an error message. Unlike exceptions, panics cannot be caught and represent unrecoverable errors.

```zig
if (critical_invariant_violated) {
    panic("Critical system invariant failed");
}
```

#### Debug vs Release Behavior

[Unverified] The behavior of unreachable and panic statements may differ between debug and release builds, with debug builds providing more diagnostic information and release builds optimizing for performance.

**Debug mode characteristics:**

- Unreachable statements trigger panic with location information
- Panic messages include stack traces and debugging details
- Additional runtime checking for undefined behavior

**Release mode characteristics:**

- Unreachable statements enable compiler optimizations
- Panic overhead minimized for performance
- Reduced diagnostic information in error messages

#### Safety and Performance Trade-offs

Using unreachable and panic involves balancing safety verification against performance optimization. Unreachable enables compiler optimizations but can lead to undefined behavior if assumptions prove incorrect.

**Best practices include:**

- Use unreachable only for provably impossible code paths
- Prefer explicit error handling over panic for recoverable errors
- Document assumptions that lead to unreachable statements
- Test edge cases that might reach supposedly unreachable code

### Control Flow Integration

Zig's control flow constructs integrate seamlessly with the language's type system, error handling, and memory management. Optional values, error unions, and tagged unions work naturally within conditional and loop structures.

#### Error Propagation Patterns

Control flow statements can propagate errors up the call stack using the `try` keyword, integrating error handling with normal program flow.

```zig
while (try getNextItem()) |item| {
    try processItem(item);
}
```

#### Compile-time Control Flow

[Inference] Control flow statements can execute at compile time when used within comptime contexts, enabling conditional compilation and code generation based on compile-time conditions.

**Comptime control flow enables:**

- Conditional feature inclusion based on target platform
- Loop unrolling for performance-critical code sections
- Template-like behavior without traditional macro systems
- Configuration-driven code specialization

### Performance Characteristics

Zig's control flow constructs compile to efficient machine code without hidden overhead. The explicit nature of control flow statements enables predictable performance analysis.

**Performance considerations:**

- Switch expressions compile to jump tables when appropriate
- Loop constructs generate optimized assembly without bounds checking overhead
- Break and continue statements compile to direct jumps
- Unreachable statements enable aggressive compiler optimizations

[Unverified] The specific optimization strategies may vary based on compiler version and target architecture, though the general principles of zero-overhead abstraction apply consistently.

**Key points** for control flow performance include understanding when bounds checking occurs, how switch statement optimization works, and the performance implications of different loop patterns in performance-critical code sections.

Related topics include error handling patterns, compile-time programming techniques, optimization strategies for control flow-heavy code, and debugging approaches for complex control flow scenarios.

---

